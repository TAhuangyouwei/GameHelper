fn createFaceBonesFromFile =  -- 根据文档中骨骼名称和坐标创建面部骨骼
(
	-- 定义文件路径
	local initialDir = getDir #userscripts  -- 获取用户脚本目录
	local initialFile = initialDir + "\\combinedBoneData.txt"  -- 为了设置初始路径，可以使用虚构的文件名
	local filename = getOpenFileName caption:"Select Data File" types:"Text Files (*.txt)|*.txt" filename:initialFile


    
    if filename != undefined then 
    (
        local file = openFile filename mode:"r"
        if file != undefined then 
        (
            -- 初始化一个空字符串来收集数据
            local dataString = ""
            while not eof file do
            (
                local line = readLine file
                dataString += line + "\n"
            )
            close file

            -- 后续处理和原来的脚本相同
            local dataLines = filterString dataString "\n"
            local boneName = #()
            local bonePos = #()
            
            -- 遍历每行数据
            for dataLine in dataLines do
            (
                local nameAndPos = filterString dataLine "|"
                if nameAndPos.count >= 2 then 
                (
                    append boneName nameAndPos[1]
                    append bonePos (execute nameAndPos[2])
                )
            )
            
            -- 创建面部骨骼
            local faceBones = #()   
            local num = boneName.count
            for i = 1 to num do 
            (
                -- 复制骨骼并设置名称和变换
                local tempBone = BoneSys.createBone [0,0,0] [0,-2,0] [0,0,1]
                local nodeName = boneName[i] 
                tempBone.name = nodeName
                tempBone.transform = bonePos[i]
                append faceBones tempBone

                -- 如果不是根骨骼，则启用骨骼并设置父级
                if nodeName != "BN_Head_Root_M01" and isValidNode $BN_Head_Root_M01 then 
                (
                    tempBone.parent = $BN_Head_Root_M01
                )     
            )

            -- 设置一些骨骼的长度和父级关系
            if isValidNode $BN_Head_Root_M01 do
            (
                $BN_Head_Root_M01.length = 20
                $BN_Head_Root_M01.boneEnable = false
                if isValidNode $'Bip001 Head' do
                (
                    -- 获取 Biped 骨骼的世界位置
                    local bipedHeadWorldPos = $'Bip001 Head'.transform.pos

                    -- 将 Biped 骨骼的位置应用到目标对象
                    $BN_Head_Root_M01.pos = bipedHeadWorldPos
                )   
            )
            
            -- 其他骨骼的长度设置
            if isValidNode $BN_Jaw_01 do $BN_Jaw_01.length = 15
            if isValidNode $BN_Eye_Pupil_L_01 do $BN_Eye_Pupil_L_01.parent = $BN_Eye_L_01
            if isValidNode $BN_Eye_Pupil_R_01 do $BN_Eye_Pupil_R_01.parent = $BN_Eye_R_01
            if isValidNode $BN_Eye_R_01 do $BN_Eye_R_01.boneEnable = false
            if isValidNode $BN_Eye_L_01 do $BN_Eye_L_01.boneEnable = false
            
            -- 设置骨骼颜色
            for facebone in faceBones do 
            (
                if findString facebone.name "_L_" != undefined then 
                    facebone.wirecolor = (color 28 28 177)
                else if findString facebone.name "_R_" != undefined then 
                    facebone.wirecolor = yellow
                else
                    facebone.wirecolor = (color 6 134 6)
            )
            
            -- 特定骨骼颜色设置
            if isValidNode $BN_Eye_R_01 do $BN_Eye_R_01.wirecolor = red
            if isValidNode $BN_Eye_L_01 do $BN_Eye_L_01.wirecolor = red
				
			if isValidNode $BN_Head_Root_M01 then
			(
				select $BN_Head_Root_M01
				max vpt front
				max zoomext sel
			)
        )
        else
        (
            print "无法打开文件，请检查文件路径和权限。"
        )
    )
    else
    (
        print "未选择任何文件。"
    )
)


fn resetBoneControllers = -- 重置骨骼的控制属性
(
    local bonesToReset

    if selection.count == 0 then -- 如果没有选中的对象
    (
        bonesToReset = for o in objects where classof o == BoneGeometry collect o -- 收集场景中所有骨骼
    )
    else -- 如果有选中的对象
    (
        bonesToReset = for o in selection where classof o == BoneGeometry collect o -- 只收集选中的骨骼
    )

    -- 对收集到的骨骼进行控制器重置
    for bone in bonesToReset do 
    (
        local tempTransform = bone.transform -- 保存当前变换
        bone.pos.controller = Position_XYZ () -- 重置位置控制器
        bone.rotation.controller = Euler_XYZ () -- 重置旋转控制器
        bone.transform = tempTransform -- 恢复原始变换
    )
)

-- 切换虚拟体层级
fn SwitchLayer controllerLayerNum =
(
    childVirtualObject = for j in objects where classof j == point and j.box == true collect j
    for k = 1 to childVirtualObject.count do
    (
        local posController = childVirtualObject[k].position.controller
        local rotController = childVirtualObject[k].rotation.controller

        -- 检查控制器是否有SetActive方法和count属性
        if (isProperty posController #SetActive) and (isProperty posController #count) then
        (
            if posController.count > 3 then
            (
                posController.SetActive controllerLayerNum
            )
        )

        if (isProperty rotController #SetActive) and (isProperty rotController #count) then
        (
            if rotController.count > 3 then
            (
                rotController.SetActive controllerLayerNum
            )
        )
    )
)

fn getBoneInformation =  -- 提取骨骼信息
(
    local userDocuments = getDir #userscripts
    local Outfile = createFile (userDocuments + "\\combinedBoneData_temp.txt")
    if Outfile != undefined then
    (
        for obj in selection do 
        (
            format "%|%\n" obj.name obj.transform to:Outfile
        )
        close Outfile
		messageBox "骨骼信息提取完成！"
    )
    else
    (
        print "无法创建文件，请检查文件路径和权限。"
    )
)







-- 定义一个用于重命名骨骼的函数
fn renameBoneGeometry selectionIndex = (
    -- 骨骼名称前缀的映射
    local namePrefixes = #(
        "BN_EyeBrow_L_", "BN_Eye_L_", "BN_CheekBone_L_", "BN_UpLip_L_",
        "BN_UpLip_", "BN_UpLip_R_", "BN_DownLip_L_", "BN_DownLip_",
        "BN_DownLip_R_", "BN_Jaw_", "BN_Nose_", "BN_EyeBrow_R_",
        "BN_Eye_R_", "BN_CheekBone_R_", "BN_Head_"
    )

    -- 检查索引是否有效
    if selectionIndex > 0 and selectionIndex <= namePrefixes.count then (
        local prefix = namePrefixes[selectionIndex]
        for i = 1 to selection.count where classof selection[i] == BoneGeometry do (
            selection[i].name = uniqueName prefix numDigits:2
        )
    ) else (
        print "Invalid selection index"
    )
)






