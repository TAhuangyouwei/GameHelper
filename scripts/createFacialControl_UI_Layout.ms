-- createBaseController: 创建基础控制器结构，包括矩形和内部形状（圆或样条）。
fn createBaseController shape length width radius wireColorHandle = 
(
    rec = Rectangle length:length width:width name:(uniqueName "FaceControl") wireColor:[0,0,200] displayRenderMesh:false render_displayRenderMesh:true render_thickness:0.3
    cir = shape radius:radius name:(uniqueName "FaceControlHandle") wireColor:wireColorHandle displayRenderMesh:false render_displayRenderMesh:true render_thickness:0.3
    cir.parent = rec 
    setTransformLockFlags cir #{3..9}

    -- 创建并设置控制器标签
    conName = text text:"控制器" size:2 wireColor:[255,255,0] pos:[0,6,0] alignment:2 displayRenderMesh:false  font:"仿宋"
    conName.parent = rec
    addModifier conName (meshSelect())
    setTransformLockFlags conName #{1..9}

    -- 设置控制器旋转
    rec.rotation.x_rotation = 90

    return #(rec, cir)
)

-- 定义一个通用函数用于配置位置和旋转控制器
fn configureControllers cir posLimitX posLimitY = 
(
-- 	format "Configuring controller: %\n" cir  -- 打印 cir 对象信息
    -- 配置位置控制器
    cir.Position.controller = position_list ()
    cir.Position.controller.Available.controller = Position_XYZ ()
    cir.Position.controller[1].controller = Bezier_Position ()
    listctrl.setname cir.Position.controller 1 "Frozen Position"
    listctrl.setname cir.Position.controller 2 "Zero Pos XYZ"
    cir.position.controller.SetActive 2 

    -- 配置旋转控制器
    cir.rotation.controller = Rotation_list ()
    cir.rotation.controller.Available.controller = Euler_XYZ ()
    listctrl.setname cir.rotation.controller 1 "Frozen Rotation"
    listctrl.setname cir.rotation.controller 2 "Zero Euler XYZ"
    cir.rotation.controller.SetActive 2 

    -- 设置位置限制
    fl = float_limit()
    cir.pos.controller[2][1].controller = fl
    fl.limits[#upper_limit].value = posLimitX
    fl.limits[#lower_limit].value = -posLimitX

    fl = float_limit()
    cir.pos.controller[2][2].controller = fl
    fl.limits[#upper_limit].value = posLimitY
    fl.limits[#lower_limit].value = -posLimitY

    fl = float_limit()
    cir.pos.controller[2][3].controller = fl
    fl.limits[#upper_limit].value = 0
    fl.limits[#lower_limit].value = 0
)

-- 创建方形表情控制器
fn facialControlSquare = 
(
    controllers = createBaseController circle 10 10 1 [200,0,0]
    configureControllers controllers[2] 5 5
    controllers
)

-- 创建条形表情控制器
fn facialControlBar = 
(
    controllers = createBaseController circle 10 1 1 [200,0,0]
    configureControllers controllers[2] 0 5
    controllers
)


-- 定义一个辅助函数来创建和配置控制器
fn createAndConfigureController shapeType pos name wireColorHandle = 
(
    rec = Rectangle length:10 width:10 name:(uniqueName "FaceControl") wireColor:[0,0,200] transform:(matrix3 [1,0,0] [0,0,1] [0,-1,0] [0,0,0]) displayRenderMesh:false  render_displayRenderMesh:true render_thickness:0.3
    rec.showFrozenInGray = off
    freeze rec

    local cir
    if (shapeType == "circle") then
    (
        cir = circle radius:1 name:name wireColor:wireColorHandle transform:(matrix3 [1,0,0] [0,0,1] [0,-1,0] [0,0,0]) displayRenderMesh:false render_displayRenderMesh:true render_thickness:0.3
    )
    else if (shapeType == "splineShape") then
    (
        cir = splineShape wireColor:wireColorHandle render_displayRenderMesh:true render_thickness:0.3 name:name
        addnewSpline cir
        for i = 1 to pos.count do 
        (
            addKnot cir 1 #corner #line pos[i]
        )
        close cir 1
        updateShape cir
    )

    if isValidNode cir then
    (
        cir.parent = rec
        return #(rec, cir)
    )
    else
    (
        format "Error: Failed to create controller '%'.\n" name
        return undefined
    )
)


-- 定义一个辅助函数来创建和配置文本标签
fn createAndConfigureText name pos = 
(
    conName = text text:name size:2 wireColor:[255,255,0] transform:(matrix3 [1,0,0] [0,0,1] [0,-1,0] pos) alignment:2 displayRenderMesh:false  font:"仿宋"
    conName.showFrozenInGray = off
    freeze conName
    conName
)


-- 创建所有表情UI控制器的主函数
fn facialControl =  
(
    strArrayText = #("右眉毛", "左眉毛", "右眼皮", "眼球", "左眼皮", "上嘴唇", "右嘴角", "左嘴角", "下嘴唇", "下巴")
    circleCtrlArrayName = #("EyeBrow_R_C", "EyeBrow_L_C", "Eyelid_R_C", "EyeBall_C", "Eyelid_L_C", "UpLip_C", "Lip_R_C", "Lip_L_C", "DownLip_C", "Jaw_C")
    posArray = #([-7,35,0], [7,35,0], [-12,20,0], [0,20,0], [12,20,0], [0,5,0], [-7,-8,0], [7,-8,0], [0,-22,0], [0,-37,0])
    ctrlParent = Rectangle length:90 width:40 cornerRadius:0 transform:(matrix3 [1,0,0] [0,0,1] [0,-1,0] [0,0,0]) wirecolor:yellow  cornerRadius:9 render_displayRenderMesh:true render_thickness:0.3

    for i = 1 to strArrayText.count do 
    (
        local shapeType = if findString strArrayText[i] "眼皮" != undefined then "splineShape" else if findString strArrayText[i] "下巴" != undefined then "splineShape" else "circle"

        local pos
        if shapeType == "splineShape" then 
        (
            pos = if findString strArrayText[i] "眼皮" != undefined then 
                #([-1.35967,0,0.679834], [-1.35967,-2.21518e-07,1.35967], [-2.71934,0,0], [-1.35967,2.21518e-07,-1.35967], [-1.35967,0,-0.679834], [1.35967,0,-0.679834], [1.35967,2.21518e-07,-1.35967], [2.71934,0,0], [1.35967,-2.21518e-07,1.35967], [1.35967,0,0.679834])
            else 
                #([0,-1.78284e-07,1.0943],[-0.437719,0,0.656578],[-0.218859,0,0.656578],[-0.218859,0,0.218859],[-0.656578,0,0.218859],[-0.656578,0,0.437719],[-1.0943,0,0],[-0.656578,0,-0.437719],[-0.656578,0,-0.218859],[-0.218859,0,-0.218859],[-0.218859,0,-0.656578],[-0.437719,0,-0.656578],[0,1.78284e-07,-1.0943],[0.437719,0,-0.656578],[0.218859,0,-0.656578],[0.218859,0,-0.218859],[0.656578,0,-0.218859],[0.656578,0,-0.437719],[1.0943,0,0],[0.656578,0,0.437719],[0.656578,0,0.218859],[0.218859,0,0.218859],[0.218859,0,0.656578],[0.437719,0,0.656578])
        )

        local controllerArray = createAndConfigureController shapeType pos circleCtrlArrayName[i] [200,0,0]
        local rec = controllerArray[1]
        local cir = controllerArray[2]

        if isValidNode cir then
        (
            local posLimitX = 5
            local posLimitY = (if findString strArrayText[i] "眼皮" != undefined then 0 else 5)
            configureControllers cir posLimitX posLimitY  -- 应用位置和旋转限制
            local conName = createAndConfigureText strArrayText[i] [0,0,6]
            conName.parent = rec
            rec.parent = ctrlParent
            in coordsys parent rec.pos = posArray[i]

            if findString strArrayText[i] "右" != undefined then 
            (
                local originalParent = conName.parent
                conName.parent = undefined -- 临时解除文本标签的父对象
                in coordsys parent rotate rec (EulerAngles 0 180 0)
                conName.parent = originalParent -- 旋转后恢复文本标签的父对象
            )
        )
        else
        (
            format "Error: Invalid controller '%'.\n" circleCtrlArrayName[i]
        )
    )
)




/*


1. createBaseController 函数
功能: 创建基础的表情控制器结构，包括一个矩形和一个内部形状（圆形或样条形状）以及文本标签。
参数:
shape: 形状类型（例如 circle 或 splineShape）。
length: 矩形的长度。
width: 矩形的宽度。
radius: 内部形状的半径（对于圆形）。
wireColorHandle: 内部形状的颜色。
用法: 用于创建一个包含矩形、一个内部形状和一个标签的复合控制器。
返回值: 返回一个包含矩形和内部形状的数组。
2. configureControllers 函数
功能: 配置表情控制器的位置和旋转控制器，包括位置限制的设置。
参数:
cir: 控制器对象。
posLimitX: X轴上的位置限制。
posLimitY: Y轴上的位置限制。
用法: 用于设置控制器的位置和旋转行为，以及位置限制。
返回值: 无（函数直接修改 cir 对象）。
3. facialControlSquare 函数
功能: 创建方形表情控制器。
参数: 无。
用法: 创建具有特定形状和配置的控制器，用于表情动画。
返回值: 返回包含矩形和圆形控制器的数组。
4. facialControlBar 函数
功能: 创建条形表情控制器。
参数: 无。
用法: 创建具有特定形状（条形）和配置的控制器。
返回值: 返回包含矩形和圆形控制器的数组。
5. createAndConfigureController 函数
功能: 基于给定的形状类型和位置数据创建和配置控制器。
参数:
shapeType: 形状类型（"circle" 或 "splineShape"）。
pos: 形状的位置数据。
name: 控制器的名称。
wireColorHandle: 控制器的颜色。
用法: 根据指定的形状类型创建控制器，并设置其位置和其他属性。
返回值: 如果成功创建，则返回包含矩形和形状对象的数组；如果失败，则返回 undefined。
6. createAndConfigureText 函数
功能: 创建和配置文本标签。
参数:
name: 文本内容。
pos: 文本标签的位置。
用法: 为控制器创建一个文本标签。
返回值: 返回文本对象。
7. facialControl 函数
功能: 创建所有表情UI控制器。
参数: 无。
用法: 生成一组表情控制器，用于动画中。
返回值: 无（函数直接在场景中创建控制器）




*/


