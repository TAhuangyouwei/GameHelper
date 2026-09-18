/* ============================================================
    Animation Key Reducer V0.58 - Biped and Bone Alignment

    目标：
    1. Biped 全身统一关键帧时间轴
    2. 优先减少 Unique Key Times，而不是每根骨骼独立找时间
    3. 保留首尾帧 / Pose Lock / 自动关键 Pose
    4. 可选保护脚底接触变化
    5. Master Frame 生成后，再删除各 Controller 的非 Master Key

    说明：
    - 这一版优先针对 Biped。
    - 不使用 clearAllAnimation，不整套重烘 Biped。
    - Biped 新增 Key 使用 biped.addNewKey。
    - Biped 删除单个 Key 使用 deleteKey（从后向前）。
    - Master Frame 的判断使用原动画逐帧采样缓存，不受删除后的曲线影响。
============================================================ */

global AKR_Core
global AKR_CandidateFrames = #()
global AKR_LockedFrames = #()
global AKR_MasterFrames = #()
global AKR_LastAnalysis = undefined
global AKR_LastGroups = undefined
global AKR_RestoreAnalysis = undefined
global AKR_RestoreGroups = undefined
global AKR_RestoreOriginalKeys = 0
global AKR_RestoreOriginalTimesCount = 0
global AKR_AddFailCount = 0
global AKR_DeleteFailCount = 0
global AKR_AddSuccessCount = 0
global AKR_DeleteSuccessCount = 0


/* ============================================================
    数据结构
============================================================ */

struct AKR_SampleData
(
    frame,
    worldTM,
    worldPos,
    worldRot,
    localPos,
    localRot
)

struct AKR_NodeData
(
    node,
    samples,
    weight = 1.0,
    startFrame = 0,
    endFrame = 0
)

struct AKR_ControllerGroup
(
    ctrl,
    isBiped = true,
    ownerName = ""
)


/* ============================================================
    Core
============================================================ */

