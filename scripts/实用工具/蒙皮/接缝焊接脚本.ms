-- 定义全局变量，用于存储当前接近顶点对的索引以及参考顶点权重
global currentCloseVerticesPairIndex
global copiedVertexWeights = #() -- 存储每个复制顶点的骨骼ID和权重
currentCloseVerticesPairIndex = 1

-- 增加全局计数器用于跟踪点击次数
global clickCount = 0  -- 用于跟踪点击的次数

-- 存储第一个和第二个点的权重
global firstBoneIDs = #()   -- 存储第一个点的骨骼ID
global firstWeights = #()   -- 存储第一个点的权重
global secondBoneIDs = #()  -- 存储第二个点的骨骼ID
global secondWeights = #()  -- 存储第二个点的权重

-- 存储上一次选中的两个点的ID
global lastFirstVertID = undefined
global lastSecondVertID = undefined


-- 查找给定对象上的指定类型的修改器
fn findModifier obj modType =
(
    if obj != undefined then 
    (
        for mod in obj.modifiers where classOf mod == modType do return mod
    )
    return undefined
)

-- 创建一个映射表，用于将 Skin 修改器中的骨骼名称和ID对应起来
fn createBoneNameIDMap skinModifier =
(
    local boneMap = #() 
    local boneNodes = skinOps.GetBoneNodes skinModifier 
    for i = 1 to boneNodes.count do
    (
        append boneMap #(boneNodes[i].name, i) 
    )
    return boneMap 
)

-- 确保源修改器中的所有骨骼都存在于目标修改器中
fn ensureAllBonesExist sourceMod targetMod =
(
    local sourceBones = skinOps.GetBoneNodes sourceMod
    local targetBones = skinOps.GetBoneNodes targetMod
    local targetBoneNames = for bone in targetBones collect bone.name

    for sourceBone in sourceBones do
    (
        if (findItem targetBoneNames sourceBone.name) == 0 do
        (
            skinOps.addBone targetMod sourceBone 1
        )
    )
)

-- 自动查找两个模型间的接近顶点对，并转移 Skin 权重
fn autoStitchOptimized node1 node2 threshold =
(
    if classOf node1.baseobject != Editable_Poly then return undefined
    if classOf node2.baseobject != Editable_Poly then return undefined

    local skinMod1 = findModifier node1 Skin
    local skinMod2 = findModifier node2 Skin

    if skinMod1 == undefined or skinMod2 == undefined do return undefined

    ensureAllBonesExist skinMod1 skinMod2

    local vertsPos1 = for i = 1 to skinOps.GetNumberVertices skinMod1 collect (polyOp.getVert node1.baseobject i)
    local vertsPos2 = for i = 1 to skinOps.GetNumberVertices skinMod2 collect (polyOp.getVert node2.baseobject i)

    local closeVertexPairs = #()
    for i = 1 to vertsPos1.count do
    (
        local minDist = threshold 
        local closestIndex = 0 

        for j = 1 to vertsPos2.count do
        (
            local dist = distance vertsPos1[i] vertsPos2[j]
            if dist < minDist do
            (
                minDist = dist
                closestIndex = j
            )
        )

        if closestIndex > 0 do append closeVertexPairs #(i, closestIndex)
    )

    local transferredWeightsCount = 0

    for pair in closeVertexPairs do
    (
        local i = pair[1] 
        local j = pair[2] 
        
        local boneCount = skinOps.GetVertexWeightCount skinMod1 i
        local copiedBoneIDs = #() 
        local copiedWeights = #() 

        for k = 1 to boneCount do
        (
            local weight = skinOps.GetVertexWeight skinMod1 i k
            local boneID1 = skinOps.GetVertexWeightBoneID skinMod1 i k
            local boneName = skinOps.GetBoneName skinMod1 boneID1 0

            local targetBoneID = 0
            for bonePair in createBoneNameIDMap(skinMod2) where bonePair[1] == boneName do
            (
                targetBoneID = bonePair[2]
            )

            if targetBoneID > 0 do
            (
                append copiedBoneIDs targetBoneID
                append copiedWeights weight
            )
        )

        if copiedBoneIDs.count > 0 do
        (
            skinOps.ReplaceVertexWeights skinMod2 j copiedBoneIDs copiedWeights
            transferredWeightsCount += copiedWeights.count
        )
    )
)

-- 设置参考顶点（可以复制多个顶点）
fn setReferenceVertices skinMod =
(
    local selectedVerts = skinOps.GetSelectedVertices skinMod
    if selectedVerts.count > 0 then 
    (
        copiedVertexWeights = #() 

        for vert in selectedVerts do
        (
            local boneCount = skinOps.GetVertexWeightCount skinMod vert
            local boneIDs = #()
            local weights = #()

            for k = 1 to boneCount do
            (
                local weight = skinOps.GetVertexWeight skinMod vert k
                local boneID = skinOps.GetVertexWeightBoneID skinMod vert k
                append boneIDs boneID
                append weights weight
            )
            append copiedVertexWeights #(boneIDs, weights)
        )
    )
)

