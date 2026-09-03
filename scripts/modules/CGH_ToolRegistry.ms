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
            #viewerExporter: "查看合并导出插件.ms"
            #fbxBatchExporter: "FBX批量导出.ms"
            #fbxToBip: "AutoFbxtoBip v1.4.mse"
            #animRange: "Process_text_file_for_animation_range.ms"
            #boneDivider: "bonedivider.ms"
            #copyTrack: "复制物体运动轨迹.ms"
            #referenceMaster: "参考大师v1.06.mse"
            #resetSkinPose: "重置蒙皮pose V1.1.mse"
            #combineSkin: "Rigging_CombineSkin.ms"
            #facialRig: "facialRig_UI.ms"
            #bodyRig: "自定义骨骼绑定.ms"
            #addSkinBones: "add_Skin_Bones.ms"
            #skinTools: "skinTools.ms"
            #copySkinWeights: "copy_paste_skin_weight.ms"
            #twistBones: "TwistBones.ms"
            #restoreBiped: "还原bip的外观和修改器.mse"
            #selectSameName: "选择同名物体.ms"
            #animcraftFloat: "animcraft_float_Script_edit.ms"
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

