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
	fn scaleCheck =
	(
		tempScale = for obj in objects where classof obj.baseobject == Editable_Poly and isProperty obj #scale and (abs(obj.scale.x - 1) > e^-5 or abs(obj.scale.y - 1) > e^-5 or abs(obj.scale.z - 1) > e^-5) collect obj
		if tempScale.count != 0 then
		(
			cd = queryBox ("缩放有问题的模型数量有" + (tempScale.count as string) + "个，是否选中缩放有问题的模型")
			if cd == true then selectmore tempScale
		)
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

	--模型命名检查

	fn nameCheck =
	(
		-- 收集所有的几何体对象，这里我们关注的是可编辑多边形
		nameObjs = for obj in geometry where classof obj.baseobject == Editable_Poly collect obj

		fileNumber = (filterString (getFilenameFile(maxFileName)) "_")

		-- 遍历这些对象
		for obj in nameObjs do
		(
			local errorFound = false

			if (filterString obj.name "_")[1] == fileNumber[1] and (filterString obj.name "_")[2] == fileNumber[2] and (filterString obj.name "_")[3] == fileNumber[3] and errorFound == false then
			(
				continue
			)
			else
			(
				-- 如果所有的条件都不符合，则说明发现了错误
				messageBox (obj.name + " 命名错误，请检查！")
				errorFound = true
			)
			-- 检查模型是否包含指定的后缀
			if errorFound == false then
			(
				if (findString obj.name "_body" != undefined) then
				(
					-- 匹配到正确的名字后缀
					continue
				)
				else if (findString obj.name "_hair" != undefined) then
				(
					continue
				)
				else if (findString obj.name "_head" != undefined) then
				(
					continue
				)

				else if (findString obj.name "_eyeShadows" != undefined and findString (getFilenameFile(maxFileName)) "_lod" == undefined) then
				(
					continue
				)
				else
				(
					-- 如果所有的条件都不符合，则说明发现了错误
					messageBox (obj.name + " 命名错误，请检查！")
					errorFound = true
				)

			)

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
	fn CreateFloor state width:600 height:600 depth:-3 = --添加参数
    (
        if state == on then
        (
            local layer = LayerManager.getLayerFromName "floor"
            if layer == undefined then
            (
                layer = LayerManager.newLayerFromName "floor"
            )

            local animFloor = box length:width width:height height:depth name:"Floor"
            animFloor.mat = standard()
            layer.addnodes animFloor
        )
        else if $Floor != undefined then
        (
            delete $Floor
            LayerManager.deleteLayerByName "floor"
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
