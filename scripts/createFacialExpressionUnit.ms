-- 定义一个函数来创建基础控制器，可选参数boneObject用于指定骨骼对象
fn createBaseControllers boneObject:undefined = 
(
    -- 如果提供了骨骼对象，则使用骨骼的宽度和长度；否则使用默认值
    local size = if boneObject != undefined then (boneObject.width + boneObject.length/5.0) else 1
    local length = if boneObject != undefined then boneObject.length else 2
	local controlObjectColor = if boneObject != undefined then boneObject.wirecolor else yellow

						
	local myBoneInstance  = if boneObject == undefined then
    (
        local b = BoneSys.createBone [0,0,0] [length,0,0] [0,0,1]
        b.width = b.height = 0.5
		b.name = "BN_01"
		b
    )
    else boneObject
	
	local radius = if boneObject != undefined then 
				(
					if (boneObject.length/10.0) >= boneObject.width then 
						(boneObject.length/10.0)
					else boneObject.width
					
				)
				else 0.5 
				
	

    -- 创建父虚拟对象
    local parentVirtualObject = point box:off cross:on size:size wirecolor:red 
	parentVirtualObject.name = replace myBoneInstance.name 1 2 "HpPar"
	
	if parentVirtualObject.name != "HpPar_Head_Root_M01" then 
	(
		parentVirtualObject.parent = $Hp_Head_Root_M01
		if parentVirtualObject.name == "HpPar_Eye_Pupil_L_01" then 
		(
			tempTransform = parentVirtualObject.transform
			lc = link_constraint()				
			parentVirtualObject.transform.controller = lc
			lc.key_mode = 0
			lc.addTarget $BN_Eye_L_01 0
			parentVirtualObject.transform = tempTransform
			
		)
		else if parentVirtualObject.name == "HpPar_Eye_Pupil_R_01" then 
		(
			tempTransform = parentVirtualObject.transform
			lc = link_constraint()				
			parentVirtualObject.transform.controller = lc
			lc.key_mode = 0
			lc.addTarget $BN_Eye_R_01 0
			parentVirtualObject.transform = tempTransform
		)
			
	)


    -- 创建子虚拟对象
    local childVirtualObject = point box:on cross:off size:size wirecolor:red 
	childVirtualObject.name = replace myBoneInstance.name 1 2 "HP"

    -- 创建控制对象
    local controlObject = circle radius:radius wirecolor:controlObjectColor pos:[length,0,0]
	controlObject.name = replace myBoneInstance.name 1 2 "CON"

    -- 如果没有提供骨骼对象，则创建一个骨骼对象


    -- 返回创建的对象数组
    return #(parentVirtualObject, childVirtualObject, controlObject, myBoneInstance )
)



-- 配置控制器形状
fn configureControllerShape controlObject =  
	(
    convertToSplineShape controlObject
    local temp1 = copy controlObject
    rotate temp1 (EulerAngles 90 0 0)
    local temp2 = copy controlObject
    rotate temp2 (EulerAngles 0 90 0)
    addAndWeld controlObject temp1 0.1
    addAndWeld controlObject temp2 0.1
)


-- 建立父子层级
fn setupHierarchy parentVirtualObject childVirtualObject controlObject boneObject = 
(
    -- 建立基本的层级关系
    childVirtualObject.parent = parentVirtualObject
    controlObject.parent = childVirtualObject
	if boneObject.name != "BN_Eye_R_01" and boneObject.name != "BN_Eye_L_01" then 
	(
		controlObject.pivot = childVirtualObject.pos
	)
	
	if classof boneObject != undefined do
	(
		parentVirtualObject.transform = boneObject.transform
		if boneObject.name == "BN_Head_Root_M01" then controlObject.parent = parentVirtualObject
	)
	
)




