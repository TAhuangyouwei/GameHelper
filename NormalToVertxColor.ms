--	--------------------------------------------------Skin------------------------------------------------------------------
fn mxsGetSkinWeights inNode = (
	setCommandPanelTaskMode #modify
	local skinModifier = inNode.Modifiers[Skin]
	modPanel.setCurrentObject skinModifier

	local skopGetVertexWeight = SkinOps.GetVertexWeight
	local skopGetVertexWeightCount = SkinOps.GetVertexWeightCount
	local skopGetVertexWeightBoneID = SkinOps.GetVertexWeightBoneID
	
	local skinData =#()
	local vertCount = SkinOps.GetNumberVertices(skinModifier)
	for vertIndex = 1 to vertCount do
	(
		local curData =#()
		local influenceCount = skopGetVertexWeightCount skinModifier vertIndex
		curData[1] = for influenceIndex = 1 to influenceCount collect skopGetVertexWeightBoneID skinModifier vertIndex influenceIndex
		curData[2] = for influenceIndex = 1 to influenceCount collect skopGetVertexWeight skinModifier vertIndex influenceIndex
		Append skinData curData
	)
	skinData
)

fn mxsSetSkinWeights inNode inData = (
	setCommandPanelTaskMode #modify
	local skinModifier = inNode.Modifiers[Skin]
	modPanel.setCurrentObject skinModifier
	local skopReplaceVertexWeights = SkinOps.ReplaceVertexWeights
	local vertCount = SkinOps.GetNumberVertices(skinModifier)
	for vertIndex = 1 to vertCount do
		skopReplaceVertexWeights skinModifier vertIndex inData[vertIndex][1] inData[vertIndex][2]
)
--	--------------------------------------------------Skin------------------------------------------------------------------

fn SmoothNormalToVertxColor inObj isFlipGreen =
(
	select inObj
	local geo = inObj
	local geoRot = inObj.transform.rotation
	local rotX90 = quat 90 [1,0,0]
	local combinedRot = rotX90 * geoRot
	geo.showVertexColors = true
	setCommandPanelTaskMode #modify

	convertToMesh geo
	addModifier geo (VertexPaint())
	addModifier geo (Edit_Normals()) 
		
	local norMod = geo.Edit_Normals
	local geoRot = inObj.transform.rotation

	local facesVertxUVW = #()		--	面顶点的UVW
	local facesVertxNormal = #()	--	面顶点的法线
		
	local facesVertxAngle = #()	--	点夹角,用于计算平均法线	
		
	local facesTangent = #()		--	面的切线	世界空间
	local facesUVflip =#{}				--	标记 UV方向是反的
	
	local numFaces = getNumFaces geo
	for i = 1 to numFaces do
	( 
		local face = getFace geo i		--	顶点序号 	[1,5,6]
		local facePos = for j = 1 to 3 collect getVert geo face[j]

		local tface = getTVFace geo i	--	UVW 序号		[1,3,5]
		local faceUVW = for j = 1 to 3 collect getTVert geo tface[j]
		
		local e1 = facePos[2] - facePos[1]
		local e2 = facePos[3] - facePos[1] 

		local delta_uv1 = faceUVW[2] - faceUVW[1]
		local delta_uv2 = faceUVW[3] - faceUVW[1]

		local faceTangent = (delta_uv1.y * e2 - delta_uv2.y * e1) / (delta_uv1.y * delta_uv2.x - delta_uv2.y * delta_uv1.x)
		
		facesUVflip[i] = (cross delta_uv1 delta_uv2).z < 0

		for j = 1 to 3 do 
		(
			append facesVertxUVW faceUVW[j]
			local vertxNormalID = norMod.getNormalID i j
			local vertxNormal = normalize((norMod.GetNormal vertxNormalID) * combinedRot)	-- vertxNormal	模型空间转世界空间
			append facesVertxNormal vertxNormal
			append facesVertxAngle (dot )
		)
		append facesTangent (normalize(faceTangent))
		--	append facesData curFaceData
	)
	
	---	计算平滑法线
	
	local facesVertxSmoothNormal = #()
	norMod.select #{1..norMod.GetNumNormals()}
	norMod.EditNormalsMod.Unify()
	--update geo
	
    getFace geo 1
	for i=1 to numFaces do
	(	
		for j = 1 to 3 do
		(
			local smoothNormal = norMod.GetNormal(norMod.GetNormalID i j)
			append facesVertxSmoothNormal smoothNormal
		)
	)
	/*	
	local pre_Debug = for g in objects where classof g == SplineShape or classof g == point collect g
	for i = pre_Debug.count to 1 by-1 do
		delete pre_Debug[i]	
	*/
	deleteModifier $ 1 -- 删除 编辑法线
	
	
	local tcols = #()
	local doneTangents = #()				--	存合并好的切线数据
	local faceToDoneTangentsIndex = #()	--	一个面占3个点 占3个索引 face i 点j 对应 faceToDoneTangentsIndex[(i-1)*3+j] 为在doneTangents的标号
	
	for i = 1 to numFaces do
	(
		local face = getFace geo i			--	面包含的顶点序号
		local faceUVW = getTVFace geo i	--	UVW 序号
	
		local curFaceFilp = facesUVflip[i]
		local curFaceTangent = facesTangent[i]
		
		for j = 1 to 3 do 
		(
			local curFacesVertxIndex = (i-1)*3+j
			local vertxIndex = face[j]
			
			local vertxUVW = facesVertxUVW[curFacesVertxIndex]
			local vertxNormal = facesVertxNormal[curFacesVertxIndex]
			local cacheIndex = faceToDoneTangentsIndex[curFacesVertxIndex]	-- 顶点合并切线索引
			
			local combineTangent = [0,0,0]
			if(cacheIndex!= undefined )then 
				combineTangent = doneTangents[cacheIndex] 
			else
			(
				local shareVertxFaces = meshop.getFacesUsingVert geo vertxIndex --当前共享顶点的 面
				local newCombineIndex = doneTangents.count+1
				for shareFaceID in shareVertxFaces do
				(
					local shareVertxFace = getFace geo shareFaceID
					for fi =1 to 3 where vertxIndex == shareVertxFace[fi] do	-- 和当前点一致
					(
						local shareFacesVertxIndex = (shareFaceID-1)*3+fi
						
						if	facesVertxNormal[shareFacesVertxIndex] == vertxNormal and \
							facesVertxUVW[shareFacesVertxIndex] == vertxUVW and \
							facesUVflip[shareFaceID] == curFaceFilp do
						(	
							combineTangent += facesTangent[shareFaceID]
							faceToDoneTangentsIndex[shareFacesVertxIndex] = newCombineIndex
						)
					)
				)
				combineTangent = normalize(combineTangent - (dot combineTangent vertxNormal) * vertxNormal) -- 平面上垂直normal的向量
				doneTangents[newCombineIndex]  = combineTangent
			)
			
			local vertxBitangent = cross vertxNormal combineTangent 
			local TBN = Matrix3 combineTangent vertxBitangent vertxNormal [0,0,0]
	
			local curVertxTBN = Matrix3 combineTangent vertxBitangent vertxNormal (getVert geo face[j])
			--	========	debug	========	--
			--debug_showGizmo curVertxTBN 1

			TBN = inverse TBN
			
			local smoothNormal = facesVertxSmoothNormal[curFacesVertxIndex]
			/*
			local norsID_bit = #{}
			norMod.ConvertVertexSelection #{face[j]} norsID_bit
			for k in norsID_bit do
				smoothNormal += norMod.getNormal k
			smoothNormal = normalize(smoothNormal * geoRot)
			*/
			smoothNormal = normalize(smoothNormal * TBN)
			
			if curFaceFilp != isFlipGreen do 	--	isFlipGreen 则 输出全部反转 isUVflip UV反了需要反转
				smoothNormal.y = -smoothNormal.y
			
			local tcol = ((smoothNormal+1)* 127.5) as color              
			append tcols tcol
		)
	)
	convertToMesh geo
	for i = 1 to meshop.getNumCPVVerts geo do setVertColor geo i tcols[i]
	--convertToPoly geo 
	free facesVertxUVW; free facesVertxNormal;	free facesTangent; free facesUVflip;
	free facesVertxSmoothNormal
	free tcols; free doneTangents; free faceToDoneTangentsIndex
	update geo
)

