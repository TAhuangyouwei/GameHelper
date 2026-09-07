/*
    AnimCraft Float Script Manager V4.5
    Author: 黄友为

    V4.5
    ------------------------------------------------------------
    1. 保留 V4 Group UI

    2. XYZ Checkbox：
       Float Script + 已包含当前变量
           -> 灰色不可选

       Float Script + 未包含当前变量
           -> 可以选择

       非 Float Script
           -> 可以选择
           -> 添加时自动创建 Float Script

    3. Scale 使用 ScaleXYZ

    4. Scale 转 Float Script 时：
       不再读取旧 Scale Controller.value
       强制初始 Expression = 1.0

       Position = 0.0 基准
       Rotation = 0.0 基准
       Scale    = 1.0 基准

    5. 添加成功后自动选择新添加的 Track

    6. 多条添加时：
       自动选择第一条成功添加的 Track
       X -> Y -> Z

    7. 保留 Biped / HeadNub 安全处理
*/


------------------------------------------------------------
-- 清理
------------------------------------------------------------

try (callbacks.removeScripts id:#AnimCraftFloatAxisState) catch()

try (destroyDialog ::nonZeroSpinnerRollout) catch()
try (destroyDialog ::floatScriptsRollout) catch()
try (destroyDialog ::editFloatScriptRollout) catch()


------------------------------------------------------------
-- 全局变量
------------------------------------------------------------

global selectedValue = undefined
global selectedScript = undefined
global modifyScript = undefined
global updatedScript = ""
global dummyController = undefined
global currentFloatScriptVarNames = #()


------------------------------------------------------------
-- 安全获取 Position Controller
------------------------------------------------------------

fn safeGetPositionController obj =
(
    local ctrl = undefined

    if isValidNode obj do
    (
        try
        (
            if isProperty obj #position do
            (
                ctrl = obj.position.controller
            )
        )
        catch()
    )

    ctrl
)


------------------------------------------------------------
-- 安全获取 Rotation Controller
------------------------------------------------------------

fn safeGetRotationController obj =
(
    local ctrl = undefined

    if isValidNode obj do
    (
        try
        (
            if isProperty obj #rotation do
            (
                ctrl = obj.rotation.controller
            )
        )
        catch()
    )

    ctrl
)


------------------------------------------------------------
-- 安全获取 Scale Controller
------------------------------------------------------------

fn safeGetScaleController obj =
(
    local ctrl = undefined

    if isValidNode obj do
    (
        try
        (
            if isProperty obj #scale do
            (
                ctrl = obj.scale.controller
            )
        )
        catch()
    )

    ctrl
)


------------------------------------------------------------
-- 获取非零 Custom Attribute
------------------------------------------------------------

fn getNonZeroSpinnerValues obj =
(
    if not isValidNode obj do return #()

    local nonZeroValues = #()
    local custAttributesList = custAttributes.getDefs obj

    if custAttributesList != undefined then
    (
        for custAttrDef in custAttributesList do
        (
            local custAttrData = custAttributes.get obj custAttrDef

            if custAttrData != undefined do
            (
                local propNames = getPropNames custAttrData

                for propName in propNames do
                (
                    local propValue = getProperty custAttrData propName

                    try
                    (
                        if classOf propValue == Float and abs(propValue) > 0.01 do
                        (
                            local formattedValue = (floor(propValue * 100 + 0.5)) / 100.0
                            local displayText = (propName as string) + ": " + (formattedValue as string)

                            append nonZeroValues displayText
                        )
                    )
                    catch()
                )
            )
        )
    )

    nonZeroValues
)


------------------------------------------------------------
-- 是否包含 AC_
------------------------------------------------------------

fn isACString s =
(
    if s == undefined then
    (
        false
    )
    else
    (
        if findString s "AC_" != undefined then true else false
    )
)


------------------------------------------------------------
-- Float Script 是否包含完整变量
------------------------------------------------------------

fn floatScriptHasVariable scriptText varName =
(
    if scriptText == undefined do return false
    if varName == undefined do return false

    local fullVarName = "AC_" + varName
    local tokens = filterString scriptText "+-*/^() \t\r\n"

    for token in tokens do
    (
        if token == fullVarName do
        (
            return true
        )
    )

    false
)


------------------------------------------------------------
-- 根据 Axis Key 获取 Controller
------------------------------------------------------------

fn getDummyFloatController dummyObj axisKey =
(
    if not isValidNode dummyObj do return undefined

    local resultCtrl = undefined


    --------------------------------------------------------
    -- Position
    --------------------------------------------------------

    if axisKey == "x_position" or axisKey == "y_position" or axisKey == "z_position" then
    (
        local posCtrl = safeGetPositionController dummyObj

        if posCtrl != undefined do
        (
            if classOf posCtrl == Position_XYZ do
            (
                try
                (
                    if axisKey == "x_position" then
                    (
                        resultCtrl = posCtrl.x_position.controller
                    )
                    else if axisKey == "y_position" then
                    (
                        resultCtrl = posCtrl.y_position.controller
                    )
                    else if axisKey == "z_position" then
                    (
                        resultCtrl = posCtrl.z_position.controller
                    )
                )
                catch()
            )
        )
    )


    --------------------------------------------------------
    -- Rotation
    --------------------------------------------------------

    else if axisKey == "x_rotation" or axisKey == "y_rotation" or axisKey == "z_rotation" then
    (
        local rotCtrl = safeGetRotationController dummyObj

        if rotCtrl != undefined do
        (
            if classOf rotCtrl == Euler_XYZ do
            (
                try
                (
                    if axisKey == "x_rotation" then
                    (
                        resultCtrl = rotCtrl.x_rotation.controller
                    )
                    else if axisKey == "y_rotation" then
                    (
                        resultCtrl = rotCtrl.y_rotation.controller
                    )
                    else if axisKey == "z_rotation" then
                    (
                        resultCtrl = rotCtrl.z_rotation.controller
                    )
                )
                catch()
            )
        )
    )


    --------------------------------------------------------
    -- Scale
    --------------------------------------------------------

    else if axisKey == "x_scale" or axisKey == "y_scale" or axisKey == "z_scale" then
    (
        local scaleCtrl = safeGetScaleController dummyObj

        if scaleCtrl != undefined do
        (
            if classOf scaleCtrl == ScaleXYZ do
            (
                try
                (
                    if axisKey == "x_scale" then
                    (
                        resultCtrl = scaleCtrl.x_scale.controller
                    )
                    else if axisKey == "y_scale" then
                    (
                        resultCtrl = scaleCtrl.y_scale.controller
                    )
                    else if axisKey == "z_scale" then
                    (
                        resultCtrl = scaleCtrl.z_scale.controller
                    )
                )
                catch()
            )
        )
    )


    resultCtrl
)


------------------------------------------------------------
-- Transform + Axis 获取 Controller
------------------------------------------------------------

fn getTransformAxisController dummyObj transformIndex axisIndex =
(
    if not isValidNode dummyObj do return undefined

    local axisKey = ""


    if transformIndex == 1 then
    (
        if axisIndex == 1 do axisKey = "x_position"
        if axisIndex == 2 do axisKey = "y_position"
        if axisIndex == 3 do axisKey = "z_position"
    )
    else if transformIndex == 2 then
    (
        if axisIndex == 1 do axisKey = "x_rotation"
        if axisIndex == 2 do axisKey = "y_rotation"
        if axisIndex == 3 do axisKey = "z_rotation"
    )
    else if transformIndex == 3 then
    (
        if axisIndex == 1 do axisKey = "x_scale"
        if axisIndex == 2 do axisKey = "y_scale"
        if axisIndex == 3 do axisKey = "z_scale"
    )


    if axisKey == "" then
    (
        undefined
    )
    else
    (
        getDummyFloatController dummyObj axisKey
    )
)


------------------------------------------------------------
-- Transform + Axis -> AxisKey
------------------------------------------------------------

fn getAxisKeyByIndex transformIndex axisIndex =
(
    local axisKey = undefined


    if transformIndex == 1 then
    (
        if axisIndex == 1 do axisKey = "x_position"
        if axisIndex == 2 do axisKey = "y_position"
        if axisIndex == 3 do axisKey = "z_position"
    )
    else if transformIndex == 2 then
    (
        if axisIndex == 1 do axisKey = "x_rotation"
        if axisIndex == 2 do axisKey = "y_rotation"
        if axisIndex == 3 do axisKey = "z_rotation"
    )
    else if transformIndex == 3 then
    (
        if axisIndex == 1 do axisKey = "x_scale"
        if axisIndex == 2 do axisKey = "y_scale"
        if axisIndex == 3 do axisKey = "z_scale"
    )


    axisKey
)


------------------------------------------------------------
-- 设置 Axis Controller
------------------------------------------------------------

fn setTransformAxisController dummyObj transformIndex axisIndex newController =
(
    if not isValidNode dummyObj do return false
    if newController == undefined do return false

    local success = false


    --------------------------------------------------------
    -- Position
    --------------------------------------------------------

    if transformIndex == 1 then
    (
        local posCtrl = safeGetPositionController dummyObj

        if posCtrl != undefined do
        (
            if classOf posCtrl == Position_XYZ do
            (
                try
                (
                    if axisIndex == 1 then
                    (
                        posCtrl.x_position.controller = newController
                        success = true
                    )
                    else if axisIndex == 2 then
                    (
                        posCtrl.y_position.controller = newController
                        success = true
                    )
                    else if axisIndex == 3 then
                    (
                        posCtrl.z_position.controller = newController
                        success = true
                    )
                )
                catch()
            )
        )
    )


    --------------------------------------------------------
    -- Rotation
    --------------------------------------------------------

    else if transformIndex == 2 then
    (
        local rotCtrl = safeGetRotationController dummyObj

        if rotCtrl != undefined do
        (
            if classOf rotCtrl == Euler_XYZ do
            (
                try
                (
                    if axisIndex == 1 then
                    (
                        rotCtrl.x_rotation.controller = newController
                        success = true
                    )
                    else if axisIndex == 2 then
                    (
                        rotCtrl.y_rotation.controller = newController
                        success = true
                    )
                    else if axisIndex == 3 then
                    (
                        rotCtrl.z_rotation.controller = newController
                        success = true
                    )
                )
                catch()
            )
        )
    )


    --------------------------------------------------------
    -- Scale
    --------------------------------------------------------

    else if transformIndex == 3 then
    (
        local scaleCtrl = safeGetScaleController dummyObj

        if scaleCtrl != undefined do
        (
            if classOf scaleCtrl == ScaleXYZ do
            (
                try
                (
                    if axisIndex == 1 then
                    (
                        scaleCtrl.x_scale.controller = newController
                        success = true
                    )
                    else if axisIndex == 2 then
                    (
                        scaleCtrl.y_scale.controller = newController
                        success = true
                    )
                    else if axisIndex == 3 then
                    (
                        scaleCtrl.z_scale.controller = newController
                        success = true
                    )
                )
                catch()
            )
        )
    )


    success
)


------------------------------------------------------------
-- 获取旧 Controller 当前值
--
-- 注意：
-- Scale 不使用 controller.value
-- 因为 ScaleXYZ 子 Controller 可能返回 100.0
------------------------------------------------------------

fn getControllerBaseValue controller transformIndex =
(
    --------------------------------------------------------
    -- Scale 强制基准 = 1.0
    --------------------------------------------------------

    if transformIndex == 3 do
    (
        return 1.0
    )


    --------------------------------------------------------
    -- Position / Rotation 默认 = 0.0
    --------------------------------------------------------

    local resultValue = 0.0


    if controller == undefined do
    (
        return resultValue
    )


    --------------------------------------------------------
    -- Position / Rotation 读取旧值
    --------------------------------------------------------

    try
    (
        local oldValue = controller.value


        if classOf oldValue == Float then
        (
            resultValue = oldValue
        )
        else if classOf oldValue == Integer then
        (
            resultValue = oldValue as float
        )
    )
    catch()


    resultValue
)


------------------------------------------------------------
-- 确保 Axis 是 Float Script
------------------------------------------------------------

fn ensureAxisFloatScript dummyObj transformIndex axisIndex =
(
    local oldController = getTransformAxisController dummyObj transformIndex axisIndex


    --------------------------------------------------------
    -- Axis 不存在
    --------------------------------------------------------

    if oldController == undefined do
    (
        return undefined
    )


    --------------------------------------------------------
    -- 已经是 Float Script
    --------------------------------------------------------

    if classOf oldController == Float_Script do
    (
        return oldController
    )


    --------------------------------------------------------
    -- 创建 Float Script
    --------------------------------------------------------

    local newController = Float_Script()


    --------------------------------------------------------
    -- Scale
    --
    -- 非常重要：
    --
    -- 不读取 oldController.value
    --
    -- ScaleXYZ 子轨道有时读出来是 100.0
    -- 但 Float Script 需要的基准是：
    --
    -- 1.0 = 100%
    --------------------------------------------------------

    if transformIndex == 3 then
    (
        try
        (
            newController.script = "1.0"
        )
        catch()
    )


    --------------------------------------------------------
    -- Position / Rotation
    --------------------------------------------------------

    else
    (
        local baseValue = getControllerBaseValue oldController transformIndex


        try
        (
            newController.script = baseValue as string
        )
        catch
        (
            newController.script = "0.0"
        )
    )


    --------------------------------------------------------
    -- 替换 Axis Controller
    --------------------------------------------------------

    local replaced = setTransformAxisController dummyObj transformIndex axisIndex newController


    if replaced then
    (
        local actualController = getTransformAxisController dummyObj transformIndex axisIndex


        if actualController != undefined then
        (
            actualController
        )
        else
        (
            newController
        )
    )
    else
    (
        undefined
    )
)


------------------------------------------------------------
-- Dummy 是否包含指定变量
------------------------------------------------------------

fn doesDummyHaveVariable dummyObj varName =
(
    if not isValidNode dummyObj do return false
    if varName == undefined do return false


    --------------------------------------------------------
    -- Position
    --------------------------------------------------------

    local posCtrl = safeGetPositionController dummyObj


    if posCtrl != undefined do
    (
        if classOf posCtrl == Position_XYZ do
        (
            local posControllers = #()


            try (append posControllers posCtrl.x_position.controller) catch()
            try (append posControllers posCtrl.y_position.controller) catch()
            try (append posControllers posCtrl.z_position.controller) catch()


            for ctrl in posControllers do
            (
                if ctrl != undefined do
                (
                    if classOf ctrl == Float_Script do
                    (
                        if floatScriptHasVariable ctrl.script varName do
                        (
                            return true
                        )
                    )
                )
            )
        )
    )


    --------------------------------------------------------
    -- Rotation
    --------------------------------------------------------

    local rotCtrl = safeGetRotationController dummyObj


    if rotCtrl != undefined do
    (
        if classOf rotCtrl == Euler_XYZ do
        (
            local rotControllers = #()


            try (append rotControllers rotCtrl.x_rotation.controller) catch()
            try (append rotControllers rotCtrl.y_rotation.controller) catch()
            try (append rotControllers rotCtrl.z_rotation.controller) catch()


            for ctrl in rotControllers do
            (
                if ctrl != undefined do
                (
                    if classOf ctrl == Float_Script do
                    (
                        if floatScriptHasVariable ctrl.script varName do
                        (
                            return true
                        )
                    )
                )
            )
        )
    )


    --------------------------------------------------------
    -- Scale
    --------------------------------------------------------

    local scaleCtrl = safeGetScaleController dummyObj


    if scaleCtrl != undefined do
    (
        if classOf scaleCtrl == ScaleXYZ do
        (
            local scaleControllers = #()


            try (append scaleControllers scaleCtrl.x_scale.controller) catch()
            try (append scaleControllers scaleCtrl.y_scale.controller) catch()
            try (append scaleControllers scaleCtrl.z_scale.controller) catch()


            for ctrl in scaleControllers do
            (
                if ctrl != undefined do
                (
                    if classOf ctrl == Float_Script do
                    (
                        if floatScriptHasVariable ctrl.script varName do
                        (
                            return true
                        )
                    )
                )
            )
        )
    )


    false
)


------------------------------------------------------------
-- Controller 是否包含任意变量
------------------------------------------------------------

fn controllerHasAnyVariable controller varNames =
(
    if controller == undefined do return false
    if classOf controller != Float_Script do return false


    for varName in varNames do
    (
        if floatScriptHasVariable controller.script varName do
        (
            return true
        )
    )


    false
)


------------------------------------------------------------
-- 添加 Track Row
------------------------------------------------------------

fn appendFloatTrack rows obj controller transformName transformCode axisName axisKey varNames =
(
    if controller != undefined do
    (
        if classOf controller == Float_Script do
        (
            if controllerHasAnyVariable controller varNames do
            (
                local row = #(
                    obj.name,
                    transformName,
                    transformCode,
                    axisName,
                    axisKey,
                    controller.script
                )


                append rows row
            )
        )
    )
)


