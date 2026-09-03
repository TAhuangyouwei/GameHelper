fn saveBipedAnimation bipRoot:undefined  filePath:"" startFrame:animationRange.start endFrame:animationRange.end = 
(
    try 
	(
        -- 自动获取Biped根骨骼（如果没有传入）
        if bipRoot == undefined then  
		(
			if classof $bip001 == Biped_Object then 
				bipRoot = $bip001
            else 
			(
				bipRoot = (for obj in objects where classof obj == Biped_Object collect obj )[1]
			)
        )
		
        
        -- 处理默认保存路径
        if filePath == "" do 
		(
			fileName = getFilenameFile maxFileName
            filePath = (getdir #animations) + "\\temp\\"+ fileName+".bip"
			biped.saveBipFile bipRoot.transform.controller filePath
        )
        

    )
    catch
	(

	)
)


fn createTimeRangeTxtFile = 
(
    local txtFile = pathConfig.appendPath (getdir #animations) "temp\\timeRange.txt"
    local parentDir = getFilenamePath txtFile
	if not doesFileExist parentDir do (
		makeDir parentDir all:true
	)
	
   if not doesFileExist txtFile then 
	(
		-- 创建文件并获取句柄
		local timeRangeFile = createFile txtFile
		local fileName = getFilenameFile maxFileName
		
		-- 写入文件内容
		format "% % %\n" fileName animationRange.start.frame animationRange.end.frame to:timeRangeFile  -- 修正变量名

		
		-- 关闭文件
		close timeRangeFile
		
		format "文件已创建：%\n" txtFile
	)
	else
	(
		format "文件已存在：%\n" txtFile
	)
)


try(DestroyDialog batchSaveAnim ) catch ()
rollout batchSaveAnim "批量保存动画"
(
	edittext etfiles "动画文件路径:"
	edittext etbips "bip 文件路径 :"
	edittext etones "bone文件路径:"
	button btSaveBip "批量保存Bip" width:280 height:25
	button btloadBip "批量加载Bip" width:280 height:25
	
	button btSaveBone "批量保存Bone" width:280 height:25
	button btloadXaf "批量加载Xaf" width:280 height:25
	
	button btSaveAll "批量保存Bip和Bone" width:280 height:25	
	button btloadAll "批量加载Bip和Bone" width:280 height:25
	
	on btSaveBip pressed do
	(
		files = getFiles (etfiles.text + "\\*.max") recurse:true 
		for file in files do 
		(
			loadMaxFile file  quiet:true  allowPrompts:true 
			saveBipedAnimation() 
			createTimeRangeTxtFile()
		)
	)
	
	
)
CreateDialog batchSaveAnim 300 300