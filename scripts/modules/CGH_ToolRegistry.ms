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
            #viewerExporter: "tools/export/查看合并导出插件.ms"
            #fbxBatchExporter: "tools/export/FBX批量导出.ms"
            #fbxToBip: "opaque/auto_fbx_to_bip/AutoFbxtoBip v1.4.mse"
            #animRange: "tools/animation/Process_text_file_for_animation_range.ms"
            #boneDivider: "tools/rigging/bonedivider.ms"
            #copyTrack: "tools/animation/复制物体运动轨迹.ms"
            #referenceMaster: "opaque/reference_master/参考大师v1.06.mse"
            #resetSkinPose: "opaque/reset_skin_pose/重置蒙皮pose V1.1.mse"
            #combineSkin: "tools/skin/Rigging_CombineSkin.ms"
            #facialRig: "tools/facial/facialRig_UI.ms"
            #bodyRig: "tools/rigging/自定义骨骼绑定.ms"
            #addSkinBones: "tools/skin/add_Skin_Bones.ms"
            #skinTools: "tools/skin/skinTools.ms"
            #copySkinWeights: "tools/skin/copy_paste_skin_weight.ms"
            #twistBones: "vendor/twist_bones/TwistBones.ms"
            #restoreBiped: "opaque/restore_biped/还原bip的外观和修改器.mse"
            #selectSameName: "tools/scene/选择同名物体.ms"
            #animcraftFloat: "tools/facial/animcraft_float_Script_edit.ms"
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

