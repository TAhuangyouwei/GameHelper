/*


这段代码是一个针对 Autodesk 3ds Max 的MaxScript脚本，主要功能包括获取特定对象的非零自定义属性值、检查Dummy对象是否包含特定变量，并在用户界面上展示相关信息。代码中使用了一系列的全局变量、函数和Rollout界面元素，以及对这些元素的事件处理，以实现其功能。

- **全局变量**：用于整个脚本中存储和传递信息。
- **函数**：执行特定任务，如检查对象属性、提取信息等。
- **Rollout定义**：用于创建用户界面，使用户能够与脚本交互。

代码中的注释提供了对每个部分功能和工作原理的说明，帮助理解脚本的整体结构和逻辑。



*/


-- 尝试销毁已经存在的对话框，以避免重复创建
try(destroyDialog ::nonZeroSpinnerRollout) catch()
try(destroyDialog ::floatScriptsRollout) catch()

-- 函数: 获取非零的自定义属性值
fn getNonZeroSpinnerValues obj =
(
    if not isValidNode obj do return #() -- 检查obj是否为有效的节点
    local nonZeroValues = #() -- 存储非零值的数组
    local custAttributesList = custAttributes.getDefs obj -- 获取对象的自定义属性定义

    -- 遍历自定义属性定义
    if custAttributesList != undefined then
    (
        for custAttrDef in custAttributesList do
        (
            local custAttrData = custAttributes.get obj custAttrDef -- 获取自定义属性数据
            if custAttrData != undefined do
            (
                local propNames = getPropNames custAttrData -- 获取属性名称
                -- 遍历所有属性
                for propName in propNames do
                (
                    local propValue = getProperty custAttrData propName -- 获取属性值
                    try
                    (
                        -- 如果属性是浮点数且非零，则添加到数组中
                        if classOf propValue == Float and abs(propValue) > 0.01 do
                        (
                            local formattedValue = (floor(propValue * 100 + 0.5)) / 100.0 -- 格式化值
                            append nonZeroValues ((propName as string) + ": " + (formattedValue as string))
                        )
                    ) catch()
                )
            )
        )
    )
    nonZeroValues -- 返回非零值数组
)



fn isString s =
(
	if findString s "AC_" != undefined then 
		return true 
	else
		return false


)


-- 函数: 检查Dummy对象是否包含特定变量
fn doesDummyHaveVariable dummyObj varName =
(
    if classOf dummyObj == Dummy do
    (
        -- 检查位置控制器的各个轴
        if isProperty dummyObj #position do
        (
            local posController = dummyObj.position.controller
            if classOf posController == Position_XYZ do
            (
                local posControllers = #(posController.x_position.controller, posController.y_position.controller, posController.z_position.controller)
                -- 遍历位置控制器
                for ctrl in posControllers do
                (
                    if classOf ctrl == Float_Script do
                    (
						varNames = filterString ctrl.script "+-*()"  -------------------------标记
						newVarName = "AC_" + varName
						for i = 1 to varNames.count do 
						(
							if varNames[i] == newVarName do 
							(
								print varNames[i]
								print newVarName
								return true
							)
						)
                        
                    )
                )
            )
        )

        -- 检查旋转控制器的各个轴
        if isProperty dummyObj #rotation do
        (
            local rotController = dummyObj.rotation.controller
            if classOf rotController == Euler_XYZ do
            (
                local rotControllers = #(rotController.x_rotation.controller, rotController.y_rotation.controller, rotController.z_rotation.controller)
                -- 遍历旋转控制器
                for ctrl in rotControllers do
                (
                    if classOf ctrl == Float_Script do
                    (
						varNames = filterString ctrl.script "+-*()"  -------------------------标记
						newVarName = "AC_" + varName
						for i = 1 to varNames.count do 
						(
							if varNames[i] == newVarName do 
							(
								print varNames[i]
								print newVarName
								return true
							)
						)
                        
                    )
                )
            )
        )
    )
    false
)

