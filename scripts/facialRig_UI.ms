try (DestroyDialog FacialRigDemo )catch ()
gc()


currentFolder = getFilenamePath (getThisScriptFilename())
rulesScript = pathConfig.appendPath currentFolder "/createFacialControl_UI_Layout.ms"  --打开创建UI的脚本
fileIn rulesScript	

	
currentFolder = getFilenamePath (getThisScriptFilename())
rulesScript = pathConfig.appendPath currentFolder "/faceBones.ms"  --打开创建骨骼的脚本
fileIn rulesScript	

	
currentFolder = getFilenamePath (getThisScriptFilename())
rulesScript = pathConfig.appendPath currentFolder "/createFacialExpressionUnit.ms"  --打开创建控制器的脚本
fileIn rulesScript	
	
	
	

rollout FacialRigDemo "表情绑定"
(
	local listNum = 1
	local ctrlName,targetObj,reactToTarget
	group "UI控制器"
	(
		button fangCtrl "方形" across:3
		button allCtrl "全"
		button tiaoCtrl "条形"
		
		on fangCtrl pressed do 
		(
			facialControlSquare()
		)
		
		on allCtrl pressed do 
		(
			with redraw off
			(
				undo off facialControl()
			)
		)
		on tiaoCtrl pressed do 
		(
			facialControlBar()
		)
	)
	
	group "表达式控制器"
	(
		button btCreate "创建控制器" height:21 width:60 toolTip:"对选择的表情骨骼创建控制器,或者不选择骨骼在原点创建一个控制器组合" across:2
		button btResetBone "骨骼还原"
		button btFaceBone "创建骨骼" across:2  tooltip:"在默认位置创建一套面部骨骼"
		button btBonInfor "提取信息" tooltip:"把当前选择的bone骨骼的名称和坐标提取到temp文档中，右键可以打开文档所在路径"
		
		
		on btCreate pressed do 
		(
			with redraw off
			(
				undo off 
				(
					createFacialExpressionUnit()					
				)
			)
		)
		
		
		on btResetBone pressed do 
		(
			resetBoneControllers()
		)
		on btFaceBone pressed do 
		(
			createFaceBonesFromFile()
		)
		on btBonInfor pressed do 
		(
			getBoneInformation()
		)
		on btBonInfor rightclick do 
		(
			tempFloder = getdir #defaults
			ShellLaunch tempFloder ""
		)
	)
	
	group "修改骨骼属性"
	(
		spinner spBonewidth "粗细:"  range:[0,999999,0.2] fieldwidth:50 across:2
		spinner spBoneLength "长短:"  range:[0,999999,2] fieldwidth:50
		
		on spBonewidth changed arg  do 
		(
			if selection.count ==0 then 
			(
				for obj in objects where classof obj == BoneGeometry and findString obj.name "BN_" != undefined do obj.width = obj.height = spBonewidth.value
 			)
			else 
				for obj in selection where classof obj == BoneGeometry do obj.width = obj.height = spBonewidth.value
			
			
		)
		
		on spBoneLength changed arg  do 
		(
			if selection.count ==0 then 
			(
				for obj in objects where classof obj == BoneGeometry and findString obj.name "BN_" != undefined do obj.length = spBoneLength.value
 			)
			else 
				for obj in selection where classof obj == BoneGeometry do obj.length = spBoneLength.value
			
			
		)
		
		
	)
	
	
	group "场景清理"
	(
		button resetScene "R" across:4 tooltip:"重置场景，不保存"
		button holdScene "H" tooltip:"暂存场景"
		button fetchScene "F"  tooltip:"取回暂存场景"
		button saveScene "S"  tooltip:"保存场景"
		
		on resetScene pressed do resetMaxFile #noPrompt
		on holdScene pressed do holdMaxFile()
		on fetchScene pressed do fetchMaxFile quiet:true
		on saveScene pressed do
		(
			filename = maxFilePath + maxFileName
			saveMaxFile filename saveAsVersion:2019
		)						
		
	)
	
	group "切换虚拟体层级"
	(
		dropdownlist layerName "层级列表" items:#("Position_XYZ","eyebrow_X","eyebrow_Y","zuoZuijiao_X","zuoZuijiao_Y","youZuijiao_X","youZuijiao_Y","upZuichun_X","upZuichun_Y","downZuichun_X","downZuichun_Y")	selection:1 height:12
		
		on layerName selected controllerLayerNum do 
		(
			SwitchLayer controllerLayerNum
			listNum = layerName.selection
			ctrlName = layerName.selected			
		)
		

		
		pickbutton pk_target "拾取控制器" tooltip:"拾取作为反应管理器目标的控制器物体"  width:80 across:2
		
		on pk_target picked obj do
		(
			if obj != undefined do
			(
				pk_target.text = obj.name
				targetObj = obj
			)
		)
		
		button btn_react "创建" tooltip:"创建反应管理器的联动关系" width:80
		on btn_react pressed do 
		(
			-- 确保 targetObj 和 obj 是有效的对象
			if targetObj != undefined do
			(
				
				for obj in selection do 
				(
					
					if isValidNode obj do
					(
						for i = 1 to 2 do 
						(
							for k = 1 to 3 do 
							(
								-- 确保索引 listNum 是有效的
								if listNum != undefined and listNum != 1 do
								(
									
									-- 现在尝试访问控制器
									local targetController = obj[3][i][listNum][k].controller
									
									local ReactionName = undefined 
									
									if classOf targetController != Float_Reactor do
									(
										targetController = float_Reactor ()
										obj[3][i][listNum][k].controller = targetController
										
										if findString ctrlName "_X" != undefined then
										(
											reactToTarget = targetObj[3][1][2][1][1].controller
											ReactionName = ctrlName
										)											
										else if findString ctrlName "_Y" != undefined then 
										(
											reactToTarget = targetObj[3][1][2][2][1].controller
											ReactionName = ctrlName
										)											
											
										if reactToTarget != undefined do
										(
											reactTo targetController reactToTarget
											
											if ReactionName != undefined then setReactionName targetController 1 ReactionName
											
											targetController.delete 1
										)
									
									)
								)
							)
						)
						
						
						
						
					)
				)
			)
		)
	)
	group "规范骨骼名称"
	(
		dropdownlist boneNamelist "层级列表" items:#("左眉毛","左眼睛","左颧骨","左上嘴唇","上嘴唇","右上嘴唇","左下嘴唇","下嘴唇","右下嘴唇","下巴","鼻子","右眉毛","右眼睛","右颧骨","头")	selection:1 height:16
		
		button btRenameBone "重命名" across:2 toolTip:"选择面部骨骼进行重命名"
		
		button btPoseSaver "POSE"
		
		on btRenameBone pressed do 
		(
			renameBoneGeometry boneNamelist.selection
		)
		
		on reNameNubBone pressed do 
		(
			reNameNub()
		)
		

		on btPoseSaver pressed do 
		(
			
			currentFolder = getFilenamePath (getThisScriptFilename())
			rulesScript = pathConfig.appendPath currentFolder "/SalPoseManager.ms"  --规范检查
			fileIn rulesScript
			if SalPoseManager !=undefined then
				SalPoseManager.initiate()
			else
				messageBox "Can't find Sal Pose Manager Script" title:"Script Not Found"
			
		)
		
	)
	label authorName "作者：HYW" 
)
	
CreateDialog FacialRigDemo 230  420