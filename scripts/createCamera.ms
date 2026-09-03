try (DestroyDialog createCamera )catch()
rollout createCamera "相机预览"
(
	button btCreate "创建"
	on btCreate pressed do 
	(w
		renderWidth = 1080
		renderHeight =  2340
		if $zxcv_P == undefined then 
			d = point  box:on size:100 cross:off name:"zxcv_P"
		if $zxcv_C == undefined then 
		(
			c = Freecamera fov:150  transform:(matrix3 [1,0,0] [0,0,1] [0,-1,0] [0,-720,245]) name:"zxcv_C"
			c.rotation = (quat 0.353553 0.353553 0.612372 0.612372)
			c.orthoProjection = on 
			c.fovType = 2
			c.fov = 120
			c.parent = d 
			viewport.setLayout #layout_2v
			viewport.activeViewportEx 1
			viewport.setCamera c 
			max safeframe toggle
			viewport.SetRenderLevel #flat 
		)
		if $zxcv_P != undefined and $zxcv_C != undefined then 
			rotate $zxcv_P (eulerangles 0 0 90)

			

	)
)
CreateDialog createCamera