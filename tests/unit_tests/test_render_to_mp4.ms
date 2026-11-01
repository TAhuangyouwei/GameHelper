/* Run in a fresh 3dsmaxbatch process; does not open or save any scene. */
(
    local root = pathConfig.appendPath (getFilenamePath (getThisScriptFilename())) "../../"
    local script = pathConfig.appendPath root "scripts/实用工具/动画/渲染后自动转MP4.ms"
    fn check ok message = (if not ok do throw message)
    fileIn script
    local registered = stringStream ""
    callbacks.show id:#CGH_AutoMP4 to:registered
    local initial = registered as string
    check (findString initial "preRender" != undefined) "Register preRender"
    check (findString initial "postRenderFrame" == undefined) "Do not depend on per-frame callbacks"
    check (findString initial "postRender:" != undefined) "Register postRender"
    fileIn script
    registered = stringStream ""
    callbacks.show id:#CGH_AutoMP4 to:registered
    check ((registered as string) == initial) "Reload must not duplicate callbacks"
    rendSaveFile = true
    rendOutputFilename = "C:\\test 中文.avi"
    CGH_AutoMP4.beginRender()
    check (CGH_AutoMP4.source == rendOutputFilename) "Capture AVI output"
    local info = CGH_AutoMP4.createProcessInfo rendOutputFilename notify:false
    check (doesFileExist info.FileName) "Regression: resolve PowerShell using systemTools.getEnvVariable"
    check (findString info.Arguments "-EncodedCommand" != undefined) "Use Unicode-safe process arguments"
    rendOutputFilename = "C:\\test.png"
    CGH_AutoMP4.beginRender()
    check (CGH_AutoMP4.source == "") "Ignore image output"
    rendOutputFilename = "C:\\test.avi"
    rendSaveFile = false
    CGH_AutoMP4.beginRender()
    check (CGH_AutoMP4.source == "") "Ignore unsaved render"
    check ((CGH_AutoMP4.quotePS "a'b & 中文") == "'a''b & 中文'") "Quote PowerShell paths"
    CGH_AutoMP4.disable()
    registered = stringStream ""
    callbacks.show id:#CGH_AutoMP4 to:registered
    check ((registered as string) == "") "Disable removes callbacks"
    format "PASS: MP4 callbacks without frame events, PowerShell executable, reload, AVI filtering, quoting, disable.\n"
)
