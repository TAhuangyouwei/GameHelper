/*
    Regression checks for public-library loading and main-panel initialization.
    Run in 3dsmaxbatch.exe. Uses temporary stub modules; never opens scenes.
*/

global CGH_TestFixtureRoot
global CGH_TestLoadedModules
global CGH_GetCurrentScriptFolder
global CGH_InitializeAniTools
global CGH_MainFolder
global CGH_ToolRegistry

(
    local testRoot = getFilenamePath (getThisScriptFilename())
    local scriptsRoot = pathConfig.appendPath testRoot "../../scripts/"
    local fileIO = dotNetClass "System.IO.File"
    local directoryIO = dotNetClass "System.IO.Directory"
    local pathIO = dotNetClass "System.IO.Path"
    local tempRoot = pathIO.GetFullPath (pathIO.GetTempPath())
    local fixtureRoot = pathIO.Combine tempRoot ("GameHelper-library-test-" + ((dotNetClass "System.Guid").NewGuid()).ToString())
    local libraryPath = pathConfig.appendPath fixtureRoot "HYW_Scripts_Library.ms"
    local registryPath = pathConfig.appendPath fixtureRoot "公共模块/CGH_ToolRegistry.ms"
    local modulePaths = #()
    local originalGetFolder = ::CGH_GetCurrentScriptFolder
    local originalInitialize = ::CGH_InitializeAniTools
    local originalMainFolder = ::CGH_MainFolder
    local originalRegistry = ::CGH_ToolRegistry
    local failure = undefined

    fn assertTrue condition description =
    (
        if not condition do throw description
    )

    fn writeScript scriptPath content =
    (
        local directoryIO = dotNetClass "System.IO.Directory"
        local fileIO = dotNetClass "System.IO.File"
        local utf8 = (dotNetClass "System.Text.Encoding").UTF8
        directoryIO.CreateDirectory (getFilenamePath scriptPath)
        fileIO.WriteAllText scriptPath content utf8
    )

    try
    (
        local normalizedScriptsRoot = (trimRight (pathIO.GetFullPath scriptsRoot) "\\/") + "\\"
        local moduleRoot = pathConfig.appendPath normalizedScriptsRoot "公共模块"
        local moduleFiles = directoryIO.GetFiles moduleRoot "*.ms" (dotNetClass "System.IO.SearchOption").AllDirectories

        directoryIO.CreateDirectory fixtureRoot
        fileIO.Copy (pathConfig.appendPath scriptsRoot "HYW_Scripts_Library.ms") libraryPath

        for moduleFile in moduleFiles where (getFilenameFile moduleFile) != "CGH_ToolRegistry" do
        (
            local relativePath = substring moduleFile (normalizedScriptsRoot.count + 1) -1
            local modulePath = pathConfig.appendPath fixtureRoot relativePath
            append modulePaths modulePath
            writeScript modulePath "append ::CGH_TestLoadedModules true"
        )

        assertTrue (modulePaths.count == 14) "Fixture must cover all 14 public modules."
        CGH_TestLoadedModules = #()
        assertTrue ((fileIn libraryPath) == true) "A complete public library must return true."
        assertTrue (CGH_TestLoadedModules.count == 14) "A complete public library must load every module."

        local missingPath = modulePaths[modulePaths.count]
        fileIO.Delete missingPath
        CGH_TestLoadedModules = #()
        local loadError = undefined
        try (fileIn libraryPath) catch (loadError = getCurrentException())
        assertTrue (loadError != undefined) "A missing module must fail library loading."
        assertTrue ((findString loadError missingPath) != undefined) "Missing-module errors must identify the path."
        assertTrue (CGH_TestLoadedModules.count == 0) "Missing-module preflight must run before any module."

        writeScript missingPath "append ::CGH_TestLoadedModules true"
        local brokenPath = modulePaths[1]
        writeScript brokenPath "throw \"Intentional module failure\""
        loadError = undefined
        try (fileIn libraryPath) catch (loadError = getCurrentException())
        assertTrue (loadError != undefined) "Module execution errors must fail library loading."
        assertTrue ((findString loadError brokenPath) != undefined) "Module execution errors must identify the path."
        writeScript brokenPath "append ::CGH_TestLoadedModules true"

        -- Evaluate only the actual initializer, without constructing any panel.
        local sourceEncoding = (dotNetClass "System.Text.Encoding").GetEncoding 936
        local mainSource = fileIO.ReadAllText (pathConfig.appendPath scriptsRoot "AnimTools.ms") sourceEncoding
        local initializerStart = findString mainSource "fn CGH_InitializeAniTools ="
        assertTrue (initializerStart != undefined) "Main-panel initializer was not found."
        local initializerSource = substring mainSource initializerStart -1
        local initializerEnd = findString initializerSource "/*"
        assertTrue (initializerEnd != undefined) "Main-panel initializer boundary was not found."
        initializerSource = substring initializerSource 1 (initializerEnd - 1)
        execute initializerSource
        CGH_TestFixtureRoot = fixtureRoot
        execute "fn CGH_GetCurrentScriptFolder = ::CGH_TestFixtureRoot"

        -- Simulate the registry reporting a missing library, without a modal dialog.
        writeScript registryPath "struct CGH_TestRegistryStruct (fn initialize value = true, fn loadTool toolId = false)\nCGH_ToolRegistry = CGH_TestRegistryStruct()"
        assertTrue ((CGH_InitializeAniTools()) == false) "A failed library load must fail main-panel initialization."

        writeScript registryPath "struct CGH_TestRegistryStruct (fn initialize value = false, fn loadTool toolId = throw \"Must not load after failed initialize\")\nCGH_ToolRegistry = CGH_TestRegistryStruct()"
        assertTrue ((CGH_InitializeAniTools()) == false) "A failed registry initialize must stop before loading the library."

        writeScript registryPath "struct CGH_TestRegistryStruct (fn initialize value = true, fn loadTool toolId = true)\nCGH_ToolRegistry = CGH_TestRegistryStruct()"
        assertTrue ((CGH_InitializeAniTools()) == true) "Successful library loading must allow main-panel initialization."
    )
    catch (failure = getCurrentException())

    CGH_GetCurrentScriptFolder = originalGetFolder
    CGH_InitializeAniTools = originalInitialize
    CGH_MainFolder = originalMainFolder
    CGH_ToolRegistry = originalRegistry
    CGH_TestFixtureRoot = undefined
    CGH_TestLoadedModules = undefined

    -- Remove only the unique fixture beneath the resolved temporary directory.
    local resolvedFixture = pathIO.GetFullPath fixtureRoot
    local fixtureParent = pathIO.GetFullPath (getFilenamePath (trimRight resolvedFixture "\\/"))
    if (toLower (trimRight fixtureParent "\\/")) == (toLower (trimRight tempRoot "\\/")) and directoryIO.Exists resolvedFixture do
        directoryIO.Delete resolvedFixture true

    if failure != undefined do throw failure
    format "PASS: public-library success, missing modules, execution failures and main-panel initialization.\n"
)
