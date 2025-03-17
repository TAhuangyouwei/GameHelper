-- currentFolder = getFilenamePath (getThisScriptFilename())
-- HYW_Scripts_Library_rulesScript = pathConfig.appendPath currentFolder "HYW_Scripts_Library.ms" --函数库
-- fileIn HYW_Scripts_Library_rulesScript

--从动作工具打开，无需导入
 
 
 
 global weapon = #("U_Char","Editable Mesh18","rdmobj002","rdmobj113","rdmobj112","Editable Poly96","Jian","gun","w_changqiang_lv6","w_shuangdao_lv6","w_shuangdao_lv007","w_shuangdao_lv007","w_paw_lv1","w_paw_lv002","w_gun_lv6")
 global timeRanges = #()
 global ContainLinkFilesName =#()
 
fn Get_AC_Objects =
(
	AC_Objs = ($Animcraft_Facial_GRP/...*) as array 

	AC_Bones = ($Facial_Master_SkinJNT/...*) as array 

	AC_Locals = ($Animcraft_Location_GRP/...*) as array 
	
	AC_Dummy = for obj in objects where (classof obj == dummy and findstring obj.name "hp_" == undefined and findstring obj.name "Dummy" == undefined  and  findstring obj.name "Nub" == undefined ) collect obj 
	
	AC_SplineShape = for obj in objects where (classof obj == SplineShape and findstring obj.name "Animcraft_" != undefined ) collect obj 
	
	join AC_Objs AC_Bones

	join AC_Objs AC_Locals
	
	join AC_Objs AC_Dummy
	
	join AC_Objs AC_SplineShape
	
	AC_Objs

)




	
 rollout batchMerge "批量合并"
