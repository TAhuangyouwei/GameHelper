/*
  鹰爷 FBX 批量导出工具

  功能：
  - 导出当前打开的单个 .max 为 FBX
  - 添加文件夹后扫描 .max，并可多选批量导出
  - 动画导出默认使用 3DMax 时间条 animationRange 的起止帧
  - 动画导出支持：
    1. 导出文件内除了模型以外的内容
    2. 记录当前选择为模板，后续文件按同名节点导出
  - 模型骨骼导出：导出模型和骨骼，不导动画
  - FBX 文件名按 .max 文件自身命名
  - 可首次弹出 FBX 设置窗口，后续批量导出沿用第一次设置
  - 自动记住上次导出保存文件夹
*/

try (destroyDialog BajieFbxBatchExporter) catch()

rollout BajieFbxBatchExporter "FBX 批量导出" width:760 height:620
(
    local folderRoots = #()
    local maxItems = #()
    local templateNodeNames = #()
    local stopRequested = false
    local outputRoot = @"C:\3dmax导出插件\fbx-export"
    local settingsPath = @"C:\3dmax导出插件\fbx-export-settings.ini"

    listbox lbFolders "待扫描文件夹" pos:[12,12] width:330 height:7
    button btnAddFolder "添加文件夹" pos:[352,28] width:90 height:28
    button btnRemoveFolder "移除选中" pos:[448,28] width:90 height:28
    button btnClearFolders "清空文件夹" pos:[544,28] width:90 height:28

    multiListBox mlbFiles "选择要导出的 .max 文件" pos:[12,172] width:720 height:10
    button btnSelectAll "全选文件" pos:[12,352] width:90 height:28
    button btnSelectNone "取消全选" pos:[110,352] width:90 height:28

    edittext edtOutput "输出目录" text:outputRoot pos:[12,394] width:560 height:22
    button btnOutput "选择" pos:[584,394] width:70 height:22
    dropdownlist ddlMode "导出模式" items:#("动画：导出除模型外全部内容", "动画：按照当前文件设置导出", "动画：按记录的选中节点导出", "模型骨骼：导出模型和骨骼，不导动画") selection:1 pos:[12,426] width:300 height:42
    button btnCaptureSelection "记录当前选择为模板" pos:[328,430] width:150 height:28
    label lblTemplate "模板：未记录" pos:[490,434] width:240 height:22
    checkbox chkPromptFirst "首次导出弹出 FBX 设置，并让后续文件沿用" checked:true pos:[12,462] width:360 height:22

    button btnExportCurrent "导出当前文件" pos:[12,500] width:130 height:36
    button btnExportBatch "批量导出选中文件" pos:[154,500] width:150 height:36
    button btnOpenOutput "打开输出目录" pos:[316,500] width:120 height:36
    button btnStop "停止导出" pos:[448,500] width:100 height:36 enabled:false
    progressbar pbProgress color:blue pos:[12,544] width:720 height:12
    label lblStatus "状态：添加文件夹后扫描，或直接导出当前打开文件。" pos:[12,566] width:720 height:22
    button btnAuthor "作者：孤鹰" pos:[620,590] width:112 height:24 toolTip:"点击添加 QQ：276636729"

    fn ensureDir dir =
    (
        if dir == undefined or dir == "" then return false
        if not (doesFileExist dir) do makeDir dir
        doesFileExist dir
    )

    fn loadOutputDir =
    (
        local dir = getINISetting settingsPath "export" "outputDir"
        if dir != undefined and dir != "" then edtOutput.text = dir
    )

    fn saveOutputDir =
    (
        if (ensureDir edtOutput.text) do setINISetting settingsPath "export" "outputDir" edtOutput.text
    )

    fn sanitizeName name =
    (
        local s = name as string
        for token in #("\\", "/", ":", "*", "?", "\"", "<", ">", "|", "\r", "\n", "\t") do
        (
            s = substituteString s token "_"
        )
        if s == "" then s = "未命名"
        s
    )

    fn pathLeaf dirPath =
    (
        local clean = trimRight (dirPath as string) "\\/"
        local parts = filterString clean "\\/"
        if parts.count == 0 then "未命名" else parts[parts.count]
    )

    fn refreshFolderList =
    (
        lbFolders.items = folderRoots
    )

    fn refreshFileList =
    (
        local labels = for item in maxItems collect item[3]
        mlbFiles.items = labels
        try (mlbFiles.selection = #{1..labels.count}) catch()
    )

    fn chooseFolders =
    (
        local dir = getSavePath caption:"选择要扫描的 .max 文件夹"
        if dir == undefined then #() else #(dir)
    )

    fn collectMaxFiles root =
    (
        local files = #()
        try (files = getFiles (root + "\\*.max") recurse:true) catch(files = #())
        if files.count == 0 do
        (
            try
            (
                local dotNetFiles = (dotNetClass "System.IO.Directory").GetFiles root "*.max" (dotNetClass "System.IO.SearchOption").AllDirectories
                for i = 0 to dotNetFiles.Length - 1 do append files (dotNetFiles.GetValue i)
            )
            catch()
        )
        files
    )

    fn relativeDir root filePath =
    (
        local dir = getFilenamePath filePath
        local rel = substituteString dir root ""
        trimLeft rel "\\/"
    )

    fn scanMaxFiles =
    (
        maxItems = #()
        for root in folderRoots do
        (
            local files = collectMaxFiles root
            local rootName = pathLeaf root
            for f in files do
            (
                local rel = relativeDir root f
                local label = rootName + "\\"
                if rel != "" do label += rel
                label += getFilenameFile f + ".max"
                append maxItems #(root, f, label)
            )
        )
        refreshFileList()
        lblStatus.text = "状态：扫描到 " + (maxItems.count as string) + " 个 .max 文件。"
    )

    fn selectedItems =
    (
        local result = #()
        local sel = mlbFiles.selection
        try (for i in sel do if i >= 1 and i <= maxItems.count do append result maxItems[i]) catch()
        result
    )

    fn captureSelectionTemplate quiet =
    (
        templateNodeNames = #()
        for n in selection do appendIfUnique templateNodeNames n.name
        lblTemplate.text = if templateNodeNames.count == 0 then "模板：未记录" else ("模板：" + (templateNodeNames.count as string) + " 个节点")
        if templateNodeNames.count == 0 and not quiet do messageBox "请先在当前文件中选择要导出的节点。" title:"鹰爷 FBX 批量导出"
        templateNodeNames.count > 0
    )

    fn outputNameForMax maxPath =
    (
        sanitizeName (getFilenameFile maxPath)
    )

    fn isSkeletonNode n =
    (
        local result = false
        try (if n.isBone do result = true) catch()
        try (if matchPattern n.name pattern:"Bip*" ignoreCase:true do result = true) catch()
        try (if matchPattern ((classOf n) as string) pattern:"*Bip*" ignoreCase:true do result = true) catch()
        try (if matchPattern ((classOf n.controller) as string) pattern:"*Bip*" ignoreCase:true do result = true) catch()
        result
    )

    fn isModelNode n =
    (
        local result = false
        try
        (
            result = (superClassOf n == GeometryClass) and (not isSkeletonNode n)
        )
        catch()
        result
    )

    fn collectAnimationNodesExceptModels =
    (
        for n in objects where ((not n.isHidden) and (not isModelNode n)) collect n
    )

    fn collectModelAndSkeletonNodes =
    (
        local result = #()
        for n in objects where ((not n.isHidden) and (isModelNode n or isSkeletonNode n)) do appendIfUnique result n
        result
    )

    fn collectTemplateNodes =
    (
        local result = #()
        for nodeName in templateNodeNames do
        (
            local n = getNodeByName nodeName exact:true
            if n != undefined and not n.isHidden do appendIfUnique result n
        )
        result
    )

    fn frameFromTime t =
    (
        ((t as integer) / ticksPerFrame) as integer
    )

    fn setFbxParam param value =
    (
        try (FBXExporterSetParam param value) catch()
    )

    fn configureFbxExporter exportAnimation resetSettings =
    (
        try (pluginManager.loadClass FBXEXP) catch()
        if resetSettings do
        (
            setFbxParam "ResetExport" true
            setFbxParam "ASCII" false
            setFbxParam "SmoothingGroups" true
            setFbxParam "TangentsandBinormals" true
            setFbxParam "Preserveinstances" true
            setFbxParam "SelectionSetExport" false
            setFbxParam "Cameras" true
            setFbxParam "Lights" true
            setFbxParam "Shapes" true
            setFbxParam "Constraints" true
        )
        setFbxParam "Animation" exportAnimation
        setFbxParam "BakeAnimation" exportAnimation
        setFbxParam "BakeFrameStart" (frameFromTime animationRange.start)
        setFbxParam "BakeFrameEnd" (frameFromTime animationRange.end)
        setFbxParam "BakeFrameStep" 1
        setFbxParam "Skins" true
        setFbxParam "Skin" true
    )

    fn nodesForCurrentMode =
    (
        case ddlMode.selection of
        (
            1: collectAnimationNodesExceptModels()
            2: collectTemplateNodes()
            3: collectTemplateNodes()
            4: collectModelAndSkeletonNodes()
            default: #()
        )
    )

    fn outputDirFor root maxPath =
    (
        local rootName = sanitizeName (pathLeaf root)
        local rel = relativeDir root maxPath
        local outDir = edtOutput.text + "\\" + rootName
        if rel != "" do outDir += "\\" + rel
        ensureDir outDir
        outDir
    )

    fn outputPathFor root maxPath =
    (
        local outDir = outputDirFor root maxPath
        local baseName = outputNameForMax maxPath
        outDir + "\\" + baseName + ".fbx"
    )

    fn outputPathForCurrentFile =
    (
        if maxFilePath == undefined or maxFilePath == "" or maxFileName == undefined or maxFileName == "" then
        (
            local outDir = edtOutput.text + "\\当前文件"
            ensureDir outDir
            outDir + "\\当前文件.fbx"
        )
        else
        (
            local currentMaxPath = maxFilePath + maxFileName
            local fileName = outputNameForMax currentMaxPath
            local outDir = edtOutput.text
            ensureDir outDir
            outDir + "\\" + fileName + ".fbx"
        )
    )

    fn exportSelectedNodesToFbx nodes fbxPath exportAnimation promptUser resetSettings =
    (
        if nodes.count == 0 then return false
        ensureDir (getFilenamePath fbxPath)
        local oldSelection = selection as array
        local ok = false
        try
        (
            configureFbxExporter exportAnimation resetSettings
            select nodes
            try (deleteFile fbxPath) catch()
            if promptUser then
            (
                local result = exportFile fbxPath selectedOnly:true using:FBXEXP
                ok = (result != false) and doesFileExist fbxPath
            )
            else
            (
                exportFile fbxPath #noPrompt selectedOnly:true using:FBXEXP
                ok = doesFileExist fbxPath
            )
        )
        catch
        (
            ok = false
        )
        try (select oldSelection) catch()
        ok
    )

    fn exportOpenedScene fbxPath promptUser resetSettings =
    (
        local exportAnimation = ddlMode.selection != 4
        local nodes = nodesForCurrentMode()
        if nodes.count == 0 then
        (
            messageBox "没有找到可导出的对象。请检查导出模式，或先记录当前选择为模板。" title:"鹰爷 FBX 批量导出"
            return false
        )

        lblStatus.text = "状态：导出 FBX " + fbxPath
        exportSelectedNodesToFbx nodes fbxPath exportAnimation promptUser resetSettings
    )

--     fn exportOneMax item promptUser resetSettings =
--     (
--         if stopRequested then return false
--         local root = item[1]
--         local maxPath = item[2]
--         local fbxPath = outputPathFor root maxPath

--         lblStatus.text = "状态：打开 " + maxPath
--         loadMaxFile maxPath quiet:true useFileUnits:true
--         try (windows.processPostedMessages()) catch()
--         if stopRequested then return false

--         exportOpenedScene fbxPath promptUser resetSettings
--     )
	


    fn setProcessingUI processing =
    (
        btnExportCurrent.enabled = not processing
        btnExportBatch.enabled = not processing
        btnStop.enabled = processing
    )

	
	-- 判断是否为 Biped 骨骼
	fn isBipedBone obj =
	(
		local id = undefined
		
		try
			id = biped.getIdLink obj
		catch
			id = undefined
		
		(id != undefined and id.x != -1)
	)


	-- 获取一个控制器及其子控制器的关键帧范围
	fn getControllerKeyRange ctrl =
	(
		if ctrl == undefined then return undefined

		local minTime = undefined
		local maxTime = undefined

		-- 当前控制器关键帧
		local keyCount = 0
		
		try
			keyCount = numKeys ctrl
		catch
			keyCount = 0

		if keyCount > 0 do
		(
			for i = 1 to keyCount do
			(
				local t = undefined
				
				try
					t = getKeyTime ctrl i
				catch
					t = undefined

				if t != undefined do
				(
					if minTime == undefined or t < minTime do minTime = t
					if maxTime == undefined or t > maxTime do maxTime = t
				)
			)
		)

		-- Position / Rotation / Scale 等子控制器
		local subCount = 0
		
		try
			subCount = ctrl.numSubs
		catch
			subCount = 0

		for i = 1 to subCount do
		(
			local subCtrl = undefined
			
			try
				subCtrl = (getSubAnim ctrl i).controller
			catch
				subCtrl = undefined

			if subCtrl != undefined do
			(
				local r = getControllerKeyRange subCtrl
				
				if r != undefined do
				(
					if minTime == undefined or r[1] < minTime do minTime = r[1]
					if maxTime == undefined or r[2] > maxTime do maxTime = r[2]
				)
			)
		)

		if minTime != undefined and maxTime != undefined then
			#(minTime, maxTime)
		else
			undefined
	)


	-- 获取场景所有 Bone + Biped 的真实关键帧范围
	fn getRealAnimRange =
	(
		local minTime = undefined
		local maxTime = undefined
		
		max select all 

		for obj in selection do
		(
			local isBone = false
			
			try
				isBone = isKindOf obj BoneGeometry
			catch
				isBone = false

			if isBone or isBipedBone obj do
			(
				local r = getControllerKeyRange obj.controller
				
				if r != undefined do
				(
					if minTime == undefined or r[1] < minTime do minTime = r[1]
					if maxTime == undefined or r[2] > maxTime do maxTime = r[2]
				)
			)
		)

		if minTime != undefined and maxTime != undefined then
			#(minTime, maxTime)
		else
			undefined
	)
	
	fn exportOneMax item promptUser resetSettings =
	(
		if stopRequested then return false

		local root = item[1]
		local maxPath = item[2]
		local fbxPath = outputPathFor root maxPath

		lblStatus.text = "状态：打开 " + maxPath

		-- 先打开 MAX
		loadMaxFile maxPath quiet:true useFileUnits:true

		try (windows.processPostedMessages()) catch()
			

		if stopRequested then return false


		-- ==============================
		-- 自动获取真实骨骼动作范围
		-- ==============================
		local r = getRealAnimRange()

		if r != undefined do
		(
			animationRange = interval r[1] r[2]

			format "当前文件：%\n" maxPath
			format "真实动作范围：% - %\n" r[1].frame r[2].frame
		)


		-- 再导出 FBX
		exportOpenedScene fbxPath promptUser resetSettings
	)
	
    on BajieFbxBatchExporter open do
    (
        loadOutputDir()
        pbProgress.value = 0
    )

    on btnAddFolder pressed do
    (
        local dirs = chooseFolders()
        if dirs.count > 0 do
        (
            for dir in dirs do appendIfUnique folderRoots dir
            refreshFolderList()
            scanMaxFiles()
            lblStatus.text = "状态：已添加文件夹并自动扫描，当前 .max 数量：" + (maxItems.count as string)
        )
    )

    on btnRemoveFolder pressed do
    (
        if lbFolders.selection > 0 do
        (
            deleteItem folderRoots lbFolders.selection
            refreshFolderList()
        )
    )

    on btnClearFolders pressed do
    (
        folderRoots = #()
        maxItems = #()
        refreshFolderList()
        refreshFileList()
        lblStatus.text = "状态：已清空文件夹。"
    )

    on btnSelectAll pressed do
    (
        try (mlbFiles.selection = #{1..maxItems.count}) catch()
    )

    on btnSelectNone pressed do
    (
        mlbFiles.selection = #{}
    )

    on btnOutput pressed do
    (
        local dir = getSavePath caption:"选择 FBX 输出目录" initialDir:edtOutput.text
        if dir != undefined do
        (
            edtOutput.text = dir
            saveOutputDir()
        )
    )

    on btnCaptureSelection pressed do
    (
        if captureSelectionTemplate false do
        (
            lblStatus.text = "状态：已记录当前选择，批量导出时会按同名节点导出。"
        )
    )

    on btnExportCurrent pressed do
    (
        if not (ensureDir edtOutput.text) then
        (
            messageBox "请先选择有效的输出目录。" title:"鹰爷 FBX 批量导出"
            return false
        )
        if ddlMode.selection == 2 do
        (
            if not (captureSelectionTemplate false) do return false
        )
        stopRequested = false
        setProcessingUI true
        pbProgress.value = 0
        local fbxPath = outputPathForCurrentFile()


        local oldRange = animationRange
        local ok = exportOpenedScene fbxPath chkPromptFirst.checked true
        try (animationRange = oldRange) catch()
        if ok do
        (
            saveOutputDir()
            pbProgress.value = 100
        )
        setProcessingUI false
        if ok then
        (
            lblStatus.text = "状态：当前文件导出完成 " + fbxPath
            messageBox ("导出完成：\n" + fbxPath) title:"鹰爷 FBX 批量导出"
        )
        else lblStatus.text = "状态：当前文件导出失败。"
    )

    on btnExportBatch pressed do
    (
        local items = selectedItems()
        if items.count == 0 then
        (
            messageBox "请先扫描并选择至少一个 .max 文件。" title:"鹰爷 FBX 批量导出"
            return false
        )
        if ddlMode.selection == 2 do
        (
            if not (captureSelectionTemplate false) do return false
            lblStatus.text = "状态：已按当前文件选择记录导出设置。"
        )
        if ddlMode.selection == 3 and templateNodeNames.count == 0 then
        (
            messageBox "当前模式需要先打开模板文件，选择要导出的节点，然后点击“记录当前选择为模板”。" title:"鹰爷 FBX 批量导出"
            return false
        )
        if not (ensureDir edtOutput.text) then
        (
            messageBox "请先选择有效的输出目录。" title:"鹰爷 FBX 批量导出"
            return false
        )

        stopRequested = false
        setProcessingUI true
        saveOutputDir()


        local oldRange = animationRange
        local total = 0
        local failed = 0
        local firstExport = true
        pbProgress.value = 0
        for item in items while not stopRequested do
        (
            try (windows.processPostedMessages()) catch()
            total += 1
            local ok = false
            local shouldPrompt = chkPromptFirst.checked and firstExport
            local shouldResetSettings = firstExport
            try (ok = exportOneMax item shouldPrompt shouldResetSettings) catch(ok = false)
            if ok do firstExport = false
            pbProgress.value = (100.0 * total / items.count)
            if not ok and not stopRequested do
            (
                failed += 1
                local keepGoing = queryBox ("导出失败：\n" + item[3] + "\n\n是否继续导出剩余文件？") title:"鹰爷 FBX 批量导出"
                if not keepGoing do stopRequested = true
            )
        )
        try (animationRange = oldRange) catch()
        setProcessingUI false

        lblStatus.text = "状态：批量导出完成。处理：" + (total as string) + "，失败：" + (failed as string)
        messageBox ("批量导出完成。\n处理：" + (total as string) + "\n失败：" + (failed as string)) title:"鹰爷 FBX 批量导出"
    )

    on btnOpenOutput pressed do
    (
        ensureDir edtOutput.text
        shellLaunch edtOutput.text ""
    )

    on btnStop pressed do
    (
        stopRequested = true
        lblStatus.text = "状态：正在停止，当前文件处理结束后退出。"
    )

    on btnAuthor pressed do
    (
        local qq = "276636729"
        try ((dotNetClass "System.Windows.Forms.Clipboard").SetText qq) catch()
        try
        (
            shellLaunch ("tencent://AddContact/?fromId=45&fromSubId=1&subcmd=all&uin=" + qq) ""
        )
        catch()
        messageBox ("作者：孤鹰\nQQ：" + qq + "\n\n已复制 QQ 号，并尝试打开 QQ 添加好友。") title:"作者信息"
    )
)

createDialog BajieFbxBatchExporter style:#(#style_titlebar, #style_sysmenu, #style_minimizebox, #style_maximizebox, #style_resizing)
