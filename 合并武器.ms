--合并武器

files = getFiles @"D:\UNITY版本美术资源\模型\成人秀\秀\秀_风格化男脸\*_skin.max" recurse:true 

thefile = @"D:\UNITY版本美术资源\动作\show\show_male\Xiu_b_01\weapons01.max"

weapons = #("Wp_Karin_01","B_Zhang","WP_Gs_Hammer_02","B_Chui","B_Gong","WP_Ace_02","B_Jian","Jian")

for File in files do 
(
	loadMaxFile File quiet:true 
	
	weaponObjs = for obj in objects where (findItem weapons obj.name) != 0 collect obj 

	try(delete weaponObjs)catch()

	mergeMAXFile theFile #("B_R_sd","B_L_sd","Editable Mesh18","Editable Poly96","U_Char","B_Qiang01","B_Qiang02","B_Qiang03","B_Jian","Jian","Bone043","Bone044","Bone045","gun")  #alwaysReparent #mergeDups #autoRenameDups #useMergedMtlDups quite:true 

	$B_R_sd.transform = (matrix3 [1.99743e-06,5.24124e-06,4.28944] [1,4.41223e-05,-5.68107e-07] [-1.08646e-05,0.246154,-3.15446e-07] [-187.605,-8.01086e-05,32.3214])

	$B_Qiang01.transform = (matrix3 [2.5332e-07,-1.78814e-07,1] [-1,-3.57628e-07,2.98023e-07] [3.8743e-07,-1,-1.49012e-07] [-259.284,2.38419e-06,-0.486336])

	$Bone043.transform = (matrix3 [1.47079e-06,2.23517e-07,1] [-0.999669,0.0257056,1.54204e-06] [-0.0257056,-0.999669,1.63913e-07] [298.337,-0.107423,7.62939e-06])

	$B_L_sd.transform = (matrix3 [2.0933e-06,2.68454e-06,4.28944] [1,4.38765e-05,-3.89293e-07] [-1.08077e-05,0.246154,-1.54055e-07] [152.239,-2.38419e-06,30.3963])

	$B_Jian.transform = (matrix3 [8.49366e-07,-4.47035e-07,1] [1,4.38616e-05,-8.27014e-07] [-4.38914e-05,1,5.36442e-07] [228.98,-0.0617092,25.4406])
	
	saveMaxFile File saveAsVersion:2021
)

--修改父子级
files = getFiles @"D:\UNITY版本美术资源\动作\show\show_male\Xiu_b_01\剑\新建文件夹\*.max" recurse:true 

weapons = #("Wp_Karin_01","B_Zhang","WP_Gs_Hammer_02","B_Chui","B_Gong","WP_Ace_02")
for File in files do 
(
	loadMaxFile File quiet:true 
	exportPath = @"D:\exp" + "\\" + (getFilenameFile maxFileName) + ".fbx"
	weaponObjs = for obj in objects where (findItem weapons obj.name) != 0 collect obj 

	try(delete weaponObjs)catch()
	try
	(
		$B_Qiang01.parent = $'Bip001 R Hand'
		
		$B_R_sd.parent =  $'Bip001 R Hand'
		
		$B_Dao.parent = $'Bip001 R Hand'	
		
		$B_L_sd.parent = $'Bip001 L Hand'
		
		$B_Jian.parent = $'Bip001 R Hand'
		
		$Bone043.parent = $'Bip001 R Hand'
	)
	catch()
	
	saveMaxFile File saveAsVersion:2021
	
-- 	导出FBX 
	try
	(
		boneObjs = ($Bip001/...*) as array 
		meshObjs = for obj in geometry where obj.modifiers[#skin] != undefined and (findItem weapon obj.name) == 0 collect obj 
		objsExp = join boneObjs meshObjs
		
		select objsExp
		exportfile exportPath #noPrompt selectedOnly:true using:FBXEXP
	) 
	catch
	(
		messagebox ("导出文件 " + (getFilenameFile maxFileName) + " 时出错！")
	)
)


--替换拳套
files = getFiles @"D:\UNITY版本美术资源\模型\成人秀\秀\秀_风格化男脸\*_skin.max" recurse:true 

theFile = @"D:\UNITY版本美术资源\模型\成人秀\秀\s_09_female_lod0_skin.max"

delWeapons = #("w_paw_lv1","w_paw_lv002","B_r_Zhua","B_l_Zhua","rdmobj113","rdmobj112")
for File in files do 
(
	loadMaxFile File quiet:true 
	
	delWeaponsObjs = for obj in objects where (findItem delWeapons obj.name) != 0 collect obj 
	try(delete delWeaponsObjs )catch ()
	
	mergeMAXFile theFile #("w_paw_lv1","w_paw_lv002","B_r_Zhua","B_l_Zhua") #alwaysReparent #mergeDups #autoRenameDups #useMergedMtlDups quite:true 
	
	max unhide all 
	$B_r_Zhua.transform = (matrix3 [0.000194028,0.00069771,-1] [1,0.000147805,0.000194135] [0.000147894,-1,-0.000697643] [-69.9951,-7.34748,46.751])
	
	$B_l_Zhua.transform = (matrix3 [0.000314516,0.000651889,-1] [1,-3.69251e-05,0.000314492] [-3.67761e-05,-1,-0.000651901] [69.995,-7.34747,46.751])

	
	saveMaxFile File saveAsVersion:2021

)


--修改武器链接约束
$B_Qiang01.transform.controller.setFrameNo 1 0
$B_L_sd.Transform.controller = Link_Constraint ()
$B_R_sd.Transform.controller = Link_Constraint ()
$Bone043.Transform.controller = Link_Constraint ()


$B_L_sd.transform.controller.addWorld frameNo: 0
$B_R_sd.transform.controller.addWorld frameNo: 0
$Bone043.transform.controller.addWorld frameNo: 0


$B_Dao.transform.controller.deleteTarget 1
$B_Dao.transform.controller.addWorld frameNo: 0

$B_Jian.transform.controller.deleteTarget 1
$B_Jian.transform.controller.addWorld frameNo: 0

$B_r_Zhua.transform.controller.deleteTarget 1
$B_r_Zhua.transform.controller.addWorld frameNo: 0

$B_l_Zhua.transform.controller.deleteTarget 1
$B_l_Zhua.transform.controller.addWorld frameNo: 0


weapons = #("B_Qiang01","B_L_sd","B_R_sd","Bone043","B_Dao","B_Jian","B_r_Zhua","B_l_Zhua")


weaponObjs = for obj in objects where (findItem weapons obj.name) != 0 collect obj 

select weaponObjs