-- 函数定义: 将控制器脚本添加到列表
fn addScriptToList controller axisName varNames scriptsList objName =
(
	if classOf controller == Float_Script then 
	(
		for varName in varNames do
		(
			if findString controller.script varName != undefined then 
			(
			-- 如果找到对应的变量，则添加到脚本列表
			append scriptsList (objName + "|" + axisName + "|" + controller.script)
			break -- 找到后终止循环
			)
		)
	)
	else 
	(
		format "Warning: Controller on % is not a Float_Script.\n" axisName
	)
)


fn getUpdatedScriptList varNames =
(
    local scriptsList = #() -- 用于存储与选定变量相关的脚本

    -- 遍历每个变量名
    for varName in varNames do
    (
        -- 遍历场景中的所有Dummy对象
        for obj in objects where classOf obj == Dummy do
        (
            -- 如果Dummy对象包含该变量，处理其控制器脚本
            if doesDummyHaveVariable obj varName do
            (
                local objName = obj.name
				
				
                -- 先将Dummy物体的名称作为单独的列表项添加
                append scriptsList objName

                -- 检查位置控制器
                if isProperty obj #position do
                (
                    local posController = obj.position.controller
                    if classOf posController == Position_XYZ do
                    (
                        -- 添加每个轴的脚本到列表
                        addScriptToList posController.x_position.controller "x_position" varNames scriptsList objName
                        addScriptToList posController.y_position.controller "y_position" varNames scriptsList objName
                        addScriptToList posController.z_position.controller "z_position" varNames scriptsList objName
                    )
                )

                -- 检查旋转控制器
                if isProperty obj #rotation do
                (
                    local rotController = obj.rotation.controller
                    if classOf rotController == Euler_XYZ do
                    (
                        -- 添加每个轴的脚本到列表
                        addScriptToList rotController.x_rotation.controller "x_rotation" varNames scriptsList objName
                        addScriptToList rotController.y_rotation.controller "y_rotation" varNames scriptsList objName
                        addScriptToList rotController.z_rotation.controller "z_rotation" varNames scriptsList objName
                    )
                )

                -- 检查缩放控制器
                if isProperty obj #scale do
                (
                    local scaleController = obj.scale.controller
                    if classOf scaleController == Scale_XYZ do
                    (
                        -- 添加每个轴的脚本到列表
                        addScriptToList scaleController.x_scale.controller "x_scale" varNames scriptsList objName
                        addScriptToList scaleController.y_scale.controller "y_scale" varNames scriptsList objName
                        addScriptToList scaleController.z_scale.controller "z_scale" varNames scriptsList objName
                    )
                )
            )
        )
    )
    scriptsList -- 返回收集到的脚本列表
)



-- 函数: 从列表项中提取变量名称
fn getVarNameFromItem item =
(
    local splitItem = filterString item ":"
    if splitItem.count > 0 then return trimRight splitItem[1] else ""
)

-- 函数: 根据变量名称获得Dummy对象
fn getDummiesBasedOnVariables varNames =
(
    for varName in varNames do
    (
        varObj = for obj in objects where (classOf obj == Dummy and doesDummyHaveVariable obj varName ) collect obj
		return varObj
    )
)


	-- 函数: 获取名称相同的通道序列
fn getSameName VarName =
(
    local obj = $Animcraft_Master_GRP
    if not isValidNode obj do return 0

    local targetName = replace VarName 1 3 ""
    print ("Looking for: " + targetName)

    local custAttributesList = custAttributes.getDefs obj
    if custAttributesList != undefined then
    (
        for custAttrDef in custAttributesList do
        (
            local custAttrData = custAttributes.get obj custAttrDef
            if custAttrData != undefined do
            (
                local propNames = getPropNames custAttrData
                for i = 1 to propNames.count do
                (
                    local propNameAsString = propNames[i] as string
                    if propNameAsString == targetName do
                    (
                        return i
                    )
                )
            )
        )
    )
    0
)


