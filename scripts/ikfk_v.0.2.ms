--Maxscript
--author:Cz
--E-Mail:hsl2r101@sina.com
--一键IK/FK创建工具 0.1

--依次选择父级骨骼(肩胛骨)-大臂-小臂-手后创建
--标准情况下,骨骼FrontFin指向关节外侧

fr = newRolloutFloater "Ikfk_1.0" 180 180

--创建层级函数
fn newLayer layerName =
(
	if ( layerManager.getLayerFromName ( layerName ) == undefined )
	then return layerManager.newLayerFromName ( layerName ) ;
	else	return layerManager.getLayerFromName ( layerName ) ;
)

--骨骼拷贝函数  
--参数含义:复制基础Node 前缀名称 偏移 尺寸修改
--示例:copyBone boneBase "upr_" 20
fn copyBone boneBase perfix sizefix =
(
	--拷贝骨骼
	boneCopy = copy boneBase ;
	
	--加上前缀命名拷贝骨骼
	boneCopy.name = perfix + boneBase.name ;
	
	--修改复制骨骼大小
	boneCopy.width += sizefix ;
	boneCopy.height += sizefix ;

	boneCopy.transform = boneBase.transform ;
	boneCopy.parent = undefine ;

	return boneCopy ;
	--自身空间偏移调整 目前函数中暂不使用
	--in coordsys local move boneCopy position
)

--旋转函数
fn RotatePivotOnly obj rotation =
( 
	local RotValInv = inverse ( rotation as quat )
	animate off in coordsys local obj.rotation *= RotValInv
	obj.objectoffsetrot *= RotValInv
	obj.objectoffsetpos *= RotValInv
)

--创建控制器方法
fn creatPositionCon boneBase conLayer =
(
	posCon = point size:10 centermarker:false axistripod:false cross:false box:true wirecolor:[28, 28, 177] ;
	posCon.transform = boneBase.transform ;
	posCon.name = boneBase.name + "_PosCon" ;
	conLayer.addnode posCon ;

	posCtrl = Position_Constraint();
	boneBase.pos.controller = posCtrl ;
	posConstraintInterface = posCtrl.constraints ;
	posConstraintInterface.appendTarget posCon 100.0 ;

	return posCon ;
)

fn creatRotationCon boneBase conLayer =
(
	rotateCon = point size:5 centermarker:false axistripod:false cross:false box:true wirecolor:[0, 197, 0] ;
	rotateCon.transform = boneBase.transform
	rotateCon.name = boneBase.name + "_RotateCon" ;
	conLayer.addnode rotateCon ;

	rotaCtrl = Orientation_Constraint ();
	boneBase.rotation.controller = rotaCtrl ;
	rotaConstraintInterface = rotaCtrl.constraints ;
	rotaConstraintInterface.appendTarget rotateCon 100.0 ;

	return rotateCon ;
)

fn creatBaseCon boneBase conLayer =
(
	baseCon = Circle radius:10 pos:[0, 0, - ( boneBase.length ) * 0.5] ;
	RotatePivotOnly baseCon ( EulerAngles 0 90 0 ) ;
	baseCon.pivot =[0, 0, 0] ;
	convertToSplineShape baseCon ;
	baseCon.name = boneBase.name + "_BaseCon" 
	baseCon.wirecolor = color 252 252 0 ;
	baseCon.transform = boneBase.transform ;
	conLayer.addnode baseCon ;

	return baseCon ;
)

--冻结变换方法
fn FreezeTransform item = 
( 
	local CurObj = item	

	if classof CurObj.rotation.controller != Rotation_Layer do
	(
		CurObj.rotation.controller = Euler_Xyz() 
		CurObj.rotation.controller = Rotation_list() 
		CurObj.rotation.controller.available.controller = Euler_xyz() 
		CurObj.rotation.controller.setname 1 "Frozen Rotation" 
		CurObj.rotation.controller.setname 2 "Zero Euler XYZ" 
		CurObj.rotation.controller.SetActive 2 
	)
	if classof CurObj.position.controller != Position_Layer do
	(
		CurObj.position.controller = Bezier_Position() 
		CurObj.position.controller = position_list() 
		CurObj.position.controller.available.controller = Position_XYZ() 
		CurObj.position.controller.setname 1 "Frozen Position" 
		CurObj.position.controller.setname 2 "Zero Pos XYZ" 
		CurObj.position.controller.SetActive 2 
		CurObj.Position.controller[2].x_Position = 0
		CurObj.Position.controller[2].y_Position = 0
		CurObj.Position.controller[2].z_Position = 0
	)
)

