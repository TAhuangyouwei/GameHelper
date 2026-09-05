try(DestroyDialog myRollout)catch()

global state = off -- 定义一个全局变量state并初始化为off

global weapon = #("rdmobj002","rdmobj002","rdmobj112","Jian","rdmobj113")


-- 定义Rollout界面
rollout myRollout "Skin Tools" width:200 
(
	
	
	fn getUniqueSkinBonesNumber =
	(
		uniqueBones = #() -- 创建一个空集合用于存储独特的骨骼节点
		for obj in selection do -- 遍历当前选中的所有对象
		(
			if obj.modifiers[#Skin] != undefined then 
			(
				local skinMod = obj.modifiers[#Skin] -- 查找当前对象上的Skin Modifier
				local boneNodes = skinOps.GetBoneNodes skinMod -- 获取当前Skin Modifier的骨骼节点
				for boneNode in boneNodes do -- 如果骨骼节点不在集合中，则添加到集合
				(
					appendIfUnique uniqueBones boneNode
				)
				
			)
		)
		uniqueBones.count -- 返回独特骨骼节点的数量
	)

	
	-- 权重转移函数
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


	
    -- 添加按钮
	spinner spWeight "Weight" range:[0,1,0.1] type:#float fieldwidth:100
    button btnSelect "选择骨骼影响的点" width:180 height:25
    button btnIncreaseWeight "加减权重" width:180 height:25
    button btnDecreaseWeight "缩放权重" width:180 height:25
	button btGetSkinBonesNumber "蒙皮骨骼数量" width:180 height:25
	
	
	group "权重交换"
	(
		button pb_1 "From Bone" across:3 width:60 height:25
		label lb "-->"  height:25
		button pb_2 "To Bone"  width:60 height:25	
		button btnTransferWeights "转移权重" width:180 height:25
	)

	-- 存储选中的骨骼节点
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

	-- 当点击“转移权重”按钮时执行的操作
	on btnTransferWeights pressed do
	(
		undo on 
		(
			-- 确保有有效的骨骼和顶点选中
			if bone1 != undefined and bone2 != undefined then  (
				local skinMod = selection[1].modifiers[#Skin]
				local selectedVerts = skinOps.GetSelectedVertices skinMod  -- 获取选中顶点的索引数组

				for vertexIndex in selectedVerts do (
					mergeVertexWeights skinMod vertexIndex bone1 bone2
				)
			) else (
				messageBox "请选择两个骨骼节点！"
			)
			
		)

	)
	

    -- 获取当前蒙皮对象
    local skinMod = modPanel.getCurrentObject()

    -- 当点击“Select Vertices by Bone”按钮时执行的操作
    on btnSelect pressed do
    (
		local skinMod = modPanel.getCurrentObject()
		max modify mode		
		subobjectLevel = 1
        if (classof skinMod == Skin) do
        (
            -- 选中当前骨骼影响的顶点
            skinOps.selectVerticesByBone skinMod
        )
    )
	
	
	-- 当点击“Increase Weight”按钮时执行的操作
	on btnIncreaseWeight pressed do
	(
		local skinMod = modPanel.getCurrentObject()
		if (classof skinMod == Skin) do
		(
			boneIndex = skinOps.GetSelectedBone skinMod -- 获取当前选中的骨骼索引
			-- 假设你已经手动或通过脚本选择了一些顶点
			selectedVerts = skinOps.GetSelectedVertices skinMod  -- 获取选中顶点的索引数组
			
			for i in selectedVerts do
			(
				numWeights = skinOps.GetVertexWeightCount skinMod i  --获取i序号的vertex的骨骼数量
				
				for j = 1 to numWeights do 
				(					
					tempBoneIndexId = skinOps.GetVertexWeightBoneID skinMod i j --获取weight tool 的列变种的骨骼在 sort list 的ID 
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
			boneIndex = skinOps.GetSelectedBone skinMod -- 获取当前选中的骨骼索引
			-- 假设你已经手动或通过脚本选择了一些顶点
			selectedVerts = skinOps.GetSelectedVertices skinMod  -- 获取选中顶点的索引数组

			for i in selectedVerts do
			(
				numWeights = skinOps.GetVertexWeightCount skinMod i  --获取i序号的vertex的骨骼数量
				
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
	

    -- 当点击“Decrease Weight”按钮时执行的操作
	-- 缩放选中顶点的权重
	on btnDecreaseWeight pressed do
	(
		local skinMod = modPanel.getCurrentObject()
		if (classof skinMod == Skin) do
		(
			boneIndex = skinOps.GetSelectedBone skinMod -- 获取当前选中的骨骼索引
			-- 假设你已经手动或通过脚本选择了一些顶点
			selectedVerts = skinOps.GetSelectedVertices skinMod  -- 获取选中顶点的索引数组
			
			for i in selectedVerts do
			(
				numWeights = skinOps.GetVertexWeightCount skinMod i  --获取i序号的vertex的骨骼数量
				
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
			boneIndex = skinOps.GetSelectedBone skinMod -- 获取当前选中的骨骼索引
			-- 假设你已经手动或通过脚本选择了一些顶点
			selectedVerts = skinOps.GetSelectedVertices skinMod  -- 获取选中顶点的索引数组
			
			for i in selectedVerts do
			(
				numWeights = skinOps.GetVertexWeightCount skinMod i  --获取i序号的vertex的骨骼数量
				
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
		-- 调用函数并显示结果
		uniqueBoneCount = getUniqueSkinBonesNumber()
		messageBox ("总共独特的蒙皮骨骼数量为：" + uniqueBoneCount as string)
	)
	
	
	button btn_deform "Skin Deform[TRUE]"  width:180 height:25
	on btn_deform pressed do 
	(
		for obj in objects do 
		(
			if obj.modifiers[#skin] != undefined and (findItem weapon obj.name) == 0 then 
				obj.modifiers[#skin].always_deform = state -- 更改always_deform属性
		)
		suffText = toUpper (state as string)
		
		btn_deform.text = "Skin Deform[" + (suffText) + "]"
		if state == off then
			state = on
		else
			state = off
	)
	
	
	button btnSkinDisplay "skin显示切换"  width:180
	
	on btnSkinDisplay pressed do 
	(
		playActiveOnly = false -- 可以将这个变量也放入struct中，如果需要
		
		-- 使用示例
		myDisplayColor = ViewportUtilities() -- 创建struct实例
		currentShaded = myDisplayColor.toggleShaded displayColor -- 调用方法
	)

	
	
)

-- 创建并显示Rollout界面
createdialog myRollout