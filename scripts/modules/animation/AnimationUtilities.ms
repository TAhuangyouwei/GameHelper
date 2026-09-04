/*
    Biped 关键帧和旋转曲线处理功能。
    从 HYW_Scripts_Library.ms 拆出，保留原结构名和调用方式。
*/

struct AnimationUtilities
(
    -- 处理相邻关键帧比较的函数
    fn processBipedKeys controller node tolerance =
    (
        local count = numKeys controller
        for idx = 1 to count - 1 do
        (
            local thisKey = biped.getkey controller idx
            local nextKey = biped.getkey controller (idx + 1)

            thisKeyTime = thisKey.time
            nextKeyTime = nextKey.time

            at time thisKeyTime thisKeyTrans = node.transform
            at time nextKeyTime nextKeyTrans = node.transform

            local matricesAreEqual = true
            for i = 1 to 4 do
            (
                for j = 1 to 3 do
                (
                    if abs(thisKeyTrans[i][j] - nextKeyTrans[i][j]) > tolerance then
                    (
                        matricesAreEqual = false
                        exit
                    )
                )
                if not matricesAreEqual do exit
            )

            if matricesAreEqual then
            (
                node.transform
                thisKey.continuity = 0
                nextKey.continuity = 0
            )
        )
    ),

	fn setTCBContinuityForBipedObjects bipedObjs continuityValue =
	(
		for bipedObj in bipedObjs do
		(
			local count = numKeys bipedObj.controller

			-- 设置Biped骨骼的关键帧连续性
			if bipedObj.name != "Bip001" then
			(
				local biped_ctrl = bipedObj.controller
				for idx = 1 to count do
				(
					if isKeySelected biped_ctrl idx then
					(
						local bipkey = biped.getkey biped_ctrl idx
						bipkey.continuity = continuityValue
					)
				)
			)
			else
			(
				-- 处理Bip001的特殊情况
				local controllers = #(bipedObj.controller.vertical.controller, bipedObj.controller.horizontal.controller, bipedObj.controller.turning.controller)
				for ctrl in controllers do
				(
					for idx = 1 to numKeys ctrl do
					(
						if isKeySelected ctrl idx then
						(
							local bipkey = biped.getkey ctrl idx
							bipkey.continuity = continuityValue
						)
					)
				)
			)
		)
	),

	fn processSingleBipedObject bipedObj tolerance =
	(
		if bipedObj.name != "Bip001" then
		(
			AnimationUtilities.processBipedKeys bipedObj.controller bipedObj tolerance
		)
		else
		(
			AnimationUtilities.processBipedKeys bipedObj.controller.vertical.controller bipedObj tolerance
			AnimationUtilities.processBipedKeys bipedObj.controller.horizontal.controller bipedObj tolerance
			AnimationUtilities.processBipedKeys bipedObj.controller.turning.controller bipedObj tolerance
		)
	),

	-- 将所选物体指定轴的旋转关键帧设置为同一个值
	fn flattenRotationAxisKeys nodes axisIndex targetValueText timeRange:animationRange createHold:true =
	(
		if nodes == undefined then
		(
			messageBox "请先选择需要处理的物体。" title:"旋转曲线打平"
			return false
		)

		if nodes.count == 0 then
		(
			messageBox "请先选择需要处理的物体。" title:"旋转曲线打平"
			return false
		)

		if axisIndex < 1 or axisIndex > 3 then
		(
			messageBox "旋转轴编号无效，请选择 X、Y 或 Z。" title:"旋转曲线打平"
			return false
		)

		local targetValue = try (targetValueText as float) catch undefined
		if targetValue == undefined then
		(
			messageBox "目标值不是有效数字。" title:"旋转曲线打平"
			return false
		)

		local jobs = #()
		local skippedNodeCount = 0
		local targetKeyCount = 0

		for obj in nodes where isValidNode obj do
		(
			local rotationController = obj.rotation.controller
			local xyzControllers = try (getXYZControllers rotationController) catch undefined
			local axisProperties = undefined

			if isProperty rotationController #x_rotation then
				axisProperties = #(#x_rotation, #y_rotation, #z_rotation)
			else if isProperty rotationController #local_x_rotation then
				axisProperties = #(#local_x_rotation, #local_y_rotation, #local_z_rotation)

			if xyzControllers == undefined then
			(
				skippedNodeCount += 1
			)
			else if xyzControllers.count < axisIndex or axisProperties == undefined then
			(
				skippedNodeCount += 1
			)
			else
			(
				local axisController = xyzControllers[axisIndex]
				local keyTimesInRange = #()

				for key in axisController.keys where \
					key.time >= timeRange.start and key.time <= timeRange.end do
				(
					append keyTimesInRange key.time
				)

				if keyTimesInRange.count > 0 do
				(
					append jobs #(rotationController, axisProperties[axisIndex], keyTimesInRange)
					targetKeyCount += keyTimesInRange.count
				)
			)
		)

		if targetKeyCount == 0 then
		(
			messageBox "当前动画范围内没有找到可处理的旋转关键帧。" title:"旋转曲线打平"
			return false
		)

		if createHold then
		(
			local holdSucceeded = try (holdMaxFile(); true) catch false
			if not holdSucceeded then
			(
				messageBox "无法创建 Hold 备份，操作已取消。" title:"旋转曲线打平"
				return false
			)
		)

		undo "打平旋转曲线" on
		(
			with animate on
			(
				for job in jobs do
				(
					local rotationController = job[1]
					local axisProperty = job[2]

					for keyTime in job[3] do
					(
						at time keyTime setProperty rotationController axisProperty targetValue
					)
				)
			)
		)

		redrawViews()

		local resultMessage = "已处理 " + (targetKeyCount as string) + " 个旋转关键帧。"
		if skippedNodeCount > 0 do
			resultMessage += "\n跳过 " + (skippedNodeCount as string) + " 个不支持 XYZ 旋转轴的物体。"

		messageBox resultMessage title:"旋转曲线打平"
		true
	)


)