-- 全局变量定义
global selectedValue = undefined  -- 存储Non-Zero Spinners选中的变量名
global selectedScript  -- 存储float script 选中的文本内容
global selectedScriptIndex    -- 存储float script 选中脚本的索引
global updatedScript = "" -- 存储更新后的脚本
global modifyScript -- 存储要修改的脚本
global listNum  -- 存储列表中选中项的编号
global dummyController = undefined  --存储物体的脚本控制器
global updatedScriptList = #()

-- rollout定义: 编辑浮点脚本对话框
rollout editFloatScriptRollout "Edit Float Script" width:300 height:120
(
	-- 文本编辑框用于显示和编辑脚本
	editText edtScript "Script" width:280 height:60 pos:[10,10] multiline:true
	-- 保存按钮，用于保存编辑后的脚本
	button btnSave "Save" width:280 height:20 pos:[10,80]
	-- 当对话框打开时，初始化脚本编辑框的内容
	on editFloatScriptRollout open do
	(
		if selectedScript != undefined do
		(
			edtScript.text = modifyScript -- 使用选中的脚本初始化编辑框
		)
	)

-- 当点击保存按钮时执行的操作
	on btnSave pressed do
	(
		if selectedScript != undefined then  
		(
				-- 获取并选择相关的Dummy对象
			local dummyName = (filterString selectedScript "|")[1]
			local theDummy = getNodeByName dummyName
			if theDummy != undefined then 
			(
				local axisFloatScriptName  = (filterString selectedScript "|")[2]
				local posController = theDummy.position.controller
				local rotController = theDummy.rotation.controller
				local scaleController = theDummy.scale.controller
				
				if findString axisFloatScriptName "position" != undefined then
				(
					if isProperty theDummy #position and classOf theDummy.position.controller == Position_XYZ do
					(
						local posController = theDummy.position.controller
						if findString axisFloatScriptName "x" != undefined and classOf posController.x_position.controller == Float_Script do
							dummyController = posController.x_position.controller
						if findString axisFloatScriptName "y" != undefined and classOf posController.y_position.controller == Float_Script do
							dummyController = posController.y_position.controller
						if findString axisFloatScriptName "z" != undefined and classOf posController.z_position.controller == Float_Script do
							dummyController = posController.z_position.controller
					)
				)
				else if findString axisFloatScriptName "rotation" != undefined then
				(
					if isProperty theDummy #rotation and classOf theDummy.rotation.controller == Euler_XYZ do
					(
						local rotController = theDummy.rotation.controller
						if findString axisFloatScriptName "x" != undefined and classOf rotController.x_rotation.controller == Float_Script do
							dummyController = rotController.x_rotation.controller
						if findString axisFloatScriptName "y" != undefined and classOf rotController.y_rotation.controller == Float_Script do
							dummyController = rotController.y_rotation.controller
						if findString axisFloatScriptName "z" != undefined and classOf rotController.z_rotation.controller == Float_Script do
							dummyController = rotController.z_rotation.controller
					)
				)
				else if findString axisFloatScriptName "scale" != undefined then
				(
					if isProperty theDummy #scale and classOf theDummy.scale.controller == Scale_XYZ do
					(
						local scaleController = theDummy.scale.controller
						if findString axisFloatScriptName "x" != undefined and classOf scaleController.x_scale.controller == Float_Script do
							dummyController = scaleController.x_scale.controller
						if findString axisFloatScriptName "y" != undefined and classOf scaleController.y_scale.controller == Float_Script do
							dummyController = scaleController.y_scale.controller
						if findString axisFloatScriptName "z" != undefined and classOf scaleController.z_scale.controller == Float_Script do
							dummyController = scaleController.z_scale.controller
					)
					
				)
				
				if dummyController != undefined then
				(
					oldScript = dummyController.script
					
					-- 对选中脚本进行重新格式化
					local words = (filterString selectedScript "|+")
					if listNum != undefined then 
						words[listNum] = edtScript.text

					-- 重构脚本字符串
					newstr = ""
					for i = 3 to words.count do (
						newstr += words[i] + "+"
					)
					newstr = trimRight newstr "+" -- 移除最后一个多余的加号

					dummyController.script = newstr
					updatedScript  = newstr
					
					if selectedValue != undefined then 
					(
						-- 构建包含所需变量名的数组
						local varNames = #(selectedValue)
						
						-- 调用 getUpdatedScriptList 函数并传递数组
						updatedScriptList = getUpdatedScriptList varNames
					)
					
					destroyDialog editFloatScriptRollout -- 关闭编辑对话框
					
					 -- 更新floatScriptsRollout 的列表内容
					if floatScriptsRollout != undefined then
					(
						
						-- 重新设置列表项
						floatScriptsRollout.lstFloatScripts.items = updatedScriptList
						
					)
					
					redrawViews()
				)
				else messagebox "Controller not found."
				
				
				
			)
			else messagebox "Dummy object not found."
			
		)
		else messagebox "No script selected."
		
		
	)

)	

