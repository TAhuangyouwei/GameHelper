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


struct CustomIKHISolver
(
    -- 成员变量
    boneNodes,
    controlPoints,
    ikChains,
    dummies,

    -- 创建IK链
    fn createIKChains boneNodes =
    (
        local ikChains = #(undefined, undefined)
        local count = boneNodes.count
        case count of 
        (
            3: ikChains[1] = IKSys.ikChain boneNodes[1] boneNodes[count] "IKHISolver"
            5: 
            (
                ikChains[1] = IKSys.ikChain boneNodes[1] boneNodes[3] "IKHISolver"
                ikChains[2] = IKSys.ikChain boneNodes[3] boneNodes[count] "IKHISolver"
            )
        )
        ikChains
    ),

    -- 创建控制点
    fn createControlPoints boneNodes =
    (
        local controlPoints = #()
        for i = 1 to boneNodes.count do 
        (
            local controlPoint = point box:off cross:on name:("IK" + boneNodes[i].name)
            controlPoint.transform = boneNodes[i].transform 
            append controlPoints controlPoint
        )
        for i = 1 to controlPoints.count-1 do 
        (
            controlPoints[i+1].parent = controlPoints[i]
        )
        controlPoints
    ),

    -- 创建dummy对象并设置约束
    fn createDummiesAndSetConstraints boneNodes controlPoints =
    (
        local baseDummy  = dummy pos:boneNodes[1].pos boxsize:[10,10,10]
        local lookAtDummy = dummy pos:boneNodes[1].pos boxsize:[5,5,5]
        local controlDummy = dummy pos:boneNodes[boneNodes.count].pos boxsize:[15,15,15]
        
        lookAtDummy.rotation.controller = LookAt_Constraint()
        lookAtDummy.rotation.controller.appendTarget controlDummy 50
        lookAtDummy.rotation.controller.viewline_length_abs = off
        lookAtDummy.rotation.controller.lookat_vector_length = 0
        lookAtDummy.rotation.controller.upnode_world = off
        lookAtDummy.rotation.controller.pickUpNode  = controlDummy
        local mainIKControlPoint = IKSys.ikChain controlPoints[1] controlPoints[controlPoints.count] "IKHISolver"
        mainIKControlPoint.parent = controlDummy 
        lookAtDummy.parent = baseDummy
        #(baseDummy, lookAtDummy, controlDummy, mainIKControlPoint)
    ),

    -- 设置IK链的父子关系和目标
    fn setupIKChainParentsAndTargets boneNodes ikChains controlPoints dummies =
    (
        local baseDummy = dummies[1]
        local lookAtDummy = dummies[2]
        local controlDummy = dummies[3]
        local mainIKControlPoint = dummies[4]
        
        if boneNodes.count == 5 and ikChains[2] != undefined and ikChains[1] != undefined then
        (
            local primaryIKChain = ikChains[1]
            local secondaryIKChain = ikChains[2]
            
            secondaryIKChain.parent = mainIKControlPoint
            primaryIKChain.parent = controlPoints[3]
            
            local primaryIKTarget = point box:on cross:off pos:[boneNodes[2].pos.x, boneNodes[2].pos.y, boneNodes[2].pos.z-30]
            local secondaryIKTarget = point box:on cross:off pos:[boneNodes[4].pos.x, boneNodes[4].pos.y, boneNodes[4].pos.z+30]
            
            primaryIKTarget.parent = lookAtDummy
            secondaryIKTarget.parent = lookAtDummy
            
            primaryIKChain.transform.controller.VHTarget = primaryIKTarget
            secondaryIKChain.transform.controller.VHTarget = secondaryIKTarget
            mainIKControlPoint.transform.controller.VHTarget = secondaryIKTarget
        )
        else if boneNodes.count == 3 and ikChains[1] != undefined then
        (
            local primaryIKChain = ikChains[1]
            primaryIKChain.parent = controlPoints[3]
            local primaryIKTarget = point box:on cross:off pos:[boneNodes[2].pos.x, boneNodes[2].pos.y, boneNodes[2].pos.z+30]
            primaryIKTarget.parent = lookAtDummy
            primaryIKChain.transform.controller.VHTarget = primaryIKTarget
            mainIKControlPoint.transform.controller.VHTarget = primaryIKTarget
        )
    ),

    -- 主函数，用于创建IK解算器
    fn create boneNodesParam:undefined =
    (
        boneNodes = boneNodesParam
        if boneNodes == undefined do
            boneNodes = selection as array

        if boneNodes == undefined or boneNodes.count < 3 then
            return false

        ikChains = createIKChains boneNodes
        controlPoints = createControlPoints boneNodes
        dummies = createDummiesAndSetConstraints boneNodes controlPoints
        setupIKChainParentsAndTargets boneNodes ikChains controlPoints dummies
        true
    )
)



struct MaterialUtilities
(
    -- 重置材质球的方法
    fn resetMeditMaterials =
    (
        renderers.current = Default_Scanline_Renderer()
        for i = 1 to 24 do
        (
            meditMaterials[i] = standard()
            local paddedNumber = if i < 10 then "0" + (i as string) else (i as string)
            meditMaterials[i].name = paddedNumber + "-standard"
        )
    ),
	fn clearMaterials = --清除材质
	(
		if selection.count != 0 then 
			selection.mat = undefined
		else 
			objects.mat = undefined
	)

    -- 这里可以添加更多与材质相关的方法
)



