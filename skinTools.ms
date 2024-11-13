try(DestroyDialog myRollout)catch()

global state = off -- ����һ��ȫ�ֱ���state����ʼ��Ϊoff

global weapon = #("rdmobj002","rdmobj002","rdmobj112","Jian","rdmobj113")


-- ����Rollout����
rollout myRollout "Skin Tools" width:200 
(
	
	
	fn getUniqueSkinBonesNumber =
	(
		uniqueBones = #() -- ����һ���ռ������ڴ洢���صĹ����ڵ�
		for obj in selection do -- ������ǰѡ�е����ж���
		(
			if obj.modifiers[#Skin] != undefined then 
			(
				local skinMod = obj.modifiers[#Skin] -- ���ҵ�ǰ�����ϵ�Skin Modifier
				local boneNodes = skinOps.GetBoneNodes skinMod -- ��ȡ��ǰSkin Modifier�Ĺ����ڵ�
				for boneNode in boneNodes do -- ��������ڵ㲻�ڼ����У������ӵ�����
				(
					appendIfUnique uniqueBones boneNode
				)
				
			)
		)
		uniqueBones.count -- ���ض��ع����ڵ������
	)

	
	-- Ȩ��ת�ƺ���
	fn mergeVertexWeights skinMod vertexIndex fromBoneIndex toBoneIndex = (
		if skinMod != undefined and vertexIndex > 0 and fromBoneIndex > 0 and toBoneIndex > 0 then  (
			numWeights = skinOps.GetVertexWeightCount skinMod vertexIndex
			weightToTransfer = 0.0
			weightTargetBone = 0.0

			for i = 1 to numWeights do (
				tempBoneIndexId = skinOps.GetVertexWeightBoneID skinMod vertexIndex i
				if tempBoneIndexId == fromBoneIndex then  (
					weightToTransfer = skinOps.GetVertexWeight skinMod vertexIndex i
				) else if tempBoneIndexId == toBoneIndex then  (
					weightTargetBone = skinOps.GetVertexWeight skinMod vertexIndex i
				)
			)

			if weightToTransfer > 0 then  (
				skinOps.SetVertexWeights skinMod vertexIndex fromBoneIndex 0
				skinOps.SetVertexWeights skinMod vertexIndex toBoneIndex (weightTargetBone + weightToTransfer)
				skinOps.RemoveZeroWeights skinMod
			)
		)
	)


	
    -- ���Ӱ�ť
	spinner spWeight "Weight" range:[0,1,0.1] type:#float fieldwidth:100
    button btnSelect "ѡ�����Ӱ��ĵ�" width:180 height:25
    button btnIncreaseWeight "�Ӽ�Ȩ��" width:180 height:25
    button btnDecreaseWeight "����Ȩ��" width:180 height:25
	button btGetSkinBonesNumber "��Ƥ��������" width:180 height:25
	
	
	group "Ȩ�ؽ���"
	(
		button pb_1 "From Bone" across:3 width:60 height:25
		label lb "-->"  height:25
		button pb_2 "To Bone"  width:60 height:25	
		button btnTransferWeights "ת��Ȩ��" width:180 height:25
	)

	-- �洢ѡ�еĹ����ڵ�
	global bone1 = undefined
	global bone2 = undefined

	on pb_1 pressed do
	(
		skinMod = selection[1].skin

		bone1 = skinOps.GetSelectedBone skinMod
		
		pb_1.text = skinOps.GetBoneName skinMod bone1 1
	)

	on pb_2 pressed do
	(
		skinMod = selection[1].skin

		bone2 = skinOps.GetSelectedBone skinMod
		
		pb_2.text = skinOps.GetBoneName skinMod bone2 1
	)

	-- �������ת��Ȩ�ء���ťʱִ�еĲ���
	on btnTransferWeights pressed do
	(
		undo on 
		(
			-- ȷ������Ч�Ĺ����Ͷ���ѡ��
			if bone1 != undefined and bone2 != undefined then  (
				local skinMod = selection[1].modifiers[#Skin]
				local selectedVerts = skinOps.GetSelectedVertices skinMod  -- ��ȡѡ�ж������������

				for vertexIndex in selectedVerts do (
					mergeVertexWeights skinMod vertexIndex bone1 bone2
				)
			) else (
				messageBox "��ѡ�����������ڵ㣡"
			)
			
		)

	)
	

    -- ��ȡ��ǰ��Ƥ����
    local skinMod = modPanel.getCurrentObject()

    -- �������Select Vertices by Bone����ťʱִ�еĲ���
    on btnSelect pressed do
    (
		local skinMod = modPanel.getCurrentObject()
		max modify mode		
		subobjectLevel = 1
        if (classof skinMod == Skin) do
        (
            -- ѡ�е�ǰ����Ӱ��Ķ���
            skinOps.selectVerticesByBone skinMod
        )
    )
	
	
	-- �������Increase Weight����ťʱִ�еĲ���
	on btnIncreaseWeight pressed do
	(
		local skinMod = modPanel.getCurrentObject()
		if (classof skinMod == Skin) do
		(
			boneIndex = skinOps.GetSelectedBone skinMod -- ��ȡ��ǰѡ�еĹ�������
			-- �������Ѿ��ֶ���ͨ���ű�ѡ����һЩ����
			selectedVerts = skinOps.GetSelectedVertices skinMod  -- ��ȡѡ�ж������������
			
			for i in selectedVerts do
			(
				numWeights = skinOps.GetVertexWeightCount skinMod i  --��ȡi��ŵ�vertex�Ĺ�������
				
				for j = 1 to numWeights do 
				(					
					tempBoneIndexId = skinOps.GetVertexWeightBoneID skinMod i j --��ȡweight tool ���б��ֵĹ����� sort list ��ID 
					if tempBoneIndexId == boneIndex then 
					(
						weight = skinOps.GetVertexWeight skinMod i j
						newWeight = if (weight + ( spWeight.value / 10) ) < 1.0 then (weight + ( spWeight.value / 10)) else 1.0
						skinOps.SetVertexWeights skinMod i boneIndex newWeight
					)
						
					
				)				
				
			)
		)
	)




	
	
	on btnIncreaseWeight rightclick do
	(
		local skinMod = modPanel.getCurrentObject()
		if (classof skinMod == Skin) do
		(
			boneIndex = skinOps.GetSelectedBone skinMod -- ��ȡ��ǰѡ�еĹ�������
			-- �������Ѿ��ֶ���ͨ���ű�ѡ����һЩ����
			selectedVerts = skinOps.GetSelectedVertices skinMod  -- ��ȡѡ�ж������������

			for i in selectedVerts do
			(
				numWeights = skinOps.GetVertexWeightCount skinMod i  --��ȡi��ŵ�vertex�Ĺ�������
				
				for j = 1 to numWeights do 
				(					
					tempBoneIndexId = skinOps.GetVertexWeightBoneID skinMod i j 
					if tempBoneIndexId == boneIndex then 
					(
						weight = skinOps.GetVertexWeight skinMod i j
						newWeight = if (weight - ( spWeight.value / 10)) >= 0 then (weight - ( spWeight.value / 10)) else 0
						skinOps.SetVertexWeights skinMod i boneIndex newWeight
					)
						
					
				)				
				
			)
		)
	)
	

    -- �������Decrease Weight����ťʱִ�еĲ���
	-- ����ѡ�ж����Ȩ��
	on btnDecreaseWeight pressed do
	(
		local skinMod = modPanel.getCurrentObject()
		if (classof skinMod == Skin) do
		(
			boneIndex = skinOps.GetSelectedBone skinMod -- ��ȡ��ǰѡ�еĹ�������
			-- �������Ѿ��ֶ���ͨ���ű�ѡ����һЩ����
			selectedVerts = skinOps.GetSelectedVertices skinMod  -- ��ȡѡ�ж������������
			
			for i in selectedVerts do
			(
				numWeights = skinOps.GetVertexWeightCount skinMod i  --��ȡi��ŵ�vertex�Ĺ�������
				
				for j = 1 to numWeights do 
				(					
					tempBoneIndexId = skinOps.GetVertexWeightBoneID skinMod i j 
					if tempBoneIndexId == boneIndex then 
					(
						weight = skinOps.GetVertexWeight skinMod i j
						newWeight = if (weight * (( spWeight.value / 10)+1)) < 1.0 then (weight * (( spWeight.value / 10)+1)) else 1.0
						skinOps.SetVertexWeights skinMod i boneIndex newWeight
					)
						
					
				)				
				
			)
		)
	)
	
		on btnDecreaseWeight rightclick do
	(
		local skinMod = modPanel.getCurrentObject()
		if (classof skinMod == Skin) do
		(
			boneIndex = skinOps.GetSelectedBone skinMod -- ��ȡ��ǰѡ�еĹ�������
			-- �������Ѿ��ֶ���ͨ���ű�ѡ����һЩ����
			selectedVerts = skinOps.GetSelectedVertices skinMod  -- ��ȡѡ�ж������������
			
			for i in selectedVerts do
			(
				numWeights = skinOps.GetVertexWeightCount skinMod i  --��ȡi��ŵ�vertex�Ĺ�������
				
				for j = 1 to numWeights do 
				(					
					tempBoneIndexId = skinOps.GetVertexWeightBoneID skinMod i j 
					if tempBoneIndexId == boneIndex then 
					(
						weight = skinOps.GetVertexWeight skinMod i j
						newWeight = if (weight * (1- ( spWeight.value / 10))) > 0 then (weight * (1- ( spWeight.value / 10))) else 0
						skinOps.SetVertexWeights skinMod i boneIndex newWeight
					)
						
					
				)				
				
			)
		)
	)
	
	on btGetSkinBonesNumber pressed do 
	(
		-- ���ú�������ʾ���
		uniqueBoneCount = getUniqueSkinBonesNumber()
		messageBox ("�ܹ����ص���Ƥ��������Ϊ��" + uniqueBoneCount as string)
	)
	
	
	button btn_deform "Skin Deform[TRUE]"  width:180 height:25
	on btn_deform pressed do 
	(
		for obj in objects do 
		(
			if obj.modifiers[#skin] != undefined and (findItem weapon obj.name) == 0 then 
				obj.modifiers[#skin].always_deform = state -- ����always_deform����
		)
		suffText = toUpper (state as string)
		
		btn_deform.text = "Skin Deform[" + (suffText) + "]"
		if state == off then
			state = on
		else
			state = off
	)
	
	
	button btnSkinDisplay "skin��ʾ�л�"  width:180
	
	on btnSkinDisplay pressed do 
	(
		playActiveOnly = false -- ���Խ��������Ҳ����struct�У������Ҫ
		
		-- ʹ��ʾ��
		myDisplayColor = ViewportUtilities() -- ����structʵ��
		currentShaded = myDisplayColor.toggleShaded displayColor -- ���÷���
	)

	
	
)

-- ��������ʾRollout����
createdialog myRollout