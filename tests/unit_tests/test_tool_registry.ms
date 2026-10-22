/*
    Smoke test for scripts/公共模块/CGH_ToolRegistry.ms.
    Run with 3dsmaxbatch.exe; this test only checks registered file paths.
*/

(
    local testRoot = getFilenamePath (getThisScriptFilename())
    local scriptsRoot = pathConfig.appendPath testRoot "../../scripts"
    local registryPath = pathConfig.appendPath scriptsRoot "公共模块/CGH_ToolRegistry.ms"
    local toolIds = #(
        #library,
        #animTools,
        #viewerExporter,
        #fbxBatchExporter,
        #fbxToBip,
        #animRange,
        #boneDivider,
        #copyTrack,
        #referenceMaster,
        #resetSkinPose,
        #combineSkin,
        #facialRig,
        #bodyRig,
        #addSkinBones,
        #skinTools,
        #copySkinWeights,
        #twistBones,
        #restoreBiped,
        #selectSameName,
        #animcraftFloat
    )
    local missingTools = #()

    if not doesFileExist registryPath do
        throw ("Registry file not found: " + registryPath)

    fileIn registryPath

    if ::CGH_ToolRegistry == undefined do
        throw "CGH_ToolRegistry was not created."

    if not (::CGH_ToolRegistry.initialize scriptsRoot) do
        throw "CGH_ToolRegistry could not be initialized."

    if (::CGH_ToolRegistry.getRelativePath #referenceMaster) != "实用工具/动画/参考大师v1.06.ms" do
        throw "Reference Master must load its readable source."

    if (::CGH_ToolRegistry.getRelativePath #resetSkinPose) != "实用工具/蒙皮/重置蒙皮pose V1.1.ms" do
        throw "Reset Skin Pose must load its readable source."

    for toolId in toolIds where not doesFileExist (::CGH_ToolRegistry.getPath toolId) do
        append missingTools toolId

    if missingTools.count > 0 do
        throw ("Missing registered tools: " + (missingTools as string))

    format "PASS: CGH_ToolRegistry resolved % tools.\n" toolIds.count
)

