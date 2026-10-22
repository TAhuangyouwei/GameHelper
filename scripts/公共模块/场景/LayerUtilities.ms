/*
图层分类、骨骼集合和空图层清理功能。
从 HYW_Scripts_Library.ms 拆出，保留原结构名和调用方式。
*/

struct LayerUtilities
(

	fn getAllChildren node collectedNodes =
	(
		if node != undefined then
		(
			-- 检查节点是否是dummy并且名字中包含'nub'
			if not (
				(classof node == Dummy and findString node.name "nub" != undefined) or
				(classof node == BoneGeometry and findString node.name "nub" != undefined)
			) then
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


	--============================================================
	-- 基础对象判断
	--============================================================

	-- Point物体
	fn isPoint obj =
	(
		classof obj == Point and
		findString obj.name "LocationLOC" == undefined
	),


	-- 普通Dummy
	fn isDummy obj =
	(
		(classof obj == Dummy and findString obj.name "hp_" != undefined) or
		(classof obj == Dummy and findString obj.name "Dummy" != undefined)
	),


	-- AnimCraft Dummy
	fn isAC_Dummy obj =
	(
		classof obj == Dummy and
		findString obj.name "hp_" == undefined and
		findString obj.name "Dummy" == undefined and
		findString obj.name "Nub" == undefined
	),


	-- IK控制器
	fn isIKChain obj =
	(
		classof obj == IK_Chain_Object
	),


	-- Bone骨骼基础判断
	-- 排除Twist和Nub
	fn isBoneGeometryWithoutTwist obj =
	(
		classof obj == BoneGeometry and
		findString (toLower obj.name) "twist" == undefined and
		findString (toLower obj.name) "nub" == undefined
	),


	-- Biped
	fn isBipedObject obj =
	(
		classof obj == Biped_Object and
		findString obj.name "Twist" == undefined
	),


	-- 是否有Skin修改器
	fn hasSkinModifier obj =
	(
		obj.modifiers[skin] != undefined
	),


	-- Bone Nub
	fn isBoneNub obj =
	(
		obj.children.count == 0 and
		classof obj == BoneGeometry and
		findString obj.name "Nub" != undefined and
		obj.parent != undefined and
		classOf obj.parent == BoneGeometry
	),


	-- Twist Bone
	fn isTwistBone obj =
	(
		findString obj.name "Twist" != undefined
	),


	--============================================================
	-- AnimCraft专用
	--============================================================

	fn isLOC obj =
	(
		classof obj == NURBSCurveshape and
		findString obj.name "_LOC" != undefined
	),


	fn isLocationCV obj =
	(
		classof obj == SplineShape and
		findString obj.name "_LocationCV" != undefined
	),


	fn isControllers obj =
	(
		(classof obj == SplineShape and findString obj.name "_Ctrl" != undefined) or
		(classof obj == NURBSCurveshape and findString obj.name "_Ctrl" != undefined)
	),


	fn isLOC_Points obj =
	(
		classof obj == Point and
		findString obj.name "LocationLOC" != undefined
	),


	--============================================================
	-- 名称判断工具
	--============================================================

	-- 判断名称是否包含任意关键词
	fn boneNameContainsAny obj keywords =
	(
		if obj == undefined then return false

		local lowerName = toLower obj.name

		for keyword in keywords do
		(
			if findString lowerName (toLower keyword) != undefined then
				return true
		)

		false
	),


	-- 判断名称是否以指定字符结尾
	fn nameEndsWith obj suffix =
	(
		if obj == undefined then return false

		local objName = toLower obj.name
		local suffixName = toLower suffix

		if objName.count < suffixName.count then
			return false

		(
			substring
				objName
				(objName.count - suffixName.count + 1)
				suffixName.count
		) == suffixName
	),


	--============================================================
	-- Bone骨骼分类
	--============================================================

	/*
	分类优先级：

	01. _SkinJNT结尾	→ BN_Face
	02. hair			→ BN_Hair
	03. eye / eyeball	→ BN_Eye
	04. cloth			→ BN_Cloth
	05. skirt			→ BN_Skirt
	06. 其他			→ Bones

	Twist	→ BN_Twist
	Nub		→ 0
	*/


	-- 表情骨骼
	-- _SkinJNT结尾优先级最高
	fn isFaceBone obj =
	(
		isBoneGeometryWithoutTwist obj and
		nameEndsWith obj "_SkinJNT"
	),


	-- Hair骨骼
	fn isHairBone obj =
	(
		isBoneGeometryWithoutTwist obj and
		not isFaceBone obj and
		boneNameContainsAny obj #(
			"hair"
		)
	),


	-- Eye骨骼
	fn isEyeBone obj =
	(
		isBoneGeometryWithoutTwist obj and
		not isFaceBone obj and
		not isHairBone obj and
		boneNameContainsAny obj #(
			"eye",
			"eyeball"
		)
	),


	-- Cloth骨骼
	fn isClothBone obj =
	(
		isBoneGeometryWithoutTwist obj and
		not isFaceBone obj and
		not isHairBone obj and
		not isEyeBone obj and
		boneNameContainsAny obj #(
			"cloth"
		)
	),


	-- Skirt骨骼
	fn isSkirtBone obj =
	(
		isBoneGeometryWithoutTwist obj and
		not isFaceBone obj and
		not isHairBone obj and
		not isEyeBone obj and
		not isClothBone obj and
		boneNameContainsAny obj #(
			"skirt"
		)
	),


	-- 其他普通Bone
	fn isNormalBone obj =
	(
		isBoneGeometryWithoutTwist obj and
		not isFaceBone obj and
		not isHairBone obj and
		not isEyeBone obj and
		not isClothBone obj and
		not isSkirtBone obj
	),


	--============================================================
	-- 通用对象收集
	--============================================================

	fn collectObjectsByCondition conditionFn =
	(
		local collectedObjects = #()

		for obj in objects do
		(
			if conditionFn obj do
			(
				append collectedObjects obj
			)
		)

		collectedObjects
	),


	--============================================================
	-- 删除空图层
	--============================================================

	fn DeleteEmptyLayers =
	(
		local previousCurrentLayerName = LayerManager.current.name
		local emptyLayerNames = #()

		-- 0号图层是默认图层，因此从1开始检查
		if LayerManager.count > 1 then
		(
			for layerIndex = 1 to (LayerManager.count - 1) do
			(
				local layer = LayerManager.getLayer layerIndex
				local layerNodes = #()

				if layer.nodes &layerNodes then
				(
					if layerNodes.count == 0 do
						append emptyLayerNames layer.name
				)
			)
		)


		if emptyLayerNames.count == 0 then
		(
			messageBox "当前场景没有空图层。"
			return #()
		)


		-- 弹窗最多显示20个名称，避免图层过多时提示框太长
		local maxNamesToShow = 20

		local displayedNameCount =
			if emptyLayerNames.count < maxNamesToShow then
				emptyLayerNames.count
			else
				maxNamesToShow

		local layerNameListText = ""


		for i = 1 to displayedNameCount do
		(
			layerNameListText += "\n- " + emptyLayerNames[i]
		)


		if emptyLayerNames.count > displayedNameCount do
		(
			layerNameListText +=
				"\n- ……其余 " +
				((emptyLayerNames.count - displayedNameCount) as string) +
				" 个"
		)


		local shouldDelete = queryBox(
			"发现空图层 " +
			(emptyLayerNames.count as string) +
			" 个：" +
			layerNameListText +
			"\n\n是否删除？"
		)


		if not shouldDelete then
			return #()


		local defaultLayer = LayerManager.getLayer 0
		local deletedLayerNames = #()


		-- 当前图层不能被删除，删除前暂时切换到默认图层
		defaultLayer.current = true


		undo "删除空图层" on
		(
			for i = emptyLayerNames.count to 1 by -1 do
			(
				if LayerManager.deleteLayerByName emptyLayerNames[i] do
				(
					append deletedLayerNames emptyLayerNames[i]
				)
			)
		)


		-- 如果原来的当前图层还存在，就恢复它
		local previousLayer =
			LayerManager.getLayerFromName previousCurrentLayerName

		if previousLayer != undefined do
			previousLayer.current = true


		messageBox
		(
			"空图层清理完成。\n\n成功删除：" +
			(deletedLayerNames.count as string) +
			" 个\n未能删除：" +
			(
				emptyLayerNames.count -
				deletedLayerNames.count
			) as string +
			" 个"
		)


		-- 返回实际删除成功的图层名称
		deletedLayerNames
	),


	--============================================================
	-- 自动分类到图层
	--============================================================

	fn addObjectsToLayer =
	(

		--========================================================
		-- 普通对象
		--========================================================

		local ptArray =
			collectObjectsByCondition isPoint

		local dummyArray =
			collectObjectsByCondition isDummy

		local AC_DummyArray =
			collectObjectsByCondition isAC_Dummy

		local IKs =
			collectObjectsByCondition isIKChain


		--========================================================
		-- Bone分类
		--========================================================

		local faceBoneArray =
			collectObjectsByCondition isFaceBone

		local hairBoneArray =
			collectObjectsByCondition isHairBone

		local eyeBoneArray =
			collectObjectsByCondition isEyeBone

		local clothBoneArray =
			collectObjectsByCondition isClothBone

		local skirtBoneArray =
			collectObjectsByCondition isSkirtBone

		local bnArray =
			collectObjectsByCondition isNormalBone


		--========================================================
		-- 其他骨骼 / 模型
		--========================================================

		local bipArray =
			collectObjectsByCondition isBipedObject

		local skinArray =
			collectObjectsByCondition hasSkinModifier

		local boneNubArray =
			collectObjectsByCondition isBoneNub

		local twistBones =
			collectObjectsByCondition isTwistBone


		--========================================================
		-- AnimCraft
		--========================================================

		local AC_LOCArray =
			collectObjectsByCondition isLOC

		local AC_LocationCVArray =
			collectObjectsByCondition isLocationCV

		local AC_ConArray =
			collectObjectsByCondition isControllers

		local AC_LOC_PointArray =
			collectObjectsByCondition isLOC_Points


		--========================================================
		-- 收集SplineShapes
		--========================================================

		local spNodes = $Animcraft_Master_GRP...*
		local AC_SplineShapeArray = spNodes


		--========================================================
		-- 普通对象图层
		--========================================================

		if ptArray.count != 0 then
			addToLayer "Points" ptArray

		if dummyArray.count != 0 then
			addToLayer "Dummys" dummyArray

		if AC_DummyArray.count != 0 then
			addToLayer "AC_Dummys" AC_DummyArray

		if IKs.count != 0 then
			addToLayer "IK" IKs


		--========================================================
		-- Bone分类图层
		--========================================================

		if faceBoneArray.count != 0 then
			addToLayer "BN_Face" faceBoneArray

		if hairBoneArray.count != 0 then
			addToLayer "BN_Hair" hairBoneArray

		if eyeBoneArray.count != 0 then
			addToLayer "BN_Eye" eyeBoneArray

		if clothBoneArray.count != 0 then
			addToLayer "BN_Cloth" clothBoneArray

		if skirtBoneArray.count != 0 then
			addToLayer "BN_Skirt" skirtBoneArray

		if bnArray.count != 0 then
			addToLayer "Bones" bnArray


		--========================================================
		-- 其他
		--========================================================

		if bipArray.count != 0 then
			addToLayer "Bipeds" bipArray

		if skinArray.count != 0 then
			addToLayer "AM_Models" skinArray

		if boneNubArray.count != 0 then
			addToLayer "0" boneNubArray

		if twistBones.count != 0 then
			addToLayer "BN_Twist" twistBones


		--========================================================
		-- AnimCraft图层
		--========================================================

		if AC_LOCArray.count != 0 then
			addToLayer "AC_LOCs" AC_LOCArray

		if AC_LocationCVArray.count != 0 then
			addToLayer "AC_LocationCVs(可删除)" AC_LocationCVArray

		if AC_ConArray.count != 0 then
			addToLayer "AC_Controllers" AC_ConArray

		if AC_LOC_PointArray.count != 0 then
			addToLayer "AC_LOC_Points(可删除)" AC_LOC_PointArray


		-- 最后一个步骤
		-- 因为这是通过父子集选择的，没有通过各种判定
		if AC_SplineShapeArray.count != 0 then
			addToLayer "AC_SplineShapes" AC_SplineShapeArray


		--========================================================
		-- 自动隐藏指定图层
		--========================================================

		local names =
		#(
			"0",
			"AC_Controllers",
			"AC_Dummys",
			"AC_LOC_Points(可删除)",
			"AC_LocationCVs(可删除)",
			"AC_LOCs",
			"AC_SplineShapes",

			"BN_Face",
			"BN_Hair",
			"BN_Eye",
			"BN_Cloth",
			"BN_Skirt",
			"BN_Twist",

			"Dummys",
			"IK",
			"Points"
		)


		for layerName in names do
		(
			local layer =
				LayerManager.getLayerFromName layerName

			if layer != undefined then
				layer.ishidden = on
		)


		-- 创建Skin骨骼集合
		createSkinBonesSet()
	)

)