--模型塌陷工具
rollout model "Ikfk"
(
	groupBox 'grp1' "说明" pos:[6, 15] width:150 height:75 align:#left
	label 'lbl1' "依次选择大臂(大腿)-小臂(小退)-手掌(脚掌)-任意手掌(脚掌)子物体创建" pos:[16, 35] width:128 height:38 align:#left
	button hit "Creat" pos:[47, 101] width:63 height:26 align:#left
	on hit pressed do (
		--收集基础骨骼数组
		baseBoneLayer = newLayer "baseBone" ;
		baseBone_Dispaly = newLayer "baseBone_Display" ;
		baseBone_Dispaly.setParent baseBoneLayer ;
		baseBone_Dispaly.ishidden = true ;

		baseConLayer = newLayer "baseCon" ;
		posConLayer = newLayer "posCon" ;
		rotateConLayer = newLayer "rotateCon" ;
		controllerLayer = newLayer "controllerLayer" ;
		baseConLayer.setParent controllerLayer ;
		posConLayer.setParent controllerLayer ;
		rotateConLayer.setParent controllerLayer ;

		baseBoneArray = for i in $selection collect ( i ) ;

		boneUpperArm = baseBoneArray[1] ;
		baseBone_Dispaly.addnode boneUpperArm ;

		boneForearmArm = baseBoneArray[2] ;
		baseBone_Dispaly.addnode boneForearmArm ;

		boneHand = baseBoneArray[3] ;
		baseBoneLayer.addnode boneHand ;
		boneHand.boxmode = on ;
		
		boneHand_end = baseBoneArray[4] ;
		baseBoneLayer.addnode boneHand_end ;
		boneHand_end.boxmode = on ;
		
		--IK骨骼部分
		--创建IK骨骼层级
		ikLayer = newLayer "ikBone" ;
		ik_Display = newLayer "ik_Display" ;
		ik_Display.setParent ikLayer ;
		ik_Display.ishidden = true ;

		--增加helper层级
		helpsLayer = newLayer "helps" ;
		helpsLayer.ishidden = true ;

		--创建ik/fk骨骼链的挂载父级
		helper_clavicle = point size:20 centermarker:false axistripod:false cross:false box:true wirecolor:[28, 28, 177] ;
		helper_clavicleChild = point size:10 centermarker:false axistripod:false cross:false box:true wirecolor:[28, 28, 177] ;
		
		helper_clavicle.transform = boneUpperArm.transform ;
		helper_clavicleChild.transform = boneUpperArm.transform ;

		--约束位移
		posCtrl = Position_Constraint();
		helper_clavicleChild.pos.controller = posCtrl ;
		posConstraintInterface = posCtrl.constraints ;
		posConstraintInterface.appendTarget helper_Clavicle 100.0 ;

		--约束旋转
		rotaCtrl = Orientation_Constraint ();
		helper_clavicleChild.rotation.controller = rotaCtrl ;
		rotaConstraintInterface = rotaCtrl.constraints ;
		rotaConstraintInterface.appendTarget helper_Clavicle 100.0 ;

		if ( boneUpperArm.parent != undefined )
		then (
			boneClavicle = boneUpperArm.parent ;
			helper_clavicle.parent = boneClavicle ;
			baseBoneLayer.addnode boneClavicle ;
		)

		helpsLayer.addnode helper_clavicle ;
		helpsLayer.addnode helper_clavicleChild ;

		boneUpperArm_ik = copyBone boneUpperArm "ik_" -2 ;
		boneUpperArm_ik.wirecolor = color 8 8 136 ;
		boneUpperArm_ik.parent = helper_clavicleChild ;
		boneUpperArm_ik.boxmode = on
		ik_Display.addnode boneUpperArm_ik ;
		FreezeTransform boneUpperArm_ik ;

		boneForearmArm_ik = copyBone boneForearmArm "ik_" -2 ;
		boneForearmArm_ik.wirecolor = color 8 8 136 ;
		boneForearmArm_ik.parent = boneUpperArm_ik ;
		boneForearmArm_ik.boxmode = on
		ik_Display.addnode boneForearmArm_ik ;
		FreezeTransform boneForearmArm_ik ;

		boneHand_ik = copyBone boneHand "ik_" -2 ;
		boneHand_ik.wirecolor = color 8 8 136 ;
		boneHand_ik.parent = boneForearmArm_ik ;
		boneHand_ik.boxmode = on
		ik_Display.addnode boneHand_ik ;
		FreezeTransform boneHand_ik ;

		boneHandEnd_ik = copyBone boneHand_end "ik_" -2 ;
		boneHandEnd_ik.wirecolor = color 8 8 136 ;
		boneHandEnd_ik.parent = boneHand_ik ;
		boneHandEnd_ik.boxmode = on
		ik_Display.addnode boneHandEnd_ik ;
		FreezeTransform boneHandEnd_ik ;

		--架设HI_ik
		armIK = iksys.ikchain boneUpperArm_ik boneHand_ik "IKHISolver" ;
		armIK.name = boneUpperArm.name + "_ik" ;
		armIK.transform = boneHand_ik.transform ;
		ik_Display.addnode armIK ;

		--创建极向物体
		ik_target = Sphere radius:2.5 smooth:on segs:4 wirecolor:[8, 8, 136] ;
		ik_target.transform = boneForearmArm_ik.transform ;
		ik_target.name = armIK.name + "_target" ;
		ikLayer.addnode ik_target ;

		--设定极向量物体
		armIK.transform.controller.VHTarget = ik_target ;
		in coordsys local move ik_target [0, 20, 0] ;

		helperElbow = point size:5 centermarker:false axistripod:false cross:false box:true wirecolor:[8, 8, 136] ;
		helperElbow.Box = off;
		helperElbow.transform=boneForearmArm.transform;

		helperElbowPosCtrl =helperElbow.pos.controller =Position_Constraint();
		helperElbowPosCtrlInterface = helperElbowPosCtrl.constraints ;
		helperElbowPosCtrlInterface.appendTarget boneForearmArm_ik 100.0 ;

		helperElbowRotaCtrl =helperElbow.rotation.controller =LookAt_Constraint ();
		helperElbowRotaCtrl.viewline_length_abs = off;
		helperElbowRotaCtrlInterface = helperElbowRotaCtrl.constraints ;
		helperElbowRotaCtrlInterface.appendTarget ik_target 100.0 ;

		--增加手部ik
		--架设HI_ik
		handIK = iksys.ikchain boneHand_ik boneHandEnd_ik "IKHISolver" ;
		handIK.name = boneHand.name + "_ik" ;
		handIK.transform = boneHandEnd_ik.transform ;
		ik_Display.addnode handIK ;

		--创建极向物体
		handIk_target = Sphere radius:2.5 smooth:on segs:4 wirecolor:[8, 8, 136] ; 
		handIk_target.transform = boneHandEnd_ik.transform ;
		handIk_target.name = handIK.name + "_target" ;
		ikLayer.addnode handIk_target ;

		--设定极向量物体
		handIK.transform.controller.VHTarget = handIk_target ;
		in coordsys local move handIk_target [0, 10, 0] ;

		helperWrist= point size:5 centermarker:false axistripod:false cross:false box:true wirecolor:[8, 8, 136] ;
		helperWrist.transform=boneHand.transform;
		helperWrist.Box = off;

		helperWristPosCtrl =helperWrist.pos.controller =Position_Constraint();
		helperWristPosCtrlInterface = helperWristPosCtrl.constraints ;
		helperWristPosCtrlInterface.appendTarget boneHand_ik 100.0 ;

		helperWristRotaCtrl =helperWrist.rotation.controller =LookAt_Constraint ();
		helperWristRotaCtrl.viewline_length_abs = off;
		helperWristRotaCtrlInterface = helperWristRotaCtrl.constraints ;
		helperWristRotaCtrlInterface.appendTarget handIk_target 100.0 ;

		--设置ik父级物体
		baseCon = Circle radius:10 pos:[0, 0, -boneHand.length*0.5] ;
		RotatePivotOnly baseCon ( EulerAngles 0 90 0 ) ;
		baseCon.pivot =[0, 0, 0]
		convertToSplineShape baseCon ;
		
		baseCon.name = boneHand.name + "_BaseCon" 
		baseCon.wirecolor = color 252 252 0 ;
		baseCon.transform = boneHand.transform ;
		baseConLayer.addnode baseCon ;

		armIK.parent = baseCon ;
		handIK.parent = baseCon ;
		ik_target.parent = baseCon ;
		handIk_target.parent = baseCon ;

		--计算距离
		exposeTmik = ExposeTm();
		exposeTmik.name = "exposeTmik_" + armIK.name ;
		exposeTmik.transform = boneUpperArm_ik.transform ;
		exposeTmik.parent = boneUpperArm_ik ;
		ik_Display.addnode exposeTmik ;

		armbegin = point size:5 centermarker:false axistripod:false cross:false box:true wirecolor:[8, 8, 136] ;
		armbegin.transform = boneUpperArm_ik.transform ;
		armbegin.parent = helper_clavicleChild ;
		ik_Display.addnode armbegin ;

		exposeTmik.useParent = off ;
		exposeTmik.exposeNode = armbegin ;

		exposeTmik.localReferenceNode = armIK ;

		ikBoneLength = boneUpperArm_ik.length + boneForearmArm_ik.length ;

		--创建新属性
		-- the_boneData = attributes boneData
		-- (
		-- 	parameters main rollout:params
		-- 	(
		-- 		hitPoints type: #float ui:hits default:10
		-- 		upperArmLength type: #float ui:upperArm default:100
		-- 		forearmArmLength type: #float ui:forearmArm default:100

		-- 	)
		-- 	rollout params "Weapon Parameters"
		-- 	( 
		-- 		spinner hits "Length" type: #float
		-- 		spinner upperArm "upperArmLength" type: #float
		-- 		spinner forearmArm "forearmArmLength" type: #float

		-- 	)
		-- )

		--创建转换挂载
		--增加属性至物体上
		-- CustAttributes.add boneHand the_boneData ;

		-- boneHand.hitPoints=ikBoneLength;
		-- boneHand.upperArmLength=boneUpperArm_ik.length;
		-- boneHand.forearmArmLength=boneForearmArm_ik.length;

		b = boneUpperArm_ik.length as string ;
		c = boneForearmArm_ik.length as string ;
		d = ( boneUpperArm_ik.length + boneForearmArm_ik.length ) as string ;
		a = "if Distance>(" + d + ") then ((Distance-" + d + ")*" + b + "/(" + d + "))else(0)" ;
		f = "if Distance>(" + d + ") then ((Distance-" + d + ")*" + c + "/(" + d + "))else(0)" ;

		paramWire.connect exposeTmik.baseObject[#Distance] boneForearmArm_ik.transform.controller.FK_Sub_Control.controller.Position.controller.Zero_Pos_XYZ.controller[#X_Position] a ;
		paramWire.connect exposeTmik.baseObject[#Distance] boneHand_ik.transform.controller.FK_Sub_Control.controller.Position.controller.Zero_Pos_XYZ.controller[#X_Position] f ;


		-- paramWire.connect exposeTmik.baseObject[#Distance] boneForearmArm_ik.transform.controller.FK_Sub_Control.controller.Position.controller.Zero_Pos_XYZ.controller[#X_Position] "if Distance>boneHand.hitPoints then ((Distance-boneHand.hitPoints)*boneHand.upperArmLength/boneHand.hitPoints)else(0)";
		-- paramWire.connect exposeTmik.baseObject[#Distance] boneHand_ik.transform.controller.FK_Sub_Control.controller.Position.controller.Zero_Pos_XYZ.controller[#X_Position] "if Distance>boneHand.hitPoints then ((Distance-boneHand.hitPoints)*boneHand.forearmArmLength/boneHand.hitPoints)else(0)";

		--手部ik
		--暂不处理

		--FK骨骼部分
		--创建FK骨骼层级
		fkLayer = newLayer "fkBone" ;
		fk_Display = newLayer "fk_Display" ;
		fk_Display.setParent fkLayer ;
		fk_Display.ishidden = true ;

		--复制出fk骨骼
		boneUpperArm_fk = copyBone boneUpperArm "fk_" 2 ;
		boneUpperArm_fk.wirecolor = color 255 169 0 ;
		boneUpperArm_fk.parent = helper_clavicleChild ;
		boneUpperArm_fk.boxmode = on
		fkLayer.addnode boneUpperArm_fk ;

		boneForearmArm_fk = copyBone boneForearmArm "fk_" 2 ;
		boneForearmArm_fk.wirecolor = color 255 169 0 ;
		boneForearmArm_fk.parent = boneUpperArm_fk ;
		boneForearmArm_fk.boxmode = on
		fkLayer.addnode boneForearmArm_fk ;

		boneHand_fk = copyBone boneHand "fk_" 2 ;
		boneHand_fk.wirecolor = color 255 169 0 ;
		boneHand_fk.parent = boneForearmArm_fk ;
		boneHand_fk.boxmode = on
		fk_Display.addnode boneHand_fk ;

		--添加基础骨骼的约束关系
		--主要是大小臂

		upperArmRotaCtrl = Orientation_Constraint ();
		boneUpperArm.rotation.controller = upperArmRotaCtrl ;
		boneUpperArmrotaConstraintInterface = upperArmRotaCtrl.constraints ;
		boneUpperArmrotaConstraintInterface.appendTarget boneUpperArm_ik 100.0 ;
		boneUpperArmrotaConstraintInterface.appendTarget boneUpperArm_fk 0.0 ;

		forearmArmPosCtrl = Position_Constraint();
		boneforearmArm.pos.controller = forearmArmPosCtrl ;
		posConstraintInterface = forearmArmPosCtrl.constraints ;
		posConstraintInterface.appendTarget boneForearmArm_ik 100.0 ;
		posConstraintInterface.appendTarget boneForearmArm_fk 100.0 ;

		forearmArmRotaCtrl = Orientation_Constraint ();
		boneforearmArm.rotation.controller = forearmArmRotaCtrl ;
		boneforearmArmrotaConstraintInterface = forearmArmRotaCtrl.constraints ;
		boneforearmArmrotaConstraintInterface.appendTarget boneForearmArm_ik 100.0 ;
		boneforearmArmrotaConstraintInterface.appendTarget boneForearmArm_fk 0.0 ;

		boneHandPosCtrl = Position_Constraint();
		boneHand.pos.controller = boneHandPosCtrl ;
		posConstraintInterface = boneHandPosCtrl.constraints ;
		posConstraintInterface.appendTarget boneHand_ik 100.0 ;
		posConstraintInterface.appendTarget boneHand_fk 100.0 ;

		boneHandRotaCtrl = Orientation_Constraint();
		boneHand.rotation.controller = boneHandRotaCtrl ;
		boneHandrotaConstraintInterface = boneHandRotaCtrl.constraints ;
		boneHandrotaConstraintInterface.appendTarget boneHand_ik 100.0 ;
		boneHandrotaConstraintInterface.appendTarget boneHand_fk 100.0 ;
		
		--创建新属性
		ikfkData = attributes ikfkSwitch
		(
			parameters main rollout:params
			(
				ikfk type:#float ui:ikfk default:10
			)
			
			rollout params "ik----fk"
			(
				slider ikfk "ik/fk" type: #float Range:[0, 100, 0]
			)
		)

		--创建转换挂载
		--增加属性至物体上
		CustAttributes.add boneHand ikfkData ;

		--设置上下臂旋转约束的参数关联
		paramWire.connect boneHand.baseObject.ikfkSwitch[#ikfk] boneUpperArm.rotation.controller[#Orientation_Weight_0] "100-ikfk" ;
		paramWire.connect boneHand.baseObject.ikfkSwitch[#ikfk] boneUpperArm.rotation.controller[#Orientation_Weight_1] "ikfk" ;
		paramWire.connect boneHand.baseObject.ikfkSwitch[#ikfk] boneforearmArm.pos.controller[#Position_Weight_0] "100-ikfk" ;
		paramWire.connect boneHand.baseObject.ikfkSwitch[#ikfk] boneforearmArm.pos.controller[#Position_Weight_1] "ikfk" ;

		paramWire.connect boneHand.baseObject.ikfkSwitch[#ikfk] boneforearmArm.rotation.controller[#Orientation_Weight_0] "100-ikfk" ;
		paramWire.connect boneHand.baseObject.ikfkSwitch[#ikfk] boneforearmArm.rotation.controller[#Orientation_Weight_1] "ikfk" ;
		paramWire.connect boneHand.baseObject.ikfkSwitch[#ikfk] boneHand.pos.controller[#Position_Weight_0] "100-ikfk" ;
		paramWire.connect boneHand.baseObject.ikfkSwitch[#ikfk] boneHand.pos.controller[#Position_Weight_1] "ikfk" ;

		paramWire.connect boneHand.baseObject.ikfkSwitch[#ikfk] boneHand.rotation.controller[#Orientation_Weight_0] "100-ikfk" ;
		paramWire.connect boneHand.baseObject.ikfkSwitch[#ikfk] boneHand.rotation.controller[#Orientation_Weight_1] "ikfk" ;
	)
)

addRollout model fr