struct AKR_CoreStruct
(
    /* --------------------------------------------------------
        基础数学
    -------------------------------------------------------- */

    fn clampValue v minV maxV =
    (
        if v < minV then minV
        else if v > maxV then maxV
        else v
    ),

    fn quatAngleDeg q1 q2 =
    (
        local dq = q1 * (inverse q2)
        local w = clampValue (abs dq.w) 0.0 1.0
        2.0 * acos w
    ),

    fn interpPoint p1 p2 t =
    (
        p1 + ((p2 - p1) * t)
    ),

    fn safeSlerp q1 q2 t =
    (
        local result = q1

        try
        (
            result = slerp q1 q2 t
        )
        catch
        (
            result = q1
        )

        result
    ),

    fn frameArrayContains frames f =
    (
        (findItem frames f) > 0
    ),

    fn appendFrameUnique frames f =
    (
        if (findItem frames f) == 0 then append frames f
        frames
    ),

    fn sortUniqueFrames frames =
    (
        local result = #()

        for f in frames do
        (
            appendFrameUnique result f
        )

        sort result
        result
    ),


    /* --------------------------------------------------------
        Biped 判断与节点展开
    -------------------------------------------------------- */

    fn isBipedNode node =
    (
        if node == undefined then
        (
            false
        )
        else
        (
            local result = false

            try
            (
                local p = biped.getTransform node #pos
                result = true
            )
            catch
            (
                result = false
            )

            result
        )
    ),

    fn isFootstepsNode node =
    (
        if node == undefined then
        (
            false
        )
        else
        (
            local n = toLower node.name
            (findString n "footsteps") != undefined
        )
    ),

    fn isStandardBoneNode node =
    (
        if node == undefined or isBipedNode node then
        (
            false
        )
        else
        (
            local result = false

            try
            (
                result = ((classOf node.baseObject) == BoneGeometry)
            )
            catch
            (
                result = false
            )

            result
        )
    ),

    fn getBipedRoot node =
    (
        if node == undefined then return undefined
        if not (isBipedNode node) then return undefined

        local rootNode = node
        local keepGoing = true

        while keepGoing do
        (
            if rootNode.parent != undefined and isBipedNode rootNode.parent then
            (
                rootNode = rootNode.parent
            )
            else
            (
                keepGoing = false
            )
        )

        rootNode
    ),

    fn collectBipedChildren node result =
    (
        if node == undefined then return result

        if isBipedNode node and not (isFootstepsNode node) then
        (
            appendFrameUnique result node

            for child in node.children do
            (
                if isBipedNode child and not (isFootstepsNode child) then
                (
                    collectBipedChildren child result
                )
            )
        )

        result
    ),

    fn expandProcessingNodes selectedNodes =
    (
        local result = #()
        local bipedRoot = undefined

        for node in selectedNodes while bipedRoot == undefined do
        (
            if isBipedNode node then
            (
                bipedRoot = getBipedRoot node
            )
        )

        if bipedRoot != undefined then
        (
            collectBipedChildren bipedRoot result
        )
        else
        (
            for node in selectedNodes do
            (
                if node != undefined and (findItem result node) == 0 then
                (
                    append result node
                )
            )
        )

        result
    ),

    fn collectStandardBoneHierarchy node result =
    (
        if node == undefined then return result

        if isStandardBoneNode node then
        (
            if (findItem result node) == 0 then append result node
        )

        for child in node.children do
        (
            collectStandardBoneHierarchy child result
        )

        result
    ),

    fn expandStandardBoneNodes selectedNodes =
    (
        local result = #()

        for node in selectedNodes do
        (
            collectStandardBoneHierarchy node result
        )

        result
    ),


    /* --------------------------------------------------------
        骨骼重要度
        核心骨骼更容易推动 Master Frame
        手指 / Toe / Twist 稍微放宽
    -------------------------------------------------------- */

    fn getNodeWeight node =
    (
        if node == undefined then return 1.0

        local n = toLower node.name

        if findString n "finger" != undefined then return 0.60
        if findString n "thumb" != undefined then return 0.65
        if findString n "toe" != undefined then return 0.70
        if findString n "twist" != undefined then return 0.65
        if findString n "nub" != undefined then return 0.50

        if findString n "foot" != undefined then return 1.15
        if findString n "hand" != undefined then return 1.10
        if findString n "pelvis" != undefined then return 1.15
        if findString n "spine" != undefined then return 1.05
        if findString n "head" != undefined then return 1.05

        if node.parent == undefined then return 1.20

        1.0
    ),


    /* --------------------------------------------------------
        采样
    -------------------------------------------------------- */

    fn getLocalTM node =
    (
        local worldTM = node.transform
        local localTM = worldTM

        if node.parent != undefined then
        (
            localTM = worldTM * (inverse node.parent.transform)
        )

        localTM
    ),

    fn sampleNode node startFrame endFrame =
    (
        local samples = #()

        for f = startFrame to endFrame do
        (
            at time f
            (
                local worldTM = node.transform
                local localTM = getLocalTM node

                local s = AKR_SampleData frame:f worldTM:worldTM worldPos:worldTM.translationpart worldRot:worldTM.rotationpart localPos:localTM.translationpart localRot:localTM.rotationpart

                append samples s
            )
        )

        AKR_NodeData node:node samples:samples weight:(getNodeWeight node) startFrame:startFrame endFrame:endFrame
    ),

    fn analyzeNodes nodes startFrame endFrame localTol rotTol trajTol =
    (
        local result = #()

        for node in nodes do
        (
            if node != undefined and not (isFootstepsNode node) then
            (
                append result (sampleNode node startFrame endFrame)
            )
        )

        result
    ),

    fn getSample nodeData frame =
    (
        local index = (frame - nodeData.startFrame) + 1

        if index < 1 or index > nodeData.samples.count then
        (
            undefined
        )
        else
        (
            nodeData.samples[index]
        )
    ),


    /* --------------------------------------------------------
        Source Space 误差
        用原始逐帧缓存判断某一帧是否必须成为 Master Frame
    -------------------------------------------------------- */

    fn getMasterLocalPosWeight node =
    (
        if node == undefined then return 0.0
        if node.parent == undefined then return 1.0
        0.0
    ),

    fn getMasterTrajectoryWeight node =
    (
        if node == undefined then return 0.0

        local n = toLower node.name

        if node.parent == undefined then return 1.0
        if findString n "pelvis" != undefined then return 0.0
        if findString n "foot" != undefined and findString n "footsteps" == undefined then return 0.40
        if findString n "hand" != undefined then return 0.35
        if findString n "head" != undefined then return 0.20

        0.0
    ),

    fn getMasterRotationWeight node =
    (
        if node == undefined then return 1.0

        local n = toLower node.name

        if findString n "finger" != undefined then return 0.55
        if findString n "thumb" != undefined then return 0.55
        if findString n "toe" != undefined then return 0.60
        if findString n "twist" != undefined then return 0.60
        if findString n "nub" != undefined then return 0.40
        if findString n "clavicle" != undefined then return 0.75
        if findString n "spine" != undefined then return 0.90
        if findString n "head" != undefined then return 0.90

        1.0
    ),

    fn getSourceFrameScore nodeData frame leftFrame rightFrame localTol rotTol trajTol =
    (
        if rightFrame <= leftFrame then return 0.0

        local sampleNow = getSample nodeData frame
        local sampleLeft = getSample nodeData leftFrame
        local sampleRight = getSample nodeData rightFrame

        if sampleNow == undefined or sampleLeft == undefined or sampleRight == undefined then return 0.0

        local alpha = (frame - leftFrame) as float / (rightFrame - leftFrame) as float

        local approxLocalPos = interpPoint sampleLeft.localPos sampleRight.localPos alpha
        local approxWorldPos = interpPoint sampleLeft.worldPos sampleRight.worldPos alpha

        local approxLocalRot = safeSlerp sampleLeft.localRot sampleRight.localRot alpha
        local approxWorldRot = safeSlerp sampleLeft.worldRot sampleRight.worldRot alpha

        local localPosError = distance sampleNow.localPos approxLocalPos
        local worldPosError = distance sampleNow.worldPos approxWorldPos

        local localRotError = quatAngleDeg sampleNow.localRot approxLocalRot
        local worldRotError = quatAngleDeg sampleNow.worldRot approxWorldRot

        local localPosWeight = getMasterLocalPosWeight nodeData.node
        local trajectoryWeight = getMasterTrajectoryWeight nodeData.node
        local rotationWeight = getMasterRotationWeight nodeData.node

        local localScore = (localPosError / (amax localTol 0.000001)) * localPosWeight
        local trajScore = (worldPosError / (amax trajTol 0.000001)) * trajectoryWeight

        local rotationErrorForMaster = localRotError
        if nodeData.node.parent == undefined then rotationErrorForMaster = amax localRotError worldRotError

        local rotScore = (rotationErrorForMaster / (amax rotTol 0.000001)) * rotationWeight

        amax localScore (amax trajScore rotScore)
    ),

    fn getWorstSourceFrame analysisData leftFrame rightFrame localTol rotTol trajTol =
    (
        local worstScore = 0.0
        local worstFrame = undefined
        local worstNode = undefined

        if rightFrame - leftFrame <= 1 then
        (
            return #(worstScore, worstFrame, worstNode)
        )

        for f = (leftFrame + 1) to (rightFrame - 1) do
        (
            for nodeData in analysisData do
            (
                local score = getSourceFrameScore nodeData f leftFrame rightFrame localTol rotTol trajTol

                if score > worstScore then
                (
                    worstScore = score
                    worstFrame = f
                    worstNode = nodeData.node
                )
            )
        )

        #(worstScore, worstFrame, worstNode)
    ),


    /* --------------------------------------------------------
        Foot Contact 候选
        只检测速度由快 -> 慢 / 慢 -> 快的切换
    -------------------------------------------------------- */

    fn collectFootContactFrames analysisData trajTol =
    (
        local result = #()
        local stopThreshold = amax (trajTol * 0.50) 0.001
        local moveThreshold = amax trajTol 0.002

        for nodeData in analysisData do
        (
            local n = toLower nodeData.node.name

            if findString n "foot" != undefined and findString n "footsteps" == undefined then
            (
                for f = (nodeData.startFrame + 1) to (nodeData.endFrame - 1) do
                (
                    local s0 = getSample nodeData (f - 1)
                    local s1 = getSample nodeData f
                    local s2 = getSample nodeData (f + 1)

                    local vPrev = distance s0.worldPos s1.worldPos
                    local vNext = distance s1.worldPos s2.worldPos

                    local landing = (vPrev >= moveThreshold and vNext <= stopThreshold)
                    local leaving = (vPrev <= stopThreshold and vNext >= moveThreshold)

                    if landing or leaving then
                    (
                        appendFrameUnique result f
                    )
                )
            )
        )

        sort result
        result
    ),


    /* --------------------------------------------------------
        自动 Pose 候选
        使用 f-1 / f+1 对当前帧的重建误差作为“动作拐点”
    -------------------------------------------------------- */

    fn detectPoseCandidates analysisData sensitivity spacing =
    (
        local scoredFrames = #()

        if analysisData.count == 0 then return #()

        local startFrame = analysisData[1].startFrame
        local endFrame = analysisData[1].endFrame

        local threshold = 1.70 - ((sensitivity as float) * 0.13)
        threshold = clampValue threshold 0.25 1.60

        for f = (startFrame + 1) to (endFrame - 1) do
        (
            local frameScore = 0.0

            for nodeData in analysisData do
            (
                local score = getSourceFrameScore nodeData f (f - 1) (f + 1) 0.10 0.35 0.20
                frameScore = amax frameScore score
            )

            if frameScore >= threshold then
            (
                append scoredFrames #(f, frameScore)
            )
        )

        -- MaxScript 在 struct 方法内部使用匿名 fn 作为 qsort 比较器
        -- 容易触发 "No outer local variable references permitted here"。
        -- 这里改成普通循环排序，按 score 从高到低排列。
        if scoredFrames.count > 1 then
        (
            for i = 1 to (scoredFrames.count - 1) do
            (
                local bestIndex = i

                for j = (i + 1) to scoredFrames.count do
                (
                    if scoredFrames[j][2] > scoredFrames[bestIndex][2] then
                    (
                        bestIndex = j
                    )
                )

                if bestIndex != i then
                (
                    local tempItem = scoredFrames[i]
                    scoredFrames[i] = scoredFrames[bestIndex]
                    scoredFrames[bestIndex] = tempItem
                )
            )
        )

        local result = #()

        for item in scoredFrames do
        (
            local f = item[1]
            local canAdd = true

            for existing in result while canAdd do
            (
                if abs(existing - f) < spacing then canAdd = false
            )

            if canAdd then append result f
        )

        sort result
        result
    ),


    /* --------------------------------------------------------
        Pose Lock
        保留兼容接口。真正保护帧在 buildMasterFrames 中使用。
    -------------------------------------------------------- */

    fn applyLockedFrames analysisData lockedFrames lockRange =
    (
        true
    ),


    /* --------------------------------------------------------
        Master Frame 构建
    -------------------------------------------------------- */

    fn collectMandatoryFrames startFrame endFrame lockedFrames lockRange footFrames =
    (
        local mandatory = #(startFrame, endFrame)

        for f in lockedFrames do
        (
            for offset = -lockRange to lockRange do
            (
                local target = f + offset

                if target >= startFrame and target <= endFrame then
                (
                    appendFrameUnique mandatory target
                )
            )
        )

        for f in footFrames do
        (
            if f >= startFrame and f <= endFrame then
            (
                appendFrameUnique mandatory f
            )
        )

        sort mandatory
        mandatory
    ),

    fn getWorstSourceFrameSpaced analysisData leftFrame rightFrame localTol rotTol trajTol minSpacing =
    (
        local worstScore = 0.0
        local worstFrame = undefined
        local worstNode = undefined

        local firstFrame = leftFrame + minSpacing
        local lastFrame = rightFrame - minSpacing

        if firstFrame > lastFrame then return #(worstScore, worstFrame, worstNode)

        for f = firstFrame to lastFrame do
        (
            for nodeData in analysisData do
            (
                local score = getSourceFrameScore nodeData f leftFrame rightFrame localTol rotTol trajTol

                if score > worstScore then
                (
                    worstScore = score
                    worstFrame = f
                    worstNode = nodeData.node
                )
            )
        )

        #(worstScore, worstFrame, worstNode)
    ),

    fn buildSegmentRecursive analysisData leftFrame rightFrame masterFrames localTol rotTol trajTol safety minSpacing =
    (
        if rightFrame - leftFrame < (minSpacing * 2) then return true

        local worst = getWorstSourceFrameSpaced analysisData leftFrame rightFrame localTol rotTol trajTol minSpacing
        local worstScore = worst[1]
        local worstFrame = worst[2]

        if worstFrame != undefined and worstScore > safety then
        (
            appendFrameUnique masterFrames worstFrame

            buildSegmentRecursive analysisData leftFrame worstFrame masterFrames localTol rotTol trajTol safety minSpacing
            buildSegmentRecursive analysisData worstFrame rightFrame masterFrames localTol rotTol trajTol safety minSpacing
        )

        true
    ),

    fn canRemoveMasterFrame analysisData frames index localTol rotTol trajTol safety =
    (
        if index <= 1 or index >= frames.count then return false

        local leftFrame = frames[index - 1]
        local rightFrame = frames[index + 1]

        local worst = getWorstSourceFrame analysisData leftFrame rightFrame localTol rotTol trajTol

        worst[1] <= safety
    ),

    fn cleanupMasterFrames analysisData masterFrames mandatoryFrames localTol rotTol trajTol safety mergeRange minSpacing =
    (
        local frames = sortUniqueFrames masterFrames
        local changed = true

        while changed do
        (
            changed = false

            if frames.count > 2 then
            (
                for i = (frames.count - 1) to 2 by -1 while not changed do
                (
                    local f = frames[i]
                    local isMandatory = (findItem mandatoryFrames f) > 0

                    if not isMandatory then
                    (
                        local leftGap = f - frames[i - 1]
                        local rightGap = frames[i + 1] - f

                        local shouldTry = true

                        if mergeRange > 0 then
                        (
                            shouldTry = (leftGap <= mergeRange) or (rightGap <= mergeRange) or (leftGap < minSpacing) or (rightGap < minSpacing)
                        )

                        if shouldTry and canRemoveMasterFrame analysisData frames i localTol rotTol trajTol safety then
                        (
                            deleteItem frames i
                            changed = true
                        )
                    )
                )
            )
        )

        -- 再做一次全局冗余删除，不只处理相邻吸附范围
        changed = true

        while changed do
        (
            changed = false

            if frames.count > 2 then
            (
                for i = (frames.count - 1) to 2 by -1 while not changed do
                (
                    local f = frames[i]

                    if (findItem mandatoryFrames f) == 0 then
                    (
                        if canRemoveMasterFrame analysisData frames i localTol rotTol trajTol safety then
                        (
                            deleteItem frames i
                            changed = true
                        )
                    )
                )
            )
        )

        sort frames
        frames
    ),

    fn buildMasterFrames analysisData startFrame endFrame lockedFrames lockRange localTol rotTol trajTol minSpacing mergeRange protectFeet safety =
    (
        local footFrames = #()

        if protectFeet then
        (
            footFrames = collectFootContactFrames analysisData trajTol
        )

        local mandatory = collectMandatoryFrames startFrame endFrame lockedFrames lockRange footFrames
        local masterFrames = mandatory as array

        if mandatory.count >= 2 then
        (
            for i = 1 to (mandatory.count - 1) do
            (
                buildSegmentRecursive analysisData mandatory[i] mandatory[i + 1] masterFrames localTol rotTol trajTol safety minSpacing
            )
        )

        masterFrames = sortUniqueFrames masterFrames

        masterFrames = cleanupMasterFrames analysisData masterFrames mandatory localTol rotTol trajTol safety mergeRange minSpacing

        masterFrames
    ),


    /* --------------------------------------------------------
        Controller 收集
    -------------------------------------------------------- */

    fn addControllerGroupUnique groups ctrl isBiped ownerName =
    (
        if ctrl == undefined then return groups

        local exists = false

        for g in groups while not exists do
        (
            if g.ctrl == ctrl then exists = true
        )

        if not exists then
        (
            append groups (AKR_ControllerGroup ctrl:ctrl isBiped:isBiped ownerName:ownerName)
        )

        groups
    ),

    fn collectKeyableControllerGroups ctrl groups visited ownerName =
    (
        if ctrl == undefined then return groups
        if (findItem visited ctrl) > 0 then return groups

        append visited ctrl

        local supports = false

        try
        (
            supports = ctrl.supportsKeys
        )
        catch
        (
            supports = false
        )

        if supports then
        (
            addControllerGroupUnique groups ctrl false ownerName
        )
        else
        (
            local subCount = 0

            try
            (
                subCount = ctrl.numSubs
            )
            catch
            (
                subCount = 0
            )

            for i = 1 to subCount do
            (
                local subCtrl = undefined

                try
                (
                    local subAnim = getSubAnim ctrl i
                    subCtrl = subAnim.controller
                )
                catch
                (
                    subCtrl = undefined
                )

                if subCtrl != undefined then
                (
                    collectKeyableControllerGroups subCtrl groups visited ownerName
                )
            )
        )

        groups
    ),

    fn buildStandardBoneControllerGroups nodes =
    (
        local groups = #()
        local visited = #()

        for node in nodes do
        (
            if isStandardBoneNode node and node.controller != undefined then
            (
                collectKeyableControllerGroups node.controller groups visited node.name
            )
        )

        groups
    ),

    fn buildControllerGroups analysisData =
    (
        local groups = #()

        for nodeData in analysisData do
        (
            local node = nodeData.node

            if node != undefined and not (isFootstepsNode node) then
            (
                if isBipedNode node then
                (
                    local ctrl = node.controller
                    local rootNode = getBipedRoot node

                    -- 只有 Biped 质心根节点才拆成 Horizontal / Vertical / Turning。
                    -- 其余 Pelvis / Spine / Arm / Leg / Hand / Foot 等全部直接处理自己的 Biped Controller。
                    if rootNode != undefined and node == rootNode then
                    (
                        local hCtrl = undefined
                        local vCtrl = undefined
                        local tCtrl = undefined

                        try
                        (
                            hCtrl = biped.getHorizontalControl ctrl
                        )
                        catch
                        (
                            hCtrl = undefined
                        )

                        try
                        (
                            vCtrl = biped.getVerticalControl ctrl
                        )
                        catch
                        (
                            vCtrl = undefined
                        )

                        try
                        (
                            tCtrl = biped.getTurnControl ctrl
                        )
                        catch
                        (
                            tCtrl = undefined
                        )

                        if hCtrl != undefined then
                        (
                            addControllerGroupUnique groups hCtrl true (node.name + " Horizontal")
                        )

                        if vCtrl != undefined then
                        (
                            addControllerGroupUnique groups vCtrl true (node.name + " Vertical")
                        )

                        if tCtrl != undefined then
                        (
                            addControllerGroupUnique groups tCtrl true (node.name + " Turning")
                        )
                    )
                    else
                    (
                        if ctrl != undefined then
                        (
                            addControllerGroupUnique groups ctrl true node.name
                        )
                    )
                )
                else
                (
                    if node.controller != undefined then
                    (
                        addControllerGroupUnique groups node.controller false node.name
                    )
                )
            )
        )

        groups
    ),


    /* --------------------------------------------------------
        Key 操作
    -------------------------------------------------------- */

    fn getControllerKeyCount group =
    (
        local count = 0

        try
        (
            count = numKeys group.ctrl
            if count == undefined then count = 0
        )
        catch
        (
            count = 0
        )

        count
    ),

    fn getKeyFrame group index =
    (
        local result = undefined

        if group.isBiped then
        (
            try
            (
                local k = biped.getKey group.ctrl index
                result = k.time.frame as integer
            )
            catch
            (
                result = undefined
            )
        )
        else
        (
            try
            (
                result = (getKeyTime group.ctrl index).frame as integer
            )
            catch
            (
                try
                (
                    result = group.ctrl.keys[index].time.frame as integer
                )
                catch
                (
                    result = undefined
                )
            )
        )

        result
    ),

    fn addKeyAtFrame group frame =
    (
        local ok = false

        if group.isBiped then
        (
            try
            (
                biped.addNewKey group.ctrl frame
                ok = true
            )
            catch
            (
                ok = false
            )
        )
        else
        (
            try
            (
                addNewKey group.ctrl frame #interpolate
                ok = true
            )
            catch
            (
                ok = false
            )
        )

        if ok then AKR_AddSuccessCount += 1 else AKR_AddFailCount += 1
        ok
    ),

    fn ensureMasterKeys group masterFrames =
    (
        for f in masterFrames do
        (
            addKeyAtFrame group f
        )

        true
    ),

    fn deleteNonMasterKeys group masterFrames startFrame endFrame =
    (
        local count = getControllerKeyCount group

        for i = count to 1 by -1 do
        (
            local f = getKeyFrame group i

            if f != undefined then
            (
                if f >= startFrame and f <= endFrame then
                (
                    if (findItem masterFrames f) == 0 then
                    (
                        try
                        (
                            deleteKey group.ctrl i
                            AKR_DeleteSuccessCount += 1
                        )
                        catch
                        (
                            AKR_DeleteFailCount += 1
                        )
                    )
                )
            )
        )

        true
    ),

    fn reduceControllerGroups controllerGroups masterFrames startFrame endFrame =
    (
        AKR_AddFailCount = 0
        AKR_DeleteFailCount = 0
        AKR_AddSuccessCount = 0
        AKR_DeleteSuccessCount = 0

        -- 先全部补齐 Master Frame。
        -- 此时动画还没有被删除，所以新增 Key 会取得原始曲线在该时间的插值值。
        for group in controllerGroups do
        (
            ensureMasterKeys group masterFrames
        )

        -- 再删除 Master Frame 之外的 Key。
        for group in controllerGroups do
        (
            deleteNonMasterKeys group masterFrames startFrame endFrame
        )

        true
    ),

    /* --------------------------------------------------------
        从精简前缓存恢复指定帧 Pose
        恢复后仍保证所有 Controller 在该帧都有 Key。
    -------------------------------------------------------- */

    fn restoreFramePose analysisData controllerGroups frame =
    (
        local restoredNodes = 0

        if analysisData == undefined or analysisData.count == 0 then return restoredNodes

        at time frame
        (
            -- analyzeNodes 的顺序是 Biped 根节点到子节点。
            -- 按该顺序恢复世界位置和旋转，减少父级改变对子级的二次影响。
            for nodeData in analysisData do
            (
                local source = getSample nodeData frame
                local node = nodeData.node

                if source != undefined and node != undefined then
                (
                    local restored = false

                    if isBipedNode node then
                    (
                        try
                        (
                            biped.setTransform node #pos source.worldPos true
                            restored = true
                        )
                        catch
                        (
                        )

                        try
                        (
                            biped.setTransform node #rotation source.worldRot true
                            restored = true
                        )
                        catch
                        (
                        )
                    )
                    else
                    (
                        try
                        (
                            animate on
                            (
                                node.transform = source.worldTM
                            )

                            restored = true
                        )
                        catch
                        (
                        )
                    )

                    if restored then restoredNodes += 1
                )
            )
        )

        -- 必须保留的规则：所有唯一 Controller 在恢复帧都有 Key。
        if controllerGroups != undefined then
        (
            for group in controllerGroups do
            (
                addKeyAtFrame group frame
            )
        )

        restoredNodes
    ),

    fn solidifyControllerGroups controllerGroups =
    (
        -- V0.50 不再逐帧 Solidify。
        -- 保留这个函数只是为了兼容旧调用。
        true
    ),


    /* --------------------------------------------------------
        统计
    -------------------------------------------------------- */

    fn getOriginalKeyCount controllerGroups =
    (
        local total = 0

        for group in controllerGroups do
        (
            total += getControllerKeyCount group
        )

        total
    ),

    fn getFinalKeyCount controllerGroups =
    (
        getOriginalKeyCount controllerGroups
    ),

    fn getUniqueKeyTimes controllerGroups startFrame endFrame =
    (
        local frames = #()

        for group in controllerGroups do
        (
            local count = getControllerKeyCount group

            for i = 1 to count do
            (
                local f = getKeyFrame group i

                if f != undefined and f >= startFrame and f <= endFrame then
                (
                    appendFrameUnique frames f
                )
            )
        )

        sort frames
        frames
    ),


    /* --------------------------------------------------------
        Reduction 后实际场景校验
    -------------------------------------------------------- */

    fn validateAnalysis analysisData localTol rotTol trajTol =
    (
        local maxLocalError = 0.0
        local maxTrajectoryError = 0.0
        local maxRotationError = 0.0

        local worstScore = 0.0
        local worstNode = undefined
        local worstFrame = undefined

        for nodeData in analysisData do
        (
            for f = nodeData.startFrame to nodeData.endFrame do
            (
                local source = getSample nodeData f

                at time f
                (
                    local worldTM = nodeData.node.transform
                    local localTM = getLocalTM nodeData.node

                    local localError = distance source.localPos localTM.translationpart
                    local trajError = distance source.worldPos worldTM.translationpart

                    local localRotError = quatAngleDeg source.localRot localTM.rotationpart
                    local worldRotError = quatAngleDeg source.worldRot worldTM.rotationpart
                    local rotError = amax localRotError worldRotError

                    maxLocalError = amax maxLocalError localError
                    maxTrajectoryError = amax maxTrajectoryError trajError
                    maxRotationError = amax maxRotationError rotError

                    local scoreLocal = localError / (amax localTol 0.000001)
                    local scoreTraj = trajError / (amax trajTol 0.000001)
                    local scoreRot = rotError / (amax rotTol 0.000001)

                    local score = amax scoreLocal (amax scoreTraj scoreRot)

                    if score > worstScore then
                    (
                        worstScore = score
                        worstNode = nodeData.node
                        worstFrame = f
                    )
                )
            )
        )

        #(maxLocalError, maxTrajectoryError, maxRotationError, worstScore, worstNode, worstFrame)
    ),

    fn validateLockedPoses analysisData lockedFrames lockRange =
    (
        local maxPosError = 0.0
        local maxRotError = 0.0
        local worstNode = undefined
        local worstFrame = undefined
        local worstScore = 0.0

        for nodeData in analysisData do
        (
            for lockedFrame in lockedFrames do
            (
                for offset = -lockRange to lockRange do
                (
                    local f = lockedFrame + offset

                    if f >= nodeData.startFrame and f <= nodeData.endFrame then
                    (
                        local source = getSample nodeData f

                        at time f
                        (
                            local worldTM = nodeData.node.transform

                            local posError = distance source.worldPos worldTM.translationpart
                            local rotError = quatAngleDeg source.worldRot worldTM.rotationpart
                            local score = posError + rotError

                            if posError > maxPosError then maxPosError = posError
                            if rotError > maxRotError then maxRotError = rotError

                            if score > worstScore then
                            (
                                worstScore = score
                                worstNode = nodeData.node
                                worstFrame = f
                            )
                        )
                    )
                )
            )
        )

        #(maxPosError, maxRotError, worstNode, worstFrame)
    )
)

