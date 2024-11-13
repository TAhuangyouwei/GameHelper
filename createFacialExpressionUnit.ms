-- ����һ��������������������������ѡ����boneObject����ָ����������
fn createBaseControllers boneObject:undefined = 
(
    -- ����ṩ�˹���������ʹ�ù����Ŀ��Ⱥͳ��ȣ�����ʹ��Ĭ��ֵ
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
				
	

    -- �������������
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


    -- �������������
    local childVirtualObject = point box:on cross:off size:size wirecolor:red 
	childVirtualObject.name = replace myBoneInstance.name 1 2 "HP"

    -- �������ƶ���
    local controlObject = circle radius:radius wirecolor:controlObjectColor pos:[length,0,0]
	controlObject.name = replace myBoneInstance.name 1 2 "CON"

    -- ���û���ṩ���������򴴽�һ����������


    -- ���ش����Ķ�������
    return #(parentVirtualObject, childVirtualObject, controlObject, myBoneInstance )
)



-- ���ÿ�������״
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


-- �������Ӳ㼶
fn setupHierarchy parentVirtualObject childVirtualObject controlObject boneObject = 
(
    -- ���������Ĳ㼶��ϵ
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




-- ����λ�ú���ת������
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
				-- ����boneObject��λ�ÿ�����
				boneObject.pos.controller = PositionList()
				boneObject.pos.controller.Available.controller = Position_Constraint ()
				local bonePosControllerList = boneObject.pos.controller
				bonePosControllerList.SetActive 2
				bonePosControllerList[2].constraints.appendTarget controlObject 50.0

				-- ����boneObject����ת������
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
				
				
				-- ����boneObject��λ�ÿ�����
				boneObject.pos.controller = PositionList()
				boneObject.pos.controller.Available.controller = Position_Constraint ()
				local bonePosControllerList = boneObject.pos.controller
				bonePosControllerList.SetActive 2
				bonePosControllerList[2].constraints.appendTarget controlObject 50.0

				-- ����boneObject����ת������
				boneObject.rotation.controller = RotationList()
				boneObject.rotation.controller.Available.controller = Orientation_Constraint ()
				local boneRotControllerList = boneObject.rotation.controller
				boneRotControllerList.SetActive 2
				boneRotControllerList[2].constraints.appendTarget controlObject 50.0
			)
			default:
			(
				-- ����childVirtualObject��λ�ÿ�����
				childVirtualObject.pos.controller = position_list()	
				for i = 1 to 10 do 
				(
					childVirtualObject.pos.controller.Available.controller = Position_XYZ ()
				)
				
				
				-- ����childVirtualObject����ת������
				childVirtualObject.rotation.controller = rotation_list()
				for i = 1 to 10 do 
				(
					childVirtualObject.rotation.controller.Available.controller = Euler_XYZ ()
				)
					
				-- ����boneObject��λ�ÿ�����
				boneObject.pos.controller = PositionList()
				boneObject.pos.controller.Available.controller = Position_Constraint ()
				local bonePosControllerList = boneObject.pos.controller
				bonePosControllerList.SetActive 2
				bonePosControllerList[2].constraints.appendTarget controlObject 50.0

				-- ����boneObject����ת������
				boneObject.rotation.controller = RotationList()
				boneObject.rotation.controller.Available.controller = Orientation_Constraint ()
				local boneRotControllerList = boneObject.rotation.controller
				boneRotControllerList.SetActive 2
				boneRotControllerList[2].constraints.appendTarget controlObject 50.0
			)
		)
			-- ����controlObject��λ�ÿ�����
			controlObject.Position.controller = position_list ()
			controlObject.Position.controller.Available.controller = Position_XYZ ()
			controlObject.Position.controller[1].controller = Bezier_Position ()
			listctrl.setname controlObject.Position.controller 1 "Frozen Position"
			listctrl.setname controlObject.Position.controller 2 "Zero Pos XYZ"
			controlObject.position.controller.SetActive 2 

			-- ����controlObject����ת������
			controlObject.rotation.controller = Rotation_list ()
			controlObject.rotation.controller.Available.controller = Euler_XYZ ()
			listctrl.setname controlObject.rotation.controller 1 "Frozen Rotation"
			listctrl.setname controlObject.rotation.controller 2 "Zero Euler XYZ"
			controlObject.rotation.controller.SetActive 2 
	
		
	)


)

-- ����������
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
    setupHierarchy parentVirtualObject childVirtualObject controlObject myBoneInstance	  -- �������Ӳ㼶
    setupPositionAndRotationControllers childVirtualObject controlObject myBoneInstance   -- ����λ�ú���ת������
	nameControllers childVirtualObject.pos.controller childVirtualObject.rotation.controller   -- ����������
    
)



-- ������
fn createFacialExpressionUnit = 
(
    boneObjects = for obj in selection where classof obj == BoneGeometry collect obj 

    if boneObjects.count == 0 then 
    (
        processBoneObject() -- ����Ĭ�������û�й�������
		
    )
    else
    (
        for Obj in boneObjects  do 
        (
            processBoneObject boneObject:Obj -- ����ÿһ����������
        )
    )
)





/*


1. createBaseControllers
���ܣ�����һ������������Ϳ�ѡ�Ĺ�������
�÷���createBaseControllers boneObject:undefined
������

boneObject (��ѡ)��ָ���Ĺ����������δ�ṩ������������һ���µĹ�������
����ֵ������һ�����飬���������������������󡢿��ƶ���͹���ʵ����
2. configureControllerShape
���ܣ����ÿ���������״��
�÷���configureControllerShape controlObject
������

controlObject��Ҫ���õĿ���������
����ֵ���ޣ�����ֱ���޸Ĵ���Ŀ��������󣩡�
3. setupHierarchy
���ܣ����������������������󡢿��ƶ���͹�������֮��Ĳ㼶��ϵ��
�÷���setupHierarchy parentVirtualObject childVirtualObject controlObject boneObject
������

parentVirtualObject�����������
childVirtualObject�����������
controlObject�����ƶ���
boneObject����������
����ֵ���ޣ�����ֱ���޸Ĵ���Ķ��󣩡�
4. setupPositionAndRotationControllers
���ܣ�Ϊ�������Ϳ��ƶ�������λ�ú���ת��������
�÷���setupPositionAndRotationControllers childVirtualObject controlObject boneObject
������

childVirtualObject�����������
controlObject�����ƶ���
boneObject����������
����ֵ���ޣ�����ֱ�����ÿ���������
5. nameControllers
���ܣ�Ϊλ�ú���ת������������
�÷���nameControllers posControllerList rotControllerList
������

posControllerList��λ�ÿ������б���
rotControllerList����ת�������б���
����ֵ���ޣ�����ֱ���޸Ŀ������б�����
6. processBoneObject
���ܣ�����һ�������������û�й�������ʱִ��Ĭ�ϲ�����
�÷���processBoneObject boneObject:undefined
������

boneObject (��ѡ)��Ҫ�����Ĺ����������δ�ṩ����ִ��Ĭ�ϲ�����
����ֵ���ޣ�����ֱ�Ӵ������󣩡�
7. createFacialExpressionUnit
���ܣ������沿������Ƶ�Ԫ����������������ѡ���Ĺ������󣬻���û��ѡ����������ʱ����Ĭ�Ͽ�������
�÷���createFacialExpressionUnit
�������ޡ�
����ֵ���ޣ�����ֱ�Ӵ��������еĶ��󣩡�



*/

