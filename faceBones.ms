fn createFaceBonesFromFile =  -- �����ĵ��й������ƺ����괴���沿����
(
	-- �����ļ�·��
	local initialDir = getDir #userscripts  -- ��ȡ�û��ű�Ŀ¼
	local initialFile = initialDir + "\\combinedBoneData.txt"  -- Ϊ�����ó�ʼ·��������ʹ���鹹���ļ���
	local filename = getOpenFileName caption:"Select Data File" types:"Text Files (*.txt)|*.txt" filename:initialFile


    
    if filename != undefined then 
    (
        local file = openFile filename mode:"r"
        if file != undefined then 
        (
            -- ��ʼ��һ�����ַ������ռ�����
            local dataString = ""
            while not eof file do
            (
                local line = readLine file
                dataString += line + "\n"
            )
            close file

            -- ����������ԭ���Ľű���ͬ
            local dataLines = filterString dataString "\n"
            local boneName = #()
            local bonePos = #()
            
            -- ����ÿ������
            for dataLine in dataLines do
            (
                local nameAndPos = filterString dataLine "|"
                if nameAndPos.count >= 2 then 
                (
                    append boneName nameAndPos[1]
                    append bonePos (execute nameAndPos[2])
                )
            )
            
            -- �����沿����
            local faceBones = #()   
            local num = boneName.count
            for i = 1 to num do 
            (
                -- ���ƹ������������ƺͱ任
                local tempBone = BoneSys.createBone [0,0,0] [0,-2,0] [0,0,1]
                local nodeName = boneName[i] 
                tempBone.name = nodeName
                tempBone.transform = bonePos[i]
                append faceBones tempBone

                -- ������Ǹ������������ù��������ø���
                if nodeName != "BN_Head_Root_M01" and isValidNode $BN_Head_Root_M01 then 
                (
                    tempBone.parent = $BN_Head_Root_M01
                )     
            )

            -- ����һЩ�����ĳ��Ⱥ͸�����ϵ
            if isValidNode $BN_Head_Root_M01 do
            (
                $BN_Head_Root_M01.length = 20
                $BN_Head_Root_M01.boneEnable = false
                if isValidNode $'Bip001 Head' do
                (
                    -- ��ȡ Biped ����������λ��
                    local bipedHeadWorldPos = $'Bip001 Head'.transform.pos

                    -- �� Biped ������λ��Ӧ�õ�Ŀ�����
                    $BN_Head_Root_M01.pos = bipedHeadWorldPos
                )   
            )
            
            -- ���������ĳ�������
            if isValidNode $BN_Jaw_01 do $BN_Jaw_01.length = 15
            if isValidNode $BN_Eye_Pupil_L_01 do $BN_Eye_Pupil_L_01.parent = $BN_Eye_L_01
            if isValidNode $BN_Eye_Pupil_R_01 do $BN_Eye_Pupil_R_01.parent = $BN_Eye_R_01
            if isValidNode $BN_Eye_R_01 do $BN_Eye_R_01.boneEnable = false
            if isValidNode $BN_Eye_L_01 do $BN_Eye_L_01.boneEnable = false
            
            -- ���ù�����ɫ
            for facebone in faceBones do 
            (
                if findString facebone.name "_L_" != undefined then 
                    facebone.wirecolor = (color 28 28 177)
                else if findString facebone.name "_R_" != undefined then 
                    facebone.wirecolor = yellow
                else
                    facebone.wirecolor = (color 6 134 6)
            )
            
            -- �ض�������ɫ����
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
            print "�޷����ļ��������ļ�·����Ȩ�ޡ�"
        )
    )
    else
    (
        print "δѡ���κ��ļ���"
    )
)


fn resetBoneControllers = -- ���ù����Ŀ�������
(
    local bonesToReset

    if selection.count == 0 then -- ���û��ѡ�еĶ���
    (
        bonesToReset = for o in objects where classof o == BoneGeometry collect o -- �ռ����������й���
    )
    else -- �����ѡ�еĶ���
    (
        bonesToReset = for o in selection where classof o == BoneGeometry collect o -- ֻ�ռ�ѡ�еĹ���
    )

    -- ���ռ����Ĺ������п���������
    for bone in bonesToReset do 
    (
        local tempTransform = bone.transform -- ���浱ǰ�任
        bone.pos.controller = Position_XYZ () -- ����λ�ÿ�����
        bone.rotation.controller = Euler_XYZ () -- ������ת������
        bone.transform = tempTransform -- �ָ�ԭʼ�任
    )
)

-- �л�������㼶
fn SwitchLayer controllerLayerNum =
(
    childVirtualObject = for j in objects where classof j == point and j.box == true collect j
    for k = 1 to childVirtualObject.count do
    (
        local posController = childVirtualObject[k].position.controller
        local rotController = childVirtualObject[k].rotation.controller

        -- ���������Ƿ���SetActive������count����
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

fn getBoneInformation =  -- ��ȡ������Ϣ
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
		messageBox "������Ϣ��ȡ��ɣ�"
    )
    else
    (
        print "�޷������ļ��������ļ�·����Ȩ�ޡ�"
    )
)







-- ����һ�����������������ĺ���
fn renameBoneGeometry selectionIndex = (
    -- ��������ǰ׺��ӳ��
    local namePrefixes = #(
        "BN_EyeBrow_L_", "BN_Eye_L_", "BN_CheekBone_L_", "BN_UpLip_L_",
        "BN_UpLip_", "BN_UpLip_R_", "BN_DownLip_L_", "BN_DownLip_",
        "BN_DownLip_R_", "BN_Jaw_", "BN_Nose_", "BN_EyeBrow_R_",
        "BN_Eye_R_", "BN_CheekBone_R_", "BN_Head_"
    )

    -- ��������Ƿ���Ч
    if selectionIndex > 0 and selectionIndex <= namePrefixes.count then (
        local prefix = namePrefixes[selectionIndex]
        for i = 1 to selection.count where classof selection[i] == BoneGeometry do (
            selection[i].name = uniqueName prefix numDigits:2
        )
    ) else (
        print "Invalid selection index"
    )
)





