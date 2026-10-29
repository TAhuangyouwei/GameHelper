/* Run in Max: exercise the actual settings controller with temporary INI files, no windows or scenes. */
(
    local sourcePath = pathConfig.appendPath (getFilenamePath (getThisScriptFilename())) "../../scripts/实用工具/动画/参考大师_窗口.ms"
    local input = openFile sourcePath encoding:#utf8
    local source = ""
    while not eof input do source += (readLine input) + "\n"
    close input
    local first = findString source "        struct sSettingCtrl"
    local last = findString source "        SettingCtrl = sSettingCtrl()"
    if first == undefined or last == undefined do throw "Settings controller not found"
    source = substring source first (last-first)

    local guidClass = dotnetclass "System.Guid"
    local guid = guidClass.NewGuid()
    local testDir = pathConfig.appendPath (getdir #temp) ("RefPlayerSettingsTest_" + (guid.ToString "N"))
    makeDir testDir
    local quotedDir = "@\"" + (substituteString testDir "\\" "/") + "\""
    source = substituteString source "getdir #plugcfg" quotedDir
    local setup = "(local RPViewIndex = 1\nlocal ApplyingSharedSettings = false\n"
    setup += "struct RefSettingsWindowProbe (Changes = #(), fn BroadcastSettings category = append Changes category)\n"
    setup += "local ui_PlayerWindow = RefSettingsWindowProbe()\n"
    local checks = "
        struct RefSettingsValueProbe (Category,Value)
        local firstCtrl = sSettingCtrl()
        RPViewIndex = 2
        local secondCtrl = sSettingCtrl()
        local firstValue = 0
        local secondValue = 0
        local a = RefSettingsValueProbe Value:&firstValue
        local b = RefSettingsValueProbe Value:&secondValue
        for category in #(\"RAMSetting\",\"RecordSetting\",\"GridSetting\",\"DisplaySetting\",\"CacheSetting\") do
        (
            a.Category = category
            b.Category = category
            firstValue = 37
            secondValue = 0
            firstCtrl.Save a
            secondCtrl.Load b
            if secondValue != 37 do throw \"A sibling did not load the shared setting\"
            secondValue = 83
            secondCtrl.Save b
            firstCtrl.Load a
            if firstValue != 83 do throw \"A sibling could not change the shared setting\"
        )
        if ui_PlayerWindow.Changes.count != 10 do throw \"Shared setting notifications missing\"
        local siblingIni = pathConfig.appendPath TEST_DIR \"RefPlayer2020_View2.ini\"
        if doesFileExist siblingIni do throw \"Shared settings leaked into the per-view INI\"

        for category in #(\"PlayerSetting\",\"PlayList\") do
        (
            a.Category = category
            b.Category = category
            firstValue = 11
            secondValue = 22
            firstCtrl.Save a
            secondCtrl.Save b
            firstValue = secondValue = 0
            firstCtrl.Load a
            secondCtrl.Load b
            if firstValue != 11 or secondValue != 22 do throw \"Per-view position/history settings were merged\"
        )
        if ui_PlayerWindow.Changes.count != 10 do throw \"Per-view settings notified siblings\"

        a.Category = \"GridSetting\"
        b.Category = \"GridSetting\"
        firstValue = 999
        ApplyingSharedSettings = true
        firstCtrl.Save a
        ApplyingSharedSettings = false
        secondCtrl.Load b
        if secondValue != 83 or ui_PlayerWindow.Changes.count != 10 do throw \"Applying settings echoed a stale value\"
        RPViewIndex = 3
        local newCtrl = sSettingCtrl()
        newCtrl.Load b
        if secondValue != 83 do throw \"A new view did not inherit shared settings\"
        format \"PASS: shared INI read/write, updates from either view, new-view inheritance, isolated position/history, no feedback writes\\n\"
    )"
    checks = substituteString checks "TEST_DIR" quotedDir
    local failure = undefined
    try (execute (setup + source + checks)) catch (failure = getCurrentException())
    for name in #("RefPlayer2020.ini","RefPlayer2020_View2.ini") do deleteFile (pathConfig.appendPath testDir name)
    removeDir testDir
    if failure != undefined do throw failure
)
