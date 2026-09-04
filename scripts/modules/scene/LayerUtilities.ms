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
