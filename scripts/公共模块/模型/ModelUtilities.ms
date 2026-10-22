/*
    模型重置和点路径相关功能。
    从 HYW_Scripts_Library.ms 拆出，保留原结构名和调用方式。
*/

struct ModelUtilities
(
    -- 功能：确保env文件存在
    fn ensureEnvFileExists =
    (
        local envPath = getdir #userscripts + "\\temp.env"
        if not doesFileExist envPath do
        (
            local file = createFile envPath
            close file
        )
        return envPath
    ),

	-- 功能：处理单个模型
	fn processModel obj applyCenterPivot envPath =
	(
		-- 提取的共用代码部分
		fn createTempModelFrom obj applyCenterPivot tempName =
		(
			for j = 1 to obj.modifiers.count do collapseStack obj
			local tempModel = convertToPoly(box())
			tempModel.EditablePoly.attach obj tempModel
			tempModel.EditablePoly.SetSelection #Face #{1..6}
			tempModel.EditablePoly.delete #Face
			tempModel.name = tempName
			if applyCenterPivot then CenterPivot tempModel else tempModel.pivot = [0,0,0]
			return tempModel
		)

		-- 处理逻辑
		local tempName = copy obj.name
		if obj.modifiers[#skin] == undefined then
		(
			-- 当没有Skin修改器时的处理
			createTempModelFrom obj applyCenterPivot tempName
		)
		else
		(
			-- 当有Skin修改器时的处理
			sliderTime = 0
			local boneArr = skinOps.GetBoneNodes obj.skin
			skinOps.SaveEnvelope obj.modifiers[#Skin] envPath
			local tempModel = createTempModelFrom obj applyCenterPivot tempName
			addModifier tempModel (skin())
			for k = 1 to boneArr.count do
			(
				local addBoneMethod = if k == boneArr.count then -1 else 0
				skinOps.addbone tempModel.modifiers[#Skin] boneArr[k] addBoneMethod
			)
			skinOps.loadEnvelope tempModel.modifiers[#Skin] envPath
			tempModel.modifiers[#Skin].bone_Limit = 4
		)
	),

    -- 主函数：重置模型材质
    fn ResetMaterialsOfModel applyCenterPivot:false =
    (
        local envPath = ensureEnvFileExists()
        local targetModel = if selection.count == 0 then objects else selection

        for obj in targetModel where classof obj.baseobject == Editable_Poly and obj.faces.count != 0 do
        (
            processModel obj applyCenterPivot envPath
        )
    ),


	fn pointPath =
	(
		obj = (for obj in geometry where (obj.modifiers[#Edit_Mesh] != undefined or classof obj == Editable_mesh) collect obj )[1]

		if obj != undefined then
		(
			num = (getVertSelection obj as array)[1]
			pt = point axistripod:on box:on cross:off color:blue name:"path_point"
			animate on
			for i = animationRange.start to animationRange.end do
			(
				at time i pt.dir = getnormal obj num
				at time i pt.pos = getVert obj num
			)
			subobjectLevel = 0
			select pt
		)
		else
		(
			result = queryBox "点轨迹只对mesh物体有效，是否给当前物体增加一个edit_mesh修改器?"

			if result then
			(
				if selection.count != 0 do
				(
					max modify mode
					obj = selection[1]
					addModifier obj (Edit_Mesh())
					subObjectLevel = 1
					pointPath() -- 递归调用
				)
			)
		)
	)
)
