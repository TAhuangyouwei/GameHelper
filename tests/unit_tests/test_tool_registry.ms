/*
    Smoke test for scripts/modules/CGH_ToolRegistry.ms.
    Run with 3dsmaxbatch.exe; this test only checks registered file paths.
*/

(
    local testRoot = getFilenamePath (getThisScriptFilename())
    local scriptsRoot = pathConfig.appendPath testRoot "../../scripts"
    local registryPath = pathConfig.appendPath scriptsRoot "modules/CGH_ToolRegistry.ms"
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

    for toolId in toolIds where not doesFileExist (::CGH_ToolRegistry.getPath toolId) do
        append missingTools toolId

    if missingTools.count > 0 do
        throw ("Missing registered tools: " + (missingTools as string))

    format "PASS: CGH_ToolRegistry resolved % tools.\n" toolIds.count
)

