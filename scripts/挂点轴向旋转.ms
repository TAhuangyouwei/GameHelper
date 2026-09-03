fliesPath =	@"D:\UNITY版本美术资源\模型\成人秀\秀\秀_风格化男脸\新骨骼"
maxopenpath = fliesPath + "\*.max"
maxfiles = getFiles maxopenpath recurse:true
if maxfiles.count > 0 then 
(
	for file in maxfiles do 
	(	
		loadMaxFile file useFileUnits:true quiet:true
		tempPos = $hp_head.pos
		$hp_head[3][2].controller =  Euler_XYZ ()		
		$hp_head.rotation = quat 0.707107 0 0 0.707107
		$hp_head.pos = tempPos
		saveMaxFile file quiet:true saveAsVersion:2021
	)
)
else (
	messageBox "未找到文件。请检查路径。"
)
	