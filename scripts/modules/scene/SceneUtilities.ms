/*
    场景检查、地面创建和场景清理功能。
    从 HYW_Scripts_Library.ms 拆出，保留原结构名和调用方式。
*/

struct SceneUtilities
(
    -- 查找具有2号或更高贴图通道的 Editable Poly
    fn mapChannelNum firstExtraChannel:2 =
    (
        local objectsWithExtraMapChannels = #()

        for obj in objects where classof obj.baseobject == Editable_Poly do
        (
            local mapChannelCount = polyop.getNumMaps obj
            local hasExtraMapChannel = false

            if mapChannelCount > firstExtraChannel then
            (
                for mapChannel = firstExtraChannel to (mapChannelCount - 1) do
                (
                    if not hasExtraMapChannel then
                    (
                        hasExtraMapChannel =
                            (polyop.getMapSupport obj mapChannel) and
                            ((polyop.getNumMapVerts obj mapChannel) > 0)
                    )
                )
            )

            if hasExtraMapChannel do
                append objectsWithExtraMapChannels obj
        )

        if objectsWithExtraMapChannels.count > 0 then
        (
            local shouldSelect = queryBox
            (
                "发现具有额外UV通道的模型，共有" +
                (objectsWithExtraMapChannels.count as string) +
                "个，是否选中？"
            )

            if shouldSelect do
                select objectsWithExtraMapChannels
        )

        -- 返回检查结果，方便其他工具继续使用。
        objectsWithExtraMapChannels
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
		local objectsWithUnexpectedModifiers = #()

		for obj in geometry do
		(
			local modifierCount = obj.modifiers.count
			local hasUnexpectedModifier =
				modifierCount > 1 or
				(
					modifierCount == 1 and
					classof obj.modifiers[1] != Skin
				)

			if hasUnexpectedModifier do
				append objectsWithUnexpectedModifiers obj
		)

		if objectsWithUnexpectedModifiers.count > 0 then
		(
			local shouldSelect = queryBox
			(
				"发现存在多余修改器的模型，共有" +
				(objectsWithUnexpectedModifiers.count as string) +
				"个。\n\n允许的情况：没有修改器，或者只有一个 Skin。\n\n是否选中这些模型？"
			)

			if shouldSelect do
				selectMore objectsWithUnexpectedModifiers
		)

		-- 返回检查结果，方便其他工具继续使用。
		objectsWithUnexpectedModifiers
	),

    -- 检查模型轴向是否Y轴向上
	fn objAxis rotationTolerance:0.01 positionTolerance:1e-4 =
	(
		local expectedRotation = normalize (quat 90 [1, 0, 0])
		local validRotationTolerance = abs rotationTolerance
		local validPositionTolerance = abs positionTolerance
		local objectsWithTransformIssues = #()

		for obj in objects where classof obj.baseobject == Editable_Poly do
		(
			local currentRotation = normalize obj.rotation
			local rotationDelta = normalize (currentRotation * (inverse expectedRotation))
			local rotationDifference = abs rotationDelta.angle

			-- 同一个旋转可能显示为0度或360度，统一取较小的角度差。
			if rotationDifference > 180.0 do
				rotationDifference = abs (360.0 - rotationDifference)

			local rotationIsValid = rotationDifference <= validRotationTolerance
			local positionIsValid =
				abs obj.position.x <= validPositionTolerance and
				abs obj.position.y <= validPositionTolerance and
				abs obj.position.z <= validPositionTolerance

			if not rotationIsValid or not positionIsValid do
				append objectsWithTransformIssues obj
		)

		if objectsWithTransformIssues.count > 0 then
		(
			local shouldSelect = queryBox
			(
				"发现轴向或位置不符合要求的模型，共有" +
				(objectsWithTransformIssues.count as string) +
				"个。\n\n要求：绕 X 轴旋转 90 度，并且位置在原点附近。\n\n是否选中这些模型？"
			)

			if shouldSelect do
				selectMore objectsWithTransformIssues
		)

		-- 返回检查结果，方便其他工具继续使用。
		objectsWithTransformIssues
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