struct ModelUtilities
(
    -- 功能：确保env文件存在
    fn ensureEnvFileExists =
    (
        local envPath = getdir #userscripts + "\\temp.env"
        if not doesFileExist envPath do
        (
            local file = createFile envPath
            close file
        )
        return envPath
    ),

	-- 功能：处理单个模型
	fn processModel obj applyCenterPivot envPath =
	(
		-- 提取的共用代码部分
		fn createTempModelFrom obj applyCenterPivot tempName =
		(
			for j = 1 to obj.modifiers.count do collapseStack obj
			local tempModel = convertToPoly(box())
			tempModel.EditablePoly.attach obj tempModel
			tempModel.EditablePoly.SetSelection #Face #{1..6}
			tempModel.EditablePoly.delete #Face
			tempModel.name = tempName
			if applyCenterPivot then CenterPivot tempModel else tempModel.pivot = [0,0,0]
			return tempModel
		)

		-- 处理逻辑
		local tempName = copy obj.name 
		if obj.modifiers[#skin] == undefined then 
		(
			-- 当没有Skin修改器时的处理
			createTempModelFrom obj applyCenterPivot tempName
		)
		else
		(
			-- 当有Skin修改器时的处理
			sliderTime = 0
			local boneArr = skinOps.GetBoneNodes obj.skin
			skinOps.SaveEnvelope obj.modifiers[#Skin] envPath
			local tempModel = createTempModelFrom obj applyCenterPivot tempName
			addModifier tempModel (skin())
			for k = 1 to boneArr.count do
			(
				local addBoneMethod = if k == boneArr.count then -1 else 0
				skinOps.addbone tempModel.modifiers[#Skin] boneArr[k] addBoneMethod
			)
			skinOps.loadEnvelope tempModel.modifiers[#Skin] envPath
			tempModel.modifiers[#Skin].bone_Limit = 4
		)
	),

    -- 主函数：重置模型材质
    fn ResetMaterialsOfModel applyCenterPivot:false =
    (
        local envPath = ensureEnvFileExists()
        local targetModel = if selection.count == 0 then objects else selection

        for obj in targetModel where classof obj.baseobject == Editable_Poly and obj.faces.count != 0 do 
        (
            processModel obj applyCenterPivot envPath
        )
    ),
	
	
	fn pointPath =
	(
		obj = (for obj in geometry where (obj.modifiers[#Edit_Mesh] != undefined or classof obj == Editable_mesh) collect obj )[1]

		if obj != undefined then 
		(
			num = (getVertSelection obj as array)[1]
			pt = point axistripod:on box:on cross:off color:blue name:"path_point"
			animate on 
			for i = animationRange.start to animationRange.end do 
			(
				at time i pt.dir = getnormal obj num
				at time i pt.pos = getVert obj num
			)
			subobjectLevel = 0
			select pt 
		)
		else 
		(
			result = queryBox "点轨迹只对mesh物体有效，是否给当前物体增加一个edit_mesh修改器?"
			
			if result then
			(
				if selection.count != 0 do
				(
					max modify mode
					obj = selection[1]
					addModifier obj (Edit_Mesh())
					subObjectLevel = 1
					pointPath() -- 递归调用
				)
			)
		)
	)
)







struct ObjectProcessing
(
    -- 定义一个旋转坐标轴的函数
	fn RotatePivotOnly obj rotation =
	(
		local rotValInv = inverse (rotation as quat)
		animate off in coordsys local obj.rotation *= rotValInv
		obj.objectoffsetpos *= rotValInv
		obj.objectoffsetrot *= rotValInv
	),
	-- 生成或验证temp.env文件的存在
	fn EnsureEnvFileExists =
	(
		local envPath = (getDir #userscripts) + "\\temp.env"
		if not doesFileExist envPath do
		(
			local file = createFile envPath
			close file
		)
		return envPath
	),
	-- 主函数处理选择的对象
	fn ProcessSelectedObjects =
	(
		local envPath = EnsureEnvFileExists()

		for obj in selection do 
		(
			if obj.modifiers[#Skin] != undefined then 
			(
				-- 保存和加载Skin修改器的包络，并转换对象
				sliderTime = 0
				skinOps.SaveEnvelope obj.modifiers[#Skin] envPath						
				local boneArr = skinOps.GetBoneNodes obj.skin
				convertToPoly obj
				if obj.rotation == (quat 0 0 0 1) then RotatePivotOnly obj (EulerAngles 90 0 0)
				
				-- 重新添加Skin修改器并设置骨骼
				addModifier obj (skin())
				for i = 1 to boneArr.count do
				(
					if i == boneArr.count then 
						skinOps.addbone obj.modifiers[#Skin] boneArr[i] -1
					else 
						skinOps.addbone obj.modifiers[#Skin] boneArr[i] 0
				)
				skinOps.loadEnvelope obj.modifiers[#Skin] envPath
				obj.modifiers[#Skin].bone_Limit = 4
			)
			else
			(
				-- 处理没有Skin修改器的对象
				sliderTime = 0
				convertToPoly obj					
				if obj.rotation == (quat 0 0 0 1) then RotatePivotOnly obj (EulerAngles 90 0 0)
			)
		)

		gw.updateScreen() 
	),
	
	fn getObjLength =
	(
		if selection.count != 0 then 
		(
			stratPoint = selection[1].transform.pos
			if selection[1].children[1] != undefined then 
				endPoint = selection[1].children[1].transform.pos
			
			objlength = distance stratPoint endPoint
			return objlength
		)
	)
)



struct ViewportUtilities
(
    -- 程序视图设置函数
    fn ProgrammeView =
    (
        viewport.ResetAllViews()
        viewport.setLayout #layout_2v 
        viewport.activeViewportEx  1
        actionMan.executeAction 0 "40410"  -- Views: Extended Views 7
    ),

    -- 动画视图设置函数
    fn AnimView =
    (
        viewport.ResetAllViews()
        max tool maximize
    ),
	
	-- 定义一个方法来切换displayColor.shaded的状态
    fn toggleShaded displayColor =
    (
        if (displayColor.shaded == #material) then
        (
            displayColor.shaded = #object
            return #object -- 返回更新后的状态
        )
        else
        (
            displayColor.shaded = #material
            return #material -- 返回更新后的状态
        )
    )

    
)



struct SceneUtilities
(
    -- 选择场景中UV数量大于2的物体
    fn mapChannelNum =
    (
        mapChannelNumTemp = #()
        for obj in objects where classof obj.baseobject == Editable_Poly do
        (
            num = polyop.getNumMaps obj
            if num > 2 then 
            (
                append mapChannelNumTemp obj 
            )
        )
        
        if mapChannelNumTemp.count != 0 then 
        (
            clearSelection()
            select mapChannelNumTemp
            messageBox ("已选中场景中模型UV大于1的模型，共有" + (mapChannelNumTemp.count as string) + "个")
        )
    ),

    -- 单位检查
    fn unitCheck =
    (
        if units.SystemScale != 1.0 or units.SystemType != #Centimeters then
        (
            cd = queryBox "单位错误，是否修复"
            if cd == true then 
            (
                units.DisplayType = #Metric
                units.MetricType = #meters
                units.SystemScale = 1.0
                units.SystemType = #Centimeters
            )
        )
    ),

    -- 缩放检查
	fn scaleCheck =
	(
		tempScale = for obj in objects where classof obj.baseobject == Editable_Poly and isProperty obj #scale and (abs(obj.scale.x - 1) > e^-5 or abs(obj.scale.y - 1) > e^-5 or abs(obj.scale.z - 1) > e^-5) collect obj
		if tempScale.count != 0 then 
		(
			cd = queryBox ("缩放有问题的模型数量有" + (tempScale.count as string) + "个，是否选中缩放有问题的模型")
			if cd == true then selectmore tempScale
		)
	),
		
	
	--检查多余的修改器
	fn getModifiers =
	(
		objs = for obj in geometry where (obj.modifiers.count > 1) or (obj.modifiers.count > 0 and obj.modifiers[#skin] == undefined) collect obj
		if objs.count != 0 then 
		(
			cd = queryBox ("有多余修改器的物体数量有" + (objs.count as string) + "个，是否选中有问题的模型")
			if cd == true then selectmore objs
		)
	),
	
	--模型命名检查
	
	fn nameCheck =
	(
		-- 收集所有的几何体对象，这里我们关注的是可编辑多边形
		nameObjs = for obj in geometry where classof obj.baseobject == Editable_Poly collect obj
		
		fileNumber = (filterString (getFilenameFile(maxFileName)) "_")
		
		-- 遍历这些对象
		for obj in nameObjs do
		(
			local errorFound = false
			
			if (filterString obj.name "_")[1] == fileNumber[1] and (filterString obj.name "_")[2] == fileNumber[2] and (filterString obj.name "_")[3] == fileNumber[3] and errorFound == false then 
			( 
				continue
			)
			else 
			(
				-- 如果所有的条件都不符合，则说明发现了错误
				messageBox (obj.name + " 命名错误，请检查！")
				errorFound = true
			)
			-- 检查模型是否包含指定的后缀
			if errorFound == false then 
			(
				if (findString obj.name "_body" != undefined) then 
				(
					-- 匹配到正确的名字后缀
					continue
				)
				else if (findString obj.name "_hair" != undefined) then 
				(
					continue
				)
				else if (findString obj.name "_head" != undefined) then 
				(
					continue
				)
				
				else if (findString obj.name "_eyeShadows" != undefined and findString (getFilenameFile(maxFileName)) "_lod" == undefined) then 
				(
					continue
				)
				else
				(
					-- 如果所有的条件都不符合，则说明发现了错误
					messageBox (obj.name + " 命名错误，请检查！")
					errorFound = true
				)
				
			)

		)
	),

    -- 检查模型轴向是否Y轴向上
	fn objAxis =
	(
		tempAxis = #()          
		for obj in objects where classof obj.baseobject == Editable_Poly do 
		(
			if isProperty obj #rotation and obj.rotation != (quat 0.707107 0 0 0.707107) then 
			(
				append tempAxis obj 
			)
			else if isProperty obj #position then 
			(
				local posCloseToZero = (abs(obj.position.x) < 0.0001 and abs(obj.position.y) < 0.0001 and abs(obj.position.z) < 0.0001)
				if not posCloseToZero then 
				(
					append tempAxis obj 
				)
			)
		)

		if tempAxis.count != 0 then 
		(
			cd = queryBox ("轴向或位置有问题的模型数量有" + (tempAxis.count as string) + "个，是否选中有问题的模型")
			if cd == true then 
			(
				selectmore tempAxis
			)               
		)
	),
	fn CreateFloor state width:600 height:600 depth:-3 = --添加参数
    (
        if state == on then 
        (
            local layer = LayerManager.getLayerFromName "floor"
            if layer == undefined then 
            (
                layer = LayerManager.newLayerFromName "floor"
            )

            local animFloor = box length:width width:height height:depth name:"Floor" 
            animFloor.mat = standard()
            layer.addnodes animFloor
        )
        else if $Floor != undefined then 
        (
            delete $Floor
            LayerManager.deleteLayerByName "floor"
        )
    ),
	
	fn DeleteParticalView =  --删除粒子视图
	(
		delete $'particle view*'
		
		delete $'粒子视图*'	
	),


	fn DeletePoints =
	(
		objs = for obj in objects where( (classof obj == Point) and ((findString obj.name "　" !=undefined ) or (findString obj.name "×t×ü" !=undefined ) or (findString obj.name "??×y×?" !=undefined ))) collect obj 
		delete objs
	),


	fn DeleteDayReca =
	(
		z=1

		while z !=undefined do

		(

		x = rootscene

		z = custattributes.getdef x 1

		custAttributes.delete x z

		)

		xx = rootscene.custAttributes
		for i =1 to xx.count do deleteItem xx 1
	),

	fn CleanScene =
	(
		DeleteParticalView()
		DeletePoints()
		DeleteDayReca()
	)

)



struct LayerUtilities
(
	
	fn getAllChildren node collectedNodes =
	(
		if node != undefined then
		(
			-- 检查节点是否是dummy并且名字中包含'nub'
			if not ((classof node == Dummy and findString node.name "nub" != undefined) or (classof node == BoneGeometry and findString node.name "nub" != undefined) ) then
			(
				append collectedNodes node
				for child in node.children do
				(
					getAllChildren child collectedNodes
				)
			)
		)
	),

	fn createSkinBonesSet =
	(
		local bipedRoot = getNodeByName "bip001"
		if bipedRoot != undefined then
		(
			local nodes = #()
			getAllChildren bipedRoot nodes
			selectionSets["skinBones"] = nodes
		)
		else
		(
			format "警告: 未找到名为 'bip001' 的节点。\n"
		)
	),

    fn addToLayer layerName objectsArray =
    (
        local layer = LayerManager.getLayerFromName layerName
        if layer == undefined then
            layer = LayerManager.newLayerFromName layerName
        layer.addnodes objectsArray
    ),
	
	
	-- 定义用于检查对象条件的函数
	fn isPoint obj = (classof obj == point and findstring obj.name "LocationLOC" == undefined) , --point物体
	fn isDummy obj = (classof obj == dummy and findstring obj.name "hp_" != undefined ) or (classof obj == dummy  and findstring obj.name "Dummy" != undefined ) , --point物体
	fn isAC_Dummy obj = (classof obj == dummy and findstring obj.name "hp_" == undefined and findstring obj.name "Dummy" == undefined  and  findstring obj.name "Nub" == undefined  ) , --AC point物体
	fn isIKChain obj = (classof obj == IK_Chain_Object) , --IK控制器
	fn isBoneGeometryWithoutTwist obj = (classof obj == BoneGeometry and findstring obj.name "Twist" == undefined and findString obj.name "Nub" == undefined ),  --bone骨骼


	fn isBipedObject obj = (classof obj == Biped_Object and findstring obj.name "Twist" == undefined ),  --是否为biped物体
	fn hasSkinModifier obj = (obj.modifiers[skin] != undefined),  --判断是有蒙皮修改器
	fn isBoneNub obj = (obj.children.count == 0 and classof obj == BoneGeometry and findString obj.name "Nub" != undefined and obj.parent != undefined and classOf obj.parent == BoneGeometry),  --nub物体
	fn isTwistBone obj = (findstring obj.name "Twist" != undefined),

	--animcraft专用
	fn isLOC obj = (classof obj == NURBSCurveshape and findstring obj.name "_LOC" != undefined ),
	fn isLocationCV obj = (classof obj == SplineShape and findstring obj.name "_LocationCV" != undefined ),

	--SplineShapes   把方法转换成直接获取

	fn isControllers  obj = ( (classof obj == SplineShape  and findstring obj.name "_Ctrl" != undefined ) or (classof obj == NURBSCurveshape and findstring obj.name "_Ctrl" != undefined)),
	fn isLOC_Points  obj = (classof obj == Point and findstring obj.name "LocationLOC" != undefined ),
		
		
	-- 定义一个通用的收集函数
	fn collectObjectsByCondition conditionFn =
	(
		collectedObjects = #()
		for obj in objects do
		(
			if (conditionFn obj) do
			(
				append collectedObjects obj
			)
		)
		collectedObjects
	),

	fn DeleteEmptyLayers =  --删除空的层
	(
		_defaultlayer = layerManager.getLayer 0
		_defaultlayer.current = true
		
		try
		(	
			_layersNum = layerManager.count - 1  --层的序号是从0开始计数的，所以减1,负号和1一定要分开，要不然报错
			_layers = for i = 1 to _layersNum collect i  --将每个层的引用存储在"_layers"列表中
			_revlayers = #()
			for i in _layers.count to 1 by -1 do append _revlayers _layers[i]   --遍历了"_layers"列表中所有的层，并将每个层的顺序倒序存储在"_revlayers"列表中。

			for j in _revlayers do
			(
				_getlayer = layerManager.getlayer j
				LayerManager.deleteLayerByName _getlayer.name
			)		
		)
		catch()
	),

	fn addObjectsToLayer =
	(
		-- 确保 addToLayer 和 createSkinBonesSet 函数在这里是可用的

		ptArray = collectObjectsByCondition isPoint
		dummyArray = collectObjectsByCondition isDummy 
		AC_DummyArray = collectObjectsByCondition isAC_Dummy
		
		IKs = collectObjectsByCondition isIKChain
		bnArray = collectObjectsByCondition isBoneGeometryWithoutTwist
		
		bipArray = collectObjectsByCondition isBipedObject
		skinArray = collectObjectsByCondition hasSkinModifier
		boneNubArray = collectObjectsByCondition isBoneNub
		twistBones = collectObjectsByCondition isTwistBone
		
		AC_LOCArray = collectObjectsByCondition isLOC
		AC_LocationCVArray = collectObjectsByCondition isLocationCV
		
		
		AC_ConArray = collectObjectsByCondition isControllers
		AC_LOC_PointArray = collectObjectsByCondition isLOC_Points
		
		
		--收集  SplineShapes	
		spNodes = $Animcraft_Master_GRP.../*   --*/取消显示影响
		AC_SplineShapeArray = spNodes
		
		


		if ptArray.count != 0 then addToLayer "Points" ptArray
		if dummyArray.count != 0 then addToLayer "Dummys" dummyArray
		if AC_DummyArray.count != 0 then addToLayer "AC_Dummys" AC_DummyArray
			
		if IKs.count != 0 then addToLayer "IK" IKs
		if bnArray.count != 0 then addToLayer "Bones" bnArray
			
		if bipArray.count != 0 then addToLayer "Bipeds" bipArray
		if skinArray.count != 0 then addToLayer "AM_Models" skinArray
		if boneNubArray.count != 0 then addToLayer "0" boneNubArray
		if twistBones.count != 0 then addToLayer "BN_Twist" twistBones
			
		if AC_LOCArray.count != 0 then addToLayer "AC_LOCs" AC_LOCArray
		if AC_LocationCVArray.count != 0 then addToLayer "AC_LocationCVs(可删除)" AC_LocationCVArray

		if AC_conArray.count != 0 then addToLayer "AC_Controllers" AC_conArray
		if AC_LOC_PointArray.count != 0 then addToLayer "AC_LOC_Points(可删除)" AC_LOC_PointArray
			
		--最后一个步骤，因为这是通过父子集选择的，没有通过各种判定
		if AC_SplineShapeArray.count != 0 then addToLayer "AC_SplineShapes" AC_SplineShapeArray
			
		names = #("0","AC_Controllers","AC_Dummys","AC_LOC_Points(可删除)","AC_LocationCVs(可删除)","AC_LOCs","AC_SplineShapes","BN_Twist","Dummys","IK","Points")
			
		for layerName in names do 
		(
			layer = LayerManager.getLayerFromName layerName
			if layer != undefined then layer.ishidden = on 
		)

		createSkinBonesSet()
		DeleteEmptyLayers()
	)
	


)




global store_amb, store_tint

if store_amb == undefined do store_amb = color 0 0 0
if store_tint == undefined do store_tint = color 255 255 255
	

struct InterfaceUtilities
(
    tempimpl,
	
	
	Fn SetDefaultLanguageToChinese = --适用于多数版本
	(
		if (MaxVersion() )[1] >= 15000 do
		if "2052" != GetINISetting (GetMAXIniFile()) "File Language Options" "LanguageToUseForFileIO" do 
		(
			DialogMonitorOPS.UnRegisterNotification id:#SetDefaultLanguageToChinese
			Fn DialogMonitorCallBackSetDefaultLanguageToChinese = 
			(
				currentHandle = DialogMonitorOPS.GetWindowHandle()
				if "Preference Settings" == UIAccessor.GetWindowText currentHandle do
				(
					languageNames = #("Chinese","English","German","French","japanese","Korean","Current")
					childrens = Windows.getChildrenHWND currentHandle
					
					languageLabel = undefined 
					for tempControl in childrens where tempControl[5] == "Default Language:" do 
					(
						languageLabel = tempControl
					)
					if languageLabel != undefined do
					for tempControl in childrens where 
					(
						tempControl[2]==languageLabel[2] and \
						tempControl[3]==languageLabel[3]  and \
						"ComboBox" == tempControl[4] and \
						FindItem languageNames tempControl[5] != 0
					)
					do
					(
						UIAccessor.SendMessage tempControl[1] 0x014E 6 0
					)
					UIAccessor.SendMessageID currentHandle #IDOK
				)
				true
			)
			DialogMonitorOPS.RegisterNotification DialogMonitorCallBackSetDefaultLanguageToChinese id:#SetDefaultLanguageToChinese
			DialogMonitorOPS.Enabled = true
			DialogMonitorOPS.ShowNotification()
			max file preferences
			DialogMonitorOPS.UnRegisterNotification id:#SetDefaultLanguageToChinese
			DialogMonitorOPS.Enabled = false
		)
	),
	
	
	
-- 2010版本
-- (DotNetClass "System.Windows.Forms.Application").CurrentCulture = dotnetObject "System.Globalization.CultureInfo" "zh-cn"  
	fn Silhouette_Viewer =
	(
		local inst = InterfaceUtilities()  -- 创建结构体实例

		-- 检查NitrousGraphicsManager是否返回有效对象
		local viewportSetting = NitrousGraphicsManager.GetActiveViewportSetting()
		if viewportSetting != undefined then 
		(
			-- 只有当viewportSetting有效时才继续
			if inst.tempimpl == undefined do inst.tempimpl = viewportSetting.VisualStyleMode

			if store_amb == undefined then store_amb = color 0 0 0
			if store_tint == undefined then store_tint = color 255 255 255
			
			if (ambientColor == color 0 0 0) and (lightTintColor == color 0 0 0) then -- 关闭剪影
			(
				animButtonState = off
				hideByCategory.bones = off
				hideByCategory.helpers = off 
				
				impl = viewportSetting
				
				if impl != undefined then impl.VisualStyleMode = inst.tempimpl
					
				ambientColor = store_amb
				lightTintColor = store_tint
				redrawViews()
			) 
			else   -- 显示剪影
			(
				animButtonState = off
				hideByCategory.bones  = on
				hideByCategory.helpers = on 
					
				impl = viewportSetting
				inst.tempimpl = impl.VisualStyleMode
				if impl != undefined then impl.VisualStyleMode = #shaded
				
				store_amb = ambientColor
				store_tint = lightTintColor
				ambientColor = color 0 0 0
				lightTintColor = color 0 0 0
				redrawViews()
			)
		)
		else
		(
			-- 如果viewportSetting无效，可以在此处处理错误或返回
		)
	)



)



struct BoneUtilities
(
	fn RenameBoneNub = --重命名末端骨
	(
		ArrayNub = for bn in selection where bn.children.count ==0 and classof bn == BoneGeometry and bn.parent != undefined and classOf bn.parent == BoneGeometry and ((findString bn.name "Nub") == undefined)collect bn

		if ArrayNub.count == 0 then 
			messageBox "请选择需要改名的物体!"
		else 
		(
			for Nub in ArrayNub do Nub.name = Nub.name + "Nub"	
		)
	)

)






struct AnimationUtilities
(
    -- 处理相邻关键帧比较的函数
    fn processBipedKeys controller node tolerance = 
    (
        local count = numKeys controller
        for idx = 1 to count - 1 do 
        (
            local thisKey = biped.getkey controller idx
            local nextKey = biped.getkey controller (idx + 1)
            
            thisKeyTime = thisKey.time
            nextKeyTime = nextKey.time
            
            at time thisKeyTime thisKeyTrans = node.transform
            at time nextKeyTime nextKeyTrans = node.transform
            
            local matricesAreEqual = true
            for i = 1 to 4 do
            (
                for j = 1 to 3 do
                (
                    if abs(thisKeyTrans[i][j] - nextKeyTrans[i][j]) > tolerance then
                    (
                        matricesAreEqual = false
                        exit
                    )
                )
                if not matricesAreEqual do exit
            )
            
            if matricesAreEqual then
            (
                node.transform
                thisKey.continuity = 0
                nextKey.continuity = 0
            )
        )
    ),
	
	fn setTCBContinuityForBipedObjects bipedObjs continuityValue =
	(
		for bipedObj in bipedObjs do 
		(
			local count = numKeys bipedObj.controller

			-- 设置Biped骨骼的关键帧连续性
			if bipedObj.name != "Bip001" then 
			(
				local biped_ctrl = bipedObj.controller
				for idx = 1 to count do 
				(
					if isKeySelected biped_ctrl idx then 
					(
						local bipkey = biped.getkey biped_ctrl idx  
						bipkey.continuity = continuityValue
					)
				)
			)
			else 
			(
				-- 处理Bip001的特殊情况
				local controllers = #(bipedObj.controller.vertical.controller, bipedObj.controller.horizontal.controller, bipedObj.controller.turning.controller)
				for ctrl in controllers do 
				(
					for idx = 1 to numKeys ctrl do 
					(
						if isKeySelected ctrl idx then 
						(
							local bipkey = biped.getkey ctrl idx  
							bipkey.continuity = continuityValue
						)
					)
				)
			)
		)
	),
	
	fn processSingleBipedObject bipedObj tolerance =
	(
		if bipedObj.name != "Bip001" then 
		(
			AnimationUtilities.processBipedKeys bipedObj.controller bipedObj tolerance
		)
		else
		(
			AnimationUtilities.processBipedKeys bipedObj.controller.vertical.controller bipedObj tolerance
			AnimationUtilities.processBipedKeys bipedObj.controller.horizontal.controller bipedObj tolerance
			AnimationUtilities.processBipedKeys bipedObj.controller.turning.controller bipedObj tolerance
		)
	)


)





struct BoneSkinUtilities
(
    -- 获取骨骼节点
    fn getBoneNodes skinObject = 
	(
		envPath =getdir #userscripts + "\\temp.env"
		skinOps.SaveEnvelope skinObject.modifiers[#Skin] envPath
		skinOps.GetBoneNodes skinObject.skin
    ),

    -- 保存骨骼名称到文件
    fn saveBoneNamesToFile boneObjs filePath = 
	(
        local outputFileStream = createFile filePath
        if outputFileStream != undefined then 
		(
            for bone in boneObjs do 
			(
                format "%\n" bone.name to:outputFileStream
            )
            close outputFileStream
        ) 
		else 
		(
            print "无法创建文件流"
        )
    ),

    -- 读取骨骼名称
    fn loadBoneNamesFromFile filePath = (
        local boneNames = #()
        local fileStream = openFile filePath
        if fileStream != undefined then (
            while not eof fileStream do (
                append boneNames (readLine fileStream)
            )
            close fileStream
        ) else (
            print "无法打开文件流"
        )
        boneNames
    ),

    -- 应用骨骼到模型
    fn applyBonesToModel boneNames model = 
	(
		envPath =getdir #userscripts + "\\temp.env"
        local boneObjs = for boneName in boneNames where (getNodeByName boneName) != undefined collect (getNodeByName boneName)
        for bone in boneObjs do (
			newBoneObjs = skinOps.GetBoneNodes model.skin
			if (findItem newBoneObjs bone ) == 0 then 
				skinOps.addBone model.skin bone 0
        )
		
		skinOps.loadEnvelope model.modifiers[#Skin] envPath
    )
)


struct RolloutUiUtilities
(
	fn widgetState = 
	(
		if (maxVersion())[8] <= 2021 then 
			return true
		else 
			return false 
	)
)


-- Base64编码的字符串
encodedString = @"/9j/4AAQSkZJRgABAQIARgBGAAD/2wBDAAYEBQYFBAYGBQYHBwYIChAKCgkJChQODwwQFxQYGBcUFhYaHSUfGhsjHBYWICwgIyYnKSopGR8tMC0oMCUoKSj/2wBDAQcHBwoIChMKChMoGhYaKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCj/wAARCAGQAZADASIAAhEBAxEB/90ABAAZ/8QAHwAAAQUBAQEBAQEAAAAAAAAAAAECAwQFBgcICQoL/8QAtRAAAgEDAwIEAwUFBAQAAAF9AQIDAAQRBRIhMUEGE1FhByJxFDKBkaEII0KxwRVS0fAkM2JyggkKFhcYGRolJicoKSo0NTY3ODk6Q0RFRkdISUpTVFVWV1hZWmNkZWZnaGlqc3R1dnd4eXqDhIWGh4iJipKTlJWWl5iZmqKjpKWmp6ipqrKztLW2t7i5usLDxMXGx8jJytLT1NXW19jZ2uHi4+Tl5ufo6erx8vP09fb3+Pn6/8QAHwEAAwEBAQEBAQEBAQAAAAAAAAECAwQFBgcICQoL/8QAtREAAgECBAQDBAcFBAQAAQJ3AAECAxEEBSExBhJBUQdhcRMiMoEIFEKRobHBCSMzUvAVYnLRChYkNOEl8RcYGRomJygpKjU2Nzg5OkNERUZHSElKU1RVVldYWVpjZGVmZ2hpanN0dXZ3eHl6goOEhYaHiImKkpOUlZaXmJmaoqOkpaanqKmqsrO0tba3uLm6wsPExcbHyMnK0tPU1dbX2Nna4uPk5ebn6Onq8vP09fb3+Pn6/9oADAMBAAIRAxEAPwD6oJxRmhqSgBc0ZpKKAFzRmkooAXNGaSigBc0ZpKKAFzRmkooAXNGaSigBc0ZpKKAFzRmkooAXNGaSigBc0ZpKKAFzRmkooAXNLTadQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQB//0PqhqSlakoAKKazBetM832p2AloqIS+op6sG6UgHUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAU6m06gAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigD/0fqhqjkbaPepGqvIcsaaAZ161DPdQwcSuAfTrUxOBXKTyGWZ3Y5JNWlcR00FxFOCYnDY61MDg8VzFhIYruMjucGumpNWAsK24Zp1QxHBxU1Qxnlnhv4iW9vHr9vrc+ozXVvqdzFE0WnzSqkan5V3IhXj65rP0fxXrOkeD/CvjDWL2e90aeyEeqpsBaJifknUAZ64Uj3Br0Xw14eTQ7PUoEuGm+23k14WK42GQ/d684rJfwJE3wvHgz7c/lC1Fr9q8sbsA5ztz/WgDmv7U8T2EXh/xHrN3LBbahqgS400quy2t5VKRKTjO4NtYn1bFZMfxB1i1h8Z313cb7We3kn0JAo+XZM1vgcckvsbn1r1bxhoMXibw3faRNK0C3KgLKgyY2DBlYe4YA/hXM3vwzsLqz8JWxupVi8PlcAJ/wAfKgoxVueAWRW78igDsNCgurbRbGHUZ2uL1IUWaVsZd8fMeOOuav0UUAFFFFABRRRQAUUUUAFFFFABRRRQAU6mV5+PEuo/8/K/98L/AIVtRoSq35ehjVrRpW5up6HmivmnxZ8eNW0bX7mxtoIJIbZ9rvIAC2PvY4r0vT/Gd1qFjBd2lyrwTIHRvLAyD+FVHDyk2kwnWUEm1uel0Vwml+Jr6TUII5nV45HCkbQOv0rus1nVpSpu0iqdVVFdC0UUVmaBRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFAH/9L6oaqz/eP1qy1Qyr3FNAUNSl8q0cj7x4Fc3XWOitjcAccisGXTrgyt5cRCZ4ywrRNCKKkhgR1zxXVW0nmwI/8AeGax7OwmS5RpYiUB/vCttFCLtUYHpSkxEkX36nqOFcDNPqGUFLXNSXWy0S6a5lF885RU3HbkPjZt6Dj8e9J9qKWttcm5lN9NME8vcSp+cBk29BgZ9+M0gOmpKztTuZotGnnj2eaFODG2QOcZyfas7zTGJIJ5ZhslAEUcxcyErkKHOCPU/wCFAHR0VhNBL/xL4pJ5vtchBdlmbaFXk8Zwey9O+aqW99c200blZpi0bmXD71dgwClQM4HPoP0oA6iiuWhu55lWHzpZ3N0ysCWh3LszgHGQAewpsdzMbf7TNIZUhiUsguWRgdzA8DhugAJ6496AOrornp/tBuriD7Uzf6QgG+Qx8GMnaCvTnFamjyiawRgCNrMhzIX5DEH5jyRxQBdooooAKKKKACiiigBK8TjksxwA2T23D/Cvba+YotQeGQPE21wcg+la0qnJcyqU1Uaudfq3gzS7u+juLqSOJposvFsDO69OD6evFWr+1s9NaONUIt9vyKGwF9qL3SZTe2V3F5VxLGVJ85iQBjnH865rxfq8lzq0kJARYTtAB6njJohJQm2jprU3KklPpsdLoc9mdZsgka5My4O/vmvZa+bPC8xbxLpYLf8ALyn8xX0pRVnzs56dNQR5lY+LrvTvH3jKzm0/W9TghuLYQizg81IQbdCR1GMkk1gaNr2sWnw80jxq9xe3MVjc3o1G0kfLS2xuZFBwTw8eFI9gRXq+l6Hb6brGsajC0hm1SSOWYMeAUjCDH4AVmR+CtPTwRd+FxJcfYLkTh33DePNkZ2wcY6ucVkaHIPJr2laPoPiTWL24Wa41VJb61EmYoYJ/3aRgdMJujP8AvZNc3/wluuDTPE7vey+br2yXQsN/qla4Nvhfw8uT/gRr2TxDoFpr3hq50S9Mn2W4iETMhwwxjBB9QQDWXceBNInm8MyMkg/4R/8A49AG4I2gfN6/dU/UUAdPaxeRbRRb2fYoXcxyWwOp96koooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKAP//T+qGpvXrTmpKAIXjI6c1HVqkp3Ar4PapEj7t+VSUtFwCiiikBXksraSXzZLeJpOPnKDPHvQ9lbPL5rW8Rl4O8oN3HTn8KsUUAMCIE2BVC+mOKhNjaGJYjbQGNTkIYxgH6VZooAjjhij2+XGibRtXaoGB6UkcEUTu8USIznLFVwW+tS0UARS28MqFJYo3RjuIZQQT60jWsDNGTDGTH9wlR8v09KmooAikgilV1liR1f7wZc5+tPRVRQqKFUDAAGAKdRQAUUUUAFFFFABRRRQAV8jtPzgV9cV8Y6fq1gNSgS9lkCD5yqLhiB9elF7aha+h6dftcadIUhuZEEUPmyY5xkYH6g1w9xdtPNJI7Es7FjzS+LPEZu9duX0q6b7HLCsRZDxIuMkH8SRWNHLxVTqObFGHKrHVeEJt3inSRn/l6j/8AQhX1RXyV4JZpfGGjIgLE3UfAHvX1rU3GZdxqUq3Kxw2zOPN8oksBn5c8c1XvNZkiTzI40CBNzbzyOSPX/Zq7daVbT3Ecpij3B97krktwR/h+VQ3WjrK2IZBDD5YjKAH1J7EetAC2WpSSJI00W7bjHkjfkH6GmW+sedYyzLFJlA5yUIX5c45/CnW2lywRSxrc4EhGWCnIA7Akn86ll04bJUt38qOSMxsmMjpgEelAFJNcYPbrIkX7zduIfGPSt2sZtGYMDDdMqg5wy7jk9ec1s0AFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFAH//U+qGpKVqSgAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACsD/AIQnwwZGkOg6aXYYLeQuSPyrfp1AHPr4L8NL93QtOH/bBaf/AMIf4d/6Aun/APfha3aKAMvT/D2j6dcCex0y0t5gMB44gGH41qUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFAH/9X6oakpWpKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKdTadQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQB//1vqhqSlaoLu5itLd5p22xoMk00ruyE2oq7JarTX9pC22W5hU+hYVw2q65d6lKY4S0cJOFjTqfr60tt4b1GdQxiWMH++2DXfHBKKvWlY8meZznJxw8ObzO6gvLe4OIJ43PorA1PXnV3oWo2a+Y0W5V53RnOP61d0PxHNbOsV6xkgPG4/eX/Gpngrx5qUuYKeaOM+TEQ5TuaKajB0DKQVYZBHeqmp6lBpsSvcE/McKFGSa4lFydkerOcYR5pPQnmuYYXVZZURm+6GOM0n2qAz+QJU87Gdmea5HxA1he3lrP9rZFkQZ+QnAz1rQ/wCEeVdRa8a5Pk8vjHPT1rpdCEYpydm/I8765WlOUacU0muvTub0F1DOzCGVHK8MFOcVPXF+HZbGxmu7g3TOI1wBsxkZ6/yrbPiKxFoJ9z4Lbdu35s1NTDyjK0E2Xh8fCdPmqtRfqac1zDDIqSSojt90E4JqauL142F5qNvP9rZFkUZwhOBXYsyxxFmOFUZJ9qmpS5Ixfc0w+Kdac4u1o7ahJIsUZeRgqjqScAVCb62EImM8flMcBt3BNYmpapYappdzGJnjCYOSvXnjjvVCx0aPUdKj+zXR3K7Fty4AzjjH4VcaC5b1HbXsc1XHzc+TDpS0vv5nZKwZQVOQeQRUS3MLTGFZUMo6oDyKbY24tLOKAMW8tduT3rl9NhtB4nYpdMzBmKrt6nByM1EKalza7G+IxM6TprlXvOz12/zOwoorn/EOufYibe2w0/duyf8A16inTlUlyxN8TiaeGpupUehuSyxwruldUHqxxVcanZE4F1Dn/eFcJDbX+rSl1WSY93Y8D8TVxvDOoBchYifQPXX9Vpx0nPU8NZxiqvvUKDcTuUZXUMpDA9wc06vOUkv9HuMfvIW67T0P9DXZaHq0epQngJOo+ZP6isq2GlTXMndHbgc2hipeymuWfZmpTqbXPfEbULrSfAev6hp8vk3drZSywybQ21gpIODkH8a5j1jo6K+FvD3xU+NHiNZzoOoX+oCAgSm306B9mc4ziPvg/lWx/wAJd+0H/wA89b/8FUP/AMboA+0aK+Lv+Eu/aD/5563/AOCqH/43WV4g+J/xr8OwRTa7fahp8UrbEe406BAxxnAzHQB9zUVwfwu8TyXnwj0XxF4ov4xJJa+ddXcoWNfvEZOAAO1dNoHiLR/EdvLNoWpWuoRRNske3kDhTjODigDWor4J1z47fEe21q/gg8SOsUVxIiL9kgOAGIA+5Vjwp8d/H03ifSYtV8TH+z3uoluN9rAq+WWG7JCcDGeaAPu6isXw74q0LxI066Dq1nqBgAMot5Q+zOcZx64P5V8yeOPE/wAcbfxjrMOhJq50qO7kW28vTYnXy93y4JjJIx3oA+taK+Edc+L/AMYPD96lrrurXlhOyhxHPYQIxXPXBj6V778YviDqV94ftE+EWsR6jrIuA1xHp6JcusO05JUg4Gcc0Ae40Vx/whutevfh1o9x4vEw111k+0iaIRvnzGC5UAAfLt7V5/8AtF6x8RtL1DRF+HS3xhkilN19mtEnG4FdudynHGaAPcKK+Lf+Et/aD/5563/4Kof/AI3XPa58Y/i7oN8bLWdZu7G7ChzFPYwI2D0ODHQB950V8JeH/ix8ZPEck0ehanfahJCA0i2+nwOUB6E4jrqPhR8VPiLf/F7RfDvijV5zE9y0V1aS2kMbcIxwcICOQKAPsWivmf8Aal+JHizwV4s0m08Mas1jbz2ZlkQQRybm3kZy6k9BXCp4u/aCdQyJrRVhkEaVDz/5DoA+0qK+Lv8AhLP2hP8Annrf/gqh/wDjdH/CWftCf889b/8ABVD/APG6APtGivkf4G/FHx9rnxg03w94p1eWW3JnW4tZLWGMhkicgEqgIIIHevrigD//1/qhq4fxvfNJeJZqfkjG5h6sf/rfzruGrzLxAd2vXW7/AJ6Y/Diu/L4KVW76Hm5pJqjyrqzqvCukpaWa3Uyjz5BuBP8AAtQah4sjimKWkPmgHBdmwD9K1fETNFoV15PBCADHYZAP6V5tW2ForFOVWpqcuLrSwcY0aOh3uj+JYb6ZYZ4/JlbhechqzvGGkpEv263XaCcSKOnPQ1yisVYMpIIOQa9I1j5/D9wZeCYcn64oq01hasZU9mTSqPG0JwrbrW5m+Cb4zWslrIcmHlf901sappsGpRKlwG+U5UqcEVyPggn+1nA6GM5/Suh8UXd7aWkbWIOS2HYLuKiscRTccRaGlzowlWMsFeqrpaGJ4hWwsby1t/sjOsaDJD4yM9P512EhQWzEqSmzO3HbHSqWnxfbbG2n1C3Q3IGfmXkc1mJqGqHxGbcxn7Nuxt2cBfXNZyvVSit43vqXC2Hk5vadrWW3qYtlcWH2a/JsnwVBA8zPGRxnHHOK09CsbHVNLKNC8Zjk5YNkk/WukSytkEgSCNRJ98BfvfWpIIIreMJBGsaDsoxTqYpNPlun6kUctcZL2jTVn0Mybw/YStCSjARjaAG+8PeqbeIEfUJbOS2JhG5CQeTgelJr1/qdvqcUdmhMRAxhM7z35qqk9/8A8JFMRaLnDDGwdMcHdVQg5R5qmummuxlWqxpz5aC5dbPTfQzrO4sRY32bN+QCP3me/HOOKu2GtRabpMf2a1O95GDbm4OMc5/GrPhfz55LuO7tkELDLZiC8+nTmuhNjamBYTBGYlOQu3gGqrVYRk4yV/mZYTCVZwVSnJJ2a+HzMOfxOI5oFW2JV1VmyeRn0qppk1o3idtlsysWYKS3Q85OK6l7S3eRHeGMun3SV6ULawLOZliQSnq4HJrBVacYtRjuu51yweInOMqk00nfYj1S6+x2M05/gXj69q4bRrNtV1LbKSV5eRq6jxiSNGbHQuoNUPAoXF438Xyj8Oa2ofu6Eqi3OLHw+s4+nQn8K1NjUL+10a1RdoHGEjXvWLH4tbzP3lqNns/P8qzvFjO2tSh84VVC/TFY2a3o4SEoKUtWzz8fm+Ip13TovljHTY9FZbTXNP4+ZG6HHKmuLgeXR9W+b70TYb3H/wCqtnwO7F7pf4MKfoeao+Lwo1htvUopNRRjyVZUd0aY+p7fCU8claaZ3KMGUMpyCMiuW+Ln/JMPFP8A2Dpv/QDW/pJLaZaluvlj+VYHxc/5Jh4p/wCwdN/6Aa82Ss7H1dOXPBS7nhH7Dn/Hn4x/66Wv8pam8TftRXGi+ItT0weFYZhZ3MkAkN+V37WIzjy+OlQ/sOf8efjH/rpa/wApa+c/iT/yUHxJ/wBhG4/9GGkWfQ2n/tW3N3f21sfCMKedKse7+0CcZOM/6utj9tv/AJFDw5/1/P8A+izXyZoH/Id07/r5j/8AQhX1n+25/wAih4c/6/n/APRZoA7D4deHR4t/Zp0nQXuTarfaf5RmCbyn7wnOMjPT1rza61pv2Y2GhWsA8Rrq4+2maRvspix8m3AD56ZzkV7R+z5/yRnwp/16f+ztXgH7bn/I4eHf+vBv/RhoA3l/Zct9aUao3iqaE3w+0mMWAbZv+bGfM5xmvFPHHw5j8M/FmDwYmpPcpLLbx/azDtI80Lzt3Hpu9a+oNG/aI+Hlpo9jbzaldiSGCONwLOQ4IUA9qr3Xxu+EF3qAv7pUmvQVIuJNLZpAR0+YrnigDofgn8IYvhdcatJFrL6l/aCxKQ1sItmwt/tHOd36Vj+HfjjNq/xkPgU6FHEgup7f7YLok/u0ds7NnfZ6967n4ffEvw34/lvY/DN1NO1mEabzIGjwGzjqOfumvmH4ff8AJ4Tf9hK+/wDRMtADf2yxu+KFgPXT4x/4+9dZceGV/ZpQeKLa6PiJr8/YDbSR/ZQgPz7twL5+7jGO9fSmq+HtF1SYXGqaVY3kyrtEk8CuwHpkivnn4s69YfHXRLbw/wDDmR73UrOf7XMk6G3AjAK53PgHlhxQB7l8MPFTeNfAuleIZLRbNr1XYwLJvCbZGT72Bn7ueneuozXxRY/Bn4y2FrHbWM81vbRjCRRasEVec8ANgcmrH/Cpfjd/z/3n/g5H/wAVQB1uvftT3Ola5qGnjwnDKLW4kgDm/I3bWIzjy+OlRW/w+j/aIj/4Tm51FtAkc/YvsccP2kDy/wCLeSvXd0xXvOgeB9Dj0PT01XQdLl1BbeMXDvbI7NJtG4lscnOea+Wv2jLnUtE+LceieFLu40u1mt4BHa2Upgj8xyRnCkDJOMmgD3r4K/BuL4X6hqd1FrT6l9tiSIq1sItm0k5+8c9a8I03/k8pv+wvL/6LauU+IGi/E7wDa2lx4k1jUYIrp2jiMeptJkgZPRuOtdj8B/hj4yn8ceGfHF9Ck2lyObp7mS6VpGUowyQTknJoAk/bY/5HrQf+wef/AEY1fQHxW+ID/DjwHZazFpy6gWeKDyWm8rqpOc4Pp6V8/wD7bH/I9aD/ANg8/wDoxq9H/a2/5Izp3/X3b/8AoDUAcd/w1tc/9CfD/wCDA/8AxuvWfgR8WpfiiNZMujppv9n+TjbcGXfv3/7IxjZ+tfAdfVf7Df3fGP1tP/a1AHMfCz/k7q4/6/r/AP8ARctfaFfF/wALP+Turn/r+v8A/wBFy19oUAf/0Pqhq8/8aWhg1XzwPknGc+44NegNVDV9Oi1OzaCXg9Vbup9a6MLW9jUUnscuLoe3puK3KmgX0Wq6UI5MNIq7JUP8/wAa53UfCt3FMTZbZoieAWCkfnWZNFfaFfZ+aJx91xyrD+tbVt4ydUAubVXb+8jY/TFegqNWlJzw+sWec6tKtFQxOkkO0XwvKtwk2obVVDkRg5yfernjTUVis/scbZllwWA/hX/69Zt74vuJEK2sCw5/iJ3H+VZ2k6Xd6zcl2LeWTl5m/wA8mhUqjl7bEuyXQmVSnGHsMKrt9Tb8C2jAT3bDAPyJ7+v9K1PFFneXlpGtiTkNllDbd1alrbx2tukMK7Y0GAKratqcGmQq9xuO44VVGSa4ZVpVK/tIrU9COHhSw3spuy6sfpMM8GnQR3Tb5lXDHOaw20zVP7fecS7YCSQ+7jGOBiuhs7mO8to54DmNxkHGKz31mymvn07c/mNlN2OM+lTTlUUpWXroOtTpShBSlttruZnhKK5S8uTNcLIoGCok35OetXvFFneXlvEtkT8rZZQ23PpVew0uLw9597cXBdAu0ALjqf51r6XqMGpQGW33YBwQwwQa0qzftPbQ1S8jGhSi6P1epo3fS+o7TIpodPgjuW3zKuGOc1z1rBdDxU5a6QqGJI8wElcdNtbGoa3aWF0kE5be3JIHC/WqSaElvqzai1wfKUmTbt6fjU03yqUp6cy00CvFVHCNPXleuu3qaOuQXFzpssdo22U4xzjPPIzUPhu1urSw8u9Yl9xIUnO0fWpNL1i11KSRLfcGTnDDGR60/VdVt9MRDcbiXOFCjJPrUfvEvY2Nv3Ll9a5tEreRerldOhul8TSF7pGUFiwEgJI7DFdNbTpcwJNEcxuMg1yWmRWQ8UMUuXZgzFVKYBbnIzn61dDRTXl2Mcc1KVJrv3sdHrlqbzS54VGWIyv1HNcd4Xv1sNRxMdsUo2sT2PavQK5DxNoTiR7uzUsrcvGOo9xV4WpFxdKezOfM8PUU44qiruO/oaniDRhqarLCwWdRgE9GFc5H4b1FpNrRoo/vFxim6X4gu7FBG2Jol4CvwR+NajeLxt+WzO73k4/lW8YYmiuSOqOCpPLsXL2tVuMuqNnTbKHRrBtzjj5pJDxmuLupZNW1clB80zhVHoP/ANVLqGqXmqyLG2dpPyxIOP8A69dN4a0U2Q+0XIH2hhgL/cH+NCX1dOpUfvMU/wDhRlDD4eNqUdzdhjEUSRr0UBRXL/Fz/kmHin/sHTf+gGurrH8a6RJ4g8JavpEEiRS3trJAsjjIUspGTXln1KVlZHzX+xTqFlY2ni4Xt3b22+S12+dKqbsCXOMmu21j4KfC7VtVvNQu9Vb7RdTNNJt1JANzHJwPxrzf/hk7Xv8AoY9M/wC/UlH/AAyfr3/Qx6Z/36koGehWvwL+FVrdQzxarJ5kTh1zqaYyDkVgftn6lY33hPw8lle21yy3rlhDKrkDYfQ1zn/DJ+vf9DHpn/fqSj/hk/Xv+hj0z/v1JQB6j4T1688Mfsq2OtaZ5f2yz0zzIvMXcufMI5H418rePPGHin4o3ttf6pZ/aXs4zArWVs20Andg4zzX1j438OzeEv2YNT0G5njuJrHTfKaWMEKx3g5GfrXKfsS/8ib4i/6/1/8ARYoAt6B+z/8ADXU7G023d3JePAskkUd+pYHaCflAyOaq+MPgJ8OtI0LVZLe6uxqcFrJJDA98pZnCkqNuMnJxx3rw/wCGnju2+HfxW1XWr6zmu4ibmDy4WAbLP15+lT6/4yt/Hvx70jX7O1ltYZ72zQRSsCw2lFPT6UAek/sbg6FfeKTrYOnLNHbCM3f7nfgyZxuxnGR+dYXgW3mt/wBqxtUuIpItM/tC9f7W6lYdrRSgHeflwSRjnvXWftxf8g/whj/nrdfyirhvEvxt03VvgkPBEek3kd2LW3t/tLOuzMboxOOvOw/nQB9pW95bXsDSWdxDcRjgtE4cZ9Mivjv9i3/komr/APYPP/oxa9N/Y1/5JfqH/YQf/wBAWvnj4E/EW0+G3ie+1O/sZ72Oe2MASFgpB3A55+lAH32+q6el39le+tVushfJMqh8noNuc14j+0v8U/EPw61DQofDxtNl7FK8vnxb+VKgY5Hqa+cNb+IdpqPxwXxyllOloLuG5+zFhvwiIpGemTtr17XrJv2nHhvtAcaImhAwyrejeZTLyCu302Hr60AepfFTx3rHhn4L2fijTTb/ANpypas3mR7k/eAbuM+9ed+DvDdj8WPCE/xH8V+afEVn5gi+zN5cX7gbkynPfrzzVfUfFMHxX0tPhLp1vJYalZhY2vpyGiY23DYA5528V6j4A8D3Pw9+Dur6He3cN3KsV1N5sKkLhkPHP0oA8j+GeoTftD3l7p3xC2m20iNbi2+wjyTuc7TuPORgCr/g34ia5oHxosvhnYG2/wCEasrtrGIPFmby1QsMvnk574rF/Yh/5GPxR/16w/8AoZr0S1+Cepw/HI+Ozq1mbQ3r3X2bY2/BQrjPTPNAHl/7bH/I86D/ANg8/wDoxq+hPGOkeEfHnhSz0nX9Vt/sqGObEN4iNuC4HOfc1yHx7+DGpfEvxBp+oWGq2lklrbeQVmRmLHcTkY+teY/8Mn69/wBDHpn/AH6koA73/hQfwn/6Csv/AIM0ruPhp4S8D/Dn+0P+Ed1aEfbvL87z75H+5uxj0+8a8K/4ZP17/oY9M/79SUf8Mn69/wBDJpn/AH6koAzfhPIkv7W00kTq6Ne37KynII8uXkGvtKvnH4Qfs+6t4F8f6d4gvNasbqG1EoaKKNwzbo2UYJ4/ir6OoA//0fqhqSlamsTtOOvagCO4hjuIzHMiuh6hhkVkTeF9MkbKxvH7K5x+tU/Dd7q0+pTJfo4hAJO5NoU+gq94puL62sUbTg24th2VdxA+ldUY1KdT2cZb+ZyylTqQdSUb2FtvDemwNu8kyHtvYn9K10VUUKgCqOAAMAVxt5qOvLDYlI3VmXLbYwdxz39OMVZ+3a1/wkHleUfJz9zb8uMdd1VOjUnrKSe/UiFanT0jG3yOrrm/GskKWUImgMrM/wAp3Y2+tN8NXmq3F/OmoK/lAZ+ZNu0+gqfxg10thGLWLepb5/kDEenFKnTdOuot/iOtUVXDyklb5GaviNbC1so7az2xMm4gsfUjioVu7QeKGf7E27cedxzux1xSX82rH+zj9lG4JkARA85+nHGK7FLeLzBMYoxORgtjn862nKFJXtvfqc1OnUrO3N8Nt0cpJ4hXULC9jurPKKoYBWPqBya0vBskL6c4hhMRD4bnO4+tbCWlugcJDGok++Ao+b61j+I3u7CzhXSY9iljv8tAcfhWXPCqvZU1a/maezqUX7apLmsu2pm+KZ7WPWoRNaGVlALHeRuHYVei177RrDae9t+5YmPJPPTuK1LCI3VnbTahAn2oLk5XkGp5oETzZ4YUNztOGxyTj1pOrCyhKOq03GqFTmdSMrJu9rdOxlTW1r4dsp7u1hZ3OBgtnv8AyrE1bVotQ023kuLTMnmMoIYgDGM/nkVLBe61NY3wliaTAGN8Y455wMc8VDNJqf8AYcC/Zht8w8+SM44xxj61006fLK89Xfe/kcNapzQ5ad1G23L5nXaQ8b6bbtDGY4ygwnpUMOjWcN+byNCJSSevAJ6nFYVzfa0l1ZqkTKpRcqqDDHvn0rqbppFtpGhAaUKSo9TXHOMqbun8XmejSnTrK0o/B3X5E1FcdbahrZsLtmSRnUjaxjwV55wMc1u+HZrufTg9+CJNxAJGCR9KVSg6abbQ6OMjWkopNXV9iS80eyvGLTwLvP8AEvB/SqQ8L6cDnEpHoXqvqt5qsWuRxWyN9nyuAFyGHfJo0u81WTXJIrhGFvlsgrgKO2DWsY1YwupaWvucs5YadXllTu722Nqz0+1sh/o0KofXqfzq3WZ4gmu4NNZ7EEy5AJAyQPpS+H5rqfTUe+BEuSMkYJHrisHGUo+0bO2FSEKnsIxtpfbQ0qg1O/ttL0+4vr+ZYLS3QySyN0RRySanrk/i5/yTHxR/2Dpv/QDWR0mV/wALq+HX/Q12P5P/APE1peHfib4N8SatFpmh6/a3l/KGKQxhssFBJ6j0Br5D/Z9+EunfE6DXH1LUbuyNg0ITyFU7t4fOc/7o/OvT9b+GNh8CNOk8faHfXOp32nkRJbXaqsbCU+WcleeAxNAF/wCP6/FVPGbTeBn1ZNDSzRnNrIoQON248nPTFeK+E/Gfxe8W3M9v4b1rWtQmgQSSJFKuVUnGecd6+sPg340uvid8P7jUtStobOSWaW0KQEkBQo557/NXkPiHRov2aYItb8OSvrE2rN9jkjvgFVFUb8jbjnIoA860Hx34pi+INr4f+KOt3n9iifytVs71t0ezGcOB2zjpX1r8LH8DSabe/wDCuvsP2LzR9o+yKQvmY4znvivnfxr8NrHxb8NtS+K93e3MGqX1v9ueyjVTCrbgu0E84wK6/wDYj/5E7xF/1/r/AOixQBf/AGgPhBp114LaTwP4WgbXZLxHdrZQJCh3Fjkn1xVH4ffC+x0L4KXWpeIvDsNr4tsoLq4SeVR50TKWaNgQcZGARX0fXzL+0F8a9V8NeI9b8H2+l2U1nLaCMzuzBwJYuenHG6gDwaP/AIWH8Wv3StqPiH+zvm2s6nyd/Gecddv6V9DeKPg5Yn4DhNK8KQf8Jn9ktgdijzvM8xPM5zjO3dmvn74QfFPUPhjNqkmm2FreG/WNXE7MNuwtjGP96vvPwTrEmv8AhHSNXuI0ilvbWOdkT7qlhnAoA8K+Autad8K/B9zofxCuo9C1aa6a4jtrnJZoyqgN8uRjIP5V5x8J/Adp4Q126vfjJosdhoksBjt5NQXcjTZBAG0k52g1758WPgnpfxE8QQ6xqGqXtpLDAIRHCqlSASc8/WvKvD/iWb9pC6fwz4ggj0i2sE+3JNZEs7MPkwd3GMNQB5t8VPAF5e67rPiTwPopfwPtEttd2wAh8tUUOQCc8OH7dQa7j9kvxz4a8IaX4jj8Savb6e9zNC0QlDfOAr5xgH1FaM/im48Pa8Pgdb28Uuis66d/aLk/aNk4EjNj7uQZCB9K6D/hlHw7/wBDDqv/AH7j/wAKAND456TovhH4e3HjLwPawaZrM88TpqVqNsjJK3zHJ/vA15D4F1P4xeL/ALHd215rWo6DLciG5cSLsZNwDqc84wTmqfxX+Lmpat4cu/Ac2nWkdjp862yXKs3mMIG2qSOmTt5qD4XfHbVvh94WXRLDSbG6hWZ5vMmdg2WxxwfagD1H9o61h+Fek6Ld/DuNfD1zfTyRXMlkNhlVVBUH2BJrt/hr8aPCSeBNEXxN4rtv7ZFsv2rztxff3zgda+ZPi98YNS+Jtjp1rqWm2lmtlI0itAzEsWAHOfpXU3fwU0qD4GDx0uqXpvfsSXX2Yqvl5LhcZ645oA3P2hvjHdS+JNNPw78Vy/YPsuJ/sjFV8zceuR1xitz4T+IfHnhXxCdT+Lmo6jZ+G5LcpHNfOGjMpwVHy5OcA1wXwD+DOmfErw9qOoajqd5ZyWtz5CrAqkEbQcnP1rL+K/xo1Txx4dHh290yztre2uFdZYmYsdgKjOeO9AH1h/wuv4df9DXY/k//AMTXm/xg8YeIfGh0s/BLVrrUBa+b/aX9nNt2btvlbt2Ou2TGPQ15j4N+Cela78FpPGk+qXsV4ttczfZ0VdmYndQM9edtdl+w19zxl9bT/wBrUAeyfDr4gaLf22k+Hr3WopvFi24jurVsmUTImZAeMZGDnntXoleTeHPgnpeh/E5/GsGqXsl4000xt3VfLzIrAjPXjdXrNAH/0vqhq5abSdRfxKLtZf8AR9wbdu6L/dxXUtTScDJ6VpTqyp35epE6ana4tc/40ilk01fLnWJQ/wAwZtu6rWma5a6jdPBBvDKMgsOGFO1/SRq1skZlMTI24NjI/KtKSdGqufQipapTajqQ6TdRWGl2cV9eRGVx8rFs559ayDb3H/CYbvtkeN27b5nO3H3cVYuPCMcsdsi3LL5S7WJXO7nPrx1qb/hF4v7W+1+e/l53eXjnOPXNbxnSi5SUtWn0OeUKkkouO1uprx6lZyebsuYm8rl8N92srX4pda0+M6TOsiq/zBWxu/8A1VQm8OW2m2N7Nc3bmJkCgheV5GO/POKueCVtlsJfs0ryMX+fcu3Hpxk1PJCmva03ez7Dcp1H7KorX8zJ1WxvYn06Oa+jWQJj5pMbTnr79vyrrWvIGka0W5jF1t6Z5Bx1xWdrfh5NUvI5zO0eBtZducj254rEW305vFTR/aJcliAu3jdjpuz/AEq/crwV3qk3ojO0qEnZaNrqN0qwvZotQjgvY2dgBhZM7jnr7Vt6Gj6LppGqzpGGf5QzZ2+1P0LQF0q5km88ylhtUbcYH9al8RaXHqkUSvcCB4ySCec59s0qtaNSfI37r62ClQlThzpe8ulzP1zTb7UNRgubGYGDaNrB8bff3ralu4ZGltI7lBc7DxnkHHWl06OCysordJlYRjGS3WsceH7Y6pJdG7BVyT5Y6gkeufesuaM/dm7KO2ho4yp+9BXct9diHwbDNHcXTPcpIvQqr7sn1qfxnFLJbW5SdI0DHcrNt3en5VZ0HQl0qeWXzzKXG0fLjA/OqfjZLZobY3ErxyAnaFXdkcZ7j2rVTU8SpRd/l5djCVN08I4yVvn59yvcaRqc1xZyxXIdVRf3gf7vr9aXTbedfFMjNdowBYsA+Swx0xVy31zT9PhtLRHkddi/PjoD61l2J06DxLLKLiT5C7AFOM4Oec/XtWidRxkpLppoYyjSjKLi7u6vrsdtRWZpGs2+qNIsAdWTkhhjI9aXV9Xt9LEfnhmaToFFcHsp83JbU9X29Pk9pfTuZmq6XqFxrkdxBLiEFcHdjZjrxUNvo+qLqVzKZ9qurAPu+9kccdq0ZPEdilzFDlz5gB3AcDPTNEfiOxe6lhy48sE7iODjriulTrqNuXp2PPlSwsp8znrfv1IvC+n3lj5/2xvlbG1d2ee5rXuru3tApuZUj3HA3HrWVH4msntZZsSDyyBtI5OemKyPEV3YalDaXHmyo3K7QmSBnnPNL2U6tS9RW+Q/rFLDUOWhJNru/M7NSGUEHIPINUPEmpWuj6Df6jqCF7O1haaVQu4lQMnjvVjTxGLGAQMWj2DaT3GKZrWmW2s6Td6bqCGS0uomhlQMVLKRgjI5FcjVnY9KLukz5h8axP8AHl7SX4Wn7CmjhkvRcf6LvMuCmNud2PLfr0zXzb4g/tLT9SvdK1C8mlktZmhlXzWZSynB69eRX1H8T9F1n4PSadH8GdNvIY9TEjahsha9yY9vl/fDbfvv0xn8K0NN8AfCPV9PttR8UT2S69dRrPfrJqjRMJ2GZMoHG07ieMDFIo+P7e/vLaPZb3VxEmc7UkKj9DXrHwB+I+keDta1S58Ym7vbae3WOFdnn7WDZJwx44qf4pfDvT4/iDZwfD3S7m/8NskIkmtGe5j3ljvHmZODjHGeK9+1f4H/AAj0aKOTV7RLKOQ7Ua41OWMMfQEvQBZ8J/HfwT4o1uw8PaZbXwlvX8mKOS1VY84J556cV69bWsFqpFtBFCDyRGgUH8q+FfD0egeHP2mrNNJubeHw/aaj+5mM++NU8vrvJORk9c19mf8ACd+FP+hk0f8A8DI/8aAOc+PPhHWvGngYaV4cnjgvvtUc255TGNoDZ5H1FL8GfBNz4Y8BWel+J4rS71SKSVnl4lyGclfmIz0Irgfgx4z+Iuu/Eu7svFKXP/CPiKZ4XewWJGww2YcKM8e/Ncl+0B8YvGng/wCJ2oaPoGpxW9hFFCyRtaxOQWjBPLKT1NAHtfxO8a+EfhzHp8niDTdy3zOsX2e1R+U25z0/vCvmP4l+A/FJ0rVviBaXqxeGrlxeQRLcssixSuAg2DgH5xxmsdr34i/He8tbCYpqI08s4l8qOCODfjJZgB12jjk8V6nqXgD4s6l4KHhS88SeHW0QRRw+QCgO1GDKNwTdwVHenYLmH8A/jXoHgrwbdad4lk1Ke8kumlVo08wBSoA5J9Qa8j+F/grXvHOtXNj4ZuI4LqKEzO0kxiBXIHUe5FfRnw1/Z68NWuhyp4+jtL3UzMSklrfyKojwMDAI5zmvUfA3w58E+BtSmvvDUC2t1NF5Ls148mVyDjDMR1AosxXRy8/ha68K/s4ajY6ylvJrdnp1wZLmP523FnZSHIzwCPyrkv2KLu4u9H8VG6nlmKz24UyOWx8r9M10XxS0T4meI9Q1qw0TxFoUXhe8QRJbTbPMCFAGBbYT97d3q3+zX8PNT+HljrkGr3VhcNeyxPH9ll34Chgc8D1FFmF0fGXjv/kdtf8A+whP/wCjGr6z/Zl0eDVfgRdxfZrd7qaa6iR5EBIJUAc49TXhvgnRvD2tfHbWLHxq0cektc3jOZZzAAwZivzAjv719aeCr74eeC9FGk+Htc0q3sRI0oRtQWQ7m6nLMT2pDOA/Z3+D+s+BNV1ifxTFp08V1BGkQjbzcEMSc5HHWvm/453U8XxV8VWkU0qWq3rKsKuQgHHAXpX0f+0V8Xrnw5pWjS+AfEGnvcTTSLceT5VxhQoxkHOOc1y3i3wH4f1v4D3fxE1GzeTxXeWSXs10JnVWlZ1BPlg7Rx2xigDmv2cfi74d+HnhnU7DXlvWnubrzk8iIONu0Dnkelang/whc/BfXZPGXjuO1uNEuka3jS2/fPvkO5cqQB0U1D+zF8LvCnjvwtqt74l0+S6uLe8EUbLcSR4XYDjCkdzXqv7V2j3upfC62s9Hsri7lS+iIigjMjBQrDOBzQBzPi79oXwNqXgzWNI0y31GKS6tJYYl+zKiBmUgZw3HJry/9mn4oaD8OF8Qf8JAt2324weV9njD/c8zOeR/eFbnhv4f+Aofg1Pe+KY47TxpFbXLm3uL14ZVcM/l5iLDqu0jjnPvWf8AstfDrw14+XxH/wAJPZPdfYjb+RtnePbv8zd90jP3R1oA+gfA3x28J+NPE1poWkJqIvbkOUM0AVflUscnJ7Ka9Wrzrwj8GfBPhLX7bWdC0yWDULcMI5GupXA3KVPDMR0Jr0WgD//T+qGppGetOamtnBx17UAULHSLOxuHmt4trtxnJOPpUPiLVH0u1SSOIOzttGegqj4fudVl1GZb9X8oA53LgKe2KseLDdDT1FpHvy3z4UMQPpXXyP2yjUd/mYOX7tuGhnXXiqWKK1dbUfvF3MGJ9SOPyrqfM/ceZtP3d2O9cbfSauYdP/0f5wuRiIHnPfjjjFXlutYPiFY2Rhb5GVC/Ltx1zWlShFxXLZb9SIVJJvmu/kLpOrjX5Liyu7ZRCy54J6Z71t6bp1vpsJjtUKhjkknJNTxQxRMzRRohblioxmsjxVNfw2cZ04Nkt87IuSB2rBtVZ8lPRMu3s4889WiDxB4hk0u+jgjgEgKhmJOM/StCPR7L7cL8QkTn5uScA+uPWnaZG9zp9tJqMKm6AydyjI54+nGK0KU5qK5YaPZ67jjByfNPVdPI5bxjrMtoVtLVijsu53HUDsBXEs7MxLEsT1JOa2fGZJ8QT89FUD/vkVmabb/bL+C3zjzHCk+le5hKcKVBS8rs8bFOVSq0QZpa9atrO3t7cQxQosYGMY6/WuC8YafHYairQKFjmXcFHQHvWeHx0a0+S1h4jAyow573I/D+tT6fdIkjs1sxwyk5x7iu61LTbbUo0W6QttOVIOCK8rrvvEVxqMVjZtp4f5h+8ZFyegx/WscbRtVi4aNmuDq/upRqK6Rl669naa1bwiwDLEFH3iNw7ce1b9xpNhbPcXwty8m1mK5ODxzge9W7GMz2ttLfQp9qCjJKjINT3RkW2lMADShTtB7muCdZu0V00eu52ww696ctb6rTY4rRtVisbS9mt7ILINvO4kYJ6GjV9Xj1DTrWW5sg0m9hncQBjGcfWnWcmrjS78C36kdYgD15wMc1veHY5bjSEXUYEyrHYGQDj6V11ZQpydRrr38jgpQnUj7JSsmu3mc9dXdodWsz/Z+AFj43HJyBjj2rorjSrCzW5vRb732MSuTg5HOKztYbUl8Qw/Z4N0S7Qh8sEEd8nt3rpL1pVs5jbgNMEJUHua56s2lDl6+Z0UKSvPm1s+3kcJbXNr/ZF4PsAzuTkOcc5xz7UXV1af2VZAWAHzNyXIHUZ575qzavqw0i8At+Cy/8sgD74GOe1LdPqx0qyBt+Ax6RAnrxkY4rs05vn38jzXF8ny/l8zsNPZXsoGRPLUoCE9BjpVqq9mZDaxGcBZSo3AdjUesala6Ppd1qOoSeVaWsbSyvtLbVAyTgcn8K8eW7Po4fCjzX44fF5fhbNpCNop1P+0FlbIufJ8vZt/2Gznd+lfPfxW+ERtvBV78R/wC2Qy6g8d7/AGf9mwU89wdvmb+du/rt5x2rrvjfG/x2l0iX4Xj+2U0hZVvS3+j+UZduz/W7c58tumelcVe/Cf4132kjS7y3vJ9OVVUW0mqQmMBcbRt8zHGBSKPZ/wBkq4+yfBW6udu/yby4k25xnCqcVyEmt/8ADToGhpB/wjX9kf6b5xf7X5u75Nu3CY65zk1f+G3iXSvhD8Pb7wj8QLk6Xr8pmuEthG0+UkXCndGGXkg96+fvhXovjbWtSvYvh69yt5HEGuPIulgOzPGSzDPNAHt//DJT/wDQ5L/4Lf8A7bSf8MlP/wBDkv8A4Lf/ALbXN/8ACB/H/wD57at/4OIv/jlcd44v/in4HvLa18T61q9nPcRmWJRqHmblBxnKMe9AH2B8TfGf/CrPAFpqTWP9p+S8Nn5Yl8nPykbs4b+7096+MPHHiEfFj4qw3y2x0v8AtOW3tNhfzvL4VN2cLn1xxXq3gmy8S+GbyLWfjdJPP4Mlh2x/bZxeRmZsGM+WpY5xu5xxXmHxQu9I134teZ8NhGlpM1vHZC3jNuBLtUcBgNp3d+KAPqTw/wCC4fhh4EtNEivRcvcXLyXNyIvLMx6qMZOABgde3vTjcwBc5XH0qDQYNf0L4Z+H7fxoZH1pJp/OM8wmblmK/MCQflx3qNtUhbgpCRn+7XoYapyQODEU+edy4bmHaSuCccDHWvALrXfGEesvdn7axgmVzEpG3qBs9D6V71Y3cVxcKiRxDJyx2/dHrU9zp2hRa9KrESXqspMO/wCXPUEDofwqMTXk2uVnTgsPD3lU67EFvqCTWsMsqeU8iBijDlSR0pyamLaQTwSFZI/mUgEVJrTw2F0GRY9kg4yvQ96yJ9XjEb48sZU/wVt7ZOJySw8oSsed/FX4dQeNv2jP7FtbtdMa/wBPW8kmEPmDeqc/LkdcDvU2rfsqNp+lXl7/AMJeJPs8LzbP7Oxu2qTjPm+1QfHPTfE2rfHq0tfBLTLrLaVGyGGcQttAO75iQOnvXuXwcsPEGh/DOeH4jNM97HJPJP8AaJhcEw47lScjGeK8w9E/PjFfRvgX4lr438GaV8I10s2TX0C2P9qGfzAm3593lbRn7uMbu9Yv7RHiL4da1pWjp8PI7NLiOeRrnyLJ4CVKjGSyjPOa1ofGnw80/wCCcNvpMltbePYbJFS4hsnSZZtw3ES7cZ255zQB9B/BD4aN8MdDv9ObVBqX2q48/wAwQeVt+UDGNzZ6V6NxXwZ4Hg+L/jixnvPDOq6veW8EnlSMdSWPDYzjDOD0NenfDibxv8M9fbW/i/qF/b+HWha3R5rv7WPOYgqNkbMegbnFAGn8fPgc2v6t4j8b/wBviALbCf7H9k3Z8qILjfvHXb6cZrJ/Yb+74y+tp/7Wrz34t+P9V8Z/E6+s/BOvX9xo2pGG2trdZHhjkJjVWXa2MAtnrU2g/CD4y+HxN/Ydndaf52PM+z6lCm/GcZxJzjJ/OgD37wv8cF174tyeCBoBgKzzw/bPte7PlKxzs2Drt9e9ez18l/A/4T+PtA+Lmm+IfFGmFLZTO1xctdxSMWeJ1BIViSSSK+tKAP/U+qGrkp7aQ+LFYXcY+YMBu5Ax93Fda1YcugxNq324zMBu3lMd/rW9Cag3d9CJxvY26KxYfEdlL53+sURruyR94e1W9J1OHUoneEMpQ4ZWHSolRnFXkilJPYwvFtvJLf2rLdRxDGArPjac9ak/sbUP7d+0/aB5ec+ZnnGOmKvazoUep3UczTNGVG1gBnI/pThrdpDfix+cFfk3kcAjtXVGrL2aVPVpO+hg4LmbkYkOi6ha29+01ysSumNxfhuc5Pp/9eoLXSry70MJbXKSDzd3lq/H51uLqFp4giuLFfMTcMhiOuD1qOFbbwvZHzXeZ5n7DGcVp7aps/jutLEOlHfoa2kW8trp0ENw++RFwWrEj0e/XxKbwyjyN27du5I/u4q1N4msohAcSMJRuyB90Zxz+RrcUhlBHIPIrl5qlJuTXxGvLCaST2POvGA/4n8/0X/0EVN4JtBNqxnbpAuR9TwP60njKMrrkjHo6KR+WP6Vmabcva3MbLK0aBwzEDPT279TXtRTqYVRi+h5srRr8z7nq1ct49tfMsIrkfehbB+h/wDr4qx/wlmmjj99/wB8VzPibVhqF0DbTOYCm0oV245z+PIrzcJh6saqbVjsxNWnKm1e5hZr1Rry3srKB7qVYlZVALd+K8sVSzAAck4Fdr4zjthZ2QuZJElXITYu7IwM9x7V24+CqTpwfW5xYRunCcl5HQSalZxyxxvcxh5BlBnrmo7i9t5/PtIbqNbnYR15XjrWJH4btL9bS6guJBDsUYK8sB/KppPDltb3dxezTv5O12K46ZBzz+Neb7OivtO/p1O7nrNfCrevQx9K026udPvora8jZiVGxXznnv6UupaZdWukWkdzdxoQ7fu2fAGcYwe+P60/w5eafpkV5ciSZ2GF2lMEjPGOa1bm1t/FVpDcQyvCYyVIK59MjrXXOpKFW8vhvvbyOKNGE6Vo/Fba/maNre29tFa2txdxtcFABz96sWDQ9STVLqY3AVXVgHDZLZBxx7Val8LQPeQzLO4SMKCmM7to9e3St64mS3t3llOEQbifauN1FT/hO999Ds9k6v8AFVlHbUxPCumXenC4+1sMORtQNn8a36zNG1m31XzBAHVo8ZDDtWpWVdzc25qzNsPGEaaVN3QVyvxaBb4ZeJwoJJ0+YADv8hrqqd1rI2Pl/wDYhhkitPF3mxumZLXG5SM8S1veBvjD4j1r4zz+FtStLKHSY57mITCNlbEYYr8xOOdorvPi18V9I+Gc2mJq9leXJv1kaP7MF+XZtznJH94V4N8Z/j14f8c/D6/0HTdO1GC5uHiZZJgm0bZFY5wSegoA9b+Lfwk8MeN9Rudf1PULlL2K08tUgmQKdgJHBBPevk34XeOtf+HGpXt7othHLLdxCFxcQswABzxjFdB8K/g9rPi3QU8U2N9ZQ2VpcMXilLbz5eGOMDHIr27/AIap8J/9AfV/++Y//iqAOz/4WHqX/Cif+Eu2Wv8Abn2L7R9nwdu/fjG3OeleX+D9Itv2g7WfWfH8j6dd6Y4tIEsyIlZCNxJD5ycmrng34can4s+KOnfFSxurWLRL25+3Jayk+cqbSuDgYzketdH+0J8HdZ+JOu6Xe6Re2NtHa2zQutwWBJLE5GAaAPQPG/gjRfHHhK38N393KLSFo3U28i7/AJBgZ4PrXxh8UvDMfwy+K/2bw+lxcQaa1vdRPcDdltqvyQBxmvffgV8D9d+H3jc61quoafcW5tZINkBfdliuDyB6Vv8AxU+K+k2Wu6h8P5LK8bVL+FbSO4AXyladMKTznA3DPFAGP/wl174x+E/hrX9VSCO7ubmcOsIIUbWZRjJPYVz/ANpHb+dbWp+FbzwN8JvDWg6jNDNc21zOWeHO07izDGeehrj/ADMDA/nVKTWhNtTotCnabVrWHzdiSNsbnHB612X9lS2esw3Vg0IALeZvUliD6HNea6OTPq1rEucs46frXUXt7dWElyIrlhFbqMjGcng4/I1duaD96xpTqqMvejf9Cj4m1aW81WffhViYooB9Kxppsxtz2NUHuWdmZmJLHJNRSy/uzz2NRzMl6u56V8aLdPBs6/EnRyZ/EVvBDZJbS/NEY3+UnaOc4PrXllp+0J411y6h0m80qwS2v3FrKyW8gZUc7SRz1wa6D4leM7LwF+0bp+uanBPcW0ejpGY4ACxLKwHUgV758NPGth8QPDK63pltPb27TPDsnA3ZXGehPrUgfKX7Q/wg0f4e6Vo9xoEmoXMl3M8cgmYOAAoIxgD1rwxrW4RSzwSqo6koQBX6H/Fn4l6X8NLHT7nV7S6uUvJGjQW4UlSoB5yR61z/AMWtdt/E/wCzhrOt2cckVvfWKTRpJjcoMi9cUAcb+xXPFD4I1wSyxoTfggMwH/LNa9g+J3gvSvHnh1NK1y5mt7RZlmDwuFO4AgckH1r83Mmv0B+M3gS/+IXw8sNH0q4t7edZYpy85O3AQjHAPrQBw+o/AXwr4Q0q58UaRfajNeaTG17AJJVaNnjG4A4HIyK3P2dfivqvxEGunxAlhbfYTD5Xkgpu3785yT/dFaOl+E7zwR+zrqegajNDPdWtheFpIc7TuMjjGeejCvgnJoA/VJWDKGUgg8gjvS1y3wr/AOSa+GP+wdB/6AK6mgD/1fqhq56bXJU1r7H5AMe7Z/tH3roWrmpzqP8AwkQKJ+6zgHaMbfrW9CMW3zLoJmXZXVuPt5Gnrgxk4DE4GRx/n0rY8ISRvaTCOARFW5IJO786pWbasGviY/nKnqgHzZ7evGaZFLq8ejt5auuJOCFAbH/667KqU04q3TqQtNTsKoHSrM332swgzdc5OM+uKdpLztp8JveJyOc8Hrx+lW3J2nbjdjgGvPu4NpMuye5kT2trolrc3lpb5kA6ZJ6n+VYeoav9v0lWubRXYS7Q2SAOM1YtptceK9EiuTs4DqODnt+Ga0fDSTy6e6X8QKbvkDKBkfSu1WpLnnq011MWubRaHPX93bbdPJ05cCPOCxGRk8f59a2odelfXBZfZwIi2wf3hx1reaKJim5EJX7uR0+lJJGoLvGieft4OOTWUq8JKzj36jVNp3TM/XtHj1WFfm2TJ918Z/A1ycnhjUlbCxI49Q4/rWnaz66be93CTcF+XcoBBzzt/DNMa41w6QjAS7vMOWC/Pt7frmumjKrR9yMlYxqRhN3aZl/8I1qn/PuP+/i/40o8M6of+XdR/wBtF/xru9MM7WEBvBicr89YCza3/bsqhWMPzYBA2Yxxz+VVHG1pNrTQmWGppJ66jdB8MNbXC3F8ylkOVjXkZ9Saf44lijt7ZZLYTFmJDEkbcY9PX+lTeGJdUkuJxqIk8sDjeuMN7VvyxRyrtlRXXrhhmuapWlGupVHe3Y0hSi6TjDS5W0h1k0y2eOLylKDCf3axLXXpLzW30+W2XyGLJ3yMA9aNbl1hNYiWxV/s/G3aBtPrmt65iKRTS20afaSh2nAyT2qLRguaSvzba7Fe9LRO1vxMLWtPsNI0a5aG0EgkZQQWPHPHPtVrwfLHLo6+VAIQrkEAk7j681iQT67Jpl75iu/QDeoz15wKR5dej0e18lJF+ZgdiDdjjGR+ddLpOUPZykr33v5HOpqM+eK0ttY7imSxrLG0cihkYYIPcVFYtKbSH7VgXBQFx7965/SptZbxBIl0H+y5bdlflA7YP5VwwpOV3fY651ErJrc2tN0y104P9kj2b/vEkkn86z/E2tS6U0CwxK/mZJLdOO1b1c14wN//AKMLJC0ecthQx3dutaUP3lVe019TPEfu6L9np6G/aTfaLWKYqU3qG2ntmsP4k391pXgHX7/T5TDd21lLLFIACUYKSDzxW5ZmU2sRuABNtG8D171R8V6OniDw3qWkSTNAl9bvAZFGSgYYziud7nRHZXPgO9uviH8W9kkyah4h/s3KgxQL+58z12gddnf0r3fx98F9Ki+CsFx4f8KyHxcYLUuImkaXeSnmfKWx03Z4r0/4M/Cm2+GEWrJaapNqA1BomYyxBNmzd0wTnO79K5jwR8brzxH8X5vBkmjW8EEc1zF9pWcsx8oMQduMc7aQzwXw3p3xr8M6LJpGhaZrlpp0jMzwrZowJYYbllJ5Fafwc8A6Touq6hJ8ZtI/s3TZIQtm+pM8CvLu5CkEZOK+0tRuDaafc3KqGMMTSBT3wCcV8t6brT/tNSPoeqQroCaQPtiy2x88yFvk2kNjHrQB9JeDItFg8MafF4WMJ0RY8WvkuXTZk9CSSec1tV83+BPiXc+EfiBpfwmh06K5tLGf7ANReUrI4wX3bMYB5xjNfSBoA4qb4q+BYZnil8VaSkiMVZTOAQRwRXx/8etcj1v44yal4PvEvnY2v2Sa2IfdKqKAB2J3Cuk+PXwSs/A/hy48S2+tXF3LPfBDA8AVRvLHqD2xSfCb4R2t78P7f4iNq063GntLeLZCEFHMDEhS2cjO3070Aei6xc+I7j4QeGZvGYuRrhup/tH2iMI+MttyAAPu4rhHuAO/Fel/C/4ip8arPXNO13RIrS2slhkUwTFm3MW5GQMY2/rR4t8C+DfD2h3Wqa1qeqx2NvtMjCENtywUcbfUigDj/AbQS+IIZZrmKLyyQqHkuSCBiqOu+ILh9Q1e1hZPstxPlsp82V4GD26V0fgbwJ4C8T6XPf8Ah/W9cnh80o8rQhG3DnH3feuYXWvhCvXxLrpbuTaE5/8AHaG3axSaWvUoJLnHNJJISuF5J4xWoPEHwiH/ADMmuf8AgGf/AImu8+FmneAPEd3NfeH7rUtWNi6ZjuIvLVWOSueBnp+lLURN+0d8O4PEXg6XVNI0OS+8UKLeJJIdzSeWDyNucdPavHPhzafGbwtLp+l6bp+tWWjfa1eaL7IhXDMN5JKk9PevtS13lS0owzdfaotZuzp+j316iB2t4HmCk4DbVJx+lMR85/tv/wDIu+Fv+vqb/wBAWur+EmveCvEXwp8O+DdV1PT7u5uLNYJtOMxEjEHdtwCDnjP4VwWmak37TjvpeqxroCaIBcpJbHzzKZPlwQ2MYxXn/wAN9ATwt+09puhxTtcR2OoSQiVl2lwIm5I7UAdL+0N8HJrTxHpqfDvwrdGwNrmf7KryjzNx6liecYr3X41T+MLH4e2TeAlu/wC2RNEri2iWRxHtO7hgRjOK9QNeGfB3433nxA8cXOg3Oi29lHDDJKJo5y5O1gMYIHrQB4jpvxC+JFx460/wn401O8WG7uYra9sbi3jQvFIRlThQRlW7HvXvfiX4cfBfwv8AZ/8AhIdN0vTvtG7yvtF3Ku/bjOPn7ZH51Q+Knwltm8W6l8Sv7VmF1YKl8tj5I2OYI1wpbORnZ1x3r5v+M/xYufigdJN1pUOn/wBn+bt8uUvv37OuQMY2frQB97eHU06PQrBNE8s6WsKi28tiy+Xj5cE9RitCvmT9n743Xmua34c8EvotvDAls0P2oTksfKiLA7cY52/rX03QB//W+qGrlbi2J8TBhdorFgQMncBjpXVNWPJokMmpfazI33txTHU/WtqM1Bu76AYum2Ekst7HFexl2Qr8pPzc9f8APrUw0G9/sxofNXcZN3l54xWrpmixWF00ySM5IwoI6CtatqmJal7jutOgrHK3Wg30kVoqzhjGuDliNvOeP89qsLo92NcW6M4MYIJbPJGOmK6KmsoZSrdCMGs/rM7WDlRlajd29/p13FbXaK6r8zZwBz/kVT8Oyw6fpjyXN3GY2fgDJ2+1Sw+GoI0nUyuwkXaOMbec/j0rP1bTLTTdORJZZGkaTKsB149K2h7OS9lFuzfYl3vcXxHGt1fWssd7GqOo2ZY8c9RRDbFfFW5r2MsDuPPzEY6elTw6HaahaWk0MsixhcHI5bk5+nOat/8ACPQf2ibkyNtJz5fv9ar2sIx5L7JrYlxbdyW9li1ewubawuVMuBnHHeq+kR/2FpxGpTogZ8qM5x9Kn0fRItNnklWVpCw2jIxgVU8Yi3NtB9oaQPuOzYM/X+lZR5ZS9jF3i/LUGmvee5qyanZxtEr3CAyjKe9OXUbRrprYTp5y9VrEj0G01CC0nhlkWIIBgjlsH9O9UoYdPk8SSJulO5mAGON2DnnrTVGk72b08gc5I6mzv7W8ZxazLIU+9jtS3l7b2SB7qVY1Y4Ge9UdF0SPS5pJFlaRnG0ZGMCn65pCaqkQeQxtGTggZ69f5Vjy0vaWv7pV58t7ak8mp2ccsUb3CB5BlBnrmo7i+trgz2cV0iXGwj/d4/pXMava6ba6rbQO8w2KqvgZHtTrO306bxFNGHmO8uqgjjJBzz19a6Vh4cvMm9r7GLqyvy6FSysj/AGTqGNQhC5XIDHB57/Wt3w/c2+maLEbu8jKu524JIHtRF4Vt0tZ4jO7NJjDYxtx/OiTwpA9nFCJ3DoxYvt65x2/CrqVqVS8ZS0v28jOFKcNUtfUoa1b+f4kt5Uv4kD7SnzHKj2+v9a7F2VFLOQFAySe1cRqdtpttrlvC7zjYEV8DI4Axz+Va82v2N411ZSiRU2MC+PvYHOKitTlOMOW7SXYdOag5X3ZpR6xYPbyTrcoYozhm54rI8QWMuvRWs+mzo8S5BBOB9awLddM/si83SXHmblx8oz3x3x611nhEW40dPspcruO7eMHdTnTWH/eQvdPqvIlTdf3J7PsalnG8NrFHI+90UKW9TXOfFaWSD4beJZYXeOVLCZldDgqdp5Brqap67pdvrej3mmXwY2t3E0MoVsEqwwcHtXA3d3O1KysfBHw58N/EL4hR37+G9WvJRZFBN5uovHjfuxjJ5+6aX4R69b/D34yx3/i2WULYtcwXLxgyt5hRk/H5j1r7R+HPw38P/D1L5PDcVxGt6UM3nTGTOzdjGen3jXyZongi31z476pB4xsry18PTXt28lzKGgj/AIyn7wgDk4780hnvr/tJfDt1KvdX5UjBBs2Oa4TxtqFj8XbS30/4MqLPUrFzPeMifYd0RG0DcMbvm7V0a/BP4OOwVNSjLE4AGrqSf1rK+InhiT4I2Npqnwosrt7/AFCQ210JEa7HlgbhxjjnvQB478MNK1PRP2i9E03XnL6pb3+y4YyeZlthP3u/GK9D/bN1fUtO8XaAmn6heWqPYszLBMyAnzDycGt+58K21r8OX+Ll3b3EPjyO3+3s0mVjWbds5iPAG3tWN8PG0L43WF1qnxXv7VNQ0+UW1r5dytpmIjcflzzyTzQB8132t6rfw+Tfale3MOd2yadnXPrgmvsr9n+wn1T9mZ7C0Cm4uor6GMMcAszOBz9TXn/7Qvwf8I+Cfh4ms+HYbpbpruKIPJcGRSjBj0/AV6T+yvrWl23wf0izudSsors3E4EDzqrkmVsfKTnmgD5e8a+BPGXwsjtJNUmNgNQLKhs7vO/ZjO7af9oV1Om/Bz4oeJtAtb2O5+06dfRLMiz6kSGU4IypP0r6q+K/gzwf4vi01PGtysCWzSG33XYgyW27up56CvE/h38V9Vsvi/aeCv7Q0+PwdZzT2kUjhBiGONzHmUnnlV570AcXZ/AP4q2EJjspI7aLO4rDqWwE+uAan/Y80+z1Hx9qsWoWlvdRrYFgs0YcA715wa9J+OPxS8ZaN4pgtvh/5Wo6W1srSS29r9qUSZORuXIBxjivnPwb4i8XfDHUJtV06ymsZbiP7OZLyzbaRnOBuAGeKAPsC/8AGXw2sfHg8IXGlWo1ozJb7BpqlNzgFfmxjowrW8a+O/BfwsntINUtxYNfqzoLOzBDbcA52j/arzz4VeH/AAj42XQ/H3iS+gPja6l8+REvFjBkjcomIs/3UXjvXPftoaRqWp6v4XOm6fd3axwThzBC0m3LJjOBxQB3/wC0xrDv8D31TSLmeATy20sUsbGN9rMCOnI4NcD+z98ZPD2j+DbbQfFF9f3GrXF46jzI2mDK5AUFj2rx7XviX428XeGo/B11EtxaQiNRbwWf70eV0zjnjHNeqfBv4QaLffDObxNr1hqFvr1lJPNEJHaIAxDchKEcjI/GgDZ/bAjTw5oPhyXw8i6VJNcyrI1kPILgKMAlcZFfKA1C8F99tF3cC83bvP8AMPmZ9d2c5rvfGvj7xp8U7e2tdRtzfrYuZUWyszlSwxk7c+leq3fwU0KP4BjxJHpmpHxR9hSbyt7k+YXAI8vHpnigD58/4SjX/wDoN6p/4Fyf419faN8ePhXpiRSW0MlvdCMI8kWm7WPHPIGa8u+Bfwv8Ja34fv5viIJtNv0udkCXNz9kLR7RyFbGec814hrWhalpjyy3Wm3ttaiQokk0DKp5OOSMHigD6bufD3ij4kfEq08b+FrmWTwRdXMBEU10Y9yRBUlBhJ6bkbjv+NfRX/CL6B/0A9L/APASP/CviLwL8U/iN4V8H2th4etSdFthIySnTzIoBdmYl8Y6k/SvoD9mL4leIviGPER8SS28n2H7P5PkwiPG/wAzdnHX7ooA6Pw34++H938QP+EZ0axih1+OSWIFLARgMisXw4Hopr1KvLvD/wAPvAWnfEZ/EGmXiP4kaaaRoxfBzvcMH/d59CfpXqNAH//X+qGpKVqydf1E2VuEiP76TofQetVCDnLlQ0ruyJNR1e3sTtYl5f7i9vrWJN4luCf3UMaj0OTVXS9Ml1GQuzFYgfmc8kn2ro4tI0+3TmJW9Wc5rtcaFH3ZLmZTSjoY8HiaYN+/gRh/snBrf0/Ube+TMDfMOqHgiqtzodlcKfLTy27Mh/p0rmbu2uNJvFw2GHKOOhoVOjXVoaMWj2O8qte2cF7GEuY96g5HOMVHpV6L6zWUYDdGHoaq+ImvEtUNkWHzfOV647VyQhLn5b2ZJpwRJBEsUShUUYAHanSNsjZgCcAnA71W01pvsMH2wgTkc56n/IrIL6r/AG46rnysnAP3duOKcafM3rsBBb+IrmSG6drdSY1DLtzgc45qrqGqG90qN7m0R28wqGyQBxWl4d+3G5uBeKfLP3twH3qm8SR3QtIksEOzd84RfyrrvTjV5VFfeQ07GfJrstotnHBaKkbIDs55+lb0em2i3n2tYQJzzuyev06U7T0kazgN4im4VecgcGsRX1f+25VUkx/NgHG3GOP6Vk7TuoaW313Dbc6aiuf8Nyai01x9vLmIf3+ze1SeJpL0W8J09m2kneU6+1ZOj+89ncfNpczfENxHHr0IayWVl2/MScv/APqpNNuI28UuBZIjMzDdk5Xjr6c/1p92Naa8s2CEkKvIAxnvmprD+0/+Eik80fucndwMbe2P0rs0VO2m3cxs+a/ma2uXr6fpzzxJvYEAZ6DPc0zw/fyajp4mmQI24rx0PvWgSjqclWXofShTGiDaVVO2OBXDzR5OW2vc2s+a99DkdcuYk8SxBrJJGUqNxJy2f04pukzQT+I54msEXzN6k5JK+vtz/Wrer/2n/wAJBD9nB8rjZwMY/izRpP8Aaf8AwkM32gHycnfwMY/hx+ldya9l/wBu9zmcXz/PsP1yystK0ab7PZq4kZQ25icehz1q54TkWXR4ykAhUMRgcg+/Na3ySKR8rr0I6ij5I1A+VV6AdK5JVnKnyPe+5sqdp8y2H1meKtYXw/4b1LV5ImmSyt3naNTgsFGcA1p1n+JH02PQb99d8s6UsLG68xSy+Xj5sgdRisDU+eP+Gs9K/wChWvv/AAKT/wCJr1Xx/oEnxW+EqWVnOmntqkVvdK0q7xGNyyYOMZ6Yrgf7Y/Z5/wCefh//AMApP/ia7Ky+NPwxsrSG1tPElnFbwoI441hlAVQMAD5aAPHdO/ZV1W01C2uT4msmEMqyFRbPzgg4617h8ZPiZbfDLSdPvbzTpr9buYwhYpAhUhc55BqD/hefw3/6Gm2/78y//EVjeJfiX8HfFEEMHiDVtM1CGFi8aXFtKwVsYyPkoA37s/8AC2vg1J9i/wCJd/blp8nnfP5Xzd8Yz92vjH4yfDO5+GWrafY3eow37XcBnDRRlAoDYxyTX2D441Wx074B6nqfgO4W1sYrHfYS2oMYQbxyoPI718f2ui/ET4sIdQijv/EAsj5BlkmTMefm2/MR65oA9i/4TKH4+6HafD/TbSTR7m3jS6N5cOJUIiXaRtGDzuqtD+zhqPg6ZPEs/iC0uotIYX7wJbsrSCL5yoJPBOMV1Hxs0Cy+HHwtsta8I2EOha/5kFvLd2a7JcMp3qWHYkc/Stz4Y61qXiD9mfUdQ1q9mvb2S0vlaaZtzEDeBz9KAOJ1a4H7T4ittIU6AdAzI7XX77zvO4AG3GMeWfzriviN+zxqHgjwZqPiG41+1u4rIRloY4GVm3SKnBJ/2s/hXEfCm0+IF1LqX/CuDfiRVj+1/ZJljOPm2ZyRn+Kvafhx4Y+K2q+M9Os/iVb6ne+E5TJ9tgvbhJIXxGxTcoY5w4Qj3AoA639jM4+GOoH01B//AEBa5jVfE0X7SkK+GNKtn0Kawb7c09ywmVwPk2gLjB+bP4Vz/wC0Nq1/8N/Gtpo/gO7m0HS5rVZ5Laxby0aQswLEDvgD8q+hbq1+HvwrjXV5bTTtBFwfs/2iOA5fPO35QT2z+FAHyJ4e8LS+Cv2iNG8PT3KXUtlqVurTIpUNuCvwD/vYr78ryDx5p/hHWPAGteP/AA7aWc2pm0kubXV44isokjG0OCQCCCuPwrmv2RPFWu+KNL8SSeIdVu9Re3mhWI3D7igKvnH5CgDCvvA8/wAE/FGofEzUL2LVbRriVfsMCGN/37ED5jkcZ9K9Z8LeOYPiH8KdX1y1spLKNoLmHypHDH5UPOR9apeLPib8KtUhudG8S6xYXUUcu2W2nt5WUOh7/LjgitXQ7jwpc/C/V5PAYtRovkXIAtozGm/Yd3BAOelAHyB8Bviha/DDUtWurvTZ78XsSRKsUgTbtYnPIPrXs3/DWek/9Cvff+BSf4V8zeEfBniDxlcXMPhrTZL+W3UPKqOq7QTgH5iK6b4T+GNnxt0bw94o09GK3TQ3VpMAwyEY4OOD2oAm+OvxKtviZ4g0/UbXTprBbW28gpJIHLHcTnge9dP8ZPjdZfEDwPbaDbaNc2ckM0cplkmVgdqkYwB71714u0j4LeD72G08SaVodhcTJ5kaPaM25c4z8oPeuG/ai8D+FdA+GlvqHh7Q7CxuHvYl86CLaxQqxx9OlAHX/AXSn1z9me00qOVYnvILy3EjDIUtNIM4/GuE0lv+GX/NGr/8T/8A4SHBj+y/ufJ8jOc7s5z5o/KvGfhj8Rte8P6zoVifEF7Z+HoLtGmgWQ+WsZfc/A7HJJr2X9oEH4zNoZ+GX/E/GlCb7b5H7vyfM2bM+ZtznY/TPSgDpfhZ8KLs/ESy+Jg1SD7Jf+bfLY+Ud6CeNsKWzjI3+navoaue+Hljc6Z4F0GxvojDdW9lFFLGSCVYKARxxXQ0Af/Q+qGri9fkabVJR1C4QV2jVxWtKY9Vnz/eDCuzBW52bUFdnTAJpml8DiJMn3P/AOuuNu7mW7lLzuWPp2FdneJ9v0t1i/5aICv864llKsVYEEcEHtW2CSbk3uVSV733LOmX8tjOrKxMWfmTsRXS+IIFudLdxyyDep/z7VyltbvczrFEMsxx9K6/WHW30iUZ/g2D37UYmyqxcdxTjZoxvCMpW6mi7Mu78R/+ur/iqISWcZaZYwrdGz835VneE4yb6R+ypj863tV05NRiVXcoVOQQM1nWko4jmImrSMSTRri6hs2huVdVTG7J457f57VYGjXP9sG58/5Mk7v4unSp5b+30YQ2e13CjJI7ZPWpU1qB9QFqFbk7Q/bNS51rXS01+4mzKmkafJpMk9xdzIItuDg9eeprSOq2QtxOZ18snaDg5z9OtTX9ql7avBISFbuO1ZTeHIDaLD5r7g27fj+lRzQqPmqPUk2opFljV42DIwyCO9c//YtyNXlujcBYzuO/PPI6Vu2dutrbRwR52oMDNZ39r29xfPYFHwxKbuxNTSck5ez2/QLGFpemtcW97FBeRszADaucHnqc1Yk8PXjabFCJl3K5YpngZx/n8avw2VvoEM12XeTOFAx79K0NLv49RtzLGpXBwVPat516ibnDbvYnlXUigurfT47ezurkGfaBznmsyPQrsarNP9oARt2GB+Y5FV9fFj/bcfn+bu+XzNvT2rqZpFhheR+FQbjWbbpJOO8hct9zkW0Wez0u8+03SRKxXjJIOD3pI9GnvdHthbXUcgVmJXJwM4/z+Nasd1b+Irea2KyRFcMD1/Gkae38N2sUOHmaQlj2/Gt/a1b8v277W8iHBfIy76w8vWLRJL9BIFQfNnIwP61ZTQrqG+uriS6VI2V/nzycg9fpVbUpdOuNbgmYzfOEZ8DjoMf0rqtR8r7BP9oz5Ww7sdcUqlWcFFd12EoJ3ZznhZoNPt7uea8jaLIBC54689Ksa5YtrsVtPp86NGuQQSQPrWJbjTf7Lu8mfzNy4yBnvj29a1NO1ey0vSoFiSVzIzFgeCD3rSpCam6kL81+3kQrcvLLY6W0iaG1ijdy7IoUse9c18XP+SYeKP8AsHTf+gGunt5VnhSWP7rgMK5j4uf8kw8U/wDYOm/9ANeY731OlbHyH+zv8J9J+JkGuvq97eWpsGhEf2fb828PnOQf7or2H/hlbwp/0GtX/OP/AOJrD/Yc/wCPTxh/v2v8pa+e/iPeXSfEDxGq3EwUahOAA54/eGkM+oP+GVvCn/Qa1j84/wD4mvKf2hPg9o/w10PSr3Sb6+uZLu4aFxcbcABc8YAryHQb26OuacDczEfaY/4z/eFfVf7bn/IoeHf+v5//AEWaALy/8maf9wj/ANqV8+fCj4xax8NdMvrLSbGxuY7uYTO1xuyCBjAwRX034P0C68U/ss2Giae0aXV7pvlRtKcKD5hPP5V8mfFD4c6t8ONSsrLW5rWWW6iMyG3YsAoOOcgUAdL8TvjhrvxC8NjRtU07T7a3E6z74A+7K545J9ah8KfGjWvDfw8l8IWmn2MtjJHNGZpA3mYlJz0OON1eqa14k0r43eFLLwP4PtmtdZgWK5ea7jEcZWJdrfMuTnLDtV/wr490H4JaLF4I8YWct3rFmzSyy2kSyRlZDvXBYg9GHagDwn4S/FDVfhnNqcmk2dpdG/WNZBcbvl2bsYwR/eNfevgfV5te8H6Pq10iRzXtrHO6p91SwyQM9q5P4WfEjwz8SZtRj0PT5ojYrG0n2iBFzv3Yxgn+6a4f4jeP9M+IP9r/AAt8Ox3Vt4guZvs0U0yhIFaFxI3zAkgbY2xx6UAeV/tlH/i51gRzjT0/9DauU+Kfxn1n4jaHbaZqlhY20VvMJ1a3DZJwRg5J45r6s+BPw+1HwT4RutN8RtaXd3JctKsiEyAKVAAywz2Ncd8APgvrngHxVfajr8mnXFvPamFVhYuQ24HoQPSgDyT4X/FDVNS0TR/hfLZ2i6RfMbB7lQ3nKkrkkjnGRuOOK7TxdeP+zRLbWPhNRqceuK007ah1QxYAC7Mdd561wvxT1W18NftSXmq3MbfZLG+tZ3SJRnaIYycCu58e2cn7SM9ne+BytrFoqtDcDUP3ZZpCCu3bnP3DQBg/GL4S6TpPw4bx1Be3r6lqDw3MkDbfKVpiGYDjOBu45r0j9m8f8Y66r9b3/wBArO+CXwR8UeDPHdtq2vXlhc6fHDJGYo5Wc5ZcDgjFe9+KY0i8I6ysSKi/YpjhRgfcNAHwF8J/iZqfw1vtQudJtLW5e8jWNxcbsKFJIxgj1rofhPr0/if9pDRtbvI44ri+vnmdI87VJjbpmk/Z3+IehfD7VNYuPENrcXEd3CkcQhjVyCGJOcketdhrXwV8RfEXWrrxn4budPttL1iQ3dqk0jJIiHoCACAeOxoA91+K3wb0b4kavaahqt/fW0ttD5CrblcEbicnIPrXKftgRiD4RWkSnIS+hUE98Kwr5k+J/gnxB8OdUtLDW79JZrmHzkNvMzALkjnOPStf4kfCLxP4K8Lwa1rl9az2csqRqkUzO2WBI4Ix2NAHV+C/gtomu/BJ/GdzqF/HfrbXM3koV8vMbuAOmedorhfhJ8VtV+GY1MaRZWd1/aHl+Z9o3fLs3Yxgj++a3fAHwP8AFvjTwlaa1pF/ZRWF0XVI5ZnU/K5U5AGOoNbf/DLfjX/n90f/AL/P/wDE0Aeg/Bz4/eIPHHxD0zQNR0zTYLa6WUtJCH3DbGzDGTjqtfS1c/4H0L+wvCmj6fcRwfa7O1jhkeNerKoBIOM10FAH/9H6oasHxLZGWMXMYyyDDD2ream9etXTm6cuZFRk4u6OX0PVhbKILgnys/K392tyazsr794yJJn+JTj+VZ2o6CsjGS0IQnqh6VkNpt9C3EMg91Of5V2ctOq+eErM3tGb5oux1CpZabGSAkQ7nPJ/rXNaxqLX8oWMEQqflHcn1pItJvpm5iYe7nFbml6NHaMJJSJJe3HC0L2dB87d2Fow1buyTQbE2dp84xLJy3t6CjXL6WxgRoUBLNgk9BWnSMoYYYAj0NcntLz55q5hfW7M6CCDU7eC5uoB5uPU1M1jbRztdLADOBnIPU1Q1kaj9si+x7/Kxxt6Z96bGNT/ALa+fd5Gef7u2teVtXUrLtf8Crdbj9D1Se+uJUljUBRkEdvY1tVT1JZhYy/YhiY9MdfesRv7Y/s1ceZu3n/exS5FVfNGyFbm1Rb1jVp7O+jhiiDKQCc9W+lUY7oL4gkYWS7/AJumd3A6+ldBYrKbSE3YBnA5JHSsdU1T+2JWAPl84JA24xxWlOULONtl33FpsP0m+fV/Pt7yFDHjPGfXpWxaWsNpCI7dAidcda521TV1trvhwxxjOM5zzj8KJBrP9mxY83dvOcffxxjP60VKSlK0WkvUGjeuNPtbi4WaaFWkXocmpbptltK2zzMKTt/vcdK5+5Gs/abbbv8AurnbjGe+afGNY/tSb73l4bGcbenGP0qPZOyvJEmfpmom1s7yW3s0VgV+YZIGT3zRqWptd6bbSXNojsXYbjkDjHTH+eK1vDqXwM4vlbyz0Djqe9bZRSoUqu0dBjgVrUrQhUvy3+fkTYzrewtLpLa6ktVWUIpA549OKt3z+XZzMY/MwhOz+97Vjal/av8AbMf2bf8AZ8jGPu475qKEa1/aFxndsw2N2NvT5cfpWfs3K0nJff8AgBlW10n9kXgFhGV3LkjOOc9ec8Vt6NaWup6RAbi0RQjEKASM+/rTvDUd8FnW/VvLJG0OOc963QABgAAegq69ZJuMe+9yYx6sRFCIFUAKBgAdq5b4uf8AJMPFP/YOm/8AQDXV1ynxc/5Jh4p/7B03/oBriNDwn9hz/jz8Yf8AXS1/lLXjXxA+H/i678c6/cW3hvVZYJb+Z0kS2YhlLkgg46Vd+B3xf/4VbDrCf2KNU/tBomz9q8ny9m7/AGGznd7dK9R/4a3P/QmD/wAGn/2mgDw/Q/h14xj1qweTwzq6otxGzMbVwAAw56V9E/tuf8if4d/6/n/9FmsX/hrc/wDQmD/waf8A2mvOPjb8af8AhZ+j6dYnQhpn2Oczb/tfnb8rjGNi4oA+sP2fv+SM+FP+vT/2Zq0PHPwz8J+Oby2u/FGmG9nt4zFEwuJY9qk5xhGGeaz/ANn3/kjPhT/r0/8AZmrn/jf8aT8MNY06wGhDU/tluZ9/2vydmGK4xsbPSgDhvGOkeF/BmntffA3yT4yWUQOlncNeyiA58z925cYyFyccVu+Cvh1pHjnwinin4u6TLJ4kfzPtc9xJJaERxkhCUQqoAQDnHvXkn7J1z9t+Nt3dbdnn2lzLtznG51OP1r0349fHA+GNX13wZ/YAuRLZ+X9s+2bMebH12bD03evOO1AHHfFDxBoHwqh06X4JanZWk2oM66iYJheblTb5efN37eWfpjP4V33w2X4XQnR/GWo6lpcXjGWH7TdXD6gynzpEIkJj3bBnc3G3AzxXxXXU/C/wn/wnPjrTPDpvPsX20yD7R5XmbNsbP93Iz93HXvQB9LfGP4gePZfEsDfCi7l1DRPs6iWSxs4rpBNk5BYo2DjHGa1f2ffEnxO1nxTew/EBL5dOS1LxefYJAPM3DuqDJxniuVHi7/hmxh4QFl/wkf2o/b/tZl+ybd3y7dmJM/dznPfpXsnxp+JB+Gfh201T+y/7S+0XAg8r7R5O35Sc52t6elAGF8ZfhH4Y1vR/EniCPRJbrxNLbNJHJHPMWaRUCrhA208AcYr5R0PxL8QfhKktvZfatDGoESMtzZoTLs4yPMU9N3b1r7o+GXir/hNvA+l+ITafYvtqu3keb5mzbIyfewM/dz071xnxw+Dv/C0b3SZzrZ0z7BHIm37L52/cVP8AfXGNvvQBwvwI8X/FXXvHFlH4x+2toE1vJJ5kmnxwox25Q71QH9a+jNTjt5dOuo77H2V4mWbLbRsIO7ntxmuG8feKD8KPhhbX/wBkGq/YFt7PZ5nkb+ibs4bHTOOaPht4vPxV+HN1qBsv7L+1Gez8vzfP28Y3ZwuevSgDzz/hBP2f/wDnrpP/AIOZv/jtZngfWvHFp8VtP0LQUuj8NIrhorVktFeH7MEJXE5UsRnvuz71nf8ADJC/9Dmf/BX/APbq+i/Anh7/AIRXwfpOhfaftX2CAQ+ds2b8d9uTj8zQB83/ALXnhXXte8ZaNPoukX1/DHYlHe3hZwrbycHFTfDO08bfEfWv7B+LunX9z4aigM0cc1oLRRMuAnzxqrHgtxmvQ/jZ8bD8MddsdOGgjU/tVv5/mfbPJ2/MRjGxs9K6T4t/EU/D7wXba+NM/tDzpo4vI8/ysblJzu2t0x6UAdL4f0XRfA/hlNP0uNbDR7JXkAeVmEYJLMSzEnGSTya8F/aL+M17oraD/wAK68TWTCYT/a/s6w3GMbNmdwbHVq9BXxh/wnn7P+reIjZfYften3Y+z+b5u3YXT72BnO3PTvXwDQB+mnw/1C51bwRoWoX8nm3dzZxTSvtC7mZQScDgfhW/XzZ8Avjidd1Tw54HGgCDbbGD7b9s3Z8qInOzYOu3+9xmvpOgD//S+qGpKVqSgAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACmXdtDeW0lvdRJNBIpV43XKsD1BHcU+nUAc1/wAIF4S/6FrR/wDwET/Ck/4QHwl/0LWj/wDgGn+FdNRQBzP/AAgPhL/oWtH/APANP8KP+EB8Jf8AQtaP/wCAif4V01FAEFhZ22n2cVrYwRW9tENscUShVUegA6VQ1jw5outTRy6vpVjfSRrtRriBZCo9BkVrUUAY2k+FtB0e6+06Vo2n2dxtKeZBbqjYPUZA6U3U/CXh7VbxrvU9F067uWADSz26uxA4HJFbdFAHNf8ACBeEv+ha0f8A8A0/wqxp3hDw5pl7Hd6doem2t1HnZNDbIjrkEHBAz0JH41u0UAY+reGNC1i5W41XSLC9nVdokngV2A9MkVZ1fRtN1mBINWsba9hRtypcRh1B9cGr9FAFbTrC00yzjtNPt4ra1jyEiiQKq5OTgDpyTVmiigCpqumWOrWhtdUtILu2JDGKdA6kjocGk0nS7DSLT7LpVnb2dtuLeVBGEXJ6nAq5RQAUUUUAZOseG9E1qZJtX0mxvZUXar3ECuVHoCRVjVNH07VrRbXU7G2u7ZSGWKeMOoI6HBq9RQBRtdH0610s6bbWNtFp5VlNskYEeGySNvTnJ/Osj/hAvCX/AELWj/8AgIn+FdLRQBh6b4R8O6XeJd6bomm2t1HnZLDbojLkYOCB6E1uUUUAf//T+qGpKVqSgAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACnU2nUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAf/9T6oakpWqCS5giJEssaY4O5gKAJqKajq6hkYMp5BByDTZJo4sea6pkE/McdKAJKKjhmjmXdDIki5xlTmpKACiiigAooooAKKKKACiiigAooooAKKKKACiio55oreJpJ5EijXq7tgD8aAJKKjgmiuIllgkSWNujowYH8RUlABRRRQAU6m06gAoqrfXTWzQbVBEj7SScAcGoYNRV5mWR7cIq7i6S7gOcc8CgDQoqut7auwVLiJmPAAcc1S/tRgjlhAhVmXbJLtJwfbNAGrRVSa78u1hmK4DlQQATjP0qO9vvJhSSMfK2fvKR0+uMUAX6Kx4dWke3kkKJuVRgdsk465xjNTW+omWQfuj5TMFVsjqRQBpUVWMl1u4gjK56+b/8AWqpe6p9nmeMRlipQZxxyeTmgDUorKTVC8Vo2I1M2Qdx6Y9PxpI9ULwyODC20RkbTnG445+lAGtRWTY6o9zMiFUAZtp9ehOevt+tRf2xN9oMP2dPM6BN/JPWgDbooqnqF41p5Z8pnQk7iMcAKT6+1AFyis2XUnWCeRICTGu4AnqMkds/3TSW2ovJciJkP/fBXtmgDTorMj1Mh5BcQSIEAzhc4z/kU281KSC6kjWMEKQAdregP9elAGrRWXJqUqWCXHlLy205O3Hzbeh5q3Z3P2nf8oXaccNmgCzRRRQB//9X6oasFoZI9RvZUEnzsoHlwg9B/tdfqK3mrHutWe3vZYGtmIGwRtuA3EmgB2m21z9ggH2iSEheUMa5FQ31tN/aFpIWeVo0kJZYgW5xj2/CorzXJ4VjdbbEbRNJknJJHbt61PPqtxFZpOLUspYqxDABfmwOp70wJ9IWQPdtKJBukBBdApPygdBxWlWRdauYjHtt5AfN2SKxGVG3OeDz1FJbas8q3rDyJVt8co5GeMk8/h+tIDYorK0fU3vwgeJVbyw7EMe/sR9a1aACiiigAooooAKKKKACiiigAooooAK+UfjxqzeJfi7d+GdUdP7I06xxBDLc+TGbiSMMJDyN2NwGM8Yzg8g/VtfLnhLwnrfjrxJrEviW38i9W/S4nt5iFeO0lUNHgY5OAw9sYrOq5qPubnXg6VGrU5a0+Vd7FX4HasPDXxhsvDWjsq6PqVjtnhjuhOguI4ixkzk7clSO2c9B0HvvjTxHqdnrGmaD4btrefV79Hl8y5YiKCJMZdscnJOABXk3xL8IjwLqXhaTwFBdT6y9287wAhmkgiTdJgY44IH44r0XxwbrRfGuh+KksLq906G1mtLpbZN8kIYgq+3qRkYOKdLn5bT3IxMaMZfuZNrzVv1C08ZaroOqXemeN4LQOllJfW93YltkyJ99dp5DDj61QPifx2ugf8JQ2m6T/AGT5f2k6cJG+0CHrnf8Ad3Y5xXFyTa74y8XSJdw3j6dLZ3ljp19Jp7QBmlUELIOwGMbu9W/EXinX5fBth4f0nStTg1mG2Nle6fJYNIky7Au5ZRwMYJGOua0Oc9y0m/h1TTLW/tSTBcxLKhIwcMMirtcz8OGU+BdEVUmTy7VImWaMxuGX5TlT05BrpqQFa6tvPlgfKgxMWBK5PQjj0oitnW482WXzPl2gbcd6s0UAJgVSjsXigaOOZUDFidsYxyTV6igClJaTMkSLOqrHtIzHnkD6027spblEV51BUnJCY4I+tX6KAMtNLYCQGfIbBB28jDbu5OamWw2mDDj931O3luuP5+lXqKAK3kT/APP2/wD3wv8AhVe503zmdvNAZipJ2+hB9fbtitGigDMGlf6PBF5x/dH7wXkj060p007nKygZ27dwLYwwPOTz09q0qKAM+HT5I5lczhlDb9uzvtI6596gGipv3ea3TBHO38s1r0UARRLIskhZ8ocbVx09ahv7RrrAEgQBSOVz14Pf0z+dW6KAMx9LZ4J42mVvMXaMp93lj68/ep8OnGG4EscoXA2ldgxjsB6f1rQooAz5NO3qMyAyE5eQry3Tgc8dBTLjS/PuDKzrlm3N8nJHHHXpxWnRQBm/2a32eKLzU2puOPL45J7Z9DipI7OaG3eKK4OScq7LlvfJ71eooARchQCcnuaWiigD/9b6oasq60kXEzSNPIrFg42gcEYx19h+prVakoAyf7EhLRlnYlYzGWCgMwPXJx/KprfTVhWFGleSOL7qNjHoM/Qf49a0KKAMsaPEY41kdmCyeZ8o2/MAAuMdMACpW0/dbzRtMxMsnmMcAZ6cfTgVfooAo2OnrZyu8crt5nLhgPmPr7d+BxV6iigAooooAKKKKACiiigAooooAKKKKAErA1bwrZajq8eqGe7ttRjTykntpdjBP7p7MPYgiugoqZRUtxptbHP6V4VstP1d9V8+8utRePymnuZd7FP7o4wo9gBW/S0URio7A23uFJS0VQgp1Np1ABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFAH//1/qhqSlIzRigBKKXFGKAEopcUYoASilxRigBKKXFGKAEopcUYoASilxRigBKKXFGKAEopcUYoASilxRigBKKXFGKAEopcUYoASnUmKWgAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigD//Z
"



