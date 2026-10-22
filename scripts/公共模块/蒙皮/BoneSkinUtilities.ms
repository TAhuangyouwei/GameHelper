/*
    Skin 骨骼读取、保存和应用功能。
    从 HYW_Scripts_Library.ms 拆出，保留原结构名和调用方式。
*/

struct BoneSkinUtilities
(
    -- 获取骨骼节点
    fn getBoneNodes skinObject =
	(
		envPath =getdir #userscripts + "\\temp.env"
		skinOps.SaveEnvelope skinObject.modifiers[#Skin] envPath
		skinOps.GetBoneNodes skinObject.skin
    ),

    -- 保存骨骼名称到文件
    fn saveBoneNamesToFile boneObjs filePath =
	(
        local outputFileStream = createFile filePath
        if outputFileStream != undefined then
		(
            for bone in boneObjs do
			(
                format "%\n" bone.name to:outputFileStream
            )
            close outputFileStream
        )
		else
		(
            print "无法创建文件流"
        )
    ),

    -- 读取骨骼名称
    fn loadBoneNamesFromFile filePath = (
        local boneNames = #()
        local fileStream = openFile filePath
        if fileStream != undefined then (
            while not eof fileStream do (
                append boneNames (readLine fileStream)
            )
            close fileStream
        ) else (
            print "无法打开文件流"
        )
        boneNames
    ),

    -- 应用骨骼到模型
    fn applyBonesToModel boneNames model =
	(
		envPath =getdir #userscripts + "\\temp.env"
        local boneObjs = for boneName in boneNames where (getNodeByName boneName) != undefined collect (getNodeByName boneName)
        for bone in boneObjs do (
			newBoneObjs = skinOps.GetBoneNodes model.skin
			if (findItem newBoneObjs bone ) == 0 then
				skinOps.addBone model.skin bone 0
        )

		skinOps.loadEnvelope model.modifiers[#Skin] envPath
    )
)
