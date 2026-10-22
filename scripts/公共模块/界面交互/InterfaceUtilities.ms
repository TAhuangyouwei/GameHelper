/*
    界面语言和轮廓显示相关功能；包含其颜色状态。
    从 HYW_Scripts_Library.ms 拆出，保留原结构名和调用方式。
*/

global store_amb, store_tint

if store_amb == undefined do store_amb = color 0 0 0
if store_tint == undefined do store_tint = color 255 255 255


struct InterfaceUtilities
(
    tempimpl,


	Fn SetDefaultLanguageToChinese = --适用于多数版本
	(
		if (MaxVersion() )[1] >= 15000 do
		if "2052" != GetINISetting (GetMAXIniFile()) "File Language Options" "LanguageToUseForFileIO" do
		(
			DialogMonitorOPS.UnRegisterNotification id:#SetDefaultLanguageToChinese
			Fn DialogMonitorCallBackSetDefaultLanguageToChinese =
			(
				currentHandle = DialogMonitorOPS.GetWindowHandle()
				if "Preference Settings" == UIAccessor.GetWindowText currentHandle do
				(
					languageNames = #("Chinese","English","German","French","japanese","Korean","Current")
					childrens = Windows.getChildrenHWND currentHandle

					languageLabel = undefined
					for tempControl in childrens where tempControl[5] == "Default Language:" do
					(
						languageLabel = tempControl
					)
					if languageLabel != undefined do
					for tempControl in childrens where
					(
						tempControl[2]==languageLabel[2] and \
						tempControl[3]==languageLabel[3]  and \
						"ComboBox" == tempControl[4] and \
						FindItem languageNames tempControl[5] != 0
					)
					do
					(
						UIAccessor.SendMessage tempControl[1] 0x014E 6 0
					)
					UIAccessor.SendMessageID currentHandle #IDOK
				)
				true
			)
			DialogMonitorOPS.RegisterNotification DialogMonitorCallBackSetDefaultLanguageToChinese id:#SetDefaultLanguageToChinese
			DialogMonitorOPS.Enabled = true
			DialogMonitorOPS.ShowNotification()
			max file preferences
			DialogMonitorOPS.UnRegisterNotification id:#SetDefaultLanguageToChinese
			DialogMonitorOPS.Enabled = false
		)
	),



-- 2010版本
-- (DotNetClass "System.Windows.Forms.Application").CurrentCulture = dotnetObject "System.Globalization.CultureInfo" "zh-cn"
	fn Silhouette_Viewer =
	(
		local inst = InterfaceUtilities()  -- 创建结构体实例

		-- 检查NitrousGraphicsManager是否返回有效对象
		local viewportSetting = NitrousGraphicsManager.GetActiveViewportSetting()
		if viewportSetting != undefined then
		(
			-- 只有当viewportSetting有效时才继续
			if inst.tempimpl == undefined do inst.tempimpl = viewportSetting.VisualStyleMode

			if store_amb == undefined then store_amb = color 0 0 0
			if store_tint == undefined then store_tint = color 255 255 255

			if (ambientColor == color 0 0 0) and (lightTintColor == color 0 0 0) then -- 关闭剪影
			(
				animButtonState = off
				hideByCategory.bones = off
				hideByCategory.helpers = off

				impl = viewportSetting

				if impl != undefined then impl.VisualStyleMode = inst.tempimpl

				ambientColor = store_amb
				lightTintColor = store_tint
				redrawViews()
			)
			else   -- 显示剪影
			(
				animButtonState = off
				hideByCategory.bones  = on
				hideByCategory.helpers = on

				impl = viewportSetting
				inst.tempimpl = impl.VisualStyleMode
				if impl != undefined then impl.VisualStyleMode = #shaded

				store_amb = ambientColor
				store_tint = lightTintColor
				ambientColor = color 0 0 0
				lightTintColor = color 0 0 0
				redrawViews()
			)
		)
		else
		(
			-- 如果viewportSetting无效，可以在此处处理错误或返回
		)
	)



)
