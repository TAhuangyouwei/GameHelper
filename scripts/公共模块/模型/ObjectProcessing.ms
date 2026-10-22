/*
    所选物体和轴心处理功能。
    从 HYW_Scripts_Library.ms 拆出，保留原结构名和调用方式。
*/

struct ObjectProcessing
(
    -- 定义一个旋转坐标轴的函数
	fn RotatePivotOnly obj rotation =
	(
		local rotValInv = inverse (rotation as quat)
		animate off in coordsys local obj.rotation *= rotValInv
		obj.objectoffsetpos *= rotValInv
		obj.objectoffsetrot *= rotValInv
	),
	-- 生成或验证temp.env文件的存在
	fn EnsureEnvFileExists =
	(
		local envPath = (getDir #userscripts) + "\\temp.env"
		if not doesFileExist envPath do
		(
			local file = createFile envPath
			close file
		)
		return envPath
	),
	-- 主函数处理选择的对象
	fn ProcessSelectedObjects =
	(
		local envPath = EnsureEnvFileExists()

		for obj in selection do
		(
			if obj.modifiers[#Skin] != undefined then
			(
				-- 保存和加载Skin修改器的包络，并转换对象
				sliderTime = 0
				skinOps.SaveEnvelope obj.modifiers[#Skin] envPath
				local boneArr = skinOps.GetBoneNodes obj.skin
				convertToPoly obj
				if obj.rotation == (quat 0 0 0 1) then RotatePivotOnly obj (EulerAngles 90 0 0)

				-- 重新添加Skin修改器并设置骨骼
				addModifier obj (skin())
				for i = 1 to boneArr.count do
				(
					if i == boneArr.count then
						skinOps.addbone obj.modifiers[#Skin] boneArr[i] -1
					else
						skinOps.addbone obj.modifiers[#Skin] boneArr[i] 0
				)
				skinOps.loadEnvelope obj.modifiers[#Skin] envPath
				obj.modifiers[#Skin].bone_Limit = 4
			)
			else
			(
				-- 处理没有Skin修改器的对象
				sliderTime = 0
				convertToPoly obj
				if obj.rotation == (quat 0 0 0 1) then RotatePivotOnly obj (EulerAngles 90 0 0)
			)
		)

		gw.updateScreen()
	),

	fn getObjLength =
	(
		if selection.count != 0 then
		(
			stratPoint = selection[1].transform.pos
			if selection[1].children[1] != undefined then
				endPoint = selection[1].children[1].transform.pos

			objlength = distance stratPoint endPoint
			return objlength
		)
	)
)