------------------------------------------------------------
-- 收集 Float Script Rows
------------------------------------------------------------

fn collectFloatScriptRows varNames =
(
    local rows = #()


    if varNames == undefined do return rows
    if varNames.count == 0 do return rows


    for obj in objects where classOf obj == Dummy do
    (
        ----------------------------------------------------
        -- Position
        ----------------------------------------------------

        local posCtrl = safeGetPositionController obj


        if posCtrl != undefined do
        (
            if classOf posCtrl == Position_XYZ do
            (
                local xCtrl = undefined
                local yCtrl = undefined
                local zCtrl = undefined


                try (xCtrl = posCtrl.x_position.controller) catch()
                try (yCtrl = posCtrl.y_position.controller) catch()
                try (zCtrl = posCtrl.z_position.controller) catch()


                if xCtrl != undefined do
                (
                    appendFloatTrack rows obj xCtrl "Position" "P" "X" "x_position" varNames
                )


                if yCtrl != undefined do
                (
                    appendFloatTrack rows obj yCtrl "Position" "P" "Y" "y_position" varNames
                )


                if zCtrl != undefined do
                (
                    appendFloatTrack rows obj zCtrl "Position" "P" "Z" "z_position" varNames
                )
            )
        )


        ----------------------------------------------------
        -- Rotation
        ----------------------------------------------------

        local rotCtrl = safeGetRotationController obj


        if rotCtrl != undefined do
        (
            if classOf rotCtrl == Euler_XYZ do
            (
                local xCtrl = undefined
                local yCtrl = undefined
                local zCtrl = undefined


                try (xCtrl = rotCtrl.x_rotation.controller) catch()
                try (yCtrl = rotCtrl.y_rotation.controller) catch()
                try (zCtrl = rotCtrl.z_rotation.controller) catch()


                if xCtrl != undefined do
                (
                    appendFloatTrack rows obj xCtrl "Rotation" "R" "X" "x_rotation" varNames
                )


                if yCtrl != undefined do
                (
                    appendFloatTrack rows obj yCtrl "Rotation" "R" "Y" "y_rotation" varNames
                )


                if zCtrl != undefined do
                (
                    appendFloatTrack rows obj zCtrl "Rotation" "R" "Z" "z_rotation" varNames
                )
            )
        )


        ----------------------------------------------------
        -- Scale
        ----------------------------------------------------

        local scaleCtrl = safeGetScaleController obj


        if scaleCtrl != undefined do
        (
            if classOf scaleCtrl == ScaleXYZ do
            (
                local xCtrl = undefined
                local yCtrl = undefined
                local zCtrl = undefined


                try (xCtrl = scaleCtrl.x_scale.controller) catch()
                try (yCtrl = scaleCtrl.y_scale.controller) catch()
                try (zCtrl = scaleCtrl.z_scale.controller) catch()


                if xCtrl != undefined do
                (
                    appendFloatTrack rows obj xCtrl "Scale" "S" "X" "x_scale" varNames
                )


                if yCtrl != undefined do
                (
                    appendFloatTrack rows obj yCtrl "Scale" "S" "Y" "y_scale" varNames
                )


                if zCtrl != undefined do
                (
                    appendFloatTrack rows obj zCtrl "Scale" "S" "Z" "z_scale" varNames
                )
            )
        )
    )


    rows
)


