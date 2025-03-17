try (destroydialog animExport) catch ()
rollout animExport "动画导出"
(
	edittext etPath "Max文件路径:" fieldWidth:150 height:20 across:2 
	button btclear1 "清理" align:#right
	edittext et_exportPath "xaf 文件路径:" fieldWidth:150 height:20 across:2 
	button btclear2 "清理" align:#right
	
	on btclear1 pressed do
	(
		etPath.text =""
	)
	on btclear2 pressed do
	(
		et_exportPath.text  = ""
	)


	
	button btexportall "导出所有"
	on btexportall pressed do
	(
		openPath = etPath.text + "\\" + "*.max"
		openPath = trimleft openPath
		openPath = trimRight openPath
		files = getFiles openPath
		
		for i = 1 to files.count do 
		(	
			loadMAXFile files[i] quiet:true 
			LoadSaveAnimation.setAnimFileDirectory "C:\Users\pc\Documents\3ds Max 2021\sceneassets\animations"
			bonesObj = for obj in objects where (classof obj != Biped_Object and obj.modifiers[#skin] == undefined and findString obj.name "bip" == undefined ) collect obj 
			if bonesObj.count != 0 then
				(	
					fileName = getFilenameFile(maxFileName) + ".xaf"					
					nodes = bonesObj
					userAttributes = ""
					userValues = ""
					
					--保存动画
					LoadSaveAnimation.saveAnimation  fileName nodes userAttributes userValues animatedTracks:on includeConstraints:on keyableTracks:off saveSegment:on segInterval:animationRange  segKeyPerFrame:off
				)
			else
				(
					messagebox "当前文件没有需要保存动画的物体"	
				)
		)
	)
	
	button btmergeall "一键合并"
	on btmergeall pressed do 
	(
		xafPath = "C:\Users\pc\Documents\3ds Max 2021\sceneassets\animations" +"\\*.xaf" 
		xafFiles = getFiles xafPath
		
		timeArray = #()
		endTime = 0f
		for i = 1 to xafFiles.count do 
		(
			fileName =xafFiles[i]
			nodes = for obj in objects where (classof obj != Biped_Object and obj.modifiers[#skin] == undefined and findString obj.name "bip" == undefined ) collect obj 		
			LoadSaveAnimation.loadAnimation fileName nodes relative:off insert:off insertTime:endTime stripLayers:off useMapFile:false  mapFileName:"Default"
			
			for obj in nodes do 
			(
				if obj.pos.controller.keys.count != 0 and obj.isanimated then 
					append timeArray (getKeyTime obj.pos.controller (obj.position.controller.keys.count))
			)
			endTime = amax timeArray + 10f			
			
			
		)

		
	)
	
	
	
	label author "author:HYW"
)
createdialog animExport 300 110