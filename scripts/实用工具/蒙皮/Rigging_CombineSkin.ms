-- 尝试销毁已存在的对话框以避免重复
try(DestroyDialog SkinCombineTool)catch()

-- 定义主要的界面和功能
rollout SkinCombineTool "Skin Combiner"
(
	-- 界面按钮定义
    button btnCombineSkin "Combine Skin" align:#center width:120
    button btnDetachSkin "Detach Skin" align:#center width:120
	
	-- 创建必要的局部变量
	local createms
	
	-- 存储常用函数以提高循环中的性能
	local p_getNumFaces = polyop.getNumFaces
	local p_getElementsUsingFace = polyop.getElementsUsingFace
	local p_getVertsUsingFace = polyop.getVertsUsingFace
	local p_deleteFaces = polyop.deleteFaces
	local m_cloneNodes = maxOps.cloneNodes
	local GetVertexWeightCount = skinOps.GetVertexWeightCount
	local GetVertexWeight = skinOps.GetVertexWeight
	local GetVertexWeightBoneID = skinOps.GetVertexWeightBoneID
	local GetNumberVertices = skinOps.GetNumberVertices
	local ReplaceVertexWeights = skinOps.ReplaceVertexWeights
	local SelectVertices = skinOps.SelectVertices
	local BakeSelectedVerts = skinOps.bakeSelectedVerts
	local RemoveZeroWeights = skinOps.RemoveZeroWeights
	local isWeightToolOpen = skinOps.isWeightToolOpen
	local closeWeightTool = skinOps.closeWeightTool
	local GetBoneName =skinOps.GetBoneName
	local GetNumberBones = skinOps.GetNumberBones
	local addbone = skinOps.addbone
	local invalidate = skinOps.invalidate
	
	-- 获取给定对象的所有元素
	fn getAllElements obj =
	(
		local elementList = #()
		local faceCount = polyop.getNumFaces obj
		local unprocessedFaces = #{1..faceCount}

		while not unprocessedFaces.isEmpty do
		(
			local seedFace = undefined
			for f in unprocessedFaces do
			(
				seedFace = f
				break
			)
			
			local newElement = polyop.getElementsUsingFace obj seedFace
			append elementList newElement
			unprocessedFaces -= newElement
		)

		elementList
	)


	-- 烘焙并清理指定皮肤修饰符的权重
	fn bakeAndCleanSkinWeights objSkin =
	(
		modPanel.setCurrentObject objSkin
		SelectVertices objSkin (GetNumberVertices objSkin)
		bakeSelectedVerts objSkin
		objSkin.clearZeroLimit = 0.0
		RemoveZeroWeights objSkin
	)

	-- 存储指定皮肤修饰符的顶点权重
	fn storeVertexWeights objSkin faceArray element =
	(
		local vertWeights = #()
		local verts = p_getVertsUsingFace obj (faceArray - element)

		for v in verts do
		(
			local weights = #()
			local bones = #()
			local wc = GetVertexWeightCount objSkin v

			for b = 1 to wc do
			(
				append weights (GetVertexWeight objSkin v b)
				append bones (GetVertexWeightBoneID objSkin v b)
			)

			append vertWeights #(bones, weights)
		)

		vertWeights
	)


	-- 克隆对象并修正权重
	fn cloneAndFixWeights obj elementWeights element =
	(
		m_cloneNodes obj newNodes:&newObjs
		p_deleteFaces newObjs[1] element

		local newObjSkin = newObjs[1].skin
		modPanel.setCurrentObject newObjSkin
		local vCount = GetNumberVertices newObjSkin

		for v = 1 to vCount do
		(
			ReplaceVertexWeights newObjSkin v elementWeights[v][1] elementWeights[v][2]
		)
	)



	-- 分离具有皮肤修饰符的对象
	fn detachElementsWithSkin obj =
	(
		elementsArray = getAllElements obj
		bakeAndCleanSkinWeights obj.skin

		local faceCount = p_getNumFaces obj
		local faceArray = #{1..faceCount}
		local vertWeightsArray = #()

		for ele in elementsArray do
		(
			append vertWeightsArray (storeVertexWeights obj.skin faceArray ele)
		)

		for i = 1 to elementsArray.count do
		(
			cloneAndFixWeights obj vertWeightsArray[i] elementsArray[i]
		)

		delete obj
	)


	-- 检查所选对象并准备处理
	fn checkAndPrepare selObjs =
	(
		local proceed = true

		if selection.count <= 1 do proceed = false
		for obj in selObjs while proceed do
		(
			if not isProperty obj #skin do proceed = false
		)

		proceed
	)


	-- 保存所选对象的权重信息
	fn saveWeights selObjs =
	(
		local createms = "" as stringstream
		local totalVerts = 0
		local NameArray = #()

		for obj in selObjs do
		(
			modPanel.setCurrentObject obj.skin

			if InstanceMgr.CanMakeModifiersUnique obj obj.skin do
			(
				InstanceMgr.MakeModifiersUnique obj obj.skin #individual
				invalidate obj.skin
			)
			
			local sk = obj.skin
			modPanel.setCurrentObject sk
			
			local bCount = GetNumberBones sk
			
			for b = 1 to bCount do
			(
				appendifUnique NameArray (GetBoneName sk b 1)
			)
			
			sort NameArray
			
			local skinCount = GetNumberVertices sk
			
			sk.clearZeroLimit = 0.0
			RemoveZeroWeights sk
			
			for v = 1 to skinCount do
			(
				local weights = #()
				local bones = #()
				
				local weightCount = GetVertexWeightCount sk v

				for b = 1 to weightCount do
				(
					local weight = GetVertexWeight sk v b
					local boneID = GetVertexWeightBoneID sk v b
					local bone = GetBoneName sk boneID 1
					 
					if weight != 0 do
					(
						append weights weight
						append bones bone
					)
				)
				
				-- ADDING TOTAL VERTS MODIFIES THE VERTEX NUMBERS AS WE SAVE
				format "%\n%\n%\n" (v+totalVerts) weights bones to:createms
			)
			
			totalVerts += skinCount
		)

		return #(createms, NameArray, totalVerts)
	)



	-- 合并所选对象
	fn mergeObjects selObjs =
	(
		convertTo selObjs Editable_Poly
		local newObj = selObjs[1]
		select newObj

		for obj in selObjs where obj != newObj do
		(
			newObj.EditablePoly.attach obj newObj
		)

		newObj
	)


	-- 添加并配置新的皮肤修饰符
	fn addAndConfigureSkinModifier newObj NameArray =
	(
		local newSkin = Skin()
		addModifier newObj newSkin
		
		newSkin.filter_cross_sections = off
		newSkin.filter_vertices = on
		newSkin.showNoEnvelopes = on
		newSkin.wt_showGlobal = on
		newSkin.wt_activeVertexSet = 1
		newSkin.wt_showAffectedBones = on

		-- 添加骨骼到皮肤修饰符
		for boneName in NameArray do
		(
			local boneNode = getNodeByName boneName
			if boneNode != undefined do
			(
				addBone newSkin boneNode 1
			)
		)

		newSkin
	)




	-- 从数据流中加载权重信息
	fn loadWeights newSkin createms NameArray =
	(
		seek createms 0  -- 将流的位置重置到开始

		while not eof createms do
		(
			local boneIDarray = #()
			local vertexIndex = execute (readline createms)
			local weights = execute (readline createms)
			local boneNames = execute (readline createms)

			for boneName in boneNames do
			(
				local BoneID = findItem NameArray boneName
				if BoneID != 0 do
				(
					append boneIDarray BoneID
				)
			)
			
			ReplaceVertexWeights newSkin vertexIndex boneIDarray weights
		)
	)



	-- 组合皮肤的主要功能
	fn combineSkin = 
	(
		clearlistener()
		max modify mode

		local selObjs = getCurrentSelection()

		if checkAndPrepare selObjs do
		(
			local createms, NameArray, totalVerts = saveWeights selObjs
			local newObj = mergeObjects selObjs
			local newSkin = addAndConfigureSkinModifier newObj NameArray
			loadWeights newSkin createms NameArray
		)
	)
		
	
	
	
	
	
    
    -- 组合皮肤按钮的动作
    fn combineAction =
    (
        try
        (
            combineSkin()
        )
        catch
        (
            format "Error during combining skins: %\n" (getcurrentexception())
        )
    )
	
	
	
    -- 分离皮肤按钮的动作
    fn detachAction =
    (
        escapeEnable = true
        clearListener()
        holdMaxFile()

        local processObjs = getCurrentSelection()
        for obj in processObjs do with redraw off
        (
            try
            (
                detachElementsWithSkin obj
            )
            catch
            (
                format "Object: % failed to process. Could be frozen or hidden.\n" obj.name
            )
        )
        clearselection()
    )

	-- 按钮事件处理
    on btnCombineSkin pressed do combineAction()
    on btnDetachSkin pressed do detachAction()
)

createDialog SkinCombineTool



