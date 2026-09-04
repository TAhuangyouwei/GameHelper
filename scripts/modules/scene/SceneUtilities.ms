/*
    场景检查、地面创建和场景清理功能。
    从 HYW_Scripts_Library.ms 拆出，保留原结构名和调用方式。
*/

struct SceneUtilities
(
    -- 选择场景中UV数量大于2的物体
    fn mapChannelNum =
    (
        mapChannelNumTemp = #()
        for obj in objects where classof obj.baseobject == Editable_Poly do
        (
            num = polyop.getNumMaps obj
            if num > 2 then
            (
                append mapChannelNumTemp obj
            )
        )

        if mapChannelNumTemp.count != 0 then
        (
            clearSelection()
            select mapChannelNumTemp
            messageBox ("已选中场景中模型UV大于1的模型，共有" + (mapChannelNumTemp.count as string) + "个")
        )
    ),

    -- 单位检查
    fn unitCheck =
    (
        if units.SystemScale != 1.0 or units.SystemType != #Centimeters then
        (
            cd = queryBox "单位错误，是否修复"
            if cd == true then
            (
                units.DisplayType = #Metric
                units.MetricType = #meters
                units.SystemScale = 1.0
                units.SystemType = #Centimeters
            )
        )
    ),

    -- 缩放检查
	fn scaleCheck tolerance:1e-5 =
	(
		local scaleTolerance = abs tolerance
		local scaledObjects = for obj in objects where
		(
			classof obj.baseobject == Editable_Poly and
			isProperty obj #scale and
			(
				abs (obj.scale.x - 1.0) > scaleTolerance or
				abs (obj.scale.y - 1.0) > scaleTolerance or
				abs (obj.scale.z - 1.0) > scaleTolerance
			)
		) collect obj

		if scaledObjects.count > 0 then
		(
			local shouldSelect = queryBox ("缩放有问题的模型数量有" + (scaledObjects.count as string) + "个，是否选中缩放有问题的模型")
			if shouldSelect do selectMore scaledObjects
		)

		-- 返回检查结果，方便其他工具继续使用。
		scaledObjects
	),


	--检查多余的修改器
	fn getModifiers =
	(
		objs = for obj in geometry where (obj.modifiers.count > 1) or (obj.modifiers.count > 0 and obj.modifiers[#skin] == undefined) collect obj
		if objs.count != 0 then
		(
			cd = queryBox ("有多余修改器的物体数量有" + (objs.count as string) + "个，是否选中有问题的模型")
			if cd == true then selectmore objs
		)
	),

    -- 检查模型轴向是否Y轴向上
	fn objAxis =
	(
		tempAxis = #()
		for obj in objects where classof obj.baseobject == Editable_Poly do
		(
			if isProperty obj #rotation and obj.rotation != (quat 0.707107 0 0 0.707107) then
			(
				append tempAxis obj
			)
			else if isProperty obj #position then
			(
				local posCloseToZero = (abs(obj.position.x) < 0.0001 and abs(obj.position.y) < 0.0001 and abs(obj.position.z) < 0.0001)
				if not posCloseToZero then
				(
					append tempAxis obj
				)
			)
		)

		if tempAxis.count != 0 then
		(
			cd = queryBox ("轴向或位置有问题的模型数量有" + (tempAxis.count as string) + "个，是否选中有问题的模型")
			if cd == true then
			(
				selectmore tempAxis
			)
		)
	),
	fn isGameHelperFloor node =
	(
		(isValidNode node) and ((getUserProp node "CGH_GameHelperFloor") == true)
	),
	fn getGameHelperFloors =
	(
		for obj in objects where isGameHelperFloor obj collect obj
	),
	fn CreateFloor state width:600 height:600 depth:-3 =
	(
		local floorLayerName = "floor"
		local animFloors = getGameHelperFloors()

		if state == on then
		(
			-- 已经由本工具创建过时直接复用，避免反复点击生成重名地面。
			if animFloors.count > 0 then return animFloors[1]

			local animFloor = undefined
			undo "创建 GameHelper 地面" on
			(
				local layer = LayerManager.getLayerFromName floorLayerName
				local floorLayerWasCreated = false

				if layer == undefined then
				(
					layer = LayerManager.newLayerFromName floorLayerName
					floorLayerWasCreated = true
				)

				animFloor = box length:width width:height height:depth name:"Floor"
				animFloor.mat = standard()
				setUserProp animFloor "CGH_GameHelperFloor" true
				setUserProp animFloor "CGH_FloorLayerCreated" floorLayerWasCreated
				layer.addNode animFloor
			)

			animFloor
		)
		else
		(
			-- 没有工具标记时不处理同名的用户模型。
			if animFloors.count == 0 then return false

			local shouldDeleteLayer = false
			for animFloor in animFloors do
			(
				if (getUserProp animFloor "CGH_FloorLayerCreated") == true do
					shouldDeleteLayer = true
			)

			undo "删除 GameHelper 地面" on
			(
				delete animFloors

				-- 只删除工具自己创建的空图层；图层内还有其他物体时保留。
				if shouldDeleteLayer then
				(
					local layer = LayerManager.getLayerFromName floorLayerName
					if layer != undefined then
					(
						local layerNodes = #()
						layer.nodes &layerNodes
						if layerNodes.count == 0 do
							LayerManager.deleteLayerByName floorLayerName
					)
				)
			)

			true
		)
	),

	fn DeleteParticalView =  --删除粒子视图
	(
		delete $'particle view*'

		delete $'粒子视图*'
	),


	fn DeletePoints =
	(
		objs = for obj in objects where( (classof obj == Point) and ((findString obj.name "　" !=undefined ) or (findString obj.name "×t×ü" !=undefined ) or (findString obj.name "??×y×?" !=undefined ))) collect obj
		delete objs
	),


	fn DeleteDayReca =
	(
		z=1

		while z !=undefined do

		(

		x = rootscene

		z = custattributes.getdef x 1

		custAttributes.delete x z

		)

		xx = rootscene.custAttributes
		for i =1 to xx.count do deleteItem xx 1
	),

	fn CleanScene =
	(
		DeleteParticalView()
		DeletePoints()
		DeleteDayReca()
	)

)
