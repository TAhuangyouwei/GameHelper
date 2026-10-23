-- HYW_Scripts_Library.ms
/*
    GameHelper 公共库兼容入口。

    功能代码已经拆分到“公共模块”子目录。旧脚本仍然只需要 fileIn 本文件，
    原来的结构名和调用方式保持不变。
*/
(
    local libraryFolder = getFilenamePath (getThisScriptFilename())
    local moduleRelativePaths = #(
        "公共模块/材质/MaterialUtilities.ms",
        "公共模块/骨骼绑定/BipedFunctions.ms",
        "公共模块/骨骼绑定/CustomIKHISolver.ms",
        "公共模块/模型/ModelUtilities.ms",
        "公共模块/模型/ObjectProcessing.ms",
        "公共模块/视口/ViewportUtilities.ms",
        "公共模块/场景/SceneUtilities.ms",
        "公共模块/场景/LayerUtilities.ms",
        "公共模块/界面交互/InterfaceUtilities.ms",
        "公共模块/骨骼绑定/BoneUtilities.ms",
        "公共模块/动画/AnimationUtilities.ms",
        "公共模块/蒙皮/BoneSkinUtilities.ms",
        "公共模块/界面组件/RolloutUiUtilities.ms",
        "公共模块/界面组件/EmbeddedImageData.ms"
    )
    local missingModulePaths = #()

    for relativePath in moduleRelativePaths do
    (
        local modulePath = pathConfig.appendPath libraryFolder relativePath

        if not doesFileExist modulePath do
            append missingModulePaths modulePath
    )

    if missingModulePaths.count > 0 then
    (
        local warningMessage = "以下 GameHelper 公共模块没有找到："

        for modulePath in missingModulePaths do
            warningMessage += "\n" + modulePath

        throw warningMessage
    )

    for relativePath in moduleRelativePaths do
    (
        local modulePath = pathConfig.appendPath libraryFolder relativePath

        local moduleError = undefined
        try (fileIn modulePath)
        catch (moduleError = getCurrentException())

        if moduleError != undefined do
            throw ("GameHelper 公共模块加载失败：\n" + modulePath + "\n\n" + moduleError)
    )

    true
)
