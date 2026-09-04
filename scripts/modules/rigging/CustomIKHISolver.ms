/*
    自定义 IK HI 解算器创建功能。
    从 HYW_Scripts_Library.ms 拆出，保留原结构名和调用方式。
*/

struct CustomIKHISolver
(
    -- 成员变量
    boneNodes,
    controlPoints,
    ikChains,
    dummies,

    -- 创建IK链
    fn createIKChains boneNodes =
    (
        local ikChains = #(undefined, undefined)
        local count = boneNodes.count
        case count of
        (
            3: ikChains[1] = IKSys.ikChain boneNodes[1] boneNodes[count] "IKHISolver"
            5:
            (
                ikChains[1] = IKSys.ikChain boneNodes[1] boneNodes[3] "IKHISolver"
                ikChains[2] = IKSys.ikChain boneNodes[3] boneNodes[count] "IKHISolver"
            )
        )
        ikChains
    ),

    -- 创建控制点
    fn createControlPoints boneNodes =
    (
        local controlPoints = #()
        for i = 1 to boneNodes.count do
        (
            local controlPoint = point box:off cross:on name:("IK" + boneNodes[i].name)
            controlPoint.transform = boneNodes[i].transform
            append controlPoints controlPoint
        )
        for i = 1 to controlPoints.count-1 do
        (
            controlPoints[i+1].parent = controlPoints[i]
        )
        controlPoints
    ),

    -- 创建dummy对象并设置约束
    fn createDummiesAndSetConstraints boneNodes controlPoints =
    (
        local baseDummy  = dummy pos:boneNodes[1].pos boxsize:[10,10,10]
        local lookAtDummy = dummy pos:boneNodes[1].pos boxsize:[5,5,5]
        local controlDummy = dummy pos:boneNodes[boneNodes.count].pos boxsize:[15,15,15]

        lookAtDummy.rotation.controller = LookAt_Constraint()
        lookAtDummy.rotation.controller.appendTarget controlDummy 50
        lookAtDummy.rotation.controller.viewline_length_abs = off
        lookAtDummy.rotation.controller.lookat_vector_length = 0
        lookAtDummy.rotation.controller.upnode_world = off
        lookAtDummy.rotation.controller.pickUpNode  = controlDummy
        local mainIKControlPoint = IKSys.ikChain controlPoints[1] controlPoints[controlPoints.count] "IKHISolver"
        mainIKControlPoint.parent = controlDummy
        lookAtDummy.parent = baseDummy
        #(baseDummy, lookAtDummy, controlDummy, mainIKControlPoint)
    ),

    -- 设置IK链的父子关系和目标
    fn setupIKChainParentsAndTargets boneNodes ikChains controlPoints dummies =
    (
        local baseDummy = dummies[1]
        local lookAtDummy = dummies[2]
        local controlDummy = dummies[3]
        local mainIKControlPoint = dummies[4]

        if boneNodes.count == 5 and ikChains[2] != undefined and ikChains[1] != undefined then
        (
            local primaryIKChain = ikChains[1]
            local secondaryIKChain = ikChains[2]

            secondaryIKChain.parent = mainIKControlPoint
            primaryIKChain.parent = controlPoints[3]

            local primaryIKTarget = point box:on cross:off pos:[boneNodes[2].pos.x, boneNodes[2].pos.y, boneNodes[2].pos.z-30]
            local secondaryIKTarget = point box:on cross:off pos:[boneNodes[4].pos.x, boneNodes[4].pos.y, boneNodes[4].pos.z+30]

            primaryIKTarget.parent = lookAtDummy
            secondaryIKTarget.parent = lookAtDummy

            primaryIKChain.transform.controller.VHTarget = primaryIKTarget
            secondaryIKChain.transform.controller.VHTarget = secondaryIKTarget
            mainIKControlPoint.transform.controller.VHTarget = secondaryIKTarget
        )
        else if boneNodes.count == 3 and ikChains[1] != undefined then
        (
            local primaryIKChain = ikChains[1]
            primaryIKChain.parent = controlPoints[3]
            local primaryIKTarget = point box:on cross:off pos:[boneNodes[2].pos.x, boneNodes[2].pos.y, boneNodes[2].pos.z+30]
            primaryIKTarget.parent = lookAtDummy
            primaryIKChain.transform.controller.VHTarget = primaryIKTarget
            mainIKControlPoint.transform.controller.VHTarget = primaryIKTarget
        )
    ),

    -- 主函数，用于创建IK解算器
    fn create boneNodesParam:undefined =
    (
        boneNodes = boneNodesParam
        if boneNodes == undefined do
            boneNodes = selection as array

        if boneNodes == undefined or boneNodes.count < 3 then
            return false

        ikChains = createIKChains boneNodes
        controlPoints = createControlPoints boneNodes
        dummies = createDummiesAndSetConstraints boneNodes controlPoints
        setupIKChainParentsAndTargets boneNodes ikChains controlPoints dummies
        true
    )
)
