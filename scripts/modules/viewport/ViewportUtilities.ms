/*
    视口布局和显示方式相关功能。
    从 HYW_Scripts_Library.ms 拆出，保留原结构名和调用方式。
*/

struct ViewportUtilities
(
    -- 程序视图设置函数
    fn ProgrammeView =
    (
        viewport.ResetAllViews()
        viewport.setLayout #layout_2v
        viewport.activeViewportEx  1
        actionMan.executeAction 0 "40410"  -- Views: Extended Views 7
    ),

    -- 动画视图设置函数
    fn AnimView =
    (
        viewport.ResetAllViews()
        max tool maximize
    ),

	-- 定义一个方法来切换displayColor.shaded的状态
    fn toggleShaded displayColor =
    (
        if (displayColor.shaded == #material) then
        (
            displayColor.shaded = #object
            return #object -- 返回更新后的状态
        )
        else
        (
            displayColor.shaded = #material
            return #material -- 返回更新后的状态
        )
    )


)
