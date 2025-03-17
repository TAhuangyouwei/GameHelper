try(destroyDialog rol_copyObjTrackToObj)
catch()

rollout rol_copyObjTrackToObj "复制运动物体轨迹" width:200 height:104
(
	pickButton 	btn_pickObj "选择运动物体" pos:[9,8] width:183 height:24  tooltip:"先选中要拷贝动画的物体，然后再点按钮去拾取带动画的物体"
	spinner 		spn_preFrame "每隔 " pos:[22,40] width:64 height:16 range:[1,760919,1] type:#integer scale:1
	label 		lbl_preFrame "帧生成1个关键帧。" pos:[96,40] width:104 height:16
	radioButtons 	rdo_range "" pos:[8,64] width:163 height:32 labels:#("指定物体的运动动画范围    ", "指定范围:   ")
	spinner 		spn_rangeStart "" pos:[90,80] width:44 height:16 range:[-760919,760919,0] type:#integer scale:1 enabled:false
	spinner 		spn_rangeEnd "到" pos:[144,80] width:48 height:16 range:[-760919,760919,0] type:#integer scale:1 enabled:false
	on rol_copyObjTrackToObj open do
	(
		spn_rangeStart.value = animationRange.start;
		spn_rangeEnd.value = animationRange.end;
	)
	on btn_pickObj picked target do
	(
		try
		(
			local createFrame = false;
			
			if selection.count == 0 do messageBox "没有选择生成关键帧的物体。  " title:"";
			if selection.count == 1 do createFrame = true;
			if selection.count > 1 do createFrame = queryBox "选择了多个物体生成关键帧，是否在这些物体上创建关键帧？\n创建后，这些物体的关键帧相同。" title:"";
			
			if createFrame do
			(
				local start_F,end_F,step,n;
				
				step = spn_preFrame.value;
				if rdo_range.state == 1 then
				(
					start_F = animationRange.start;
					end_F = animationRange.end;
				)
				else
				(
					start_F = spn_rangeStart.value;
					end_F = spn_rangeEnd.value;
				)
				n = 0;
				sliderTime = start_F;
				for obj in selection do obj.transform = target.transform;
				animate on
				(
					while end_F >= (start_F + step * n) do
					(
						at time (start_F + step * n) 
						(
							for obj in selection do obj.transform = target.transform;
						)
						n += 1;
					)
					at time end_F 
					(
						for obj in selection do obj.transform = target.transform;
					)
				)
			)
		)
		catch()
	)
	on rdo_range changed state do
	(
		spn_rangeStart.enabled = state == 2;
		spn_rangeEnd.enabled = state == 2;
	)
)

createdialog rol_copyObjTrackToObj 200 104