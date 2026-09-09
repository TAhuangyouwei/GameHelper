try(DestroyDialog ModelStandardRollout) catch()

struct ModelStandardConfig
(
    RenderSize = [1080, 1080],
    BgColor = color 97 97 97,
    AmbientColor = color 255 255 255,
    ExcludedTextureSuffixes = #("_h.dds", "_s.dds", "_g.dds"),
    LayoutType = #layout_1,
    DefaultView = #view_front,
    MaterialSlots = 24,
    CreateBackup = true,
    BackupSuffix = ".modelstandard.bak",
    LogFileName = "模型规范整理_处理日志.txt",
    SaveVersionOffset = 3,
    ArtRenderTimeSeconds = 300
)

struct FileProcessResult
(
    filePath = "",
    success = false,
    errorMessage = "",
    warnings = #(),
    backupPath = "",
    renderPath = "",
    texturePath = "",
    deletedCount = 0
)

struct FileProcessor
(
    config = ModelStandardConfig(),
    results = #(),
    logStream = undefined,
    logPath = "",
    totalFileCount = 0,
    cleanedBackupCount = 0,
    cancelled = false,
    fatalError = "",
    progressControl = undefined,
    progressLabel = undefined,
    currentFileLabel = undefined,

    fn JoinPath dirPath fileName =
    (
        if dirPath.count > 0 and (dirPath[dirPath.count] == "\\" or dirPath[dirPath.count] == "/") then
            dirPath + fileName
        else
            dirPath + "\\" + fileName
    ),

    fn WriteLog message =
    (
        format "%\n" message
        if logStream != undefined do
        (
            format "%\n" message to:logStream
            flush logStream
        )
    ),

    fn OpenLog dirPath =
    (
        logPath = JoinPath dirPath config.LogFileName
        logStream = createFile logPath
        if logStream == undefined do throw ("无法创建日志文件: " + logPath)
        WriteLog ("模型规范整理开始: " + (localTime as string))
        WriteLog ("处理目录: " + dirPath)
        WriteLog ("MAX 备份后缀: " + config.BackupSuffix)
        WriteLog ""
    ),

    fn CloseLog =
    (
        if logStream != undefined do
        (
            close logStream
            logStream = undefined
        )
    ),

    fn UpdateRolloutProgress completedCount totalCount statusText =
    (
        local percent = 0
        if totalCount > 0 do
            percent = (100.0 * completedCount / totalCount) as integer

        if progressControl != undefined do progressControl.value = percent
        if progressLabel != undefined do
            progressLabel.text = ("进度: " + (percent as string) + "%  (" + (completedCount as string) + "/" + (totalCount as string) + ")")
        if currentFileLabel != undefined do currentFileLabel.text = statusText

        try((dotNetClass "System.Windows.Forms.Application").DoEvents()) catch()
    ),

    fn AddWarning result message =
    (
        append result.warnings message
    ),

    fn AddWarningsFromList result prefix values =
    (
        if values != undefined do
        (
            for value in values do AddWarning result (prefix + (value as string))
        )
    ),

    fn IsValidTexturePath path =
    (
        for suffix in config.ExcludedTextureSuffixes do
        (
            if matchPattern path pattern:("*" + suffix) do return false
        )
        true
    ),

    fn CreateSourceBackup filePath result =
    (
        if not config.CreateBackup do return true

        local backupPath = filePath + config.BackupSuffix

        if doesFileExist backupPath then
        (
            result.backupPath = backupPath
            true
        )
        else
        (
            if copyFile filePath backupPath then
            (
                result.backupPath = backupPath
                true
            )
            else
                throw ("创建备份失败: " + backupPath)
        )
    ),

    fn DeleteNoSkinObjects =
    (
        max unfreeze all
        local deleteCandidates = for obj in geometry where
        (
            obj.modifiers[#skin] == undefined and
            (classof obj == Box or classof obj == Editable_mesh or classof obj == Plane)
        ) collect obj

        local deletedCount = deleteCandidates.count
        if deletedCount > 0 do delete deleteCandidates
        clearSelection()
        deletedCount
    ),

    fn SetupViewport result =
    (
        viewport.setLayout config.LayoutType
        viewport.setGridVisibility #all off
        hideByCategory.bones = on
        hideByCategory.helpers = on
        backgroundColor = config.BgColor
        ambientColor = config.AmbientColor

        if not actionMan.executeAction -844228238 "12" do
            AddWarning result "未能启用高质量视口模式"

        local defaultShadingSet = false
        try
        (
            local viewportSettings = NitrousGraphicsManager.GetActiveViewportSetting()
            if viewportSettings != undefined and isProperty viewportSettings #VisualStyleMode do
            (
                viewportSettings.VisualStyleMode = #Realistic
                defaultShadingSet = true
            )
        )
        catch()

        if not defaultShadingSet do
        (
            try
            (
                viewport.setRenderLevel #smoothhighlights
                defaultShadingSet = true
            )
            catch()
        )

        if not defaultShadingSet do AddWarning result "未能启用 Default Shading 显示模式"
    ),

    fn SetupMaterials dirPath =
    (
        local ddsFiles = getFiles (JoinPath dirPath "*.dds")
        local selectedTexture = undefined
        local mainMaterial = Standardmaterial()

        sort ddsFiles
        for filePath in ddsFiles do
        (
            if selectedTexture == undefined and IsValidTexturePath filePath do
                selectedTexture = filePath
        )

        if selectedTexture != undefined do
        (
            mainMaterial.diffuseMap = Bitmaptexture fileName:selectedTexture
            mainMaterial.opacityMap = Bitmaptexture fileName:selectedTexture
            mainMaterial.opacityMap.monoOutput = 1
        )

        for i = 1 to config.MaterialSlots do meditMaterials[i] = mainMaterial
        geometry.material = mainMaterial
        selectedTexture
    ),

    fn SetupRenderOutput =
    (
        if renderSceneDialog.isOpen() do renderSceneDialog.close()
        rendLockImageAspectRatio = false
        rendLockPixelAspectRatio = false
        renderWidth = config.RenderSize.x as integer
        renderHeight = config.RenderSize.y as integer
        renderPixelAspect = 1.0
    ),

    fn PrepareRenderView viewType zoomSelected result =
    (
        viewport.setType viewType
        sliderTime = animationRange.start

        if zoomSelected then
        (
            displaySafeFrames = true
            local renderNodes = for obj in geometry where not obj.isHidden collect obj

            if renderNodes.count > 0 then
            (
                select renderNodes
                max zoomext sel
                clearSelection()
            )
            else
            (
                AddWarning result "没有可用于 Zoom Extents Selected 的可见几何体"
                max tool zoomextents
            )
        )
        else
        (
            max tool zoomextents
        )
    ),

    fn RenderPreview filePath useArtRenderer result =
    (
        local renderedBitmap = undefined
        local missingFiles = undefined
        local missingUVW = undefined
        local outputPath = (getFilenamePath filePath) + (getFilenameFile filePath) + ".jpg"

        result.renderPath = outputPath

        if useArtRenderer then
        (
            local artRenderer = ART_Renderer()
            if isProperty artRenderer #enable_time do artRenderer.enable_time = true
            if isProperty artRenderer #time_in_seconds do artRenderer.time_in_seconds = config.ArtRenderTimeSeconds
            renderers.current = artRenderer
        )
        else
        (
            renderers.current = Default_Scanline_Renderer()
        )

        SetupRenderOutput()
        PrepareRenderView config.DefaultView true result

        try
        (
            renderedBitmap = render \
                outputFile:outputPath \
                vfb:off \
                outputSize:config.RenderSize \
                quiet:true \
                missingExtFilesAction:#logmsg \
                missingExtFilesList:&missingFiles \
                missingUVWAction:#logmsg \
                missingUVWList:&missingUVW

            if renderedBitmap == undefined do throw ("渲染没有返回图像: " + outputPath)
            close renderedBitmap
            renderedBitmap = undefined

            if not doesFileExist outputPath do throw ("渲染输出文件不存在: " + outputPath)
            AddWarningsFromList result "渲染时缺少外部文件: " missingFiles
            AddWarningsFromList result "渲染时缺少 UVW: " missingUVW
        )
        catch
        (
            if renderedBitmap != undefined do try(close renderedBitmap) catch()
            throw()
        )
    ),

    fn ProcessMaxFile filePath =
    (
        local result = FileProcessResult filePath:filePath warnings:#()
        local loadMissingFiles = undefined
        local loadMissingDLLs = undefined
        local loadMissingXRefs = undefined
        local mergeMissingFiles = undefined
        local mergeMissingDLLs = undefined
        local mergeMissingXRefs = undefined

        try
        (
            CreateSourceBackup filePath result

            local loaded = loadMaxFile filePath \
                quiet:true \
                allowPrompts:false \
                missingExtFilesAction:#logmsg \
                missingExtFilesList:&loadMissingFiles \
                missingDLLsAction:#logmsg \
                missingDLLsList:&loadMissingDLLs \
                missingXRefsAction:#logmsg \
                missingXRefsList:&loadMissingXRefs
            if not loaded do throw ("加载文件失败: " + filePath)

            local sourceRange = interval animationRange.start animationRange.end
            resetMaxFile #noPrompt

            local merged = mergeMAXFile filePath \
                #mergeDups \
                #useMergedMtlDups \
                #alwaysReparent \
                quiet:true \
                missingExtFilesAction:#logmsg \
                missingExtFilesList:&mergeMissingFiles \
                missingDLLsAction:#logmsg \
                missingDLLsList:&mergeMissingDLLs \
                missingXRefsAction:#logmsg \
                missingXRefsList:&mergeMissingXRefs
            if not merged do throw ("合并文件失败: " + filePath)

            AddWarningsFromList result "加载时缺少外部文件: " loadMissingFiles
            AddWarningsFromList result "加载时缺少插件: " loadMissingDLLs
            AddWarningsFromList result "加载时缺少 XRef: " loadMissingXRefs
            AddWarningsFromList result "合并时缺少外部文件: " mergeMissingFiles
            AddWarningsFromList result "合并时缺少插件: " mergeMissingDLLs
            AddWarningsFromList result "合并时缺少 XRef: " mergeMissingXRefs

            animationRange = sourceRange
            result.deletedCount = DeleteNoSkinObjects()
            SetupViewport result
            result.texturePath = SetupMaterials (getFilenamePath filePath)
            if result.texturePath == undefined do AddWarning result "同目录中没有找到可用的 DDS 主贴图"

            local objectName = getFilenameFile filePath
            local isAtStand = matchPattern objectName pattern:"*atstand*"
            local isStand = matchPattern objectName pattern:"*stand*"

            case of
            (
                (isAtStand): RenderPreview filePath true result
                (isStand): RenderPreview filePath false result
                default:
                (
                    SetupRenderOutput()
                    PrepareRenderView #view_left false result
                )
            )

            local targetVersion = (maxVersion())[8] - config.SaveVersionOffset
            local saved = saveMaxFile filePath saveAsVersion:targetVersion quiet:true
            if not saved do throw ("保存文件失败: " + filePath)

            result.success = true
            resetMaxFile #noPrompt
        )
        catch
        (
            result.errorMessage = getCurrentException() as string
            try(resetMaxFile #noPrompt) catch()
        )

        result
    ),

    fn WriteFileResult result =
    (
        if result.success then
        (
            WriteLog ("[成功] " + result.filePath)
            WriteLog ("  删除对象: " + (result.deletedCount as string))
            if result.texturePath != undefined do WriteLog ("  使用贴图: " + result.texturePath)
            if result.renderPath != "" do WriteLog ("  渲染输出: " + result.renderPath)
            if result.backupPath != "" do WriteLog ("  原文件备份: " + result.backupPath)
        )
        else
        (
            WriteLog ("[失败] " + result.filePath)
            WriteLog ("  原因: " + result.errorMessage)
            if result.backupPath != "" do WriteLog ("  原文件备份: " + result.backupPath)
        )

        for warning in result.warnings do WriteLog ("  [警告] " + warning)
        WriteLog ""
    ),

    fn CleanupSuccessfulBackups =
    (
        cleanedBackupCount = 0
        WriteLog "开始清理处理成功文件的备份..."

        for result in results where
        (
            result.success and
            result.backupPath != ""
        ) do
        (
            if doesFileExist result.backupPath do
            (
                if deleteFile result.backupPath then
                (
                    cleanedBackupCount += 1
                    WriteLog ("[已清理备份] " + result.backupPath)
                )
                else
                (
                    AddWarning result ("处理成功，但无法删除备份: " + result.backupPath)
                    WriteLog ("[备份清理失败] " + result.backupPath)
                )
            )
        )

        WriteLog ("已清理备份: " + (cleanedBackupCount as string))
        WriteLog ""
    ),

    fn PrintFailedFilePaths =
    (
        local failedResults = for result in results where not result.success collect result

        format "\n============================================================\n"
        format "失败文件路径汇总（共 % 个）\n" failedResults.count
        format "============================================================\n"

        if failedResults.count == 0 then
        (
            format "无失败文件。\n"
        )
        else
        (
            for i = 1 to failedResults.count do
                format "%、%\n" i failedResults[i].filePath
        )

        format "============================================================\n\n"
    ),

    fn GetSummaryText =
    (
        local successCount = 0
        local warningFileCount = 0

        for result in results do
        (
            if result.success do successCount += 1
            if result.warnings.count > 0 do warningFileCount += 1
        )

        local failedCount = results.count - successCount
        local remainingCount = totalFileCount - results.count
        local summary = "批量处理结束\n"
        summary += "扫描到文件: " + (totalFileCount as string) + "\n"
        summary += "成功: " + (successCount as string) + "\n"
        summary += "失败: " + (failedCount as string) + "\n"
        summary += "含警告: " + (warningFileCount as string) + "\n"
        if not cancelled and fatalError == "" do
            summary += "已清理成功文件备份: " + (cleanedBackupCount as string) + "\n"
        if remainingCount > 0 do summary += "未处理: " + (remainingCount as string) + "\n"
        if cancelled do summary += "状态: 用户已取消\n"
        if fatalError != "" do summary += "批处理错误: " + fatalError + "\n"
        if cancelled or fatalError != "" do summary += "备份清理: 未执行\n"
        summary += "日志: " + logPath
        summary
    ),

    fn CollectMaxFiles dirPath =
    (
        local maxFiles = getFiles (JoinPath dirPath "*.max")
        local subDirs = getDirectories (JoinPath dirPath "*")

        for subDir in subDirs do join maxFiles (CollectMaxFiles subDir)
        maxFiles
    ),

    fn ProcessDirectory dirPath =
    (
        results = #()
        totalFileCount = 0
        cleanedBackupCount = 0
        cancelled = false
        fatalError = ""
        local progressOpened = false

        try
        (
            OpenLog dirPath
            local maxFiles = CollectMaxFiles dirPath
            sort maxFiles
            totalFileCount = maxFiles.count
            WriteLog ("扫描到 MAX 文件: " + (totalFileCount as string))
            WriteLog ""
            UpdateRolloutProgress 0 totalFileCount "准备开始..."

            if totalFileCount > 0 do
            (
                progressStart "模型规范整理"
                progressOpened = true

                for i = 1 to totalFileCount while not cancelled do
                (
                    local percent = (100.0 * (i - 1) / totalFileCount) as integer
                    if not (progressUpdate percent) then
                    (
                        cancelled = true
                    )
                    else
                    (
                        UpdateRolloutProgress (i - 1) totalFileCount ("正在处理: " + (filenameFromPath maxFiles[i]))
                        WriteLog ("[" + (i as string) + "/" + (totalFileCount as string) + "] 开始处理: " + maxFiles[i])
                        local result = ProcessMaxFile maxFiles[i]
                        append results result
                        WriteFileResult result
                        UpdateRolloutProgress i totalFileCount ("已完成: " + (filenameFromPath maxFiles[i]))
                    )
                )

                if not cancelled do progressUpdate 100
            )
        )
        catch
        (
            fatalError = getCurrentException() as string
            WriteLog ("[批处理错误] " + fatalError)
            UpdateRolloutProgress results.count totalFileCount "批处理发生错误"
        )

        if progressOpened do try(progressEnd()) catch()
        if not cancelled and fatalError == "" do
        (
            UpdateRolloutProgress totalFileCount totalFileCount "正在清理成功文件的备份..."
            CleanupSuccessfulBackups()
            UpdateRolloutProgress totalFileCount totalFileCount "处理完成"
        )
        if cancelled do UpdateRolloutProgress results.count totalFileCount "用户已取消"
        WriteLog ""
        WriteLog (GetSummaryText())
        CloseLog()
        fatalError == ""
    )
)

rollout ModelStandardRollout "模型规范整理 v2.5"
(
    edittext edtPath "项目路径:" fieldWidth:200 height:30 labelOnTop:true across:2
    button btnBrowse "浏览..." width:60 height:30 offset:[40,18]
    button btnProcess "开始处理" width:300 height:40
    label lblProgress "进度: 0%  (0/0)" width:300 align:#left
    progressbar pgbProgress "" value:0 width:300 height:16 color:(color 70 160 220)
    label lblCurrentFile "等待开始" width:300 align:#left

    on btnBrowse pressed do
    (
        local path = getSavePath()
        if path != undefined do edtPath.text = path
    )

    on btnProcess pressed do
    (
        local dirPath = edtPath.text
        if not doesDirectoryExist dirPath then
        (
            messageBox "请选择一个有效的项目目录。" title:"模型规范整理"
        )
        else if checkForSave() then
        (
            local originalScenePath = undefined
            if maxFileName != "" do originalScenePath = maxFilePath + maxFileName

            btnProcess.enabled = false
            btnBrowse.enabled = false
            edtPath.enabled = false
            pgbProgress.value = 0
            lblProgress.text = "进度: 0%  (0/0)"
            lblCurrentFile.text = "正在扫描文件..."

            local processor = FileProcessor \
                progressControl:pgbProgress \
                progressLabel:lblProgress \
                currentFileLabel:lblCurrentFile
            local uiError = ""

            try
            (
                with redraw off
                (
                    with quiet on
                    (
                        processor.ProcessDirectory dirPath
                    )
                )
            )
            catch
            (
                uiError = getCurrentException() as string
            )

            try
            (
                with quiet on
                (
                    if originalScenePath != undefined and doesFileExist originalScenePath then
                        loadMaxFile originalScenePath quiet:true allowPrompts:false
                    else
                        resetMaxFile #noPrompt
                )
            )
            catch()

            btnProcess.enabled = true
            btnBrowse.enabled = true
            edtPath.enabled = true
            redrawViews()
            processor.PrintFailedFilePaths()

            if uiError != "" then
                messageBox ("批处理意外终止:\n" + uiError + "\n\n已完成文件请查看日志。") title:"模型规范整理"
            else
                messageBox (processor.GetSummaryText()) title:"模型规范整理"
        )
    )
)

createDialog ModelStandardRollout 320 175