AKR_Core = AKR_CoreStruct()


/* ============================================================
    UI V0.58
============================================================ */

try
(
    destroyDialog AKR_Rollout
)
catch
(
)

rollout AKR_Rollout "动画关键帧精简 V0.58"
(
    group "处理范围"
    (
        label lblSelection "普通骨骼：处理当前选择"
        label lblBiped "Biped：选择任意骨骼自动分析整个 Biped"
        label lblFootsteps "Footsteps：不直接处理"
        label lblAnimRange "范围：当前 Animation Range"
    )


    group "误差设置"
    (
        spinner spnLocalPos "局部位置误差：" range:[0.001,1000.0,0.10] type:#float fieldwidth:70
        spinner spnRotation "旋转误差(度)：" range:[0.001,180.0,0.25] type:#float fieldwidth:70
        spinner spnTrajectory "世界轨迹误差：" range:[0.001,1000.0,0.20] type:#float fieldwidth:70
    )


    group "Master Frame 编辑友好"
    (
        spinner spnMinMasterSpacing "最小 Key 间隔：" range:[1,12,3] type:#integer fieldwidth:50
        spinner spnMergeRange "相邻帧合并 ±：" range:[0,5,1] type:#integer fieldwidth:50
        spinner spnSafety "误差倍率：" range:[0.50,4.00,1.00] type:#float fieldwidth:60

        checkbox chkProtectFeet "保护脚底接触变化" checked:true

        label lblMasterHint "目标：优先减少全身不同 Key 时间"
    )


    group "自动关键 Pose 候选"
    (
        spinner spnSensitivity "识别灵敏度：" range:[1,10,5] type:#integer fieldwidth:50
        spinner spnCandidateSpacing "候选最小间隔：" range:[1,30,3] type:#integer fieldwidth:50

        button btnDetectPose "自动识别关键 Pose" width:310 height:28

        label lblCandidateCount "自动候选：0"

        listbox lstCandidates "" items:#() height:4 width:310

        button btnGotoCandidate "跳转候选" width:100 across:3
        button btnAddCandidate "加入锁定" width:100
        button btnAddAllCandidates "全部加入" width:100
    )


    group "手动 Pose Lock"
    (
        spinner spnLockRange "保护范围 ±：" range:[0,10,0] type:#integer fieldwidth:50

        label lblLockCount "锁定 Pose：0"

        listbox lstLocked "" items:#() height:4 width:310

        button btnAddCurrent "添加当前帧" width:100 across:3
        button btnGotoLocked "跳转锁定" width:100
        button btnRemoveLocked "移除锁定" width:100

        button btnClearLocked "清空所有锁定" width:310
    )


    group "操作"
    (
        button btnAnalyze "分析 Master Frames" width:150 height:30 across:2
        button btnReduce "执行精简" width:150 height:30

        button btnRestoreCurrent "恢复当前帧原始 Pose" width:310 height:28
        label lblRestoreStatus "恢复缓存：请先执行精简" width:315 align:#left

        button btnReduceBone "按 Biped Master 精简选中 Bone" width:310 height:28
        label lblBoneStatus "Bone 对齐：请先精简 Biped" width:315 align:#left
    )


    group "结果"
    (
        label lblNodes "处理节点：0" width:315 align:#left
        label lblControllers "唯一 Controller：0" width:315 align:#left

        label lblOriginalKeys "原始 Keys：0" width:315 align:#left
        label lblFinalKeys "精简后 Keys：0" width:315 align:#left
        label lblReduction "Keys 减少：0%" width:315 align:#left

        label lblOriginalTimes "原始关键时间：0" width:315 align:#left
        label lblFinalTimes "精简关键时间：0" width:315 align:#left
        label lblTimeReduction "时间轴精简：0%" width:315 align:#left

        label lblMasterCount "Master Frames：0" width:315 align:#left
        label lblMasterPreview "帧：" width:315 align:#left
        label lblKeyOps "Key操作：未执行" width:315 align:#left

        label lblTrajectoryError "最大轨迹误差：0" width:315 align:#left
        label lblRotationError "最大旋转误差：0" width:315 align:#left

        label lblLockedError "锁定 Pose 误差：未执行" width:315 align:#left
        label lblValidation "整体校验：未执行" width:315 align:#left
    )


    /* --------------------------------------------------------
        UI Helper
    -------------------------------------------------------- */

    fn framesToStrings frames =
    (
        local result = #()

        for frame in frames do
        (
            append result (frame as string)
        )

        result
    )

    fn refreshPoseLists =
    (
        lstCandidates.items = framesToStrings AKR_CandidateFrames
        lstLocked.items = framesToStrings AKR_LockedFrames

        lblCandidateCount.text = "自动候选：" + (AKR_CandidateFrames.count as string)
        lblLockCount.text = "锁定 Pose：" + (AKR_LockedFrames.count as string)

        true
    )

    fn getSelectedCandidateFrame =
    (
        local index = lstCandidates.selection

        if index <= 0 or index > AKR_CandidateFrames.count then undefined
        else AKR_CandidateFrames[index]
    )

    fn getSelectedLockedFrame =
    (
        local index = lstLocked.selection

        if index <= 0 or index > AKR_LockedFrames.count then undefined
        else AKR_LockedFrames[index]
    )

    fn masterPreviewText frames =
    (
        local text = ""
        local showCount = amin frames.count 18

        for i = 1 to showCount do
        (
            if i > 1 then text += ", "
            text += frames[i] as string
        )

        if frames.count > showCount then text += " ..."

        text
    )

    fn buildCurrentAnalysis =
    (
        if selection.count == 0 then return undefined

        local startFrame = animationRange.start.frame as integer
        local endFrame = animationRange.end.frame as integer

        local selectedNodes = selection as array
        local processingNodes = AKR_Core.expandProcessingNodes selectedNodes

        AKR_Core.analyzeNodes processingNodes startFrame endFrame spnLocalPos.value spnRotation.value spnTrajectory.value
    )

    fn buildCurrentMasterFrames analysisData =
    (
        local startFrame = animationRange.start.frame as integer
        local endFrame = animationRange.end.frame as integer

        AKR_Core.buildMasterFrames analysisData startFrame endFrame AKR_LockedFrames spnLockRange.value spnLocalPos.value spnRotation.value spnTrajectory.value spnMinMasterSpacing.value spnMergeRange.value chkProtectFeet.checked spnSafety.value
    )


    /* --------------------------------------------------------
        自动 Pose
    -------------------------------------------------------- */

    on btnDetectPose pressed do
    (
        if selection.count == 0 then
        (
            messageBox "请先选择普通骨骼或任意 Biped 骨骼。" title:"Animation Key Reducer"
        )
        else
        (
            local analysisData = buildCurrentAnalysis()

            if analysisData != undefined then
            (
                AKR_CandidateFrames = AKR_Core.detectPoseCandidates analysisData spnSensitivity.value spnCandidateSpacing.value

                refreshPoseLists()
            )
        )
    )

    on btnGotoCandidate pressed do
    (
        local frame = getSelectedCandidateFrame()

        if frame != undefined then sliderTime = frame
    )

    on btnAddCandidate pressed do
    (
        local frame = getSelectedCandidateFrame()

        if frame != undefined then
        (
            appendIfUnique AKR_LockedFrames frame
            sort AKR_LockedFrames
            refreshPoseLists()
        )
    )

    on btnAddAllCandidates pressed do
    (
        for frame in AKR_CandidateFrames do
        (
            appendIfUnique AKR_LockedFrames frame
        )

        sort AKR_LockedFrames
        refreshPoseLists()
    )


    /* --------------------------------------------------------
        Pose Lock
    -------------------------------------------------------- */

    on btnAddCurrent pressed do
    (
        local frame = sliderTime.frame as integer

        appendIfUnique AKR_LockedFrames frame
        sort AKR_LockedFrames
        refreshPoseLists()
    )

    on btnGotoLocked pressed do
    (
        local frame = getSelectedLockedFrame()

        if frame != undefined then sliderTime = frame
    )

    on btnRemoveLocked pressed do
    (
        local index = lstLocked.selection

        if index > 0 and index <= AKR_LockedFrames.count then
        (
            deleteItem AKR_LockedFrames index
            refreshPoseLists()
        )
    )

    on btnClearLocked pressed do
    (
        AKR_LockedFrames = #()
        refreshPoseLists()
    )


    /* --------------------------------------------------------
        手动恢复当前帧原始 Pose
    -------------------------------------------------------- */

    on btnRestoreCurrent pressed do
    (
        if AKR_RestoreAnalysis == undefined or AKR_RestoreGroups == undefined then
        (
            messageBox "没有精简前的原始 Pose 缓存。请先执行一次精简。" title:"Animation Key Reducer"
        )
        else
        (
            local frame = sliderTime.frame as integer
            local startFrame = AKR_RestoreAnalysis[1].startFrame
            local endFrame = AKR_RestoreAnalysis[1].endFrame

            if frame < startFrame or frame > endFrame then
            (
                messageBox "当前帧不在本次精简的缓存范围内。" title:"Animation Key Reducer"
            )
            else
            (
                local restoreSuccess = true
                local restoredNodes = 0

                undo "Restore Original Pose" on
                (
                    disableSceneRedraw()

                    try
                    (
                        restoredNodes = AKR_Core.restoreFramePose AKR_RestoreAnalysis AKR_RestoreGroups frame
                    )
                    catch
                    (
                        restoreSuccess = false
                        messageBox (getCurrentException()) title:"Animation Key Reducer Error"
                    )

                    enableSceneRedraw()
                    completeRedraw()
                )

                if restoreSuccess then
                (
                    -- 恢复帧成为新的合法 Master Frame，后续再次精简也会被 Pose Lock 保护。
                    appendIfUnique AKR_MasterFrames frame
                    sort AKR_MasterFrames

                    appendIfUnique AKR_LockedFrames frame
                    sort AKR_LockedFrames
                    refreshPoseLists()

                    local finalKeys = AKR_Core.getFinalKeyCount AKR_RestoreGroups
                    local finalTimes = AKR_Core.getUniqueKeyTimes AKR_RestoreGroups startFrame endFrame
                    local keyReduction = 0.0
                    local timeReduction = 0.0

                    if AKR_RestoreOriginalKeys > 0 then
                    (
                        keyReduction = 100.0 * (1.0 - (finalKeys as float / AKR_RestoreOriginalKeys))
                    )

                    if AKR_RestoreOriginalTimesCount > 0 then
                    (
                        timeReduction = 100.0 * (1.0 - (finalTimes.count as float / AKR_RestoreOriginalTimesCount))
                    )

                    local poseCheck = AKR_Core.validateLockedPoses AKR_RestoreAnalysis #(frame) 0

                    lblFinalKeys.text = "精简后 Keys：" + (finalKeys as string)
                    lblReduction.text = "Keys 减少：" + (formattedPrint keyReduction format:"3.1f") + "%"
                    lblFinalTimes.text = "精简关键时间：" + (finalTimes.count as string)
                    lblTimeReduction.text = "时间轴精简：" + (formattedPrint timeReduction format:"3.1f") + "%"

                    lblMasterCount.text = "Master Frames：" + (AKR_MasterFrames.count as string)
                    lblMasterPreview.text = "帧：" + masterPreviewText AKR_MasterFrames
                    lblKeyOps.text = "Key操作：Add " + (AKR_AddSuccessCount as string) + " / Del " + (AKR_DeleteSuccessCount as string) + " / Fail " + ((AKR_AddFailCount + AKR_DeleteFailCount) as string)

                    lblRestoreStatus.text = "已恢复 Frame " + (frame as string) + " / 节点 " + (restoredNodes as string)
                    lblValidation.text = "恢复帧误差：Pos " + (formattedPrint poseCheck[1] format:"3.4f") + " / Rot " + (formattedPrint poseCheck[2] format:"3.4f") + " 度"

                    format "Manual Restore - Frame: %, Nodes: %, Pos Error: %, Rot Error: %\n" frame restoredNodes poseCheck[1] poseCheck[2]
                )
            )
        )
    )


    /* --------------------------------------------------------
        标准 Bone 对齐到 Biped Master Frames
    -------------------------------------------------------- */

    on btnReduceBone pressed do
    (
        if AKR_MasterFrames.count == 0 then
        (
            messageBox "当前没有 Biped Master Frames。请先执行 Biped 精简。" title:"Animation Key Reducer"
        )
        else if selection.count == 0 then
        (
            messageBox "请选择标准 Bone 根骨或需要处理的 Bone。" title:"Animation Key Reducer"
        )
        else
        (
            local selectedNodes = selection as array
            local boneNodes = AKR_Core.expandStandardBoneNodes selectedNodes

            if boneNodes.count == 0 then
            (
                messageBox "选择中没有找到标准 BoneGeometry 骨骼。" title:"Animation Key Reducer"
            )
            else
            (
                local boneGroups = AKR_Core.buildStandardBoneControllerGroups boneNodes

                if boneGroups.count == 0 then
                (
                    messageBox "没有找到可关键帧化的 Bone Controller。" title:"Animation Key Reducer"
                )
                else
                (
                    local startFrame = AKR_MasterFrames[1]
                    local endFrame = AKR_MasterFrames[AKR_MasterFrames.count]
                    local originalKeys = AKR_Core.getOriginalKeyCount boneGroups
                    local originalTimes = AKR_Core.getUniqueKeyTimes boneGroups startFrame endFrame
                    local processSuccess = true

                    -- Bone 操作使用独立统计，不覆盖 Biped 精简和手动恢复的统计。
                    local savedAddFail = AKR_AddFailCount
                    local savedDeleteFail = AKR_DeleteFailCount
                    local savedAddSuccess = AKR_AddSuccessCount
                    local savedDeleteSuccess = AKR_DeleteSuccessCount

                    local boneAddFail = 0
                    local boneDeleteFail = 0
                    local boneAddSuccess = 0
                    local boneDeleteSuccess = 0

                    undo "Align Bone Keys to Biped Master Frames" on
                    (
                        disableSceneRedraw()

                        try
                        (
                            AKR_Core.reduceControllerGroups boneGroups AKR_MasterFrames startFrame endFrame
                        )
                        catch
                        (
                            processSuccess = false
                            messageBox (getCurrentException()) title:"Animation Key Reducer Error"
                        )

                        enableSceneRedraw()
                        completeRedraw()
                    )

                    boneAddFail = AKR_AddFailCount
                    boneDeleteFail = AKR_DeleteFailCount
                    boneAddSuccess = AKR_AddSuccessCount
                    boneDeleteSuccess = AKR_DeleteSuccessCount

                    AKR_AddFailCount = savedAddFail
                    AKR_DeleteFailCount = savedDeleteFail
                    AKR_AddSuccessCount = savedAddSuccess
                    AKR_DeleteSuccessCount = savedDeleteSuccess

                    if processSuccess then
                    (
                        local finalKeys = AKR_Core.getFinalKeyCount boneGroups
                        local finalTimes = AKR_Core.getUniqueKeyTimes boneGroups startFrame endFrame

                        lblBoneStatus.text = "Bone：" + (boneNodes.count as string) + " 节点 / " + (boneGroups.count as string) + " Ctrl / " + (originalKeys as string) + "→" + (finalKeys as string) + " Keys"

                        format "========================================\n"
                        format "Bone Alignment to Biped Master Frames\n"
                        format "Bone Nodes: %\n" boneNodes.count
                        format "Bone Controllers: %\n" boneGroups.count
                        format "Keys: % -> %\n" originalKeys finalKeys
                        format "Unique Times: % -> %\n" originalTimes.count finalTimes.count
                        format "Key Ops - Add Success: %, Delete Success: %, Add Fail: %, Delete Fail: %\n" boneAddSuccess boneDeleteSuccess boneAddFail boneDeleteFail
                        format "Master Frames (%): %\n" AKR_MasterFrames.count AKR_MasterFrames
                        format "========================================\n"
                    )
                    else
                    (
                        lblBoneStatus.text = "Bone 对齐：执行失败"
                    )
                )
            )
        )
    )


    /* --------------------------------------------------------
        分析 Master Frame
    -------------------------------------------------------- */

    on btnAnalyze pressed do
    (
        if selection.count == 0 then
        (
            messageBox "请先选择需要处理的骨骼。" title:"Animation Key Reducer"
        )
        else
        (
            local startFrame = animationRange.start.frame as integer
            local endFrame = animationRange.end.frame as integer

            AKR_LastAnalysis = buildCurrentAnalysis()

            if AKR_LastAnalysis != undefined then
            (
                AKR_LastGroups = AKR_Core.buildControllerGroups AKR_LastAnalysis
                AKR_MasterFrames = buildCurrentMasterFrames AKR_LastAnalysis

                local originalKeys = AKR_Core.getOriginalKeyCount AKR_LastGroups
                local originalTimes = AKR_Core.getUniqueKeyTimes AKR_LastGroups startFrame endFrame

                lblNodes.text = "处理节点：" + (AKR_LastAnalysis.count as string)
                lblControllers.text = "唯一 Controller：" + (AKR_LastGroups.count as string)

                lblOriginalKeys.text = "原始 Keys：" + (originalKeys as string)
                lblFinalKeys.text = "精简后 Keys：等待执行"
                lblReduction.text = "Keys 减少：等待执行"

                lblOriginalTimes.text = "原始关键时间：" + (originalTimes.count as string)
                lblFinalTimes.text = "精简关键时间：预计 " + (AKR_MasterFrames.count as string)
                lblTimeReduction.text = "时间轴精简：等待执行"

                lblMasterCount.text = "Master Frames：" + (AKR_MasterFrames.count as string)
                lblMasterPreview.text = "帧：" + masterPreviewText AKR_MasterFrames
                lblKeyOps.text = "Key操作：等待执行"

                lblTrajectoryError.text = "最大轨迹误差：等待执行"
                lblRotationError.text = "最大旋转误差：等待执行"
                lblLockedError.text = "锁定 Pose 误差：等待执行"
                lblValidation.text = "整体校验：等待执行"

                format "========================================\n"
                format "Animation Key Reducer V0.58 - Analyze\n"
                format "Nodes: %\n" AKR_LastAnalysis.count
                format "Controllers: %\n" AKR_LastGroups.count
                format "Original Unique Times: %\n" originalTimes.count
                format "Master Frames (%): %\n" AKR_MasterFrames.count AKR_MasterFrames
                format "========================================\n"
            )
        )
    )


    /* --------------------------------------------------------
        执行
    -------------------------------------------------------- */

    on btnReduce pressed do
    (
        if selection.count == 0 then
        (
            messageBox "请先选择需要处理的骨骼。" title:"Animation Key Reducer"
        )
        else
        (
            local startFrame = animationRange.start.frame as integer
            local endFrame = animationRange.end.frame as integer

            local analysisData = buildCurrentAnalysis()

            if analysisData != undefined then
            (
                local controllerGroups = AKR_Core.buildControllerGroups analysisData
                local masterFrames = buildCurrentMasterFrames analysisData

                if controllerGroups.count == 0 then
                (
                    messageBox "没有找到可处理的动画 Controller。" title:"Animation Key Reducer"
                )
                else
                (
                    local originalKeys = AKR_Core.getOriginalKeyCount controllerGroups
                    local originalTimes = AKR_Core.getUniqueKeyTimes controllerGroups startFrame endFrame
                    local processSuccess = true

                    -- 单独保存精简前缓存。之后再点“分析”不会覆盖手动恢复所需数据。
                    AKR_RestoreAnalysis = analysisData
                    AKR_RestoreGroups = controllerGroups
                    AKR_RestoreOriginalKeys = originalKeys
                    AKR_RestoreOriginalTimesCount = originalTimes.count

                    undo "Animation Key Reducer V0.58" on
                    (
                        disableSceneRedraw()

                        try
                        (
                            AKR_Core.reduceControllerGroups controllerGroups masterFrames startFrame endFrame
                        )
                        catch
                        (
                            processSuccess = false
                            messageBox (getCurrentException()) title:"Animation Key Reducer Error"
                        )

                        enableSceneRedraw()
                        completeRedraw()
                    )

                    if processSuccess then
                    (
                        local finalKeys = AKR_Core.getFinalKeyCount controllerGroups
                        local finalTimes = AKR_Core.getUniqueKeyTimes controllerGroups startFrame endFrame

                        local keyReduction = 0.0
                        local timeReduction = 0.0

                        if originalKeys > 0 then
                        (
                            keyReduction = 100.0 * (1.0 - (finalKeys as float / originalKeys))
                        )

                        if originalTimes.count > 0 then
                        (
                            timeReduction = 100.0 * (1.0 - (finalTimes.count as float / originalTimes.count))
                        )

                        local validation = AKR_Core.validateAnalysis analysisData spnLocalPos.value spnRotation.value spnTrajectory.value

                        local maxLocalError = validation[1]
                        local maxTrajectoryError = validation[2]
                        local maxRotationError = validation[3]
                        local worstScore = validation[4]
                        local worstNode = validation[5]
                        local worstFrame = validation[6]

                        local lockedValidation = AKR_Core.validateLockedPoses analysisData AKR_LockedFrames spnLockRange.value

                        local lockedPositionError = lockedValidation[1]
                        local lockedRotationError = lockedValidation[2]

                        AKR_MasterFrames = masterFrames
                        AKR_LastAnalysis = analysisData
                        AKR_LastGroups = controllerGroups
                        lblRestoreStatus.text = "恢复缓存：可用"

                        lblNodes.text = "处理节点：" + (analysisData.count as string)
                        lblControllers.text = "唯一 Controller：" + (controllerGroups.count as string)

                        lblOriginalKeys.text = "原始 Keys：" + (originalKeys as string)
                        lblFinalKeys.text = "精简后 Keys：" + (finalKeys as string)
                        lblReduction.text = "Keys 减少：" + (formattedPrint keyReduction format:"3.1f") + "%"

                        lblOriginalTimes.text = "原始关键时间：" + (originalTimes.count as string)
                        lblFinalTimes.text = "精简关键时间：" + (finalTimes.count as string)
                        lblTimeReduction.text = "时间轴精简：" + (formattedPrint timeReduction format:"3.1f") + "%"

                        lblMasterCount.text = "Master Frames：" + (masterFrames.count as string)
                        lblMasterPreview.text = "帧：" + masterPreviewText masterFrames
                        lblKeyOps.text = "Key操作：Add " + (AKR_AddSuccessCount as string) + " / Del " + (AKR_DeleteSuccessCount as string) + " / Fail " + ((AKR_AddFailCount + AKR_DeleteFailCount) as string)

                        lblTrajectoryError.text = "最大轨迹误差：" + (formattedPrint maxTrajectoryError format:"3.4f")
                        lblRotationError.text = "最大旋转误差：" + (formattedPrint maxRotationError format:"3.4f") + " 度"

                        if AKR_LockedFrames.count == 0 then
                        (
                            lblLockedError.text = "锁定 Pose 误差：没有手动锁定"
                        )
                        else
                        (
                            lblLockedError.text = "锁定 Pose：Pos " + (formattedPrint lockedPositionError format:"3.4f") + " / Rot " + (formattedPrint lockedRotationError format:"3.4f") + " 度"
                        )

                        if worstScore <= 1.0 then
                        (
                            lblValidation.text = "整体校验：通过"
                        )
                        else
                        (
                            if worstNode != undefined then
                            (
                                lblValidation.text = "整体校验：超差 " + worstNode.name + " Frame " + (worstFrame as string)
                            )
                            else
                            (
                                lblValidation.text = "整体校验：超差"
                            )
                        )

                        format "========================================\n"
                        format "Animation Key Reducer V0.58\n"
                        format "Original Keys: %\n" originalKeys
                        format "Final Keys: %\n" finalKeys
                        format "Key Reduction: %\n" ((formattedPrint keyReduction format:"3.1f") + "%")
                        format "Original Unique Times: %\n" originalTimes.count
                        format "Final Unique Times: %\n" finalTimes.count
                        format "Time Reduction: %\n" ((formattedPrint timeReduction format:"3.1f") + "%")
                        format "Master Frames (%): %\n" masterFrames.count masterFrames
                        format "Key Ops - Add Success: %, Delete Success: %, Add Fail: %, Delete Fail: %\n" AKR_AddSuccessCount AKR_DeleteSuccessCount AKR_AddFailCount AKR_DeleteFailCount
                        format "Max Local Error: %\n" maxLocalError
                        format "Max Trajectory Error: %\n" maxTrajectoryError
                        format "Max Rotation Error: %\n" maxRotationError
                        format "Worst Score: %\n" worstScore

                        if worstNode != undefined then
                        (
                            format "Worst Node: %\n" worstNode.name
                            format "Worst Frame: %\n" worstFrame
                        )

                        format "========================================\n"
                    )
                )
            )
        )
    )

    on AKR_Rollout open do
    (
        refreshPoseLists()
    )
)

createDialog AKR_Rollout width:350 height:1035
