--合并武器

files = getFiles @"D:\UNITY版本美术资源\动作\show\show_female\s_09_female\home\*.max" recurse:true 

thefile = @"D:\UNITY版本美术资源\模型\成人秀\秀\秀_风格化女脸\s_09_female新\s_09_female_lod0_skin.max"

anim_weaponsName = #("B_R_sd","B_L_sd","B_Jian","B_Dao","B_r_Zhua","B_l_Zhua")

for File in files do 
(
	loadMaxFile File quiet:true 
	anim_weaponsNameObj = for obj in objects where (findItem anim_weaponsName obj.name) != 0 collect obj 
	for i = 1 to anim_weaponsName.count do 
	(
		addNewKey anim_weaponsNameObj[i].transform.controller animationrange.start
		addNewKey anim_weaponsNameObj[i].transform.controller animationrange.end
	)
	
	localPath = (getdir #animations) +"\\"
	
	fileName = (filterString (getFilenameFile maxFileName) "@")[2]
	
	anim_bonesObj = for obj in objects where (findItem anim_weaponsName obj.name) != 0 collect obj 
	
	xaf_file_name = localPath+ fileName + ".xaf"
	userAttributes = ""
	userValues = ""
	
	
	LoadSaveAnimation.saveAnimation xaf_file_name anim_bonesObj userAttributes userValues animatedTracks:on includeConstraints:on keyableTracks:off saveSegment:off 
	
	
	mergeMAXFile theFile #("B_Qiang01","B_Qiang02","B_Qiang03","w_changqiang_lv6","B_Gun01","B_Gun02","B_Gun03","w_gun_lv6") #alwaysReparent quite:true 

-- 	if isLinkConstraint $AAA2 then 
-- 	(
-- 		num = $AAA2.controller.getNumTargets()
-- 		
-- 		lc = link_constraint()		
-- 		
-- 		lc_node = $AAA2.controller.getNode 1
-- 		lc_fream = $AAA2.controller.getFrameNo 1
-- 	
-- 		lc.addTarget lc_node lc_fream
-- 		
-- 		$'B_R_sd'.controller = lc  
-- 			
-- 	)
-- 	
-- 	
-- 	
-- 	if isLinkConstraint $AAA4 then 
-- 	(
-- 		num = $AAA4.controller.getNumTargets()
-- 		
-- 		lc = link_constraint()		
-- 		
-- 		lc_node = $AAA4.controller.getNode 1
-- 		lc_fream = $AAA4.controller.getFrameNo 1
-- 	
-- 		lc.addTarget lc_node lc_fream
-- 		
-- 		$'B_L_sd'.controller = lc  
-- 			
-- 	)
-- 	newBonesObj = for obj in objects where (findItem anim_weaponsName obj.name) != 0 collect obj 
-- 	LoadSaveAnimation.loadAnimation xaf_file_name newBonesObj relative:off insert:off insertTime:animationRange.start
	
-- 	addNewKey $B_R_sd.transform.controller animationrange.start
-- 	addNewKey $B_L_sd.transform.controller animationrange.start
-- 	
-- 	addNewKey $B_R_sd.transform.controller animationrange.end
-- 	addNewKey $B_L_sd.transform.controller animationrange.end
-- 	
--     try(delete delete_weaponsNameObjs)catch()
	
	saveMaxFile File saveAsVersion:2021
)
