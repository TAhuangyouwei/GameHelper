-- 名称：清理飘带根骨骼的帧
-- 作者:很喜欢乱来
-- 版本：v1.0

----记录写入ini

fn getAnimProp_yunEdit obj =(    ----获取选择的帧
	keytest  = #()
	selKeyArray = #()
	if classof obj ==Biped_Object  then
	(
		if (obj.controller != undefined) do
		(
			cs_Bone =  (for o in objects where classOf o == Biped_Object  OR (try(classOf o.transform.controller == BipSlave_Control)catch(false)) collect o)
			if obj.name==(cs_Bone[1].controller.rootName) then
			(
				for k in obj.controller[1].keys do
				(appendIfUnique  selKeyArray k.time)
				for k in obj.controller[2].keys do
				(appendIfUnique  selKeyArray k.time)
				for k in obj.controller[3].keys do
				(appendIfUnique  selKeyArray k.time)
			)
			else if (keyTest = obj.controller.keys) != undefined and keyTest.count > 0 do
			(
				keytest = obj.controller.keys
				for k in 1 to keyTest.count  do
				(
					appendIfUnique  selKeyArray keytest[k].time
				)
			)
		)
	)
	else (
		if obj.numSubs > 0 then
		(
			for i = 1 to obj.numSubs do
			(
				getAnimProp_yunEdit obj[i]
			)
		)
		else
		(
			if (obj.controller != undefined) do
			(
				if (keyTest = obj.keys) != undefined and keyTest.count > 0 do
				(
					keytest = obj.keys
					for k in 1 to keyTest.count  do
					(
						appendIfUnique  selKeyArray keytest[k].time
					)
				)
			)
		)
	)
	sort selKeyArray
	makeUniqueArray  selKeyArray
	
	fileName =((GetDir #export)+ "\\keyframe.ini")
	delIniSetting fileName obj.name 
	for i=1 to selKeyArray.count do
	(
		setINISetting fileName  obj.name  ("countF_"+ (i as string)) (selKeyArray[i] as string)
	)
	
	return selKeyArray
)

key_sel = selection as array

for i in key_sel do ( getAnimProp_yunEdit i)

---读取 并且删除bone帧数

fn getKeyframeFromIni obj =  -- 读取关键帧
(
	fileName =((GetDir #export)+ "\\keyframe.ini")
	frameCount = getINISetting fileName obj.name
	keyFF = #()
	for i  in frameCount do
	(
		append keyFF ((getINISetting fileName obj.name i) as time)
	)
	return keyFF
)

-----删除当前帧
fn CleanCuurentKey inputObject =
(
	key_CS = #()
	if classof inputObject == Biped_Object then
	(
		cs_Bone =  (for o in objects where classOf o == Biped_Object  OR (try(classOf o.transform.controller == BipSlave_Control)catch(false)) collect o)
		if inputObject.name==(cs_Bone[1].controller.rootName) then
		(
			keyH = inputObject.transform.controller.horizontal.controller.keys
			needDel = #()
			-- 这里是帧表编号
			for k=1 to keyH.count do (if keyH[k].Time == sliderTime then( append  needDel k))
			if needDel.count ==1 then ( DeleteKey keyH needDel[1] )
			
			keyV = inputObject.transform.controller.vertical.controller.keys
			needDel = #()
			-- 这里是帧表编号
			for k=1 to keyV.count do (if keyV[k].Time == sliderTime then( append  needDel k))
			if needDel.count ==1 then ( DeleteKey keyV needDel[1] )
			
			keyT = inputObject.transform.controller.turning.controller.keys
			needDel = #()
			-- 这里是帧表编号
			for k=1 to keyT.count do (if keyT[k].Time == sliderTime then( append  needDel k))
			if needDel.count ==1 then ( DeleteKey keyT needDel[1] )
			keyT = inputObject.transform.controller.turning.controller.keys
		)
		else
		(
			tempKeyList = inputObject[3].Keys
			needDel = #()
			-- 这里是帧表编号
			for k=1 to tempKeyList.count do (if tempKeyList[k].Time == sliderTime then( append  needDel k))
			if needDel.count ==1 then ( DeleteKey tempKeyList needDel[1] )
		)
	)
	else
	(
		for i = 1 to inputObject.numSubs do
		(
			tempSubAnim = GetSubAnim inputObject i
			tempController = tempSubAnim.Controller
			
			if tempController != undefined then
			(
				if tempSubAnim.numSubs > 0 then (CleanCuurentKey tempSubAnim)
				else
				(
					tempKeyList = tempController.Keys
					needDel = #()
					for k=1 to tempKeyList.count do (if tempKeyList[k].Time == sliderTime then( append  needDel k))
					if needDel.count==1 then ( DeleteKey tempKeyList needDel[1])
				)
			)
		)
	)
)

-- CleanCuurentKey $
tStart = (animationRange.start as string) as integer
tEnd = (animationRange.end as string) as integer
tNow = (currentTime as string) as integer
TimeLength = (tEnd - tStart) + 1
frames = #()
for i = tStart to tEnd do append frames i

-- 用户自定义选择bone骨骼
-- 修改为手动选择骨骼，不使用getNodeByName函数
defineBones = selection as array

-- 获取用户自定义的选择并处理
clearselection ()
for o in defineBones where (o.ishidden == false) do
(
	if classof o == BoneGeometry then selectmore o
)
selBones = selection as array

for vT in frames do
(
	sliderTime=vT
	for o in selBones do
	(
		kersFF = #()
		for k  in key_sel do
		(
			join kersFF (getKeyframeFromIni k )
		)
		sort kersFF
		kersFF = makeuniquearray kersFF
		
		if findItem kersFF slidertime == 0 do (CleanCuurentKey o)
	)
)