------------------------------------------------------------
-- 获取变量名
------------------------------------------------------------

fn getVarNameFromItem item =
(
    if item == undefined do return ""


    local splitItem = filterString item ":"


    if splitItem.count > 0 then
    (
        trimRight splitItem[1]
    )
    else
    (
        ""
    )
)


------------------------------------------------------------
-- 获取包含变量的 Dummy
------------------------------------------------------------

fn getDummiesBasedOnVariables varNames =
(
    local result = #()


    for obj in objects where classOf obj == Dummy do
    (
        local found = false


        for varName in varNames while found == false do
        (
            if doesDummyHaveVariable obj varName do
            (
                append result obj

                found = true
            )
        )
    )


    result
)


------------------------------------------------------------
-- 获取 Animcraft Master Custom Attribute 序号
------------------------------------------------------------

fn getSameName VarName =
(
    local obj = $Animcraft_Master_GRP


    if not isValidNode obj do return 0


    local targetName = replace VarName 1 3 ""


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


------------------------------------------------------------
-- 找当前变量对应 Expression 片段
------------------------------------------------------------

fn findVariableFragment scriptText varName =
(
    if scriptText == undefined do return undefined
    if varName == undefined do return undefined


    local parts = filterString scriptText "+"


    for part in parts do
    (
        if floatScriptHasVariable part varName do
        (
            return part
        )
    )


    undefined
)


------------------------------------------------------------
-- 当前变量 Expression 编辑器
------------------------------------------------------------

rollout editFloatScriptRollout "Edit Variable Expression" width:560 height:190
(
    label lblTitle "Current Variable Expression:" pos:[10,10] width:520 height:18

    editText edtScript "" pos:[10,32] width:540 height:105 multiline:true

    button btnSave "保存修改" pos:[10,148] width:265 height:30

    button btnCancel "取消" pos:[285,148] width:265 height:30


    on editFloatScriptRollout open do
    (
        if modifyScript != undefined then
        (
            edtScript.text = modifyScript
        )
        else
        (
            edtScript.text = ""
        )
    )


    on btnSave pressed do
    (
        local canContinue = true


        if selectedScript == undefined then
        (
            messageBox "没有选中的 Float Script。"

            canContinue = false
        )


        if canContinue do
        (
            local data = filterString selectedScript "|"


            if data.count < 2 then
            (
                messageBox "无法解析当前 Float Script。"

                canContinue = false
            )


            if canContinue do
            (
                local dummyName = data[1]

                local axisKey = data[2]

                local theDummy = getNodeByName dummyName


                if not isValidNode theDummy then
                (
                    messageBox "Dummy object not found."

                    canContinue = false
                )


                if canContinue do
                (
                    dummyController = getDummyFloatController theDummy axisKey


                    if dummyController == undefined then
                    (
                        messageBox "Controller not found."

                        canContinue = false
                    )
                    else if classOf dummyController != Float_Script then
                    (
                        messageBox "Controller is not Float_Script."

                        canContinue = false
                    )


                    if canContinue do
                    (
                        if modifyScript == undefined then
                        (
                            messageBox "没有找到当前变量对应的 Expression。"

                            canContinue = false
                        )
                    )


                    if canContinue do
                    (
                        local oldScript = dummyController.script

                        local newPart = edtScript.text

                        local newScript = substituteString oldScript modifyScript newPart


                        try
                        (
                            dummyController.script = newScript

                            updatedScript = newScript

                            modifyScript = newPart

                            redrawViews()

                            try (floatScriptsRollout.refreshTrackList()) catch()

                            destroyDialog editFloatScriptRollout
                        )
                        catch
                        (
                            local err = getCurrentException() as string

                            messageBox ("Expression 写入失败。\n\n" + err)
                        )
                    )
                )
            )
        )
    )


    on btnCancel pressed do
    (
        destroyDialog editFloatScriptRollout
    )
)


------------------------------------------------------------
-- Float Script 主窗口
------------------------------------------------------------

rollout floatScriptsRollout "AnimCraft Float Scripts" width:1400 height:650
(
    local trackRows = #()


    --------------------------------------------------------
    -- 左侧
    --------------------------------------------------------

    label lblTracks "Float Script Tracks - Grouped by Object" pos:[10,10] width:400 height:18

    dotNetControl lvTracks "System.Windows.Forms.ListView" pos:[10,32] width:520 height:500


    --------------------------------------------------------
    -- 右侧
    --------------------------------------------------------

    label lblExpression "Expression" pos:[545,10] width:100 height:18

    label lblCurrent "No Track Selected" pos:[650,10] width:730 height:18

    dotNetControl edtExpression "System.Windows.Forms.TextBox" pos:[545,32] width:845 height:500


    --------------------------------------------------------
    -- Bottom
    --------------------------------------------------------

    groupBox grpTarget "Add Variable To Selected Dummy" pos:[10,542] width:1380 height:95


    dropDownList ddlTransform "Transform:" items:#("Position", "Rotation", "Scale") selection:1 pos:[25,562] width:155


    checkBox chkX "X" checked:true pos:[205,580] width:40

    checkBox chkY "Y" checked:false pos:[250,580] width:40

    checkBox chkZ "Z" checked:false pos:[295,580] width:40


    button btnAdd "添加到选择的 Dummy" pos:[350,570] width:170 height:32

    button btnApplyExpression "应用完整 Expression" pos:[535,570] width:170 height:32

    button btnEditPart "编辑当前变量片段" pos:[720,570] width:160 height:32

    button btnSelectNode "选择列表对象" pos:[895,570] width:115 height:32

    button btnRefresh "刷新" pos:[1025,570] width:90 height:32


    label lblStatus "Ready" pos:[1130,578] width:250 height:18


    --------------------------------------------------------
    -- 初始化 ListView
    --------------------------------------------------------

    fn initListView =
    (
        local viewClass = dotNetClass "System.Windows.Forms.View"


        lvTracks.View = viewClass.Details

        lvTracks.FullRowSelect = true

        lvTracks.GridLines = false

        lvTracks.HideSelection = false

        lvTracks.MultiSelect = false

        lvTracks.ShowGroups = true


        lvTracks.Columns.Clear()

        lvTracks.Groups.Clear()


        lvTracks.Columns.Add "Transform" 135

        lvTracks.Columns.Add "Axis" 75

        lvTracks.Columns.Add "Controller" 160


        try
        (
            lvTracks.HeaderStyle = (dotNetClass "System.Windows.Forms.ColumnHeaderStyle").Nonclickable
        )
        catch()


        try
        (
            local colorClass = dotNetClass "System.Drawing.Color"

            lvTracks.BackColor = colorClass.FromArgb 245 245 245
        )
        catch()
    )


    --------------------------------------------------------
    -- Expression Editor
    --------------------------------------------------------

    fn initExpressionEditor =
    (
        local scrollClass = dotNetClass "System.Windows.Forms.ScrollBars"


        edtExpression.Multiline = true

        edtExpression.ScrollBars = scrollClass.Both

        edtExpression.WordWrap = false

        edtExpression.AcceptsReturn = true

        edtExpression.AcceptsTab = true


        try
        (
            edtExpression.Font = dotNetObject "System.Drawing.Font" "Consolas" 10.0
        )
        catch()
    )


    --------------------------------------------------------
    -- Object Group
    --------------------------------------------------------

    fn getOrCreateObjectGroup objectName =
    (
        local foundGroup = undefined


        if lvTracks.Groups.Count > 0 do
        (
            for i = 0 to lvTracks.Groups.Count - 1 while foundGroup == undefined do
            (
                local grp = lvTracks.Groups.Item[i]


                if grp.Header == objectName do
                (
                    foundGroup = grp
                )
            )
        )


        if foundGroup == undefined do
        (
            foundGroup = dotNetObject "System.Windows.Forms.ListViewGroup" objectName


            try
            (
                foundGroup.HeaderAlignment = (dotNetClass "System.Windows.Forms.HorizontalAlignment").Left
            )
            catch()


            lvTracks.Groups.Add foundGroup
        )


        foundGroup
    )


    --------------------------------------------------------
    -- Add Track Item
    --------------------------------------------------------

    fn addTrackItem row rowIndex =
    (
        local objectName = row[1]

        local transformName = row[2]

        local transformCode = row[3]

        local axisName = row[4]


        local item = dotNetObject "System.Windows.Forms.ListViewItem" transformName


        item.SubItems.Add axisName

        item.SubItems.Add "Float Script"


        item.Tag = rowIndex as string


        local objectGroup = getOrCreateObjectGroup objectName


        item.Group = objectGroup


        try
        (
            item.UseItemStyleForSubItems = false


            local colorClass = dotNetClass "System.Drawing.Color"


            if transformCode == "P" do
            (
                item.SubItems.Item[0].ForeColor = colorClass.SteelBlue
            )


            if transformCode == "R" do
            (
                item.SubItems.Item[0].ForeColor = colorClass.DarkOrange
            )


            if transformCode == "S" do
            (
                item.SubItems.Item[0].ForeColor = colorClass.SeaGreen
            )


            item.SubItems.Item[1].ForeColor = colorClass.FromArgb 70 70 70
        )
        catch()


        lvTracks.Items.Add item
    )


    --------------------------------------------------------
    -- 获取当前 Track
    --------------------------------------------------------

    fn getSelectedTrack =
    (
        if lvTracks.SelectedItems.Count == 0 do
        (
            return undefined
        )


        local item = lvTracks.SelectedItems.Item[0]

        local rowIndex = (item.Tag as string) as integer


        if rowIndex < 1 do
        (
            return undefined
        )


        if rowIndex > trackRows.count do
        (
            return undefined
        )


        trackRows[rowIndex]
    )


    --------------------------------------------------------
    -- 自动选择 Track
    --------------------------------------------------------

    fn selectTrackByNodeAndAxis nodeName axisKey =
    (
        if nodeName == undefined do return false
        if axisKey == undefined do return false


        local foundRowIndex = 0


        for i = 1 to trackRows.count while foundRowIndex == 0 do
        (
            local row = trackRows[i]


            if row[1] == nodeName and row[5] == axisKey do
            (
                foundRowIndex = i
            )
        )


        if foundRowIndex == 0 do
        (
            return false
        )


        local foundItem = undefined


        if lvTracks.Items.Count > 0 do
        (
            for i = 0 to lvTracks.Items.Count - 1 while foundItem == undefined do
            (
                local item = lvTracks.Items.Item[i]

                local itemRowIndex = 0


                try
                (
                    itemRowIndex = (item.Tag as string) as integer
                )
                catch()


                if itemRowIndex == foundRowIndex do
                (
                    foundItem = item
                )
            )
        )


        if foundItem == undefined do
        (
            return false
        )


        try
        (
            if lvTracks.Items.Count > 0 do
            (
                for i = 0 to lvTracks.Items.Count - 1 do
                (
                    lvTracks.Items.Item[i].Selected = false
                )
            )


            foundItem.Selected = true

            foundItem.Focused = true

            foundItem.EnsureVisible()

            lvTracks.Focus()


            updateSelectionInfo trackRows[foundRowIndex]


            true
        )
        catch
        (
            false
        )
    )


    --------------------------------------------------------
    -- XYZ Checkbox 状态
    --------------------------------------------------------

    fn updateAxisCheckboxState =
    (
        chkX.enabled = true

        chkY.enabled = true

        chkZ.enabled = true


        if selection.count != 1 do
        (
            return false
        )


        local obj = selection[1]


        if not isValidNode obj do
        (
            return false
        )


        if selectedValue == undefined do
        (
            return false
        )


        local xCtrl = getTransformAxisController obj ddlTransform.selection 1

        local yCtrl = getTransformAxisController obj ddlTransform.selection 2

        local zCtrl = getTransformAxisController obj ddlTransform.selection 3


        ----------------------------------------------------
        -- X
        ----------------------------------------------------

        if xCtrl != undefined do
        (
            if classOf xCtrl == Float_Script do
            (
                if floatScriptHasVariable xCtrl.script selectedValue do
                (
                    chkX.checked = false

                    chkX.enabled = false
                )
            )
        )


        ----------------------------------------------------
        -- Y
        ----------------------------------------------------

        if yCtrl != undefined do
        (
            if classOf yCtrl == Float_Script do
            (
                if floatScriptHasVariable yCtrl.script selectedValue do
                (
                    chkY.checked = false

                    chkY.enabled = false
                )
            )
        )


        ----------------------------------------------------
        -- Z
        ----------------------------------------------------

        if zCtrl != undefined do
        (
            if classOf zCtrl == Float_Script do
            (
                if floatScriptHasVariable zCtrl.script selectedValue do
                (
                    chkZ.checked = false

                    chkZ.enabled = false
                )
            )
        )


        true
    )


    --------------------------------------------------------
    -- 更新选中 Track 信息
    --------------------------------------------------------

    fn updateSelectionInfo row =
    (
        if row != undefined do
        (
            local nodeName = row[1]

            local transformName = row[2]

            local axisName = row[4]

            local axisKey = row[5]

            local scriptText = row[6]


            local obj = getNodeByName nodeName


            if isValidNode obj do
            (
                try (select obj) catch()
            )


            edtExpression.Text = scriptText


            lblCurrent.text = nodeName + "    " + transformName + " / " + axisName


            selectedScript = nodeName + "|" + axisKey + "|" + scriptText


            modifyScript = findVariableFragment scriptText selectedValue


            if modifyScript != undefined then
            (
                lblStatus.text = "Variable fragment found"
            )
            else
            (
                lblStatus.text = "Variable fragment not found"
            )


            updateAxisCheckboxState()
        )
    )


    --------------------------------------------------------
    -- Group 数量
    --------------------------------------------------------

    fn getObjectGroupCount =
    (
        lvTracks.Groups.Count
    )


    --------------------------------------------------------
    -- Refresh
    --------------------------------------------------------

    fn refreshTrackList =
    (
        local vars = currentFloatScriptVarNames


        if vars == undefined do
        (
            vars = #()
        )


        if vars.count == 0 do
        (
            if selectedValue != undefined do
            (
                vars = #(selectedValue)
            )
        )


        trackRows = collectFloatScriptRows vars


        lvTracks.BeginUpdate()


        lvTracks.Items.Clear()

        lvTracks.Groups.Clear()


        for i = 1 to trackRows.count do
        (
            addTrackItem trackRows[i] i
        )


        lvTracks.EndUpdate()


        edtExpression.Text = ""

        lblCurrent.text = "No Track Selected"


        selectedScript = undefined

        modifyScript = undefined


        local objectCount = getObjectGroupCount()


        lblStatus.text = "Objects: " + (objectCount as string) + "   Tracks: " + (trackRows.count as string)


        updateAxisCheckboxState()
    )


    --------------------------------------------------------
    -- 添加变量到 Float Script
    --------------------------------------------------------

    fn addVariableToController controller =
    (
        if controller == undefined do return false

        if classOf controller != Float_Script do return false

        if selectedValue == undefined do return false

        if modifyScript == undefined do return false


        ----------------------------------------------------
        -- 防重复
        ----------------------------------------------------

        if floatScriptHasVariable controller.script selectedValue do
        (
            return false
        )


        ----------------------------------------------------
        -- Master
        ----------------------------------------------------

        local master = $Animcraft_Master_GRP


        if not isValidNode master then
        (
            messageBox "Animcraft_Master_GRP not found."

            return false
        )


        local newVarName = "AC_" + selectedValue

        local custAttrDefNumber = getSameName newVarName


        if custAttrDefNumber == 0 then
        (
            messageBox ("Animcraft_Master_GRP 中没有找到：\n" + newVarName)

            return false
        )


        local custAttributesDefs = master.custom_attributes


        ----------------------------------------------------
        -- Add Target
        ----------------------------------------------------

        try
        (
            controller.addTarget newVarName custAttributesDefs[custAttrDefNumber]
        )
        catch
        (
            local err = getCurrentException() as string


            messageBox ("addTarget 失败：\n" + newVarName + "\n\n" + err)


            return false
        )


        ----------------------------------------------------
        -- 来源变量
        ----------------------------------------------------

        local existingScript = controller.script

        local modifyParts = filterString modifyScript "*"

        local variablePart = undefined


        for part in modifyParts do
        (
            if isACString part do
            (
                variablePart = substituteString part ")" ""
            )
        )


        if variablePart == undefined do
        (
            variablePart = newVarName
        )


        ----------------------------------------------------
        -- Expression
        ----------------------------------------------------

        try
        (
            if existingScript == undefined or existingScript == "" then
            (
                controller.script = variablePart
            )
            else
            (
                controller.script = existingScript + "+" + variablePart
            )
        )
        catch
        (
            local err = getCurrentException() as string


            messageBox ("Expression 写入失败。\n\n" + err)


            return false
        )


        true
    )


    --------------------------------------------------------
    -- Open
    --------------------------------------------------------

    on floatScriptsRollout open do
    (
        initListView()

        initExpressionEditor()

        refreshTrackList()


        try
        (
            callbacks.removeScripts id:#AnimCraftFloatAxisState
        )
        catch()


        callbacks.addScript #selectionSetChanged "try(floatScriptsRollout.updateAxisCheckboxState())catch()" id:#AnimCraftFloatAxisState


        updateAxisCheckboxState()
    )


    --------------------------------------------------------
    -- Close
    --------------------------------------------------------

    on floatScriptsRollout close do
    (
        try
        (
            callbacks.removeScripts id:#AnimCraftFloatAxisState
        )
        catch()
    )


    --------------------------------------------------------
    -- Resize
    --------------------------------------------------------

    on floatScriptsRollout resized size do
    (
        local leftWidth = 520


        if size.x < 1150 do
        (
            leftWidth = 420
        )


        if size.x > 1650 do
        (
            leftWidth = 600
        )


        local rightX = leftWidth + 25

        local contentHeight = size.y - 118


        if contentHeight < 300 do
        (
            contentHeight = 300
        )


        lvTracks.width = leftWidth

        lvTracks.height = contentHeight - 32


        lblExpression.pos = [rightX,10]

        lblCurrent.pos = [rightX + 105,10]


        edtExpression.pos = [rightX,32]

        edtExpression.width = size.x - rightX - 10

        edtExpression.height = contentHeight - 32


        local bottomY = contentHeight + 10


        grpTarget.pos = [10,bottomY]

        grpTarget.width = size.x - 20


        ddlTransform.pos = [25,bottomY + 20]


        chkX.pos = [205,bottomY + 38]

        chkY.pos = [250,bottomY + 38]

        chkZ.pos = [295,bottomY + 38]


        btnAdd.pos = [350,bottomY + 28]

        btnApplyExpression.pos = [535,bottomY + 28]

        btnEditPart.pos = [720,bottomY + 28]

        btnSelectNode.pos = [895,bottomY + 28]

        btnRefresh.pos = [1025,bottomY + 28]


        lblStatus.pos = [1130,bottomY + 36]
    )


    --------------------------------------------------------
    -- Transform 切换
    --------------------------------------------------------

    on ddlTransform selected index do
    (
        updateAxisCheckboxState()
    )


    --------------------------------------------------------
    -- Track Selection
    --------------------------------------------------------

    on lvTracks SelectedIndexChanged sender args do
    (
        local row = getSelectedTrack()


        if row != undefined do
        (
            updateSelectionInfo row
        )
    )


    --------------------------------------------------------
    -- Double Click
    --------------------------------------------------------

    on lvTracks DoubleClick sender args do
    (
        local row = getSelectedTrack()


        if row != undefined do
        (
            updateSelectionInfo row


            if modifyScript == undefined then
            (
                messageBox "当前变量在这个 Expression 中没有找到。"
            )
            else
            (
                try (destroyDialog editFloatScriptRollout) catch()

                createDialog editFloatScriptRollout
            )
        )
    )


    --------------------------------------------------------
    -- 编辑当前变量
    --------------------------------------------------------

    on btnEditPart pressed do
    (
        local row = getSelectedTrack()


        if row == undefined then
        (
            messageBox "请先选择一个 Float Script Track。"
        )
        else
        (
            updateSelectionInfo row


            if modifyScript == undefined then
            (
                messageBox "当前 Expression 中没有找到选择的变量。"
            )
            else
            (
                try (destroyDialog editFloatScriptRollout) catch()

                createDialog editFloatScriptRollout
            )
        )
    )


    --------------------------------------------------------
    -- 应用完整 Expression
    --------------------------------------------------------

    on btnApplyExpression pressed do
    (
        local row = getSelectedTrack()


        if row == undefined then
        (
            messageBox "请先选择一个 Float Script Track。"
        )
        else
        (
            local nodeName = row[1]

            local axisKey = row[5]

            local obj = getNodeByName nodeName


            if not isValidNode obj then
            (
                messageBox "Dummy object not found."
            )
            else
            (
                local controller = getDummyFloatController obj axisKey


                if controller == undefined then
                (
                    messageBox "Controller not found."
                )
                else if classOf controller != Float_Script then
                (
                    messageBox "Selected Controller is not Float_Script."
                )
                else
                (
                    local newScript = edtExpression.Text


                    try
                    (
                        controller.script = newScript


                        updatedScript = newScript

                        row[6] = newScript


                        selectedScript = nodeName + "|" + axisKey + "|" + newScript

                        modifyScript = findVariableFragment newScript selectedValue


                        lblStatus.text = "Expression applied"


                        redrawViews()

                        updateAxisCheckboxState()
                    )
                    catch
                    (
                        local err = getCurrentException() as string

                        messageBox ("Expression 写入失败。\n\n" + err)
                    )
                )
            )
        )
    )


    --------------------------------------------------------
    -- 选择列表对象
    --------------------------------------------------------

    on btnSelectNode pressed do
    (
        local row = getSelectedTrack()


        if row != undefined do
        (
            local obj = getNodeByName row[1]


            if isValidNode obj do
            (
                try (select obj) catch()
            )
        )
    )


    --------------------------------------------------------
    -- Refresh
    --------------------------------------------------------

    on btnRefresh pressed do
    (
        refreshTrackList()
    )


    --------------------------------------------------------
    -- 添加
    --------------------------------------------------------

    on btnAdd pressed do
    (
        local canAdd = true


        ----------------------------------------------------
        -- Selection
        ----------------------------------------------------

        if selection.count != 1 then
        (
            messageBox "请选择一个 Dummy object。"

            canAdd = false
        )


        if canAdd do
        (
            if classOf selection[1] != Dummy then
            (
                messageBox "选择的对象不是 Dummy。"

                canAdd = false
            )
        )


        ----------------------------------------------------
        -- Variable
        ----------------------------------------------------

        if canAdd do
        (
            if selectedValue == undefined then
            (
                messageBox "请先在 Non-Zero Spinners 中选择一个变量。"

                canAdd = false
            )
        )


        ----------------------------------------------------
        -- Source
        ----------------------------------------------------

        if canAdd do
        (
            if modifyScript == undefined then
            (
                messageBox "请先在左侧选择一个包含当前变量的 Float Script，作为添加来源。"

                canAdd = false
            )
        )


        ----------------------------------------------------
        -- Axis
        ----------------------------------------------------

        if canAdd do
        (
            local anyAxis = false


            if chkX.checked and chkX.enabled do anyAxis = true

            if chkY.checked and chkY.enabled do anyAxis = true

            if chkZ.checked and chkZ.enabled do anyAxis = true


            if not anyAxis then
            (
                messageBox "至少选择一个可添加的 X / Y / Z Axis。"

                canAdd = false
            )
        )


        ----------------------------------------------------
        -- 执行
        ----------------------------------------------------

        if canAdd do
        (
            local dummyObj = selection[1]

            local addedNodeName = dummyObj.name

            local currentTransformIndex = ddlTransform.selection

            local firstAddedAxisKey = undefined


            ------------------------------------------------
            -- Axis
            ------------------------------------------------

            local axisIndices = #()


            if chkX.checked and chkX.enabled do
            (
                append axisIndices 1
            )


            if chkY.checked and chkY.enabled do
            (
                append axisIndices 2
            )


            if chkZ.checked and chkZ.enabled do
            (
                append axisIndices 3
            )


            ------------------------------------------------
            -- Count
            ------------------------------------------------

            local successCount = 0

            local convertedCount = 0

            local existsCount = 0

            local invalidCount = 0


            ------------------------------------------------
            -- Loop
            ------------------------------------------------

            for axisIndex in axisIndices do
            (
                local oldController = getTransformAxisController dummyObj currentTransformIndex axisIndex


                if oldController == undefined then
                (
                    invalidCount += 1
                )
                else
                (
                    ------------------------------------------------
                    -- 已经 Float Script
                    ------------------------------------------------

                    if classOf oldController == Float_Script then
                    (
                        if floatScriptHasVariable oldController.script selectedValue then
                        (
                            existsCount += 1
                        )
                        else
                        (
                            if addVariableToController oldController then
                            (
                                successCount += 1


                                if firstAddedAxisKey == undefined do
                                (
                                    firstAddedAxisKey = getAxisKeyByIndex currentTransformIndex axisIndex
                                )
                            )
                            else
                            (
                                invalidCount += 1
                            )
                        )
                    )


                    ------------------------------------------------
                    -- 非 Float Script
                    ------------------------------------------------

                    else
                    (
                        local newController = ensureAxisFloatScript dummyObj currentTransformIndex axisIndex


                        if newController == undefined then
                        (
                            invalidCount += 1
                        )
                        else
                        (
                            if classOf newController != Float_Script then
                            (
                                invalidCount += 1
                            )
                            else
                            (
                                if addVariableToController newController then
                                (
                                    successCount += 1

                                    convertedCount += 1


                                    if firstAddedAxisKey == undefined do
                                    (
                                        firstAddedAxisKey = getAxisKeyByIndex currentTransformIndex axisIndex
                                    )
                                )
                                else
                                (
                                    ------------------------------------------------
                                    -- 添加失败恢复旧 Controller
                                    ------------------------------------------------

                                    try
                                    (
                                        setTransformAxisController dummyObj currentTransformIndex axisIndex oldController
                                    )
                                    catch()


                                    invalidCount += 1
                                )
                            )
                        )
                    )
                )
            )


            ----------------------------------------------------
            -- View
            ----------------------------------------------------

            redrawViews()


            ----------------------------------------------------
            -- Refresh
            ----------------------------------------------------

            refreshTrackList()


            ----------------------------------------------------
            -- 自动选择第一条成功添加的轨道
            ----------------------------------------------------

            if firstAddedAxisKey != undefined do
            (
                selectTrackByNodeAndAxis addedNodeName firstAddedAxisKey
            )


            ----------------------------------------------------
            -- Checkbox
            ----------------------------------------------------

            updateAxisCheckboxState()


            ----------------------------------------------------
            -- Status
            ----------------------------------------------------

            lblStatus.text = "Added: " + (successCount as string) + "   Converted: " + (convertedCount as string) + "   Exists: " + (existsCount as string) + "   Failed: " + (invalidCount as string)


            ----------------------------------------------------
            -- Error
            ----------------------------------------------------

            if invalidCount > 0 do
            (
                local msg = (invalidCount as string) + " 个 Axis 添加失败。"

                messageBox msg
            )
        )
    )
)


------------------------------------------------------------
-- 打开 Float Script Manager
------------------------------------------------------------

fn displayFloatScriptsOfSelectedDummies varNames =
(
    currentFloatScriptVarNames = varNames


    try (destroyDialog floatScriptsRollout) catch()


    createDialog floatScriptsRollout style:#(#style_titlebar, #style_resizing, #style_sysmenu) autoLayoutOnResize:false
)


------------------------------------------------------------
-- Non-Zero Spinners
------------------------------------------------------------

rollout nonZeroSpinnerRollout "Non-Zero Spinners" width:220 height:285
(
    button btnGetValues "Get Non-Zero Values" width:200 height:25 pos:[10,10]


    listBox lstNonZeroValues "Values" width:200 height:10 pos:[10,40]


    button btnSelectDummies "Select Dummies / Float Scripts" width:200 height:30 pos:[10,215]


    label lblStatus "Status: Ready" pos:[10,250] width:200


    label author "作者: 黄友为" pos:[10,268] width:200


    --------------------------------------------------------
    -- Get Values
    --------------------------------------------------------

    on btnGetValues pressed do
    (
        local masterObj = $Animcraft_Master_GRP


        if isValidNode masterObj then
        (
            lstNonZeroValues.items = getNonZeroSpinnerValues masterObj


            if lstNonZeroValues.items.count == 0 then
            (
                lblStatus.text = "No non-zero values found."
            )
            else
            (
                lblStatus.text = "Non-zero values updated."
            )
        )
        else
        (
            lblStatus.text = "Animcraft_Master_GRP not found."
        )
    )


    --------------------------------------------------------
    -- Select Dummies / Float Scripts
    --------------------------------------------------------

    on btnSelectDummies pressed do
    (
        local selectedIndex = lstNonZeroValues.selection


        if selectedIndex == undefined or selectedIndex == 0 then
        (
            messageBox "Please select an item from the list."
        )
        else
        (
            selectedValue = getVarNameFromItem lstNonZeroValues.items[selectedIndex]


            local extractedVarNames = #(selectedValue)


            local varObj = getDummiesBasedOnVariables extractedVarNames


            if varObj.count > 0 do
            (
                try (select varObj) catch()
            )


            displayFloatScriptsOfSelectedDummies extractedVarNames
        )
    )
)


------------------------------------------------------------
-- 启动
------------------------------------------------------------

createDialog nonZeroSpinnerRollout