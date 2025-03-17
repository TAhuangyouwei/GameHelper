global copiedBoneNames = #() -- 存储骨骼名称
global copiedWeights = #() -- 存储权重信息
global copiedVertexWeights = #() -- 存储每个顶点的权重信息数组
global copiedVertexBoneNames = #() -- 存储每个顶点的骨骼名称数组
global allVertices = #() -- 存储总点集合
global selectedVertices = #() -- 初始化为一个空数组
global copiedVertexGroups = #() -- 存储拷贝顶点的组
global pasteVertsGroups = #() -- 存储粘贴顶点的组

global currentCloseVerticesPairIndex
currentCloseVerticesPairIndex = 1




try(DestroyDialog skinWeightsRollout)catch()
rollout skinWeightsRollout "皮肤权重工具" width:160 height:200
(
	fn refreshWeightToolsPanel skinModifier = 
	(
		max modify mode -- 切换到修改面板
		vertNumbers = skinOps.getSelectedVertices skinModifier
		skinOps.SelectVertices  skinModifier #{}
		skinOps.SelectVertices skinModifier vertNumbers
		if (skinOps.isWeightToolOpen skinModifier) == 1 then 
		(
			skinOps.closeWeightTool  skinModifier
			skinOps.WeightTool  skinModifier
		)

	)
	
	

	fn findModifier obj modType =
	(
		if obj != undefined then 
		(
			for mod in obj.modifiers where classOf mod == modType do return mod
			return undefined
		)
	)

	fn getCurrentSelectedVertices skinMod = 
	(
		return skinOps.GetSelectedVertices skinMod
	)

	
		
	fn inverseSelection skinMod totalVertices =
	(
		currentSelection = getCurrentSelectedVertices skinMod
		newSelection = #() -- 初始化一个空数组用于存储最终的新选中顶点集

		-- 生成总点集合中未被当前选中的顶点
		for vert in totalVertices do
		(
			if (findItem currentSelection vert) == 0 then -- 如果当前顶点不在currentSelection中
			(
				append newSelection vert -- 则将其添加到newSelection中
			)
		)

		-- 更新skin modifier的顶点选中状态
		skinOps.SelectVertices skinMod newSelection
	)
	
	-- 正确定义BoneMap结构体
	struct BoneMap
	(
		map = #(),
		fn addBone boneName boneID = (append map #(boneName, boneID)),
		fn getBoneID boneName = (for bonePair in map where bonePair[1] == boneName do return bonePair[2])
	)


	-- 创建BoneNameIDMap的函数
	fn createBoneNameIDMap skinModifier =
	(
		local myBoneMap = BoneMap()
		local boneNodes = skinOps.GetBoneNodes skinModifier
		for i = 1 to boneNodes.count do
		(
			local boneName = boneNodes[i].name
			myBoneMap.addBone boneName i
		)
		return myBoneMap
	)


	-- 确保在使用createBoneNameIDMap之前已经定义了BoneMap结构体
	-- 这样在调用createBoneNameIDMap时就能正确创建映射并使用它的方法

	fn ensureAllBonesExist sourceMod targetMod =
	(
		local sourceBones = skinOps.GetBoneNodes sourceMod
		local targetBones = skinOps.GetBoneNodes targetMod
		local targetBoneNames = for bone in targetBones collect bone.name

		for sourceBone in sourceBones do
		(
			if not (findItem targetBoneNames sourceBone.name) > 0 do
			(
				skinOps.addBone targetMod sourceBone 1
			)
		)
	)



	fn autoStitchOptimized node1 node2 threshold =
	(
		local skinMod1 = findModifier node1 Skin
		local skinMod2 = findModifier node2 Skin

		if skinMod1 == undefined or skinMod2 == undefined do
		(
			messagebox "One or both objects do not have a Skin modifier."
			return undefined
		)

		ensureAllBonesExist skinMod1 skinMod2

		local boneMap1 = createBoneNameIDMap skinMod1
		local boneMap2 = createBoneNameIDMap skinMod2

		local vertsPos1 = for i = 1 to skinOps.GetNumberVertices skinMod1 collect (polyOp.getVert node1.baseobject i)
		local vertsPos2 = for i = 1 to skinOps.GetNumberVertices skinMod2 collect (polyOp.getVert node2.baseobject i)
		
		local closeVerticesCount = 0
		local transferredWeightsCount = 0

		for i = 1 to vertsPos1.count do
		(
			for j = 1 to vertsPos2.count do
			(
				if distance vertsPos1[i] vertsPos2[j] <= threshold do
				(
					local boneCount = skinOps.GetVertexWeightCount skinMod1 i
					local copiedBoneIDs = #()
					local copiedWeights = #()

					for k = 1 to boneCount do
					(
						local weight = skinOps.GetVertexWeight skinMod1 i k
						local boneID1 = skinOps.GetVertexWeightBoneID skinMod1 i k
						local boneName = skinOps.GetBoneName skinMod1 boneID1 0
						local targetBoneID = boneMap2.getBoneID(boneName)

						if targetBoneID != undefined do
						(
							append copiedBoneIDs targetBoneID
							append copiedWeights weight
						)
					)

					if copiedBoneIDs.count > 0 do
					(
						skinOps.ReplaceVertexWeights skinMod2 j copiedBoneIDs copiedWeights
						closeVerticesCount += 1
						transferredWeightsCount += copiedWeights.count
					)
				)
			)
		)

		format "Total close vertices pairs found: %\n" closeVerticesCount
		format "Total weights transferred: %\n" transferredWeightsCount
	)





    group "单次拷贝"
    (
        button btnCopy "拷贝权重"  width:140 height:30
        button btnPaste "粘贴权重"  width:140 height:30
		


    )
    group "批量拷贝"
    (
		
		button btnRecordCopy "Record Copy" width:110 height:30	across:2	
		button btnBatchCopy "拷贝"  width:40 height:30 offset:[20,0]
		button btnRecordPaste "Record Paste" width:110 height:30 pos:[12,154] across:2
		button btnBatchPaste "粘贴"  width:40 height:30 offset:[20,0]
		button btnAutoStitch "自动缝合" width:150 height:30



		on btnAutoStitch pressed do  --自动拷贝权重
		(
			if selection.count == 2 then
			(
				autoStitchOptimized selection[1] selection[2] 0.1
			)
			else messagebox "请选择两个对象进行自动缝合。"
		)
		
		
		
    )
	group "点存储"
	(		

		
		
		button btnSaveAllVertices "All Verts" width:140 height:30
				
		on btnSaveAllVertices pressed do
		(
			local skinMod = findModifier selection[1] Skin
			if skinMod != undefined then
			(
				local currentSelection = getCurrentSelectedVertices skinMod
				if currentSelection.count == 0 and allVertices.count > 0 then
				(
					-- 如果没有选中的顶点且allVertices有存储，则选择allVertices中的点
					skinOps.SelectVertices skinMod allVertices
				)
				else
				(
					-- 如果有选中的顶点或allVertices为空，则更新allVertices
					allVertices = currentSelection
				)
			)
			else
			(
				messagebox "No skin modifier found on selected object."
			)
			completeRedraw()

		)

		on btnSaveAllVertices rightclick  do
		(
			allVertices = #() -- 清空allVertices
		)

		
		-- 存储或选择Selected Verts
		button btnSaveSelectedVertices "Selected Verts" width:140 height:30
		on btnSaveSelectedVertices pressed do 
		(
			local skinMod = findModifier selection[1] Skin
			if skinMod != undefined then
			(
				local currentSelection = getCurrentSelectedVertices skinMod
				if currentSelection.count == 0 and selectedVertices.count > 0 then
				(
					-- 如果没有选中的顶点且selectedVertices有存储，则选择selectedVertices中的点
					skinOps.SelectVertices skinMod selectedVertices
				)
				else
				(
					-- 如果有选中的顶点或selectedVertices为空，则更新selectedVertices
					selectedVertices = currentSelection
				)
			)
			completeRedraw()

		)

		on btnSaveSelectedVertices rightclick  do
		(
			selectedVertices = #() -- 清空Selected Verts
		)


		-- 选择allVertices中除去selectedVertices的点
		button btnSelectInverse "选择Inverse" width:140 height:30
		on btnSelectInverse pressed do
		(
			local skinMod = findModifier selection[1] Skin
			if skinMod != undefined then
			(
				local inverseSelection = for vert in allVertices where not (findItem selectedVertices vert > 0) collect vert -- 计算差集
				skinOps.SelectVertices skinMod inverseSelection
			)
			else
			(
				messagebox "No skin modifier found on selected object."
			)
			completeRedraw()

		)

		
		

	)
	group "状态信息"
	(
		label cpoyVertsNumber "当前Copy顶点数：0" offset:[0,5]
		
		label pasteVertsNumber "Paste顶点数：0"  offset:[0,5]
		
		on btnRecordCopy pressed do
		(
			local skinMod = findModifier selection[1] Skin
			if skinMod != undefined then
			(
				local currentSelection = getCurrentSelectedVertices skinMod
				for vert in currentSelection do
				(
					append copiedVertexGroups vert -- 直接添加整数值，不是数组
				)
				cpoyVertsNumber.text = "Copied vertex groups: " + (copiedVertexGroups.count as string)
			)
			else messagebox "Please select a mesh with a Skin modifier."
		)

		
		on btnRecordPaste pressed do
		(
			local skinMod = findModifier selection[1] Skin
			if skinMod != undefined then
			(
				local currentSelection = getCurrentSelectedVertices skinMod
				append pasteVertsGroups currentSelection
				format "Recorded selection group: %\n" currentSelection
				pasteVertsNumber.text = "Paste组数：" + (pasteVertsGroups.count as string)
			)
			else messagebox "Please select a mesh with a Skin modifier."
			
		)
		
		
		on btnCopy pressed do
		(
			copiedBoneNames = #()
			copiedWeights = #()
			skinModifier = selection[1].modifiers[#skin]
			vertNumbers = skinOps.getSelectedVertices skinModifier --获取选中的点
			if vertNumbers.count != 0 then 
			(
				vertBoneCount = skinOps.GetVertexWeightCount skinModifier vertNumbers[1] --获取当前选中点有几个骨骼影响
				cpoyVertsNumber.text = "只copy第一个选择的顶点"   					-- 更新拷贝顶点数标签的文本
				pasteVertsNumber.text = "Paste数：0" 
			)
			else 
			(
				cpoyVertsNumber.text = "当前Copy顶点数：0"
				pasteVertsNumber.text = "Paste数：0" 
				return undefined
			)
				
				
			for weightTool_ListNumber = 1 to vertBoneCount do 
			(
				vertWeight = skinOps.GetVertexWeight skinModifier vertNumbers[1] weightTool_ListNumber  --获取骨骼的权重信息 
				
				boneID = skinOps.GetVertexWeightBoneID skinModifier vertNumbers[1]  weightTool_ListNumber  --获取骨骼ID 
				
				
				append copiedWeights vertWeight
				listID = skinOps.GetListIDByBoneID skinModifier boneID
				
				boneNode = skinOps.GetBoneNode skinModifier boneID --获取选择的骨骼名称
				
				boneName = skinOps.GetBoneName skinModifier boneID 0  --这里是boneID,不是weightTool_ListNumber
				append copiedBoneNames boneName 
				
				
				

			)
			
		)
	
		
		on btnPaste pressed do
		(
			with undo "Paste Single Vertex Weight" on
			(
				skinModifier = selection[1].modifiers[#skin]
				targetVertNumbers = skinOps.getSelectedVertices skinModifier --获取选中的点用于粘贴操作
				updatedSkinBoneNodes = skinOps.GetBoneNodes skinModifier
				copiedBoneIDs =#()
				
				
				missingBoneNodes = #()
				-- 遍历copiedBoneNames中的每个骨骼名称
				for boneName in copiedBoneNames do
				(
					local found = false
					for boneNode in updatedSkinBoneNodes do
					(
						if boneNode.name == boneName then
						(
							found = true
							break
						)
					)
					-- 如果没有找到，则添加到临时列表中
					if not found do append missingBoneNodes (getNodeByName boneName)
				)
				
				-- 对于每个缺失的骨骼，将其添加到skinModifier中
				for boneNode in missingBoneNodes do
				(
					-- 假设这里的boneNode是一个有效的骨骼节点对象
					skinOps.addBone skinModifier boneNode 1
				)
				
				-- 重新获取更新后的骨骼节点列表
				updatedSkinBoneNodes = skinOps.GetBoneNodes skinModifier
				
				for boneName in copiedBoneNames do 
				(
					for boneIndex = 1 to updatedSkinBoneNodes.count do --通过名称对比获取boneID ，然后再把BoneID 转换到copiedBoneIDs中
					(
						if updatedSkinBoneNodes[boneIndex].name == boneName then
						(
							append copiedBoneIDs boneIndex    
						)
					)
				)
				
				for vertNumber in targetVertNumbers do 
					skinOps.ReplaceVertexWeights skinModifier vertNumber copiedBoneIDs copiedWeights
				
				refreshWeightToolsPanel skinModifier
				pasteVertsNumber.text = "Paste数："  + ( targetVertNumbers.count as string )
			)
		)
		
		
		
		on btnBatchCopy pressed do
		(
			
			copiedVertexWeights = #() -- 重置，以便存储新的拷贝顶点权重信息
			copiedVertexBoneNames = #() -- 重置，以便存储新的拷贝顶点骨骼名称信息
			-- 注意：这里不需要重置 copiedVertexGroups，因为它是由 btnRecordCopy 填充的

			skinModifier = findModifier selection[1] Skin
			if skinModifier == undefined do 
			(
				messagebox "选中的对象没有Skin Modifier!"
				return undefined 
			)

			-- 检查是否已经记录了拷贝顶点
			if copiedVertexGroups.count == 0 do
			(
				cpoyVertsNumber.text = "Copy顶点数为：0"
				messagebox "No copy vertex recorded."
				return undefined
			)
			cpoyVertsNumber.text = "Copy顶点数为：" + (copiedVertexGroups.count as string)
			-- 遍历记录的每个顶点
			for vert in copiedVertexGroups do
			(
				local vertWeights = #() -- 存储当前顶点的权重信息
				local vertBoneNames = #() -- 存储当前顶点的骨骼名称信息
				local vertBoneCount = skinOps.GetVertexWeightCount skinModifier vert
				
				for i = 1 to vertBoneCount do
				(
					local vertWeight = skinOps.GetVertexWeight skinModifier vert i
					local boneID = skinOps.GetVertexWeightBoneID skinModifier vert i
					local boneName = skinOps.GetBoneName skinModifier boneID 0
					append vertWeights vertWeight
					append vertBoneNames boneName
				)
				
				append copiedVertexWeights vertWeights
				append copiedVertexBoneNames vertBoneNames
			)
			
			messagebox ("Batch copy completed. " + (copiedVertexGroups.count as string) + " vertices copied.")

		)


		
		
		
		
				
		on btnBatchPaste pressed do
		(
			with undo "Batch Paste Vertex Weights" on
			(
				
				skinModifier = findModifier selection[1] Skin
				if skinModifier == undefined do 
				(
					messagebox "选中的对象没有Skin Modifier!"
					return undefined
				)
				if pasteVertsGroups.count == 0 do
				(
					messagebox "No paste vertex groups recorded."
					return undefined
				)
				updatedSkinBoneNodes = skinOps.GetBoneNodes skinModifier
				for groupIndex = 1 to pasteVertsGroups.count do
				(
					local pasteGroup = pasteVertsGroups[groupIndex]
					local copyIndex = groupIndex
					if copyIndex > copiedVertexWeights.count then
						copyIndex = copiedVertexWeights.count -- 确保索引不会超出拷贝数据的范围
					
					local vertWeights = copiedVertexWeights[copyIndex]
					local vertBoneNames = copiedVertexBoneNames[copyIndex]
					local vertexBoneIDs = for boneName in vertBoneNames collect (findItem (for bn in updatedSkinBoneNodes collect bn.name) boneName)
					for vert in pasteGroup do
					(
						if vert <= skinOps.GetNumberVertices skinModifier do
						(
							skinOps.ReplaceVertexWeights skinModifier vert vertexBoneIDs vertWeights
						)
					)
				)
				
				refreshWeightToolsPanel skinModifier
				pasteVertsGroups = #() -- 存储粘贴顶点的组
			)
		)


		
	)
	

	
)

createdialog skinWeightsRollout 180 435
