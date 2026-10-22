try(destroyDialog ::myRollout)catch()
rollout myRollout "Text Rearranger" width:300 height:200
(
    button btnChooseInput "Choose Input File" pos:[10,10] width:280 height:30
    label lblInputFile "Input File: Not selected" pos:[10,50] width:280 height:20
    button btnChooseOutput "Choose Output File" pos:[10,80] width:280 height:30
    label lblOutputFile "Output File: Not selected" pos:[10,120] width:280 height:20
    button btnProcess "Process Text" pos:[10,160] width:280 height:30  tooltip:"左键max2unity，右键unity2max"

    -- 文件选择逻辑
    fn chooseFile isForInput =
    (
        local fileDialog = dotNetObject "System.Windows.Forms.OpenFileDialog"
        fileDialog.Filter = "Text files (*.txt)|*.txt"
        local dialogResult = fileDialog.ShowDialog()

        if dialogResult == (dotNetClass "System.Windows.Forms.DialogResult").OK then
        (
            if isForInput then
                lblInputFile.text = "Input File: " + fileDialog.FileName
            else
                lblOutputFile.text = "Output File: " + fileDialog.FileName
        )
    )

    on btnChooseInput pressed do chooseFile true
    on btnChooseOutput pressed do chooseFile false

    -- 在这里添加其余的函数定义
	
	
	fn rearrangeTextBack text =
	(
		result = ""
		lines = filterString text "\n"
		for line in lines do
		(
			parts = filterString line " " -- 使用空格分隔每行
			if parts.count >= 3 then
			(
				newLine = (parts[2] + "|" + parts[3] + "|" + parts[1] + "|false")
				result += newLine + "\n"
			)
		)
		result
	)

	fn rearrangeText text =
	(
		result = ""
		lines = filterString text "\n"
		for line in lines do
		(
			parts = filterString line "|"
			if parts.count >= 3 then
			(
				newLine = (parts[3] + " " + parts[1] + " " + parts[2])
				result += newLine + "\n"
			)
		)
		result
	)

	fn readFromFile filename =
	(
		if doesFileExist filename then
		(
			fileStream = openFile filename
			content = ""
			while not eof fileStream do
			(
				line = readline fileStream
				content += line + "\n"
			)
			close fileStream
			content
		)
		else
		(
			"File not found"
		)
	)

	fn writeToFile filename content =
	(
		fileStream = createFile filename
		if fileStream != undefined then
		(
			format "%" content to:fileStream
			close fileStream
			true -- 返回 true 表示写入成功
		)
		else
		(
			false -- 返回 false 表示写入失败
		)
	)

	

	fn processFile isUnity2Max =
	(
		local inputFile = if lblInputFile.text != "Input File: Not selected" then substring lblInputFile.text 13 -1 else ""
		local outputFile = if lblOutputFile.text != "Output File: Not selected" then substring lblOutputFile.text 14 -1 else ""

		if (inputFile != "" and outputFile != "") then
		(
			local fileContent = readFromFile inputFile
			local processedContent

			if isUnity2Max then
				processedContent = rearrangeTextBack fileContent
			else
				processedContent = rearrangeText fileContent

			writeToFile outputFile processedContent

			-- 反馈操作结果
			print "Text successfully processed and written to file."
		)
		else
		(
			-- 如果输入或输出文件没有选择，显示错误信息
			print "Please select both input and output files."
		)
	)


    on btnProcess pressed do processFile true -- 左键点击
    on btnProcess rightclick do processFile false -- 右键点击
)

createDialog myRollout
