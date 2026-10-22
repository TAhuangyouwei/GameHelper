/*
    Biped、辅助骨骼和肌肉控制相关功能。
    从 HYW_Scripts_Library.ms 拆出，保留原结构名和调用方式。
*/

-- BoneFunctions.ms
struct BipedFunctions
(
    -- 创建手肘或者膝盖的骨骼连接
    fn createElbowJoint upperArmBone forearmBone =
    (
        -- 创建一个点作为手肘/膝盖的位置参考
        elbowKneePoint = point cross:on box:on size:20
        elbowKneePoint.transform = upperArmBone.transform

        -- 添加位置约束和旋转约束
        positionConstraint = Position_Constraint()
        orientationConstraint = Orientation_Constraint()

        -- 为创建的点设置位置控制器和旋转控制器
        elbowKneePoint.pos.controller = positionConstraint
        elbowKneePoint.rotation.controller = orientationConstraint

        -- 获取位置约束和旋转约束的接口
        positionConstraintInterface = positionConstraint.constraints
        orientationConstraintInterface = orientationConstraint.constraints

        -- 添加目标到位置约束和旋转约束
        positionConstraintInterface.appendTarget forearmBone 50.0
        orientationConstraintInterface.appendTarget forearmBone 50.0
        orientationConstraintInterface.appendTarget upperArmBone 50.0

        -- 创建一个骨骼并调整其位置和旋转
        bone = BoneSys.createBone [0,0,0] [10,0,0] [0,0,1]
        bone.transform = elbowKneePoint.transform
        in coordsys local rotate bone (EulerAngles 0 0 90)

        -- 添加链接约束到骨骼
        linkConstraint = Link_Constraint ()
        bone.Transform.controller = linkConstraint
        linkConstraint.key_mode = 0
        linkConstraint.addTarget elbowKneePoint 0
        bone.parent = upperArmBone
    ),

    -- 创建肌肉骨骼(缩放)
    fn createMuscleControlSystem upperArmBone forearmBone muscleBone =
    (
        bonesArray = #(upperArmBone, forearmBone)

        if (classof muscleBone == BoneGeometry) then
        (
            muscleLength = muscleBone.Length
            pointArray = #()

            for i = 1 to 2 do
            (
                controlPoint = point cross:on box:on size:5
                append pointArray controlPoint
                controlPoint.transform = muscleBone.transform

                if i == 2 then
                (
                    in coordsys local move controlPoint [muscleLength, 0, 0]
                )

                linkConstraint = Link_Constraint ()
                controlPoint.Transform.controller = linkConstraint
                linkConstraint.key_mode = 0
                linkConstraint.addTarget bonesArray[i] 0
            )

            positionConstraint = Position_Constraint()
            lookAtConstraint = LookAt_Constraint()

            muscleBone.pos.controller = positionConstraint
            muscleBone.scale.controller = ScaleXYZ()
            muscleBone.rotation.controller = lookAtConstraint

            muscleBone.scale.controller.X_Scale.controller = float_expression()
            distanceValue = distance pointArray[1] pointArray[2]

            muscleBone.scale.controller.X_Scale.controller.AddScalarConstant "dis" distanceValue
            muscleBone.scale.controller.X_Scale.controller.AddVectorNode "a" pointArray[1]
            muscleBone.scale.controller.X_Scale.controller.AddVectorNode "b" pointArray[2]
            muscleBone.scale.controller.X_Scale.controller.setExpression "length(a-b)/dis"

            positionConstraintInterface = positionConstraint.constraints
            rotationConstraintInterface = lookAtConstraint.constraints

            positionConstraintInterface.appendTarget pointArray[1] 50.0
            rotationConstraintInterface.appendTarget pointArray[2] 50.0

            lookAtConstraint.viewline_length_abs = off
            lookAtConstraint.upnode_world = off

            if findString upperArmBone.name "head" == undefined then
                lookAtConstraint.pickUpNode = pointArray[1]
            else
                lookAtConstraint.pickUpNode = pointArray[2]

            muscleBone.parent = upperArmBone
        )
    ),

	-- 创建四肢肌肉骨骼(好方法)
	fn createMuscleSystem upperBone lowerBone muscleBone =
	(
		bonesArray = #(upperBone, lowerBone)

		if (classof muscleBone == BoneGeometry) then
		(

			posPoint = point cross:on box:off size:5
			posPoint.transform = muscleBone.transform

			expPoint = point cross:off box:on size:5
			expPoint.transform = muscleBone.transform

			expPoint.parent = posPoint

			upperPoint = point cross:on box:on size:5 transform:upperBone.transform

			linkConstraint = Link_Constraint ()
			upperPoint.Transform.controller = linkConstraint
			linkConstraint.key_mode = 0
			linkConstraint.addTarget bonesArray[1] 0

			lowerPoint = point cross:on box:on size:5  transform:lowerBone.transform

			linkConstraint = Link_Constraint ()
			lowerPoint.Transform.controller = linkConstraint
			linkConstraint.key_mode = 0
			linkConstraint.addTarget bonesArray[2] 0

			pointArray = #(posPoint,expPoint,upperPoint,lowerPoint)





			-- 配置controlObject的位置控制器
			controlObject = circle radius:3 wirecolor:yellow pos:[muscleBone.length,0,0]
			controlObject.name = replace muscleBone.name 1 4 "CON_"
			controlObject.Position.controller = position_list ()
			controlObject.Position.controller.Available.controller = Position_XYZ ()
			controlObject.Position.controller[1].controller = Bezier_Position ()
			listctrl.setname controlObject.Position.controller 1 "Frozen Position"
			listctrl.setname controlObject.Position.controller 2 "Zero Pos XYZ"
			controlObject.position.controller.SetActive 2

			-- 配置controlObject的旋转控制器
			controlObject.rotation.controller = Rotation_list ()
			controlObject.rotation.controller.Available.controller = Euler_XYZ ()
			listctrl.setname controlObject.rotation.controller 1 "Frozen Rotation"
			listctrl.setname controlObject.rotation.controller 2 "Zero Euler XYZ"
			controlObject.rotation.controller.SetActive 2

			controlObject.parent = pointArray[2]




			linkConstraint = Link_Constraint ()
			posPoint.Transform.controller = linkConstraint
			linkConstraint.key_mode = 0
			linkConstraint.addTarget bonesArray[1] 0


			linkConstraint = Link_Constraint ()
			muscleBone.Transform.controller = linkConstraint
			linkConstraint.key_mode = 0
			linkConstraint.addTarget pointArray[2] 0

			expPoint.pos.controller.X_Position.controller = float_expression()
			expPoint.pos.controller.Y_Position.controller = float_expression()

			distanceValue = distance pointArray[3] pointArray[4]

			expPoint.pos.controller.X_Position.controller.AddScalarConstant "dis" distanceValue
			expPoint.pos.controller.X_Position.controller.AddVectorNode "a" pointArray[3]
			expPoint.pos.controller.X_Position.controller.AddVectorNode "b" pointArray[4]
			expPoint.pos.controller.X_Position.controller.setExpression "if(length(a-b)>9,dis/length(a-b)-1,dis/9-1)"


			expPoint.pos.controller.Y_Position.controller.AddScalarConstant "dis" distanceValue
			expPoint.pos.controller.Y_Position.controller.AddVectorNode "a" pointArray[3]
			expPoint.pos.controller.Y_Position.controller.AddVectorNode "b" pointArray[4]
			expPoint.pos.controller.Y_Position.controller.setExpression "if(length(a-b)>9,dis/length(a-b)-1,dis/9-1)"

			muscleBone.parent = bonesArray[1]
			if classof bonesArray[1] == BoneGeometry then
				muscleBone.boneEnable= false
		)
	),

		-- 创建关节
	fn createJointSystem upperBone lowerBone endBone =
	(
		bonesArray = #(upperBone, lowerBone,endBone)

		posPoint = point cross:on box:off size:5
		posPoint.transform = bonesArray[2].transform

		expPoint = point cross:off box:on size:5
		expPoint.transform = posPoint.transform

		expPoint.parent = posPoint


        -- 添加位置约束和旋转约束
        positionConstraint = Position_Constraint()
        orientationConstraint = Orientation_Constraint()

        -- 为创建的点设置位置控制器和旋转控制器
        posPoint.pos.controller = positionConstraint
        posPoint.rotation.controller = orientationConstraint

        -- 获取位置约束和旋转约束的接口
        positionConstraintInterface = positionConstraint.constraints
        orientationConstraintInterface = orientationConstraint.constraints

        -- 添加目标到位置约束和旋转约束
        positionConstraintInterface.appendTarget bonesArray[2] 50.0
        orientationConstraintInterface.appendTarget bonesArray[1] 50.0
        orientationConstraintInterface.appendTarget bonesArray[2] 50.0


		-- 创建一个骨骼并调整其位置和旋转
        jointBone = BoneSys.createBone [0,0,0] [5,0,0] [0,0,1]
        jointBone.transform = posPoint.transform
        in coordsys local rotate jointBone (EulerAngles 0 0 90)

        -- 添加链接约束到骨骼
        linkConstraint = Link_Constraint ()
        jointBone.Transform.controller = linkConstraint
        linkConstraint.key_mode = 0
        linkConstraint.addTarget expPoint 0
        jointBone.parent = bonesArray[1]



		upperPoint = point cross:on box:on size:5 transform:upperBone.transform

		linkConstraint = Link_Constraint ()
		upperPoint.Transform.controller = linkConstraint
		linkConstraint.key_mode = 0
		linkConstraint.addTarget bonesArray[1] 0

		endPoint = point cross:on box:on size:5  transform:endBone.transform

		linkConstraint = Link_Constraint ()
		endPoint.Transform.controller = linkConstraint
		linkConstraint.key_mode = 0
		linkConstraint.addTarget bonesArray[3] 0


		expPoint.pos.controller.Y_Position.controller = float_expression()

		distanceValue = distance upperPoint endPoint

		expPoint.pos.controller.Y_Position.controller.AddScalarConstant "dis" distanceValue
		expPoint.pos.controller.Y_Position.controller.AddVectorNode "a" upperPoint
		expPoint.pos.controller.Y_Position.controller.AddVectorNode "b" endPoint
		expPoint.pos.controller.Y_Position.controller.setExpression "if(length(a-b)>9,dis/length(a-b)-1,dis/9-1)"

		if classof bonesArray[1] == BoneGeometry then
			jointBone.boneEnable= false
	),


    -- 控制腿部的骨骼结构
    fn setupLegControlSystem upperLegBone lowerLegBone legControlBone =
    (
        controlPoint = point cross:on box:on size:20
        controlPoint.transform = lowerLegBone.transform

        -- 创建一个控制矩形，用于腿部的动画控制
        controlRect = Rectangle length:25 width:15 cornerRadius:3 render_displayRenderMesh:on
        controlRect.transform = lowerLegBone.transform
        controlRect.parent = controlPoint

        -- 为控制点添加链接约束
        linkConstraint = Link_Constraint ()
        controlPoint.Transform.controller = linkConstraint
        linkConstraint.key_mode = 0
        linkConstraint.addTarget legControlBone 0

        -- 为上腿骨添加 LookAt 约束，以控制其朝向
        lookAtConstraint = LookAt_Constraint ()
        upperLegBone.rotation.controller = lookAtConstraint
        rotationConstraintInterface = lookAtConstraint.constraints
        rotationConstraintInterface.appendTarget controlRect 50.0
        lookAtConstraint.viewline_length_abs = off
        lookAtConstraint.upnode_world = off
        lookAtConstraint.pickUpNode = controlRect

        lowerLegBone.parent = upperLegBone
    ),

    -- 根据脊椎骨骼创建控制器
    fn createSpineControlSystem spineBone =
    (
        hpParent = point box:off cross:on size:10 wirecolor:red transform:spineBone.transform
        hpParent.name = replace spineBone.name 1 2 "HpPar"

        hpControl = point box:on cross:off size:10 wirecolor:red transform:spineBone.transform
        hpControl.name = replace spineBone.name 1 2 "HP"

        controlCircle = circle radius:20 wirecolor:yellow transform:spineBone.transform
        controlCircle.name = replace spineBone.name 1 2 "CON"
        convertToSplineShape controlCircle
        hpControl.parent = hpParent
        controlCircle.parent = hpControl

        -- 设置位置控制器
        controlCircle.Position.controller = position_list()
        controlCircle.Position.controller.Available.controller = Position_XYZ()
        controlCircle.Position.controller[1].controller = Bezier_Position()
        listctrl.setname controlCircle.Position.controller 1 "Frozen Position"
        listctrl.setname controlCircle.Position.controller 2 "Zero Pos XYZ"
        controlCircle.position.controller.SetActive 2

        -- 设置旋转控制器
        controlCircle.rotation.controller = Rotation_list()
        controlCircle.rotation.controller.Available.controller = Euler_XYZ()
        listctrl.setname controlCircle.rotation.controller 1 "Frozen Rotation"
        listctrl.setname controlCircle.rotation.controller 2 "Zero Euler XYZ"
        controlCircle.rotation.controller.SetActive 2

        -- 设置缩放控制器
        controlCircle.Scale.controller = ScaleXYZ()
    ),

    -- 根据脊椎骨骼和肌肉骨骼调整骨骼的伸缩
    fn adjustSpineFlexibility upperSpineBone lowerSpineBone muscleBone =
    (
        if (classof muscleBone == BoneGeometry) then
        (
            muscleBone.parent = undefined

            -- 添加位置约束和旋转约束
            positionConstraint = Position_Constraint()
            lookAtConstraint = LookAt_Constraint()

            muscleBone.pos.controller = positionConstraint
            muscleBone.scale.controller = ScaleXYZ()
            muscleBone.rotation.controller = lookAtConstraint

            -- 设置缩放控制器
            muscleBone.scale.controller.X_Scale.controller = float_expression()
            muscleBone.scale.controller.Y_Scale.controller = float_expression()
            muscleBone.scale.controller.Z_Scale.controller = float_expression()
            distanceValue = distance upperSpineBone lowerSpineBone

            muscleBone.scale.controller.X_Scale.controller.AddScalarConstant "dis" distanceValue
            muscleBone.scale.controller.X_Scale.controller.AddVectorNode "a" upperSpineBone
            muscleBone.scale.controller.X_Scale.controller.AddVectorNode "b" lowerSpineBone
            muscleBone.scale.controller.X_Scale.controller.setExpression "length(a-b)/dis"
            muscleBone.scale.controller.Y_Scale.controller.AddScalarTarget "conScale_Y" upperSpineBone[3][3][2].controller
            muscleBone.scale.controller.Y_Scale.controller.setExpression "conScale_Y"
            muscleBone.scale.controller.Z_Scale.controller.AddScalarTarget "conScale_Z" upperSpineBone[3][3][3].controller
            muscleBone.scale.controller.Z_Scale.controller.setExpression "conScale_Z"

            positionConstraintInterface = positionConstraint.constraints
            rotationConstraintInterface = lookAtConstraint.constraints

            positionConstraintInterface.appendTarget upperSpineBone 50.0
            rotationConstraintInterface.appendTarget lowerSpineBone 50.0

            lookAtConstraint.viewline_length_abs = off
            lookAtConstraint.upnode_world = off

            if findString upperSpineBone.name "head" == undefined then
                lookAtConstraint.pickUpNode = upperSpineBone
            else
                lookAtConstraint.pickUpNode = lowerSpineBone
        )
        else if (classof muscleBone == point) then
        (
            muscleBone.position.controller = position_expression()
            muscleBone.position.controller.AddVectorTarget "a" upperSpineBone[3][1][2].controller
            muscleBone.position.controller.AddVectorTarget "b" lowerSpineBone[3][1][2].controller
            muscleBone.position.controller.setExpression "(a+b)*0.5"
        )
    ),
	fn BipedScaleOn = --bip骨骼缩放
	(
		bipedobj = for obj in selection where classof obj == Biped_Object and findString obj.name "Footsteps" == undefined  collect obj
		for i = 1 to bipedobj.count do
		(
			if bipedobj[i].transform.controller.Biped_SubAnim.controller.BipScaleList[1].name == "Available" then
			bipedobj[i].transform.controller.Biped_SubAnim.controller.BipScaleList.controller.Available.controller = ScaleXYZ ()
		)
		$bip001.transform.controller.enableSubAnims = on
	),

	fn BipedScaleOff = --bip骨骼缩放
	(
		bipedobj = for obj in selection where classof obj == Biped_Object and findString obj.name "Footsteps" == undefined  collect obj
		for i = 1 to bipedobj.count do
		(
			if bipedobj[i].transform.controller.Biped_SubAnim.controller.BipScaleList[1].name == "Available" then
			bipedobj[i].transform.controller.Biped_SubAnim.controller.BipScaleList.controller.Available.controller = ScaleXYZ ()
		)

		$bip001.transform.controller.enableSubAnims = off

	),
	fn BipedEulerQuarter = --切换欧拉曲线和四元数曲线
	(
		bipedobj = for obj in objects where classof obj == Biped_Object and findString obj.name "Footsteps" == undefined  collect obj

		for i = 1 to bipedobj.count do
		(
			if (biped.getEulerActive bipedobj[i]) then biped.setQuaternionActive bipedobj[i]
			else (biped.setEulerActive  bipedobj[i] #xyz)
		)
	),
	fn boneScale = -- bone骨骼匹配
    (
        bipedobj = for obj in selection where classof obj == Biped_Object and findString obj.name "Footsteps" == undefined and obj.name != "Bip001" collect obj

        for i = 1 to bipedobj.count do
        (
            PosStart = bipedobj[i].transform.pos
            PosEnd = if bipedobj[i].children.count != 0 then bipedobj[i].children[1].transform.pos else [PosStart.x + 5, PosStart.y, PosStart.z]
            bn = boneSys.createBone PosStart PosEnd [0, 0, 1]
            bn.transform = bipedobj[i].transform
            bn.Transform.controller = Link_Constraint()
            bn.transform.controller.addTarget bipedobj[i] 0
            bn.name = replace bipedobj[i].name 1 7 "B_"
        )
    )

)
