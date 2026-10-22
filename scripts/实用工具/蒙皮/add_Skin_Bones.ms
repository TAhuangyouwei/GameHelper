
-- 用户界面部分
try(DestroyDialog myRollout)catch()
rollout myRollout "添加原模型的SkinBones" width:200 height:100 (
    button btnSave "保存骨骼" pos:[10,10] width:180 height:25
    button btnLoad "读取骨骼" pos:[10,40] width:180 height:25
	
	label  doit_prog  ""
	timer clock "testClock" interval:5000 --tick once a second
	
    on btnSave pressed do (
        skinObj1 = selection[1]
		if skinObj1.modifiers[#skin] != undefined then
		(
			boneObjs = BoneSkinUtilities.getBoneNodes skinObj1
			filePath = (getDir #userScripts) + "\\boneList.txt"
			BoneSkinUtilities.saveBoneNamesToFile boneObjs filePath
			
			doit_prog.text = "保存已完成"
			
		)
		else
		(
			doit_prog.text = "当前物体没有skin修改器"
		)


		
    )

    on btnLoad pressed do 
	(
        filePath = (getDir #userScripts) + "\\boneList.txt"
		boneNames = BoneSkinUtilities.loadBoneNamesFromFile filePath
		
		skinObj2 = selection[1]
		if skinObj2.modifiers[#skin] != undefined then 
		(
			BoneSkinUtilities.applyBonesToModel boneNames skinObj2
			skinObj2.modifiers[#Skin].bone_Limit = 4
		)
			
		else
		(
			addModifier skinObj2 (skin())
			BoneSkinUtilities.applyBonesToModel boneNames skinObj2
			skinObj2.modifiers[#Skin].bone_Limit = 4
		)
		doit_prog.text = "加载已完成"
    )
	
	on clock tick do
	(
		doit_prog.text = ""
	)

)

createDialog myRollout
