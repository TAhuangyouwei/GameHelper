/* Run in Max 2021/2024 or 3dsmaxbatch. Creates and deletes only its own nodes.
   Does not open, reset, or save any .max scene; uses a separate clipboard file.
*/
(
    local base = pathConfig.appendPath (getFilenamePath (getThisScriptFilename())) "../../"
    local oldNoUI = ::CGH_PoseClipboardNoUI
    ::CGH_PoseClipboardNoUI = true
    fileIn (base + "scripts/实用工具/动画/跨Max姿势剪贴板.ms")
    ::CGH_PoseClipboardNoUI = oldNoUI
    local tool = CGH_PoseClipboardStruct()
    local token = tool.uniqueId()
    local prefix = "PoseTest_" + token
    tool.cachePath = (getDir #temp) + "\\" + prefix + ".xml"
    local created = #()
    local failure = undefined
    fn check condition message = (if not condition do throw message)
    fn closeTM a b =
    (
        local equal = true
        for row = 1 to 4 where distance a[row] b[row] > 0.001 do equal = false
        equal
    )
    fn keyTimes ctrl = (for index = 1 to numKeys ctrl collect getKeyTime ctrl index)
    try
    (
        -- Exercise the real default path too; cachePath below bypasses this in scene tests.
        local defaultTool = CGH_PoseClipboardStruct()
        local localAppData = (dotNetClass "System.Environment").GetFolderPath (dotNetClass "System.Environment+SpecialFolder").LocalApplicationData
        local expectedPath = (dotNetClass "System.IO.Path").Combine localAppData "GameHelper\\PoseClipboard.xml"
        check (defaultTool.getCachePath() == expectedPath) "default cross-Max clipboard path"
        check (tool.getCachePath() == tool.cachePath) "test clipboard path override"
        -- An empty .NET XmlNodeList must reach validation, not fail MXS collection mapping.
        local emptyDoc = dotNetObject "System.Xml.XmlDocument"
        emptyDoc.LoadXml "<PoseClipboard version='1'/>"
        emptyDoc.DocumentElement.SetAttribute "unitScale" (formattedPrint units.SystemScale format:".9g")
        emptyDoc.DocumentElement.SetAttribute "unitType" (units.SystemType as string)
        emptyDoc.Save tool.cachePath
        local emptyError = ""
        try (tool.pastePose()) catch (emptyError = getCurrentException() as string)
        check (findString emptyError "Pose 缓存为空。" != undefined) "empty XML node list did not reach validation"
        local parent = point name:(prefix + "_parent") pos:[20,0,0]
        append created parent
        local child = boneSys.createBone [25,0,0] [35,0,0] [0,0,1]
        append created child
        child.name = prefix + "_bone"
        child.parent = parent
        rotate child (angleAxis 35 [0,0,1])
        local wanted = child.transform
        local originalController = child.controller
        check (tool.copyPose #(child,parent) == 2) "copy count"
        local boneDoc = tool.loadPose()
        check ((boneDoc.SelectNodes "/PoseClipboard/Node").Count == 2) "Bone XML node list fixture"
        check ((boneDoc.SelectNodes "/PoseClipboard/Biped").Count == 0) "Bone-only XML Biped list fixture"
        parent.pos = [40,20,10]
        child.rotation = quat 0 0 0 1
        local before = child.transform
        local parentBefore = parent.transform
        local boneKeyTimes = keyTimes child.rotation.controller
        local parentKeyTimes = keyTimes parent.position.controller
        -- Rollout buttons run without an undo-on context; Listener-only tests hide this bug.
        with undo off (at time 10 tool.pastePose())
        at time 10 check (closeTM wanted child.transform) "parent-first Bone round trip"
        check (child.controller == originalController) "controller replaced"
        max undo
        at time 10
        (
            check (closeTM before child.transform) "single undo did not restore pose"
            check (closeTM parentBefore parent.transform) "single undo did not restore parent"
        )
        check ((keyTimes child.rotation.controller) as string == boneKeyTimes as string) "undo retained new Bone keys"
        check ((keyTimes parent.position.controller) as string == parentKeyTimes as string) "undo retained new parent keys"
        max redo
        at time 10 check (closeTM wanted child.transform) "Bone redo did not restore pasted pose"
        max undo
        -- Local Bone posture must follow the target parent instead of restoring world space.
        tool.copyPose #(child)
        local boneLocalPose = child.transform * inverse parent.transform
        parent.pos += [0,30,20]
        rotate parent (angleAxis 60 [1,0,0])
        child.rotation = quat 0 0 0 1
        local movedParent = parent.transform
        tool.pastePose()
        check (closeTM movedParent parent.transform) "partial Bone paste moved its parent"
        check (closeTM boneLocalPose (child.transform * inverse parent.transform)) "partial Bone paste did not follow target parent"
        -- Force a late controller failure after Bone edits; cancel must not undo earlier work.
        local blocked = point name:(prefix + "_blocked")
        append created blocked
        blocked.parent = child
        blocked.position.controller = position_script()
        blocked.position.controller.script = "[1,0,0]"
        tool.copyPose #(child,blocked)
        local blockedDoc = tool.loadPose()
        local blockedEntry = (blockedDoc.SelectNodes "/PoseClipboard/Node").Item 1
        blockedEntry.SetAttribute "r4_1" "999"
        blockedDoc.Save tool.cachePath
        rotate child (angleAxis 20 [0,0,1])
        undo "Pose test previous edit" on (parent.pos += [3,0,0])
        local previousEdit = parent.transform
        local failedPasteBefore = child.transform
        local failedKeyTimes = keyTimes child.rotation.controller
        local pasteError = ""
        with undo off (try (tool.pastePose()) catch (pasteError = getCurrentException() as string))
        check (pasteError != "") "controller failure fixture was not rejected"
        check (closeTM failedPasteBefore child.transform) "failed paste did not roll back earlier Bone edits"
        check (closeTM previousEdit parent.transform) "failed paste undid unrelated earlier work"
        check (((keyTimes child.rotation.controller) as string) == (failedKeyTimes as string)) "failed paste retained new keys"
        -- Replace an existing clipboard and ensure a rejected copy preserves it.
        tool.copyPose #(child)
        local replacedDoc = tool.loadPose()
        check ((replacedDoc.SelectNodes "/PoseClipboard/Node").Count == 1) "replacement retained old clipboard nodes"
        tool.copyPose #(parent,child)
        replacedDoc = tool.loadPose()
        check ((replacedDoc.SelectNodes "/PoseClipboard/Node").Count == 2) "consecutive clipboard replacement failed"
        tool.copyPose #(child)
        check ((getFiles (tool.cachePath + ".*.replace.bak")).count == 0) "replacement backup leaked"
        local bytes = (dotNetClass "System.IO.File").ReadAllText tool.cachePath
        local rejected = false
        try (tool.copyPose #()) catch (rejected = true)
        check rejected "empty selection accepted"
        check (bytes == (dotNetClass "System.IO.File").ReadAllText tool.cachePath) "failed copy overwrote clipboard"
        local duplicate = point name:child.name
        append created duplicate
        rejected = false
        try (tool.pastePose()) catch (rejected = true)
        check rejected "duplicate target accepted"
        duplicate.name = prefix + "_duplicate"
        local originalParent = child.parent
        child.parent = undefined
        rejected = false
        try (tool.pastePose()) catch (rejected = true)
        check rejected "mismatched hierarchy accepted"
        child.parent = originalParent

        local bip = biped.createNew 100 0 [0,0,0]
        for node in objects where classOf node == Biped_Object and tool.bipedRoot node == bip do append created node
        local hand = biped.getNode bip #larm link:4
        local ctrl = bip.controller
        local keep = biped.createCopyCollection ctrl (prefix + "_keep")
        local copyCount = biped.numCopyCollections ctrl
        local controller = hand.controller
        local rotation = biped.getTransform hand #rotation
        tool.copyPose #(hand,child)
        check (biped.numCopyCollections ctrl == copyCount) "copy leaked collection"
        biped.setTransform hand #rotation (rotation * quat 25 [0,0,1]) true
        local mixedHandBefore = at time 12 hand.transform
        local mixedBoneBefore = at time 12 child.transform
        local handKeyTimes = keyTimes hand.controller
        boneKeyTimes = keyTimes child.rotation.controller
        with undo off (at time 12 tool.pastePose())
        at time 12 check (closeTM (matrix3 rotation) (matrix3 (biped.getTransform hand #rotation))) "Biped native posture round trip"
        check (hand.controller == controller) "Biped controller replaced"
        check (biped.numCopyCollections ctrl == copyCount) "paste lost or leaked collections"
        check ((biped.getCopyCollection ctrl copyCount).name == keep.name) "existing Biped collection changed"
        local mixedHandAfter = at time 12 hand.transform
        local mixedBoneAfter = at time 12 child.transform
        max undo
        at time 12
        (
            check (closeTM mixedHandBefore hand.transform) "single mixed undo did not restore Biped"
            check (closeTM mixedBoneBefore child.transform) "single mixed undo did not restore Bone"
        )
        check ((keyTimes hand.controller) as string == handKeyTimes as string) "mixed undo retained new Biped keys"
        check ((keyTimes child.rotation.controller) as string == boneKeyTimes as string) "mixed undo retained new Bone keys"
        max redo
        at time 12
        (
            check (closeTM mixedHandAfter hand.transform) "mixed redo did not restore Biped"
            check (closeTM mixedBoneAfter child.transform) "mixed redo did not restore Bone"
        )
        with undo off (at time 13 tool.pastePose())
        check (biped.numCopyCollections ctrl == copyCount) "repeated paste leaked collections"
        -- Copy a finger, raise the arm, then restore only the finger's local posture.
        local finger = biped.getNode bip #lfingers link:1
        local upperArm = biped.getNode bip #larm link:2
        check (finger != undefined) "Biped finger fixture missing"
        biped.setTransform finger #rotation ((biped.getTransform finger #rotation) * (quat 30 [0,0,1])) true
        local fingerLocalPose = finger.transform * inverse finger.parent.transform
        tool.copyPose #(finger)
        at time 14
        (
            biped.setTransform upperArm #rotation ((biped.getTransform upperArm #rotation) * (quat 75 [1,0,0])) true
            biped.setTransform finger #rotation ((biped.getTransform finger #rotation) * (quat -20 [0,0,1])) true
            local raisedArm = upperArm.transform
            local raisedHand = hand.transform
            local fingerParent = finger.parent.transform
            local fingerBefore = finger.transform
            local fingerKeyTimes = keyTimes finger.controller
            with undo off (tool.pastePose())
            check (closeTM raisedArm upperArm.transform) "finger posture paste moved raised arm"
            check (closeTM raisedHand hand.transform) "finger posture paste moved hand"
            check (closeTM fingerParent finger.parent.transform) "finger posture paste moved its parent"
            check (closeTM fingerLocalPose (finger.transform * inverse finger.parent.transform)) "finger local posture changed with raised arm"
            local fingerAfter = finger.transform
            max undo
            check (closeTM fingerBefore finger.transform) "Biped-only undo did not restore finger"
            check ((keyTimes finger.controller) as string == fingerKeyTimes as string) "Biped-only undo changed original key times"
            check (closeTM raisedArm upperArm.transform) "finger undo moved raised arm"
            max redo
            check (closeTM fingerAfter finger.transform) "Biped-only redo did not restore finger"
        )
        biped.deleteCopyCollection ctrl copyCount
        format "PASS: Bone hierarchy, native Biped posture, mixed selection, repeat paste, controller preservation, undo, duplicate/missing hierarchy and atomic clipboard.\n"
    ) catch (failure = getCurrentException())
    with undo on (for node in created where isValidNode node do delete node)
    if doesFileExist tool.cachePath do deleteFile tool.cachePath
    if failure != undefined do throw failure
)
