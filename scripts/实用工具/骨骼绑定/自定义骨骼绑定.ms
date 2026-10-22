currentFolder = getFilenamePath (getThisScriptFilename())
HYW_Scripts_Library_rulesScript = pathConfig.appendPath currentFolder "../../HYW_Scripts_Library.ms" --函数库
fileIn HYW_Scripts_Library_rulesScript


/*
    功能层
    只负责骨骼绑定相关操作，不依赖 rollout 控件。
*/
struct CustomBoneBindingServiceStruct
(
    fn createCornerBones selectedNodes =
    (
        local nodeCount = selectedNodes.count
        local createdCount = -1

        if nodeCount == 0 then
        (
            local defaultPairs = #(
                #("Bip001 R UpperArm", "Bip001 R Forearm"),
                #("Bip001 L UpperArm", "Bip001 L Forearm"),
                #("Bip001 R Thigh", "Bip001 R Calf"),
                #("Bip001 L Thigh", "Bip001 L Calf")
            )

            createdCount = 0
            for pair in defaultPairs do
            (
                local upperNode = getNodeByName pair[1]
                local lowerNode = getNodeByName pair[2]

                if isValidNode upperNode and isValidNode lowerNode then
                (
                    BipedFunctions.createElbowJoint upperNode lowerNode
                    createdCount += 1
                )
                else
                (
                    format "没有找到绑定节点：% / %\n" pair[1] pair[2]
                )
            )
        )
        else if nodeCount == 2 then
        (
            BipedFunctions.createElbowJoint selectedNodes[1] selectedNodes[2]
            createdCount = 1
        )

        createdCount
    ),

    fn createScaleMuscle selectedNodes =
    (
        BipedFunctions.createMuscleControlSystem selectedNodes[1] selectedNodes[2] selectedNodes[3]
    ),

    fn adjustSpineFlexibility selectedNodes =
    (
        BipedFunctions.adjustSpineFlexibility selectedNodes[1] selectedNodes[2] selectedNodes[3]
        print "ABCD"
    ),

    fn createLegControls selectedNodes =
    (
        local nodeCount = selectedNodes.count

        if nodeCount == 0 or (mod nodeCount 3) != 0 do
        (
            return false
        )

        -- 先检查全部分组，避免选择顺序错误时只创建一半。
        for i = 1 to nodeCount by 3 do
        (
            if classof selectedNodes[i] != BoneGeometry do (return false)
            if classof selectedNodes[i + 1] != BoneGeometry do (return false)
            if classof selectedNodes[i + 2] != Biped_Object do (return false)
        )

        -- 每组三个：自定义上腿骨、自定义下腿骨、对应的 Biped 大腿骨。
        for i = 1 to nodeCount by 3 do
        (
            BipedFunctions.setupLegControlSystem selectedNodes[i] selectedNodes[i + 1] selectedNodes[i + 2]
        )

        true
    ),

    fn createSpineControls selectedNodes =
    (
        undo on
        (
            for obj in selectedNodes do
            (
                BipedFunctions.createSpineControlSystem obj
            )
        )
    ),

    fn createSpiderLeg =
    (
        local customIKSolver = CustomIKHISolver()
        customIKSolver.create()
    ),

    fn createJoint selectedNodes =
    (
        undo on
        (
            BipedFunctions.createJointSystem selectedNodes[1] selectedNodes[2] selectedNodes[3]
        )
    ),

    fn createTranslationMuscle selectedNodes =
    (
        undo on
        (
            BipedFunctions.createMuscleSystem selectedNodes[1] selectedNodes[2] selectedNodes[3]
        )
    ),

    fn buildUpperArmRig bipName side =
    (
        local upperArmName = bipName + " " + side + " UpperArm"
        local foreArmName = bipName + " " + side + " Forearm"
        local upperArm = getNodeByName upperArmName
        local foreArm = getNodeByName foreArmName

        if not isValidNode upperArm then
        (
            format "没有找到节点：%\n" upperArmName
            return undefined
        )

        if not isValidNode foreArm then
        (
            format "没有找到节点：%\n" foreArmName
            return undefined
        )

        local armTM = upperArm.transform
        local startPt = armTM.translation
        local endPt = foreArm.transform.translation
        local middlePt = (startPt + endPt) * 0.5
        local xAxis = normalize armTM.row1
        local yAxis = normalize armTM.row2
        local zAxis = normalize armTM.row3

        -- 创建两根 Bone，并直接链接到 UpperArm。
        local bone01 = BoneSys.createBone startPt middlePt zAxis
        bone01.name = side + "_UpperArm_Bone_01"
        bone01.frontfin = true

        local bone02 = BoneSys.createBone middlePt endPt zAxis
        bone02.name = side + "_UpperArm_Bone_02"
        bone02.frontfin = true

        bone01.parent = upperArm
        bone02.parent = upperArm

        -- 创建圆环，并复制 UpperArm 的位置与轴向。
        local armRing = Circle name:(side + "_UpperArm_Control") radius:13.0 steps:32
        armRing.wirecolor = yellow
        armRing.transform = matrix3 xAxis yAxis zAxis startPt
        armRing.objectOffsetRot = (angleAxis 90 [0, 1, 0]) as quat

        -- 圆环位置约束到 UpperArm。
        local posCtrl = Position_Constraint()
        armRing.pos.controller = posCtrl
        posCtrl.appendTarget upperArm 100.0

        -- Bone01 注视 ForeArm，圆环作为 UpNode。
        local lookAtCtrl = LookAt_Constraint()
        bone01.rotation.controller = lookAtCtrl
        lookAtCtrl.target_axis = 0
        lookAtCtrl.lookat_vector_length = 0
        lookAtCtrl.target_axisFlip = false
        lookAtCtrl.relative = false
        lookAtCtrl.upnode_world = false
        lookAtCtrl.pickUpNode = armRing
        lookAtCtrl.appendTarget foreArm 100.0

        -- Bone02 方向约束。
        local oriCtrl = Orientation_Constraint()
        bone02.rotation.controller = oriCtrl
        oriCtrl.appendTarget upperArm 50.0
        oriCtrl.appendTarget bone01 50.0

        format "% 侧肩膀绑定创建完成。\n" side
        #(bone01, bone02, armRing)
    ),

    fn createClavicleRigs bipName =
    (
        undo on
        (
            local createdNodes = #()
            local leftRig = buildUpperArmRig bipName "L"
            local rightRig = buildUpperArmRig bipName "R"

            if leftRig != undefined do
            (
                join createdNodes leftRig
            )

            if rightRig != undefined do
            (
                join createdNodes rightRig
            )

            if createdNodes.count > 0 then
            (
                select createdNodes
                format "左右肩膀绑定全部创建完成，共创建 % 个对象。\n" createdNodes.count
            )
            else
            (
                messageBox "左右肩膀绑定创建失败，请检查 Biped 节点名称。"
            )
        )
    ),

    fn measureSelectedBones selectedNodes =
    (
        if selectedNodes.count == 0 do
        (
            return undefined
        )

        local measuredLength = 0
        local boneNodes = for obj in selectedNodes where classof obj == BoneGeometry collect obj
        local bipedNodes = for obj in selectedNodes where classof obj == Biped_Object collect obj

        -- 普通 Bone：直接累计所有已选骨骼的 Length。
        if boneNodes.count == selectedNodes.count then
        (
            for obj in boneNodes do
            (
                measuredLength += obj.length
            )

            return measuredLength
        )

        -- Biped：按选择顺序累计相邻节点之间的距离。
        if selectedNodes.count >= 2 and bipedNodes.count == selectedNodes.count then
        (
            for i = 2 to selectedNodes.count do
            (
                measuredLength += distance selectedNodes[i - 1] selectedNodes[i]
            )

            return measuredLength
        )

        undefined
    )
)

