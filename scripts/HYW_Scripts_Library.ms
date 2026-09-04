-- HYW_Scripts_Library.ms
/*
    GameHelper 公共库兼容入口。

    功能代码已经拆分到 modules 子目录。旧脚本仍然只需要 fileIn 本文件，
    原来的结构名和调用方式保持不变。
*/
(
    local libraryFolder = getFilenamePath (getThisScriptFilename())
    local moduleRelativePaths = #(
        "modules/material/MaterialUtilities.ms",
        "modules/rigging/BipedFunctions.ms",
        "modules/rigging/CustomIKHISolver.ms",
        "modules/model/ModelUtilities.ms",
        "modules/model/ObjectProcessing.ms",
        "modules/viewport/ViewportUtilities.ms",
        "modules/scene/SceneUtilities.ms",
        "modules/scene/LayerUtilities.ms",
        "modules/interface/InterfaceUtilities.ms",
        "modules/rigging/BoneUtilities.ms",
        "modules/animation/AnimationUtilities.ms",
        "modules/skin/BoneSkinUtilities.ms",
        "modules/ui/RolloutUiUtilities.ms",
        "modules/ui/EmbeddedImageData.ms"
    )
    local missingModulePaths = #()

    for relativePath in moduleRelativePaths do
    (
        local modulePath = pathConfig.appendPath libraryFolder relativePath

        if doesFileExist modulePath then
            fileIn modulePath
        else
            append missingModulePaths modulePath
    )

    if missingModulePaths.count > 0 then
    (
        local warningMessage = "以下 GameHelper 公共模块没有找到："

        for modulePath in missingModulePaths do
            warningMessage += "\n" + modulePath

        messageBox warningMessage title:"GameHelper 加载失败"
    )
)