-- 将复制的权重按顺序应用到其他选中的顶点
fn unifySelectedVertexWeights skinMod =
(
    if copiedVertexWeights.count == 0 then return undefined 

    local selectedVerts = skinOps.GetSelectedVertices skinMod
    local numCopied = copiedVertexWeights.count
    local numSelected = selectedVerts.count

    for i = 1 to numSelected do
    (
        local sourceIndex = if i <= numCopied then i else numCopied

        local boneIDs = copiedVertexWeights[sourceIndex][1]
        local weights = copiedVertexWeights[sourceIndex][2]

        skinOps.ReplaceVertexWeights skinMod selectedVerts[i] boneIDs weights
    )
)

-- 创建工具窗口UI
try (DestroyDialog skinWeightsRollout) catch ()
rollout skinWeightsRollout "自动权重工具" width:180 height:160
(
    button btnAutoStitch "自动同步接缝权重" width:160 height:30 tooltip:"把模型1的接缝权重赋值给接缝2"
    button btnCopyWeights "同步选中点的权重" width:160 height:30 tooltip:"同步两个点的权重(可以多次点击交换)"

    -- 自动缝合功能按钮
    on btnAutoStitch pressed do  
    (
        if selection.count == 2 then
        (
            autoStitchOptimized selection[1] selection[2] 0.02
        )
        else messagebox "请选择两个对象进行自动缝合。"
    )

    -- 复制选中点权重功能按钮
    on btnCopyWeights pressed do  
    (
        if selection.count > 0 then
        (
            local skinMod = findModifier selection[1] Skin
            if skinMod != undefined then
            (
                local selectedVerts = skinOps.GetSelectedVertices skinMod
                if selectedVerts.count == 2 then
                (
                    local firstVert = selectedVerts[1]
                    local secondVert = selectedVerts[2]

                    -- 如果选中的顶点ID发生变化，重置点击计数
                    if (firstVert != lastFirstVertID or secondVert != lastSecondVertID) then
                    (
                        clickCount = 0  -- 重置点击计数
                        lastFirstVertID = firstVert  -- 更新第一个点ID
                        lastSecondVertID = secondVert  -- 更新第二个点ID
                    )

                    -- 如果是第一次点击，存储两个点的权重
                    if clickCount == 0 then
                    (
                        -- 获取第一个点的权重
                        firstBoneIDs = #()
                        firstWeights = #()
                        local boneCount1 = skinOps.GetVertexWeightCount skinMod firstVert
                        for k = 1 to boneCount1 do
                        (
                            local weight = skinOps.GetVertexWeight skinMod firstVert k
                            local boneID = skinOps.GetVertexWeightBoneID skinMod firstVert k
                            append firstBoneIDs boneID
                            append firstWeights weight
                        )

                        -- 获取第二个点的权重
                        secondBoneIDs = #()
                        secondWeights = #()
                        local boneCount2 = skinOps.GetVertexWeightCount skinMod secondVert
                        for k = 1 to boneCount2 do
                        (
                            local weight = skinOps.GetVertexWeight skinMod secondVert k
                            local boneID = skinOps.GetVertexWeightBoneID skinMod secondVert k
                            append secondBoneIDs boneID
                            append secondWeights weight
                        )
                    )
                    
                    -- 判断clickCount的奇偶性
                    if (mod clickCount 2) == 1 then
                    (
                        -- 奇数点击：将第一个点的权重复制给第二个点

						if skinOps.isWeightToolOpen skinMod then 
						(
							skinOps.closeWeightTool skinMod
							skinOps.ReplaceVertexWeights skinMod secondVert firstBoneIDs firstWeights
							skinOps.ReplaceVertexWeights skinMod firstVert firstBoneIDs firstWeights
							skinOps.SelectVertices skinMod #()
							forceCompleteRedraw()
							skinOps.SelectVertices skinMod selectedVerts 
							forceCompleteRedraw()
							skinOps.weightTool skinMod 
						)
						else
						(
							skinOps.weightTool skinMod 
						)
						
							
						
						
                    )
                    else
                    (
                        -- 偶数点击：恢复第二个点的原始权重，并复制到第一个和第二个点						
						if skinOps.isWeightToolOpen skinMod then 
						(
							skinOps.closeWeightTool skinMod
							skinOps.ReplaceVertexWeights skinMod firstVert secondBoneIDs secondWeights
							skinOps.ReplaceVertexWeights skinMod secondVert secondBoneIDs secondWeights
							skinOps.SelectVertices skinMod #()
							forceCompleteRedraw()
							skinOps.SelectVertices skinMod selectedVerts 
							forceCompleteRedraw()
							skinOps.weightTool skinMod 
						)
						else
						(
							skinOps.weightTool skinMod 
						)

						
                    )
                    
                    -- 增加点击计数
                    clickCount += 1
                )
                else messagebox "请选择两个顶点。"
            )
            else messagebox "选中的对象没有Skin修改器。"
        )
        else messagebox "请选择至少一个对象。"
    )
)

createdialog skinWeightsRollout 200 80
