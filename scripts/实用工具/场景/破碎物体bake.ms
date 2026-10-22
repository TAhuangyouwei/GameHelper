try(DestroyDialog rayFireTools)catch()

rollout rayFireTools "ÆÆËé¶¯»­"
	
(
	button btnConvert "×ª»»" width:130
	on btnConvert pressed do 
	(
		rayFireObjs = for obj in selection where obj.position.controller.keys.count != 0 collect obj 
			
		if rayFireObjs.count != 0 then 
		(
			for obj in rayFireObjs do 
			(
				animBone = BoneSys.createBone  [0,0,0] [0,5,0] [0,0,1]
				animate on 
				for t = animationRange.start to animationRange.end  do 
				(
					at time t animBone.transform = obj.transform 	
						
					if t == animationRange.end then 
					(
						sliderTime = 0
						deleteKeys  obj.position.controller.keys #allKeys
						deleteKeys  obj.rotation.controller.keys #allKeys
						
						
					)
				)
				addModifier obj (skin())
				skinOps.addbone obj.skin animBone -1
			)
			
			
		)
	)
	
)
CreateDialog rayFireTools