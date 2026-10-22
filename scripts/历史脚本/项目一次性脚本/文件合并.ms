fliesPath =	@"D:\UNITY版本美术资源\模型\成人秀\秀\秀_风格化女脸"
maxopenpath = fliesPath + "\*.max"
maxfiles = getFiles maxopenpath recurse:true

mergeFile = @"D:\UNITY版本美术资源\模型\成人秀\秀\秀_风格化男脸\Untitled.max"
if maxfiles.count > 0 then 
(
	for file in maxfiles do 
	(
			if findString file "_skin" != undefined  then 
			(
				loadMaxFile file useFileUnits:true quiet:true
				
				if $B_Zhang == undefined then 
				(
					mergeMAXFile mergeFile #mergeDups #autoRenameDups useFileUnits:true quiet:true --merge all objects, allowing duplicates to be renamed
					$B_Zhang.parent =  $'Bip001 R Hand'
					$B_Chui.parent =  $'Bip001 R Hand'
					$B_Gong.parent =  $'Bip001 L Hand'
					saveMaxFile file quiet:true saveAsVersion:2021
				)
				

					
				
			)
		
	)
)
else (
	messageBox "未找到文件。请检查路径。"
)
	