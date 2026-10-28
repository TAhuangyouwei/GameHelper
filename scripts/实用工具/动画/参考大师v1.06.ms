/* 参考大师多视图入口：每个视角加载同一套完整窗口逻辑。 */
(
    local corePath = pathConfig.appendPath (getFilenamePath (getThisScriptFilename())) "参考大师_窗口.ms"
    if not doesFileExist corePath do throw ("找不到参考大师窗口脚本：" + corePath)
    if ::RefPlayerSession != undefined then
    (
        -- Old sessions may retain the broken CloseAll function until Max exits.
        local previousSession = ::RefPlayerSession
        local pending = for quitView in previousSession.CloseCallbacks collect quitView
        for quitView in pending do quitView()
    )
    else if ::RefPlayer_Close != undefined do ::RefPlayer_Close()

    struct RefPlayerSessionData
    (
        CorePath,
        Assembly,
        TypeNamespace,
        NextIndex = 0,
        PendingIndex = 0,
        PendingBeside,
        CloseCallbacks = #(),

        fn CreateView beside:undefined =
        (
            NextIndex += 1
            PendingIndex = NextIndex
            PendingBeside = beside
            fileIn CorePath
        ),

        fn CloseAll =
        (
            local pending = for quitView in CloseCallbacks collect quitView
            for quitView in pending do quitView()
        )
    )

    local rpGuidClass = dotnetclass "System.Guid"
    local rpRunGuid = rpGuidClass.NewGuid()
    local session = RefPlayerSessionData CorePath:corePath TypeNamespace:("RefPlayerMV_" + (rpRunGuid.ToString "N"))
    global RefPlayerSession = session
    global RefPlayer_Close = (fn CloseAllRefPlayerViews = session.CloseAll())

    session.CreateView()
)
