try (destroydialog Reset_tpose) catch()  -- 尝试销毁现有对话框，如果不存在则忽略
rollout Reset_tpose "重置蒙皮pose V1.1" width:200
(
    -- 按钮和超链接定义
    button resetButton "一键重置" width:100 height:32 align:#center offset:[0,8]
    -- 获取节点的父节点
    fn getParentNode nodes =
    (
        local currentParent = nodes
        local finalParent = nodes
        while true do (
            currentParent = currentParent.parent  -- 循环找到父节点
            if currentParent != undefined do(
                finalParent = currentParent  -- 更新最终父节点
            )
            if currentParent == undefined do(
                exit  -- 如果没有父节点则退出
            )
        )
        finalParent  -- 返回最终父节点
    )

    -- 获取所有子节点
    fn getAllChildren nodes =
    (
        local childArray = #()  -- 创建一个空数组存储子节点
        for child in nodes do append childArray child  -- 将每个子节点添加到数组中
        childArray  -- 返回子节点数组
    )

    -- 重置到 T-Pose 的函数
    fn resetToTpose modelNodes nodeList =
    (
        max modify mode  -- 切换到修改模式
        local tposeNames = #()  -- 存储 T-Pose 骨骼名称
        local tposeTransforms = #()  -- 存储 T-Pose 骨骼变换
        local rootTransforms = #()  -- 存储根骨骼变换
        local rootNodes = #()  -- 存储根骨骼节点
        local allChildren = #()  -- 存储所有子节点
        local hasBip = false  -- 是否有 Bip 骨架标志
        local completedTransforms = #()  -- 存储完成的变换
        unfreeze objects  -- 解冻所有对象
        
        -- 遍历模型节点
        for i = 1 to modelNodes.count do (
            local skinModifier = modelNodes[i].modifiers[#Skin]  -- 获取 Skin 修改器
            modPanel.setCurrentObject skinModifier  -- 设置当前修改器
            local boneCount = skinOps.getnumberbones skinModifier  -- 获取骨骼数量
            
            -- 遍历骨骼
            for ii = 1 to boneCount do (
                local boneName = skinOps.GetBoneName skinModifier ii 0  -- 获取骨骼名称
                local index = finditem tposeNames boneName  -- 查找骨骼名称是否已存在
                if index == 0 do (
                    append tposeNames boneName  -- 如果不存在，添加骨骼名称
                    append tposeTransforms (skinUtils.GetBoneBindTM modelNodes[i] (getNodeByName boneName))  -- 添加骨骼变换
                    if (matchpattern boneName pattern:"*Bip*Pelvis*") do (
                        hasBip = true  -- 标记为存在 Bip 骨架
                        append rootTransforms (skinUtils.GetBoneBindTM modelNodes[i] (getNodeByName boneName))  -- 添加根骨骼变换
                        try (
                            append rootNodes (getNodeByName boneName).parent  -- 获取根骨骼节点
                        ) catch (
                            messagebox "bip骨架缺少根骨骼"  -- 弹出错误提示
                        )
                    )
                )
            )
        )
        
        -- 如果存在 Bip 骨架
        if hasBip then(
            if rootNodes.count != 0 do(
                animate on  -- 开启动画
                at time 0(
                    for i = 1 to rootNodes.count do(
                        rootNodes[i].transform = rootTransforms[i]  -- 设置根骨骼变换
                        in coordsys local rotate rootNodes[i] (eulerangles 0 0 90)  -- 旋转根骨骼
                        in coordsys local rotate rootNodes[i] (eulerangles 90 0 0)  -- 旋转根骨骼
                        allChildren = getAllChildren rootNodes[i]  -- 获取所有子节点
                        for ii = 1 to allChildren.count do (
                            index = finditem tposeNames allChildren[ii].name  -- 查找子节点名称
                            if index != 0 do(
                                allChildren[ii].transform = tposeTransforms[index]  -- 设置子节点变换
                                append completedTransforms allChildren[ii].name  -- 添加到完成列表
                            )
                        )
                    )
                )
            )
            -- 处理 T-Pose 骨骼
            for i = 1 to tposeNames.count do (
                index = finditem completedTransforms tposeNames[i]
                if index == 0 do( 
                    reParent = getParentNode (getNodeByName(tposeNames[i]))  -- 获取父节点
                    reAllChildren = getAllChildren reParent  -- 获取所有子节点
                    for ii = 1 to reAllChildren.count do(
                        index2 = finditem tposeNames reAllChildren[ii].name  -- 查找子节点名称
                        if index2 != 0 do(
                            animate on
                            at time 0(
                                reAllChildren[ii].transform = tposeTransforms[index2]  -- 设置变换
                            )
                        )
                    )
                    exit  -- 退出
                )
            )
        ) else (
            -- 如果没有 Bip 骨架，处理节点列表
            for i = 1 to nodeList.count do (
                index = finditem tposeNames nodeList[i].name
                if index != 0 do(
                    animate on
                    at time 0(
                        nodeList[i].transform = tposeTransforms[index]  -- 设置节点变换
                    )
                )
            )
        )
    )



    -- 按钮被按下时执行的操作
    on resetButton pressed do(
        modelNodes = #()  -- 创建模型节点数组
        nodeList = #()  -- 创建节点列表
        
        -- 获取所有具有 Skin 修改器的对象
        for obj in objects where (classof obj == Editable_mesh or classof obj == PolyMeshObject or classof obj == Editable_Poly) and (obj.modifiers[#Skin] != undefined) do append modelNodes obj
        -- 获取所有 Dummy 或 BoneGeometry 类型的对象
        for obj in objects where (classof obj == Dummy or classof obj == BoneGeometry) do append nodeList obj

        try (
            resetToTpose modelNodes nodeList  -- 调用重置函数
            sliderTime = 0f  -- 将时间滑块设置为 0
        ) catch (
            messagebox "重置失败"  -- 弹出错误提示
        )
    )
)

createDialog Reset_tpose  -- 创建对话框
