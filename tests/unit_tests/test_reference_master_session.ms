/* Run in Max to check session cleanup without opening reference windows. */
(
    local testDir = getFilenamePath (getThisScriptFilename())
    local launcherPath = pathConfig.appendPath testDir "../../scripts/实用工具/动画/参考大师v1.06.ms"
    local input = openFile launcherPath encoding:#utf8
    local source = ""
    while not eof input do source += (readLine input) + "\n"
    close input
    source = substituteString source "getThisScriptFilename()" ("@\"" + (substituteString launcherPath "\\" "/") + "\"")
    source = substituteString source "    session.CreateView()" "    session"

    local savedSession = ::RefPlayerSession
    local savedClose = ::RefPlayer_Close
    local failure = undefined
    struct RefPlayerLegacySessionProbe (CloseCallbacks = #())
    struct RefPlayerCleanupProbe
    (
        calls = 0,
        session,
        fn OnQuit =
        (
            calls += 1
            if session.CloseCallbacks.count > 0 do deleteItem session.CloseCallbacks 1
        )
    )
    local probe = RefPlayerCleanupProbe()
    fn quitFirst = probe.OnQuit()
    fn quitSecond = probe.OnQuit()
    fn staleClose = throw "Cached broken close function must not run"

    try
    (
        -- Reproduce the cached, already-closed session from the reported error.
        ::RefPlayerSession = RefPlayerLegacySessionProbe()
        ::RefPlayer_Close = staleClose
        local session = execute source
        session.CloseAll()
        session.CloseAll()
        if session.CloseCallbacks.count != 0 do throw "Empty cleanup failed"

        -- Each callback removes itself; both must still be called exactly once.
        session.CloseCallbacks = #(quitFirst,quitSecond)
        probe.session = session
        session.CloseAll()
        session.CloseAll()
        if probe.calls != 2 or session.CloseCallbacks.count != 0 do throw "Cleanup snapshot failed"

        -- Updating a still-open old session must bypass its cached broken function.
        probe.calls = 0
        probe.session = RefPlayerLegacySessionProbe CloseCallbacks:#(quitFirst,quitSecond)
        ::RefPlayerSession = probe.session
        ::RefPlayer_Close = staleClose
        execute source
        if probe.calls != 2 or probe.session.CloseCallbacks.count != 0 do throw "Old session migration failed"
    )
    catch (failure = getCurrentException())

    ::RefPlayerSession = savedSession
    ::RefPlayer_Close = savedClose
    if failure != undefined do throw failure
    format "PASS: empty/repeated cleanup, mutating callbacks, cached session migration\n"
)
