currentFolder = getFilenamePath (getThisScriptFilename())
HYW_Scripts_Library_rulesScript = pathConfig.appendPath currentFolder "HYW_Scripts_Library.ms" --函数库
fileIn HYW_Scripts_Library_rulesScript



try(DestroyDialog boneFin )catch() 
rollout boneFin "自定义骨骼绑定"
(
	
	button createConerBone "手肘膝盖创建" height:21 width:130   tooltip:"依次选择父级和子级" across:2  
	
	on createConerBone pressed do 
	(
		upper = #($'Bip001 R UpperArm',$'Bip001 L UpperArm')
		lower = #($'Bip001 R Forearm',$'Bip001 L Forearm')
		num = selection.count 
		if num == 0 then 
		(
			for i = 1 to 2 do 
			(
				BipedFunctions.createElbowJoint upper[i] lower[i]
			)
		)
		else if num == 2 then 
		(
			BipedFunctions.createElbowJoint selection[1] selection[2]
		)
		
	)
	
	button btmuscle "肌肉创建(缩放)"   height:21 width:130    tooltip:"依次选择3个物体 upper lower muscle(肩膀、头、肌肉)" 
	
	on btmuscle pressed do 
	(
		objs = selection as array 
		BipedFunctions.createMuscleControlSystem objs[1] objs[2] objs[3] 
			
	)
	
	on btmuscle rightclick do 
	(
		objs = selection as array 
		BipedFunctions.adjustSpineFlexibility objs[1] objs[2] objs[3] 
		
		print "ABCD"
	)
	
	button btLegCtrl "马腿部控制器" tooltip:"顺序选择upper，lower，Thigh(Biped)选完一组再选另一组" across:2   height:21 width:130 
	on btLegCtrl pressed do 
	(
		num = selection.count
		temp = num/3
		if num !=0 then --顺序选择，选完一组再选另一组
		(
			for i = 1 to num by 3 do 
				(
					j = i+1
					k = i+2 
					BipedFunctions.setupLegControlSystem (selection[i]) (selection[j]) (selection[k])
				)
		)
	)
	
	button btSpineCtrl "创建脊椎控制器"  tooltip:"创建出来脊椎骨骼的控制器系统"      height:21 width:130 
	
	on btSpineCtrl pressed do 
	(
		undo on 
		(
			bnArray = selection as array 
			for obj in bnArray do BipedFunctions.createSpineControlSystem obj  --创建出来脊椎骨骼的控制器系统
		)
		
	)
	
	button btCustomIKHISolver "蜘蛛腿创建" tooltip:"双击全选单个腿的所有骨骼(算上末端骨3根或5根)" across:2    height:21 width:130 
	
	on btCustomIKHISolver pressed do 
	(
		myCustomIKSolver = CustomIKHISolver()
		myCustomIKSolver.create()
	)
	button btn_Measure "测量物体长度"    height:21 width:130 
	
	
	button btn_Joint "关节创建"   tooltip:"需要依次选择三个物体" across:2        height:21 width:130 
	
	on btn_Joint pressed do 
	(
		undo on 
		(
			bnArray = selection as array
			BipedFunctions.createJointSystem bnArray[1] bnArray[2] bnArray[3]
		)
	)
	
	
	
	button btn_Muscle "肌肉创建(位移)"   tooltip:"Bone骨骼需要X轴向前，Y轴向上"           height:21 width:130 
	
	on btn_Muscle pressed do 
	(
		undo on 
		(
			bnArray = selection as array 
			BipedFunctions.createMuscleSystem bnArray[1] bnArray[2] bnArray[3]
		)
	)
	
	
	label lbl_Measure "骨骼的测量长度为:"       
	
	on btn_Measure pressed do 
	(
		objs = selection as array 
		obj_length = 0 
		if objs.count != 0 and classof objs[1] == BoneGeometry then 
		(
			for i = 1 to 3 do 
			(
				obj_length = objs[i].length + obj_length
			)
			
		)
		else if classof objs[1] == Biped_Object then 
		(
			for i = 2 to 3 do 
			(
				dis = distance objs[i-1] objs[i]
				obj_length = dis + obj_length
			)
		)
		
		lbl_Measure.text = "骨骼的测量长度为:" + obj_length as string 
	)
		
)
createdialog boneFin 300 130