-- rollout定义: 浮点脚本列表显示
rollout floatScriptsRollout "Float Scripts" width:1900 height:340
(
	-- 列表框，用于显示所有的浮点脚本
	listBox lstFloatScripts "Scripts" width:1880 height:20 pos:[10,10]
	
	radioButtons 'rdo_trans' "Transform"   height:30 align:#left labels:#("Position", "Rotation", "Scale") columns:3 across:3
	
	radioButtons 'rdo_Axis' "Axis"   height:30 align:#left labels:#("X", "Y", "Z")  columns:3
	
	button btn_add "添加" width:200  height:30
	
	
	
	
	
	
	-- 更新列表中特定项的脚本
	fn updateFloatScriptItem index newScript =
	(
		if index != undefined and index > 0 and index <= lstFloatScripts.items.count do
		(
		lstFloatScripts.items[index] = newScript -- 更新列表项
		)
	)
	
	-- 当对话框打开时执行的操作
	on floatScriptsRollout open do
	(
		lstFloatScripts.width = 1880
		floatScriptsRollout.width = 1900
		if updatedScriptList.count > 0 do
        (
            lstFloatScripts.items = updatedScriptList
            updatedScriptList = #() -- 清空全局变量，避免重复更新
        )
	)


	
	on floatScriptsRollout resized size do
	(
		-- 计算新的列表宽度
        local newWidth = (size.x - 20)
		lstFloatScripts.width = newWidth
	)
	

	-- 当在列表中选择一个项时执行的操作
	on lstFloatScripts selected index do
	(
		selectedScript = lstFloatScripts.items[index]
		selectedScriptIndex = index
		
		-- 获取并选择相关的Dummy对象
		local dummyName = (filterString selectedScript "|")[1]
		local theDummy = getNodeByName dummyName
		if theDummy != undefined do select theDummy
			
		-- 从selectedScript解析modifyScript
		-- 获取选中脚本的所有部分
		local varScripts = (filterString selectedScript "|+")
		
		-- 遍历脚本的每个部分，查找与选中变量相关的脚本
		for i = 1 to varScripts.count do 
		(
			if findString varScripts[i] selectedValue != undefined then
			(
				modifyScript = varScripts[i]  -- 设置要修改的脚本
			)
		)
	)

	-- 当在列表中双击一个项时执行的操作
	on lstFloatScripts doubleClicked index do
	(
		selectedScriptIndex = index
		selectedScript = lstFloatScripts.items[index]
		
		-- 获取选中脚本的所有部分
		local varScripts = (filterString selectedScript "|+")
		
		-- 遍历脚本的每个部分，查找与选中变量相关的脚本
		newselectedValue = "AC_" + selectedValue
		for i = 1 to varScripts.count do 
		(
			if findString varScripts[i] newselectedValue != undefined then
			(
				subvarScripts = filterString varScripts[i] "*"
				
				--这里需要增加一个判断，让字符串相等

				for part in subvarScripts do
				(
					if isString part then
					(
						--这里需要增加一个判断，让字符串相等
						if part == newselectedValue then  -- 使用==来判断字符串是否完全相等
						(
							modifyScript = varScripts[i]  -- 设置要修改的脚本
							listNum = i  -- 记录列表中的位置
							try (DestroyDialog editFloatScriptRollout) catch()
							CreateDialog editFloatScriptRollout -- 打开编辑对话框
						)
					)
						
				)
				
			)
		)
	)
	
	on btn_add pressed do 
	(
		if selection.count == 1 and classof selection[1] == Dummy then 
		(
			local dummyObj = selection[1]
			local controller = dummyObj[3][rdo_trans.state][rdo_Axis.state].controller
			local custAttributesDefs =  $Animcraft_Master_GRP.custom_attributes
			
			if controller != undefined and classOf controller == Float_Script then
			(
				
				local newVarName = "AC_" + selectedValue
				

				if newVarName != undefined and modifyScript != undefined then
				(
					--这里可以正常执行
					
					local existingScript = controller.script
					
					custAttrDefNumber = getSameName newVarName
					
					if custAttrDefNumber != 0 then
					(
						controller.addTarget newVarName custAttributesDefs[custAttrDefNumber]
						
						
						if existingScript != undefined and classOf existingScript == String then
						(
							
							newModifyScript = (filterString modifyScript "*")  
							
							for part in newModifyScript do
							(
								if isString part then
								(
									local fixedPart = substituteString part ")" ""
									
									if fixedPart != undefined then  -- 确保fixedPart已定义
									(
										controller.script = existingScript + "+" + fixedPart
									)
								)
									
							)
						)
						else
						(
							messagebox "Existing script or modify script is invalid."
						)
						
					)
					
					-- 获取更新后的脚本列表
					updatedScriptList = getUpdatedScriptList #(selectedValue)  -- 假设selectedValue包含需要更新的变量名
					
					-- 调用函数刷新floatScriptsRollout的列表内容
					if floatScriptsRollout != undefined then
					(
						floatScriptsRollout.lstFloatScripts.items = updatedScriptList
					)
					f
					redrawViews()
					
				)
				else
				(
					messagebox "New variable name or modify script is undefined."
				)
				
			)
			else
			(
				messagebox "Selected controller is not a Float_Script or undefined. Cannot add the script."
			)
		)
		else
		(
			messagebox "Please select one Dummy object."
		)
	)






	
)