fn copyModifiers inNode =
(
	local modifs  = for m in inNode.modifiers collect 
	(
		local modifData =#()
		modifData[1] = copy m
		modifData[2] = if classof m == Skin then  mxsGetSkinWeights inNode else undefined
		modifData
	)
	modifs
)

fn pasteModifiers inNode inModifs =
(
	local ModifsNum = inModifs.count
	for i=ModifsNum to 1 by -1 do
	(
		local modifData = inModifs[i]
		addModifier inNode modifData[1]
		if(modifData[2] != undefined and classof modifData[1] == Skin )do
			mxsSetSkinWeights inNode modifData[2]
	)
)
	
fn isMeshObj inObj =
(
	local curClass = classof inObj
	curClass == Editable_mesh or  curClass == PolyMeshObject or curClass == Editable_Poly
)	
	
try (DestroyDialog normalToVertColor) catch()

rollout normalToVertColor "平滑法线->转顶点色"  width:220  height:100
( 
    checkbox cb_FilpGreen "反转绿通道(unity中不用勾选默认关闭)" checked:false
    
    label lb_space1 ""
    button btn_normalToVertColor "执行---选择的模型" height:26
    
    on btn_normalToVertColor pressed do
    (
        local allObjs = for sel in selection where isMeshObj sel collect sel
        local allStart = timeStamp()
        
        for obj in allObjs do
        (
            local start = timeStamp()
            
            local modifsData = copyModifiers obj
            for m=1 to obj.modifiers.count do deleteModifier obj 1
            
            SmoothNormalToVertxColor obj cb_FilpGreen.state
            
            pasteModifiers obj modifsData
            free modifsData
            format "Processing % took % seconds\n" obj.name ((timeStamp() - start) / 1000.0)
        )
        format "Processing all took % seconds\n" ((timeStamp() - allStart) / 1000.0)
        gc()
    )
)

Createdialog normalToVertColor  lockHeight:false autoLayoutOnResize:true