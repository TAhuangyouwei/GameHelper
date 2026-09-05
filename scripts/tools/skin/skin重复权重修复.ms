--获取当前物体蒙皮修改器
skin_mod = $.skin

--获取蒙皮修改器内骨骼数量
skin_bone_num = skinOps.GetNumberBones skin_mod

--生成所有骨骼id数组和对应数量的零权重数组
bones_ary = for i=1 to skin_bone_num collect i
zero_weights_ary = for i=1 to skin_bone_num collect 0.0

--遍历模型所有顶点
for i=1 to (skinOps.GetNumberVertices skin_mod) do(
	--获取当前顶点内权重骨骼数量
	vert_weight_num = skinOps.GetVertexWeightCount skin_mod i
	--生成空的骨骼id数组和对应的空的骨骼权重数组
	vert_bone_id_ary = #()
	vert_bone_weight_ary = #()
	--生成当前骨骼权重id数组并判断是否有重复id 没有则跳过当前顶点
	id_ary = for j=1 to vert_weight_num collect(skinOps.GetVertexWeightBoneID skin_mod i j)
	if id_ary.count == (makeUniqueArray id_ary).count then(continue)
	
	--遍历当前顶点内有权重骨骼
	for j=1 to vert_weight_num do(
		--获取权重骨骼的id
		vert_bone_id = skinOps.GetVertexWeightBoneID skin_mod i j
		--使用findItem判断骨骼id数组内有无上一步获取的骨骼id
		id_int = findItem vert_bone_id_ary vert_bone_id
		--返回0 代表骨骼id列表内没有这个骨骼的id
		if id_int == 0 then(
			--将骨骼id添加进骨骼id数组
			append vert_bone_id_ary vert_bone_id
			--将骨骼的权重添加进骨骼权重数组
			append vert_bone_weight_ary (skinOps.GetVertexWeight skin_mod i j)
			)
		--返回其他值 代表骨骼id列表内有这个骨骼
		else(
			--将获得的骨骼权重加到已有骨骼对应位置的权重上
			vert_bone_weight_ary[id_int] += skinOps.GetVertexWeight skin_mod i j
			)
		)
	--将当前点的所有权重归零 因为有bug所以要多归零几次
	for k=1 to vert_weight_num do(skinOps.SetVertexWeights skin_mod i bones_ary zero_weights_ary)
	--将整理好的权重应用到当前顶点上
	skinOps.SetVertexWeights skin_mod i vert_bone_id_ary vert_bone_weight_ary
	)