-- 配置位置和旋转控制器
fn setupPositionAndRotationControllers childVirtualObject controlObject boneObject=  
(
	
	if boneObject != undefined then 
	(
		case of 
		(
			(boneObject.name == "BN_Eye_L_01" or boneObject.name == "BN_Eye_R_01"):
			(
				boneObject.pos.controller = PositionList()
				boneObject.pos.controller.Available.controller = Position_Constraint ()
				boneObjectposlst = boneObject.pos.controller
				boneObjectposlst.SetActive 2
				boneObjectposlst[2].constraints.appendTarget childVirtualObject 50.0
				
				boneObject.rotation.controller = RotationList()
				boneObject.rotation.controller.Available.controller = LookAt_Constraint ()
				boneObjectrotlst = boneObject.rotation.controller
				boneObjectrotlst.SetActive 2
				boneObjectrotlst[2].constraints.appendTarget controlObject 50.0
				boneObjectrotlst[2].lookat_vector_length = 0
				boneObjectrotlst[2].upnode_world = off
				boneObjectrotlst[2].pickUpNode = childVirtualObject
				
				
			)
			
			(findString boneObject.name "BN_Eye_" != undefined ):
			(
				-- 配置boneObject的位置控制器
				boneObject.pos.controller = PositionList()
				boneObject.pos.controller.Available.controller = Position_Constraint ()
				local bonePosControllerList = boneObject.pos.controller
				bonePosControllerList.SetActive 2
				bonePosControllerList[2].constraints.appendTarget controlObject 50.0

				-- 配置boneObject的旋转控制器
				boneObject.rotation.controller = RotationList()
				boneObject.rotation.controller.Available.controller = Orientation_Constraint ()
				local boneRotControllerList = boneObject.rotation.controller
				boneRotControllerList.SetActive 2
				boneRotControllerList[2].constraints.appendTarget controlObject 50.0
				
				
			)
			
			(boneObject.name == "BN_Head_Root_M01"):
			(
				lc = link_constraint()				
				childVirtualObject.transform.controller = lc
				lc.key_mode = 0
				lc.addTarget boneObject 0
				childVirtualObject.transform = boneObject.transform
				
				
				-- 配置boneObject的位置控制器
				boneObject.pos.controller = PositionList()
				boneObject.pos.controller.Available.controller = Position_Constraint ()
				local bonePosControllerList = boneObject.pos.controller
				bonePosControllerList.SetActive 2
				bonePosControllerList[2].constraints.appendTarget controlObject 50.0

				-- 配置boneObject的旋转控制器
				boneObject.rotation.controller = RotationList()
				boneObject.rotation.controller.Available.controller = Orientation_Constraint ()
				local boneRotControllerList = boneObject.rotation.controller
				boneRotControllerList.SetActive 2
				boneRotControllerList[2].constraints.appendTarget controlObject 50.0
			)
			default:
			(
				-- 配置childVirtualObject的位置控制器
				childVirtualObject.pos.controller = position_list()	
				for i = 1 to 10 do 
				(
					childVirtualObject.pos.controller.Available.controller = Position_XYZ ()
				)
				
				
				-- 配置childVirtualObject的旋转控制器
				childVirtualObject.rotation.controller = rotation_list()
				for i = 1 to 10 do 
				(
					childVirtualObject.rotation.controller.Available.controller = Euler_XYZ ()
				)
					
				-- 配置boneObject的位置控制器
				boneObject.pos.controller = PositionList()
				boneObject.pos.controller.Available.controller = Position_Constraint ()
				local bonePosControllerList = boneObject.pos.controller
				bonePosControllerList.SetActive 2
				bonePosControllerList[2].constraints.appendTarget controlObject 50.0

				-- 配置boneObject的旋转控制器
				boneObject.rotation.controller = RotationList()
				boneObject.rotation.controller.Available.controller = Orientation_Constraint ()
				local boneRotControllerList = boneObject.rotation.controller
				boneRotControllerList.SetActive 2
				boneRotControllerList[2].constraints.appendTarget controlObject 50.0
			)
		)
			-- 配置controlObject的位置控制器
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
	
		
	)


)

