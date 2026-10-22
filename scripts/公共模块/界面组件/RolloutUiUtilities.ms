/*
    Rollout 界面状态判断功能。
    从 HYW_Scripts_Library.ms 拆出，保留原结构名和调用方式。
*/

struct RolloutUiUtilities
(
	fn widgetState =
	(
		if (maxVersion())[8] <= 2021 then
			return true
		else
			return false
	)
)