(

	edittext fliesPath "源 文 件 路径:"  tooltip:"只会选出非LOD的skin文件" across:2 fieldWidth:430  height:20
	button btn_clear1  "清空" align:#right width:50 
	
	edittext targetPath "合并文件路径:" tooltip:"头的文件名需要为mergefile" across:2 fieldWidth:430  height:20	
	button btn_clear2  "清空" align:#right width:50 
	
	button btn_mergeHead "批量/单次(L/R)合并头" across:3  width:140  tooltip:"左键批量合并，右键单词合并"
	button btn_mergeWepon "批量/单次(L/R)合并武器"  width:140  tooltip:"左键批量合并，右键单词合并"
	button btn_mergeKnee "批量/单次(L/R)合并膝盖"  width:140  tooltip:"左键批量合并，右键单词合并"
	
	
	button btn_select "选择AC物体" width:140 across:2
	
	
	
	on btn_clear1 pressed do 
	(
		fliesPath.text = ""
	)
	
	
	on btn_clear2 pressed do 
	(
		targetPath.text = ""
	)
	
	on btn_select pressed do 
	(
		AC_Objects = Get_AC_Objects()
		select AC_Objects
	)
	
	button btn_delete "删除AC物体" width:140 
	
	on btn_delete pressed do 
	(
		AC_Objects = Get_AC_Objects()
		delete AC_Objects
	)
	
	on btn_mergeHead pressed do 
	(
		maxopenpath = fliesPath.text + "\*.max"
		maxfiles = getFiles maxopenpath recurse:true

		mergeFile = targetPath.text +"\mf.max"
		if maxfiles.count > 0 then 
		(
			for file in maxfiles do 
			(
					if findString file "_skin" != undefined and findString file "lod_skin" == undefined then 
					(
						loadMaxFile file useFileUnits:true quiet:true
						AC_Objects = Get_AC_Objects()
						delete AC_Objects
						mergeMAXFile mergeFile #autoRenameDups useFileUnits:true quiet:true
						
						parentObj = $'Bip001 Head'
						childObj= $'Facial_Master_SkinJNT'
						if parentObj != undefined then 
						(
							if childObj != undefined  then 
							(
								childObj.parent = parentObj
								
								targetNodes = $ACCFacial
								targetNodes[3].addTarget $'Bip001 Head' 0
								
								
								fileName = substring (getFilenameFile( maxFileName )) 1 9
								eyeshadow = (for obj in objects where (classof obj.baseobject == Editable_Poly) and ((findString obj.name "_eyeShadows" != undefined or findString obj.name "_eyeShdows" != undefined ) and (obj.modifiers[#skin]  != undefined)) collect obj)[1]
								if eyeshadow != undefined then 
									skinOps.addbone eyeshadow.skin $'Bip001 Head' -1
								
								temp_eyeshadow_name = replace (eyeshadow.name) 1 9 fileName
								eyeshadow.name = temp_eyeshadow_name

								headObj = (for obj in objects where (classof obj.baseobject == Editable_Poly) and ((findString obj.name "_head" != undefined) and (obj.modifiers[#skin]  != undefined)) collect obj)[1]
								
								temp_head_name = replace (headObj.name) 1 9 fileName
								headObj.name = temp_head_name
									
								saveMaxFile file quiet:true saveAsVersion:2021
							)
						)
					)
				
			)
		)
		else (
			messageBox "未找到文件。请检查路径。"
		)
	)
	
	
	on btn_mergeHead rightclick do 
	(
		try 
		(
			
		delete (Get_AC_Objects())
		)
		catch()
		mergeFile = targetPath.text +"\mf.max"
		mergeMAXFile mergeFile #autoRenameDups useFileUnits:true quiet:true
		
		file = maxfilepath + maxFileName
		
		parentObj = $'Bip001 Head'
		childObj= $'Facial_Master_SkinJNT'
		if parentObj != undefined then 
		(
			if childObj != undefined  then 
			(
				childObj.parent = parentObj
				
				targetNodes = $ACCFacial
				targetNodes[3].addTarget $'Bip001 Head' 0
				
				
				fileName = substring (getFilenameFile( maxFileName )) 1 9
				eyeshadow = (for obj in objects where (classof obj.baseobject == Editable_Poly) and ((findString obj.name "_eyeShadows" != undefined or findString obj.name "_eyeShdows" != undefined ) and (obj.modifiers[#skin]  != undefined)) collect obj)[1]
				if eyeshadow != undefined then 
					skinOps.addbone eyeshadow.skin $'Bip001 Head' -1
				
				try 
				(
				temp_eyeshadow_name = replace (eyeshadow.name) 1 9 fileName
				eyeshadow.name = temp_eyeshadow_name
				)
				catch()
				headObj = (for obj in objects where (classof obj.baseobject == Editable_Poly) and ((findString obj.name "_head" != undefined) and (obj.modifiers[#skin]  != undefined)) collect obj)[1]
				
				temp_head_name = replace (headObj.name) 1 9 fileName
				headObj.name = temp_head_name
					
				saveMaxFile file quiet:true saveAsVersion:2021
			)
		)

	)
	
	
	on btn_mergeWepon pressed do 
	(
		maxopenpath = fliesPath.text + "\*.max"
		maxfiles = getFiles maxopenpath recurse:true
		
		mergeFile = targetPath.text +"\mf.max"
		if maxfiles.count > 0 then 
		(
			for file in maxfiles do 
			(
					if findString file "_skin" != undefined  then 
					(
						loadMaxFile file useFileUnits:true quiet:true
						mergeMAXFile mergeFile #autoRenameDups useFileUnits:true quiet:true
						
						parentObj_L = $'Bip001 L Hand'
						parentObj_R= $'Bip001 R Hand'
						
						childObjs= #($B_Dao,$B_r_Zhua,$B_l_Zhua,$B_Jian)
						if parentObj_L != undefined and  parentObj_R != undefined  then 
						(
							for i = 1 to childObjs.count do 
							(
								if childObjs[i] != undefined  then 
								(
									if i < 3 then 
										childObjs[i].parent = parentObj_R
									else 
										childObjs[i].parent = parentObj_L
									
										
									saveMaxFile file quiet:true saveAsVersion:2021
								)
								else
									messageBox "未找到武器！"
								
							)
						)
						else 
							messageBox "未找到武器的父物体"
					)
				
			)
		)
		else (
			messageBox "未找到文件。请检查路径。"
		)
	)
	
	
	on btn_mergeWepon rightclick do 
	(
		mergeFile = targetPath.text +"\mf.max"
		mergeMAXFile mergeFile #autoRenameDups useFileUnits:true quiet:true
		
		parentObj_L = $'Bip001 L Hand'
		parentObj_R= $'Bip001 R Hand'
		
		childObjs= #($B_Dao,$B_r_Zhua,$B_l_Zhua,$B_Jian)
		
		file = maxfilepath + maxFileName 
		if parentObj_L != undefined and  parentObj_R != undefined  then 
		(
			for i = 1 to childObjs.count do 
			(
				if childObjs[i] != undefined  then 
				(
					if i < 3 then 
						childObjs[i].parent = parentObj_R
					else 
						childObjs[i].parent = parentObj_L
					
						
					saveMaxFile file quiet:true saveAsVersion:2021
				)
				else
					messageBox "未找到武器！"
				
			)
		)
			

	)
	
	on btn_mergeKnee pressed do 
	(
		maxopenpath = fliesPath.text + "\*.max"
		maxfiles = getFiles maxopenpath recurse:true
		
		mergeFile = targetPath.text +"\mf.max"
		if maxfiles.count > 0 then 
		(
			for file in maxfiles do 
			(
					if findString file "lod0_skin" != undefined  then 
					(
						loadMaxFile file useFileUnits:true quiet:true
						mergeMAXFile mergeFile #autoRenameDups useFileUnits:true quiet:true
						
						try
						(

						$BN_01.parent =  $'Bip001 R Thigh'
						$BN_002.parent = $'Bip001 R Thigh'
						$BN_003.parent =  $'Bip001 L Thigh'
						$BN_004.parent =  $'Bip001 L Thigh'
							
						targetNodesR1 = $HpPar_XigaiB_R
						targetNodesR2 = $HpPar_XigaiF_R
						targetNodesR1[3].addTarget $'BN_knee_R' 0
						targetNodesR2[3].addTarget $'BN_knee_R' 0		
							
						targetNodesR1 = $HpPar_XigaiB_L
						targetNodesR2 = $HpPar_XigaiF_L
						targetNodesR1[3].addTarget $'BN_knee_L' 0
						targetNodesR2[3].addTarget $'BN_knee_L' 0
							
						ctrlRF = $Hp_XigaiF_R[3][1][2][1].controller
						ctrlRF.SetVectorNode "a"  $Dummy004
						ctrlRF.SetVectorNode "b"  $Dummy012
							
							
						ctrlRB = $Hp_XigaiB_R[3][1][2][1].controller
						ctrlRB.SetVectorNode "a"  $Dummy004
						ctrlRB.SetVectorNode "b"  $Dummy012
							
							
						ctrlLF = $Hp_XigaiF_L[3][1][2][1].controller
						ctrlLF.SetVectorNode "a"  $Dummy003
						ctrlLF.SetVectorNode "b"  $Dummy011
							
						ctrlLB = $Hp_XigaiB_L[3][1][2][1].controller
						ctrlLB.SetVectorNode "a"  $Dummy003
						ctrlLB.SetVectorNode "b"  $Dummy011
						
						saveMaxFile file quiet:true saveAsVersion:2021
						
						)
						catch()
					)
				
			)
		)
		else (
			messageBox "未找到文件。请检查路径。"
		)
	)
	
	
	on btn_mergeKnee rightclick do 
	(
		mergeFile = targetPath.text +"\mf.max"
		mergeMAXFile mergeFile #autoRenameDups useFileUnits:true quiet:true
		
		try
		(

			$BN_01.parent =  $'Bip001 R Thigh'
			$BN_002.parent = $'Bip001 R Thigh'
			$BN_003.parent =  $'Bip001 L Thigh'
			$BN_004.parent =  $'Bip001 L Thigh'

			targetNodesR1 = $HpPar_XigaiB_R
			targetNodesR2 = $HpPar_XigaiF_R
			targetNodesR1[3].addTarget $'BN_knee_R' 0
			targetNodesR2[3].addTarget $'BN_knee_R' 0		
				
			targetNodesR1 = $HpPar_XigaiB_L
			targetNodesR2 = $HpPar_XigaiF_L
			targetNodesR1[3].addTarget $'BN_knee_L' 0
			targetNodesR2[3].addTarget $'BN_knee_L' 0
				
			ctrlRF = $Hp_XigaiF_R[3][1][2][1].controller
			ctrlRF.SetVectorNode "a"  $Dummy004
			ctrlRF.SetVectorNode "b"  $Dummy012
				
				
			ctrlRB = $Hp_XigaiB_R[3][1][2][1].controller
			ctrlRB.SetVectorNode "a"  $Dummy004
			ctrlRB.SetVectorNode "b"  $Dummy012
				
				
			ctrlLF = $Hp_XigaiF_L[3][1][2][1].controller
			ctrlLF.SetVectorNode "a"  $Dummy003
			ctrlLF.SetVectorNode "b"  $Dummy011
				
			ctrlLB = $Hp_XigaiB_L[3][1][2][1].controller
			ctrlLB.SetVectorNode "a"  $Dummy003
			ctrlLB.SetVectorNode "b"  $Dummy011
		
		)
		catch()
			

	)
	
)
 
 
 
 rollout animExport "批量导出"
(
    edittext etPath "Max文件路径:" fieldWidth:430 height:20 across:2 
    button btclear1 "清空" align:#right width:50 
    edittext et_exportPath "导出文件路径" fieldWidth:430 height:20 across:2 text:"D:\exp"
    button btclear2 "清空" align:#right width:50 
    
    on btclear1 pressed do (etPath.text = "")
	on btclear1 rightclick do 
	(
		if etPath.text != "" then 
			ShellLaunch  etPath.text ""
		else 
			messageBox "地址为空，请输入要打开的文件地址"
	)
	
    on btclear2 pressed do (et_exportPath.text = "")
	on btclear2 rightclick do 
	(
		if et_exportPath.text != "" then 
			ShellLaunch  et_exportPath.text ""
		else 
			messageBox "地址为空，请输入要打开的文件地址"
	)
	
	button btBentchExport "批量导出所有文件"   tooltip:"左键不拆分导出，右键拆分头和身体导出,动画文件需要放到anim文件夹导出"  width:140  across:2
	
	button btExport "单次导出当前文件"   tooltip:"左键不拆分导出，右键拆分头和身体导出" width:140
	
	button btnSaveAnim "保存动画" width:140  across:2  tooltip:"左键批量保存动画,右键保存当前文件动画"
	
	button btnloadAnim "加载动画" width:140  tooltip:"左键批量加载动画,右键加载当前文件动画"
	
	
    on btBentchExport pressed do
    (
        local shouldContinue = true

        if (trimleft etPath.text == "" and trimleft et_exportPath.text == "") then
        (
            messagebox "请填写Max文件路径和导出文件路径！"
            shouldContinue = false
        )
        else
        (
            if (trimleft etPath.text == "") then
            (
                messagebox "请填写Max文件路径！"
                shouldContinue = false
            )
            else if (doesFileExist etPath.text == false) then
            (
                messagebox "Max文件路径无效或不存在！"
                shouldContinue = false
            )

            if shouldContinue and (trimleft et_exportPath.text == "") then
            (
                messagebox "请填写导出文件路径！"
                shouldContinue = false
            )
            else if shouldContinue then
            (
                try 
                (
                    makeDir (et_exportPath.text + "\\lod0")
                    makeDir (et_exportPath.text + "\\lod2")
                    makeDir (et_exportPath.text + "\\lod3")
                )
                catch ()
                if isDirectoryWriteable et_exportPath.text then 
                    shouldContinue = true
                else 
                (
                    messageBox "文件夹创建失败，请手动修改导出地址."
                    shouldContinue = false
                )
            )
        )

        if shouldContinue then
        (
            openPath = (etPath.text + "\\*.max")
            files = getFiles openPath recurse:true 
            if files.count == 0 then 
            (
                messagebox "未找到文件!"
            )
            else
            (
                for i = 1 to files.count do 
                (   
                    local file = files[i] 
                    
                    if (findString file "lod0_skin" == undefined ) and (findString file "lod2_skin" == undefined ) and (findString file "lod3_skin" == undefined ) and (findString file "动作" == undefined ) then 
                        continue
                    
                    loadMAXFile file useFileUnits:true  quiet:true  allowPrompts:false

                    -- 确保 exportPath 设置在每个文件加载后
                    if (findString file "lod0_skin" != undefined) then 
                    (
                        exportPath = et_exportPath.text + "\\lod0\\" + (getFilenameFile file) + ".fbx"
                    )
                    else if (findString file "lod2_skin" != undefined) then 
                    (
                        exportPath = et_exportPath.text + "\\lod2\\" + (getFilenameFile file) + ".fbx"
                    )
                    else if (findString file "lod3_skin" != undefined) then 
                    (
                        exportPath = et_exportPath.text + "\\lod3\\" + (getFilenameFile file) + ".fbx"
                    )
                    else 
                    (
                        exportPath = et_exportPath.text + "\\" + (getFilenameFile file) + ".fbx"
                    )

                    -- 删除和导出操作
                    if findString file "lod2" != undefined then 
                    (
                        try 
                        ( 
                            AC_Objects = Get_AC_Objects()
                            delete AC_Objects 
                        ) catch()
                    )

                    weaponObj = for obj in geometry where  (findItem weapon obj.name) != 0 collect obj 
                    try (delete weaponObj ) catch()

                    meshObjs = for obj in geometry where obj.modifiers[#skin] != undefined collect obj 
                    for obj in meshObjs do 
                    (
                        if obj.parent != undefined then 
                            obj.parent = undefined 
                    )

                    boneObjs = ($Bip001/...*) as array 
                    objsExp = join boneObjs meshObjs

                    if objsExp.count == 0 then 
                        continue

                    try
                    (
                        select objsExp
                        exportfile exportPath #noPrompt selectedOnly:true using:FBXEXP
                    )
                    catch
                    (
                        messagebox ("导出文件 " + file + " 时出错！")
                    )
                    if i == files.count do
                    (
                        resetMaxFile #noPrompt
                        ShellLaunch et_exportPath.text ""
                    )
                )						
            )
        )
    )
	
	
	on btBentchExport rightclick do
	(
		local shouldContinue = true

		if (trimleft etPath.text == "" and trimleft et_exportPath.text == "") then
		(
			messagebox "请填写Max文件路径和导出文件路径！"
			shouldContinue = false
		)
		else
		(
			-- 检查Max文件路径是否已填写且有效
			if (trimleft etPath.text == "") then
			(
				messagebox "请填写Max文件路径！"
				shouldContinue = false
			)
			else if (doesFileExist etPath.text == false) then
			(
				messagebox "Max文件路径无效或不存在！"
				shouldContinue = false
			)

			-- 检查导出文件路径是否已填写且有效
			if shouldContinue and (trimleft et_exportPath.text == "") then
			(
				messagebox "请填写导出文件路径！"
				shouldContinue = false
			)
			else if shouldContinue and (doesFolderExist et_exportPath.text == false) then
			(
				messagebox "导出文件路径无效或不存在！"
				shouldContinue = false
			)
			
		)


		if shouldContinue then
		(
			openPath = etPath.text + "\\*.max"
			files = getFiles openPath recurse:true 
			if files.count == 0 then 
			(
				messagebox "未找到文件!"
			)
			else
			(
				for i = 1 to files.count do 
				(   
					local file = files[i] 
					
					if findString file "lod2_skin" == undefined then 
						continue
					
					
					
					--loadMaxFile file useFileUnits:true quiet:true allowPrompts:false missingExtFilesAction:#abort missingDLLsAction:#abort missingXRefsAction:#abort

					loadMAXFile file useFileUnits:true  quiet:true  allowPrompts:false
					
					weaponObj = for obj in geometry where  (findItem weapon obj.name) != 0 collect obj 
					
					try (delete weaponObj ) catch()
					
					headboneObjs = ($Bip001/...*) as array 
					bodyboneObjs = ($Bip001/...*) as array 
					
-- 					headObjs = for obj in geometry where obj.modifiers[#skin] != undefined and findstring obj.name "body" == undefined and (findItem weapon obj.name) == 0 and ( findstring obj.name "hair" != undefined or  findstring obj.name "head" != undefined or findstring obj.name "eyeShadows" != undefined  ) collect obj 
					headObjs = for obj in geometry where obj.modifiers[#skin] != undefined and findstring obj.name "body" == undefined and (findItem weapon obj.name) == 0 and ( findstring obj.name "hair" != undefined or  findstring obj.name "head" != undefined ) collect obj 

					bodyObjs = for obj in geometry where ( obj.modifiers[#skin] != undefined and findstring obj.name "body" != undefined ) or ( obj.modifiers[#skin] != undefined and (findItem weapon obj.name) == 0  and (findItem headObjs obj) == 0 ) collect obj 

						
					headEXP = join headboneObjs headObjs
					bodyEXP = join bodyboneObjs bodyObjs
					
					fileName = getFilenameFile file
					
					num = fileName.count - 9 
					
					
					if findString fileName "lod2_skin" != undefined then 
					(
						newfileName = replace fileName num 10 ""
						try
						(
							dir = et_exportPath.text + "\\LOD"
							
							if not (isDirectoryWriteable dir) then 
								makeDir dir
							
							select headEXP
							exportPath = dir + "\\" + newfileName +  "_head_lod2.fbx"
							exportfile exportPath #noPrompt selectedOnly:true using:FBXEXP
							
							select bodyEXP
							exportPath = dir + "\\" + newfileName +  "_body_lod2.fbx"
							exportfile exportPath #noPrompt selectedOnly:true using:FBXEXP
							
						) 
						catch
						(
							messagebox ("导出文件 " + file + " 时出错！")
						)
					)
					else 
					(
						newfileName = replace fileName num 10 ""
						try
						(
							select headEXP
							exportPath = et_exportPath.text + "\\" + newfileName + "_head_lod0.fbx"
							exportfile exportPath #noPrompt selectedOnly:true using:FBXEXP
							
							select bodyEXP
							exportPath = et_exportPath.text + "\\" + newfileName + "_body_lod0.fbx"
							exportfile exportPath #noPrompt selectedOnly:true using:FBXEXP
							
						) 
						catch
						(
							messagebox ("导出文件 " + file + " 时出错！")
						)
					)
					
					

					if i == files.count do
					(
						resetMaxFile #noPrompt
						ShellLaunch  et_exportPath.text ""
					)
					
				)						

			)
		)
	)
	
	--------------------------------分割线----------------------------------------------------
	
	on btExport pressed do
	(
		exportPath = et_exportPath.text + "\\" + (getFilenameFile maxFileName) + ".fbx"
		
		weaponObj = for obj in geometry where  (findItem weapon obj.name) != 0 collect obj 
		
		try (delete weaponObj ) catch()
		
		boneObjs = ($Bip001/...*) as array 
		meshObjs = for obj in geometry where obj.modifiers[#skin] != undefined and (findItem weapon obj.name) == 0 collect obj 
		objsExp = join boneObjs meshObjs
		
		if objsExp.count == 0 then 
		(
			messageBox "未找到可导出物体"
			return false 
		)
			
		
		if (doesFolderExist et_exportPath.text == false) then
		(
			cd = queryBox  "导出文件路径无效或不存在！是否尝试创建"
			
			if not cd then 
				return false 
			else 
			(
				makeDir et_exportPath.text 
				if not (isDirectoryWriteable et_exportPath.text) then 
				(
					messageBox "文件夹创建失败，请手动修改导出地址."
					shouldContinue = false
				)
					
			)
		)
		
		try
		(
			select objsExp
			exportfile exportPath #noPrompt selectedOnly:true using:FBXEXP
		) 
		catch
		(
			messagebox ("导出文件 " + (getFilenameFile maxFileName) + " 时出错！")
		)
		ShellLaunch  et_exportPath.text ""
	
	)
	
	
	on btExport rightclick do
	(
		headboneObjs = ($Bip001/...*) as array 
		bodyboneObjs = ($Bip001/...*) as array 		
		
		headObjs = for obj in geometry where obj.modifiers[#skin] != undefined and findstring obj.name "body" == undefined and (findItem weapon obj.name) == 0 and ( findstring obj.name "hair" != undefined or  findstring obj.name "head" != undefined or findstring obj.name "eyeShadows" != undefined  ) collect obj 

		bodyObjs = for obj in geometry where ( obj.modifiers[#skin] != undefined and findstring obj.name "body" != undefined ) or ( obj.modifiers[#skin] != undefined and (findItem weapon obj.name) == 0  and (findItem headObjs obj) == 0 ) collect obj 
			
			
		headEXP = join headboneObjs headObjs
		bodyEXP = join bodyboneObjs bodyObjs
		
		if (doesFolderExist et_exportPath.text == false) then
		(
			cd = queryBox  "导出文件路径无效或不存在！是否尝试创建"
			
			if not cd then 
				return false 
			else 
			(
				makeDir et_exportPath.text 
				if not (isDirectoryWriteable et_exportPath.text) then 
				(
					messageBox "文件夹创建失败，请手动修改导出地址."
				)
					
			)
		)
		
		
		fileName = getFilenameFile maxFileName
		
		if findString fileName "lod2_skin" != undefined then 
		(
			newfileName = replace fileName 12 10 ""
			try
			(
				dir = et_exportPath.text + "\\LOD"				
				if not (isDirectoryWriteable dir) then 
					makeDir dir
				select headEXP
				exportPath = dir + "\\" + newfileName + "_head.fbx"
				exportfile exportPath #noPrompt selectedOnly:true using:FBXEXP
				
				select bodyEXP
				exportPath = dir + "\\" + newfileName + "_body.fbx"
				exportfile exportPath #noPrompt selectedOnly:true using:FBXEXP
				
			) 
			catch
			(
				messagebox ("导出文件 " + file + " 时出错！")
			)
		)
		else 
		(
			newfileName = replace fileName 12 10 ""
			try
			(
				select headEXP
				exportPath = et_exportPath.text + "\\" + newfileName + "_head_h.fbx"
				exportfile exportPath #noPrompt selectedOnly:true using:FBXEXP
				
				select bodyEXP
				exportPath = et_exportPath.text + "\\" + newfileName + "_body_h.fbx"
				exportfile exportPath #noPrompt selectedOnly:true using:FBXEXP
				
			) 
			catch
			(
				messagebox ("导出文件 " + file + " 时出错！")
			)
		)
		
			
		ShellLaunch  et_exportPath.text ""
	)
	
	on btnSaveAnim pressed do   --左键批量保存动画
	(
		local shouldContinue = true

		if (trimleft etPath.text == "") then
		(
			messagebox "请填写Max文件路径！"
			shouldContinue = false
		)
		else if (doesFileExist etPath.text == false) then
		(
			messagebox "Max文件路径无效或不存在！"
			shouldContinue = false
		)
			
		if shouldContinue then
		(
			openPath = (etPath.text + "\\*.max")
			files = getFiles openPath recurse:true 
			
			if files.count == 0 then 
			(
				messagebox "未找到文件!"
			)
			else
			(
				for i = 1 to files.count do 
				(   
					local file = files[i] 
					
					if not (isMaxFile file) then 
					(
						print file
						continue
					)
						
					
					loadMAXFile file useFileUnits:true  quiet:true  allowPrompts:false
					
					localPath = (getdir #animations) +"\\"
					
					--保存旧文件动画
					try
					(
						biped_ctrl = $'Bip001 Head'.transform.controller
						bonesObj = for obj in Geometry where classOf obj == BoneGeometry collect obj 

						-------------------------标记-----------------------------
						spNodes = ($Animcraft_Master_GRP.../* ) as array   --*/取消显示影响			
						AC_ctrls = for obj in spNodes where findstring obj.name "_ctrl" != undefined  collect obj 
						join bonesObj AC_ctrls
						
						
						bip_file_name = localPath + ( getFilenameFile maxFileName) + ".bip"
						xaf_file_name = localPath+ ( getFilenameFile maxFileName) + ".xaf"

						biped.saveBipFile  biped_ctrl bip_file_name 
						animRange = animationRange
						
						append timeRanges animRange
						userAttributes = ""
						userValues = ""
-- 						保存bone骨骼和其它非biped物体的动画
-- 						LoadSaveAnimation.saveAnimation xaf_file_name bonesObj userAttributes userValues animatedTracks:on includeConstraints:on keyableTracks:off saveSegment:off 
						
						if i == files.count do
						(
							fileStreams = createFile (localPath +"timeRanges.txt")
							-- 将timeRanges的内容写入到文件中
							for range in timeRanges do
							(
								format "%\n"  (range as string)  to:fileStreams
							)
							-- 关闭文件流
							close fileStreams
							
							ShellLaunch  (getdir #animations) ""
						)

					)
					catch()
					
				)
				timeRanges = #()

			)
		)
	)
	
	on btnSaveAnim rightclick do 
	(
		try
		(
			--保存旧文件动画
			biped_ctrl = $'Bip001 Head'.transform.controller
			bonesObj = for obj in Geometry where classOf obj == BoneGeometry collect obj 
						
			-------------------------标记-----------------------------
			spNodes = ($Animcraft_Master_GRP.../* ) as array   --*/取消显示影响			
			AC_ctrls = for obj in spNodes where findstring obj.name "_ctrl" != undefined  collect obj 
			join bonesObj AC_ctrls
			
			localPath = (getdir #animations) +"\\"
			bip_file_name = localPath + ( getFilenameFile maxFileName) + ".bip"
			xaf_file_name = localPath+ ( getFilenameFile maxFileName) + ".xaf"
			biped.saveBipFile  biped_ctrl bip_file_name 
			animRange = animationRange
			append timeRanges animRange
			userAttributes = ""
			userValues = ""
			LoadSaveAnimation.saveAnimation xaf_file_name bonesObj userAttributes userValues animatedTracks:on includeConstraints:on keyableTracks:off saveSegment:off 
			
			fileStreams = createFile (localPath +"timeRanges.txt")
			-- 将timeRanges的内容写入到文件中
			for range in timeRanges do
			(
				format "%\n" ((getFilenameFile maxFileName) + "@" +  (range as string))  to:fileStreams
			)
			-- 关闭文件流
			close fileStreams
			timeRanges = #()
		)
		catch(messageBox "请检查骨骼是否存在")
		
		ShellLaunch  (getdir #animations) ""
	)
	
	on btnloadAnim pressed do   --左键批量加载动画
	(
		local shouldContinue = true

		if (trimleft etPath.text == "") then
		(
			messagebox "请填写Max文件路径！"
			shouldContinue = false
		)
		else if (doesFileExist etPath.text == false) then
		(
			messagebox "Max文件路径无效或不存在！"
			shouldContinue = false
		)
			
		if shouldContinue then
		(
			openPath = (etPath.text + "\\*.max")
			files = getFiles openPath recurse:true 
			timeRangeFile = (getdir #animations) + "\\timeRanges.txt"
			if files.count == 0 then 
			(
				messagebox "未找到文件!"
			)
			else
			(
				for i = 1 to files.count do 
				(   
					local file = files[i] 
					
					if findString file "skin" != undefined  then 
					(
						loadMAXFile file useFileUnits:true  quiet:true  allowPrompts:false
						
						--加载动画
						biped_ctrl = $'Bip001 Head'.transform.controller
						
-- 						取消掉非biped物体的动画加载
-- 						bonesObj = for obj in Geometry where classOf obj == BoneGeometry collect obj 
						-------------------------标记-----------------------------
-- 						spNodes = ($Animcraft_Master_GRP.../* ) as array   --*/取消显示影响			
-- 						AC_ctrls = for obj in spNodes where findstring obj.name "_ctrl" != undefined  collect obj 
-- 						join bonesObj AC_ctrls
							
						localPath = (getdir #animations) +"\\"
						bip_files = getFiles (localPath + "*.bip")
-- 						xaf_files = getFiles (localPath + "*.xaf")
						
						fileStreams = openFile timeRangeFile mode:"r"
						-- 检查文件是否成功打开
						if fileStreams != undefined then
						(
							for j = 1 to bip_files.count do 
							(
								biped.loadBipFile  biped_ctrl bip_files[j] 
-- 								LoadSaveAnimation.loadAnimation xaf_files[j] bonesObj relative:off insert:off insertTime:0f
								-- 如果文件已经读取到末尾，就跳出循环
								if eof fileStreams then
								(
								break
								)
								
								local line = (readLine fileStreams) 
								
								animationRange= execute line
								fileName = (getFilenameFile bip_files[j]) + ".max"
								saveMaxFile (maxFilePath + fileName) quiet:true saveAsVersion:2021
								
							)
							
							-- 关闭文件
							close fileStreams
						)
						else
						(
							print "无法打开文件"
						)
						
					)
					if i == files.count do
					(
						ShellLaunch  (getdir #animations) ""
						resetMaxFile #noPrompt
					)
					
				)						
			)
		)
	)
	
	on btnloadAnim rightclick do   --右键加载当前文件动画
	(
		try 
		(
			
			--加载动画
			biped_ctrl = $'Bip001 Head'.transform.controller
			bonesObj = for obj in Geometry where classOf obj == BoneGeometry collect obj   
			-------------------------标记-----------------------------
			spNodes = ($Animcraft_Master_GRP.../* ) as array   --*/取消显示影响			
			AC_ctrls = for obj in spNodes where findstring obj.name "_ctrl" != undefined  collect obj 
			join bonesObj AC_ctrls
				
			localPath = (getdir #animations) +"\\"
			bip_files = getFiles (localPath + "*.bip")
			xaf_files = getFiles (localPath + "*.xaf")
			timeRangeFile = (getdir #animations) + "\\timeRanges.txt"
			fileStreams = openFile timeRangeFile mode:"r"
			-- 检查文件是否成功打开
			line = ( FilterString (readLine fileStreams) "@")
			
			file_Name = line[1]
			if fileStreams != undefined then
			(
				for j = 1 to bip_files.count do 
				(
					if findString bip_files[j] file_Name != undefined then 
					(
						
						biped.loadBipFile  biped_ctrl bip_files[j]    
						LoadSaveAnimation.loadAnimation xaf_files[j] bonesObj relative:off insert:off insertTime:0f
						animationRange= execute line[2]
-- 						fileName = (getFilenameFile bip_files[j]) + ".max"
-- 						saveMaxFile (maxFilePath + fileName) quiet:true saveAsVersion:2021
						close fileStreams
-- 						resetMaxFile #noPrompt
					)
					
				
				)

			)
			else
			(
				print "无法打开文件"
			)
			ShellLaunch  (getdir #animations) ""
			
		)
		catch ()

		
		
		
	)

	
	
)


rollout modelView "资源查看"
(
	edittext edittext_filt "指定关键词" fieldWidth:165 height:20 labelOnTop:true readOnly:false  tooltip:"筛选出包含关键词的文件，关键词是<或者>的关系" across:4
	
	dropdownlist logicDropdown "逻辑关系" items:#("与", "或", "非") selection:1  width:50  offset:[35,0]
	
	edittext edittext_openFolderPath "max文件路径" fieldWidth:270 height:20 labelOnTop:true readOnly:false  tooltip:"文件根目录"  offset:[-45,0]
	button clearEdit "清空"   tooltip:"清楚路径及列表"  align:#right width:50   offset:[0,17]
	

	
	
	listbox maxList "max文件列表" items:#() selection:1 height:30  tooltip:"左键双击打开文件,右键单击打开选择的文件夹"
	
	
	button btn1 "XRef Scenes" width:100 across:3
	button btn2 "Delete" width:100
	button btn3 "相机尺寸" width:100
	
	button btnShowImage  "Author:HYW ，联系作者，反馈报错!"  width:560


	global maxfiles = #()
	global maxListItems = #()
	
	
	local baseXRef,newXRef

	-- 更新界面的尺寸
-- 	fn updateUI listSize = 
-- 	(
-- 		local baseHeight = 135 -- 初始对话框高度
-- 		local headerHeight = 91 -- 对话框头部控件的高度
-- 		local initialBtnY = 91 -- 假设的初始按钮位置
-- 		local initialAuthorY = 117 -- 假设的初始作者标签位置
-- 		local listItemHeight = 13 -- 每个列表项目的高度
-- 		local listBaseHeight = 19 -- 列表基础高度
-- 		maxList.height = if listSize == 0 then listBaseHeight else if listSize <= 30 then ((listItemHeight * (listSize - 1))  + listBaseHeight) else listItemHeight*29+19

-- 		if listSize == 0 then
-- 		(
-- 			modelView.height = baseHeight -- 当列表为空时，保持对话框初始高度
-- 			btn1.pos.y = initialBtnY -- 保持按钮初始位置
-- 			btn2.pos.y = initialBtnY
-- 			btn3.pos.y = initialBtnY
-- 			author.pos.y = initialAuthorY -- 保持作者标签初始位置
-- 		)
-- 		else
-- 		(
-- 			-- 当列表非空时的位置计算
-- 			local newBtnY = headerHeight + maxList.height - 19 -- 按钮位置
-- 			btn1.pos.y = newBtnY
-- 			btn2.pos.y = newBtnY
-- 			btn3.pos.y = newBtnY
-- 			author.pos.y = newBtnY + btn1.height + 5 -- 作者标签位置
-- 			modelView.height = author.pos.y + 18 -- 计算对话框高度
-- 		)
-- 	)



	-- 筛选文件，返回纯文件路径数组
	fn filterFiles files keywords logic = (
		local filtered = #()
		for file in files do (
			local filename = getFilenameFile file
			local shouldInclude = false
			case logic of (
				"与": (
					shouldInclude = true
					for keyword in keywords do (
						if findString filename keyword == undefined do (
							shouldInclude = false
							break
						)
					)
				)
				"或": (
					shouldInclude = false
					for keyword in keywords do (
						if findString filename keyword != undefined do (
							shouldInclude = true
							break
						)
					)
				)
				"非": (
					shouldInclude = true
					for keyword in keywords do (
						if findString filename keyword != undefined do (
							shouldInclude = false
							break
						)
					)
				)
			)
			if shouldInclude do append filtered file
		)
		filtered
	)
	
	
	
	fn performFiltering = (
		maxopenpath = edittext_openFolderPath.text + "\\" + "*.max"
		local allFiles = getFiles (trimLeft (trimRight maxopenpath)) recurse:true

		if allFiles != undefined then (
			local allwords = edittext_filt.text
			local keyWords = filterString allwords ", -"
			local logic = logicDropdown.selected as string

			-- 更新 maxfiles 以包含经过筛选的文件路径
			maxfiles = filterFiles allFiles keyWords logic

			-- 更新 maxList.items 以显示文件夹名称和文件名的组合字符串
			maxListItems = for file in maxfiles collect (
				local pathArray = filterString (getFilenamePath file) "\\"
				local folderName = pathArray[pathArray.count]
				local filename = getFilenameFile file
				folderName + "\t==>\t" + filename
			)

			maxList.items = maxListItems
-- 			updateUI maxListItems.count
		) else (
			messageBox "未找到文件。请检查路径。"
		)
	)

		
	
	
	
	
	
	on edittext_openFolderPath entered txt do 
	(
		performFiltering()
	)
	
	
	on edittext_filt changed txt do 
	(
		performFiltering()
	)
	
	on logicDropdown selected itm do 
	(
		performFiltering()
	)

	
	on maxList doubleClicked itm do 
	(
		try
			(
			loadMaxFile maxfiles[maxList.selection] useFileUnits:true  quiet:true 
			
			ViewPanelManager.SetActiveViewPanel 1
			viewport.setLayout #layout_1
			viewport.setType #view_persp_user
				
			disp = NitrousGraphicsManager.GetActiveViewportSetting() 
			disp.VisualStyleMode = #ConsistentColors 
				
			max tool zoomextents
			) 
		catch
			(
			messageBox "文件有病毒,请手动打开，杀毒后请另存文件！"
			ShellLaunch (getFilenamePath(maxfiles[maxList.selection])) ""
			)
	)
	
	on maxList rightClick itm do 
	(	
		n1 = maxList.selection
-- 		pathConfig.getCurrentProjectFolder()   知识点
		ShellLaunch (getFilenamePath(maxfiles[n1])) ""
	)
		
	on clearEdit pressed do 
	(
		
		edittext_openFolderPath.text = ""
		maxList.items = #()
-- 		updateUI 30
		
	)
	
	
	on btn1 pressed do 
	(
		try
		(
			local currentScene = maxFilePath + maxFileName
			local selectedFile = maxfiles[maxList.selection]
			
			format "当前场景: %\n选择文件: %\n" currentScene selectedFile
			
			if selectedFile != currentScene then
			(
				if baseXRef == undefined then
				(
					format "添加根XRef: %\n" selectedFile
					baseXRef = xrefs.addNewXRefFile selectedFile
				)
				else
				(
					format "添加嵌套XRef: %\n" selectedFile
					newXRef = xrefs.addNewXRefFile selectedFile root:baseXRef
				)
			)
			else
			(
				messageBox "无法将当前场景文件添加为外部引用。请选择不同的文件。"
			)
		)
		catch
		(
			messageBox ("出现错误: " + (getCurrentException()))
		)
	)

	
	on btn2 pressed do 
	(
		
		local xrefCount = xrefs.getXRefFileCount()   
		if xrefCount != 0 then 
		(
			if baseXRef != undefined  then 
				delete baseXRef 
			else
			(
				xrefs.deleteAllXRefs()
			)
		)
		else if xrefCount == 0 then 
		(
			max reset file 
		)
		
		baseXRef = undefined
	)
	
	on btn3 pressed do 
	(
		state = renderSceneDialog.isOpen() 
		if state then 
		(
			renderSceneDialog.close()
			renderWidth  = 1080
			renderHeight = 2340
			renderSceneDialog.open()
		)
		else 
		(
			renderWidth  = 1080
			renderHeight = 2340
		)
	)
	
	
	    on btnShowImage pressed do
    (

		
		if encodedString != undefined then 
		(
			-- 使用DotNet类将Base64字符串解码为字节数组
			byteArray = (dotnetclass "System.Convert").FromBase64String(encodedString)

			-- 创建一个新的内存流
			memoryStream = dotNetObject "System.IO.MemoryStream" byteArray

			-- 使用内存流创建Bitmap图片
			global decodedImage
			decodedImage = (dotnetobject "System.Drawing.Bitmap" memoryStream)

			try(DestroyDialog ::imageRollout) catch()

			rollout imageRollout "Image Viewer" width:600 height:600
			(
				dotNetControl picture "System.Windows.Forms.PictureBox" pos:[0,0] width:600 height:600

				on imageRollout open do
				(
					picture.SizeMode = (dotNetClass "System.Windows.Forms.PictureBoxSizeMode").StretchImage
					picture.Image = decodedImage
				)
			)
			createDialog imageRollout
		)
			

    )

	
)
 
 
try( closeRolloutFloater theBatchRollout )catch()

theBatchRollout = newRolloutFloater  "批量操作" 600 815 autoLayoutOnResize:true --scrollBar:#asNeeded

addRollout batchMerge theBatchRollout
 
addRollout animExport theBatchRollout

addRollout modelView theBatchRollout