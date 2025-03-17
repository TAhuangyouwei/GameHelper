currentFolder = getFilenamePath (getThisScriptFilename())
HYW_Scripts_Library_rulesScript = pathConfig.appendPath currentFolder "HYW_Scripts_Library.ms" --函数库
fileIn HYW_Scripts_Library_rulesScript



try (DestroyDialog AniTools ) catch ()
rollout AniTools "动作工具"
(
		
		
	group "模型材质规范"
	(
		button btResetMat "重置材质编辑器"  height:21 width:93 tooltip:"重置材质球，切换为线扫描渲染器" across:2
		button bnResetModelMat "重置模型"  	height:21 width:93 tooltip:"只作用于Editable_Poly物体，左键轴点在原点，右键轴点在物体中心"
		on btResetMat pressed do --重置材质编辑器
		(
			MaterialUtilities.resetMeditMaterials()
		)
		on bnResetModelMat pressed do  --左键点击模型轴点在原点
		(
			ModelUtilities.ResetMaterialsOfModel()
		)
		
		on bnResetModelMat rightclick do 
		(
			ModelUtilities.ResetMaterialsOfModel applyCenterPivot:true
		)			--右键轴点居中模型
		
		button btClearMat "清除材质"  height:21 width:93  tooltip:"清除选择物体的材质或者所有物体的材质" across:2 --清理材质   
		
		on btClearMat pressed do 
		(
			MaterialUtilities.clearMaterials()
		)
		
		button btClearScene "清理场景"   height:21 width:93
		
		on btClearScene pressed do 
		(
			SceneUtilities.cleanScene()
		)
		
		checkbutton btcreateFloor "创建地面" height:21 width:93 across:2
		
		on btcreateFloor changed state do
		if state == on then  SceneUtilities.createFloor state else  SceneUtilities.createFloor state
		
		
		button bt_check "规范检查" height:21 width:93  tooltip:"检查贴图通道数量，场景单位，模型缩放、轴向" 
		
		on bt_check pressed do 
		( 

			SceneUtilities.mapChannelNum() --检查模型贴图通道数量
			SceneUtilities.unitCheck()		--检查场景单位
			SceneUtilities.scaleCheck()	--检查模型是否有缩放
			SceneUtilities.objAxis() 		--检查模型轴向是否Y轴向上
			SceneUtilities.getModifiers()  --检查多余的修改器
			SceneUtilities.nameCheck()
		)
		
		button btY_Up "Y轴向上" height:21 width:93 across:2
		on btY_Up pressed do 
		(
			-- 如果有选中的对象，则处理它们
			if selection.count != 0 do
			(
				ObjectProcessing.ProcessSelectedObjects()
			)
		)
		button btPointPath "点轨迹"  height:21 width:93
		on btPointPath pressed do 
		(
			ModelUtilities.pointPath()
		)

	)
		group "曲线编辑器旋转曲线一键暴力打平" --第一版需手动修复
	(
		radiobuttons btAxis labels:#("X", "Y", "Z")  columns:3 across:2
		edittext btValue "目标值:"  fieldWidth:60
		button btConfirm "确认" tooltip:"可能会引起旋转滑动" width:100
		on btConfirm pressed do 
		(
			saveMaxFile "C:\\Users\\pc\\Documents\\3ds Max 2021\\autoback\\maxhold.mx"            
			animate on 
			if selection.count != 0 then 
			(
				for obj in selection do 
				(
					local keys = obj.rotation.controller.keys
					local numKeys = keys.count
					for i = 1 to numKeys do 
					(
						local keyTime = getKeyTime obj.rotation.controller i
						
						local val = btValue.text as integer
						if keyTime >= animationRange.start and keyTime <= animationRange.end then
						(
							if btAxis.state == 1 then 
							(
								at time keyTime obj.rotation.controller[1].value = val
							)
							else if btAxis.state == 2 then 
							(
								at time keyTime obj.rotation.controller[2].value = val
							)
							else if btAxis.state == 3 then 
							(
								at time keyTime obj.rotation.controller[3].value = val
							)
						)
					)
				)
			)
		)

	)
	
	-------------------------------------------------------------------------------------------------------------------
	
		group "快捷工具"
	(
		button btprogram "代码视图" height:21 width:93 across: 2
		
		on btprogram pressed do 
		(
			ViewportUtilities.ProgrammeView()
		)
		button restore "动画视图"	height:21 width:93
		
		on restore pressed do 
		(
			ViewportUtilities.AnimView()
		)
		
		button btQuickLook "查看导出合并文件" height:21 width:200
		
		on btQuickLook pressed do 
		(
			currentFolder = getFilenamePath (getThisScriptFilename())
			rulesScript = pathConfig.appendPath currentFolder "/查看合并导出插件.ms"  --max文件查看器
			fileIn rulesScript
		)
		

		
		checkbutton cbt_click "剪影" height:21 width:93 across: 2
		
		on cbt_click changed state do
		(
			InterfaceUtilities.Silhouette_Viewer()
		)
		button btFBXtoBip "FBX转Bip" height:21 width:93 enabled:(RolloutUiUtilities.widgetState()) tooltip:"支持2021及以下版本"
		
		on btFBXtoBip pressed do 
		(
			currentFolder = getFilenamePath (getThisScriptFilename())
			rulesScript = pathConfig.appendPath currentFolder "/AutoFbxtoBip v1.4.mse"  --FBX转Bip
			fileIn rulesScript
1
		)
		button bt_TCB_Continuity  "TCB_Continuity" width:93 tooltip:"左键对选中的帧设置 为0，右键设置为25" across:2 width:93

		
		on bt_TCB_Continuity pressed do 
		(
			local bipedObjs = for obj in selection where classof obj == Biped_Object collect obj 
			AnimationUtilities.setTCBContinuityForBipedObjects bipedObjs 0  -- 设置为0
		)
		
		on bt_TCB_Continuity rightclick do 
		(
			local bipedObjs = for obj in selection where classof obj == Biped_Object collect obj 
			AnimationUtilities.setTCBContinuityForBipedObjects bipedObjs 25  -- 设置为25
		)
		
		button bt_Auto_TCB "AUTO TCB"  width:93 		
		on bt_Auto_TCB pressed do 
		(
			local tolerance = 0.01 -- 定义一个小的容忍度值
			
			-- 检查当前选择是否为空
			if selection.count == 0 do
			(
				local bipedParts = #("Bip001 L Hand", "Bip001 R Hand", "Bip001 R Foot", "Bip001 L Foot","Bip001 Spine1","Bip001")
				local objectsToSelect = for partName in bipedParts where (getNodeByName partName) != undefined collect (getNodeByName partName)
				select objectsToSelect
			)

			local bipedObjs = for obj in selection where classof obj == Biped_Object collect obj 
			
			for bipedObj in bipedObjs do 
			(
				AnimationUtilities.processSingleBipedObject bipedObj tolerance
			)
		)
		

		button bt_animRange "帧数表转换" width:200  tooltips:"unity和max格式转换"
		on bt_animRange pressed do 
		(
			currentFolder = getFilenamePath (getThisScriptFilename())
			rulesScript = pathConfig.appendPath currentFolder "/Process_text_file_for_animation_range.ms"  --FBX转Bip
			fileIn rulesScript
		)
		
		
		

		
		
		
		Dropdownlist BoneColorList "骨骼颜色列表" items:#("red-眼睛","green-裙子","blue-头发","white-其它","black-末端骨","orange-武器","yellow-披风","brown-袖子","gray-胸") selection:1 height:10 toolTip:"骨骼可选颜色列表"
		
		button BoneWireColor "确认" width:90
		
		on BoneWireColor pressed do 
		(
			case of 
			(
				(BoneColorList.selection == 1): $.wirecolor = red
				
				(BoneColorList.selection == 2): $.wirecolor = green
				
				(BoneColorList.selection == 3): $.wirecolor = blue
				
				(BoneColorList.selection == 4): $.wirecolor = white
				
				(BoneColorList.selection == 5): $.wirecolor = black
				
				(BoneColorList.selection == 6): $.wirecolor = orange
				
				(BoneColorList.selection == 7): $.wirecolor = yellow
				
				(BoneColorList.selection == 8): $.wirecolor = brown
				
				(BoneColorList.selection == 9): $.wirecolor = gray		
			)		
		)
		
		button btBoneDivider "骨骼切分工具"  height:21 width:93 across:2
		
		on btBoneDivider pressed do 
		(
			currentFolder = getFilenamePath (getThisScriptFilename())
			rulesScript = pathConfig.appendPath currentFolder "/bonedivider.ms"  --FBX转Bip
			fileIn rulesScript
		)

		button btCopyTrans "轨迹拷贝" height:21 width:93  
		
		on btCopyTrans pressed do 
		(
			currentFolder = getFilenamePath (getThisScriptFilename())
			rulesScript = pathConfig.appendPath currentFolder "/复制物体运动轨迹.ms"  --FBX转Bip
			fileIn rulesScript
		)
		
		
		button btRecoder "参考大师"  height:21 width:93 across:2
		
		on btRecoder pressed do 
		(
			currentFolder = getFilenamePath (getThisScriptFilename())
			rulesScript = pathConfig.appendPath currentFolder "/参考大师v1.06.mse"  --恢复蒙皮pose
			fileIn rulesScript
		)
		
		button btRepair "乱码修复Repair"  height:21 width:93 tooltip:"修复界面乱码问题"
		
		on btRepair pressed do
		(
			InterfaceUtilities.SetDefaultLanguageToChinese()
			currentFolder = getFilenamePath (getThisScriptFilename())
			rulesScript = pathConfig.appendPath currentFolder "/AnimTools.ms"  --FBX转Bip
			fileIn rulesScript
			
		)			
		
		

	)
	group "绑定工具"
	(
		button btObjLayer "调整层级" height:21 width:93 across: 2  tooltip:"把不同属性的物体放入不同的层级,左键普通分层，右键表情绑定分层"   across:2
		
		on btObjlayer pressed do 
		(
			LayerUtilities.AddObjectsToLayer()
		)
		
		button bt_clearNullLayer "清理空层"  height:21 width:93
		on bt_clearNullLayer pressed do 
		(
			LayerUtilities.DeleteEmptyLayers()
		)
		
		button bt_resetSkinPose "恢复蒙皮pose" height:21 width:93 across: 2  tooltip:"恢复到Tpose"
		
		on bt_resetSkinPose pressed do 
		(
			currentFolder = getFilenamePath (getThisScriptFilename())
			rulesScript = pathConfig.appendPath currentFolder "/重置蒙皮pose V1.1.mse"  --恢复蒙皮pose
			fileIn rulesScript
		)
		button bt_CombineSkin "蒙皮拆分合并"  height:21 width:93   tooltip:"合并时每次选择两个物体"
		
		on bt_CombineSkin pressed do 
		(
			currentFolder = getFilenamePath (getThisScriptFilename())
			rulesScript = pathConfig.appendPath currentFolder "/Rigging_CombineSkin.ms"  --蒙皮拆分合并
			fileIn rulesScript
		)
		
		button bt_facialRig  "表情绑定"  height:21 width:93  across:2  tooltip:"表情绑定工具"
		
		on bt_facialRig pressed do 
		(
			currentFolder = getFilenamePath (getThisScriptFilename())
			rulesScript = pathConfig.appendPath currentFolder "/facialRig_UI.ms"  --打开表情绑定界面
			fileIn rulesScript
		)
		
		button bt_bodylRig  "身体绑定"  height:21 width:93    tooltip:"身体绑定工具"
		
		on bt_bodylRig pressed do 
		(
			currentFolder = getFilenamePath (getThisScriptFilename())
			rulesScript = pathConfig.appendPath currentFolder "/自定义骨骼绑定.ms"  --打开身体绑定界面
			fileIn rulesScript
		)
		
		button reNameNub "命名末端" height:21 width:93 tooltip:"bone骨骼末端骨重命名"  across: 2
		on reNameNub pressed do 
		(
			BoneUtilities.RenameBoneNub()
		)
		
		button btAddSkinBones "拷贝骨骼列表" width:93
		on btAddSkinBones pressed do 
		(
			currentFolder = getFilenamePath (getThisScriptFilename())
			rulesScript = pathConfig.appendPath currentFolder "add_Skin_Bones.ms" --函数库
			fileIn rulesScript
		)
		
		button btSkinTools "蒙皮工具" width:93  across: 2
		
		on btSkinTools pressed do 
		(
			currentFolder = getFilenamePath (getThisScriptFilename())
			rulesScript = pathConfig.appendPath currentFolder "/skinTools.ms"  --权重蒙皮工具
			fileIn rulesScript
		)

		
		button btn_weightCopy "权重缝合" width:93
		on btn_weightCopy pressed do 
		(
			currentFolder = getFilenamePath (getThisScriptFilename())
			rulesScript = pathConfig.appendPath currentFolder "/copy_paste_skin_weight.ms"  --打开身体绑定界面
			fileIn rulesScript
		)
	)
	
	group "biped"
	(
		button btQuater "四元数" height:21 width:93 across:2 tooltip:"切换到Quater曲线模式"
		button btBipScale "Bip缩放"  height:21 width:93 tooltip:"只作用于选中的bip骨骼,左键开启，右键关闭"
		button btBoneScale "骨骼匹配"  height:21 width:93  across:2
		button btTwistCreate "扭曲骨骼" height:21 width:93 tooltip:"创建扭曲骨骼" 
		
		on btQuater pressed do 
		(
			BipedFunctions.BipedEulerQuarter()
		)
		on btBipScale pressed do BipedFunctions.BipedScaleOn() --左键开启缩放
		
		on btBipScale rightClick do BipedFunctions.BipedScaleOff()  --右键关闭缩放
		
		on btBoneScale pressed do 
		(
			BipedFunctions.boneScale()
		)
		on btTwistCreate  pressed do 
		(
			currentFolder = getFilenamePath (getThisScriptFilename())
			rulesScript = pathConfig.appendPath currentFolder "/TwistBones.ms"
			fileIn rulesScript
		)
		button btCheakName "重名检查" height:21 width:93 tooltip:"检查场景中的重名物体"  across:2
		
		button btRestoreBiped "还原外观"  height:21 width:93
		on btRestoreBiped pressed do 
		(
			currentFolder = getFilenamePath (getThisScriptFilename())
			rulesScript = pathConfig.appendPath currentFolder "/还原bip的外观和修改器.mse"  --biped外观还原
			fileIn rulesScript
		)
		
		on btCheakName pressed do 
		(
			currentFolder = getFilenamePath (getThisScriptFilename())
			rulesScript = pathConfig.appendPath currentFolder "/选择同名物体.ms"  --biped外观还原
			fileIn rulesScript
		)
	) 
	
	group "快捷工具"
	(
		button bt_wh "工具书" height:21 width:205  tooltip:"适用于max2008之前的版本"  --across: 2
		
		on bt_wh pressed do 
		(
			currentFolder = @"D:\3dsmax-2021.1-maxscript-help-chm\maxscript-2021.chm"
			ShellLaunch currentFolder ""
		)
		
		button btnFaceRig "表情绑定辅助工具" height:21 width:205
		on btnFaceRig pressed do 
		(
			currentFolder = getFilenamePath (getThisScriptFilename())
			rulesScript = pathConfig.appendPath currentFolder "/animcraft_float_Script_edit.ms"  --biped外观还原
			fileIn rulesScript
		)
			
		
		
		
		button btnShowImage  "Author:HYW ，联系作者，反馈报错！  " height:21 width:205

		on btnShowImage pressed do
		(
			-- 使用DotNet类将Base64字符串解码为字节数组
			byteArray = (dotnetclass "System.Convert").FromBase64String(encodedString)

			-- 创建一个新的内存流
			memoryStream = dotNetObject "System.IO.MemoryStream" byteArray

			-- 使用内存流创建Bitmap图片
			global decodedImage
			decodedImage = (dotnetobject "System.Drawing.Bitmap" memoryStream)

			try(DestroyDialog ::imageRollout) catch()

			rollout imageRollout "Image Viewer" width:600 height:600
			(
				dotNetControl picture "System.Windows.Forms.PictureBox" pos:[0,0] width:600 height:600

				on imageRollout open do
				(
					picture.SizeMode = (dotNetClass "System.Windows.Forms.PictureBoxSizeMode").StretchImage
					picture.Image = decodedImage
				)
			)
			createDialog imageRollout
		)
	)


)
CreateDialog AniTools  width:240 