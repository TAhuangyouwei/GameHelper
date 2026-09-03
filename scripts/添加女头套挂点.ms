try(DestroyDialog batchMerge)catch() 
 
 rollout batchMerge "批量合并"
(	
	edittext fliesPath "源文件路径:"  tooltip:"只会选出非LOD的skin文件"  fieldWidth:430  height:20
	button btn_mergeHead "批量添加"  width:140  tooltip:"批量添加头套挂点"
	on btn_mergeHead pressed do 
	(
		maxopenpath = fliesPath.text + "\*.max"
		maxfiles = getFiles maxopenpath recurse:true
		if maxfiles.count > 0 then 
		(
			for file in maxfiles do 
			(
					if findString file "_skin.max" != undefined then 
					(
						loadMaxFile file useFileUnits:true quiet:true

-- 						mergeMAXFile mergeFile #autoRenameDups useFileUnits:true quiet:true
						
-- 						headDummy = dummy boxsize:[5,5,5] 
-- 						headDummy.name  = "hp_toutao"
-- 						headDummy.rotation = (quat 0.707107 0 0 0.707107)
-- 						headDummy.pos = $'Bip001 Head'.transform.pos
-- 						parentObj = $'Bip001 Head'
-- 						headDummy.parent = parentObj
-- 						$hp_toutao.transform = (matrix3 [1,-2.64149e-06,-4.64226e-07] [4.64226e-07,-2.38419e-07,1] [-2.64149e-06,-1,-2.38418e-07] [2.14085e-05,3.96011,158.566])          --男秀头套挂点
						
						$hp_toutao.transform = (matrix3 [1,-2.49139e-06,0] [0,-4.47035e-07,1] [-2.49229e-06,-1,-4.47035e-07] [-2.14091e-05,3.33475,142.824])          --女秀头套挂点
						
						saveMaxFile file quiet:true saveAsVersion:2021
					)
				
			)
		)
		else (
			messageBox "未找到文件。请检查路径。"
		)
	)
)
createdialog batchMerge 520 52.0
