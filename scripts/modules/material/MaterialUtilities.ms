/*
    材质相关公共功能。
    本文件由 HYW_Scripts_Library.ms 加载，界面脚本仍然直接调用 MaterialUtilities。
*/

struct MaterialUtilities
(
    -- 重置材质球的方法
    fn resetCompactMaterialSlots =
    (
        renderers.current = Default_Scanline_Renderer()
		local slotCount = meditMaterials.count
        for i = 1 to slotCount do
        (
            local materialName = (formattedPrint i format:".2d") + "-standard"
			setMeditMaterial i (standard name:materialName)
        )
    ),
	fn clearSelectedMaterials =
	(
		if selection.count == 0 then
		(
			messageBox "请先选择需要清除材质的物体。"
			return false
		)

		undo "清除所选物体材质" on
		(
			for obj in selection do
			(
				obj.material = undefined
			)
		)

		true
	)

    -- 这里可以添加更多与材质相关的方法
)
