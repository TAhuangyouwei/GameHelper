try(destroydialog SequenceSECreateTool)catch()
rollout SequenceSECreateTool "序列帧特效动画创建工具" width:210 height:121
(
	spinner 'Uspn' "U" pos:[72,33] width:45 height:16 range:[-99999,99999,4] type:#integer align:#left
	spinner 'Vspn' "V" pos:[138,33] width:45 height:16 range:[-99999,99999,4] type:#integer align:#left
	label 'lbl1' "Grid:" pos:[31,33] width:42 height:16 align:#left
	--button 'delUVWbtn' "删UV修改器" pos:[34,61] width:146 height:25 align:#left
	button 'CreateSEAnibtn' "创建动画" pos:[34,60] width:146 height:25 align:#left
	HyperLink 'lbl_01' "帮助       开发者：叶孤弦" pos:[29,98] width:166 height:14 address:"https://www.cgjoy.com/thread-275528-1-1.html" color:(color 80 80 80) align:#left
--设置UV大小
fn uvScaleSet obj GridX GridY =(
	GridU = 1.0/GridX
	GridV = 1.0/GridY
	--选择所有uv多边形 											uv多边形 编号
	subobjectLevel = 3
	obj.modifiers[#unwrap_uvw].unwrap6.selectFacesByNode #{1..(obj.modifiers[#unwrap_uvw].numberPolygons())} obj
	obj.modifiers[#unwrap_uvw].unwrap2.ScaleSelectedXY GridU GridV [0,1,0]
	)
--设置UV动画
fn SEUVPosSet obj GridX GridY =(
	--选择所有uv多边形 													uv多边形 编号
	obj.modifiers[#unwrap_uvw].unwrap6.selectFacesByNode #{1..(obj.modifiers[#unwrap_uvw].numberPolygons())} obj
		for Y in 1 to GridY do(
		if Y != 1 then (
			sliderTime+=1
			obj.modifiers[#unwrap_uvw].unwrap2.MoveSelected [-(1-1.0/GridX),-(1.0/GridY),0])
			for X in 1 to (GridX-1) do(
			sliderTime+=1
			obj.modifiers[#unwrap_uvw].unwrap2.MoveSelected [(1.0/GridX),0,0]

				)
			)
	)

	on CreateSEAnibtn pressed do
	(
			undo on(
				---------分UV---------
				sliderTime = 0	
				global obj
				if selection[1] != undefined then (
					obj = selection[1]
				if obj.Modifiers[#unwrap_uvw]!=undefined then deleteModifier obj obj.modifiers[#unwrap_uvw]	
				modPanel.addModToSelection (Unwrap_UVW ()) ui:on
					)
				uvScaleSet obj Uspn.value Vspn.value
				----------创建动画----------------
					
				if selection[1] != undefined then (
				maxops.setDefaultTangentType #step #step			
				set animate on
				SEUVPosSet obj Uspn.value Vspn.value
				maxops.setDefaultTangentType #flat #flat
				subobjectLevel = 0
				)
				)
		)
)
createdialog SequenceSECreateTool fgcolor:(color 14 255 2)