fn processController dummyObj controllerType varName =
(
    if isProperty dummyObj controllerType do
    (
        local controller = getProperty dummyObj controllerType
        if classOf controller == Position_XYZ or classOf controller == Euler_XYZ or classOf controller == Scale_XYZ do
        (
            local axesControllers = #(controller[1].controller, controller[2].controller, controller[3].controller)
            for ctrl in axesControllers do
            (
                if classOf ctrl == Float_Script and (findString ctrl.script varName) != undefined do
                    return true
            )
        )
    )
    false
)


-- 函数定义: 显示与选定变量相关的Dummy对象的浮点脚本
fn displayFloatScriptsOfSelectedDummies varNames =
(
	local scriptsList = #() -- 用于存储与选定变量相关的脚本
	
	-- 遍历每个变量名
	for varName in varNames do
	(
		-- 遍历场景中的所有Dummy对象
		for obj in objects where classOf obj == Dummy do
		(
			-- 如果Dummy对象包含该变量，处理其控制器脚本
			if doesDummyHaveVariable obj varName do
			(
				local objName = obj.name
				append scriptsList objName -- 将对象名称添加到列表

				-- 检查位置控制器
				if isProperty obj #position do
				(
					local posController = obj.position.controller
					if classOf posController == Position_XYZ do
					(
						-- 添加每个轴的脚本到列表
						addScriptToList posController.x_position.controller "x_position" varNames scriptsList objName
						addScriptToList posController.y_position.controller "y_position" varNames scriptsList objName
						addScriptToList posController.z_position.controller "z_position" varNames scriptsList objName
					)
				)

				-- 检查旋转控制器
				if isProperty obj #rotation do
				(
					local rotController = obj.rotation.controller
					if classOf rotController == Euler_XYZ do
					(
						-- 添加每个轴的脚本到列表
						addScriptToList rotController.x_rotation.controller "x_rotation" varNames scriptsList objName
						addScriptToList rotController.y_rotation.controller "y_rotation" varNames scriptsList objName
						addScriptToList rotController.z_rotation.controller "z_rotation" varNames scriptsList objName
					)
				)

				-- 检查缩放控制器
				if isProperty obj #scale do
				(
					local scaleController = obj.scale.controller
					if classOf scaleController == Scale_XYZ do
					(
						-- 添加每个轴的脚本到列表
						addScriptToList scaleController.x_scale.controller "x_scale" varNames scriptsList objName
						addScriptToList scaleController.y_scale.controller "y_scale" varNames scriptsList objName
						addScriptToList scaleController.z_scale.controller "z_scale" varNames scriptsList objName
					)
				)
			)
		)
	)
	-- 创建并显示脚本列表对话框
	createDialog floatScriptsRollout  style:#(#style_titlebar, #style_resizing, #style_sysmenu) autoLayoutOnResize:true  lockHeight:on 
	if floatScriptsRollout.lstFloatScripts != undefined do
	(
		floatScriptsRollout.lstFloatScripts.items = scriptsList -- 更新列表内容
	)

)	



