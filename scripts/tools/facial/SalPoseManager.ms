
global SalPoseManager
(

try
(

local theMainMenu = menuMan.getMainMenuBar() --get the main menu bar
 local  theMenu=menuMan.findMenu "SalTools"
local theSubMenu=undefined
if theMenu == undefined do
	(
	theMenu= menuMan.createMenu "SalTools"
	theSubMenu = menuMan.createSubMenuItem "SalTools" theMenu --create a SubMenuItem
	theMainMenu.addItem theSubMenu (theMainMenu.numItems()+1)
	)
	
theMenu=menuMan.findMenu "SalTools"
-- menuMan.unRegisterMenu theMenu
menuMan.updateMenuBar() 
local theAction = menuMan.createActionItem "SalPoseManager" "SalTools" --create an ActionItem from the MacroScript
local Maxnum=theMenu.numItems()
local exists=false
for num=1 to Maxnum do
	(	
	mItem=theMenu.getItem num
	if mItem.getTitle() == "Sal Pose Manager" do
		exists=true
	)
if exists == false do
	(
	theMenu.addItem theAction (theMenu.numItems()+1) --add the ActionItem to the menu
	menuMan.updateMenuBar() --update the menu bar 
	)
)	
catch
	(
	if not hasinisetting  (getMaxIniFile()) "SalFacialPose" "FailedToMenu" do
		(
		messageBox "error was happened while creating the script menu, you can still add the script from\nCustomize>Customize User Interface>Category:SalTools>Drag SalPoseManager to max Command Panel" title:"can't create Saltools menu"
		theMenu=menuMan.findMenu "SalTools"
		menuMan.unRegisterMenu theMenu
		setinisetting (getMaxIniFile()) "SalFacialPose" "FailedToMenu" "True"
		--delinisetting (getMaxIniFile()) "SalFacialPose" "FailedToMenu"
		)
	)
if SalPoseManager!= undefined do
	DestroyDialog SalPoseManager
rcMenu SalPoseManagerMenu
(
subMenu "Help"
	(
	menuItem HelpBtn "See Help"
	menuItem AboutBtn "About"
	)
on HelpBtn picked do
		HiddenDOSCommand "explorer https://www.behance.net/gallery/16659737/Maxscript-Sal-Pose-Manager"
on AboutBtn picked do
	createDialog SalPoseManager.AboutSPM
)

global SalPoseManager
rollout SalPoseManager "±íÇéÔ¤Éè" width:512 height:509
(
	fn AnyObject obj = 
		true
	listbox CharacterListBox "Characters" pos:[8,8] width:112 height:6
	listbox SetListBox "Pose Groups" pos:[128,8] width:112 height:6 selection:1
	edittext DirectoryEt "" pos:[296,8] width:176 height:16
	label DirectoryLabel "Directory" pos:[248,8] width:48 height:24
	edittext newSetEt "" pos:[128,112] width:112 height:16
	edittext newCharacterEt "" pos:[8,112] width:112 height:16
	GroupBox PosesGroupBox "Poses" pos:[8,144] width:496 height:336
	listbox NamesEt "" pos:[296,32] width:80 height:4
	label lbl3 "Names" pos:[248,48] width:40 height:16
	bitmap poseBtn1 "Bitmap" pos:[16,160] width:112 height:88 
	bitmap poseBtn2 "Bitmap" pos:[136,160] width:112 height:88  
	bitmap poseBtn3 "Bitmap" pos:[256,160] width:112 height:88
	bitmap poseBtn4 "Bitmap" pos:[376,160] width:112 height:88
	bitmap poseBtn5 "Bitmap" pos:[16,264] width:112 height:88
	bitmap poseBtn6 "Bitmap" pos:[136,264] width:112 height:88
	bitmap poseBtn7 "Bitmap" pos:[256,264] width:112 height:88
	bitmap poseBtn8 "Bitmap" pos:[376,264] width:112 height:88
	bitmap poseBtn9 "Bitmap" pos:[16,368] width:112 height:88
	bitmap poseBtn10 "Bitmap" pos:[136,368] width:112 height:88
	bitmap poseBtn11 "Bitmap" pos:[256,368] width:112 height:88
	bitmap poseBtn12 "Bitmap" pos:[376,368] width:112 height:88
	button poseLabel1 "Pose" pos:[16,249] width:96 height:15
	button poseLabel2 "Pose" pos:[137,250] width:95 height:14
	button poseLabel3 "Pose" pos:[256,248] width:96 height:16
	button poseLabel4 "Pose" pos:[376,248] width:96 height:16
	button poseLabel5 "Pose" pos:[16,352] width:96 height:16
	button poseLabel6 "Pose" pos:[136,352] width:96 height:16
	button poseLabel7 "Pose" pos:[256,352] width:96 height:16
	button poseLabel8 "Pose" pos:[376,352] width:96 height:16
	button poseLabel9 "Pose" pos:[16,456] width:96 height:16
	button poseLabel10 "Pose" pos:[136,456] width:96 height:16
	button poseLabel11 "Pose" pos:[256,456] width:96 height:16
	button poseLabel12 "Pose" pos:[376,456] width:96 height:16
	button PoseOp1 "O" pos:[112,248] width:16 height:15 toolTip:"Pose Options"
	button PoseOp2 "O" pos:[232,248] width:16 height:15 toolTip:"Pose Options"
	button PoseOp3 "O" pos:[352,248] width:16 height:15 toolTip:"Pose Options"
	button PoseOp4 "O" pos:[472,248] width:16 height:15 toolTip:"Pose Options"
	button PoseOp5 "O" pos:[112,352] width:16 height:15 toolTip:"Pose Options"
	button PoseOp6 "O" pos:[232,352] width:16 height:15 toolTip:"Pose Options"
	button PoseOp7 "O" pos:[352,352] width:16 height:15 toolTip:"Pose Options"
	button PoseOp8 "O" pos:[472,352] width:16 height:15 toolTip:"Pose Options"
	button PoseOp9 "O" pos:[112,456] width:16 height:15 toolTip:"Pose Options"
	button PoseOp10 "O" pos:[232,456] width:16 height:15 toolTip:"Pose Options"
	button PoseOp11 "O" pos:[352,456] width:16 height:15 toolTip:"Pose Options"
	button PoseOp12 "O" pos:[472,456] width:16 height:15 toolTip:"Pose Options"
	button NameChangeBtn "Name Change" pos:[416,80] width:72 height:16
	button SetSelectionBtn "Set Selection" pos:[416,32] width:72 height:16
	edittext newPoseEt "" pos:[296,120] width:80 height:15
	label lbl81 "New Pose" pos:[248,120] width:48 height:16
	pickbutton ObjectSpaceBtn "Render Space" pos:[384,120] width:72 height:16 message:"" filter:AnyObject toolTip:""
	slider PageSld "" pos:[88,480] width:256 height:25 range:[1,1,1] type:#integer ticks:1
	button SelectBtn "Select" pos:[416,56] width:72 height:16
	button DefineMirror "Define Mirror" pos:[508,62] width:72 height:16 toolTip:"" visible:false
	button MirrorBtn "Mirror" pos:[509,88] width:70 height:16 visible:false
	button openDir "Open" pos:[472,8] width:32 height:16
	button GetBtn "Get" pos:[456,120] width:24 height:16
	button SetBtn "Set" pos:[480,120] width:24 height:16
	radiobuttons ViewportOrRender "" pos:[296,96] width:148 height:16 labels:#("Viewport", "Render") columns:2
	label lbl7 "Image" pos:[248,96] width:32 height:16
rollout AboutSPM "About Sal Pose Manager V1.0" width:272 height:96
(
	label lbl3 "Sal Pose Manager V1.0 by Salwan Badra" pos:[8,9] width:209 height:16
	label lbl4 "Thanks for using my scripts please report bugs and share my scripts if you liked them" pos:[8,56] width:272 height:32
	label lbl7 "Please Follow me at" pos:[8,40] width:96 height:16
	HyperLink lbl14 "Linkedin" pos:[104,40] width:40 height:16 color:(color 0 255 255) address:"www.linkedin.com/in/salwanbadra"
	label lbl15 "and" pos:[200,40] width:19 height:16
	HyperLink lbl18 "Facebook" pos:[152,40] width:46 height:16 color:(color 0 255 255) address:"www.facebook.com/salwanbadra"
	label lbl19 "," pos:[144,40] width:8 height:16
	HyperLink lbl20 "Twitter" pos:[224,40] width:40 height:16 color:(color 0 255 255) address:"www.twitter.com/salwanbadra"
	label lblss14 "For updates and more free scripts" pos:[8,24] width:216 height:16
)
fn initiate = 
(
	createDialog SalPoseManager menu: SalPoseManagerMenu

	if GetIniSetting (getMaxIniFile()) "SalPoseManagerMain" "Dir"=="" do
	(
		SetIniSetting (getMaxIniFile()) "SalPoseManagerMain" "Dir" "C:\\SPL"
	)
	if GetIniSetting (getMaxIniFile()) "SalPoseManagerDefault" "Character"=="" do
	(
		SetIniSetting (getMaxIniFile()) "SalPoseManagerDefault" "Character" (1 as string)
	)
	if GetIniSetting (getMaxIniFile()) "SalPoseManagerDefault" "Set"=="" do
	(
		SetIniSetting (getMaxIniFile()) "SalPoseManagerDefault" "Set" (1 as string)
	)
	if not hasIniSetting (getMaxIniFile()) "SalPoseManagerDefault" "ViewOrRender" do
		setIniSetting (getMaxIniFile()) "SalPoseManagerDefault" "ViewOrRender" (1 as string)
	SalPoseManager.ViewportOrRender.state=execute(getIniSetting (getMaxIniFile()) "SalPoseManagerDefault" "ViewOrRender")
	local SplDir=GetINISetting (getMaxIniFile()) "SalPoseManagerMain" "Dir" 
	SalPoseManager.DirectoryEt.text=SplDir
	makeDir SplDir
	SalPoseManager.refresh()
)
fn SelectSet=
(
	local folderDir=SalPoseManager.DirectoryEt.text+"\\"+SalPoseManager.CharacterListBox.items[SalPoseManager.CharacterListBox.selection]+"\\"+SalPoseManager.SetListBox.items[SalPoseManager.SetListBox.selection]
	local SelectionIni=folderDir+"\\Settings.ini"
	local SelectionList=execute (GetIniSetting SelectionIni "Selection" "Selection")
	SelectionList= for nam in SelectionList collect SalPoseManager.NameChange.Resolve nam
	if classOf SelectionList == Array then
	(
		clearSelection()
		local AvailableSelection=#()
		for i=1 to SelectionList.count do
		(
			if SelectionList[i] !="" do
			(
				local obj="$'"+SelectionList[i]+"'"
				local eObj=(execute obj )
				if eObj!=undefined do
				(
					append AvailableSelection eObj
				)
			)
		)
		if AvailableSelection.count >0 do
		(
			select AvailableSelection
		)
	)
	else
		messageBox "There is something wrong with your selection objects names, please delete the selection file or rename the object that cause the problem"  title:"error"
)
fn SaveUI =
(
	SetIniSetting (getMaxIniFile()) "SalPoseManagerMain" "Dir" SalPoseManager.DirectoryEt.text
	SetIniSetting (getMaxIniFile()) "SalPoseManagerDefault" "Character" (SalPoseManager.CharacterListBox.selection as string)
	SetIniSetting (getMaxIniFile()) "SalPoseManagerSet" (SalPoseManager.CharacterListBox.selection as string) (SalPoseManager.SetListBox.selection as string)
)
fn NewFolderNum folders =
(
n=0
for i=1 to folders.count do
	(
	fl=filterString folders[i] "_"
	val=try(execute(fl[1]))catch()
	if classOf val ==integer then
		n=val
	)
n +=1
n=n as string
if n.count==1 do
	n="0"+n
n=n+"_"	
)
fn makeNewCharacterFolder=
(
	--newCharacter="Esmer"
	local newCharacter=SalPoseManager.newCharacterEt.text
	local SplDir=SalPoseManager.DirectoryEt.text
	local dirs= GetDirectories (SplDir+"/*")
	if newCharacter != "" then
	(
		folders=for d in dirs collect (filterString d "\\")[(filterString d "\\").count]--d=dirs[1]
		n=NewFolderNum folders
		newCharacter=n+newCharacter
		makedir (SplDir+"\\"+newCharacter)
		SalPoseManager.newCharacterEt.text=""
		newCharacter
		items=append SalPoseManager.CharacterListBox.items newCharacter
		 SalPoseManager.CharacterListBox.items =items
		SalPoseManager.CharacterListBox.selection= ((SalPoseManager.CharacterListBox.items).count)
		SalPoseManager.fillSetListBox()
		SalPoseManager.fillPosesIntoUI()
		SalPoseManager.SaveUI()
	)
)
fn makeNewSetFolder=
(
	local newSet=SalPoseManager.newSetEt.text
	--newSet="newPose"
	if newSet != "" then
	(
		local SplDir=SalPoseManager.DirectoryEt.text
		local selectedSet=SalPoseManager.CharacterListBox.selected
		local dirs= GetDirectories (SplDir+"\\"+selectedSet+"/*")
		folders=for d in dirs collect (filterString d "\\")[(filterString d "\\").count]--d=dirs[1]
		n=SalPoseManager.NewFolderNum folders
		newSet=n+newSet
		makedir (SalPoseManager.DirectoryEt.text+"\\"+selectedSet+"\\"+newSet)
		folders=append folders  newSet
		SalPoseManager.SetListBox.Items=folders
		SalPoseManager.SetListBox.selection=folders.count
		--SalPoseManager.createNewPose()
		SalPoseManager.SaveUI()
		SalPoseManager.refresh()
		SalPoseManager.newSetEt.text=""
		--SalPoseManager.newPoseEt.entered(SalPoseManager.newSetEt.text)
		--SalPoseManager.newSetEt.text=""
	)
	/*
	folders=for d in dirs collect (filterString d "\\")[(filterString d "\\").count]--d=dirs[1]
		n=0
		for i=1 to folders.count do
		(
		fl=filterString folders[i] "_"
		val=try(execute(fl[1]))catch()
		if classOf val ==integer then
			n=val
		)
		n +=1
		n=n as string
		if n.count==1 do
			n="0"+n
		n=n+"_"
		newCharacter=n+newCharacter
		makedir (SplDir+"\\"+newCharacter)
		SalPoseManager.newCharacterEt.text=""
		newCharacter
		items=append SalPoseManager.CharacterListBox.items newCharacter
		 SalPoseManager.CharacterListBox.items =items
		SalPoseManager.CharacterListBox.selection= ((SalPoseManager.CharacterListBox.items).count)
		SalPoseManager.fillSetListBox()
		SalPoseManager.fillPosesIntoUI()
		SalPoseManager.SaveUI()*/
)
fn getTheLastFolders arrayName =
( 
	local returnResult=#()
	for s in arrayName do
	(
		s=filterString s "\\"
		returnResult+=#(s[s.count()])
	)
	return  returnResult
)
fn fileNameFromDir direc=
(
	folders=(filterString direc "\\")
	return (filterString folders[folders.count] ".")[1]
)
fn fillCharacterListBox=
(
	makeDir SalPoseManager.DirectoryEt.text
	local foldersDir=GetDirectories (SalPoseManager.DirectoryEt.text+"/*")
	if  foldersDir.count ==0 then
		makeDir (SalPoseManager.DirectoryEt.text+"\\00_Default")
	foldersDir=GetDirectories (SalPoseManager.DirectoryEt.text+"/*")
	local foldersNames=#()
	for f in foldersDir do
	(
		--f=foldersDir[1]
		local dirArray=filterString f "\\" 
		insertItem dirArray[dirArray.count] foldersNames (foldersNames.count +1)
	)
	SalPoseManager.CharacterListBox.items=foldersNames
	SalPoseManager.SetDefault("Character")
	
)
fn fillSetListBox=
(
	local folderDir=SalPoseManager.DirectoryEt.text+"\\"+SalPoseManager.CharacterListBox.items[SalPoseManager.CharacterListBox.selection]
	makeDir  folderDir
	local setsDir=GetDirectories (folderDir+"\*")
	if  setsDir.count ==0 then
		makeDir (folderDir+"\\00_Default")
	setsDir=GetDirectories (folderDir+"/*")
	local setsNames=#()
	for f in setsDir do
	(
		--f=foldersDir[1]
		local dirArray=filterString f "\\" 
		insertItem dirArray[dirArray.count] setsNames (setsNames.count +1)
	)
	SalPoseManager.SetListBox.items=setsNames
	SalPoseManager.SetDefault("Set")
	SalPoseManager.NameChange.fillNameChange()
)
fn createCameraFromView =
(
max vpt persp user
cams1=cameras as array
macros.run "Lights and Cameras" "StandardCamera_CreateFromView"
cams2=cameras as array
for i =1 to (cams2.count - 2) do
	deleteItem cams2 1
cams2
)
fn createNewPose takepose:true retake:false=
(
	SalPoseManager.DeleteFiles()
	if SalPoseManager.newPoseEt.text != "" do
	(
		--PoseName="10_6"
		local PoseName=SalPoseManager.newPoseEt.text
		local oldName=PoseName as string
		local folderDir=SalPoseManager.DirectoryEt.text+"\\"+SalPoseManager.CharacterListBox.items[SalPoseManager.CharacterListBox.selection]+"\\"+SalPoseManager.SetListBox.items[SalPoseManager.SetListBox.selection]
		files=getFiles (folderDir+"\\*.jpg")
		filesNams=#()
		for d in files do--d=files[1]
			(
			n=(filterString d "\\")
			n=filterString (n[n.count]) "."
			append filesNams (n[1])
			)
		n=SalPoseManager.NewFolderNum filesNams
		nname=(filterString PoseName "_")
		if nname.count>1 do
			(
			nt=try(execute nname[1])	catch (false)
				if nt!=false do
					(
					n=nt as string	
					if n.count==1 do
						n="0"+n+"_"
					PoseName=nname[2]
					)
			)
		PoseName=n+PoseName
		local ImageFileName=folderDir+"\\"+PoseName+".jpg"
		local PoseFileName=folderDir+"\\"+PoseName+".ini"
		if retake do
			(
			ImageFileName=folderDir+"\\"+oldName+".jpg"
			PoseFileName=folderDir+"\\"+oldName+".ini"
			)
		local SelectionIni=folderDir+"\\Settings.ini"
		local oldPoses
		if hasIniSetting SelectionIni "ObjectSpace" do
			(
			if hasIniSetting SelectionIni "ObjectSpace" "Object" do
				(
				local objTex=getIniSetting SelectionIni "ObjectSpace" "Object"
				obj=execute ("$'"+objTex+"'")
				cams=SalPoseManager.createCameraFromView()
				oldPoses=#(cams[1].position,cams[2].position)
				--format "pose2 %\n" oldPoses
				Poses=execute(getIniSetting SelectionIni "ObjectSpace" "Poses")
				if Poses != OK then
					(
					cams[1].parent=obj
					cams[2].parent=obj
					cams[1].pos.controller.value=Poses[1]
					cams[2].pos.controller.value=Poses[2]
					redrawViews()
					)
				delete cams[1]
				)
			)
		local notFoundObject=""
		if doesFileExist(SelectionIni) do
		(
			grpObjects=getINISetting SelectionIni "Selection" "Selection"
			grpObjects=execute(grpObjects) 
			for obj in grpObjects do
			(--obj=grpObjects[1]
				if obj != "" do
				(
					--execute ("$'"+obj+"'")
					if (execute ("$'"+obj+"'"))==undefined do
					(
						--print obj
						notFoundObject+=obj+" , "
					)
				)
			)
		)
		if (not doesFileExist(SelectionIni)) and selection.count==0 then
		(
			messageBox "Nothing is selected and selection set is empty" lable:"No Selection"
		)
		else if notFoundObject !="" then
		(
			messageBox ("Can't find the objects below, please fix selection, \n"+notFoundObject) lable:"No Selection"
		)
		else
		(
			local validSelection=True
			if not doesFileExist(SelectionIni) do
			(
				SalPoseManager.createSelectionFile()
				if (SalPoseManager.getSceneRepeatedItems selection).count>0 then
				(
					validSelection=False
				)
			)
			if validSelection then
			(
				--print ("before "+ ImageFileName+" "+getIniSetting (getMaxIniFile()) "SalPoseManagerDefault" "ViewOrRender")
				if getIniSetting (getMaxIniFile()) "SalPoseManagerDefault" "ViewOrRender" =="2" then
					(
					local ImageFile=render outputwidth:112 outputheight:88 outputfile:ImageFileName 
					close ImageFile
					)
				else
					SalPoseManager.grabViewport outputwidth:112 outputheight:60 outputfile:ImageFileName 
				if takepose do
				(
				local SelectionList=getINISetting SelectionIni "Selection" "Selection" 
				SelectionList=execute SelectionList
				if classOf SelectionList == Array do
					(
					for sel in SelectionList do
						(
						sel="$'"+sel+"'"-- sel=SelectionList[1]
						sel=execute sel
						if sel != undefined do
							(
								local LocalPosition=sel.transform.controller[1].value as string
								local LocalRotation=sel.transform.controller[2].value as string
								local LocalScale=sel.transform.controller[3].value as string
								--print sel
								setINISetting PoseFileName (sel.name+"_Trans") "LocalPosition" LocalPosition
								setINISetting PoseFileName (sel.name+"_Trans")  "LocalRotation" LocalRotation
								setINISetting PoseFileName (sel.name+"_Trans")  "LocalScale" LocalScale
							)
						)
					)
				)
			)
		)
		if oldPoses != undefined do
			(
			cams=SalPoseManager.createCameraFromView()
			cams[1].position=oldPoses[1]
			cams[2].position=oldPoses[2]
			redrawViews()
			delete cams[1]
			)
		SalPoseManager.newPoseEt.text=""
		SalPoseManager.refresh()
		forceCompleteRedraw
	)
)
fn grabViewport outputwidth:112 outputheight:88 outputfile:false =
	(
	if  outputfile !=false do
		(
		geo =hideByCategory.geometry
		sha=hideByCategory.shapes
		lig=hideByCategory.lights
		cam=hideByCategory.cameras
		hel=hideByCategory.helpers 
		spa=hideByCategory.spacewarps  
		par=hideByCategory.particles  
		bon=hideByCategory.bones 
			
		hideByCategory.geometry=false
		hideByCategory.shapes=true
		hideByCategory.lights=true
		hideByCategory.cameras=true
		hideByCategory.helpers =true
		hideByCategory.spacewarps= true 
		hideByCategory.particles  =true
		hideByCategory.bones =true
		completeredraw()
		redrawViews() 
		viewport.setGridVisibility
		anim_bmp = bitmap outputwidth outputheight filename:outputfile
		dib = gw.getViewportDib()
		copy dib anim_bmp
		save anim_bmp
		close anim_bmp
		gc()
		 hideByCategory.geometry=geo
		 hideByCategory.shapes=sha
		 hideByCategory.lights=lig
		 hideByCategory.cameras=cam
		 hideByCategory.helpers =hel
		 hideByCategory.spacewarps= spa 
		 hideByCategory.particles  =par
		 hideByCategory.bones =bon
		)
	outputfile
	)
fn deleteFolder type=
(
	local setFolder=SalPoseManager.DirectoryEt.text+"\\"+SalPoseManager.CharacterListBox.items[SalPoseManager.CharacterListBox.selection]+"\\"+SalPoseManager.SetListBox.items[SalPoseManager.SetListBox.selection]
	local characterFolder=SalPoseManager.DirectoryEt.text+"\\"+SalPoseManager.CharacterListBox.items[SalPoseManager.CharacterListBox.selection]
	if type=="Set" do
	(
		if (yesNoCancelBox "Are you sure you want to delete this Pose Group folder? \nit will delete the poses inside it, and selection info if existed")==#yes do
			HiddenDOSCommand ("rmdir \""+setFolder+"\" /Q /S")
	)
	if type=="Character" do
	(
		
		if (yesNoCancelBox "Are you sure you want to delete this Character folder? \nit will delete poses, selection info, and mirror defination if existed")==#yes do
		(
			items=SalPoseManager.CharacterListBox.Items
			if items.count > 1 do
				SalPoseManager.CharacterListBox.selection=items.count-1
			HiddenDOSCommand ("rmdir \""+characterFolder+"\"  /Q /S")
			
		)
	)
SalPoseManager.refresh()
)
fn insertObjDataToIni obj ini =
(
--obj=$
setINISetting ini (obj.name+"_Trans") "LocalPosition" (obj.position.controller.value as string)
setINISetting ini (obj.name+"_Trans") "LocalRotation" (obj.rotation.controller.value as string)
setINISetting ini (obj.name+"_Trans") "LocalScale" (obj.scale.controller.value as string)
)
fn createSelectionFile=
(
	local folderDir=SalPoseManager.DirectoryEt.text+"\\"+SalPoseManager.CharacterListBox.items[SalPoseManager.CharacterListBox.selection]+"\\"+SalPoseManager.SetListBox.items[SalPoseManager.SetListBox.selection]
	local SelectionIni=folderDir+"\\Settings.ini"
	local selectionList=#()
	local selectionLsStr="#("
	local validSelection=SalPoseManager.validateSelection()
	sels=selection as array
	for i=1 to sels.count do 
	(
		selectionLsStr+="\""+sels[i].name+"\""
		if i != sels.count do
			selectionLsStr+=","
	)
	selectionLsStr+=")"

	if validSelection then
	(			
		if doesFileExist(SelectionIni) and selection.count != 0 then
		(
			if (yesNoCancelBox "Are you sure you want to change your current selection? your old select will be removed" title:"Selection Changed")==#yes do
			(
				setINISetting  SelectionIni "Selection" "Selection" selectionLsStr
				inis=SalPoseManager.GetPoseGrpFiles type:#ini
				strSel=#()
				for obj in selection do
				(
				append strSel (obj.name+"_Trans") 
				for pini in inis do
					(
					if not hasinisetting pini (obj.name+"_Trans") do
						SalPoseManager.insertObjDataToIni obj pini	
					)
				)
				for ini in inis do --ini =inis[1]
				(
					stngs=getIniSetting ini 
					transs=#()
					for s in stngs  do
						if matchpattern s pattern:"*_Trans" do
							append transs s
					for stng in transs do --stng=stngs[1]
						(
						if (findItem strSel stng)==0 do
							delinisetting ini stng
						)
				)
			)
		)
		else if doesFileExist(SelectionIni) and selection.count == 0 then
		(
			if (yesNoCancelBox "Nothing is selected, do you want to delete your selection file?" title:"Delete file")==#yes do
			(
				deleteFile(SelectionIni)
			)
		)
		else if not doesFileExist(SelectionIni) and selection.count == 0 then
		(
			MessageBox "Nothing is selected, Please select something" title:" No Selection"
		)
		else if not doesFileExist(SelectionIni) and selection.count != 0 then
		(
			local ini=createFile(SelectionIni)
			close ini
			setINISetting  SelectionIni "Selection" "Selection" selectionLsStr
			/*
			setINISetting  SelectionIni "ObjectSpace" "Object" (selection[1].name as string)
			setINISetting  SelectionIni "ObjectSpace" "Poses" (SalPoseManager.GetCameraPos selection[1] as string)
			*/
		)
		SalPoseManager.EnableDisable()
	)
)
fn validateSelection=
(
	if selection.count >0 then
	(
		if (SalPoseManager.getSceneRepeatedItems selection).count>0 then
		(
			messageBox "There are repeated names in your selection,\n please rename them to unique names" title:"Repeated Names"
			return False
		)
		else
			return True
	)
	else
	(
		messageBox "Nothing is selected" 
		return False
	)
)
fn getSceneRepeatedItems arrayName =
(
	local selectedObjs= arrayName as array
	repeatedObjs=#()
	local sceneObjects =objects as array
	for obj in selectedObjs do
		--obj=selectedObjs[1]
		if (SalPoseManager.itemCountInArray sceneObjects obj).count >1 do
			append repeatedObjs obj
	--print repeatedObjs
	return repeatedObjs
)
fn itemCountInArray inputArray item=
(
	--inputArray=selection as array
	local inputArrayToRemove=inputArray as array
	--item=inputArray[1]
	result=#()
	if inputArrayToRemove.count !=0 do
		if classOf inputArrayToRemove[1] !=String do
			inputArrayToRemove=(for s in inputArrayToRemove collect s.name)
		if classOF item!=String do
			item=item.name
		while findItem  inputArrayToRemove item !=0 do
		(
			index=findItem  inputArrayToRemove item
			append result index
			deleteItem inputArrayToRemove index
			insertItem #RemovedItem inputArrayToRemove index 
		)
	return result
	
)
fn removeLastStringsOf inputString num =
(
objCount=inputString.count
objCount-=num
Obj=""
for i=1 to objCount do 
	Obj+=inputString[i]
return Obj
)
fn endswith str end=
(
	if end.count > str.count then
		return False
	else
		return lastInArray str end.count == end
)
fn setPoseCommand id actionType=
(
	--id=1
	--local actionType=0
	id=id as integer
	local folderDir=SalPoseManager.DirectoryEt.text+"\\"+SalPoseManager.CharacterListBox.items[SalPoseManager.CharacterListBox.selection]+"\\"+SalPoseManager.SetListBox.items[SalPoseManager.SetListBox.selection]
	local poseBtn=execute ("SalPoseManager.poseLabel"+id as string)
	local PoseName=poseBtn.caption
	local PoseFileName=folderDir+"\\"+PoseName+".ini"
	local SelectionIni=folderDir+"\\Settings.ini"
	local SelectionList=execute(getINISetting SelectionIni "Selection" "Selection")
	if classOf SelectionList== Array do
	(
		if actionType==7 do
		(-- retake image 
			PoseName=SalPoseManager.searchAndReplaceString SalPoseManager.PoseOptions.PoseName.text "Name: " ""
			SalPoseManager.newPoseEt.text=PoseName
			SalPoseManager.createNewPose takepose:false retake:true
			destroyDialog SalPoseManager.PoseOptions
		)
		if actionType==0 do
		(--create option dialoge
		createDialog SalPoseManager.PoseOptions()
		SalPoseManager.PoseOptions.PoseName.text="Name: "+poseBtn.caption
		SalPoseManager.PoseOptions.RenamePoseEt.text=poseBtn.caption
		SalPoseManager.PoseOptions.ID.range=[0,100,id]
		)
		if actionType==6 do
		(-- check data
		
		hiddenDosCommand("\""+PoseFileName+"\"")
		destroyDialog SalPoseManager.PoseOptions
		)
		if actionType==5 do
		(--rename pose
		newName=SalPoseManager.PoseOptions.RenamePoseEt.text
		if doesFileExist(PoseFileName) do
			(
			local oldName=(filterString PoseFileName ".")[1]
			oldName=filterString oldName "\\" 
			oldName=oldName[oldName.count]
			local newFileName= newName+".ini"
			hiddenDosCommand("rename \""+PoseFileName+"\" \""+newFileName+"\"")
			local oldImageFileName=SalPoseManager.SearchAndReplaceString PoseFileName ".ini" ".jpg"
			local newImageFileName= newName+".jpg"
			if doesFileExist(oldImageFileName) do
				(
				hiddenDosCommand("rename \""+oldImageFileName+"\" \""+newImageFileName+"\"")
				)
			SalPoseManager.fillPosesIntoUI()
			destroyDialog SalPoseManager.PoseOptions
			)
		)
		if actionType==4 do
		(--select
			poseMembers=getINISetting PoseFileName
			local objList=#()
			for i=1 to poseMembers.count do
			(
				local obj=SalPoseManager.removeLastStringsOf poseMembers[i] 6
				appendIfUnique objList obj
			)
			MaxObjList=#()
			for i=3 to objList.count do
			(
				local MaxObj=execute("$'"+objList[i]+"'")
				if MaxObj !=undefined do
					append MaxObjList MaxObj
			)
			select MaxObjList
		)
		if actionType==3 do
		(--delete
			
			PoseName=SalPoseManager.searchAndReplaceString SalPoseManager.PoseOptions.PoseName.text "Name: " ""
			deleteFile (folderDir+"\\"+PoseName+".ini")
			deleteFile (folderDir+"\\"+PoseName+".jpg")
			SalPoseManager.fillPosesIntoUI()
			if SalPoseManager.PoseOptions != undefined do
				destroyDialog SalPoseManager.PoseOptions
		)
		if actionType==2 do
		(-- retake pose 
			PoseName=SalPoseManager.searchAndReplaceString SalPoseManager.PoseOptions.PoseName.text "Name: " ""
			SalPoseManager.newPoseEt.text=PoseName
			SalPoseManager.createNewPose  retake:true
			destroyDialog SalPoseManager.PoseOptions
		)
		if actionType==1 do
		(--create
			for sel in SelectionList do
			(
				--sel=SelectionList[1]
				obj=SalPoseManager.NameChange.Resolve sel
				--print sel
				obj = "$'"+obj+"'"
				obj=execute obj
				if obj != undefined do
				(
					local LocalPosition=getINISetting PoseFileName (sel+"_Trans") "LocalPosition" 
					local LocalRotation=execute (getINISetting PoseFileName (sel+"_Trans") "LocalRotation")
					local LocalScale=execute (getINISetting PoseFileName (sel+"_Trans") "LocalScale" )
					if LocalPosition !="" do
					(
						LocalPosition=execute LocalPosition
						if classOF LocalPosition == Point3 do
						(
							animate on
							(
								at time currentTime
								(
									obj.transform.controller[1].value=LocalPosition
									obj.transform.controller[2].value=LocalRotation
									obj.transform.controller[3].value=LocalScale
								)
							)
						)
					)
				)
			)
		)

	)	--print PoseFileName
	
)
fn refresh=
(
	SalPoseManager.fillCharacterListBox()
	SalPoseManager.fillSetListBox()
	SalPoseManager.fillPosesIntoUI()
	SalPoseManager.SaveUI()
)
fn SetDefault Mode=
(

	if Mode=="Set" then
	(
		local val=(getINISetting (getMaxIniFile()) "SalPoseManagerSet" (SalPoseManager.CharacterListBox.selection as string) ) as integer
		if val ==0 do
			val=1
		if val > SalPoseManager.SetListBox.items.count do
			val=SalPoseManager.SetListBox.items.count
		SalPoseManager.SetListBox.selection =val
	)
	else
	(
		local val=(getINISetting (getMaxIniFile()) "SalPoseManagerDefault" "Character") as integer
		if val ==0 do
			val=1
		if val > SalPoseManager.CharacterListBox.items.count do
			val=SalPoseManager.CharacterListBox.items.count
		SalPoseManager.CharacterListBox.selection =val
	)
)
fn GetCameraPos obj =--obj=$
(
if obj != undefined then
	(
	max vpt persp user
	cams1=cameras as array
	macros.run "Lights and Cameras" "StandardCamera_CreateFromView"
	cams2=cameras as array
	for i =1 to (cams2.count - 2) do
		deleteItem cams2 1
	cams2
	cams2[1].parent=obj
	cams2[2].parent=obj
	pos=cams2[1].pos.controller.value
	postarg=cams2[2].pos.controller.value
	delete cams2[1]
	return #(pos,postarg)
	)
else
	return false
)
fn SetCameraPos obj poses =  
(
-- obj=$	
-- poses=GetCameraPos obj
max vpt persp user
cams1=cameras as array
macros.run "Lights and Cameras" "StandardCamera_CreateFromView"
cams2=cameras as array
for i =1 to (cams2.count - 2) do
	deleteItem cams2 1
cams2
cams2[1].parent=obj
cams2[2].parent=obj
cams2[1].pos.controller.value=poses[1]
cams2[2].pos.controller.value=poses[2]
redrawViews() 
viewport.setCamera cams2[1]
max vpt persp user
delete cams2
)
fn searchAndReplaceString subjectStr searchStr replaceStr=
(
	local pos=findstring subjectStr searchStr
	if pos != undefined  then
		return (replace subjectStr pos (searchStr.count) replaceStr)
)
fn GetPoseGrpFiles type:#jpg=
(
	local folderDir=SalPoseManager.DirectoryEt.text+"\\"+SalPoseManager.CharacterListBox.items[SalPoseManager.CharacterListBox.selection]+"\\"+SalPoseManager.SetListBox.items[SalPoseManager.SetListBox.selection]
	local jpgs=getFiles (folderDir+"\\*.jpg")
	local valid=#()
	local inis=#()
	for j in jpgs do
		(
			--j=jpgs[1]
			local nj=substituteString j ".jpg" ".ini"
			if doesFileExist( nj) do
				(
				append valid j 
				append inis nj
				)
		)	
	if type== #jpg then
		return valid
	else if type== #ini do
		return inis
)
fn copyFileToTemp img =
(
--  img="D:\\1.jpg"
local spm=GetDir #temp+"\\SPMTempImg"
makeDir spm
local jpgs=getFiles (spm+"\\*.jpg")
local id=1
if jpgs.count > 0 do
(
jp=jpgs[jpgs.count]
local arr=filterString jp "_"
id=(filterString arr[arr.count] ".")[1] as integer
id+=1
)
timg=spm+"\\"+"Image_"+id as string +".jpg"
copyFile img timg
return timg
)
fn DeleteFiles=
(
local spm=GetDir #temp+"\\SPMTempImg"
makeDir spm
local jpgs=getFiles (spm+"\\*.jpg")
for j in jpgs do
	try 
		(
		deleteFile j
		)
	catch()
)
fn fillPosesIntoUI=
(
	SalPoseManager.DeleteFiles()
	SalPoseManager.PageSld.visible=false
	local jpgs=SalPoseManager.GetPoseGrpFiles()
	local pagesNumber=0
	
	 if jpgs.count>12 then
		(
		SalPoseManager.PageSld.visible=true
		)
	else
		(
		SalPoseManager.PageSld.value=1	
		)
	local icount=jpgs.count/12
	local icount=icount as float
	local fcount=jpgs.count/12 as float
	pagesNumber=icount as integer
	if fcount >icount do
		pagesNumber+=1
	
	local currentPage=SalPoseManager.PageSld.range[3] as integer
	SalPoseManager.PageSld.range=[1,pagesNumber,currentPage]
	for i=1 to 12 do
	(
		--i=1
		local j=i+(currentPage-1)*12
		--print pagesNumber
		local poseImage=execute ("SalPoseManager.poseBtn"+i as string)
		local poseBtn=execute ("SalPoseManager.poseLabel"+i as string)
		local PoseOp=execute ("SalPoseManager.PoseOp"+i as string)
		if not jpgs[j] == undefined then
		(
			local poseName
			local jp=jpgs[j]
			poseImage.fileName=jp
			--poseImage.fileName=jp
			poseName=fileNameFromDir(jpgs[j])
			poseBtn.caption=poseName
			poseBtn.visible=true
			poseImage.visible=true
			PoseOp.visible=true
		)
		else
		(
		poseBtn.visible=false
		poseImage.visible=false
		PoseOp.visible=false
		)
	)
	SalPoseManager.NameChange.fillNameChange()
	SalPoseManager.EnableDisable()
)
fn GetSetProp obj Prop getSet data=
(
--obj=$box003
--Prop="Position"
--getSet=#Get
--data=undefined	
--GetSetProp $box003 #Pos #X #Get undefined
	if Prop=="Scale" do
	(
		if getSet==#Get do
			return obj.transform.Controller[3].value
		if getSet==#Set do
			obj.transform.Controller[3].value=Data
	)
	if Prop=="Position" do
	(
		if (hasProperty obj.transform.Controller[1] "X_Position") then
		(
			if getSet==#Get do
			(
				local X=obj.transform.Controller[1].X_Position
				local Y=obj.transform.Controller[1].Y_Position
				local Z=obj.transform.Controller[1].Z_Position
				return [X,Y,Z]
			)
			if getSet==#Set do
			(
				obj.transform.Controller[1].X_Position=data[1]
				obj.transform.Controller[1].Y_Position=data[2]
				obj.transform.Controller[1].Z_Position=data[3]
			)
		)
		if (hasProperty obj.transform.Controller[1] "Zero_Pos_XYZ") do
		(
			if getSet==#Get do
			(
				local X=obj.transform.Controller[1].Zero_Pos_XYZ.X_Position
				local Y=obj.transform.Controller[1].Zero_Pos_XYZ.Y_Position
				local Z=obj.transform.Controller[1].Zero_Pos_XYZ.Z_Position
				return [X,Y,Z]
			)
			if getSet==#Set do
			(
				obj.transform.Controller[1].Zero_Pos_XYZ.X_Position=data[1]
				obj.transform.Controller[1].Zero_Pos_XYZ.Y_Position=data[2]
				obj.transform.Controller[1].Zero_Pos_XYZ.Z_Position=data[3]
			)
		)
	)
	if Prop=="Rotation" do
	(
		if (hasProperty obj.transform.Controller[2] "X_Rotation") do
		(
			if getSet==#Get do
			(
				local X=obj.transform.Controller[2].X_Rotation
				local Y=obj.transform.Controller[2].Y_Rotation
				local Z=obj.transform.Controller[2].Z_Rotation
				return [X,Y,Z]
			)
			if getSet==#Set do
			(
				obj.transform.Controller[2].X_Rotation=data[1]
				obj.transform.Controller[2].Y_Rotation=data[2]
				obj.transform.Controller[2].Z_Rotation=data[3]
			)
		)
		if (hasProperty obj.transform.Controller[2] "Keyframe_XYZ") then
		(
			if getSet==#Get do
			(
				local X=obj.transform.Controller[2].Keyframe_XYZ.X_Rotation
				local Y=obj.transform.Controller[2].Keyframe_XYZ.Y_Rotation
				local Z=obj.transform.Controller[2].Keyframe_XYZ.Z_Rotation
				return [X,Y,Z]
			)
			if getSet==#Set do
			(
				obj.transform.Controller[2].Keyframe_XYZ.X_Rotation=data[1]
				obj.transform.Controller[2].Keyframe_XYZ.Y_Rotation=data[2]
				obj.transform.Controller[2].Keyframe_XYZ.Z_Rotation=data[3]
			)
		)
	)
)
fn mirrorCurrent=
(
	local MirrorSettings=SalPoseManager.DirectoryEt.text+"\\"+SalPoseManager.CharacterListBox.items[SalPoseManager.CharacterListBox.selection]+"\\MirrorSettings.ini"	
	local folderDir=SalPoseManager.DirectoryEt.text+"\\"+SalPoseManager.CharacterListBox.items[SalPoseManager.CharacterListBox.selection]+"\\"+SalPoseManager.SetListBox.items[SalPoseManager.SetListBox.selection]
	local SelectionIni=folderDir+"\\Settings.ini"
	local SelectionList=execute(getINISetting SelectionIni "Selection" "Selection")
	if doesFileExist(SelectionIni) then
	(
		if doesFileExist(MirrorSettings) then
		(
			if classOf SelectionList ==Array do
			(
				for ObjStr in SelectionList do
				(
					--ObjStr=SelectionList[1]
					local Obj=execute("$'"+ObjStr+"'")
					if Obj != undefined do
					(
						local MirrorArray=getINISetting MirrorSettings "MirrorSettings"
						res=findItem MirrorArray ObjStr
						if res != 0 do
						(
							local mirrorSetingArray= execute(getIniSetting MirrorSettings "MirrorSettings" MirrorArray[res])
							local refObjStr=mirrorSetingArray[1]
							local multiArray=mirrorSetingArray[2]
							local refObj=execute ("$'"+refObjStr+"'")
							if refObj != undefined do
							(
								local posx=Obj.transform.controller[1].value[1]*multiArray[1]
								local posy=Obj.transform.controller[1].value[2]*multiArray[2]
								local posz=Obj.transform.controller[1].value[3]*multiArray[3]
								
								local rotx=Obj.transform.controller[2].value.X*multiArray[4]
								local roty=Obj.transform.controller[2].value.Y*multiArray[5]
								local rotz=Obj.transform.controller[2].value.Z*multiArray[6]
								
								local refPosx=refObj.transform.controller[1].value[1]*multiArray[1]
								local refPosy=refObj.transform.controller[1].value[2]*multiArray[2]
								local refPosz=refObj.transform.controller[1].value[3]*multiArray[3]
								
								local refRotx=refObj.transform.controller[2].value.X*multiArray[4]
								local refRoty=refObj.transform.controller[2].value.Y*multiArray[5]
								local refRotz=refObj.transform.controller[2].value.Z*multiArray[6]
								
								local LocalScale=Obj.transform.controller[3].value as point3
								local refLocalScale=refObj.transform.controller[3].value as point3
								
								Obj.transform.controller[1].value=[refPosx,refPosy,refPosz]
								Obj.transform.controller[2].value.X=refRotx
								Obj.transform.controller[2].value.Y=refRoty
								Obj.transform.controller[2].value.z=refRotz
								Obj.transform.controller[3].value=refLocalScale
								
								refObj.transform.controller[1].value=[posx,posy,posz]
								refObj.transform.controller[2].value.X=rotx
								refObj.transform.controller[2].value.Y=roty
								refObj.transform.controller[2].value.Z=rotz
								refObj.transform.controller[3].value=LocalScale
								
								remObj=(findItem SelectionList refObjStr)
								remRefObj=(findItem SelectionList ObjStr)
								if remObj != 0 do
									deleteItem SelectionList remObj
								if remRefObj !=0 do
									deleteItem SelectionList remRefObj
							)
						)
					)
				)
			)
		)
		else
		(
		messageBox "There is no saved selection, please create mirror defination" title:"Create Mirror Defination"
		)
	)
	else
	(
	messageBox "There is no saved selection, please Set Selection for this set" title:"Set Selection"	
	)
)	
fn EnableDisable=
(
	local folderDir=SalPoseManager.DirectoryEt.text+"\\"+SalPoseManager.CharacterListBox.items[SalPoseManager.CharacterListBox.selection]+"\\"+SalPoseManager.SetListBox.items[SalPoseManager.SetListBox.selection]
	local SelectionFile=folderDir+"\\Settings.ini"
	local MirrorSettings=SalPoseManager.DirectoryEt.text+"\\"+SalPoseManager.CharacterListBox.items[SalPoseManager.CharacterListBox.selection]+"\\MirrorSettings.ini"
	if doesFileExist(SelectionFile) then
		(
		SalPoseManager.SelectBtn.enabled=true
		SalPoseManager.SetSelectionBtn.enabled=true
		SalPoseManager.GetBtn.enabled=true
		SalPoseManager.SetBtn.enabled=true
		SalPoseManager.ObjectSpaceBtn.enabled=true
		SalPoseManager.NameChangeBtn.enabled=true
		if hasiniSetting SelectionFile "ObjectSpace" "Object" then
			(
			SalPoseManager.ObjectSpaceBtn.caption=getiniSetting SelectionFile "ObjectSpace" "Object"
			SalPoseManager.GetBtn.enabled=true
			)
		else
			(
			SalPoseManager.ObjectSpaceBtn.caption="Render Space"
			SalPoseManager.ObjectSpaceBtn.tooltip="No object specified"
			SalPoseManager.GetBtn.enabled=false
			)
		if SalPoseManager.NamesEt.selected =="Default" then
			(
			SalPoseManager.newSetEt.enabled=true
			SalPoseManager.SetSelectionBtn.enabled=true
			SalPoseManager.newPoseEt.enabled=true
			SalPoseManager.lbl81.enabled=true
			SalPoseManager.GetBtn.enabled=true
			SalPoseManager.SetBtn.enabled=true
			SalPoseManager.ObjectSpaceBtn.enabled=true
			SalPoseManager.PoseOp1.enabled=true
			SalPoseManager.PoseOp2.enabled=true
			SalPoseManager.PoseOp3.enabled=true
			SalPoseManager.PoseOp4.enabled=true
			SalPoseManager.PoseOp5.enabled=true
			SalPoseManager.PoseOp6.enabled=true
			SalPoseManager.PoseOp7.enabled=true
			SalPoseManager.PoseOp8.enabled=true
			SalPoseManager.PoseOp9.enabled=true
			SalPoseManager.PoseOp10.enabled=true
			SalPoseManager.PoseOp11.enabled=true
			SalPoseManager.PoseOp12.enabled=true
			)
		else
			(
			SalPoseManager.newSetEt.enabled=false
			SalPoseManager.SetSelectionBtn.enabled=false
			SalPoseManager.newPoseEt.enabled=false
			SalPoseManager.lbl81.enabled=false
			SalPoseManager.GetBtn.enabled=false
			SalPoseManager.SetBtn.enabled=false
			SalPoseManager.ObjectSpaceBtn.enabled=false
			SalPoseManager.PoseOp1.enabled=false
			SalPoseManager.PoseOp2.enabled=false
			SalPoseManager.PoseOp3.enabled=false
			SalPoseManager.PoseOp4.enabled=false
			SalPoseManager.PoseOp5.enabled=false
			SalPoseManager.PoseOp6.enabled=false
			SalPoseManager.PoseOp7.enabled=false
			SalPoseManager.PoseOp8.enabled=false
			SalPoseManager.PoseOp9.enabled=false
			SalPoseManager.PoseOp10.enabled=false
			SalPoseManager.PoseOp11.enabled=false
			SalPoseManager.PoseOp12.enabled=false
			)
		)
	else
		(
		SalPoseManager.SelectBtn.enabled=false
		SalPoseManager.SetSelectionBtn.enabled=false
		SalPoseManager.GetBtn.enabled=false
		SalPoseManager.SetBtn.enabled=false
		SalPoseManager.ObjectSpaceBtn.enabled=false
		SalPoseManager.NameChangeBtn.enabled=false
		)
	/*
	if doesFileExist(MirrorSettings) then
		(
		--SalPoseManagerMenu.MirrorBtn.enabled=true
		SalPoseManager.MirrorBtn.enabled=true
		)
	else
		(
		--SalPoseManagerMenu.MirrorBtn.enabled=false
		SalPoseManager.MirrorBtn.enabled=false
		)
	
	--deleteFile MirrorSettings
	--deleteFile SelectionFile
	--if	
	--SalPoseManager.EnableDisable()
	*/
		
		
)  --SalPoseManager.EnableDisable()
fn postNameChange inputStr=
(
	local folderDir=SalPoseManager.DirectoryEt.text+"\\"+SalPoseManager.CharacterListBox.items[SalPoseManager.CharacterListBox.selection]
	local nameIni=folderDir+"\\Names.ini"
	local currentName=getIniSetting (getMaxIniFile()) "SalPoseManagerCurrentNameFix" currentCharacter
	if not doesFileExist(nameIni) then
		return inputStr
	else
	(
		names=getIniSetting nameIni
		local sel=1
		for i=1 to names.count do
			if (names[i] )==currentName do
				sel=i
		selected=names[sel]
		SalPoseManager.NameChange.RemoveS.value= getIniSetting nameIni selected "RemoveFirst"  as integer
		SalPoseManager.NameChange.PrefixEt.text=getIniSetting nameIni selected "Prefix"
		SalPoseManager.NameChange.SearchEt.text=getIniSetting nameIni selected "Search"
		SalPoseManager.NameChange.ReplaceEt.text=getIniSetting nameIni selected "Replace" 
		SalPoseManager.NameChange.RemoveS.value=getIniSetting nameIni selected "RemoveFirst" as integer
		SalPoseManager.NameChange.PrefixEt.text  =getIniSetting nameIni selected "Prefix" 
		SalPoseManager.NameChange.RemoveL.value=getIniSetting nameIni selected "RemoveLast" as integer
		SalPoseManager.NameChange.SuffixEt.text   =getIniSetting nameIni selected "Suffix"
	)
)
rollout NameChange "Name Change" width:327 height:189
(
	listbox NameListLb "Name List" pos:[8,16] width:96 height:6
	edittext NewEt "Create New  " pos:[80,8] width:136 height:17
	edittext NameEt "Name" pos:[112,32] width:104 height:17
	spinner RemoveS "Del First" pos:[287,-13] width:84 height:16 type:#integer visible:false
	edittext PrefixEt "Prefix  " pos:[251,-16] width:104 height:17 visible:false
	label NameL1 "None" pos:[8,136] width:248 height:24
	label NameL2 "None" pos:[8,160] width:248 height:24
	label NameStat1 "Not Found" pos:[256,136] width:56 height:24
	label NameStat2 "Not Found" pos:[256,160] width:56 height:24
	edittext SearchEt "Search" pos:[116,58] width:100 height:17
	edittext ReplaceEt "Replace" pos:[110,83] width:104 height:17
	spinner RemoveL "Del Last" pos:[295,-14] width:81 height:16 range:[0,100,0] type:#integer visible:false
	edittext SuffixEt "Suffix" pos:[280,-8] width:96 height:17 visible:false
	listBox SelectionEt "Current Selection" pos:[224,16] width:98 height:6
	fn fillNameChange=
	(
		local folderDir=SalPoseManager.DirectoryEt.text+"\\"+SalPoseManager.CharacterListBox.items[SalPoseManager.CharacterListBox.selection]
		local nameIni=folderDir+"\\Names.ini"
		local currentCharacter=SalPoseManager.CharacterListBox.items[SalPoseManager.CharacterListBox.selection]
		currentName=getIniSetting (getMaxIniFile()) "SalPoseManagerCurrentNameFix" currentCharacter
		if not doesFileExist(nameIni) do
			(
			local fileS=createFile nameIni
			close(fileS)
			setIniSetting nameIni "Default" "Search" ""
			setIniSetting nameIni "Default" "Replace" ""
			--setIniSetting nameIni "Default" "RemoveFirst" "0"
			--setIniSetting nameIni "Default" "Prefix" ""
			--setIniSetting nameIni "Default" "RemoveLast" "0"
			--setIniSetting nameIni "Default" "Suffix" ""
			)
		local names=getIniSetting nameIni
		SalPoseManager.NameChange.NameListLb.items=names
		SalPoseManager.NamesEt.items=names
		local sel=1
		for i=1 to names.count do
			if (names[i] )==currentName do
				sel=i
		local selected=names[sel]
		SalPoseManager.NameChange.NameListLb.selection=sel
		SalPoseManager.NamesEt.selection=sel
		items=SalPoseManager.NameChange.NameListLb.items
		SalPoseManager.NameChange.NameEt.text=selected
		SalPoseManager.NameChange.RemoveS.value= getIniSetting nameIni selected "RemoveFirst"  as integer
		SalPoseManager.NameChange.PrefixEt.text=getIniSetting nameIni selected "Prefix"
		SalPoseManager.NameChange.SearchEt.text=getIniSetting nameIni selected "Search"
		SalPoseManager.NameChange.ReplaceEt.text=getIniSetting nameIni selected "Replace" 
		SalPoseManager.NameChange.RemoveS.value=getIniSetting nameIni selected "RemoveFirst" as integer
		SalPoseManager.NameChange.PrefixEt.text  =getIniSetting nameIni selected "Prefix" 
		SalPoseManager.NameChange.RemoveL.value=getIniSetting nameIni selected "RemoveLast" as integer
		SalPoseManager.NameChange.SuffixEt.text   =getIniSetting nameIni selected "Suffix"
		if selected=="Default" then
		(
			SalPoseManager.NameChange.RemoveS.enabled=False
			SalPoseManager.NameChange.PrefixEt.enabled=False
			SalPoseManager.NameChange.SearchEt.enabled=False
			SalPoseManager.NameChange.ReplaceEt.enabled=False
			SalPoseManager.NameChange.RemoveL.enabled=False
			SalPoseManager.NameChange.SuffixEt.enabled=False
			SalPoseManager.NameChange.NameEt.text="Default"
			SalPoseManager.NameChange.NameEt.enabled=False
		)
		else
		(
			SalPoseManager.NameChange.RemoveS.enabled=True
			SalPoseManager.NameChange.PrefixEt.enabled=True
			SalPoseManager.NameChange.SearchEt.enabled=True
			SalPoseManager.NameChange.ReplaceEt.enabled=True
			SalPoseManager.NameChange.RemoveL.enabled=True
			SalPoseManager.NameChange.SuffixEt.enabled=True
			SalPoseManager.NameChange.NameEt.enabled=True
		)

	local folderDir=SalPoseManager.DirectoryEt.text+"\\"+SalPoseManager.CharacterListBox.items[SalPoseManager.CharacterListBox.selection]+"\\"+SalPoseManager.SetListBox.items[SalPoseManager.SetListBox.selection]
	local SelectionIni=folderDir+"\\Settings.ini"
	local SelectionList=execute (GetIniSetting SelectionIni "Selection" "Selection")
	if SelectionList == OK do
		SelectionList=#()
	SalPoseManager.NameChange.SelectionEt.items=SelectionList
	
	if SalPoseManager.NameChange.inDialog do
		(
		local orginalStr=SalPoseManager.NameChange.SelectionEt.selected
		local ResolvedStr=SalPoseManager.NameChange.Resolve orginalStr
		SalPoseManager.NameChange.NameL1.text="Orginal: "+orginalStr
		SalPoseManager.NameChange.NameL2.text="Resolved: "+ResolvedStr
		local orginal=execute("$'"+orginalStr+"'")
		local Resolved=execute("$'"+ResolvedStr+"'")
		if orginal != undefined then
			SalPoseManager.NameChange.NameStat1.text="Exists"
		else 
			SalPoseManager.NameChange.NameStat1.text="Not Found"
		if Resolved != undefined then
			SalPoseManager.NameChange.NameStat2.text="Exists"
		else 
			SalPoseManager.NameChange.NameStat2.text="Not Found"
		)  
	)
	fn setCurrentNaming outside:false=
	(
		local currentCharacter=SalPoseManager.CharacterListBox.items[SalPoseManager.CharacterListBox.selection]
		local selected=SalPoseManager.NameChange.NameListLb.items[SalPoseManager.NameChange.NameListLb.selection]
		if outside do
			selected=SalPoseManager.NamesEt.items[SalPoseManager.NamesEt.selection]
		setIniSetting (getMaxIniFile()) "SalPoseManagerCurrentNameFix" currentCharacter selected
	)
	fn saveNameChange=
	(
		local folderDir=SalPoseManager.DirectoryEt.text+"\\"+SalPoseManager.CharacterListBox.items[SalPoseManager.CharacterListBox.selection]
		local nameIni=folderDir+"\\Names.ini"
		local nameEdit=SalPoseManager.NameChange.NameEt.text
		nameEdit=SalPoseManager.searchAndReplaceString nameEdit  " "  "_"
		if nameEdit ==undefined do nameEdit=SalPoseManager.NameChange.NameEt.text
			
		local selected=SalPoseManager.NameChange.NameListLb.selected
		local currentCharacter=SalPoseManager.CharacterListBox.items[SalPoseManager.CharacterListBox.selection] 
		if selected != "Default" then 
		( 
			delIniSetting nameIni selected 
		)
		
		if nameEdit != ""then 
		(
			setIniSetting nameIni  nameEdit "RemoveFirst" (SalPoseManager.NameChange.RemoveS.value as string)
			setIniSetting nameIni  nameEdit "Prefix" (SalPoseManager.NameChange.PrefixEt.text as string)
			setIniSetting nameIni  nameEdit "Search" (SalPoseManager.NameChange.SearchEt.text as string)
			setIniSetting nameIni  nameEdit "Replace" (SalPoseManager.NameChange.ReplaceEt.text as string)
			setIniSetting nameIni  nameEdit "RemoveLast" (SalPoseManager.NameChange.RemoveL.value as string)
			setIniSetting nameIni  nameEdit "Suffix" (SalPoseManager.NameChange.SuffixEt.text as string)
		)
	)
	on NameListLb selected index do
	(
		SalPoseManager.NameChange.setCurrentNaming()
		SalPoseManager.NameChange.fillNameChange()
		SalPoseManager.EnableDisable()
	)
	on NewEt entered tex do
	(
		--tex="newName"
		SalPoseManager.NameChange.NewEt.text=""
		items=SalPoseManager.NameChange.NameListLb.items
		append items tex
		SalPoseManager.NameChange.NameListLb.items=items
		SalPoseManager.NameChange.NameListLb.selection=items.count
		SalPoseManager.NameChange.NameEt.text=tex
		SalPoseManager.NameChange.saveNameChange()
		SalPoseManager.NameChange.setCurrentNaming()
		SalPoseManager.NameChange.fillNameChange()
		SalPoseManager.EnableDisable()
	)
	on NameEt entered tex do
	(
		SalPoseManager.NameChange.saveNameChange()
		SalPoseManager.NameChange.fillNameChange()
		items=SalPoseManager.NameChange.NameListLb.items
		SalPoseManager.NameChange.NameListLb.selection=items.count
		SalPoseManager.NameChange.setCurrentNaming()
		SalPoseManager.NameChange.fillNameChange()
	)
	on RemoveS changed val do
		SalPoseManager.NameChange.saveNameChange()
	on PrefixEt entered tex do
		SalPoseManager.NameChange.saveNameChange()
	on SearchEt entered tex do
		(
		SalPoseManager.NameChange.saveNameChange()
		SalPoseManager.NameChange.fillNameChange()
		)
	on ReplaceEt entered tex do
		(
		SalPoseManager.NameChange.saveNameChange()
		SalPoseManager.NameChange.fillNameChange()
		)
	on SelectionEt selected sel do
		SalPoseManager.NameChange.fillNameChange()
	on RemoveL changed val do
		SalPoseManager.NameChange.saveNameChange()
	on SuffixEt entered tex do
		SalPoseManager.NameChange.saveNameChange()
	fn Resolve nam=
		(
		--nam="Box002"
		if nam ==undefined do
			nam=""
		local folderDir=SalPoseManager.DirectoryEt.text+"\\"+SalPoseManager.CharacterListBox.items[SalPoseManager.CharacterListBox.selection]
		local nameIni=folderDir+"\\Names.ini"
		local currentCharacter=SalPoseManager.CharacterListBox.items[SalPoseManager.CharacterListBox.selection]
		currentName=getIniSetting (getMaxIniFile()) "SalPoseManagerCurrentNameFix" currentCharacter
		search=getIniSetting nameIni currentName "Search" 
		replac=getIniSetting nameIni currentName "Replace" 
		return (substituteString nam search replac)
		)
)
rollout MirrorDefination "Mirror Definination" width:304 height:208
(
	listbox SelectionList "Selection And Mirror" pos:[8,8] width:288 height:9
	button AddSelected "Add Selected" pos:[8,152] width:88 height:24
	button RemoveMirroring "Remove Mirroring" pos:[104,152] width:96 height:24
	pickbutton PickMirror "Pick Mirror" pos:[208,152] width:88 height:24
	checkbutton posx "PosX" pos:[64,184] width:32 height:16 checked:true
	checkbutton posz "PosZ" pos:[144,184] width:32 height:16
	checkbutton posy "PosY" pos:[104,184] width:32 height:16
	checkbutton roty "RotY" pos:[224,184] width:32 height:16 checked:true
	checkbutton rotx "RotX" pos:[184,184] width:32 height:16
	checkbutton rotz "RotZ" pos:[264,184] width:32 height:16
	label lbl1 "-1 X to" pos:[16,184] width:40 height:16
	fn Create=
	(
		local MirrorSettings=SalPoseManager.DirectoryEt.text+"\\"+SalPoseManager.CharacterListBox.items[SalPoseManager.CharacterListBox.selection]+"\\MirrorSettings.ini"
		local ini=createFile(MirrorSettings)
		close ini
		return MirrorSettings
		SalPoseManager.EnableDisable()
	)
	fn Load=
	(
	local MirrorSettings=SalPoseManager.DirectoryEt.text+"\\"+SalPoseManager.CharacterListBox.items[SalPoseManager.CharacterListBox.selection]+"\\MirrorSettings.ini"
    MirrorDefination.SelectionList.items=getINISetting MirrorSettings "MirrorSettings"
	)
	fn AddSelectedCmd=
	(
	local MirrorSettings=SalPoseManager.DirectoryEt.text+"\\"+SalPoseManager.CharacterListBox.items[SalPoseManager.CharacterListBox.selection]+"\\MirrorSettings.ini"
	global FillMirrorListSelection
	FillMirrorListSelection=selection as array
	local SelectionList=for obj in selection collect obj.name
	local MirroredList=getINISetting MirrorSettings "MirrorSettings"
	local strArrRes=#()
	for sel in SelectionList do
		(
			--sel=SelectionList[1]
			local res=findItem MirroredList sel
			local resToList= sel as string
			local targetSetting=(execute (getINISetting MirrorSettings "MirrorSettings" resToList))
				
			if res == 0 or targetSetting==OK then
				resToList=resToList+"&"
			else
			(
				if execute("$'"+targetSetting[1]+"'") != undefined then
					resToList=resToList+"&"+(targetSetting[1])
				else
					resToList=resToList+"&"
			)
			append strArrRes resToList
			
		)
	SalPoseManager.MirrorDefination.SelectionList.items=strArrRes
	SalPoseManager.EnableDisable()
	)
	fn SelectionListManager obj action =
	(
		--obj="Box002"
		global FillMirrorListSelection
		if SalPoseManager.MirrorDefination.SelectionList.selection !=0 do
		(
			local SelectedListItem=SalPoseManager.MirrorDefination.SelectionList.items[SalPoseManager.MirrorDefination.SelectionList.selection]
			local MirrorSettings=SalPoseManager.DirectoryEt.text+"\\"+SalPoseManager.CharacterListBox.items[SalPoseManager.CharacterListBox.selection]+"\\MirrorSettings.ini"
			local SourceTargetObjs=(filterString SelectedListItem "&")
			local sourceObj=""
			if SourceTargetObjs.count >0 do
			(
				sourceObj=SourceTargetObjs[1]
				local settings=#("PosX","PosY","PosZ","RotX","RotY","RotZ")
				local intSettings=#()
				for PosRot in settings do
					(
						--PosRot=settings[1]
						if execute("SalPoseManager.MirrorDefination."+PosRot+".checked") then
							append intSettings -1
						else 
							append intSettings 1
					)
				if action == "Pick" then
				(
				setINISetting MirrorSettings "MirrorSettings" sourceObj (#(obj.name,intSettings) as string)
				setINISetting MirrorSettings "MirrorSettings" obj.name (#(sourceObj,intSettings) as string)
				)
				else if action == "Remove" then
				(
				if SourceTargetObjs.count >=1 do
					(
					setINISetting MirrorSettings "MirrorSettings" SourceTargetObjs[1] ""
					)
				if SourceTargetObjs.count ==2 do
					(
					setINISetting MirrorSettings "MirrorSettings" SourceTargetObjs[2]  ""
					)
				)
			nowSelection=selection as array
			select FillMirrorListSelection
			SalPoseManager.MirrorDefination.AddSelectedCmd()
			select nowSelection
			)
		)
	SalPoseManager.EnableDisable()
	)
	fn ApplyNegativeMulti ReadWrite =
	(
		--ReadWrite="Read"
		
		if SalPoseManager.MirrorDefination.SelectionList.selection != 0 do
		(
			local SelectedListItem=SalPoseManager.MirrorDefination.SelectionList.items[SalPoseManager.MirrorDefination.SelectionList.selection]
			local MirrorSettings=SalPoseManager.DirectoryEt.text+"\\"+SalPoseManager.CharacterListBox.items[SalPoseManager.CharacterListBox.selection]+"\\MirrorSettings.ini"	
			local MirrorSettingsArray=filterString SelectedListItem "&"
			local settings=#("PosX","PosY","PosZ","RotX","RotY","RotZ")
			local intSettings=#()
			if MirrorSettingsArray.count==2 do
			(	
				if ReadWrite =="Write" do
				(
					for PosRot in settings do
						(
							--PosRot=settings[1]
							if execute("SalPoseManager.MirrorDefination."+PosRot+".checked") then
								append intSettings -1
							else 
								append intSettings 1
						)
					setINISetting MirrorSettings "MirrorSettings" MirrorSettingsArray[1] (#(MirrorSettingsArray[2],intSettings) as string)
					setINISetting MirrorSettings "MirrorSettings" MirrorSettingsArray[2] (#(MirrorSettingsArray[1],intSettings) as string)
				)
				if ReadWrite =="Read" do
				(
					intSettings=(execute (getINISetting MirrorSettings "MirrorSettings" MirrorSettingsArray[1]))[2]
					for i=1 to i=6 do
					(
						if intSettings[i]==-1 do
							execute("SalPoseManager.MirrorDefination."+settings[i]+".checked=true")
						if intSettings[i]==1 do
							execute("SalPoseManager.MirrorDefination."+settings[i]+".checked=false")
					)
				)
			)
		)
	)
	on SelectionList selected txt do
	(
		local SelectedListItem=SalPoseManager.MirrorDefination.SelectionList.items[SalPoseManager.MirrorDefination.SelectionList.selection]
		local objs=filterString SelectedListItem "&"
		if objs.count >0 do
		(
			clearSelection()
			local newSelection=for obj in Objs collect execute("$'"+obj+"'")
			select newSelection
		)
	SalPoseManager.MirrorDefination.ApplyNegativeMulti "Read"
	)
	on AddSelected pressed do
		SalPoseManager.MirrorDefination.AddSelectedCmd()
	on RemoveMirroring pressed do
		SalPoseManager.MirrorDefination.SelectionListManager "" "Remove"
	on PickMirror picked obj do
		SalPoseManager.MirrorDefination.SelectionListManager obj "Pick"
	on posx changed state do
		SalPoseManager.MirrorDefination.ApplyNegativeMulti "Write"
	on posz changed state do
		SalPoseManager.MirrorDefination.ApplyNegativeMulti "Write"
	on posy changed state do
		SalPoseManager.MirrorDefination.ApplyNegativeMulti "Write"
	on roty changed state do
		SalPoseManager.MirrorDefination.ApplyNegativeMulti "Write"
	on rotx changed state do
		SalPoseManager.MirrorDefination.ApplyNegativeMulti "Write"
	on rotz changed state do
		SalPoseManager.MirrorDefination.ApplyNegativeMulti "Write"
)
rollout PoseOptions "Options" width:112 height:136
(
	button DeletePoseBtn "Delete" pos:[0,16] width:111 height:23
	button ImageRetakeBtn "Retake Image" pos:[0,40] width:112 height:24
	button PoseSelectBtn "Select" pos:[115,75] width:107 height:24
	edittext RenamePoseEt "" pos:[40,112] width:66 height:17
	label lbl1 "Rename" pos:[0,112] width:44 height:23
	button checkDataBtn "Check Data" pos:[-8,152] width:112 height:24
	label PoseName "Name:" pos:[8,0] width:96 height:23
	spinner id "" pos:[105,162] width:30 height:16 type:#integer scale:1
	button PoseRetakeBtn "Retake Pose" pos:[0,88] width:112 height:24
	button RetakeImageForALL "Retake Image ALL" pos:[0,64] width:112 height:24
	on DeletePoseBtn pressed do
	(
		if yesnocancelBox "Are you sure you want to  delete this pose, this action can't be undo" title: "Delete Pose" ==#yes do
		(
		local id=SalPoseManager.PoseOptions.ID.range[3]
		SalPoseManager.setPoseCommand id 3
		)
	)
	on ImageRetakeBtn pressed do
	(
		
		local id=SalPoseManager.PoseOptions.ID.range[3]
		SalPoseManager.setPoseCommand id 1
		SalPoseManager.setPoseCommand id 7
	)
	on PoseSelectBtn pressed do
	(
		local id=SalPoseManager.PoseOptions.ID.range[3]
		SalPoseManager.setPoseCommand id 4
	)
	on RenamePoseEt entered txt do
	(
		local id=SalPoseManager.PoseOptions.ID.range[3]
		SalPoseManager.setPoseCommand id 5
	)
	on checkDataBtn pressed do
	(
		local id=SalPoseManager.PoseOptions.ID.range[3]
		SalPoseManager.setPoseCommand id 6
	)
	on PoseRetakeBtn pressed do
	(
		local id=SalPoseManager.PoseOptions.ID.range[3]
		SalPoseManager.setPoseCommand id 2
	)
	on RetakeImageForALL pressed do
	(
	if yesnocancelBox "Are you sure you want to retake images for this page \nthis might take sometime and it can't be canceled" title: "Retake images for ALL" ==#yes do
		(
		for id=1 to 12 do
			(
			lbl=execute("SalPoseManager.poseBtn"+id as string)
			if lbl != undefined do
				(
				if lbl.visible do
					(
					SalPoseManager.setPoseCommand id 0
					SalPoseManager.setPoseCommand id 1
					SalPoseManager.setPoseCommand id 7
					)
				)
			)
		)
	)
)
	fn GetSetBtn state=
	(
	SettingsIni=SalPoseManager.DirectoryEt.text+"\\"+SalPoseManager.CharacterListBox.selected+"\\"+SalPoseManager.SetListBox.selected+"\\Settings.ini"
	if doesFileExist SettingsIni then
		(
		if hasIniSetting	SettingsIni "ObjectSpace" then
			(
			objTex =getIniSetting 	SettingsIni "ObjectSpace" "Object" 
			obj =execute ("$'"+objTex+"'")
			if obj == undefined then
				MessageBox ("The object "+objTex+ "Does not Exists") title:"Object Not Found"
			else 
				(
				if state == #Get do
					(
					if hasIniSetting 	SettingsIni "ObjectSpace" "Poses" then
						(
						poses=execute (getIniSetting 	SettingsIni "ObjectSpace" "Poses")
						SetCameraPos obj poses  
						)
					else
						(
						MessageBox ("No position data was found please use the \"Set\" button first") title:"No Pose Data"
						)
					)
				if state == #Set do
					(
					Poses=GetCameraPos obj
					res=yesnocancelBox "This might change your Pose Group  render view, do you want to continue?" title:"New View"
					if res ==#yes do
						setIniSetting 	SettingsIni "ObjectSpace" "Poses" (Poses as string)
					)
				)
			)
		else
			messageBox "Couldn't Find Object please pick the Render Space Object"	title:"No File"
		)
	else
		(
		messageBox "No Selection file please Set Selection and try again"	title:"No File"
		)
	)

	on SalPoseManager close do
	(
	if SalPoseManager.MirrorDefination != undefined do
		destroyDialog SalPoseManager.MirrorDefination
	if SalPoseManager.PoseOptions != undefined do
		destroyDialog SalPoseManager.PoseOptions
	if SalPoseManager.NameChange != undefined do
		destroyDialog SalPoseManager.NameChange
	)
	on CharacterListBox selected sel do
	(
	SalPoseManager.fillSetListBox()
	SalPoseManager.fillPosesIntoUI()
	SalPoseManager.SaveUI()
	)
	on CharacterListBox doubleClicked txt do
		SalPoseManager.deleteFolder("Character")
	on SetListBox selected sel do
	(
		SalPoseManager.SaveUI()
		SalPoseManager.refresh()
	)
	on SetListBox doubleClicked txt do
		SalPoseManager.deleteFolder("Set")
	on DirectoryEt entered txt do
	(
		SetIniSetting (getMaxIniFile()) "SalPoseManagerMain" "Dir"  SalPoseManager.DirectoryEt.text
		destroyDialog SalPoseManager
		SalPoseManager.initiate()
	)
	on newSetEt entered text do
		SalPoseManager.makeNewSetFolder()
	on newCharacterEt entered text do
		SalPoseManager.makeNewCharacterFolder()
	on NamesEt selected sel do
	(
	SalPoseManager.NameChange.setCurrentNaming outside:true
	--SalPoseManager.NameChange.setCurrentNaming()
	SalPoseManager.NameChange.fillNameChange()
	SalPoseManager.EnableDisable()
	)
	on poseLabel1 pressed do
		SalPoseManager.setPoseCommand 1  1
	on poseLabel2 pressed do
		SalPoseManager.setPoseCommand 2 1
	on poseLabel3 pressed do
		SalPoseManager.setPoseCommand 3 1
	on poseLabel4 pressed do
		SalPoseManager.setPoseCommand 4 1
	on poseLabel5 pressed do
		SalPoseManager.setPoseCommand 5 1
	on poseLabel6 pressed do
		SalPoseManager.setPoseCommand 6 1
	on poseLabel7 pressed do
		SalPoseManager.setPoseCommand 7 1
	on poseLabel8 pressed do
		SalPoseManager.setPoseCommand 8 1
	on poseLabel9 pressed do
		SalPoseManager.setPoseCommand 9 1
	on poseLabel10 pressed do
		SalPoseManager.setPoseCommand 10 1
	on poseLabel11 pressed do
		SalPoseManager.setPoseCommand 11 1
	on poseLabel12 pressed do
		SalPoseManager.setPoseCommand 12 1
	on PoseOp1 pressed do
		SalPoseManager.setPoseCommand 1 0
	on PoseOp2 pressed do
		SalPoseManager.setPoseCommand 2 0
	on PoseOp3 pressed do
		SalPoseManager.setPoseCommand 3 0
	on PoseOp4 pressed do
		SalPoseManager.setPoseCommand 4 0
	on PoseOp5 pressed do
		SalPoseManager.setPoseCommand 5 0
	on PoseOp6 pressed do
		SalPoseManager.setPoseCommand 6 0
	on PoseOp7 pressed do
		SalPoseManager.setPoseCommand 7 0
	on PoseOp8 pressed do
		SalPoseManager.setPoseCommand 8 0
	on PoseOp9 pressed do
		SalPoseManager.setPoseCommand 9 0
	on PoseOp10 pressed do
		SalPoseManager.setPoseCommand 10 0
	on PoseOp11 pressed do
		SalPoseManager.setPoseCommand 11 0
	on PoseOp12 pressed do
		SalPoseManager.setPoseCommand 12 0
	on NameChangeBtn pressed do
	(
		if SalPoseManager.NameChange== undefined do
	DestroyDialog SalPoseManager.NameChange
	createDialog SalPoseManager.NameChange
	SalPoseManager.NameChange.fillNameChange()
	)
	on SetSelectionBtn pressed do
		SalPoseManager.createSelectionFile()
	on newPoseEt entered text do
		SalPoseManager.createNewPose()
	on ObjectSpaceBtn picked obj do--oj=$
	(
	SettingsIni=SalPoseManager.DirectoryEt.text+"\\"+SalPoseManager.CharacterListBox.selected+"\\"+SalPoseManager.SetListBox.selected+"\\Settings.ini"
	if doesFileExist SettingsIni do
		(
		--if hasIniSetting SettingsIni "ObjectSpace" do
		--	(
			setIniSetting SettingsIni "ObjectSpace" "Object" (obj.name)
			setINISetting  SettingsIni "ObjectSpace" "Poses" ((SalPoseManager.GetCameraPos obj) as string)
		--	)
		)
		--SalPoseManager.ObjectSpaceBtn.tooltip=obj.name	
	SalPoseManager.EnableDisable()
	)
	on PageSld changed val do
		SalPoseManager.fillPosesIntoUI()
	on SelectBtn pressed do
		SalPoseManager.SelectSet()
	on DefineMirror pressed do
		createDialog SalPoseManager.MirrorDefination
	on openDir pressed do
		HiddenDOSCommand ("explorer "+SalPoseManager.DirectoryEt.text	)
	on GetBtn pressed do
		SalPoseManager.GetSetBtn #Get
	on SetBtn pressed do
		SalPoseManager.GetSetBtn #Set
	on ViewportOrRender changed val do
	(
	setIniSetting (getMaxIniFile()) "SalPoseManagerDefault" "ViewOrRender" (val as string)
	--print val
	)
)
ok
)