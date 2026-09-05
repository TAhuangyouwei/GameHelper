try (destroydialog rootCheck) catch ()
rollout rootCheck "root检查"
(
	edittext etPath "Max文件路径:" fieldWidth:150 height:20 across:2 
	button btclear1 "清理" align:#right
	
	on btclear1 pressed do
	(
		etPath.text =""
	)

	button btBentchExportPJ "检查" 
	on btBentchExportPJ pressed do
	(
		openPath = etPath.text + "\\" + "*.max"
		openPath = trimleft openPath
		openPath = trimRight openPath
		files = getFiles openPath recurse:true 
		errFile = #()
		for i = 1 to files.count do 
		(	
			temp = getFilenameFile files[i]
			if ( findString temp "_ani" != undefined )then 
			(
				cc = loadMAXFile files[i] quiet:true 
				if cc then 
				(
					
					rootObj = (for obj in objects where obj.children != undefined and  obj.parent == undefined and obj.name == "root" collect obj )
					if rootObj.count == 0 then 
					(
						
						append errFile files[i] 
						
					)
					
				)
			)
		)
		clearListener()
		
		if errFile.count != 0 then 
			print errFile
		else
			print "很完美，没有找到有问题的root"
	)

	
	label author "author:HYW"
)
createdialog rootCheck 300 75