-- Rollout定义: 非零旋钮
rollout nonZeroSpinnerRollout "Non-Zero Spinners" width:200 height:265
(
	button btnGetValues "Get Non-Zero Values" width:180 height:25 -- 获取非零值按钮
	listBox lstNonZeroValues "Values" width:180 height:10 pos:[10,35] -- 显示非零值的列表框
	button btnSelectDummies "Select Dummies" width:180 height:25 pos:[10,200] -- 选择Dummy对象的按钮
		
	label lblStatus "Status: Ready" -- 显示状态信息的标签
	label author "作者:黄友为" -- 作者信息标签
	
	-- 当点击获取非零值按钮时执行的操作
	on btnGetValues pressed do
	(
		local selectedObj = $Animcraft_Master_GRP -- 指定要检查的对象
		if isValidNode selectedObj then
		(
			lstNonZeroValues.items = getNonZeroSpinnerValues selectedObj -- 获取并显示非零值
			if lstNonZeroValues.items.count == 0 then
			(
				lblStatus.text = "No non-zero values found." -- 显示未找到非零值的信息
			)
			else lblStatus.text = "Non-zero values updated." -- 显示非零值更新的信息
		)
		else lblStatus.text = "Invalid or no object selected." -- 显示无效或未选择对象的信息
	)

	-- 当点击选择Dummy对象按钮时执行的操作
	on btnSelectDummies pressed do
	(
		if lstNonZeroValues.selected != undefined then
		(
			selectedValue = (FilterString lstNonZeroValues.selected ":")[1] -- 提取选中的变量名
			local selectedIndices = lstNonZeroValues.selection
			if classOf selectedIndices != Array do
				selectedIndices = #(selectedIndices)  -- 如果只选择了一个项，将其转换为数组

			-- 确保所有选中索引都是有效的（大于0）
			selectedIndices = for index in selectedIndices where index > 0 collect index

			if selectedIndices.count > 0 then
			(
				-- 提取并处理每个选中项对应的变量名
				local extractedVarNames = for index in selectedIndices collect getVarNameFromItem lstNonZeroValues.items[index]
				-- 根据变量名选择相关的Dummy对象，并显示其浮点脚本
				varObj = getDummiesBasedOnVariables extractedVarNames  --获取浮点脚本种含有变量的dummy物体
				displayFloatScriptsOfSelectedDummies extractedVarNames
			)
			else messagebox "Please select an item from the list."  -- 如果没有选中任何项，则显示提示信息      
		)
		else messagebox "No item is selected." -- 如果没有选中任何项，则显示提示信息
	)
	


)

-- 创建并显示非零旋钮对话框
createdialog nonZeroSpinnerRollout   


	
	