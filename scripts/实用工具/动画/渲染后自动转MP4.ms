/* Max 2024: load once per session, or load from the user's startup folder.
   AVI stays unchanged. Encoding runs in a separate, hidden process. */
global CGH_AutoMP4
global CGH_AutoMP4Struct

struct CGH_AutoMP4Struct
(
    folder,
    source = "",
    previousWriteTime = "",
    previousLength = "0",
    tracePath = pathConfig.appendPath (getDir #temp) "GameHelper-AutoMP4.log",

    fn quotePS value = ("'" + (substituteString value "'" "''") + "'"),

    fn trace message =
    (
        format "GameHelper MP4: %\n" message
        try
        (
            (dotNetClass "System.IO.File").AppendAllText tracePath ((dotNetClass "System.DateTime").Now.ToString("s") + " " + message + "\r\n")
        ) catch (format "GameHelper MP4: 无法写入诊断日志：%\n" (getCurrentException()))
    ),

    fn beginRender =
    (
        source = ""
        previousWriteTime = ""
        previousLength = "0"
        trace ("preRender save=" + (rendSaveFile as string) + " output=" + rendOutputFilename)
        if rendSaveFile and (toLower (getFilenameType rendOutputFilename)) == ".avi" do
        (
            source = rendOutputFilename
            if doesFileExist source do
            (
                local file = dotNetObject "System.IO.FileInfo" source
                previousWriteTime = file.LastWriteTimeUtc.ToString "O"
                previousLength = (dotNetClass "System.Convert").ToString file.Length
            )
        )
        source
    ),

    fn createProcessInfo input notify:true =
    (
        local worker = pathConfig.appendPath folder "RenderToMP4.ps1"
        local ffmpeg = (dotNetClass "System.IO.Path").GetFullPath (pathConfig.appendPath folder "../../../.local/refplayer/ffmpeg.exe")
        if not (doesFileExist worker) or not (doesFileExist ffmpeg) do
            throw "找不到转码脚本或 FFmpeg，请保留完整 GameHelper 目录。"
        local command = "& " + (quotePS worker) + " -InputPath " + (quotePS input) + " -FFmpegPath " + (quotePS ffmpeg)
        if previousWriteTime != "" do command += " -PreviousWriteTime " + (quotePS previousWriteTime) + " -PreviousLength " + previousLength
        if notify do command += " -Notify"
        local bytes = (dotNetClass "System.Text.Encoding").Unicode.GetBytes command
        local encoded = (dotNetClass "System.Convert").ToBase64String bytes
        local info = dotNetObject "System.Diagnostics.ProcessStartInfo"
        info.FileName = pathConfig.appendPath (systemTools.getEnvVariable "SystemRoot") "System32/WindowsPowerShell/v1.0/powershell.exe"
        info.Arguments = "-NoProfile -NonInteractive -ExecutionPolicy Bypass -EncodedCommand " + encoded
        info.UseShellExecute = false
        info.CreateNoWindow = true
        info
    ),

    fn finishRender =
    (
        local input = source
        source = ""
        trace ("postRender input=" + input)
        if input == "" do return false
        try
        (
            local info = createProcessInfo input
            local process = (dotNetClass "System.Diagnostics.Process").Start info
            trace ("转换进程已启动，PID=" + (process.Id as string))
            process.Dispose()
            true
        )
        catch
        (
            trace ("启动失败：" + getCurrentException())
            messageBox ("无法启动 MP4 转换：\n" + getCurrentException()) title:"GameHelper MP4"
            false
        )
    ),

    fn disable =
    (
        callbacks.removeScripts id:#CGH_AutoMP4
        source = ""
        true
    ),

    fn enable =
    (
        disable()
        callbacks.addScript #preRender "CGH_AutoMP4.beginRender()" id:#CGH_AutoMP4 persistent:false
        callbacks.addScript #postRender "CGH_AutoMP4.finishRender()" id:#CGH_AutoMP4 persistent:false
        trace "已启用 v2：AVI 渲染后自动转 MP4（保留 AVI，不依赖逐帧通知）。"
        format "GameHelper MP4: 诊断日志：%\n" tracePath
        true
    )
)

if CGH_AutoMP4 != undefined do CGH_AutoMP4.disable()
CGH_AutoMP4 = CGH_AutoMP4Struct folder:(getFilenamePath (getThisScriptFilename()))
CGH_AutoMP4.enable()
