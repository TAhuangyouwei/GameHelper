/*
    骨骼命名相关功能。
    从 HYW_Scripts_Library.ms 拆出，保留原结构名和调用方式。
*/

struct BoneUtilities
(
	fn RenameBoneNub = --重命名末端骨
	(
		local endBones = for bone in selection where
						(
							classOf bone == BoneGeometry and
							bone.parent != undefined and
							classOf bone.parent == BoneGeometry and
							bone.children.count == 0 and
							findString bone.name "Nub" == undefined
						)
						collect bone

		if endBones.count == 0 then
		(
			messageBox "当前选择中没有需要添加 Nub 后缀的末端 Bone。"
			return 0
		)

        undo "重命名末端骨骼" on
        (
            for bone in endBones do
                bone.name += "Nub"
        )
		endBones.count
		
	)

)
