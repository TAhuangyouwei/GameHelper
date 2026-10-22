/*
    GameHelper tool registry.
    Keep every script location in this file so tools can be moved without
    rewriting rollout event handlers.
*/

global CGH_ToolRegistry

struct CGH_ToolRegistryStruct
(
    rootPath = undefined,

    fn initialize value =
    (
        if value == undefined or value == "" then
        (
            rootPath = undefined
            false
        )
        else
        (
            rootPath = pathConfig.appendPath value ""
            true
        )
    ),

    fn getRelativePath toolId =
    (
        case toolId of
        (
            #library: "HYW_Scripts_Library.ms"
            #animTools: "AnimTools.ms"
            #viewerExporter: "实用工具/导出/查看合并导出插件.ms"
            #fbxBatchExporter: "实用工具/导出/FBX批量导出.ms"
            #fbxToBip: "加密与封装工具/FBX转Biped/AutoFbxtoBip v1.4.mse"
            #animRange: "实用工具/动画/Process_text_file_for_animation_range.ms"
            #boneDivider: "实用工具/骨骼绑定/bonedivider.ms"
            #copyTrack: "实用工具/动画/复制物体运动轨迹.ms"
            #referenceMaster: "加密与封装工具/参考大师/参考大师v1.06.mse"
            #resetSkinPose: "加密与封装工具/重置蒙皮姿态/重置蒙皮pose V1.1.mse"
            #combineSkin: "实用工具/蒙皮/Rigging_CombineSkin.ms"
            #facialRig: "实用工具/面部绑定/facialRig_UI.ms"
            #bodyRig: "实用工具/骨骼绑定/自定义骨骼绑定.ms"
            #addSkinBones: "实用工具/蒙皮/add_Skin_Bones.ms"
            #skinTools: "实用工具/蒙皮/skinTools.ms"
            #copySkinWeights: "实用工具/蒙皮/copy_paste_skin_weight.ms"
            #twistBones: "第三方工具/扭转骨骼/TwistBones.ms"
            #restoreBiped: "加密与封装工具/还原Biped外观与修改器/还原bip的外观和修改器.mse"
            #selectSameName: "实用工具/场景/选择同名物体.ms"
            #animcraftFloat: "实用工具/面部绑定/animcraft_float_Script_edit.ms"
            default: undefined
        )
    ),

    fn getPath toolId =
    (
        local relativePath = getRelativePath toolId

        if rootPath == undefined or relativePath == undefined then
            undefined
        else
            pathConfig.appendPath rootPath relativePath
    ),

    fn loadTool toolId =
    (
        local scriptPath = getPath toolId

        if scriptPath == undefined then
        (
            messageBox ("GameHelper tool is not registered: " + (toolId as string))
            false
        )
        else if doesFileExist scriptPath then
        (
            fileIn scriptPath
            true
        )
        else
        (
            messageBox ("GameHelper script was not found:" + "\n" + scriptPath)
            false
        )
    )
)

CGH_ToolRegistry = CGH_ToolRegistryStruct()