global customBoneBindingService = CustomBoneBindingServiceStruct()


/*
    界面层
    只负责布局、收集当前选择并调用功能层。
*/
try (destroyDialog boneFin) catch()

rollout boneFin "自定义骨骼绑定"
(
    button createConerBone "手肘膝盖创建" height:21 width:130 tooltip:"不选择：自动创建 Bip001 左右手肘和膝盖；选择2个：创建单个关节" across:2
    button btmuscle "肌肉创建(缩放)" height:21 width:130 tooltip:"依次选择3个物体 upper lower muscle(肩膀、头、肌肉)"

    button btLegCtrl "马腿控制器(选3个)" height:21 width:130 tooltip:"依次选择：自定义上腿骨、自定义下腿骨、对应的 Biped 大腿骨" across:2
    button btSpineCtrl "创建脊椎控制器" height:21 width:130 tooltip:"创建出来脊椎骨骼的控制器系统"

    button btCustomIKHISolver "蜘蛛腿创建" height:21 width:130 tooltip:"双击全选单个腿的所有骨骼(算上末端骨3根或5根)" across:2
    button btn_Measure "测量物体长度" height:21 width:130 tooltip:"普通Bone可选任意数量；Biped至少选2个，并按骨链顺序选择"

    button btn_Joint "关节创建" height:21 width:130 tooltip:"需要依次选择三个物体" across:2
    button btn_Muscle "肌肉创建(位移)" height:21 width:130 tooltip:"Bone骨骼需要X轴向前，Y轴向上"

    button btn_Clavicle "肩膀绑定" height:21 width:130 tooltip:"解决抬胳膊问题"
    label lbl_Measure "骨骼的测量长度为:"

    on createConerBone pressed do
    (
        local selectedNodes = selection as array
        local createdCount = customBoneBindingService.createCornerBones selectedNodes

        if createdCount == -1 then
        (
            messageBox "使用方法：\n\n不选择任何物体：自动创建 Bip001 左右手肘和膝盖。\n选择两个物体：按父级、子级顺序创建单个关节。"
        )
        else if selectedNodes.count == 0 and createdCount < 4 then
        (
            messageBox ("自动创建完成 " + (createdCount as string) + "/4 组。\n未创建的部分请检查 Bip001 手臂和腿部节点名称。")
        )
    )

    on btmuscle pressed do
    (
        customBoneBindingService.createScaleMuscle (selection as array)
    )

    on btmuscle rightclick do
    (
        customBoneBindingService.adjustSpineFlexibility (selection as array)
    )

    on btLegCtrl pressed do
    (
        local succeeded = customBoneBindingService.createLegControls (selection as array)

        if not succeeded do
        (
            messageBox "马腿控制器使用方法：\n\n依次选择 3 个物体：\n1. 自定义上腿 Bone\n2. 自定义下腿 Bone\n3. 对应的 Biped 大腿骨（Thigh）\n\n前两个必须是普通 Bone，第三个必须是 Biped。\n建议每次只处理一条腿；批量处理时，选择数量必须是 3 的倍数。"
        )
    )

    on btSpineCtrl pressed do
    (
        customBoneBindingService.createSpineControls (selection as array)
    )

    on btCustomIKHISolver pressed do
    (
        customBoneBindingService.createSpiderLeg()
    )

    on btn_Joint pressed do
    (
        customBoneBindingService.createJoint (selection as array)
    )

    on btn_Muscle pressed do
    (
        customBoneBindingService.createTranslationMuscle (selection as array)
    )

    on btn_Clavicle pressed do
    (
        customBoneBindingService.createClavicleRigs "Bip001"
    )

    on btn_Measure pressed do
    (
        local measuredLength = customBoneBindingService.measureSelectedBones (selection as array)

        if measuredLength == undefined then
        (
            lbl_Measure.text = "测量失败：选择类型或数量不正确"
            messageBox "测量方法：\n\n普通 Bone：选择一个或多个 Bone 后点击，结果为 Length 总和。\nBiped：选择至少两个 Biped 骨骼，并按骨链顺序选择，结果为相邻节点的距离总和。\n\n请不要混选普通 Bone、Biped 或其它物体。"
        )
        else
        (
            lbl_Measure.text = "骨骼的测量长度为:" + (measuredLength as string)
        )
    )
)

createDialog boneFin 300 155
