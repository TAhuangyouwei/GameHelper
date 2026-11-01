param(
    [Parameter(Mandatory = $true)][string]$InputPath,
    [Parameter(Mandatory = $true)][string]$FFmpegPath,
    [string]$PreviousWriteTime = '',
    [long]$PreviousLength = 0,
    [switch]$Notify
)

$ErrorActionPreference = 'Stop'
$partial = $null
$logPath = $InputPath + '.mp4.log'
try {
    if ([IO.Path]::GetExtension($InputPath) -ine '.avi') { throw '仅支持 AVI 输入。' }
    if (-not [IO.File]::Exists($InputPath)) { throw "找不到 AVI：$InputPath" }
    if (-not [IO.File]::Exists($FFmpegPath)) { throw "找不到 FFmpeg：$FFmpegPath" }

    # postRender may run just before Max closes its AVI writer.
    $ready = $false
    for ($attempt = 0; $attempt -lt 60; $attempt++) {
        try {
            $stream = [IO.File]::Open($InputPath, 'Open', 'Read', 'None')
            $stream.Dispose()
            $ready = $true
            break
        } catch [IO.IOException] { Start-Sleep -Milliseconds 500 }
    }
    if (-not $ready) { throw 'AVI 仍被占用，请等渲染写入完成后再试。' }

    # Some renderers omit postRenderFrame. Inspect the closed AVI instead of
    # requiring per-frame callbacks; unchanged old output must not be converted.
    $inputFile = Get-Item -LiteralPath $InputPath
    if ($PreviousWriteTime -and $inputFile.LastWriteTimeUtc.ToString('o') -eq $PreviousWriteTime -and
        $inputFile.Length -eq $PreviousLength) {
        [IO.File]::WriteAllText($logPath, '跳过转换：本次渲染未更新 AVI。', [Text.Encoding]::UTF8)
        exit 0
    }

    $base = [IO.Path]::Combine([IO.Path]::GetDirectoryName($InputPath), [IO.Path]::GetFileNameWithoutExtension($InputPath))
    $partial = $base + '.' + [Guid]::NewGuid().ToString('N') + '.partial.mp4'
    $info = New-Object Diagnostics.ProcessStartInfo
    $info.FileName = $FFmpegPath
    $info.Arguments = '-nostdin -hide_banner -loglevel error -xerror -n -i "' + $InputPath +
        '" -map 0:v:0 -map 0:a? -c:v libx264 -crf 18 -preset medium' +
        ' -vf "pad=ceil(iw/2)*2:ceil(ih/2)*2" -pix_fmt yuv420p -c:a aac -b:a 192k -movflags +faststart "' + $partial + '"'
    $info.UseShellExecute = $false
    $info.CreateNoWindow = $true
    $info.RedirectStandardError = $true
    $process = New-Object Diagnostics.Process
    $process.StartInfo = $info
    try {
        [void]$process.Start()
        $details = $process.StandardError.ReadToEnd()
        $process.WaitForExit()
        if ($process.ExitCode -ne 0) { throw "FFmpeg 转换失败：`r`n$details" }
    } finally { $process.Dispose() }
    if (-not [IO.File]::Exists($partial) -or (Get-Item -LiteralPath $partial).Length -eq 0) {
        throw '未生成有效的 MP4 文件。'
    }
    $output = $base + '.mp4'
    $index = 1
    while ([IO.File]::Exists($output)) {
        $output = $base + '_' + $index.ToString('000') + '.mp4'
        $index++
    }
    [IO.File]::Move($partial, $output)
    $partial = $null
    [IO.File]::WriteAllText($logPath, "MP4 已生成：$output`r`nAVI 已保留。", [Text.Encoding]::UTF8)
    Write-Output $output
    if ($Notify) {
        Add-Type -AssemblyName System.Windows.Forms
        [void][Windows.Forms.MessageBox]::Show("MP4 已生成：`r`n$output`r`n`r`nAVI 已保留。", 'GameHelper MP4')
    }
} catch {
    $message = $_.Exception.Message
    if ($partial -and [IO.File]::Exists($partial)) { [IO.File]::Delete($partial) }
    [IO.File]::WriteAllText($logPath, $message, [Text.Encoding]::UTF8)
    if ($Notify) {
        Add-Type -AssemblyName System.Windows.Forms
        [void][Windows.Forms.MessageBox]::Show("MP4 转换失败，AVI 已保留。`r`n$message`r`n日志：$logPath", 'GameHelper MP4')
    }
    Write-Error -Message $message -ErrorAction Continue
    exit 1
}
