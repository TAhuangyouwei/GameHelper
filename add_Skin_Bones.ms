
-- �û����沿��
try(DestroyDialog myRollout)catch()
rollout myRollout "����ԭģ�͵�SkinBones" width:200 height:100 (
    button btnSave "�������" pos:[10,10] width:180 height:25
    button btnLoad "��ȡ����" pos:[10,40] width:180 height:25
	
	label  doit_prog  ""
	timer clock "testClock" interval:5000 --tick once a second
	
    on btnSave pressed do (
        skinObj1 = selection[1]
		if skinObj1.modifiers[#skin] != undefined then
		(
			boneObjs = BoneSkinUtilities.getBoneNodes skinObj1
			filePath = (getDir #userScripts) + "\\boneList.txt"
			BoneSkinUtilities.saveBoneNamesToFile boneObjs filePath
			
			doit_prog.text = "���������"
			
		)
		else
		(
			doit_prog.text = "��ǰ����û��skin�޸���"
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
		doit_prog.text = "���������"
    )
	
	on clock tick do
	(
		doit_prog.text = ""
	)

)

createDialog myRollout