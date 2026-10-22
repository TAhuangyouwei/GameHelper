
try 
(
	if classof $B_r_Zhua.transform.controller == Link_Constraint  then 
	(
		$B_r_Zhua.transform.controller.deleteTarget 1
		$B_r_Zhua.transform.controller.AddTarget $'Bip001 Spine1' 0
		$B_r_Zhua.parent = $'Bip001 R Hand'
	)
	else
	(
		tempTrans = $B_r_Zhua.transform
		$B_r_Zhua.transform.controller = Link_Constraint()
		$B_r_Zhua.transform = tempTrans
		$B_r_Zhua.transform.controller.AddTarget $'Bip001 Spine1' 0
		$B_r_Zhua.parent = $'Bip001 R Hand'
	)


)
catch ()

try 
(
	if classof $B_Dao.transform.controller == Link_Constraint  then 
	(
		$B_Dao.transform.controller.deleteTarget 1
		$B_Dao.transform.controller.AddTarget $'Bip001 Spine1' 0
		$B_Dao.parent = $'Bip001 R Hand'
	)
	else
	(
		tempTrans = $B_Dao.transform
		$B_Dao.transform.controller = Link_Constraint()
		$B_Dao.transform = tempTrans
		$B_Dao.transform.controller.AddTarget $'Bip001 Spine1' 0
		$B_Dao.parent = $'Bip001 R Hand'
	)
)
catch ()









try 
(
	if classof $B_Qiang01.transform.controller == Link_Constraint  then 
	(
		$B_Qiang01.transform.controller.deleteTarget 1
		$B_Qiang01.transform.controller.AddTarget $'Bip001 Spine1' 0
		$B_Qiang01.parent = $'Bip001 R Hand'
	)
	else
	(
		tempTrans = $B_Qiang01.transform
		$B_Qiang01.transform.controller = Link_Constraint()
		$B_Qiang01.transform = tempTrans
		$B_Qiang01.transform.controller.AddTarget $'Bip001 Spine1' 0
		$B_Qiang01.parent = $'Bip001 R Hand'
	)

)
catch ()

try 
(
	if classof $B_R_sd.transform.controller == Link_Constraint  then 
	(
		$B_R_sd.transform.controller.deleteTarget 1
		$B_R_sd.transform.controller.AddTarget $'Bip001 Spine1' 0
		$B_R_sd.parent = $'Bip001 R Hand'
	)
	else
	(
		tempTrans = $B_R_sd.transform
		$B_R_sd.transform.controller = Link_Constraint()
		$B_R_sd.transform = tempTrans
		$B_R_sd.transform.controller.AddTarget $'Bip001 Spine1' 0
		$B_R_sd.parent = $'Bip001 R Hand'
	)
)
catch ()

try 
(
	if classof $B_Jian.transform.controller == Link_Constraint  then 
	(
		$B_Jian.transform.controller.deleteTarget 1
		$B_Jian.transform.controller.AddTarget $'Bip001 Spine1' 0
		$B_Jian.parent = $'Bip001 R Hand'
	)
	else
	(
		tempTrans = $B_Jian.transform
		$B_Jian.transform.controller = Link_Constraint()
		$B_Jian.transform = tempTrans
		$B_Jian.transform.controller.AddTarget $'Bip001 Spine1' 0
		$B_Jian.parent = $'Bip001 R Hand'
	)
)
catch ()

try 
(
	if classof $B_Gun01.transform.controller == Link_Constraint  then 
	(
		$B_Gun01.transform.controller.deleteTarget 1
		$B_Gun01.transform.controller.AddTarget $'Bip001 Spine1' 0
		$B_Gun01.parent = $'Bip001 R Hand'
	)
	else
	(
		tempTrans = $B_Gun01.transform
		$B_Gun01.transform.controller = Link_Constraint()
		$B_Gun01.transform = tempTrans
		$B_Gun01.transform.controller.AddTarget $'Bip001 Spine1' 0
		$B_Gun01.parent = $'Bip001 R Hand'
	)
)
catch ()

try 
(
	if classof $B_l_Zhua.transform.controller == Link_Constraint  then 
	(
		$B_l_Zhua.transform.controller.deleteTarget 1
		$B_l_Zhua.transform.controller.AddTarget $'Bip001 Spine1' 0
		$B_l_Zhua.parent = $'Bip001 L Hand'
	)
	else
	(
		tempTrans = $B_l_Zhua.transform
		$B_l_Zhua.transform.controller = Link_Constraint()
		$B_l_Zhua.transform = tempTrans
		$B_l_Zhua.transform.controller.AddTarget $'Bip001 Spine1' 0
		$B_l_Zhua.parent = $'Bip001 L Hand'
	)
)
catch ()

try 
(
	if classof $B_L_sd.transform.controller == Link_Constraint  then 
	(
		$B_L_sd.transform.controller.deleteTarget 1
		$B_L_sd.transform.controller.AddTarget $'Bip001 Spine1' 0
		$B_L_sd.parent = $'Bip001 L Hand'
	)
	else
	(
		tempTrans = $B_L_sd.transform
		$B_L_sd.transform.controller = Link_Constraint()
		$B_L_sd.transform = tempTrans
		$B_L_sd.transform.controller.AddTarget $'Bip001 Spine1' 0
		$B_L_sd.parent = $'Bip001 L Hand'
	)
)
catch ()
