--调整武器位置

files = getFiles @"D:\UNITY版本美术资源\动作\show\show_female\svip_11_female\mount\*.max" recurse:true 

thefile = @"E:\asda\wp.max"


for File in files do 
(
	loadMaxFile File quiet:true 
	
-- 	in coordsys local Rotate $B_R_sd (EulerAngles 180 0 0)
-- 	
	in coordsys local Rotate $B_L_sd (EulerAngles 180 0 0)

-- 	in coordsys local move $B_R_sd [0,0,5]
-- 	
-- 	try(delete $w_shuangdao_lv6 )catch()
	try(delete $w_shuangdao_lv007 )catch()
-- 	try(delete $'Editable Mesh18' )catch()
-- 	try(delete $'Editable Poly96' )catch()

-- 	mergeMAXFile theFile #("w_shuangdao_lv6","w_shuangdao_lv007") #alwaysReparent  #mergeDups #useMergedMtlDups quite:true 
	
-- 	mergeMAXFile theFile #("w_shuangdao_lv6") #alwaysReparent  #mergeDups #useMergedMtlDups quite:true 

	mergeMAXFile theFile #("w_shuangdao_lv007") #alwaysReparent  #mergeDups #useMergedMtlDups quite:true 
	
	temp = animationRange.start
	
	animationRange = Interval 0 animationRange.end 
	
	sliderTime = 0f 

-- 	$w_shuangdao_lv6.transform = $B_R_sd.transform
-- 	
	$w_shuangdao_lv007.transform = $B_L_sd.transform
-- 	
-- 	addModifier $w_shuangdao_lv6 (skin())
-- 		
	addModifier $w_shuangdao_lv007 (skin())
-- 		
-- 	skinOps.addBone $w_shuangdao_lv6.modifiers[#Skin] $B_R_sd 1
-- 		
	skinOps.addBone $w_shuangdao_lv007.modifiers[#Skin] $B_L_sd 1
-- 		
	animationRange = Interval temp animationRange.end 
		
		
	saveMaxFile File saveAsVersion:2021
)
