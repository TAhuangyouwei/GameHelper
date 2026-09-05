
try(DestroyDialog BonesKeySimple) catch()
rollout BonesKeySimple "飘带关键帧精简"
(
	checkbox ckParent "同步父级关键帧位置"
	spinner spNum "关键帧间隔:" range:[0,10,3] type:#integer
	button btnKeySimple "执行"
	on btnKeySimple pressed do 
	(
		undo on 
		(
			if ckParent.state == off then 
			(
				if selection.count != 0 then 
				(
					sTime = animationRange.start
					eTime = animationRange.end
					
					for obj in selection do 
					(
						for t = sTime to eTime do addNewKey obj[3] t
						
						local keys = obj.position.controller.keys
						
						local KeysNum = numKeys obj.position.controller
						
						if KeysNum >= 2 then 
						(
							for keyTime = ((sTime +1f) as integer ) /TicksPerFrame to (( eTime /2 - 1f) as integer )/TicksPerFrame  do 
							(		
								if (mod keyTime spNum.value) != 0 then
								(
									selectKeys obj.position.controller keyTime
									deleteKeys obj.position.controller  #selection
									
									selectKeys obj.rotation.controller keyTime
									deleteKeys obj.rotation.controller  #selection
									
									selectKeys obj.scale.controller keyTime
									deleteKeys obj.scale.controller  #selection
								)
							)
							
							for keyTime = (( eTime /2 + 1f) as integer ) /TicksPerFrame to (( eTime - 1f) as integer )/TicksPerFrame  do 
							(		
								if (mod keyTime spNum.value) != 0 then
								(
									selectKeys obj.position.controller keyTime
									deleteKeys obj.position.controller  #selection
									
									selectKeys obj.rotation.controller keyTime
									deleteKeys obj.rotation.controller  #selection
									
									selectKeys obj.scale.controller keyTime
									deleteKeys obj.scale.controller  #selection
								)
							)
							
						)
					)
				)
			)
			else
			(
				if ckParent.state == off then 
				(
					if selection.count != 0 then 
					(
						sTime = animationRange.start
						eTime = animationRange.end
						
						for obj in selection do 
						(
							for t = sTime to eTime do addNewKey obj[3] t
							
							local keys = obj.position.controller.keys
							
							local KeysNum = numKeys obj.position.controller
							
							if KeysNum >= 2 then 
							(
								for keyTime = ((sTime +1f) as integer ) /TicksPerFrame to (( eTime - 1f) as integer )/TicksPerFrame  do 
								(		
									if obj.parent !=undefined and (obj.parent[3].controller.keys spNum.value) != 0 then
									(
										selectKeys obj.position.controller keyTime
										deleteKeys obj.position.controller  #selection
										
										selectKeys obj.rotation.controller keyTime
										deleteKeys obj.rotation.controller  #selection
										
										selectKeys obj.scale.controller keyTime
										deleteKeys obj.scale.controller  #selection
									)
								)
								
								
							)
						)
					)
				)
			)

			
		)

	)
	
)
CreateDialog BonesKeySimple