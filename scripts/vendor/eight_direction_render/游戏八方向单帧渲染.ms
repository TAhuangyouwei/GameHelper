if GameRender != undefined then destroydialog GameRender 
rollout GameRender "八方单帧渲染工具" width:355 height:252
(
	local curentime = animationRange.start as string + "------" + animationRange.end as string
	local ScenePoints = #()
	local CenterPoint
	local SceneCamera = #()
	local RenderCamera
	local RenderWidth = 256
	local RenderHight = 256
	local RenderTime = #active
	local Rendernthframe
	local TheSavePath
	local RenderFile
	
	----------------------UI------------------------------------------------
	GroupBox grp4 "重要设置" pos:[7,7] width:343 height:45
	label lbl11 "轴心点：" pos:[17,28] width:60 height:19
	dropdownList ddl1 pos:[75,24] width:90 height:18
	label lbl10 "设置相机：" pos:[174,28] width:71 height:16
	dropdownList ddl2 "" pos:[242,24] width:102 height:22
	-------------------------------------------------------------------------	
	GroupBox grp1 "输出大小" pos:[7,56] width:343 height:43
	label lbl1 "宽度：" pos:[18,76] width:51 height:16
	spinner spn1 "" pos:[65,75] width:65 height:16  range:[0,1000,0]  type:#integer scale:1 
	label lbl2 "高度：" pos:[150,76] width:51 height:16
	spinner spn2 "" pos:[197,75] width:65 height:16 range:[0,1000,0]  type:#integer scale:1 
	---------------------------------------------------------------------------
	GroupBox grp2 "时间输出" pos:[6,104] width:343 height:64
	label lbl8 "每隔几帧：" pos:[232,118] width:81 height:16
	spinner spn5 "" pos:[296,117] width:45 height:16 range:[1,99,1] type:#integer scale:1 
	radiobuttons rdo1 "" pos:[14,129] width:93 height:32 labels:#("当前时间线", "自定义") default:1 columns:1
	edittext curent_time "" pos:[95,128] width:119 height:12                                      ---当前时间线 
	spinner spn3 "" pos:[99,146] width:65 height:16 range:[0,99999,0] type:#integer scale:1        ---自定义时间a
	label lbl7 "到" pos:[175,147] width:22 height:16
	spinner spn4 "" pos:[199,146] width:65 height:16 range:[0,99999,30] type:#integer scale:1     ---自定义时间b
	--------------------------------------------------------------------------
	GroupBox grp3 "渲染输出" pos:[6,174] width:343 height:45
	button SetSavePath "保存目录" pos:[12,191] width:60 height:20
	edittext SavePathString "" pos:[80,193] width:261 height:18 enabled:false
	---------------------------------------------------------------------------
	HyperLink lnk1 "--------------------作者：铁豌豆   网上帮助--------------------" pos:[13,227] width:272 height:15 color:(color 0 0 255) hovercolor:(color 0 0 255) visitedcolor:(color 0 0 192) address:"http://www.cgjoy.net/bbs/thread-790-1-1.html"
	button btn_render "八方向渲染" pos:[270,224] width:79 height:22
	---------------------------------------------------------------------------
	on GameRender open  do
	(
		for i in $Cameras do (if (classof i == Freecamera or classof i == Targetcamera) then append SceneCamera i.name)
		try (ddl2.items = SceneCamera;RenderCamera = execute ("$"+ ddl2.selected))catch (messageBox "请创渲染摄像机后重新运行本工具")
		for i in Helpers do (if classof i == Point then append ScenePoints i.name)
		try (ddl1.items = ScenePoints;CenterPoint = execute ("$"+ ddl1.selected))catch (messageBox "请创建轴心点后重新运行本工具")
		spn1.value = RenderWidth 
		spn2.value = RenderHight
		curent_time.text = curentime
		rendernthframe = spn5.value
	)
	on ddl1 selected sel do
	(
		CenterPoint = execute ("$"+ ddl1.selected)
	)
	on ddl2 selected sel do
	(
		RenderCamera = execute ("$"+ ddl2.selected)
	)
	on spn1 changed val do  --设置渲染宽度
	(
		RenderWidth = spn1.value
	)
	on spn2 changed val do  --设置渲染高度
	(
		RenderHight = spn2.value
	)
	on rdo1 changed state do
	(
		case rdo1.state of
		(
			1: (curent_time.text = curentime;RenderTime = #active)
			2: RenderTime = interval spn3.value spn4.value
		)
		print RenderTime 
	)
	on spn3 changed val do
	(
		RenderTime = interval spn3.value spn4.value
	)
	on spn4 changed val do
	(
		RenderTime = interval spn3.value spn4.value
	)
	on spn5 changed val do
	(
		rendernthframe = spn5.value
		print rendernthframe
	)
	on SetSavePath pressed do
	(
		TheSavePath = getSavePath caption:"设置保存目录"
		if TheSavePath != undefined then 
		(
			SavePathString.text = TheSavePath
		)
	)
	on btn_render pressed do
	(
		if TheSavePath != undefined then 
		(
			num = #("前","右前","右","右后","后","左后","左","左前")
			for i in 1 to 8 do 
			(
				RenderPath = TheSavePath
				makedir RenderPath 
				RenderFile = RenderPath + "\\"+ num[i] + ".png"
				render camera:RenderCamera outputwidth:RenderWidth outputheight:RenderHight framerange:RenderTime nthframe:rendernthframe outputFile:RenderFile
				rotate CenterPoint (angleaxis 45 [0,0,1])
			)
		)
		else (messagebox "请指定保存目录")
	)
)

---------
---------
----------------
------------------
CreateDialog GameRender 355 252 25 25