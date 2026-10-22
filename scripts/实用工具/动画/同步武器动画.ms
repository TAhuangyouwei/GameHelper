try (DestroyDialog fileAnim) catch ()

rollout fileAnim "同步武器动画"
(
	edittext et_Original "无武器动画:"
	edittext et_Reference "有武器动画:"
	
	button bt_Confirm "确认"
	label lb_author "author:HYW"
	
	on bt_Confirm pressed do 
	(
		originalPath = et_Original.text + "\\*.max"
		referencePath = et_Reference.text + "\\*.max"
		
		originalFiles = getFiles originalPath recurse:true 
		referenceFiles = getFiles referencePath recurse:true 

		mergeWeaponsName = #("w_changqiang_lv6","B_Qiang01","B_Qiang02","B_Qiang03","w_shuangdao_lv6","B_R_sd","rdmobj002","B_Dao","w_paw_lv1","B_r_Zhua","w_paw_lv002","B_l_Zhua","w_shuangdao_lv007","B_L_sd","Jian","B_Jian","w_gun_lv6","B_Gun01","B_Gun02","B_Gun03")
		deleteWeaponsName = #("Wp_Karin_01","B_Zhang","WP_Gs_Hammer_02","B_Chui","rdmobj002","B_Dao","rdmobj113","B_r_Zhua","rdmobj112","B_l_Zhua","Jian","B_Jian","WP_Ace_02","B_Gong","w_changqiang_lv6","B_Qiang01","B_Qiang02","B_Qiang03","w_shuangdao_lv6","B_R_sd","w_paw_lv1","w_paw_lv002","w_shuangdao_lv007","B_L_sd","w_gun_lv6","B_Gun01","B_Gun02","B_Gun03")

		for file in originalFiles do 
		(
			loadMaxFile file quiet:true 
			
			deleteWeaponsNameObjs = for obj in objects where (findItem deleteWeaponsName obj.name) != 0 collect obj 

			tempName = (filterString maxFileName "@")[2]
			
			if tempName != undefined then
			(
				for i = 1 to referenceFiles.count do
				(
					if (findString referenceFiles[i] tempName) != undefined then
					(
						try (if deleteWeaponsNameObjs.count > 0 then delete deleteWeaponsNameObjs) catch (format "删除物体失败: %\n" file)
						
						try
						(
							mergeMAXFile referenceFiles[i] mergeWeaponsName #alwaysReparent #mergeDups #useMergedMtlDups quiet:true 
						)
						catch (format "合并文件失败: %\n" referenceFiles[i])

						saveMaxFile file saveAsVersion:2021
					)
				)
			)	
		)
	)
)

CreateDialog fileAnim 300 95