-- 命名控制器
fn nameControllers posControllerList rotControllerList=  
(
	names = #("eyebrow_X","eyebrow_Y","zuoZuijiao_X","zuoZuijiao_Y","youZuijiao_X","youZuijiao_Y","upZuichun_X","upZuichun_Y","downZuichun_X","downZuichun_Y")
	if (classof posControllerList ==Position_List) and (classof rotControllerList == Rotation_List) then 
	(
		for i = 2 to 11 do 
		(
			local controllerIndex = i - 1
			posControllerList.setName i names[controllerIndex]
			rotControllerList.setName i names[controllerIndex]
		)
	)

)



fn processBoneObject boneObject:undefined = 
(
    local controllers = createBaseControllers boneObject:boneObject
    local parentVirtualObject = controllers[1]
    local childVirtualObject = controllers[2]
    local controlObject = controllers[3]
    local myBoneInstance  = controllers[4]

    configureControllerShape controlObject
    setupHierarchy parentVirtualObject childVirtualObject controlObject myBoneInstance	  -- 建立父子层级
    setupPositionAndRotationControllers childVirtualObject controlObject myBoneInstance   -- 配置位置和旋转控制器
	nameControllers childVirtualObject.pos.controller childVirtualObject.rotation.controller   -- 命名控制器
    
)



-- 主函数
fn createFacialExpressionUnit = 
(
    boneObjects = for obj in selection where classof obj == BoneGeometry collect obj 

    if boneObjects.count == 0 then 
    (
        processBoneObject() -- 处理默认情况，没有骨骼对象
		
    )
    else
    (
        for Obj in boneObjects  do 
        (
            processBoneObject boneObject:Obj -- 处理每一个骨骼对象
        )
    )
)





/*


1. createBaseControllers
功能：创建一组基础控制器和可选的骨骼对象。
用法：createBaseControllers boneObject:undefined
参数：

boneObject (可选)：指定的骨骼对象。如果未提供，则函数将创建一个新的骨骼对象。
返回值：返回一个数组，包含父虚拟对象、子虚拟对象、控制对象和骨骼实例。
2. configureControllerShape
功能：配置控制器的形状。
用法：configureControllerShape controlObject
参数：

controlObject：要配置的控制器对象。
返回值：无（函数直接修改传入的控制器对象）。
3. setupHierarchy
功能：建立父虚拟对象、子虚拟对象、控制对象和骨骼对象之间的层级关系。
用法：setupHierarchy parentVirtualObject childVirtualObject controlObject boneObject
参数：

parentVirtualObject：父虚拟对象。
childVirtualObject：子虚拟对象。
controlObject：控制对象。
boneObject：骨骼对象。
返回值：无（函数直接修改传入的对象）。
4. setupPositionAndRotationControllers
功能：为虚拟对象和控制对象配置位置和旋转控制器。
用法：setupPositionAndRotationControllers childVirtualObject controlObject boneObject
参数：

childVirtualObject：子虚拟对象。
controlObject：控制对象。
boneObject：骨骼对象。
返回值：无（函数直接配置控制器）。
5. nameControllers
功能：为位置和旋转控制器命名。
用法：nameControllers posControllerList rotControllerList
参数：

posControllerList：位置控制器列表。
rotControllerList：旋转控制器列表。
返回值：无（函数直接修改控制器列表）。
6. processBoneObject
功能：处理一个骨骼对象或在没有骨骼对象时执行默认操作。
用法：processBoneObject boneObject:undefined
参数：

boneObject (可选)：要处理的骨骼对象。如果未提供，则执行默认操作。
返回值：无（函数直接处理对象）。
7. createFacialExpressionUnit
功能：创建面部表情控制单元。处理场景中所有选定的骨骼对象，或在没有选定骨骼对象时创建默认控制器。
用法：createFacialExpressionUnit
参数：无。
返回值：无（函数直接处理场景中的对象）。



*/


