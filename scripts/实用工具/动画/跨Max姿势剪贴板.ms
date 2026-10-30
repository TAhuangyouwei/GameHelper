/* Single-frame pose clipboard. MAXScript + .NET Framework, target: Max 2021/2024.
   Load in both Max processes. No dependency on the GameHelper main panel.
   Set CGH_PoseClipboardNoUI=true before fileIn for automated tests.
*/
global CGH_PoseClipboard
global CGH_PoseClipboardUI
global CGH_PoseClipboardNoUI

struct CGH_PoseClipboardStruct
(
    cachePath = undefined,

    fn getCachePath =
    (
        if cachePath != undefined then cachePath else
            (dotNetClass "System.IO.Path").Combine (systemTools.getEnvVariable "LOCALAPPDATA") "GameHelper\\PoseClipboard.xml"
    ),

    fn uniqueId = ((dotNetClass "System.Guid").NewGuid()).ToString "N",

    fn parentName node = (if node.parent == undefined then "" else node.parent.name),

    fn bipedRoot node =
    (
        if classOf node == Biped_Object then biped.getNode node #vertical else undefined
    ),

    fn exactNode nodeName =
    (
        local matches = for node in objects where node.name == nodeName collect node
        if matches.count != 1 do throw ("对象缺失或重名：" + nodeName)
        matches[1]
    ),

    fn nodeDepth node =
    (
        local depth = 0
        while node.parent != undefined do (depth += 1; node = node.parent)
        depth
    ),

    fn sortByDepth a b =
    (
        local da = nodeDepth a[1]
        local db = nodeDepth b[1]
        if da < db then -1 else if da > db then 1 else 0
    ),

    fn writeMatrix element tm =
    (
        -- String conversion must not truncate matrix values to the Listener precision.
        for row = 1 to 4 do for col = 1 to 3 do
            element.SetAttribute ("r" + (row as string) + "_" + (col as string)) (formattedPrint tm[row][col] format:".9g")
    ),

    fn readMatrix element =
    (
        local tm = matrix3 1
        for row = 1 to 4 do
        (
            local value = [0,0,0]
            for col = 1 to 3 do
            (
                local numberText = element.GetAttribute ("r" + (row as string) + "_" + (col as string))
                value[col] = (dotNetClass "System.Single").Parse numberText (dotNetClass "System.Globalization.CultureInfo").InvariantCulture
            )
            tm[row] = value
        )
        tm
    ),

    fn copyPose nodes =
    (
        if nodes.count == 0 do throw "请先选择需要复制的骨骼或控制器。"
        local io = dotNetClass "System.IO.File"
        local path = getCachePath()
        local folder = getFilenamePath path
        (dotNetClass "System.IO.Directory").CreateDirectory folder
        local token = uniqueId()
        local staging = path + "." + token + ".tmp"
        local backup = staging + ".replace.bak"
        local cpyPath = folder + token + ".cpy"
        local doc = dotNetObject "System.Xml.XmlDocument"
        local root = doc.CreateElement "PoseClipboard"
        doc.AppendChild root
        root.SetAttribute "version" "1"
        root.SetAttribute "unitScale" (formattedPrint units.SystemScale format:".9g")
        root.SetAttribute "unitType" (units.SystemType as string)
        local bipRoots = #()
        local failure = undefined
        try
        (
            for node in nodes do
            (
                if exactNode node.name != node do throw ("源对象名称不唯一：" + node.name)
                local entry = doc.CreateElement "Node"
                entry.SetAttribute "name" node.name
                entry.SetAttribute "parent" (parentName node)
                entry.SetAttribute "class" ((classOf node) as string)
                local bip = bipedRoot node
                if bip != undefined then
                (
                    entry.SetAttribute "biped" bip.name
                    appendIfUnique bipRoots bip
                )
                else
                (
                    local tm = node.transform
                    if node.parent != undefined do tm = tm * inverse node.parent.transform
                    writeMatrix entry tm
                )
                root.AppendChild entry
            )
            for bip in bipRoots do
            (
                local ctrl = bip.controller
                if ctrl.figureMode do throw "请退出 Biped Figure 模式后复制。"
                local collectionName = "GameHelper_" + token
                local collection = biped.createCopyCollection ctrl collectionName
                local collectionIndex = biped.numCopyCollections ctrl
                local copyFailure = undefined
                try
                (
                    local parts = for node in nodes where bipedRoot node == bip collect node
                    biped.copyBipPosture ctrl collection parts #snapNone
                    biped.saveCopyPasteFile ctrl cpyPath
                    local entry = doc.CreateElement "Biped"
                    entry.SetAttribute "root" bip.name
                    entry.SetAttribute "collection" collectionName
                    entry.InnerText = (dotNetClass "System.Convert").ToBase64String (io.ReadAllBytes cpyPath)
                    root.AppendChild entry
                ) catch (copyFailure = getCurrentException())
                biped.deleteCopyCollection ctrl collectionIndex
                if copyFailure != undefined do throw copyFailure
            )
            doc.Save staging
            -- Publish one complete file; a failed copy leaves the previous pose intact.
            -- Use three String arguments: MXS undefined does not bind to a .NET String null.
            if io.Exists path then io.Replace staging path backup else io.Move staging path
        ) catch (failure = getCurrentException())
        if io.Exists backup do io.Delete backup
        if io.Exists cpyPath do io.Delete cpyPath
        if io.Exists staging do io.Delete staging
        if failure != undefined do throw failure
        nodes.count
    ),

    fn loadPose =
    (
        local path = getCachePath()
        if not doesFileExist path do throw "还没有复制 Pose，请先在源 Max 中复制。"
        -- Read data only, never fileIn/execute clipboard contents.
        local settings = dotNetObject "System.Xml.XmlReaderSettings"
        settings.DtdProcessing = (dotNetClass "System.Xml.DtdProcessing").Prohibit
        settings.XmlResolver = undefined
        local reader = (dotNetClass "System.Xml.XmlReader").Create path settings
        local doc = dotNetObject "System.Xml.XmlDocument"
        local failure = undefined
        try (doc.Load reader) catch (failure = getCurrentException())
        reader.Close()
        if failure != undefined do throw failure
        local root = doc.DocumentElement
        if root.Name != "PoseClipboard" or root.GetAttribute "version" != "1" do throw "Pose 缓存格式不受支持。"
        if (root.GetAttribute "unitType") != (units.SystemType as string) or \
            (root.GetAttribute "unitScale") != (formattedPrint units.SystemScale format:".9g") do
            throw "两个场景的系统单位不同，请先统一系统单位。"
        doc
    ),

    fn pastePose =
    (
        local doc = loadPose()
        local pairs = #()
        local seenNames = #()
        -- XmlNodeList is a .NET collection, not a mappable MAXScript array.
        local nodeEntries = doc.SelectNodes "/PoseClipboard/Node"
        for entryIndex = 0 to (nodeEntries.Count - 1) do
        (
            local entry = nodeEntries.Item entryIndex
            local nodeName = entry.GetAttribute "name"
            if findItem seenNames nodeName > 0 do throw ("缓存中有重复对象：" + nodeName)
            append seenNames nodeName
            local node = exactNode nodeName
            if parentName node != entry.GetAttribute "parent" do throw ("父级不一致：" + nodeName)
            if (classOf node) as string != entry.GetAttribute "class" do throw ("对象类型不一致：" + nodeName)
            if bipedRoot node != undefined then
            (
                if (bipedRoot node).name != entry.GetAttribute "biped" do throw ("Biped 归属不一致：" + nodeName)
            )
            else readMatrix entry -- Validate every numeric value before editing the scene.
            append pairs #(node,entry)
        )
        if pairs.count == 0 do throw "Pose 缓存为空。"
        qsort pairs sortByDepth
        local bips = #()
        local bipedEntries = doc.SelectNodes "/PoseClipboard/Biped"
        for entryIndex = 0 to (bipedEntries.Count - 1) do
        (
            local entry = bipedEntries.Item entryIndex
            local bip = exactNode (entry.GetAttribute "root")
            if bipedRoot bip != bip do throw "目标 Biped 根节点不正确。"
            if bip.controller.figureMode do throw "请退出 Biped Figure 模式后粘贴。"
            append bips #(bip,entry)
        )
        local io = dotNetClass "System.IO.File"
        local cpyPath = (getFilenamePath (getCachePath())) + (uniqueId()) + ".cpy"
        local failure = undefined
        -- Restore all edits together if a controller rejects the operation.
        if theHold.Holding() do throw "请结束当前交互操作后再粘贴。"
        -- Rollout handlers start with MXS undo recording off. A Hold alone does not enable it.
        -- Group the explicit undo context so a failed paste can cancel only its own edits.
        theHold.SuperBegin()
        undo "GameHelper Paste Pose" on
        (
            try
            (
                with animate on
                (
                    for pair in bips do
                    (
                        local ctrl = pair[1].controller
                        local before = biped.numCopyCollections ctrl
                        local pasteFailure = undefined
                        try
                        (
                            io.WriteAllBytes cpyPath ((dotNetClass "System.Convert").FromBase64String pair[2].InnerText)
                            biped.loadCopyPasteFile ctrl cpyPath
                            local collection = undefined
                            for index = before + 1 to biped.numCopyCollections ctrl do
                            (
                                local candidate = biped.getCopyCollection ctrl index
                                if candidate.name == pair[2].GetAttribute "collection" do collection = candidate
                            )
                            if collection == undefined do throw "未找到导入的 Biped 姿势集合。"
                            local posture = getCopy collection #posture 1
                            if not (biped.pasteBipPosture ctrl posture false #pstcopied true true true false) do
                                throw "Biped 拒绝粘贴姿势。"
                        ) catch (pasteFailure = getCurrentException())
                        for index = biped.numCopyCollections ctrl to (before + 1) by -1 do biped.deleteCopyCollection ctrl index
                        if pasteFailure != undefined do throw pasteFailure
                    )
                    for pair in pairs where bipedRoot pair[1] == undefined do
                    (
                        local tm = readMatrix pair[2]
                        if pair[1].parent != undefined do tm = tm * pair[1].parent.transform
                        pair[1].transform = tm
                        -- Some constrained controllers silently ignore assignments.
                        local actual = pair[1].transform
                        for row = 1 to 4 where distance actual[row] tm[row] > 0.001 do
                            throw ("控制器无法直接恢复姿势，请选择驱动控制器：" + pair[1].name)
                    )
                )
            ) catch (failure = getCurrentException())
        )
        if failure != undefined then theHold.SuperCancel() else theHold.SuperAccept "GameHelper Paste Pose"
        if io.Exists cpyPath do io.Delete cpyPath
        if failure != undefined do throw failure
        redrawViews()
        pairs.count
    )
)

CGH_PoseClipboard = CGH_PoseClipboardStruct()
try (destroyDialog CGH_PoseClipboardUI) catch()
rollout CGH_PoseClipboardUI "跨 Max 姿势剪贴板" width:320
(
    label hint "源 Max：选骨骼/控制器 → 复制" align:#left
    label hint2 "目标 Max：切到目标帧 → 粘贴（自动打帧）" align:#left
    button copyButton "复制 Pose（当前选择）" width:290 height:34
    button pasteButton "粘贴 Pose（按同名匹配）" width:290 height:34
    label scope "复制包含整体位移；目标端无需重新选择。" align:#left
    label face "表情仅支持变换控制器，不含 Morpher/自定义属性。" align:#left
    label status "就绪。两个 Max 各运行本脚本一次。" width:295 height:42 align:#left
    on copyButton pressed do
    (
        try (status.text = "已复制 " + ((CGH_PoseClipboard.copyPose (selection as array)) as string) + " 个对象。")
        catch (status.text = "复制失败。"; messageBox (getCurrentException() as string) title:"姿势剪贴板")
    )
    on pasteButton pressed do
    (
        try (status.text = "已粘贴 " + ((CGH_PoseClipboard.pastePose()) as string) + " 个对象，可撤销。")
        catch (status.text = "粘贴失败。"; messageBox (getCurrentException() as string) title:"姿势剪贴板")
    )
)
if CGH_PoseClipboardNoUI != true do createDialog CGH_PoseClipboardUI
