/******** 功能说明 ********\

	提供图片序列播放和录制功能,支持Max2011或以上


    打开图片序列:
            拖拽文件夹/图像文件到播放窗口
            会打开该文件夹中所有*.jpg|*.png格式的图像
            图像序列的宽高比 以首个文件为标准

            *在打开图片序列之前,一些功能无法使用,如窗口缩放,鼠标中键/右键菜单

    播放:
        侧边栏:-----------------------------------------------------------------------

            X:
                关闭程序
                也可以双击关闭

            ▲
                缩小窗口至左上角
                缩小的窗口不会更新 不占用cpu资源

            录屏
                进入录屏模式

            历史:
                保存10个历史记录
                历史记录会保存窗口大小和图片序列开始时间

            加载:
                加载按钮可以加载全部图片到内存
                不手动点击加载的情况下,图片会在首次播放时加载到内存,以提升预览效率

            设置:
                打开设置界面

            Gif:
                Gif尺寸为原始图像尺寸 固定帧率 约30帧(0.03秒一帧)

                Gif生成位置: 图片序列文件夹/MyGif.gif , 重复生成会覆盖
                背景相对固定时,生成的Gif文件会相对较小

            左下角锁:
                进入/离开锁定模式
                锁定模式:无法对播放窗口进行操作 操作会透过窗口操作MAX
                通常与不透明度一同工作



        鼠标中键:  显示相关--------------------------------------------------------------
        
            调整窗口大小:
                鼠标滚轮上下,按住中键拖动:
                *窗口大小超过100%会导致性能较大降低 (原始分辨率(100%)时性能最好)
            
            鼠标中键菜单:

                原始分辨率:
                    将窗口大小调整为100%缩放
                    100%缩放为实际加载的分辨率 可能低于图片实际分辨率
                    设置为动态内存占用时,每次打开的原始分辨率可能不同

                覆盖视口:
                    让播放窗口匹配当前选中视口(但不会改变播放窗口的比例)
                    在覆盖视口的状态下再次点击覆盖视口可返回
                
                显示参考线:
                    显示/隐藏参考线
                    可在 侧边栏->设置->参考线设置 中调整细节,包括格子数量,不透明度,颜色

                不透明度:
                    设置播放窗口的不透明度
                    可在 侧边栏->设置->播放设置->不透明度 更细致的调整
                
                总在最前:
                    不被其他窗口遮挡
        

        鼠标右键:  时间相关-----------------------------------------------------------------

            鼠标右键菜单:

                同步时间轴:
                    将MAX时间轴范围设置成图片序列播放的范围

                将首张图像同步到此帧:
                    例: 序列时长200帧 在Max100帧处点击'将首张图像同步到此帧' 则序列的播放范围为100-300帧     (MAX100帧和图片序列0帧对其)

                将当前图像同步到0帧:
                    例：序列时长200帧 在图片序列100帧处点击'将当前图像同步到0帧' 则序列的播放范围为-100-100帧 (MAX0帧和图片序列100帧对其)

            侧边栏->设置->时间设置中可以进行更细致的调整 调整当前帧与起始帧的功能相同 方向相反


    录制:
        录屏:---------------------------------------------------------------------------------

            默认保存路径为桌面 可在设置中更改

            录制Max时,会录制整个时间轴

            设置了最大分辨率和时长限制
                原因: -GDI录屏效率低 
                      -高分辨率与高时长在播放时会占用更多内存
            *录制网页时,可能需要缩小网页窗口来匹配录制窗口的大小

            *录制区域在开始录制时决定 录制开始后拖拽窗口不会改变录制区域 (**可能更改)

            *录屏存在误差区间,如果对精确度有需求,可用其他软件导出图片序列
            

        录制辅助:-------------------------------------------------------------------------------

            可以选择在录制开始时向下方窗口发送空格键或媒体键
            媒体键等效于笔记本上的开始/结束按键

            可以在设置中更改 或者在开始录制按钮上点击鼠标右键切换

            开启录制辅助时,应在暂停状态开始录制

            *在一些网页,空格可能同时用于网页播放器开始和下翻,点击录制前需要保证网页播放器刚进行过操作


    其他:
        性能:----------------------------------------------------------------------------------

            内存耗费:图片长 * 图片宽 * 图片数量 * 4 / (1024*1024) MB 
                例: 1280*720  , 180帧(6s)  -> 632.8MB  
                    1920*1080 , 180帧(6s)  -> 1423.8MB
                    960*960   , 600帧(20s) -> 2109.4MB 

            超过设置中最大内存占用时,会在加载时缩小图片,图片的清晰度会降低

            gif生成会额外耗费内存


        设置文件:------------------------------------------------------------------------------
        
            保存位置:
                plugcfg\RefPlayer2020.ini,不同版本,不同语言的Max不共享设置文件
                例: C:\Users\Administrator\AppData\Local\Autodesk\3dsMax\2014 - 64bit\ENU\en-US\plugcfg\RefPlayer2020.ini

            保存内容:
                历史记录,录屏保存目录,是否录制鼠标,录屏辅助选项,内存设置,参考线,窗口位置


        可搭配软件:-----------------------------------------------------------------------------
			
			剪辑软件-> 导出图片序列
			PotPlayer->连续截取画面(Ctrl + G)
*/

/********** 版本 ***********\
	2020-09-12(第一版):
			-录制(GDI)
				-录制辅助
			-播放
				-大小控制
				-历史记录
				-内存占用设置
				-参考线
				-透明度

    2020-12-18:
        -参考线效率 录屏效率优化
        -录制Max
        -录制后预览不与Max时间轴绑定
        -加入锁定功能 生成Gif功能
        -固定每秒fps 不随Max变化
        -Chinese Encode -> UTF-8

    2020-12-30:
        新增:
            -添加侧边栏阴影
            -历史记录加入预览图
            -优化Gif生成 引入透明机制 减小生成大小

            -锁定模式侧边栏也可以透过
            -在录制按钮上回提示辅助信息,或者Max模式
            -在录制按钮右键可以调整录制辅助模式
            -超过100%尺寸提示会变色 提示效率降低

            -加入时间Log 优化关闭效率
            -实时编译出错时可弹出具体错误


        修复:
            Gif生成第二个序列出错(概率) -> 未复现
            "文件夹无图片"会显示两次 -> Fixed (只显示一次)
            录制窗口小的时候显示不全 -> Fixed
            HistoryButton 拖拽到其他ToolStripButton上 Max快捷键失效 ->Fixed (其他侧边栏控件Enter += HistoryButton.DropDown.Close()))
            加载 小概率出错(<1/20) ToolStripEx加载失败? ->fixed (dotnet.setLifetimeControl相关 )
            
    2021-01-12(V1.01):
        -高分屏支持
        -合并Timer
        -整理Icon 删除不需要的Icon
        -低版本Max会提示不支持
        -录制Max 固定30fps

        版本测试:
            win7: 2014 2016 2017 2020
            win10: 2017(High DPI)

        修复:
            分辨率 读取与比例问题 ->Fixed
            录制窗口提示无效 ->Fixed

	2021-06-04(V1.02)
		-优化Gif生成速度 略微提高了Gif质量的参数

		修复:
			-WindowsBasic Aero关闭的模式下CopyFromScreen(BitBlt)不锁30帧 ->Fixed (DwmIsCompositionEnabled)
			-高分屏下 ∧ ∨ 字体问题 -> 改用 ▲ ▼
			-高分屏Rollout大小区别 -> Fixed （ScaleFactor) 
			-生成Gif内存泄漏 -> Fixed (创建了两个hBitmap)
			
	2021-06-09(V1.03)
		-加入功能说明
		-优化Gif功能(有效区域,重复帧) 增加分辨率选项
		-调整Gif质量参数 高下降 中低上升

	2021-08-03(V1.04)
		-调整Gif质量参数 整体调高 (1,4,10)

		修复:
			-修复2011-2012支持
				Max2011-2012不支持UTF8编码,为了同时支持Max2011-2012和不需设置Default Language,把中文转换成了IntArray
			-C#编译小概率会出现dotNet runtime exception: Could not find file 'C:\Users\Administrator\AppData\Local\Temp\mds22yj0\mds22yj0.dll
				暂时用trycatch处理了 会尝试编译5次 不行再报错
				

		版本测试:win7 2012 2014 2016 2020
	
	2021-08-11(V1.05)
		-添加录制鼠标
		-窗口过小时侧边栏随之缩小
		-修改一些界面文字 
			Gif面板:分辨率->尺寸
			将当前帧设为图像序列首帧 -> 将首张图像同步到此帧
			将当前图像序列帧设为0帧  -> 将当前图像同步到0帧
			设置:Credit->About
			添加商业使用说明
		-录制和播放最小尺寸现在受ScaleFactor影响
		-启动时清除历史记录中无效文件夹
		
		-修复录屏预览模式生成Gif尺寸不对的问题

		测试:win7 2012 2014 2016 2017 2020
			 win10 2017
			 
	2021-08-16(V1.06)
		-修复Max2019不出现侧边栏的问题(#MouseEnter 无效)
		-修复'将当前图像同步至0帧'的问题 使其与描述相符
		-修复设置->时间设置中 '将当前图像同步至0帧' 实际效果为 '将首张图像同步到此帧' 的问题
		

	TODO:
		设置素材Fps? -> 播放30fps素材以外的情况
		Gif低质量时缩减palette? 会不会导致闪烁?
		把快捷键传递给Max?
		Gif生成取消
		录制检测窗口大小? spy++ like
		GifCreator Erosion参数没有用到 删除?
		权限测试?
		检查WindowPos是否在屏幕内?

		测试WPF resize 速度
		更多 Win10 测试

    TOFIX:
		现在录制的预览界面可能会出现透过的情况
			设置BackColor会导致hittest不能透过窗口
			预览时更改录制窗口TransparencyKey会导致错误?
		录制Max时进入录像模式快速开始录制会判定失误 因为播放窗口未隐藏(在播放消失动画) WindowFromPoint会返回播放窗口
		配置低时打开设置闪烁?

	    次要:
            新打开录屏 闪一下 -> CreateParam?
            uifn_SetGridVisible 放在 cDisplay_UpdateGrid 里会不会不好(触发太频繁)
			
			



*/


(----  Check -----

	/* 版本检测:不支持2011以下 */
    if (MaxVersion())[1] < 13000 do 
	(
		local VersionNotSupport = ""
		for n in #(19981, 25903, 25345, 50, 48, 49, 49, 20197, 19979, 29256, 26412)  /* 不支持2011以下版本 */ do
		(
			IntVal = dotnetobject "System.Int32" n
			VersionNotSupport += (dotnetclass "System.Convert").ToChar IntVal
		)

		throw VersionNotSupport 
		--throw "\nThis script requires Max2011 or higher" 
	)
    
    /*
    local FirstRun =
    (
        iniFileDir  = getdir #plugcfg
        iniFileName = "RefPlayer2020.ini"
        inifilePath = iniFileDir + "\\" + iniFileName

        doesfileexist inifilePath == false
    )

    */
	/* TODO: test if this work 
		fn CheckAdministrator =
		(
			local WindowsIdentity = (dotnetclass "System.Security.Principal.WindowsIdentity").GetCurrent()
			local Principal = dotnetobject "System.Security.Principal.WindowsPrincipal" WindowsIdentity
			local Administrator = (dotnetclass "System.Security.Principal.WindowsBuiltInRole").Administrator
			
			Principal.IsInRole Administrator 
		)

		CheckAdministrator()
	*/

    
)

(----- REFPLAYER -----
    
	(----- Variables -----
    
		----------------------------
		--------- Setting  ---------
        ----------------------------

        local RPVersion /* 版本信息 */  = "V 1.06"
		local RPAllowMultiple    /* 允许多个运行 */  = off

		--[录制模式]:
		local RPRecorderTSColor    /*录制窗口顶部颜色*/  = color 50 50 60
		local RPRecorderBorderColor/*录制窗口边框颜色*/  = color 66 96 135
        local RPMaxRecordReslotion /*最大录制分辨率*/   = [960,960]
        local RPMinRecordReslotion /*最小录制分辨率*/   = [210,135]
        local RPMaxRecordSeconds   /*最大录制时长(秒)*/ = 20

		--[播放模式]:
        local RPMinPlayerReslotion /*播放模式最小窗口*/  = [135,135]
		local RPMinimizeAnimation  /*开启最小化动画*/ = on
        local RPUseHotKey           /* 开启热键 */    = off
        /******** 热键 ********\
            透明度：1 2 3 4
            时间轴：AD前后 S同步
            原始分辨率:R
            总在最前:T
            参考线:G
            覆盖视口:F
            打开当前文件夹:~
            打开历史记录 Q , H
		\**********************/
		
		--[侧边栏]:
        local RPToolStripShowDelay /*鼠标进入至显示时间(ms)*/ = 100
        local RPToolStripHideDelay /*鼠标离开至消失时间(ms)*/ = 300
        local RPLockButtonAutoHide /*锁定键自动隐藏*/ = off
        local RPGradientToolStrip /* 渐变底色 */   = on




		----------------------------
		---------- Structs ---------
        ----------------------------

        local Icons
		local SettingCtrl -- Load,Save

		----------------------------
		------ User Interface ------
        ----------------------------

        local ui_PlayerWindow
			local ui_PlayerPictureBox
			local ui_PlayerGridPictureBox
            local ui_PlayerGradient
            local ui_PlayerToolStrip
			local ui_PlaylistItemArray

        local ui_RecordWindow
        	local ui_RecordToolStrip

		local rcMenu_Display
		local rcMenu_Time

		-- UI Mode 
  
		local m_PlayerMode = 2
			local MODE_PLAYER_HOME     = 1
			local MODE_PLAYER_NORMAL    = 2
			local MODE_PLAYER_MINIMIZED = 3  

		local m_RecorderMode = 1
			local MODE_RECORDER_IDLE       = 1
			local MODE_RECORDER_RECORDING  = 2
			local MODE_RECORDER_PREVIEWING = 3

		local m_RecAssistMode = 1
			local MODE_ASSIST_NONE = 1
			local MODE_ASSIST_SPACE = 2
			local MODE_ASSIST_MEDIA = 3

        local RecordSetting_Rollout
        local PlayerSetting_Rollout
        local TimeSetting_Rollout
		local GridSetting_Rollout
        
		local s_Grid,s_Player,s_PlayList,s_RAM,s_Recorder
		----------------------------
		--- Initailze Finalize -----
        ----------------------------

		-- Initialize
        local init_RegisterMouseEvents
        local init_RegisterTSAutoHide
        local init_RegisterMinimize
        local init_RegisterSwitchUI
        local init_RegisterHotKey
        local init_PlayList
		local init_SetRecorderBorderColor

		-- Finalize
		local final_FreeImageDatas
        local final_FreeThumbs
        local final_FreeTSShadowBitmap

		----------------------------
		------- UI Functions -------
        ----------------------------

		-- Description
        local uifn_SetPlayerDes
		local uifn_SetTempPlayerDes
		local uifn_HidePlayerDes
		
        local uifn_SetRecorderDes
		local uifn_ResumeRecorderDes
		
		-- UI Events 
		local uifn_PlayerIsMinimize
		local uifn_MinimizeAnimPlaying
		local uifn_CaculateMinimizeSize
		
        local uifn_MinimizePlayer
        local uifn_PlayerToRecorder
        local uifn_RecorderToPlayer

        local uifn_EnableTSAutoHide
        local uifn_DisableTSAutoHide

        local uifn_ShowToolStrip
        local uifn_HideToolStrip

        local uifn_ShowTSGradient
        local uifn_HideTSGradient

        local uifn_ShowHomePanel
        local uifn_QuitHomePanel

		local uifn_OpenSetting
		local uifn_CloseSetting
		local uifn_OpenGifRollout
		local uifn_CloseGifRollout

        local uifn_ResizeToRatio
        local uifn_EnablePlayerZoom
        local uifn_DisablePlayerZoom

        local uifn_PlayerUIHomeMode
        local uifn_PlayerUINormalMode
        local uifn_PlayerUIMinimizedMode
        local uifn_PlayerUILockMode

        local uifn_RecorderIdleMode
        local uifn_RecorderRecordMode
        local uifn_RecorderPreviewMode

        local uifn_UpdatePlayerTS
        local uifn_SetRecorderMinMaxSize
		
		local uifn_ResizePlayerToolStrip
		
		----------------------------
		---------- Datas -----------
        ----------------------------
        local dFile_GetCurrFolder
		local dFile_GetImageCount
		local dFile_GetImageDatas
		local dFile_GetImageLoadRes
        local dDisplay_GetScaleRatio
		local dDisplay_SetLoadRes

		local dRec_GetRecordFolder
		local dRec_GetAssistanceType
        local dRec_SetAssistanceType
		local dRec_GetRecordFiles

		local dTime_GetStartTime
		local dTime_SetStartTime
		local dTIme_GetPlayerFps
		local dTime_SetPlayerFps
        local dTime_GetTimeDatas

		local dUI_IsDragging
		----------------------------
		-------  Functions ---------
        ----------------------------

        --ImageSequence
        local fFile_ReadFolder   
        local fFile_GetImage
        local fFile_Preload
        --PlayList
        local fFile_ReadPlayList 
        local fFile_SavePlayList
		--Recorder
        local fRec_StartRecord
        local fRec_StopRecord
        local fRec_GetRecordImage
        local fRec_DeleteRecordImage
        --Grid
        local fGrid_GenerateGridImage

		----------------------------
		---------- Ctrls -----------
        ----------------------------

		local cTime_GetCurrTimeImgIndex
		local cTime_SyncMaxTimeRange
        local cTime_SetCurrFrameAsStartTime
        local cTime_SetCurrImgAsFirstFrame
		local cTime_Forward
		local cTime_Backward

		local cRec_StartRecord
		local cRec_StopRecord
		local cRec_StartPreview
		local cRec_StopPreview


        local cDisplay_ScaleToRatio
		local cDisplay_IsGridOn
		local cDisplay_ToggleGridOn
		local cDisplay_UpdateGrid
		local cDisplay_IsAlwaysOnTop
		local cDisplay_ToggleAlwaysOnTop
		local cDisplay_GetOpacity
		local cDisplay_SetOpacity
		local cDisplay_FillViewport

    )

	(---- Utility ↓ ----
    
        (---- Common Use ----
            fn  DNPoint x y = dotnetobject "System.Drawing.Point" x y
            local PictureBoxSizeMode  = dotnetclass "PictureBoxSizeMode"
            local DockStyle           = dotnetclass "DockStyle"
			local Cursor              = dotnetclass "Cursor"

            local DNColor = dotnetclass "System.Drawing.Color"
            fn GrayScaleColor grayscale = DNColor.FromARGB grayscale grayscale grayscale
            fn RGBColor r g b = DNColor.FromARGB r g b

			fn DNFont Font FontSize Bold:false Italic:false =
			(
				local FontStyle = (dotnetclass "System.Drawing.FontStyle").Regular

				if Bold   do FontStyle = 
					dotnet.combineenums FontStyle (dotNetClass "system.drawing.fontStyle").Bold
				if Italic do FontStyle = 
					dotnet.combineenums FontStyle (dotNetClass "system.drawing.fontStyle").Italic

				dotnetobject "system.drawing.font" \
				(dotnetobject "system.drawing.fontfamily" Font) FontSize FontStyle
			)

			fn SolidBrush c = dotnetobject "System.Drawing.SolidBrush" c
			
            local ScaleFactor /* High DPI Support */ = if GetUIScaleFactor != undefined then GetUIScaleFactor() else 1 

			RPMinPlayerReslotion *= ScaleFactor
			RPMinRecordReslotion *= ScaleFactor

			/*
            
            local BackgroundWorker = DotNetObject "System.ComponentModel.BackgroundWorker"

            fn util_DoBGWork theFunc =
            (
                dotnet.addeventhandler BackgroundWorker #DoWork theFunc 
                
                BackgroundWorker.WorkerSupportsCancellation = false
                BackgroundWorker.RunWorkerAsync()
            )

			*/

            fn MouseInForm =
            (
                CursorPos = ui_PlayerWindow.PointToClient Cursor.Position
                FormRect  = ui_PlayerWindow.ClientRectangle
                
                bool_result = FormRect.Contains CursorPos
            )

        )

        (---- Debug TimeLog ----
            local DebugInfoString
            local Debug_StartTime
            local Debug_LastTime

            fn Debug_LogTimeStart =
            (
                DebugInfoString = "\n"
                Debug_StartTime = timestamp()
                Debug_LastTime  = timestamp()			
            )
            

            fn Debug_LogTime ProcName =
            (
                local currTime  = timestamp()
                local timeSpent = currTime - Debug_LastTime
                Debug_LastTime  = currTime

                local timeInfo = ProcName + ": " + timeSpent as string + "ms" + "\n"
                DebugInfoString += timeInfo
            )

            fn Debug_LogTimeEnd =
            (
                Debug_LastTime = Debug_StartTime
                DebugInfoString += "\n"
                Debug_LogTime "Total"
            )

            Debug_LogTimeStart()
        )

		(---- ViewPort Redraw ----
            local SceneRedrawDisabled = false 

            fn util_DisableSceneRedraw =
            (
                if not SceneRedrawDisabled do
                (
                    DisableSceneRedraw()
                    SceneRedrawDisabled = true
                )
            )

            fn util_EnableSceneRedraw =
            (
                if SceneRedrawDisabled do 
                (
                    EnableSceneRedraw()
                    SceneRedrawDisabled = false
                )
            )
        )
        
        (---- Timer ----
            local util_Timer = dotnetobject "Timer"
            util_Timer.interval = 1

            local util_TimerInterval = util_Timer.interval + 15

            fn util_StartTimer =
            (
                util_Timer.Start()
            )

            fn util_StopTimer =
            (
                util_Timer.Stop()
            )

            local TimerEvents = #()

            fn util_RegisterTimerEvent TickEvent =
            (
                struct TimerEvent(Enabled = false,TickEvent)

                NewEvent = TimerEvent TickEvent:TickEvent
                append TimerEvents NewEvent

                NewEvent
            )

            dotnet.addeventHandler util_Timer #Tick (fn _TimerTickEvents sender eventArgs =
            (
                local EventsToTrigger = for ev in TimerEvents where ev.Enabled collect ev.TickEvent

                if EventsToTrigger.count == 0  then util_Timer.Stop()
                else (
                        for ev in EventsToTrigger do 
                        (
                            try(
                                ev()
                            )
                            catch(
                                util_StopTimer()

                                local ErrorMsg = "TimerEvent Error:\n"
                                ErrorMsg += "EventsToTrigger:"  + EventsToTrigger as string + "\n"
                                ErrorMsg += "ev:" + (ev as string) + "\n"
                                ErrorMsg += getcurrentException()
                                MessageBox ErrorMsg
                            )
                        )
                    )
            ))

            fn Debug_TimerStatus =
            (
                local s = "Timer Status:"
                s += "isRunning:" + util_Timer.Enabled as string + "\n"

                for ev in TimerEvents do
                (
                    s += ev as string
                    s += "\n"
                )

                s += "\n"

                print s
            )

        )

		/* Debug */ Debug_LogTime "Utility"
	)

	(----- Resource -----
        /*
		
        struct Resource_Chinese
        (
            ----- GifCreation -----
            GIF_INIT_COMPLETE         = "初始化完成",
            GIF_PROCESSING_FRAME      = "处理帧:{0}/{1}",
            GIF_CACULATE_VALID_REGION = "计算有效帧区域...",
            GIF_PREPARE_TO_ADD_FRAME  = "准备添加帧到Gif...",
            GIF_ADDING_FRAME          = "添加帧:{0}/{1}",
            GIF_GENERATING_GIF        = "生成Gif...",
            GIF_SAVEGIF_TO_FILE       = "存储至文件...",

            ----- Record -----

            REC_RECORD = "录制",
            REC_RECORD_TOOLTIP_NORMAL   = "开始录制",
            REC_RECORD_TOOLTIP_SPACEKEY = "开始录制(辅助:空格)",
            REC_RECORD_TOOLTIP_MEDIAKEY = "开始录制(辅助:媒体键)",
            REC_RECORD_TOOLTIP_MAXMODE  = "开始录制(Max模式)",

            REC_STOP         = "停止",
            REC_STOP_TOOLTIP = "停止录制",

			REC_SETTING_TOOLTIP = "设置(保存路径,录制辅助)",

            REC_ABORT         = "重录",
            REC_ABORT_TOOLTIP = "放弃当前预览内容,返回录制",

			REC_FINISH = "完成",
			REC_FINISH_TOOLTIP = "结束录制,返回播放模式",

            REC_RETURN_TO_PLAYER         = "返回",
            REC_RETURN_TO_PLAYER_TOOLTIP = "返回播放模式",



			REC_GIF = "GIF",
			REC_GIF_TOOLTIP = "生成Gif",

            ----- Player Sidebar -----

            PLAYER_CLOSE            = "X",
            PLAYER_CLOSE_TOOLTIP    = "关闭",

            PLAYER_MINIMIZE_CLOSED         = "▲",
            PLAYER_MINIMIZE_CLOSED_TOOLTIP = "缩小",
            PLAYER_MINIMIZE_OPEN    = "▼",

            PLAYER_RECORDER         = "录屏",
            PLAYER_RECORDER_TOOLTIP = "进入录屏模式",

            PLAYER_HISTORY          = "历史",
            PLAYER_HISTORY_TOOLTIP  = "历史记录",

            PLAYER_PRELOAD          = "加载",
            PLAYER_PRELOAD_TOOLTIP  = "预加载,提升预览速度",

            PLAYER_SETTING          = "设置",
            PLAYER_SETTING_TOOLTIP  = "打开设置界面",

            PLAYER_GIF              = "GIF",
            PLAYER_GIF_TOOLTIP      = "生成Gif",

            ----- Home Panel -----

            HOME_TITLE                = "参考大师",
            HOME_DRAGAREA_TITLE       = "拖拽区",
            HOME_DRAGAREA_TEXT        = "(拖拽图像文件至窗口)",
            HOME_DRAGAREA_DESCRIPTION = "录制分辨率最高{0}*{1} 录制时长{2}秒",

            HOME_TUTORIAL = "教程",
            HOME_COMPANY  = "长春伯仲",
            HOME_CLINICAL = "临床动画学",

            ----- Error ------
			ERROR_FOLDER_NOT_EXIST = "文件夹不存在",
            ERROR_NO_IMAGE_FILE = "文件夹无图片",

            -----Gif Rollout -----
            SETTING_GIF_TITLE   = "生成Gif",

            SETTING_GIF_QUALITY_GROUP  = "质量",
            SETTING_GIF_QUALITY_HIGH   = "高  ",
            SETTING_GIF_QUALITY_MEDIUM = "中  ",
            SETTING_GIF_QUALITY_LOW    = "低  ",

            SETTING_GIF_RESOLUTION_GROUP      = "尺寸",
            SETTING_GIF_RESOLUTION_IMAGE      = "原始素材尺寸",
            SETTING_GIF_RESOLUTION_PLAYERSIZE = "当前窗口尺寸",

            SETTING_GIF_GENERATE_GROUP = "生成",
            SETTING_GIF_GENERATE_START = "开始生成",
            
            SETTING_GIF_OPEN_GROUP = "操作",
            SETTING_GIF_OPEN_GIF   = "打开Gif",
            SETTING_GIF_OPEN_DIR   = "打开路径",

            SETTING_GIF_SHOW_FILE_SIZE =  "完成 文件大小:",


			----- Setting -----

			SETTING_TITILE = "设置",

			-----Record Rollout -----

			SETTING_REC_TITLE         = "录制设置",
			SETTING_REC_OUTPUT_FOLDER = "输出文件夹:",
			SETTING_REC_OPEN          =  "打开",

			SETTING_REC_RECORDMOUSE    = "录制鼠标:",
			SETTING_REC_RECORDMOUSE_ON = "开启",

			SETTING_REC_ASSIST        = "录制辅助:",
			SETTING_REC_ASSIST_NONE     = "无",
			SETTING_REC_ASSIST_SPACEKEY = "空格键",
			SETTING_REC_ASSIST_MEDIAKEY = "媒体播放键",

			SETTING_REC_ASSIST_SPACEKEY_DESCRIPTION = "按下录制键时,向录制框中心的窗口发送空格",
			SETTING_REC_ASSIST_MEDIAKEY_DESCRIPTION = "按下录制键时,向录制框中心的窗口发送媒体播放键,WIN10或本地播放器推荐",

			----- Player Rollout -----

			SETTING_PLAYER_TITLE  = "播放设置",

			SETTING_PLAYER_RAM_GROUP = "最高内存占用:",
			SETTING_PLAYER_RAM_DYNAMIC = "动态",
			SETTING_PLAYER_RAM_STATIC  = "固定",
			SETTING_PLAYER_RAM_MAXPERCENTAGE = "剩余内存的百分之",
			SETTING_PLAYER_RAM_MAXRAM         = "最大内存占用(MB):",

			SETTING_PLAYER_OPACITY_GROUP = "不透明度:",

			----- Time Rollout ------
			SETTING_TIME_TITLE  = "时间设置",

			SETTING_TIME_STATUS_GROUP   = "状态:",
			SETTING_TIME_STATUS_START   = "起始:",
			SETTING_TIME_STATUS_END     = "结束:",

			SETTING_TIME_SYNC_GROUP    = "同步:",
			SETTING_TIME_CURRENT_FRAME = "当前帧:",
			SETTING_TIME_START_FRAME   = "起始帧:",
			
			SYNC_MAX_TIMERANGE                   = "同步时间轴",
			SYNC_SET_CURRENT_FRAME_AS_START_TIME = "将首张图像同步到此帧",
			SYNC_SET_CURRENT_IMG_AS_ZERO_FRAME   = "将当前图像同步到0帧",

			----- Grid Rollout -----
			SETTING_GRID_TITILE  = "参考线设置",

			SETTING_GRID_ENABLE  = "开启参考线",

			SETTING_GRID_OPACITY = "不透明度:",
			SETTING_GRID_COLOR   = "颜色:",

			SETTING_GRID_COUNT_GROUP = "格子数量:",
			SETTING_GRID_HORIZONTAL = "横:",
			SETTING_GRID_VERTICAL   = "竖:",


			----- Player Controls -----

			PLAYER_FILE_OPEN = "打开:",

			PLAYER_TIME_CURRENT    = "当前:",
			PLAYER_TIME_STARTFRAME = "开始帧:",
			PLAYER_TIME_ENDFRAME   = " 结束帧:",
			PLAYER_TIME_FORWARD    = "向前一帧 ",
			PLAYER_TIME_BACKWARD   = "向后一帧 ",
			

			PLAYER_OPACITY       = "不透明度:",
			PLAYER_OPACITY_1     = "不透明度100%",
			PLAYER_OPACITY_2     = "不透明度75%",
			PLAYER_OPACITY_3     = "不透明度50%",
			PLAYER_OPACITY_4     = "不透明度25%",
			
			PLAYER_ORIGINALRES   = "原始分辨率",

			PLAYER_GRID_ON  = "显示参考线",
			PLAYER_GRID_OFF = "隐藏参考线",

			PLAYER_ALWAYS_ON_TOP_ON  = "总在最前",
			PLAYER_ALWAYS_ON_TOP_OFF = "取消总在最前",

			PLAYER_FILL_VIEWPORT_ON  = "覆盖视口",
			PLAYER_FILL_VIEWPORT_OFF = "取消覆盖视口",

			--About Rollout
			ABOUT_AUTHOR     = "By: 永泽",
			ABOUT_COPYRIGHT  = "CopyRight: 长春伯仲",
			ABOUT_BUSINESS_1 = "本插件仅供学习交流使用",
			ABOUT_BUSINESS_2 = "如需商业授权及合作 联系QQ:138988114",
			
			__SETTTING_END__ = ""
        )

		fn MakeOutputResource sResource Lang =
		(
			local ResourceOutputString = "if language == " + Lang + " do\n(\n"
			
			local CharToInt32 = (dotnetclass "System.Convert").ToInt32 
			local Resource  = sResource()
			local PropNames = getpropnames Resource
			sort  PropNames
			
			for p = 1 to PropNames.count do
			(
				local propname = PropNames[p]
				local ResourceString  = getproperty Resource propname
				local IntArrayString  = #() 
				IntArrayString.count = ResourceString.count
				
				for i = 1 to ResourceString.count do
				(
					local char = dotnetobject "System.Char" ResourceString[i]
					IntArrayString[i] = CharToInt32 char
				)
				
				with PrintAllElements on
				(
					ResourceOutputString += 
						"	" + propname as string + " = IntArrayToString " + (IntArrayString as string) + "\n"
				)
				
			)
			
			ResourceOutputString += "\n)"
		)
		
		ResourceOutputString = ""
		ResourceOutputString += MakeOutputResource Resource_Chinese "Chinese"
		setclipboardText ResourceOutputString
        
        */
		local IntToChar = (dotnetclass "System.Convert").ToChar
		local Int32     = dotnetclass "System.Int32"
		
		fn IntArrayToString intArray = 
		(
			local Result = "" 
			
			for i = 1 to intArray.count do
			(
				local intval = dotnet.ValueToDotNetObject intArray[i] Int32
				local char =  IntToChar intval
				
				Result += char
			)

			Result
		)
		
		/*TODO: Add more language? */
		
		local Chinese  = 1
		local language = Chinese
		
		if language == Chinese do
		(
			ABOUT_AUTHOR = IntArrayToString #(66, 121, 58, 32, 27704, 27901)
			ABOUT_BUSINESS_1 = IntArrayToString #(26412, 25554, 20214, 20165, 20379, 23398, 20064, 20132, 27969, 20351, 29992)
			ABOUT_BUSINESS_2 = IntArrayToString #(22914, 38656, 21830, 19994, 25480, 26435, 21450, 21512, 20316, 32, 32852, 31995, 81, 81, 58, 49, 51, 56, 57, 56, 56, 49, 49, 52)
			ABOUT_COPYRIGHT = IntArrayToString #(67, 111, 112, 121, 82, 105, 103, 104, 116, 58, 32, 38271, 26149, 20271, 20210)
			ERROR_FOLDER_NOT_EXIST = IntArrayToString #(25991, 20214, 22841, 19981, 23384, 22312)
			ERROR_NO_IMAGE_FILE = IntArrayToString #(25991, 20214, 22841, 26080, 22270, 29255)
			GIF_ADDING_FRAME = IntArrayToString #(28155, 21152, 24103, 58, 123, 48, 125, 47, 123, 49, 125)
			GIF_CACULATE_VALID_REGION = IntArrayToString #(35745, 31639, 26377, 25928, 24103, 21306, 22495, 46, 46, 46)
			GIF_GENERATING_GIF = IntArrayToString #(29983, 25104, 71, 105, 102, 46, 46, 46)
			GIF_INIT_COMPLETE = IntArrayToString #(21021, 22987, 21270, 23436, 25104)
			GIF_PREPARE_TO_ADD_FRAME = IntArrayToString #(20934, 22791, 28155, 21152, 24103, 21040, 71, 105, 102, 46, 46, 46)
			GIF_PROCESSING_FRAME = IntArrayToString #(22788, 29702, 24103, 58, 123, 48, 125, 47, 123, 49, 125)
			GIF_SAVEGIF_TO_FILE = IntArrayToString #(23384, 20648, 33267, 25991, 20214, 46, 46, 46)
			HOME_CLINICAL = IntArrayToString #(20020, 24202, 21160, 30011, 23398)
			HOME_COMPANY = IntArrayToString #(38271, 26149, 20271, 20210)
			HOME_DRAGAREA_DESCRIPTION = IntArrayToString #(24405, 21046, 20998, 36776, 29575, 26368, 39640, 123, 48, 125, 42, 123, 49, 125, 32, 24405, 21046, 26102, 38271, 123, 50, 125, 31186)
			HOME_DRAGAREA_TEXT = IntArrayToString #(40, 25302, 25341, 22270, 20687, 25991, 20214, 33267, 31383, 21475, 41)
			HOME_DRAGAREA_TITLE = IntArrayToString #(25302, 25341, 21306)
			HOME_TITLE = IntArrayToString #(21442, 32771, 22823, 24072)
			HOME_TUTORIAL = IntArrayToString #(25945, 31243)
			PLAYER_ALWAYS_ON_TOP_OFF = IntArrayToString #(21462, 28040, 24635, 22312, 26368, 21069)
			PLAYER_ALWAYS_ON_TOP_ON = IntArrayToString #(24635, 22312, 26368, 21069)
			PLAYER_CLOSE = IntArrayToString #(88)
			PLAYER_CLOSE_TOOLTIP = IntArrayToString #(20851, 38381)
			PLAYER_FILE_OPEN = IntArrayToString #(25171, 24320, 58)
			PLAYER_FILL_VIEWPORT_OFF = IntArrayToString #(21462, 28040, 35206, 30422, 35270, 21475)
			PLAYER_FILL_VIEWPORT_ON = IntArrayToString #(35206, 30422, 35270, 21475)
			PLAYER_GIF = IntArrayToString #(71, 73, 70)
			PLAYER_GIF_TOOLTIP = IntArrayToString #(29983, 25104, 71, 105, 102)
			PLAYER_GRID_OFF = IntArrayToString #(38544, 34255, 21442, 32771, 32447)
			PLAYER_GRID_ON = IntArrayToString #(26174, 31034, 21442, 32771, 32447)
			PLAYER_HISTORY = IntArrayToString #(21382, 21490)
			PLAYER_HISTORY_TOOLTIP = IntArrayToString #(21382, 21490, 35760, 24405)
			PLAYER_MINIMIZE_CLOSED = IntArrayToString #(9650)
			PLAYER_MINIMIZE_CLOSED_TOOLTIP = IntArrayToString #(32553, 23567)
			PLAYER_MINIMIZE_OPEN = IntArrayToString #(9660)
			PLAYER_OPACITY = IntArrayToString #(19981, 36879, 26126, 24230, 58)
			PLAYER_OPACITY_1 = IntArrayToString #(19981, 36879, 26126, 24230, 49, 48, 48, 37)
			PLAYER_OPACITY_2 = IntArrayToString #(19981, 36879, 26126, 24230, 55, 53, 37)
			PLAYER_OPACITY_3 = IntArrayToString #(19981, 36879, 26126, 24230, 53, 48, 37)
			PLAYER_OPACITY_4 = IntArrayToString #(19981, 36879, 26126, 24230, 50, 53, 37)
			PLAYER_ORIGINALRES = IntArrayToString #(21407, 22987, 20998, 36776, 29575)
			PLAYER_PRELOAD = IntArrayToString #(21152, 36733)
			PLAYER_PRELOAD_TOOLTIP = IntArrayToString #(39044, 21152, 36733, 44, 25552, 21319, 39044, 35272, 36895, 24230)
			PLAYER_RECORDER = IntArrayToString #(24405, 23631)
			PLAYER_RECORDER_TOOLTIP = IntArrayToString #(36827, 20837, 24405, 23631, 27169, 24335)
			PLAYER_SETTING = IntArrayToString #(35774, 32622)
			PLAYER_SETTING_TOOLTIP = IntArrayToString #(25171, 24320, 35774, 32622, 30028, 38754)
			PLAYER_TIME_BACKWARD = IntArrayToString #(21521, 21518, 19968, 24103, 32)
			PLAYER_TIME_CURRENT = IntArrayToString #(24403, 21069, 58)
			PLAYER_TIME_ENDFRAME = IntArrayToString #(32, 32467, 26463, 24103, 58)
			PLAYER_TIME_FORWARD = IntArrayToString #(21521, 21069, 19968, 24103, 32)
			PLAYER_TIME_STARTFRAME = IntArrayToString #(24320, 22987, 24103, 58)
			REC_ABORT = IntArrayToString #(37325, 24405)
			REC_ABORT_TOOLTIP = IntArrayToString #(25918, 24323, 24403, 21069, 39044, 35272, 20869, 23481, 44, 36820, 22238, 24405, 21046)
			REC_FINISH = IntArrayToString #(23436, 25104)
			REC_FINISH_TOOLTIP = IntArrayToString #(32467, 26463, 24405, 21046, 44, 36820, 22238, 25773, 25918, 27169, 24335)
			REC_GIF = IntArrayToString #(71, 73, 70)
			REC_GIF_TOOLTIP = IntArrayToString #(29983, 25104, 71, 105, 102)
			REC_RECORD = IntArrayToString #(24405, 21046)
			REC_RECORD_TOOLTIP_MAXMODE = IntArrayToString #(24320, 22987, 24405, 21046, 40, 77, 97, 120, 27169, 24335, 41)
			REC_RECORD_TOOLTIP_MEDIAKEY = IntArrayToString #(24320, 22987, 24405, 21046, 40, 36741, 21161, 58, 23186, 20307, 38190, 41)
			REC_RECORD_TOOLTIP_NORMAL = IntArrayToString #(24320, 22987, 24405, 21046)
			REC_RECORD_TOOLTIP_SPACEKEY = IntArrayToString #(24320, 22987, 24405, 21046, 40, 36741, 21161, 58, 31354, 26684, 41)
			REC_RETURN_TO_PLAYER = IntArrayToString #(36820, 22238)
			REC_RETURN_TO_PLAYER_TOOLTIP = IntArrayToString #(36820, 22238, 25773, 25918, 27169, 24335)
			REC_SETTING_TOOLTIP = IntArrayToString #(35774, 32622, 40, 20445, 23384, 36335, 24452, 44, 24405, 21046, 36741, 21161, 41)
			REC_STOP = IntArrayToString #(20572, 27490)
			REC_STOP_TOOLTIP = IntArrayToString #(20572, 27490, 24405, 21046)
			SETTING_GIF_GENERATE_GROUP = IntArrayToString #(29983, 25104)
			SETTING_GIF_GENERATE_START = IntArrayToString #(24320, 22987, 29983, 25104)
			SETTING_GIF_OPEN_DIR = IntArrayToString #(25171, 24320, 36335, 24452)
			SETTING_GIF_OPEN_GIF = IntArrayToString #(25171, 24320, 71, 105, 102)
			SETTING_GIF_OPEN_GROUP = IntArrayToString #(25805, 20316)
			SETTING_GIF_QUALITY_GROUP = IntArrayToString #(36136, 37327)
			SETTING_GIF_QUALITY_HIGH = IntArrayToString #(39640, 32, 32)
			SETTING_GIF_QUALITY_LOW = IntArrayToString #(20302, 32, 32)
			SETTING_GIF_QUALITY_MEDIUM = IntArrayToString #(20013, 32, 32)
			SETTING_GIF_RESOLUTION_GROUP = IntArrayToString #(23610, 23544)
			SETTING_GIF_RESOLUTION_IMAGE = IntArrayToString #(21407, 22987, 32032, 26448, 23610, 23544)
			SETTING_GIF_RESOLUTION_PLAYERSIZE = IntArrayToString #(24403, 21069, 31383, 21475, 23610, 23544)
			SETTING_GIF_SHOW_FILE_SIZE = IntArrayToString #(23436, 25104, 32, 25991, 20214, 22823, 23567, 58)
			SETTING_GIF_TITLE = IntArrayToString #(29983, 25104, 71, 105, 102)
			SETTING_GRID_COLOR = IntArrayToString #(39068, 33394, 58)
			SETTING_GRID_COUNT_GROUP = IntArrayToString #(26684, 23376, 25968, 37327, 58)
			SETTING_GRID_ENABLE = IntArrayToString #(24320, 21551, 21442, 32771, 32447)
			SETTING_GRID_HORIZONTAL = IntArrayToString #(27178, 58)
			SETTING_GRID_OPACITY = IntArrayToString #(19981, 36879, 26126, 24230, 58)
			SETTING_GRID_TITILE = IntArrayToString #(21442, 32771, 32447, 35774, 32622)
			SETTING_GRID_VERTICAL = IntArrayToString #(31446, 58)
			SETTING_PLAYER_OPACITY_GROUP = IntArrayToString #(19981, 36879, 26126, 24230, 58)
			SETTING_PLAYER_RAM_DYNAMIC = IntArrayToString #(21160, 24577)
			SETTING_PLAYER_RAM_GROUP = IntArrayToString #(26368, 39640, 20869, 23384, 21344, 29992, 58)
			SETTING_PLAYER_RAM_MAXPERCENTAGE = IntArrayToString #(21097, 20313, 20869, 23384, 30340, 30334, 20998, 20043)
			SETTING_PLAYER_RAM_MAXRAM = IntArrayToString #(26368, 22823, 20869, 23384, 21344, 29992, 40, 77, 66, 41, 58)
			SETTING_PLAYER_RAM_STATIC = IntArrayToString #(22266, 23450)
			SETTING_PLAYER_TITLE = IntArrayToString #(25773, 25918, 35774, 32622)
			SETTING_REC_ASSIST = IntArrayToString #(24405, 21046, 36741, 21161, 58)
			SETTING_REC_ASSIST_MEDIAKEY = IntArrayToString #(23186, 20307, 25773, 25918, 38190)
			SETTING_REC_ASSIST_MEDIAKEY_DESCRIPTION = IntArrayToString #(25353, 19979, 24405, 21046, 38190, 26102, 44, 21521, 24405, 21046, 26694, 20013, 24515, 30340, 31383, 21475, 21457, 36865, 23186, 20307, 25773, 25918, 38190, 44, 87, 73, 78, 49, 48, 25110, 26412, 22320, 25773, 25918, 22120, 25512, 33616)
			SETTING_REC_ASSIST_NONE = IntArrayToString #(26080)
			SETTING_REC_ASSIST_SPACEKEY = IntArrayToString #(31354, 26684, 38190)
			SETTING_REC_ASSIST_SPACEKEY_DESCRIPTION = IntArrayToString #(25353, 19979, 24405, 21046, 38190, 26102, 44, 21521, 24405, 21046, 26694, 20013, 24515, 30340, 31383, 21475, 21457, 36865, 31354, 26684)
			SETTING_REC_OPEN = IntArrayToString #(25171, 24320)
			SETTING_REC_OUTPUT_FOLDER = IntArrayToString #(36755, 20986, 25991, 20214, 22841, 58)
			SETTING_REC_RECORDMOUSE = IntArrayToString #(24405, 21046, 40736, 26631, 58)
			SETTING_REC_RECORDMOUSE_ON = IntArrayToString #(24320, 21551)
			SETTING_REC_TITLE = IntArrayToString #(24405, 21046, 35774, 32622)
			SETTING_TIME_CURRENT_FRAME = IntArrayToString #(24403, 21069, 24103, 58)
			SETTING_TIME_START_FRAME = IntArrayToString #(36215, 22987, 24103, 58)
			SETTING_TIME_STATUS_END = IntArrayToString #(32467, 26463, 58)
			SETTING_TIME_STATUS_GROUP = IntArrayToString #(29366, 24577, 58)
			SETTING_TIME_STATUS_START = IntArrayToString #(36215, 22987, 58)
			SETTING_TIME_SYNC_GROUP = IntArrayToString #(21516, 27493, 58)
			SETTING_TIME_TITLE = IntArrayToString #(26102, 38388, 35774, 32622)
			SETTING_TITILE = IntArrayToString #(35774, 32622)
			SYNC_MAX_TIMERANGE = IntArrayToString #(21516, 27493, 26102, 38388, 36724)
			SYNC_SET_CURRENT_FRAME_AS_START_TIME = IntArrayToString #(23558, 39318, 24352, 22270, 20687, 21516, 27493, 21040, 27492, 24103)
			SYNC_SET_CURRENT_IMG_AS_ZERO_FRAME = IntArrayToString #(23558, 24403, 21069, 22270, 20687, 21516, 27493, 21040, 48, 24103)

		)
		
		
		
	)

    (---- RP_Ctrl ----
		local RP_Start,RP_Update,RP_OpenFile,RP_Quit
		
		local LastDisplayIndex = 0

        fn RP_Update =
		(
			if m_PlayerMode == MODE_PLAYER_NORMAL do(
				
				local index = cTime_GetCurrTimeImgIndex()
				
				if index != LastDisplayIndex do
				(
					local image = fFile_GetImage index
					ui_PlayerPictureBox.image = image
					
					LastDisplayIndex = index
					ui_PlayerWindow.Refresh()

				)
			)
		)

		fn RP_Start =
		(
			if ::RefPlayer_Close != undefined do ::RefPlayer_Close()
			/* Debug */Debug_LogTime "Start:CloseLast"															
            uifn_ShowHomePanel()

			/* Debug */Debug_LogTime "Start:ShowHomePanel"
			--init_RegisterMouseEvents()
			init_RegisterMinimize()
			init_RegisterSwitchUI()
			init_RegisterTSAutoHide()
			init_PlayList()
			
			init_RegisterHotKey()
			init_SetRecorderBorderColor()
			
			uifn_ResizePlayerToolStrip()
			
			/* Debug */Debug_LogTime "Start:InitRegisterEvents"

            local thePtr  = DotNetObject "System.IntPtr" (windows.getMAXHWND())
            local theHwnd = DotNetObject "RefPlayer.Win32HandleWrapper" thePtr
            ui_PlayerWindow.Show(theHwnd)	
			


			/* Debug */Debug_LogTime "Start:ShowPlayerForm"
			SettingCtrl.Load s_Player

            RegisterTimeCallBack RP_Update

			if not RPAllowMultiple do
				global RefPlayer_Close = (fn _CloseThisRefPlayer = RP_Quit())

			/* Debug */Debug_LogTime "Start:LoadPos,RegisterTimeCallback"
			/* Debug */Debug_LogTimeEnd()
		)

		fn RP_OpenFile thepath =
		(
			if (fFile_ReadFolder thepath) then
			(
				if m_PlayerMode == MODE_PLAYER_HOME do uifn_QuitHomePanel()
				LastDisplayIndex = 0
				RP_Update()
				--fFile_SavePlayList() /* Keep Ratio When ReLoaded */

				true
			)else false
		)

		local IsQuiting = false
		
		fn RP_Quit =
		(
			if IsQuiting do return()

			IsQuiting = true

			util_EnableSceneRedraw()
			ui_PlayerWindow.Hide()

			fFile_SavePlayList()

			SettingCtrl.Save s_Player

			uifn_CloseSetting()
			uifn_CloseGifRollout()

            ui_PlayerWindow.Close()
			ui_RecordWindow.Close()

			final_FreeImageDatas()
            final_FreeTSShadowBitmap()
            final_FreeThumbs()

			Icons.Dispose()
			
			UnRegisterTimeCallBack RP_Update 
		)

		/* Debug */Debug_LogTime "RPCtrls"

    )

    (---- Setting ----

        struct RefPlayer_PlayListSetting
        (
            Category = "PlayList",
            History01,History02,History03,History04,History05,
            History06,History07,History08,History09,History10
        )

        struct RefPlayer_PlayerSetting
        (
            Category = "PlayerSetting",
            pos_x,pos_y
        )

        struct RefPlayer_RAMSetting
        (
            Category = "RAMSetting",
            MaxRAM_Mode,MaxRAM_Percentage,MaxRAM_Usage
        )

        struct RefLayer_RecorderSettting
        (
            Category = "RecordSetting",
            RecordSavePath,AssistanceMode,RecordMouse
        )

        struct RefPlayer_GridSetting
        (
            Category = "GridSetting",
            Enabled,Color,Opacity,HorizontalCount,VerticalCount
        )

        s_PlayList = RefPlayer_PlayListSetting()
        s_Player   = RefPlayer_PlayerSetting()
        s_RAM      = RefPlayer_RAMSetting()
        s_Recorder = RefLayer_RecorderSettting()
        s_Grid     = RefPlayer_GridSetting()

        struct sSettingCtrl
        (
            private

            fn GetIniFile =
            (
                iniFileDir  = getdir #plugcfg
                iniFileName = "RefPlayer2020.ini"

                inifilePath = iniFileDir + "\\" + iniFileName
            ),
            
            iniFile = GetIniFile(),
            
            fn ReadValFrom PropVal_string =
            (
                if PropVal_string == "" do return undefined
                    
                try(Execute PropVal_string)catch(PropVal_string)
            ),
            
            fn GetSavingProp InputStruct =
            (
                for prop in getpropnames InputStruct where classof (getproperty InputStruct prop) == ValueRef collect prop
            ),

            public
            
            fn Load InputStruct =
            (
                Category = InputStruct.category
                
                for prop in (GetSavingProp InputStruct) do 
                (
                    PropertyToLoad = GetProperty InputStruct prop
                    PropVal_string = getINISetting iniFile Category prop
                    
                    if ReadValFrom PropVal_string != undefined do 
                    (
                        *PropertyToLoad = ReadValFrom PropVal_string
                    )
                )
            ),
            
            fn Save InputStruct =
            (
                Category = InputStruct.category
                
                for prop in (GetSavingProp InputStruct) do 
                (
                    PropertyToSave = GetProperty InputStruct prop
                    
                    setINISetting iniFile Category prop (*PropertyToSave as string)
                )
            )
        )

        SettingCtrl = sSettingCtrl()

		/* Debug */Debug_LogTime "Setting"
    )

	(---- C# Code  ----
		fn CompileCSharpCode =
		(
			RecorderForm =
			"
			using System;
			using System.Drawing;
			using System.Windows.Forms;


			namespace RefPlayer
			{
				public class Win32HandleWrapper : System.Windows.Forms.IWin32Window
				{
					public Win32HandleWrapper(IntPtr handle)
					{
						_hwnd = handle;
					}
					
					public IntPtr Handle
					{
						get { return _hwnd; }
					}

					private IntPtr _hwnd;
				}
				
				public class ToolStripEX : ToolStrip
				{
					public ToolStripEX()
					{ 
						this.GripStyle = ToolStripGripStyle.Hidden;
						this.AutoSize = true;
						this.BackColor = Color.FromArgb(50, 50, 60);
						//this.RenderMode = ToolStripRenderMode.ManagerRenderMode;
						this.Enabled = true;
						//this.Renderer = new CustomProfessionalColors();
						//ToolStripManager.Renderer = new CustomProfessionalColors();

						this.Paint += ToolStripEX_Paint;
					}

					private void ToolStripEX_Paint(object sender, PaintEventArgs e)
					{
						Rectangle rect = new Rectangle(0, 0, this.Width - 2, this.Height - 2);
						e.Graphics.SetClip(rect);
					}

                    public bool clickThrough = false;

					protected override void WndProc(ref Message m)
					{
                        const int WM_NCHITTEST = 0x0084;
                        const int HTTRANSPARENT = (-1);

                        if (m.Msg == WM_NCHITTEST && clickThrough)
                        {
                            m.Result = (IntPtr)HTTRANSPARENT;
                        }
						else if (m.Msg == 0x0021) // WM_MOUSEACTIVATE
						{
							base.WndProc(ref m);
							// Force result to be MA_ACTIVATE rather than MA_ACTIVATEANDEAT or MA_NOACTIVATE
							m.Result = (IntPtr)1; // MA_ACTIVATE
						}
                        else
                        {
						    base.WndProc(ref m);
                        }
					}
					
				
					class CustomProfessionalColors : ToolStripProfessionalRenderer
					{
						protected override void OnRenderMenuItemBackground(ToolStripItemRenderEventArgs e)
						{
							if (e.Item.Selected)
							{
								using (Brush b = new SolidBrush(ProfessionalColors.SeparatorLight))
								{
									e.Graphics.FillEllipse(b, e.Item.ContentRectangle);
								}
							}
							else
							{
								using (Pen p = new Pen(ProfessionalColors.SeparatorLight))
								{
									e.Graphics.DrawEllipse(p, e.Item.ContentRectangle);
								}
							}
						}
					}
				}

				public partial class RecordWindow : Form
				{

					public Brush borderBrush = new SolidBrush(Color.FromArgb(66, 96, 135));
					public ToolStripEX toolStrip;
					
					public ToolStripButton deleteButton;
					public ToolStripLabel resLabel;
					
					public BORDERS Borders { get { return new BORDERS(this.ClientSize.Width, this.ClientSize.Height, toolStrip.Height); } }
					public FormEvents formEvents;

					private const int CornerTolerance = 10;
					private const int borderWidth = 3;

					public RecordWindow()
					{
						this.FormBorderStyle = FormBorderStyle.None; 
						this.DoubleBuffered = true;
						this.SetStyle(ControlStyles.ResizeRedraw, true); // this is to avoid visual artifacts
						this.TransparencyKey = this.BackColor;
						this.TopMost = true;
					}

					private void ToolStrip_Paint(object sender, PaintEventArgs e) 
					{ 
						Rectangle rect = new Rectangle(0, 0, this.toolStrip.Width - 2, this.toolStrip.Height - 2);
						e.Graphics.SetClip(rect); 
					}


					protected override void OnPaint(PaintEventArgs e) 
					{
						e.Graphics.FillRectangle(borderBrush, Borders.Top);
						e.Graphics.FillRectangle(borderBrush, Borders.Left);
						e.Graphics.FillRectangle(borderBrush, Borders.Right);
						e.Graphics.FillRectangle(borderBrush, Borders.Bottom);
					}
					
					private void RecordWindow_Load(object sender, EventArgs e)
					{

					}
					
					public Point GetRecordPos()
					{
						int x = this.Location.X + borderWidth;
						int y = this.Location.Y + toolStrip.Height + borderWidth;
						return new Point(x, y);
					}

					public Size GetRecordRes() 
					{
						int width  = this.ClientSize.Width - 2 * borderWidth;
						int height = this.ClientSize.Height - toolStrip.Height - 2 * borderWidth;
						return new Size(width, height);
					}
					
					public void SetRecordPos(Point pos)
					{
						int x = pos.X - borderWidth;
						int y = pos.Y - toolStrip.Height - borderWidth;

						this.Location = new Point(x, y);
						this.StartPosition = FormStartPosition.Manual;
					}

					public void SetRecordRes(Size size)
					{
						int width = size.Width + 2 * borderWidth;
						int height = size.Height + toolStrip.Height + 2 * borderWidth;

						this.Size = new Size(width, height);
					}
					
					public void SetResText()
					{
						Size RecordRes = GetRecordRes();
						resLabel.Text = RecordRes.Width + \"x\" + RecordRes.Height;
					}

					protected override void WndProc(ref Message message)
					{
						base.WndProc(ref message);

						if (message.Msg == 0x84) // WM_NCHITTEST
						{
							Point cursor = this.PointToClient(Cursor.Position);
							message.Result = Borders.GetIntPtrFromPoint(cursor);
						}
					}

					private const int
					HTLEFT = 10,
					HTRIGHT = 11,
					HTTOP = 12,
					HTTOPLEFT = 13,
					HTTOPRIGHT = 14,
					HTBOTTOM = 15,
					HTBOTTOMLEFT = 16,
					HTBOTTOMRIGHT = 17;

					public struct BORDERS
					{
						public Rectangle Top, Left, Bottom, Right;
						public Point TopLeftPoint, TopRightPoint, ButtomLeftPoint, ButtomRightPoint;

						public BORDERS(int formWidth,int formHeight,int toolStripHeight)
						{
							TopLeftPoint = new Point(0, toolStripHeight);
							TopRightPoint = new Point(formWidth - borderWidth, toolStripHeight);
							ButtomLeftPoint = new Point(0,formHeight - borderWidth);
							ButtomRightPoint = new Point(formWidth - borderWidth, formHeight - borderWidth);

							Size HorizontalLine = new Size(formWidth, borderWidth);
							Size VerticalLine   = new Size(borderWidth, formHeight);

							this.Top = new Rectangle(TopLeftPoint, HorizontalLine);
							this.Bottom = new Rectangle(ButtomLeftPoint, HorizontalLine);
							this.Left = new Rectangle(TopLeftPoint, VerticalLine);
							this.Right = new Rectangle(TopRightPoint, VerticalLine);
						}

						private bool InRangeOf(Point corner,Point cursorPoint)
						{
							return (Math.Abs(cursorPoint.X - corner.X) < CornerTolerance && Math.Abs(cursorPoint.Y - corner.Y) < CornerTolerance);
						}

						public IntPtr GetIntPtrFromPoint(Point cursorPoint)
						{
							if (InRangeOf(TopLeftPoint, cursorPoint)) { return (IntPtr)HTTOPLEFT; }
							if (InRangeOf(TopRightPoint, cursorPoint)) { return (IntPtr)HTTOPRIGHT; }
							if (InRangeOf(ButtomLeftPoint, cursorPoint)) { return (IntPtr)HTBOTTOMLEFT; }
							if (InRangeOf(ButtomRightPoint, cursorPoint)) { return (IntPtr)HTBOTTOMRIGHT; }
							
							if (Top.Contains(cursorPoint)) { return (IntPtr)HTTOP; }
							if (Bottom.Contains(cursorPoint)) { return (IntPtr)HTBOTTOM; }
							if (Left.Contains(cursorPoint)) { return (IntPtr)HTLEFT; }
							if (Right.Contains(cursorPoint)) { return (IntPtr)HTRIGHT; }

							return new IntPtr(1);
						} 

					}

				}
				
				public class FormEvents
				{
					Timer TheTimer = new Timer();

					public FormEvents(Control c, Form f)
					{
						this.control = c;
						this.winForm = f;
						TheTimer.Interval = 15;
						control.MouseDown += DragStart;
						control.MouseMove += DragUpdatePos;
						control.MouseUp += DragEnd;

						TheTimer.Tick += DragUpdatePos;
					}

					bool isDragging = false;

					Control control;
					Form winForm;

					Point Mouse_StartPos = new Point(0, 0);
					Point Form_StartPos = new Point(0, 0);

					public void DragStart(Object sender, MouseEventArgs e)
					{
						//if (sender != this.control) { return; }
						if (e.Button == MouseButtons.Left)
						{
							TheTimer.Start();
							isDragging = true;

							Mouse_StartPos = Cursor.Position;
							Form_StartPos = winForm.Location;
						}

					}

					public void DragUpdatePos(Object sender, EventArgs e)
					{
						if (isDragging && Control.MouseButtons == MouseButtons.Left)
						{
							int MouseOffset_X = Cursor.Position.X - Mouse_StartPos.X;
							int MouseOffset_Y = Cursor.Position.Y - Mouse_StartPos.Y;

							winForm.Location = new Point(Form_StartPos.X + MouseOffset_X, Form_StartPos.Y + MouseOffset_Y);
						}
						else
						{
							TheTimer.Stop();
							isDragging = false;
						}
					}

					public void DragEnd(Object sender,EventArgs e)
					{
						isDragging = false;
					}
					

				}
			}
			"
				
			WinAPI =
			"
			using System;
			using System.Drawing;
			using System.Runtime.InteropServices;

			namespace RefPlayer
			{
				public class WinApi
				{
					[DllImport(\"dwmapi.dll\", PreserveSig = false)]
					public static extern bool DwmIsCompositionEnabled();

					[DllImport(\"dwmapi.dll\", PreserveSig = false)]
					public static extern int DwmEnableComposition(bool fEnable); 

					[DllImport(\"dwmapi.dll\", PreserveSig = false)]
					public static extern void DwmFlush(); 


					[DllImport(\"user32.dll\")]
					public static extern bool SetForegroundWindow(IntPtr hWnd);

					[DllImport(\"user32.dll\", EntryPoint = \"WindowFromPoint\")]
					public static extern IntPtr WindowFromPoint(POINTAPI p);
					
					public static IntPtr GetWindowFromPoint(int x, int y)
					{
						POINTAPI p = new POINTAPI(x, y);
						return WindowFromPoint(p);
					}

					/* Mouse Capture from https://stackoverflow.com/questions/918990/c-sharp-capturing-the-mouse-cursor-image*/

					[StructLayout(LayoutKind.Sequential)]
					public struct CURSORINFO
					{
						public Int32 cbSize;
						public Int32 flags;
						public IntPtr hCursor;
						public POINTAPI ptScreenPos;
					}

					[StructLayout(LayoutKind.Sequential)]
					public struct POINTAPI
					{
						public int x;
						public int y;

						public POINTAPI(int x,int y)
						{
							this.x = x;
							this.y = y;
						}
					}

					[DllImport(\"user32.dll\")]
					public static extern bool GetCursorInfo(out CURSORINFO pci);

					[DllImport(\"user32.dll\", SetLastError = true)]
					public static extern bool DrawIconEx(IntPtr hdc, int xLeft, int yTop, IntPtr hIcon, int cxWidth, int cyHeight, int istepIfAniCur, IntPtr hbrFlickerFreeDraw, int diFlags);

					private const Int32 CURSOR_SHOWING = 0x0001;
					private const Int32 DI_NORMAL = 0x0003;

					public static void CaptureMouseToGraphics(Graphics g,int x,int y)
					{
						CURSORINFO pci;
						pci.cbSize = Marshal.SizeOf(typeof (CURSORINFO));

						if (GetCursorInfo(out pci))
						{
							if (pci.flags == CURSOR_SHOWING)
							{
								var hdc = g.GetHdc();
								DrawIconEx(hdc, x, y, pci.hCursor, 0, 0, 0, IntPtr.Zero, DI_NORMAL);
								g.ReleaseHdc();
							}
						}
					}
				}
			}
			"

			GifCreator = 
			"using System;
			using System.Collections.Generic;
			using System.Drawing;
			using System.Linq;
			using System.Windows.Forms;
			using System.Drawing.Imaging;
			using System.Windows.Media.Imaging;
			using System.IO;
			using System.Runtime;

			namespace RefPlayer
			{
				public static class GifCreator
				{
					[System.Runtime.InteropServices.DllImport(\"gdi32.dll\")]
					private static extern bool DeleteObject(IntPtr hObject);

					public delegate void SendMessage(string Message);
					public static event SendMessage SendMessageToMax;

					private static void TellMax(string msg)
					{
						if (SendMessageToMax != null)
							SendMessageToMax(msg);
					}

					public static string GIF_INIT_COMPLETE;
					public static string GIF_PROCESSING_FRAME;
					public static string GIF_CACULATE_VALID_REGION;
					public static string GIF_PREPARE_TO_ADD_FRAME;
					public static string GIF_ADDING_FRAME;
					public static string GIF_GENERATING_GIF;
					public static string GIF_SAVEGIF_TO_FILE;

					public static float GifColorTolerance = 1;
					public static float GifFps = 30;

					public static int ErosionVal = 0;
					public static float ErosionColorTolerance = 1;
					public static int ReduceSmallAreaVal;
					public static int ForceRefreshInterval = int.MaxValue;

					struct FrameData
					{
						public byte FrameDuration; // TODO:more than 255 still frames?
						public bool[] TransparentData;
						public int PosX, PosY;
						public int Width, Height;

						public bool skip;
					}

					private static FrameData[] FrameDatas = null;

					public static void Init(int fps, float colorTolerance,int erosion, float erosionColorTolerance)
					{
						GifColorTolerance = colorTolerance * colorTolerance;
						ErosionColorTolerance = erosionColorTolerance * erosionColorTolerance;
						GifFps = fps;
						ErosionVal = erosion;
						ForceRefreshInterval = int.MaxValue;

						TellMax(GIF_INIT_COMPLETE);
					}
					public static void Init(int fps, float ColorTolerance)
					{
						Init(fps,ColorTolerance,0,0);
					}
					public static void Init(float ColorTolerance,int erosion,float erosionColorTolerance)
					{
						Init(30,ColorTolerance, erosion, erosionColorTolerance);
					}

					private static void SaveGifFileFromMs(MemoryStream ms, string gifSavePath)
					{
						// http://www.matthewflickinger.com/lab/whatsinagif/bits_and_bytes.asp
						/* TODO: Diagnostics  */

						var fileBytes = ms.ToArray();

						/* Replace graphic control to change play speed */

						byte frameduration = (byte)((1f / GifFps) * 100f);
						byte[] bytesSearch = { 0x21, 0xF9, 0x04, 0x01, 0x00 };
						int index = 0;
						int frame = 0;

						byte duration = frameduration;
						for (int i = FrameDatas.Length - 1; i > 0; i--)
						{
							if (FrameDatas[i].skip)
								duration += frameduration;
							else
							{
								FrameDatas[i].FrameDuration = duration;
								duration = frameduration;
							}
						}

						for (int i = 0; i < fileBytes.Length; i++)
						{
							if (fileBytes[i] == bytesSearch[index])
							{
								if (++index == bytesSearch.Length)
								{
									index = 0;

									FrameData data = FrameDatas[frame++];
									while (data.skip)
										data = FrameDatas[frame++];

									fileBytes[i] = data.FrameDuration;

									fileBytes[i + 5] = (byte)data.PosX;
									fileBytes[i + 6] = (byte)(data.PosX >> 8);
									fileBytes[i + 7] = (byte)data.PosY;
									fileBytes[i + 8] = (byte)(data.PosY >> 8);
								}
							}
							else index = 0;
						}

						using (FileStream fs = new FileStream(gifSavePath, FileMode.Create))
						{
							/*  Add loop info  */
							byte[] LoopInfo = new byte[] { 0x21, 0xFF, 0x0B, 0x4E, 0x45, 0x54, 0x53, 0x43,
												0x41, 0x50, 0x45, 0x32, 0x2E, 0x30, 0x03, 0x01, 0x00, 0x00, 0x00 };
							fs.Write(fileBytes, 0, 13);
							fs.Write(LoopInfo, 0, LoopInfo.Length);
							fs.Write(fileBytes, 13, fileBytes.Length - 13);
						}

						fileBytes = null;
					}

					private static BitmapFrame GetBitmapFrame(Bitmap img)
					{
						IntPtr hBitmap = img.GetHbitmap();

						BitmapSource src = System.Windows.Interop.Imaging.CreateBitmapSourceFromHBitmap
						(
							hBitmap,
							IntPtr.Zero,
							System.Windows.Int32Rect.Empty,
							BitmapSizeOptions.FromEmptyOptions()
						);
						BitmapFrame frame = BitmapFrame.Create(src);

						DeleteObject(hBitmap);

						return frame;
					}

					struct Colour
					{
						public byte R, G, B;
					}

					private static bool ColorSimilar(
						byte colorA_R, byte colorA_G, byte colorA_B,
						byte colorB_R, byte colorB_G, byte colorB_B,
						float tolerance)
					{
						/*
						float weight_R = 0.8f,weight_G = 1f,weight_B = 0.5f;
						double GDif = colorA_R - colorB_R;
						double BDif = colorA_G - colorB_G;
						double RDif = colorA_B - colorB_B;

						double Dif = Math.Sqrt(Math.Pow(GDif, 2) * weight_G + Math.Pow(BDif, 2) * weight_B + Math.Pow(RDif, 2) * weight_R);
						*/
						float RDif = colorA_R - colorB_R;
						float GDif = colorA_G - colorB_G;
						float BDif = colorA_B - colorB_B;

						float Dif = RDif * RDif * 0.8f +
									GDif * GDif * 1.0f +
									BDif * BDif * 0.5f;

						return Dif < tolerance;
					}

					private static bool ColorSimilar(Colour A, Colour B, float tolerance)
					{
						return ColorSimilar(A.R, A.G, A.B, B.R, B.G, B.B, tolerance);
					}

					private static bool ColorSimilar(System.Windows.Media.Color A, System.Windows.Media.Color B, float tolerance)
					{
						return ColorSimilar(A.R, A.G, A.B, B.R, B.G, B.B, tolerance);
					}

					private static FrameData CollectFrameData(Bitmap bmp, ref Colour[] CurrentColor, float ColorTolerance, bool refresh)
					{

						// https://docs.microsoft.com/en-us/dotnet/api/system.drawing.bitmap.unlockbits

						bool[] TPData = new bool[bmp.Width * bmp.Height];
						Colour[] frameColor = new Colour[bmp.Width * bmp.Height];

						Rectangle rect = new Rectangle(0, 0, bmp.Width, bmp.Height);
						// Lock the bitmap's bits. 
						System.Drawing.Imaging.BitmapData bmpData =
							bmp.LockBits(rect, System.Drawing.Imaging.ImageLockMode.ReadWrite,
							bmp.PixelFormat);

						// Get the address of the first line.
						IntPtr ptr = bmpData.Scan0;

						// Declare an array to hold the bytes of the bitmap.
						int bytes = Math.Abs(bmpData.Stride) * bmp.Height;
						byte[] rgbValues = new byte[bytes];

						// Copy the RGB values into the array.
						System.Runtime.InteropServices.Marshal.Copy(ptr, rgbValues, 0, bytes);

						int pixelcounter = 0;
						for (int counter = 0; counter<rgbValues.Length; counter += 4)
						{
							Colour pixelColor = new Colour
							{
								G = rgbValues[counter],
								B = rgbValues[counter + 1],
								R = rgbValues[counter + 2]
							};
							frameColor[pixelcounter] = pixelColor;

							if(refresh)
								CurrentColor[pixelcounter] = pixelColor;
							else if (ColorSimilar(pixelColor, CurrentColor[pixelcounter], ColorTolerance))
								TPData[pixelcounter] = true;
							
							pixelcounter++;
						}
						
						if(!refresh)
						{
							if(ErosionVal > 0)
							{
								bool[] TPDataNew = Dilation(TPData, bmp.Width, bmp.Height, ErosionVal);

								for (int i = 0; i < TPData.Length; i++)
								{
									bool newAdded = !TPData[i] && TPDataNew[i];
									if (newAdded && ColorSimilar(frameColor[i], CurrentColor[i], ErosionColorTolerance))
										TPData[i] = true;
								}
							}

							for (int i = 0; i < TPData.Length; i++)
								if (!TPData[i]) CurrentColor[i] = frameColor[i];
						}

						FrameData result = new FrameData
						{
							TransparentData = TPData,
							PosX = 0,
							PosY = 0,
							Width = bmp.Width,
							Height = bmp.Height
						};

						// Unlock the bits.
						bmp.UnlockBits(bmpData);

						return result;
					}

					private static bool[] Dilation(bool[] TPData, int Width, int Height, int iteration)
					{
						for (int i = 0; i < iteration; i++)
						{
							bool[] TPDataNew = (bool[])TPData.Clone();
							for (int y = 0; y < Height; y++)
							{
								for (int x = 0; x < Width ; x++)
								{
									int index = y * Width + x;

									if (TPData[index] == false) // Not Transparent
									{
										if (( y != 0 && TPData[index - Width]) ||
											( y != 0 && x != 0 && TPData[index - Width - 1] ) ||
											( y != 0 && x != Width - 1 && TPData[index - Width + 1]) ||
											( y != Height - 1 && TPData[index + Width] ) ||
											( y != Height - 1 && x != 0 && TPData[index + Width - 1]  )||
											( y != Height - 1 && x != Width - 1 && TPData[index + Width + 1] )||
											( x != 0 && TPData[index - 1]) ||
											( x != Width - 1 && TPData[index + 1] ))
										{
											TPDataNew[index] = true;
										}
									}
								}
							}
							TPData = TPDataNew;
						}

						return TPData;
					}

					private static void CaculateValidFrameRegion(ref FrameData[] datas)
					{
						//Parallel.ForEach(datas, data =>
						for (int i = 0; i < datas.Length; i++)
						{
							int MinX = datas[i].Width;
							int MinY = datas[i].Height;
							int MaxX = 0;
							int MaxY = 0;

							int Height = datas[i].Height;
							int Width = datas[i].Width;

							bool[] TPData = datas[i].TransparentData;

							for (int y = 0; y < Height; y++)
							{
								for (int x = 0; x < Width; x++)
								{
									int index = y * Width + x;
									if (!TPData[index]) /* Pixel not transparent */
									{
										if (x > MaxX) MaxX = x;
										if (y > MaxY) MaxY = y;
										if (x < MinX) MinX = x;
										if (y < MinY) MinY = y;
									}
								}
							}

							datas[i].PosX = MinX == datas[i].Width ? 0 : MinX;
							datas[i].PosY = MinY == datas[i].Height ? 0 : MinY;
							datas[i].Width  = Math.Max(MaxX - MinX + 1, 0);
							datas[i].Height = Math.Max(MaxY - MinY + 1, 0);
						}

					}

					public static void Start(string[] files, string saveDir,int width,int height)
					{
						/*TODO: Need dynamic frame duration to accurately handle different fps .. */
						if (GifFps < 30)
						{
							List<string> filesNew = new List<string>();

							float frame = 0;
							while (frame < files.Length)
							{
								filesNew.Add(files[(int)(frame)]);
								frame += 30f / GifFps;
							}

							files = filesNew.ToArray();
						}

						GifBitmapEncoder GifEncoder = new GifBitmapEncoder();
						FrameDatas = new FrameData[files.Length];
						Colour[] CurrentColor = null;

						for (int i = 0; i < files.Length; i++)
						{
							TellMax(string.Format(GIF_PROCESSING_FRAME, i + 1, files.Length));

							using (Bitmap SourceBitmap = new Bitmap(files[i]))
							{
								Bitmap bmp;
								
								if(width == 0 || height == 0)
									bmp = SourceBitmap.Clone(new Rectangle(0, 0, SourceBitmap.Width, SourceBitmap.Height), PixelFormat.Format32bppArgb);
								else
								{
									bmp = new Bitmap(width, height, PixelFormat.Format32bppArgb);
									using (Graphics g = Graphics.FromImage(bmp))
										g.DrawImage(SourceBitmap, new Rectangle(0, 0, width, height));
								}

								
								//float tolerance = i % ForceRefreshInterval == 0 ? 1f : GifColorTolerance;
								bool refresh = i % ForceRefreshInterval == 0;
								if (CurrentColor == null) CurrentColor = new Colour[bmp.Width * bmp.Height];
								FrameDatas[i] = CollectFrameData(bmp, ref CurrentColor, GifColorTolerance,refresh);


								BitmapFrame frame = GetBitmapFrame(bmp);
								GifEncoder.Frames.Add(frame);

								bmp.Dispose();
							}
						}
						CurrentColor = null;

						TellMax(GIF_CACULATE_VALID_REGION);

						CaculateValidFrameRegion(ref FrameDatas);

						TellMax(GIF_PREPARE_TO_ADD_FRAME);

						MemoryStream ms = new MemoryStream();
						GifEncoder.Save(ms);

						GifBitmapDecoder decoder = new GifBitmapDecoder(ms, BitmapCreateOptions.None, BitmapCacheOption.Default);
						GifEncoder = new GifBitmapEncoder();

						GC.Collect();

						//System.Windows.Media.Color[] LastFrame = null;
						for (int i = 0; i < decoder.Frames.Count; i++)
						{
							TellMax(string.Format(GIF_ADDING_FRAME, i + 1, decoder.Frames.Count));

							BitmapFrame f = decoder.Frames[i];
							FrameData data = FrameDatas[i];

							byte[] pixels = new byte[(int)(f.Width * f.Height)];
							f.CopyPixels(pixels, (int)f.Width, 0);

							/* Find palette transparent index */
							byte TPIndex = 255; /*Is this Determined ? */
							for (int p = 0; p < f.Palette.Colors.Count(); p++)
								if (f.Palette.Colors[p].A == 0) TPIndex = (byte)p;

							/* Set transparent pixels */
							for (int p = 0; p < pixels.Length; p++)
							{
								if (i != 0 && FrameDatas[i].TransparentData[p])
									pixels[p] = TPIndex;
							}

							/* Set valid region pixels to gif frame */
							int counter = 0;
							byte[] pixelsValid = new byte[data.Width * data.Height];
							for(int y = data.PosY;y < data.Height + data.PosY; y++)
							{
								for (int x = data.PosX; x < data.Width + data.PosX; x++)
									pixelsValid[counter++] = pixels[(int)f.Width * y + x];
							}

							if(pixelsValid.Length > 0)
							{
								BitmapSource bitmap = BitmapSource.Create(
								data.Width, data.Height, 0, 0,
								System.Windows.Media.PixelFormats.Indexed8, f.Palette,
								pixelsValid, (data.Width * System.Windows.Media.PixelFormats.Indexed8.BitsPerPixel + 7) / 8
								);
								GifEncoder.Frames.Add(BitmapFrame.Create(bitmap));
							}
							else FrameDatas[i].skip = true;

						}

						ms.Close();
						TellMax(GIF_GENERATING_GIF);

						ms = new MemoryStream();
						GifEncoder.Save(ms);
						TellMax(GIF_SAVEGIF_TO_FILE);

						SaveGifFileFromMs(ms, saveDir);

						ms.Close();
						FrameDatas = null;

					}

					public static void Start(string[] files, string saveDir)
					{
						Start(files, saveDir, 0, 0);
					}
				}
			}
			"

            PlayerForm =
            "
            using System;
            using System.Windows.Forms;

            namespace RefPlayer
            {
                public class PlayerForm : MaxCustomControls.MaxForm
                {
                    public bool clickThrough = false;

                    protected override void WndProc(ref Message m)
                    {
                        const int WM_NCHITTEST = 0x0084;
                        const int HTTRANSPARENT = (-1);

                        if (m.Msg == WM_NCHITTEST && clickThrough)
                        {
                            m.Result = (IntPtr)HTTRANSPARENT;
                        }
                        else
                        {
                            base.WndProc(ref m);
                        }
                    }
                }

                public class PictureBoxEx : PictureBox
                {
                        
                    protected override void WndProc(ref Message m)
                    {
                        const int WM_NCHITTEST = 0x0084;
                        const int HTTRANSPARENT = (-1);

                        if (m.Msg == WM_NCHITTEST)
                        {
                            m.Result = (IntPtr)HTTRANSPARENT;
                        }
                        else
                        {
                            base.WndProc(ref m);
                        }
                    }
                }
            }
            "

			CSharpProvider = dotnetobject "Microsoft.CSharp.CSharpCodeProvider"
			CompilerParams = dotnetobject "System.CodeDom.Compiler.CompilerParameters"

			CompilerParams.ReferencedAssemblies.Add "System.dll"
			CompilerParams.ReferencedAssemblies.Add "System.Drawing.dll"
			CompilerParams.ReferencedAssemblies.Add "System.Windows.Forms.dll"
			CompilerParams.ReferencedAssemblies.Add "System.Runtime.InteropServices.dll"
 			CompilerParams.ReferencedAssemblies.Add "System.Core.dll"
            CompilerParams.ReferencedAssemblies.Add "System.Xaml.dll"
            CompilerParams.ReferencedAssemblies.Add  (dotnet.loadAssembly "MaxCustomControls.dll").Location
            CompilerParams.ReferencedAssemblies.Add (dotnet.loadAssembly "PresentationCore.dll").Location
            CompilerParams.ReferencedAssemblies.Add (dotnet.loadAssembly "WindowsBase.dll").Location
			
			CompilerParams.GenerateExecutable = false
			CompilerParams.GenerateInMemory = true 

			/*TODO: 小概率会出现 dotNet runtime exception: 
				Could not find file 'C:\Users\Administrator\AppData\Local\Temp\mds22yj0\mds22yj0.dll

				暂时用trycatch处理了 会尝试编译5次 不行再报错
				之前似乎没有遇到? 跟安装Max2012有关? dotnet版本?
			*/
			local CompilerResults
			
			local MaxAttemptsCount = 5
			local CompileSucceed = false
			for i = 1 to MaxAttemptsCount do 
			(
				if not CompileSucceed do
				(
					try(
						CompilerResults = CSharpProvider.CompileAssemblyFromSource CompilerParams #(RecorderForm,WinAPI,GifCreator,PlayerForm)
						CompileSucceed = true
					)catch(
						if i == MaxAttemptsCount do throw()
					)
				)
			)

            if CompilerResults.Errors.HasErrors do
            (
                local ErrorMessage ="C# Compile Error:"
                
                for i = 1 to CompilerResults.Errors.Count do
                (		
                    ErrorMessage += "\n"			
                    ErrorMessage += CompilerResults.Errors.Item[i-1].ToString()
                )
                MessageBox ErrorMessage
            )

            CompilerResults.CompiledAssembly
		)

        if (dotnetclass "RefPlayer.RecordWindow") == undefined do
			CompileCSharpCode()
		

		/* Debug */Debug_LogTime "CompileCSharpCode"
	)

	(---- Icons ----
		if false do 
		(
			
			struct RefPlayer_icons 
			(
				ImageFromFile  = (dotnetclass "System.Drawing.Image").fromFile,
				
				--OpenRecordFile = ImageFromFile @"F:\脚本\Player\icons\openfile2.png",
				--Menu   = ImageFromFile @"F:\脚本\Player\icons\menu3.png",
				--OpenNewFile = ImageFromFile @"F:\脚本\Player\icons\openfile.png",
				--Grid    = ImageFromFile @"F:\脚本\Player\icons\Grid1.png",
				--Preload = ImageFromFile @"F:\脚本\Player\icons\Preload1.png",
				--History = ImageFromFile @"F:\脚本\Player\icons\History.png",
				--Time    = ImageFromFile @"F:\脚本\Player\icons\Time2.png",
				RecordStop = ImageFromFile @"F:\脚本\Player\icons\RecordStop.png",
				Record = ImageFromFile @"F:\脚本\Player\icons\RecordCircle.png",
				Setting = ImageFromFile @"F:\脚本\Player\icons\Setting.png",
				Back    = ImageFromFile @"F:\脚本\Player\icons\return.png",
				Redo    = ImageFromFile @"F:\脚本\Player\icons\redo8.png",
				Okey    = ImageFromFile @"F:\脚本\Player\icons\okey.png",
				Lock    = ImageFromFile @"F:\脚本\Player\icons\lock4.png",
				
				fn Dispose =
				(
					for prop in getpropnames this do
					(
						image = getproperty this prop
						if isproperty image #Dispose do image.Dispose()
					)
				),
				
				fn EncodeBase64Image image =
				(
					ConvertClass = dotnetclass "System.Convert"
					
					memstream = dotnetobject "System.IO.MemoryStream"
					image.save memstream image.rawformat
					Base64string = ConvertClass.ToBase64String (memstream.ToArray())
					memstream.close()
						
					return Base64String
				),
				
				fn CopyInfoToClipBoard =
				(
					result = stringStream ""
					
					for prop in getpropnames this do
					(
						image = getproperty this prop
						if isproperty image #Dispose do 
						(
							imageName = prop as string
							base64String = EncodeBase64Image image
							
							format "% = DecodeBase64Image \"%\",\n" imageName base64String to:result
							image.Dispose()
						)
					)
					
					setclipboardText result
				)
			)
			RefPlayer_icons = RefPlayer_icons()
			
			RefPlayer_icons.CopyInfoToClipBoard()

		)
		
		fn DecodeBase64Image ImgString =
		(
			local Image = dotnetclass "System.Drawing.Image"
			local Convert = dotnetclass "System.Convert"
			
			bytearr = Convert.FromBase64String ImgString
			memstream = dotnetobject "System.IO.MemoryStream" bytearr
			DecodedImg = Image.fromstream memstream
			memstream.close()
			
			return DecodedImg
		)

		struct RefPlayer_icons 
		(
			Back = DecodeBase64Image "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",
			Lock = DecodeBase64Image "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",
			Okey = DecodeBase64Image "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",
			Record = DecodeBase64Image "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",
			RecordStop = DecodeBase64Image "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",
			redo = DecodeBase64Image "iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAABGdBTUEAALGOfPtRkwAAACBjSFJNAACHDwAAjA8AAP1SAACBQAAAfXkAAOmLAAA85QAAGcxzPIV3AAAKOWlDQ1BQaG90b3Nob3AgSUNDIHByb2ZpbGUAAEjHnZZ3VFTXFofPvXd6oc0w0hl6ky4wgPQuIB0EURhmBhjKAMMMTWyIqEBEEREBRZCggAGjoUisiGIhKKhgD0gQUGIwiqioZEbWSnx5ee/l5ffHvd/aZ+9z99l7n7UuACRPHy4vBZYCIJkn4Ad6ONNXhUfQsf0ABniAAaYAMFnpqb5B7sFAJC83F3q6yAn8i94MAUj8vmXo6U+ng/9P0qxUvgAAyF/E5mxOOkvE+SJOyhSkiu0zIqbGJIoZRomZL0pQxHJijlvkpZ99FtlRzOxkHlvE4pxT2clsMfeIeHuGkCNixEfEBRlcTqaIb4tYM0mYzBXxW3FsMoeZDgCKJLYLOKx4EZuImMQPDnQR8XIAcKS4LzjmCxZwsgTiQ7mkpGbzuXHxArouS49uam3NoHtyMpM4AoGhP5OVyOSz6S4pyalMXjYAi2f+LBlxbemiIluaWltaGpoZmX5RqP+6+Dcl7u0ivQr43DOI1veH7a/8UuoAYMyKarPrD1vMfgA6tgIgd/8Pm+YhACRFfWu/8cV5aOJ5iRcIUm2MjTMzM424HJaRuKC/6386/A198T0j8Xa/l4fuyollCpMEdHHdWClJKUI+PT2VyeLQDf88xP848K/zWBrIieXwOTxRRKhoyri8OFG7eWyugJvCo3N5/6mJ/zDsT1qca5Eo9Z8ANcoISN2gAuTnPoCiEAESeVDc9d/75oMPBeKbF6Y6sTj3nwX9+65wifiRzo37HOcSGExnCfkZi2viawnQgAAkARXIAxWgAXSBITADVsAWOAI3sAL4gWAQDtYCFogHyYAPMkEu2AwKQBHYBfaCSlAD6kEjaAEnQAc4DS6Ay+A6uAnugAdgBIyD52AGvAHzEARhITJEgeQhVUgLMoDMIAZkD7lBPlAgFA5FQ3EQDxJCudAWqAgqhSqhWqgR+hY6BV2ArkID0D1oFJqCfoXewwhMgqmwMqwNG8MM2An2hoPhNXAcnAbnwPnwTrgCroOPwe3wBfg6fAcegZ/DswhAiAgNUUMMEQbigvghEUgswkc2IIVIOVKHtCBdSC9yCxlBppF3KAyKgqKjDFG2KE9UCIqFSkNtQBWjKlFHUe2oHtQt1ChqBvUJTUYroQ3QNmgv9Cp0HDoTXYAuRzeg29CX0HfQ4+g3GAyGhtHBWGE8MeGYBMw6TDHmAKYVcx4zgBnDzGKxWHmsAdYO64dlYgXYAux+7DHsOewgdhz7FkfEqeLMcO64CBwPl4crxzXhzuIGcRO4ebwUXgtvg/fDs/HZ+BJ8Pb4LfwM/jp8nSBN0CHaEYEICYTOhgtBCuER4SHhFJBLVidbEACKXuIlYQTxOvEIcJb4jyZD0SS6kSJKQtJN0hHSedI/0ikwma5MdyRFkAXknuZF8kfyY/FaCImEk4SXBltgoUSXRLjEo8UISL6kl6SS5VjJHslzypOQNyWkpvJS2lIsUU2qDVJXUKalhqVlpirSptJ90snSxdJP0VelJGayMtoybDFsmX+awzEWZMQpC0aC4UFiULZR6yiXKOBVD1aF6UROoRdRvqP3UGVkZ2WWyobJZslWyZ2RHaAhNm+ZFS6KV0E7QhmjvlygvcVrCWbJjScuSwSVzcopyjnIcuUK5Vrk7cu/l6fJu8onyu+U75B8poBT0FQIUMhUOKlxSmFakKtoqshQLFU8o3leClfSVApXWKR1W6lOaVVZR9lBOVd6vfFF5WoWm4qiSoFKmclZlSpWiaq/KVS1TPaf6jC5Ld6In0SvoPfQZNSU1TzWhWq1av9q8uo56iHqeeqv6Iw2CBkMjVqNMo1tjRlNV01czV7NZ874WXouhFa+1T6tXa05bRztMe5t2h/akjpyOl06OTrPOQ12yroNumm6d7m09jB5DL1HvgN5NfVjfQj9ev0r/hgFsYGnANThgMLAUvdR6KW9p3dJhQ5Khk2GGYbPhqBHNyMcoz6jD6IWxpnGE8W7jXuNPJhYmSSb1Jg9MZUxXmOaZdpn+aqZvxjKrMrttTjZ3N99o3mn+cpnBMs6yg8vuWlAsfC22WXRbfLS0suRbtlhOWWlaRVtVWw0zqAx/RjHjijXa2tl6o/Vp63c2ljYCmxM2v9ga2ibaNtlOLtdZzllev3zMTt2OaVdrN2JPt4+2P2Q/4qDmwHSoc3jiqOHIdmxwnHDSc0pwOub0wtnEme/c5jznYuOy3uW8K+Lq4Vro2u8m4xbiVun22F3dPc692X3Gw8Jjncd5T7Snt+duz2EvZS+WV6PXzAqrFetX9HiTvIO8K72f+Oj78H26fGHfFb57fB+u1FrJW9nhB/y8/Pb4PfLX8U/z/z4AE+AfUBXwNNA0MDewN4gSFBXUFPQm2Dm4JPhBiG6IMKQ7VDI0MrQxdC7MNaw0bGSV8ar1q66HK4RzwzsjsBGhEQ0Rs6vdVu9dPR5pEVkQObRGZ03WmqtrFdYmrT0TJRnFjDoZjY4Oi26K/sD0Y9YxZ2O8YqpjZlgurH2s52xHdhl7imPHKeVMxNrFlsZOxtnF7YmbineIL4+f5rpwK7kvEzwTahLmEv0SjyQuJIUltSbjkqOTT/FkeIm8nhSVlKyUgVSD1ILUkTSbtL1pM3xvfkM6lL4mvVNAFf1M9Ql1hVuFoxn2GVUZbzNDM09mSWfxsvqy9bN3ZE/kuOd8vQ61jrWuO1ctd3Pu6Hqn9bUboA0xG7o3amzM3zi+yWPT0c2EzYmbf8gzySvNe70lbEtXvnL+pvyxrR5bmwskCvgFw9tst9VsR23nbu/fYb5j/45PhezCa0UmReVFH4pZxde+Mv2q4quFnbE7+0ssSw7uwuzi7Rra7bD7aKl0aU7p2B7fPe1l9LLCstd7o/ZeLV9WXrOPsE+4b6TCp6Jzv+b+Xfs/VMZX3qlyrmqtVqreUT13gH1g8KDjwZYa5ZqimveHuIfu1nrUttdp15UfxhzOOPy0PrS+92vG140NCg1FDR+P8I6MHA082tNo1djYpNRU0gw3C5unjkUeu/mN6zedLYYtta201qLj4Ljw+LNvo78dOuF9ovsk42TLd1rfVbdR2grbofbs9pmO+I6RzvDOgVMrTnV32Xa1fW/0/ZHTaqerzsieKTlLOJt/duFczrnZ86nnpy/EXRjrjup+cHHVxds9AT39l7wvXbnsfvlir1PvuSt2V05ftbl66hrjWsd1y+vtfRZ9bT9Y/NDWb9nffsPqRudN65tdA8sHzg46DF645Xrr8m2v29fvrLwzMBQydHc4cnjkLvvu5L2key/vZ9yff7DpIfph4SOpR+WPlR7X/aj3Y+uI5ciZUdfRvidBTx6Mscae/5T+04fx/Kfkp+UTqhONk2aTp6fcp24+W/1s/Hnq8/npgp+lf65+ofviu18cf+mbWTUz/pL/cuHX4lfyr468Xva6e9Z/9vGb5Dfzc4Vv5d8efcd41/s+7P3EfOYH7IeKj3ofuz55f3q4kLyw8Bv3hPP74uYdwgAAAAlwSFlzAAAPYAAAD2ABenhFjQAAAgNJREFUWEfF18lKA0EQBmCj4oZgAqLP4AN48klcQNCzL+ALuF0VQXLVu2ePenY5CIoePbqCiIIw/n/oHmpqanp64pAcPpLurqquZDJLBpIk6StzspfMyTq1Ty8oUdJ1KzikCWtwDHfwDiz44cac5/oUyLx/N8CNd+ALdDEL47aBeczX65UaWIZn0EViMI/5ej6qgQbsgk6uQ1QDW2Al16G0gSUXGPIN13DmXjm24izBBmbgzQVaHmAFJkA2zTHnuW7lScEG9kWg1oZRkBvTE7wKZd9GYQM8bYpOtUPQG3tWfEizqAFeRKyERxgBvbFn5YSsFjVwogI9Hlu9qcQrIeN+QB6KT9C1aKOogVsVSDye46A3jcFvreXI385QUQP+k0hX4BMrk/UtmQES9OZ0DrnCsWR9S2aAhL5/A3X/BgZlfUtmgIRuz4IiLVnfkhkgYR2sBnh5DV0HLIyflvUtmQESur0SWhg/J+uLfRr+vV6gA7AaoCOw7gUS1xnHeH6YTRgWe/A5I90zfeMWaRbK7oa8Xesf5hgsgnU3vIF5t8ckBBug2OeBS+DzAF/L7oC/sACdPcoaoLqfiPh4l9aPaYDHag+sYlWxTufYezENeHyqfQGrcBnmMT9Xt0oD1M3/Asb7/wU5VRvwWJAPLbxi3oO/d/CVY85b/4xyzAb6wZzsnWTgD4Ci7pXFSAMwAAAAAElFTkSuQmCC",
			Setting = DecodeBase64Image "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",

			fn Dispose =
			(
				for prop in getpropnames this do
				(
					image = getproperty this prop
					if isproperty image #Dispose do image.Dispose()
				)
			)
		)
		
		Icons = RefPlayer_icons()

		/* Debug */Debug_LogTime "LoadIcons"
	)

	(----- UI Design ↓ ------ 

        (---- Main UIs ----

            /*  PlayerWindow  */
            --ui_PlayerWindow = dotnetobject "MaxCustomControls.MaxForm"
            ui_PlayerWindow = dotnetobject "RefPlayer.PlayerForm"
            ui_PlayerWindow.BackColor = (dotNetClass "System.Drawing.Color").Black
            ui_PlayerWindow.FormBorderStyle = ui_PlayerWindow.FormBorderStyle.None
            ui_PlayerWindow.AllowDrop = true

			s_Player.pos_x = &ui_PlayerWindow.Location.X
			s_Player.pos_y = &ui_PlayerWindow.Location.Y


			/*  PlayerToolStrip  */

			ui_PlayerToolStrip = dotnetobject "RefPlayer.ToolStripEx"
            ui_PlayerToolStrip.backColor = (dotnetclass "System.Drawing.Color").FromArgb 0 50 50 50
            ui_PlayerToolStrip.ImageScalingSize = dotnetobject "System.Drawing.Size" 20 20
            ui_PlayerToolStrip.Dock =  ui_PlayerToolStrip.Dock.left
			ui_PlayerToolStrip.visible = true 
            ui_PlayerToolStrip.CanOverflow = false


			--ui_PlayerToolStrip.padding = dotnetobject "Padding" 0 0 0 0
			--ui_PlayerWindow.Controls.Add ui_PlayerToolStrip

			/*  PlayerPictureBox  */
			
            ui_PlayerPictureBox = dotnetobject "RefPlayer.PictureBoxEx"
            ui_PlayerPictureBox.SizeMode = PictureBoxSizeMode.StretchImage
            ui_PlayerPictureBox.Dock     = DockStyle.Fill 
            ui_PlayerPictureBox.AutoSize = false
            --ui_PlayerPictureBox.Enabled  = false

            ui_PlayerWindow.Controls.Add ui_PlayerPictureBox
			
			--ui_PlayerPictureBox.Controls.Add ui_PlayerToolStrip

			/*  GridPictureBox  */

            ui_PlayerGridPictureBox = dotnetobject "RefPlayer.PictureBoxEx"
            ui_PlayerGridPictureBox.BackColor = DNColor.Transparent
            ui_PlayerGridPictureBox.ClientSize = dotnetobject "System.Drawing.Size" ui_PlayerWindow.width ui_PlayerWindow.Height
            ui_PlayerGridPictureBox.SizeMode = PictureBoxSizeMode.StretchImage
            ui_PlayerGridPictureBox.Dock     = DockStyle.Fill 
            ui_PlayerGridPictureBox.AutoSize = false
            --ui_PlayerGridPictureBox.Enabled  = false
            
            ui_PlayerPictureBox.Controls.Add ui_PlayerGridPictureBox
            ui_PlayerGridPictureBox.BringToFront()


            (-- PlayerToolStrip Gradient Shadow
				if RPGradientToolStrip then
				(
					/* ToolStrip Shadow Gradient */

					ui_PlayerTSShadow = dotnetobject "RefPlayer.PictureBoxEx"
					ui_PlayerTSShadow.BackColor = DNColor.Transparent
					ui_PlayerTSShadow.Size = dotnetobject "System.Drawing.Size" 100 ui_PlayerWindow.Height
					ui_PlayerTSShadow.SizeMode = PictureBoxSizeMode.StretchImage
					ui_PlayerTSShadow.Dock     = DockStyle.Left 
					ui_PlayerTSShadow.AutoSize = false
					ui_PlayerTSShadow.Controls.Add ui_PlayerToolStrip

					local PlayerTSShadowFrames = #()

					fn CreateGradientBitmap alphaMultiplier =
					(
						local ScreenHeight = sysInfo.desktopSize[2]
						local GradientBitmap = dotnetobject "System.Drawing.Bitmap" 100 100
						local GradientGraphics = (dotnetclass "System.Drawing.Graphics").FromImage GradientBitmap

						local FromColor= DNColor.FromARGB (175*alphaMultiplier) 50 50 50
						local ToColor  = DNColor.FromARGB 0 50 50 50
						local TheAngle =  0
						local Rect = dotnetobject "System.Drawing.Rectangle" 0 0 GradientBitmap.Width GradientBitmap.Height

						local GBrush = dotnetobject "System.Drawing.Drawing2D.LinearGradientBrush" \ 
						Rect FromColor ToColor TheAngle

					
						local GradientBlend = dotnetobject "System.Drawing.Drawing2D.Blend"
						GradientBlend.Factors   = #(0.0,0.1,0.6,0.9,1.0)
						GradientBlend.Positions = #(0.0,0.1,0.5,0.8,1.0)
						
						GBrush.Blend = GradientBlend

						GradientGraphics.FillRectangle GBrush Rect
						GradientGraphics.Dispose()
						
						GradientBitmap
					)

					PlayerTSShadowFrames = for i = 0 to 1 by 1./15 collect CreateGradientBitmap i


					fn uifn_HideTSGradient = 
					(

						if MouseInForm() and not dUI_IsDragging() and not isAnimPlaying() do
						(
                            local StartTime  = timestamp()
                            local CurrTime   = timestamp() 
                            local framecount = PlayerTSShadowFrames.count
                            local finish     = false

                            for i = PlayerTSShadowFrames.count to 1 by -1  do
                            (
                                if not finish do
                                (
                                    CurrTime = timestamp()
                                    local indexByTime = framecount - (CurrTime - StartTime) / (1000/60.) + 1
                                    if i > indexByTime do i = indexByTime
                                    if i < 1  do (i = 1;finish = true)

                                    ui_PlayerTSShadow.image = PlayerTSShadowFrames[i]
                                    ui_PlayerTSShadow.Refresh()
                                )
                            )
						)

						ui_PlayerTSShadow.image = undefined
                        
                        /*
                        if MouseInForm() do
						(
							for i = PlayerTSShadowFrames.count to 1 by -1  do
							(
								ui_PlayerTSShadow.image = PlayerTSShadowFrames[i]
								ui_PlayerTSShadow.Refresh()
							)
						)

						ui_PlayerTSShadow.image = undefined
                        */
                        
					)

					fn uifn_ShowTSGradient = 
					(
                        local StartTime = timestamp()
                        local CurrTime = timestamp()
                        local framecount = PlayerTSShadowFrames.count
                        local finish = false

						for i = 1 to PlayerTSShadowFrames.count do
						(
                            if not finish do
                            (
                                CurrTime = timestamp()
                                local indexByTime = (CurrTime - StartTime) / (1000/60.)  + 1
                                if i < indexByTime do i = indexByTime
                                if i > framecount  do (i = framecount;finish = true)

                                ui_PlayerTSShadow.image = PlayerTSShadowFrames[i]
                                ui_PlayerTSShadow.Refresh()

                                --format "indexByTime:% i:%\n" indexByTime i
                            )
						)
                        
					)

					fn uifn_HideToolStrip = 
					(
						uifn_HideTSGradient()
						ui_PlayerTSShadow.Visible = false
						ui_PlayerToolStrip.visible = false
					)
					fn uifn_ShowToolStrip = 
					(
						ui_PlayerTSShadow.Visible = true
						uifn_ShowTSGradient()
						ui_PlayerToolStrip.visible = true
					)

					fn final_FreeTSShadowBitmap = 
					(
						try(
							for x in PlayerTSShadowFrames do x.Dispose()
						)catch()

					)

					ui_PlayerToolStrip.visible = false
					ui_PlayerTSShadow.Visible = false

				)else /* NO ToolStrip Shadow */
				(
					fn uifn_ShowToolStrip  = ui_PlayerToolStrip.Visible = true
					fn uifn_HideToolStrip  = ui_PlayerToolStrip.Visible = false

					fn uifn_HideTSGradient = ()
					fn uifn_ShowTSGradient = ()
					fn final_FreeTSShadowBitmap = ()

					ui_PlayerToolStrip.Visible = false
				)
			)
            



            local PlayerTSControlToUpdate = 
                if RPGradientToolStrip then ui_PlayerTSShadow else ui_PlayerToolStrip

            fn uifn_UpdatePlayerTS = /* Ensure Transparent */
            (
                local parent = ui_PlayerWindow
                if ui_PlayerPictureBox.Visible     do parent = ui_PlayerPictureBox
                if ui_PlayerGridPictureBox.Visible do parent = ui_PlayerGridPictureBox

                if ui_PlayerToolStrip.parent != parent do
                    parent.Controls.Add PlayerTSControlToUpdate
            )

            fn uifn_SetPicBoxVisible val =
            (
                ui_PlayerPictureBox.visible = val

                uifn_UpdatePlayerTS()
            )

            fn uifn_SetGridVisible val =
            (
                ui_PlayerGridPictureBox.visible = val

                uifn_UpdatePlayerTS()
            )

			/*  Recorder Window  */

            ui_RecordWindow = dotnetobject "RefPlayer.RecordWindow"
			
			ui_RecordToolStrip = dotnetobject "RefPlayer.ToolStripEX"
            ui_RecordToolStrip.CanOverflow = false
			ui_RecordToolStrip.backColor = RGBColor RPRecorderTSColor.r RPRecorderTSColor.g RPRecorderTSColor.b
			ui_RecordWindow.Controls.Add ui_RecordToolStrip
			ui_RecordWindow.ToolStrip = ui_RecordToolStrip
			ui_RecordWindow.formEvents = dotnetobject "RefPlayer.FormEvents" ui_RecordToolStrip ui_RecordWindow

            
            fn uifn_SetRecorderMinMaxSize =
            (
                fn Res_To_RecorderSize res =
                (
                    local borderWidth = 3
                    
                    local width  = res.x + borderWidth * 2
                    local height = res.y + ui_RecordToolStrip.Height + borderWidth * 2

                    dotnetobject "System.Drawing.Size" width height
                )

                ui_RecordWindow.MinimumSize = Res_To_RecorderSize RPMinRecordReslotion
                ui_RecordWindow.MaximumSize = Res_To_RecorderSize RPMaxRecordReslotion
                
            )

            uifn_SetRecorderMinMaxSize()

			dotnet.addeventHandler ui_PlayerWindow #Closed ( fn _PlayerClose = RP_Quit() )

			dotnet.addeventHandler ui_RecordWindow #Closed (fn _RecorderClose = RP_Quit() )

			/* Debug */Debug_LogTime "MainUI"

        )


        (---- Player&Recorder ToolStrip -----

            fn AddControl ControlType Text: Image: ForeColor: Align:#Left Enabled:true Des: Font:#Default =
            (
                local newControl = dotnetobject ControlType
                newControl.ForeColor = (dotnetclass "System.Drawing.Color").white
                newControl.AutoToolTip = false

                if Text  != unsupplied     do newControl.Text = Text
                if Image != unsupplied     do newControl.Image = Image
                if ForeColor != unsupplied do newControl.ForeColor = ForeColor
                if Align   == #Right       do newControl.Alignment = newControl.Alignment.right
                if Enabled == false        do newControl.Enabled  = false
                    
				if Font == #Default do
					NewControl.Font = DNFont "Microsoft YaHei" 8.5 Bold:true 
				
				if Font == #Arial do
					NewControl.Font = DNFont "Arial" 8.2 Bold:true 
				
                
                newControl
            )
            
            (---- RecorderToolStrip ----

                local ShowRecorderDes = true
                
				fn AddControl_Rec ControlType Text: Image: ForeColor: Align:#Left Enabled:true Des: Font:#Default = 
				(
					local newControl = AddControl ControlType Text:Text Image:Image ForeColor:ForeColor Align:Align Enabled:Enabled Des:Des Font:Font

					if Des != unsupplied do
					(
						newControl.Tag = Des
						dotnet.addeventhandler newControl #MouseEnter (fn new sender eventArgs  = if ShowRecorderDes do uifn_SetRecorderDes sender.tag)
						dotnet.addeventhandler newControl #MouseLeave (fn new sender eventArgs  = if ShowRecorderDes do uifn_ResumeRecorderDes())	
					)

					ui_RecordToolStrip.items.add newControl

					newControl
				)
                
                local rBackButton     = AddControl_Rec "ToolStripButton" Image:icons.Back Text:REC_RETURN_TO_PLAYER /*"返回"*/ ForeColor:DNColor.White Des:REC_RETURN_TO_PLAYER_TOOLTIP /*返回播放模式*/
                local rResLabel       = AddControl_Rec "ToolStripLabel"  Text:"1280x720"  
                rResLabel.Padding = dotnetobject "Padding" 10 0 0 0
                ui_RecordWindow.resLabel = rResLabel

                local rSettingButton  = AddControl_Rec "ToolStripButton" Align:#right Image:icons.Setting Des:REC_SETTING_TOOLTIP /*设置(保存路径,录制辅助*/
				local rFinishButton   = AddControl_Rec "ToolStripButton" Align:#right Image:icons.okey    Text:REC_FINISH /*完成*/ Des:REC_FINISH_TOOLTIP /*结束录制,返回播放模式*/
                local rRecordButton   = AddControl_Rec "ToolStripButton" Align:#right Image:icons.Record  Text:REC_RECORD /*录制*/ --Des:"开始录制"
                local rGifButton      = AddControl_Rec "ToolStripButton" Align:#right  Text:REC_GIF/*GIF*/ Des:REC_GIF_TOOLTIP /*生成Gif*/

                --local CloseButton    = AddControl_Rec toolStripButton Align:#right Text:"X" ForeColor:DNColor.white
                --local OpenFileButton = AddControl_Rec toolStripButton Align:#right Image:icons.OpenRecordFile Des:"打开文件夹"
                rFinishButton.visible = false
                rGifButton.visible = false

                

                (---- Recorder Mode
                
                    fn SetBorderColor dotnet_color =
                    (
                        ui_RecordWindow.borderBrush = dotNetObject "System.Drawing.SolidBrush" dotnet_color
                        ui_RecordWindow.Refresh()
                    )

                    fn SetRecordButton ButtonText Descripiton IconImg =
                    (
                        rRecordButton.Text = ButtonText

                        rRecordButton.tag  = Descripiton
                        rRecordButton.image = IconImg

                        if ShowRecorderDes do rResLabel.text = Descripiton
                    ) 

                    fn SetBackButton ButtonText Descripiton IconImg =
                    (
                        rBackButton.Text = ButtonText
                        rBackButton.tag  = Descripiton
                        rBackButton.image = IconImg
                    ) 

                    fn uifn_RecorderIdleMode = 
                    (
						
                        m_RecorderMode = MODE_RECORDER_IDLE
                        SetBorderColor (RGBColor RPRecorderBorderColor.r RPRecorderBorderColor.g RPRecorderBorderColor.b)
						/*TODO:find out why set TransparencyKey would cause UI not switching mode */
						--ui_RecordWindow.TransparencyKey = ui_RecordWindow.BackColor

                        local RecordDes = case dRec_GetAssistanceType() of
                        (
                            (1):REC_RECORD_TOOLTIP_NORMAL   --开始录制
                            (2):REC_RECORD_TOOLTIP_SPACEKEY --开始录制(辅助:空格)
                            (3):REC_RECORD_TOOLTIP_MEDIAKEY --开始录制(辅助:媒体键)
                        )

                        SetBackButton REC_RETURN_TO_PLAYER /*返回*/ REC_RETURN_TO_PLAYER_TOOLTIP /*返回播放模式*/ Icons.Back
						
                        SetRecordButton REC_RECORD /*录制*/ RecordDes Icons.Record

                        rFinishButton.visible = false
                        rGifButton.visible = false
                        rBackButton.visible = true
                    )

					fn init_SetRecorderBorderColor = uifn_RecorderIdleMode()

                    fn uifn_RecorderRecordMode = 
                    (
                        m_RecorderMode = MODE_RECORDER_RECORDING
                        SetBorderColor DNColor.Red
                        rBackButton.Enabled = false

                        SetRecordButton REC_STOP /*停止*/ REC_RETURN_TO_PLAYER_TOOLTIP /*停止录制*/ Icons.RecordStop

                        rFinishButton.visible = false
                        rGifButton.visible = false
                        rBackButton.visible = true
                    )

                    fn uifn_RecorderPreviewMode = 
                    (
                        m_RecorderMode = MODE_RECORDER_PREVIEWING
						--ui_RecordWindow.TransparencyKey = DNColor.Empty
                        SetBorderColor DNColor.Green
                        
                        SetRecordButton REC_ABORT /*重录*/ REC_ABORT_TOOLTIP /*放弃当前预览内容,返回录制*/ Icons.Redo

                        rBackButton.Enabled = true
                        rFinishButton.visible = true
                        rGifButton.visible = true
                    )
                )

                fn RecorderOnMax = 
                (
                    local Pos  = ui_RecordWindow.GetRecordPos()
                    local Size = ui_RecordWindow.GetRecordRes()

                    local Point_x = Pos.x + Size.width/2
                    local Point_y = Pos.y + Size.height/2
                    
					local WinApi  = dotnetclass "RefPlayer.WinApi"
                    local HWnd = WinApi.GetWindowFromPoint point_x point_y
                    local HWndRoot = (windows.getHWNDData HWnd)[7]

                    bool_Result = HWndRoot == windows.getMAXHWND()
                )

                fn UpdateRecordButtonDes =
                (
                    local RecordDes = if RecorderOnMax() then REC_RECORD_TOOLTIP_MAXMODE else (
                        case dRec_GetAssistanceType() of
                        (
                            (1):REC_RECORD_TOOLTIP_NORMAL
                            (2):REC_RECORD_TOOLTIP_SPACEKEY
                            (3):REC_RECORD_TOOLTIP_MEDIAKEY
                        )
                    )

                    if m_RecorderMode == MODE_RECORDER_PREVIEWING do RecordDes = REC_ABORT_TOOLTIP
 
                    rResLabel.Text = RecordDes
                )

                dotnet.addeventhandler rRecordButton #MouseEnter (fn _SetRecDesText sender eventArgs = 
                        if ShowRecorderDes do UpdateRecordButtonDes())

                dotnet.addeventhandler rRecordButton #MouseLeave (fn _SetRecDesText sender eventArgs = 
                    if ShowRecorderDes do uifn_ResumeRecorderDes())
 
                dotnet.addeventhandler rRecordButton #Click  (fn _RecordButtonClick = 
                (
                    if m_RecorderMode == MODE_RECORDER_IDLE then /* StartRec */
                    (
                        cRec_StartRecord()
                    )
                    else if m_RecorderMode == MODE_RECORDER_RECORDING then /* StopRec */
                    (
                        cRec_StopRecord()
                    )
                    else if m_RecorderMode == MODE_RECORDER_PREVIEWING then /* Cancel Prevew  */
                    (
                        cRec_StopPreview()
                        fRec_DeleteRecordImage()
                    )
                ))
                 dotnet.addeventhandler rRecordButton #MouseDown  (fn _SwitchRecAssistMode sender eventArgs = 
                 (
                    if eventArgs.Button.ToString() == "Right" do
                    (
                        if not RecorderOnMax() do 
                        (
                            local AssistTypeIndex = dRec_GetAssistanceType()
							AssistTypeIndex = mod AssistTypeIndex 3 + 1
                            dRec_SetAssistanceType AssistTypeIndex

                            if RecordSetting_Rollout.open do 
                            (
                                RecordSetting_Rollout.Load()
                                RecordSetting_Rollout.UpdateDescriptionLabel()
                            )
                            
                            UpdateRecordButtonDes()
                        )
                    )
                 ))

                --dotnet.addeventhandler OpenFileButton #Click  fn OpenFileButtonClick 
                
                dotnet.addeventhandler ui_RecordWindow #Resize (fn _SetResLabel sender eventArgs =
                (
                    ui_RecordWindow.SetResText()
                    ShowRecorderDes   = not ui_RecordWindow.Width < 350 * ScaleFactor 
                    rResLabel.visible = not ui_RecordWindow.Width < 280 * ScaleFactor
                ))
				

				dotnet.addeventHandler ui_PlayerWindow #Resize (fn _ChangeToolStripSize sender eventArgs =
				(
					uifn_ResizePlayerToolStrip()
				))

                dotnet.addeventhandler rSettingButton #Click  (fn _OpenRecorderSetting =
                (
                    uifn_OpenSetting open:#Record hwnd:ui_RecordWindow.Handle
                ))

                fn Rec_ReturnToPlayer = 
                (
                    m_RecorderMode = MODE_RECORDER_IDLE
                    uifn_RecorderIdleMode()
                    uifn_RecorderToPlayer()
                    uifn_UpdatePlayerTS() /* visiable would turn to false on recordmode */
                )

                dotnet.addeventhandler rBackButton #Click   ( fn _ReturnToPlayer =
                (
                    if m_RecorderMode == MODE_RECORDER_PREVIEWING do 
                    (
                        cRec_StopPreview()
                        fRec_DeleteRecordImage()
                    )

					if not m_PlayerMode == MODE_PLAYER_HOME do fFile_ReadPlayList 1

                    Rec_ReturnToPlayer()
                ))

                
                dotnet.addeventHandler rFinishButton  #Click   (fn _rFinishRecord sender eventArgs =
                (
                    (/* Open Recorded File */
                        cRec_StopPreview()
                        RP_OpenFile (dRec_GetRecordFolder())
                        dTime_SetStartTime 0
                        cDisplay_ScaleToRatio 1
                        fFile_SavePlayList() 
                    )

                    Rec_ReturnToPlayer()              
                ))

                dotnet.addeventHandler rGifButton  #Click   (fn _rOpenGifRollout sender eventArgs =
				(
					uifn_OpenGifRollout parent:ui_RecordWindow.handle
				))

            )
			
			
            (---- PlayerToolStrip -----

				local PlayerTsItems = #()
                local HistoryButton

            	fn AddControl_Player ControlType Text: Image: ForeColor: Align:#Left Enabled:true Des: Font:#Default ToolTip: = 
				(
					newControl = AddControl ControlType Text:Text Image:Image ForeColor:ForeColor Align:Align Enabled:Enabled Des:Des Font:Font

					newControl.Padding = dotNetObject "System.Windows.Forms.Padding" 3	

					append PlayerTsItems newControl

					if ToolTip != unsupplied do
						newControl.ToolTipText = ToolTip
					

					dotnet.addeventhandler newControl #MouseEnter  (fn _TSControlMouseEnter sender eventargs = 
					(
						sender.backcolor = DNColor.FromARGB 50 50 50

                        if sender != HistoryButton do HistoryButton.DropDown.CLose() /* Avoid Max HotKey Diabled */

					))

					dotnet.addeventhandler newControl #MouseLeave  (fn _TSControlMouseEnter sender eventargs = 
					(
						sender.backcolor = DNColor.Transparent
					))
					

					ui_PlayerToolStrip.items.add newControl

					newControl
				)

                
                CloseButton    = AddControl_Player "ToolStripButton"  Text:PLAYER_CLOSE   Font:#Arial ToolTip:PLAYER_CLOSE_TOOLTIP
                MinimizeButton = AddControl_Player "ToolStripButton"  Text:PLAYER_MINIMIZE_CLOSED   Font:#Arial ToolTip:PLAYER_MINIMIZE_CLOSED_TOOLTIP
                RecordButton   = AddControl_Player "ToolStripButton"  Text:PLAYER_RECORDER ForeColor:(RGBColor 255 100 100) ToolTip:PLAYER_RECORDER_TOOLTIP --Align:#right 
				
                Separator      = AddControl_Player "ToolStripSeparator"
                HistoryButton  = AddControl_Player "ToolStripDropDownButton" Text:PLAYER_HISTORY ToolTip:PLAYER_HISTORY_TOOLTIP --Align:#right Image:icons.History
                HistoryButton.ShowDropDownArrow = false
                PreloadButton  = AddControl_Player "ToolStripButton"  Text:PLAYER_PRELOAD ToolTip:PLAYER_PRELOAD_TOOLTIP --Align:#right  Image:icons.Preload
                SettingButton  = AddControl_Player "ToolStripButton"  Text:PLAYER_SETTING ToolTip:PLAYER_SETTING_TOOLTIP --ForeColor:DNColor.White Align:#right 
                --SettingButton.Margin = dotNetObject "System.Windows.Forms.Padding" 0 0 0 40
				GifButton  = AddControl_Player "ToolStripButton"  Text:PLAYER_GIF Font:#Arial ToolTip:PLAYER_GIF_TOOLTIP

                LockButton = AddControl_Player "ToolStripButton"  Image:Icons.Lock  
                LockButton.Alignment = LockButton.Alignment.Right
				--LockButton.ImageAlign = LockButton.ImageAlign.MiddleLeft

                --GridButton     = AddControl toolStripButton  Text:"网格"  Align:#right  --Des:"参考线设置" Image:icons.Grid 

                fn uifn_PlayerUIHomeMode = 
                (
                    for c in PlayerTsItems do c.visible = false

                    for c in #(CloseButton,RecordButton,Separator,HistoryButton) do c.visible = true
					
					--HistoryButton.Alignment = HistoryButton.Alignment.Left
                )
                
                fn uifn_PlayerUINormalMode =
                (
                    for c in PlayerTsItems do c.visible = true
                )

                fn uifn_PlayerUIMinimizedMode =
                (
                    for c in PlayerTsItems do c.visible = false

                    for c in #(CloseButton,MinimizeButton) do c.visible = true
                )

                fn uifn_PlayerUILockMode =
                (
                    for c in PlayerTsItems do c.visible = false

                    LockButton.visible = true
                )

				mapped fn ResizeToolStripItem item fontSize height =
				(
					if fontsize != item.font.size do
					(
						local newFont = dotnetobject "System.Drawing.Font" \
						item.font.FontFamily fontsize (dotNetClass "system.drawing.fontStyle").Bold

						item.font = newFont
					)

					item.autosize = false
					item.height = height
				) 
				
				local ArialToolStripItems = #(CloseButton,MinimizeButton) 
				local YaHeiToolStripItems = #(RecordButton,HistoryButton,PreloadButton,SettingButton,GifButton)

				fn uifn_ResizePlayerToolStrip =
				(
					local CanResize = 
						not uifn_MinimizeAnimPlaying() and not uifn_PlayerIsMinimize()

					if CanResize do
					(
						/* Yahei size */

						local maxFontSize = 8
						local maxHeight   = 25 * ScaleFactor

						local fontsize = ui_PlayerWindow.height / 25.0
						local height   = ui_PlayerWindow.height / 8.5

						if fontsize > maxFontSize do fontsize = maxFontSize
						if height   > maxHeight   do height   = maxHeight

						ResizeToolStripItem YaHeiToolStripItems fontsize height

						/* Arial ToolStrip items  */

						local ArialMultiplier = 0.9
						fontsize *= ArialMultiplier
						height   *= ArialMultiplier

						ResizeToolStripItem ArialToolStripItems fontsize height
					)
				)
				
				fn uifn_CaculateMinimizeSize &width &height =
				(
					local padding = 3
					height = CloseButton.Height + MinimizeButton.Height + padding * ScaleFactor
					width  = CloseButton.Width 
				)
                
                --ToolStrip.items.add 
                
                ui_PlaylistItemArray = for i = 1 to 10 collect
                (
                    newItem = dotnetobject "ToolStripMenuItem"
                    newItem.tag = i
                    
                    HistoryButton.DropDownItems.Add newItem
                    
                    newItem
                )
				

                dotnet.addeventHandler HistoryButton #DropDownItemClicked (fn _ReadPlayList sender eventArgs = 
                (
                    fFile_ReadPlayList eventArgs.ClickedItem.tag
                ))


                dotnet.addeventhandler SettingButton   #Click   (fn _OpenAllSettings sender eventArgs = 
                (
                    uifn_OpenSetting open:#All hwnd:ui_PlayerWindow.Handle
                ))

				
                dotnet.addeventhandler CloseButton     #Click   (fn _QuitRefPlayer sender eventArgs   =
                (
                    RP_Quit()
                ))
				

                dotnet.addeventHandler MinimizeButton  #Click   (fn _ToggleMinimize sender eventArgs =
                (
                    uifn_MinimizePlayer()

                    if uifn_PlayerIsMinimize() then (
                        sender.text = PLAYER_MINIMIZE_OPEN
						sender.ToolTipText = ""
						uifn_PlayerUIMinimizedMode()
                    )else (
                        sender.text = PLAYER_MINIMIZE_CLOSED
						sender.ToolTipText = PLAYER_MINIMIZE_CLOSED_TOOLTIP
						uifn_PlayerUINormalMode()
                    )
                ))
                
                dotnet.addeventHandler PreloadButton   #Click   (fn _PreloadImages sender eventArgs =
                (
                    local ButtonText = sender.text
					
                    local lastPercent = 0
					local ImageDatas = dFile_GetImageDatas()
					local ImageCount = dFile_GetImageCount()

                    for i = 1 to ImageCount do 
                    (
                        ImageDatas[i].LoadImageFile()
                        Percent = i*100/ImageCount
                        
                        if Percent != lastPercent do
                        (
                            lastPercent = Percent
                            sender.text = (Percent as string + "%")
                        )
                        
                        if mod i 20 == 0 do windows.processPostedMessages()
                    )
                    
                    sender.text  = ButtonText
                ))

                --dotnet.addeventHandler GridButton      #Click  ( fn GridButtonClick =  
                dotnet.addeventHandler RecordButton  #Click   (fn _SwitchToRecorder sender eventArgs =
                (
                    uifn_PlayerToRecorder();
					fFile_SavePlayList();
                ))
  			    dotnet.addeventHandler GifButton  #Click   (fn _OpenGifRollout sender eventArgs =
				(
					uifn_OpenGifRollout parent:ui_PlayerWindow.handle
				))

                dotnet.addeventHandler LockButton  #Click   (fn _LockPlayer sender eventArgs =
				(
					ui_PlayerWindow.clickThrough    = not ui_PlayerWindow.clickThrough
                    --ui_PlayerToolStrip.clickThrough = not ui_PlayerToolStrip.clickThrough

                    if ui_PlayerWindow.clickThrough then
                    (
                        uifn_DisableTSAutoHide()
                        uifn_PlayerUILockMode()

						sender.BackColor = DNColor.Transparent
                        uifn_HideTSGradient()

                        ui_PlayerToolStrip.Dock = DockStyle.None
                        local posx =  sender.Width * 0.9 - ui_PlayerToolStrip.Width 
                        local posy = ui_PlayerWindow.Height - ui_PlayerToolStrip.Height + 2
                        ui_PlayerToolStrip.location = DNPoint posx posy

						
                    )else 
                    (

                        uifn_EnableTSAutoHide()
                        uifn_PlayerUINormalMode()
                        ui_PlayerToolStrip.Dock = DockStyle.Left

                        uifn_ShowTSGradient()
                    )
				))

                if RPLockButtonAutoHide do
                (
                    dotnet.addeventHandler LockButton  #MouseLeave  (fn _HideImgOnLockMode sender eventArgs =
                    (
                        if ui_PlayerWindow.clickThrough do 
                        (
                            LockButton.AutoSize = false
                            LockButton.image = undefined
                        )
                    ))

                    dotnet.addeventHandler LockButton  #MouseEnter   (fn _HideImgOnLockMode sender eventArgs =
                    (
                        if ui_PlayerWindow.clickThrough do  
                        (
                            LockButton.image = Icons.Lock 
                            LockButton.AutoSize = true
                        )
                    ))
                )


            )

			/* Debug */Debug_LogTime "Player&Recorder ToolStrip"
        )


		(------ Home Panel -----
		
			local HighlightControls = #()
			local HomeControls = #()

			---------------------------------------
			/*         Label Create             */
			---------------------------------------
			
			fn CreateLabel Pos: Colour: Text: FontSize:10 Bold:true Italic:false Highlight:false Cursor: = 
			(
				NewLabel = dotnetobject "System.Windows.Forms.Label"
				
				NewLabel.AutoSize = true
				NewLabel.BackColor = (dotnetclass "System.Drawing.Color").Transparent
				
				if Text   != unsupplied  do NewLabel.Text = Text
				if Cursor != unsupplied  do NewLabel.Cursor = Cursor
				if Pos    != unsupplied  do NewLabel.Location = dotnetobject "System.Drawing.Point" Pos.x Pos.y
				if Classof Colour == Color then NewLabel.ForeColor = RGBColor Colour.r Colour.g Colour.b
				if Classof Colour == Integer do NewLabel.ForeColor = RGBColor Colour Colour Colour
                if Classof Colour == dotnetobject do NewLabel.ForeColor = Colour

				NewLabel.Font = DNFont "Microsoft YaHei" FontSize Bold:Bold Italic:Italic
				
				if Highlight do append HighlightControls NewLabel

				append HomeControls NewLabel

				NewLabel
			)
			
			---------------------------------------
			/*    BACKGROUND PAINTING EVENT     */
			---------------------------------------
			
			local HomePanelBackgrounds = #()

			struct DrawingRect 
			(
				Pen,Rect,
				
				fn Draw eventArgs = 
					eventArgs.Graphics.DrawRectangle Pen Rect,

				on create do append HomePanelBackgrounds this
			)
			
			struct DrawingString
			(
				Txt,Font,Brush,Pos,
				
				fn Draw eventArgs =
					eventArgs.Graphics.DrawString Txt Font Brush Pos.x Pos.y,

				on create do append HomePanelBackgrounds this
			)

			
			/*  COLOR SETTING  */
            
			local BackColor      = GrayscaleColor 40
			local TitleColor     = GrayscaleColor 130
			local TitleShadowColor = RGBColor 20 20 30
			local DragAreaColor  = GrayscaleColor 90
			local TutorialColor  = RGBColor 50 150 50

			local DashRect      = DrawingRect()
			DashRect.Pen = dotnetobject "System.Drawing.Pen" DragAreaColor
			DashRect.Pen.DashPattern = #( 5,4 )
			DashRect.Pen.Width = 2
			DashRect.Rect = dotnetobject "System.Drawing.Rectangle" (25*ScaleFactor) (20*ScaleFactor) (375*ScaleFactor) (120*ScaleFactor)

			local RefPlayerTitleShadow = DrawingString()
			RefPlayerTitleShadow.txt   = HOME_TITLE --参考大师
			RefPlayerTitleShadow.Font  = DNFont "Microsoft YaHei" 30 Bold:true
			RefPlayerTitleShadow.Brush = SolidBrush TitleShadowColor
			RefPlayerTitleShadow.Pos   = [23,180] * ScaleFactor
			
			local RefPlayerTitle = DrawingString()
			RefPlayerTitle.txt   = HOME_TITLE --参考大师
			RefPlayerTitle.Font  = DNFont "Microsoft YaHei" 30 Bold:true
			RefPlayerTitle.Brush = SolidBrush TitleColor
			RefPlayerTitle.Pos   = [15,175] * ScaleFactor
			
			local DragAreaTitle = DrawingString()
			DragAreaTitle.txt   = HOME_DRAGAREA_TITLE --拖拽区
			DragAreaTitle.Font  = DNFont "Microsoft YaHei" 22
			DragAreaTitle.Brush = SolidBrush DragAreaColor
			DragAreaTitle.Pos   = [160,35] * ScaleFactor
			
			local DragAreaText = DrawingString()
			DragAreaText.txt   = HOME_DRAGAREA_TEXT --(拖拽图像文件至窗口)
			DragAreaText.Font  = DNFont "Microsoft YaHei" 10 
			DragAreaText.Brush = SolidBrush DragAreaColor
			DragAreaText.Pos   = [145,75] * ScaleFactor

			local DragAreaDescription   = DrawingString()
			DragAreaDescription.txt   = (
				(dotnetclass "System.String").format HOME_DRAGAREA_DESCRIPTION \ --录制分辨率最高{0}*{1} 录制时长{2}秒
				RPMaxRecordReslotion.x RPMaxRecordReslotion.y RPMaxRecordSeconds
			)
			DragAreaDescription.Font  = DNFont "Microsoft YaHei" 10 
			DragAreaDescription.Brush = SolidBrush DragAreaColor
			DragAreaDescription.Pos   = [100,115] * ScaleFactor




			fn _PaintHomeBackground sender eventArgs =
			(
				sender.BackColor = BackColor
				
				for x in HomePanelBackgrounds do x.Draw eventArgs
			)
			
			--------------------------------------------
			/*     MOUSE ENTER HIGHLIGHT EVENTS     */
			--------------------------------------------
			
			local HightlightColorIncrease = 30

			fn SetLabelColor sender ColorIncrease =
			(
				r = sender.ForeColor.r + ColorIncrease
				g = sender.ForeColor.g + ColorIncrease
				b = sender.ForeColor.b + ColorIncrease
				
				if r > 255 do r = 255
				if g > 255 do g = 255
				if b > 255 do b = 255
				
				sender.ForeColor = DNColor.FromARGB 255 r g b
			)

			fn _HomeHighlightMouseEnter sender eventArgs = SetLabelColor sender HightlightColorIncrease
			fn _HomeHighlightMouseLeave sender eventArgs = SetLabelColor sender -HightlightColorIncrease
				
			
			
			--------------------------------------------
			/*  CREATE CONTROLS ,ADD EVENTHANDLERS   */
			--------------------------------------------
			
			fn OpenTutorialLink   = shellLaunch "https://www.cgjoy.com/forum.php?mod=viewthread&tid=248859&page=1" ""
            fn OpenCompanyWebsite = shellLaunch "http://www.brozone.cn" ""

            fn CreateHomePanel =
            (
				--if m_PlayerMode == MODE_PLAYER_HOME do return()

				local Cursors = (dotnetclass "Cursors")
                local winform = ui_PlayerWindow

				winform.width  = 420 * ScaleFactor
				winform.Height = 240 * ScaleFactor
				winform.BackColor = BackColor

				Label_Title    = CreateLabel Pos:([15,175] * ScaleFactor)   Highlight:false  FontSize:30 Text:HOME_TITLE    Colour:TitleColor
				Label_Version  = CreateLabel Pos:([193,210] * ScaleFactor)  Highlight:false  FontSize:10 Text:RPVersion     Colour:TitleColor
				Label_Tutorial = CreateLabel Pos:([362,162] * ScaleFactor)  Highlight:true   FontSize:14 Text:HOME_TUTORIAL Colour:TutorialColor Cursor:Cursors.Hand
				Label_Company  = CreateLabel Pos:([342,188] * ScaleFactor)  Highlight:true   FontSize:11  Text:HOME_COMPANY  Colour:TitleColor    Cursor:Cursors.Hand
				Label_Clinical = CreateLabel Pos:([327,210] * ScaleFactor)  Highlight:true   FontSize:11  Text:HOME_CLINICAL Colour:TitleColor    
				
				dotnet.addeventhandler Label_Tutorial #MouseClick OpenTutorialLink
                --dotnet.addeventhandler Label_Company  #MouseClick OpenCompanyWebsite
				dotnet.addeventhandler winform #Paint _PaintHomeBackground
				
				for Label in HighlightControls do
				(
					dotnet.addeventhandler Label #MouseEnter _HomeHighlightMouseEnter 
					dotnet.addeventhandler Label #MouseLeave _HomeHighlightMouseLeave 
				)

				for c in HomeControls do winform.Controls.Add c

            )
			
			fn uifn_ShowHomePanel =
			(
                m_PlayerMode = MODE_PLAYER_HOME
				uifn_SetPicBoxVisible false
				
                uifn_PlayerUIHomeMode()
                CreateHomePanel()
			)

			fn uifn_QuitHomePanel =
			(
                m_PlayerMode = MODE_PLAYER_NORMAL
				uifn_SetPicBoxVisible true

				for c in HomeControls do c.Dispose()
				HomeControls = #()
				dotnet.removeeventhandler ui_PlayerWindow #Paint _PaintHomeBackground
				
                uifn_PlayerUINormalMode()
			)

			/* Debug */Debug_LogTime "Create Home Panel"
		)


	)
	
	(----- Functions ↓ ------

		(----- ScreenRecord -----

			fn GetDeskTop = (Dotnetclass "System.Environment").GetFolderPath (dotnetclass "System.Environment+SpecialFolder").DeskTop

			local SaveDir = GetDeskTop()
			local MaxFileCount = 30 * RPMaxRecordSeconds
			
			local AssistType = #(#None,#Space,#MediaPlayPause)
			local AssistanceMode = 1
			
			local RecordPos,RecordSize
			local RecordMouse = false
			local Recording = false
			local FileCount = 0
			local CurrentRecordFolder
			local RecordImages = #()
			local RecordHWnd = 0 
			
			s_Recorder.RecordSavePath = &SaveDir
			s_Recorder.AssistanceMode = &AssistanceMode
			s_Recorder.RecordMouse    = &RecordMouse

			fn SaveRecSetting = SettingCtrl.Save s_Recorder
			fn LoadRecSetting = SettingCtrl.Load s_Recorder
				
			LoadRecSetting()


			
			fn RecordAssist =
			(
				if RecordHWnd == 0 or AssistType[AssistanceMode] == #None do return()

				SendKeys = dotnetclass "System.Windows.Forms.SendKeys"

				local hwnd = dotnetobject "System.IntPtr" RecordHWnd

				local WinApi  = dotnetclass "RefPlayer.WinApi"
				WinApi.SetForegroundWindow hwnd
				--sleep 0.05
				if AssistType[AssistanceMode] == #Space do 
				(
					SendKeys.SendWait " "
				)
				if AssistType[AssistanceMode] == #MediaPlayPause do
				(
					WM_APPCOMMAND = 0x319
					APPCOMMAND_MEDIA_PLAY_PAUSE = 0xE0000
					
					windows.SendMessage RecordHWnd WM_APPCOMMAND RecordHWnd APPCOMMAND_MEDIA_PLAY_PAUSE 
				)
			)
			
			fn GetAssistanceMode = AssistType[AssistanceMode]
			
			(-- Record
				local Graphics
				local ScreenBitmap
				local SaveFormat = (DotNetClass "System.Drawing.Imaging.ImageFormat").jpeg

				fn CreateGraphics =
				(
					ScreenBitmap = dotnetobject "System.Drawing.Bitmap" \
					RecordSize.width RecordSize.height (dotnetclass "System.Drawing.Imaging.PixelFormat").Format32bppPArgb
					
					Graphics = (dotnetclass "System.Drawing.Graphics").FromImage ScreenBitmap
				)
				
				fn DisposeGraphics =
				(
					ScreenBitmap.Dispose()
					Graphics.Dispose()
				)

				fn GetNextRecordFolder =
				(
					RecordFolderIsEmpty = CurrentRecordFolder != undefined and (getFiles (CurrentRecordFolder + "\\*")).count == 0
					if RecordFolderIsEmpty do return CurrentRecordFolder
					
					FolderName = HOME_TITLE
					
					for i = 1 to 99999 do 
					(
						num_String = if i < 10 then ("0" + i as string) else i as string
						
						RecordPath = SaveDir + "\\" + FolderName + num_String
						if not doesFileExist RecordPath do return RecordPath
					)
				)
				
				fn GetNextFileName =
				(
					local TimeCode = (dotnetclass "System.String").format "{0:d5}" FileCount

					CurrentRecordFolder + "\\" + TimeCode + ".jpg"
				)
				
				fn RecordScreenImage =
				(
					local ImageFileName = GetNextFileName()

					Graphics.CopyFromScreen RecordPos.x RecordPos.y 0 0 ScreenBitmap.Size (dotnetclass "System.Drawing.CopyPixelOperation").SourceCopy
					
					if RecordMouse do 
					(
						local WinApi = dotnetclass "RefPlayer.WinApi"
						local CursorPos  = Cursor.Position
						local x = CursorPos.X - RecordPos.x
						local y = CursorPos.Y - RecordPos.y
						WinApi.CaptureMouseToGraphics Graphics x y

						/*
						local CursorPos  = Cursor.Position
						local CursorSize = Cursor.Current.Size
						local CursorRect = dotnetobject "System.Drawing.Rectangle" \
						(CursorPos.X - RecordPos.x)  (CursorPos.Y - RecordPos.y) CursorSize.Width CursorSize.Height

						Cursor.Current.Draw Graphics CursorRect
						*/
					)
					--Graphics.Flush() 
					ScreenBitmap.Save ImageFileName SaveFormat

					append RecordImages ImageFileName
			
					FileCount += 1
				)

				fn RecordMax = 
				(
					CreateGraphics()

                    local RecordInterval = frameRate / 30.
					for i = animationrange.start to animationrange.end by RecordInterval do
					(
						if not Recording do exit
						
						slidertime = i
						RedrawViews()
						RecordScreenImage()
						
						windows.processPostedMessages()

						if i > (animationrange.end - RecordInterval) do cRec_StopRecord()
					)

					DisposeGraphics()
					
					cRec_StartPreview()
				)
		
				fn Record =
				(
					CreateGraphics()

					local WinApi  = dotnetclass "RefPlayer.WinApi"
					local LastFrameTimeStamp = 0

					while Recording do
					(
						while timestamp() -  LastFrameTimeStamp < 30 do 
							WinApi.DwmFlush()

						LastFrameTimeStamp = timestamp()

						RecordScreenImage()
						
						if FileCount >= MaxFileCount do cRec_StopRecord() 

						windows.processPostedMessages()

					)
					
					DisposeGraphics()
					cRec_StartPreview()

				)

                fn Record_AeroOff =
                (
                    CreateGraphics()
                    
                    local LastFrameTimeStamp = 0

                    while Recording do
                    (
                        RecordInterval = 30 + (if mod FileCount 3 == 0 then 1 else 0)

                        currentTimeStamp = timestamp()

                        if (currentTimeStamp - LastFrameTimeStamp) >=  RecordInterval do
                        (
                            LastFrameTimeStamp = currentTimeStamp
                            
                            RecordScreenImage()
                            
                            if FileCount >= MaxFileCount  do cRec_StopRecord()

                            windows.processPostedMessages()
                        )
                    )

                    DisposeGraphics()
                    cRec_StartPreview()
                )


			)
			
			fn dRec_GetRecordFolder = CurrentRecordFolder
            fn dRec_GetAssistanceType = AssistanceMode
            fn dRec_SetAssistanceType i = AssistanceMode = i
			fn dRec_GetRecordFiles  = RecordImages
			

			fn fRec_StartRecord Pos Size = /*TODO:Should we support moving record region ? */
			(
				--SetRecordPosSize
				if classof Pos == Point2  do Pos  = dotnetobject "System.Drawing.Point" Pos.x Pos.y
				if classof Size == Point2 do Size = dotnetobject "System.Drawing.Size" Size.x Size.y
					
				RecordPos = Pos
				RecordSize = Size
				
				-- GetFilePath to save
				RecordImages = #()
				FileCount = 0
				CurrentRecordFolder = GetNextRecordFolder()
				makedir CurrentRecordFolder
				
				-- Record Assist
				local Point_x = Pos.x + Size.width/2
				local Point_y = Pos.y + Size.height/2
				
				local WinApi  = dotnetclass "RefPlayer.WinApi"
                RecordHWnd = WinApi.GetWindowFromPoint point_x point_y
                local HWndRoot = (windows.getHWNDData RecordHWnd)[7]

				if HWndRoot == windows.getMAXHWND() then
				(
					Recording = true
					RecordMax()
					RecordHWnd = 0
				)else
				(
					Recording = true                    
					RecordAssist()

					local AeroEnabled = WinApi.DwmIsCompositionEnabled()
					if AeroEnabled then Record() else Record_AeroOff()
				)
			)
				
			fn fRec_StopRecord = 
			(
				Recording = false
				RecordAssist()
			)

            fn fRec_GetRecordImage = RecordImages
			
			fn fRec_DeleteRecordImage = for file in RecordImages do deleteFile file

		)
		
		(----- ImageSequence ------
			
			fn LoadImage file = messageBox "Error: LoadImage Not Set!"
			fn SetImageLoadSolution = ()
			
			local CurrFolder 
			local ImageDatas = #()	

			local ImageRes = [0,0]
			local LoadRes  = [0,0]
			
            fn dFile_GetImageCount = ImageDatas.count 
			fn dFile_GetCurrFolder = CurrFolder
			fn dFile_GetImageDatas = ImageDatas
			fn dFile_GetImageLoadRes = LoadRes

			struct ImageData 
			(
				ImageFile,Image,
				ImageLoaded = false,
				
				fn LoadImageFile =
				(
					Image = LoadImage ImageFile 
					ImageLoaded = true
				),
				
				fn GetImage =
				(
					if not ImageLoaded do LoadImageFile()
					
					Image
				),
				
				fn Dispose = if ImageLoaded do Image.Dispose()
			)


			(---- RAM Manager ----
				
				local MaxRAM_Mode = 1
				local MaxRAM_Percentage = .5
				local MaxRAM_Usage = 1000
				
				fn LoadRAMSetting = SettingCtrl.Load s_Ram
				fn SaveRAMSetting = SettingCtrl.Save s_Ram
					
				s_Ram.MaxRAM_Mode       = &MaxRAM_Mode
				s_Ram.MaxRAM_Percentage = &MaxRAM_Percentage
				s_Ram.MaxRAM_Usage      = &MaxRAM_Usage

				LoadRAMSetting()
				
				--SettingCtrl.SaveRamSetting = SaveSetting

				/* LoadImage Function */
				
				local PixelFormat = (dotnetclass "System.Drawing.Imaging.PixelFormat").Format32bppPArgb

				fn GetOriginalImage filePath = (dotnetclass "System.Drawing.Image").FromFile filePath

				fn GetResizedImage  filePath =
				(
					local ImageTemp = GetOriginalImage filePath 
				
					local NewBitmap = dotnetobject "System.Drawing.Bitmap" LoadRes.x LoadRes.y PixelFormat
					local g = (dotnetclass "System.Drawing.Graphics").FromImage NewBitmap
					g.DrawImage ImageTemp (dotnetobject "System.Drawing.Rectangle" 0 0 LoadRes.x LoadRes.y)
					
					g.Dispose();ImageTemp.Dispose()
				
					NewBitmap
				)

				/* Set ImageLoad Solution by Memory Condition  */

				fn GetFreeMemory = (sysinfo.getSystemMemoryInfo())[3] / (1024*1024.)
				
				fn CaculateMemoryUsage imageWidth imageHeight imageCount =
					(imageWidth * imageHeight * 4 /(1024*1024.) * imageCount)
				
				fn GetExpectedMemoryUsage = 
				(
					case MaxRAM_Mode of
					(
						(1):GetFreeMemory() * MaxRAM_Percentage
						(2):MaxRAM_Usage
					)
				)
				
				fn SetImageLoadSolution imageWidth imageHeight imageCount =
				(
					local ExpectedMemoryUsage = GetExpectedMemoryUsage()
					local FullMemoryUsage = CaculateMemoryUsage imageWidth imageHeight imageCount
					local DecreaseMultiplier = sqrt (ExpectedMemoryUsage/FullMemoryUsage)
					
					if DecreaseMultiplier < 1 then
					(
						LoadRes.x  = (imageWidth  * DecreaseMultiplier + .5) as integer
						LoadRes.y  = (imageHeight * DecreaseMultiplier + .5) as integer
						
						LoadImage = GetResizedImage
					)else
					(
						LoadRes = [imageWidth,imageHeight]
						LoadImage = GetOriginalImage
					)
				)
				
			)

			/*      File      */

			fn PreloadAll =
			(
				for i = 1 to ImageDatas.count do 
				(
					ImageDatas[i].LoadImageFile()
					
					if mod i 20 == 0 do windows.processPostedMessages()
				)
			)
			
			fn FreeImgDatas = 
			(
				for ImgData in ImageDatas do ImgData.Dispose()
				
				free ImageDatas
			)
			
			fn fFile_ReadFolder Folder =
			(
				local imagesInPath = #()
				local imageTypes   = #("*.png","*.jpg")

				for type in imageTypes do 
					imagesInPath += GetFiles (Folder + "\\" + type)
					
				if imagesInPath.count == 0 do
				(	
					if doesFileExist Folder 
						then messageBox ERROR_NO_IMAGE_FILE 
						else messageBox ERROR_FOLDER_NOT_EXIST
					
					return false
				)
				
				/*  Load New Folder  */

				fFile_SavePlayList();

				ui_PlayerPictureBox.image = undefined 

				FreeImgDatas()
				
				CurrFolder = Folder
				
				ImageDatas = for ImgFile in imagesInPath collect (ImageData ImageFile:ImgFile)
				
				ImageRes = 
				(
                    local BitmapInfo = getBitmapInfo imagesInPath[1]
                    res = [BitmapInfo[3],BitmapInfo[4]]
					
					res
				)
				
				SetImageLoadSolution ImageRes.x ImageRes.y ImageDatas.count

				true
			)
			
			fn fFile_GetImage index = ImageDatas[index].GetImage()
			
			fn final_FreeImageDatas = FreeImgDatas()
			
				
			
		)
		
		(----- GridGenerate -----
			struct RefPlayer_GridSetting
			(
				Category = "GridSetting",
				Enabled,Color,Opacity,HorizontalCount,VerticalCount
			)

			local GridEnabled = false
			local HorizontalCount = 4
			local VerticalCount   = 3
			local GridColor = white 
			local GridOpacity = .5
			local LineWidth = 1

			s_Grid.Enabled = &GridEnabled
			s_Grid.Color   = &GridColor
			s_Grid.Opacity = &GridOpacity
			s_Grid.HorizontalCount = &HorizontalCount
			s_Grid.VerticalCount   = &VerticalCount

			fn LoadGridSetting =
			(
				SettingCtrl.Load s_Grid
				
				if GridEnabled     == undefined do GridEnabled = false
				if HorizontalCount == undefined do HorizontalCount = 4
				if VerticalCount   == undefined do VerticalCount = 3
				if GridColor       == undefined do GridColor = white
				if GridOpacity     == undefined do GridOpacity = 0.5
			)
			
			fn SaveSetting = SettingCtrl.Save s_Grid
			
			LoadGridSetting()
			
			
			local GridBitmap
			
			fn fGrid_GenerateGridImage width height =
			(
				LineWidth = width / 900.

				try(GridBitmap.Dispose())catch()
					
				GridBitmap = dotnetobject "System.Drawing.Bitmap" width height
				GridBitmap.MakeTransparent()
				
				local LineColor = DNColor.FromArgb (GridOpacity*255) GridColor.r GridColor.g GridColor.b
				local Pen       = dotnetobject "System.Drawing.Pen" LineColor LineWidth

				local Graphics   = (dotnetclass "System.Drawing.Graphics").FromImage GridBitmap
				
				for i = 1 to VerticalCount - 1  do 
				(
					y = i/(VerticalCount as float) * height
					Graphics.DrawLine Pen 0 y width y
				)

				for i = 1 to HorizontalCount - 1 do 
				(
					x = i/(HorizontalCount as float) * width
					Graphics.DrawLine Pen  x 0 x height
				)
				
				Graphics.Dispose()
				
				GridBitmap
			)
			
			
			fn Dispose = try(GridBitmap.Dispose())catch()
			
			fn cDisplay_IsGridOn = GridEnabled

		)

		(----  Playlist  ----
			
			struct RefPlayer_PlayListData (FilePath,Width,Height,StartTime)
			global RefPlayer_PlayListData = RefPlayer_PlayListData
			
			local PlayListDataArray = #()
            local PlayListThumbArray = #()

            fn GetThumb size Folder =
            (
                local imgFiles = GetFiles (Folder + "\\*.jpg")
                if imgfiles.count == 0 do imgfiles += GetFiles (Folder + "\\*.png")
				if imgfiles.count == 0 do return()
				
                local source = (dotnetclass "System.Drawing.Image").FromFile imgfiles[1]
                local thumbSize = dotnetobject "System.Drawing.Size" size.x size.y
                local thumb = dotnetobject "System.Drawing.Bitmap" source thumbSize
                
                source.Dispose()
                
                thumb
            )

            fn FreeThumbs = 
            (
               for i = 1 to ui_PlaylistItemArray.count do
                    ui_PlaylistItemArray[i].image == undefined

                for x in PlayListThumbArray where x != undefined do x.Dispose()

                PlayListThumbArray = #()
            )

			
			fn UpdateDropDownItemArray =
			(
				for i = 1 to PlayListDataArray.count do
				(
					local Data = PlayListDataArray[i]
					local Item = ui_PlaylistItemArray[i]
					
					if Data == undefined then Item.visible = false 
					else (
                        Item.visible = true;
                        Item.text = data.filepath
                        Item.Image = 
                        (
                            if PlayListThumbArray[i] == undefined do
                            (
                                local FilePath = PlayListDataArray[i].FilePath
                                PlayListThumbArray[i] = GetThumb [20,20] FilePath
                            )

                            PlayListThumbArray[i]
                        )
                    )
				)
				
			)
			
			fn GetCurrentPlayingItemData =
			(
				local FilePath  = dFile_GetCurrFolder()
				local Width     = ui_PlayerPictureBox.Width
				local Height    = ui_PlayerPictureBox.Height
				local StartTime = dTime_GetStartTime()
				
				RefPlayer_PlayListData FilePath:FilePath Width:Width Height:Height StartTime:StartTime
			)

				
			fn fFile_SavePlayList =
            (
                if dFile_GetCurrFolder() == undefined do return(UpdateDropDownItemArray())

				local NewData = GetCurrentPlayingItemData()
				
				for i = PlayListDataArray.count to 1 by -1 where PlayListDataArray[i] != undefined do
				(
					FilePath = PlayListDataArray[i].FilePath


					if FilePath == NewData.FilePath do
                    (
                        DeleteItem PlayListDataArray i

                        ui_PlaylistItemArray[i].image = undefined
                        if PlayListThumbArray[i] != undefined do
                        (
                            PlayListThumbArray[i].Dispose()
                            DeleteItem PlayListThumbArray i 
                        ) 
                    )
				)
				
				insertItem NewData   PlayListDataArray 1
                insertItem undefined PlayListThumbArray 1
				
				if PlaylistDataArray.count == 11 do 
                (
                    deleteItem PlayListDataArray 11
                )
				if PlayListThumbArray.count == 11 do
				(
					--ui_PlaylistItemArray[i].image = undefined
					try(PlayListThumbArray[11].Dispose())catch()
					deleteItem PlayListThumbArray 11
				)

					
				SettingCtrl.Save s_PlayList
				
				UpdateDropDownItemArray()
            )
			
			fn fFile_ReadPlayList index =
			(
				data = PlayListDataArray[index]
				
				if RP_OpenFile data.FilePath do
				(
                    ui_PlayerWindow.Width  = data.Width
                    ui_PlayerWindow.Height = data.Height
                    dTime_SetStartTime data.StartTime

                    fFile_SavePlayList()

					RP_Update()
					cDisplay_UpdateGrid()
				)
				
			)
			
			fn init_PlayList =
			(
				PlayListDataArray = #()
				PlayListDataArray.count = 10
				
				s_PlayList.History01 = &PlayListDataArray[1]
				s_PlayList.History02 = &PlayListDataArray[2]
				s_PlayList.History03 = &PlayListDataArray[3]
				s_PlayList.History04 = &PlayListDataArray[4]
				s_PlayList.History05 = &PlayListDataArray[5]
				s_PlayList.History06 = &PlayListDataArray[6]
				s_PlayList.History07 = &PlayListDataArray[7]
				s_PlayList.History08 = &PlayListDataArray[8]
				s_PlayList.History09 = &PlayListDataArray[9]
				s_PlayList.History10 = &PlayListDataArray[10]
				
				
				SettingCtrl.Load s_PlayList


				(--Clear folder not exist or has no image file
					PlayListDataArray = for data in PlayListDataArray where 
					(
						data != undefined and
						(getFiles (data.FilePath + "\\*.jpg")).count + \
						(getFiles (data.FilePath + "\\*.png")).count > 0
					)collect data 
					
					PlayListDataArray.count = 10
				)

				fFile_SavePlayList()
			)

            fn final_FreeThumbs = FreeThumbs()
				
		)

		(---- GreateGif ----

			rollout CreateGif_Rollout SETTING_GIF_TITLE width:180 --生成Gif
			(
				
				--dotnetcontrol pb "picturebox" 
				--edittext saveDir "保存路径"

				group "quality"   --质量
				(
					radiobuttons quality labels:#(
					SETTING_GIF_QUALITY_HIGH,  --高  
					SETTING_GIF_QUALITY_MEDIUM,--中  
					SETTING_GIF_QUALITY_LOW    --低  
					) default:1
				)
				
				group "resolution" --尺寸
				(
					radiobuttons res labels:#(
						SETTING_GIF_RESOLUTION_IMAGE,     --原始尺寸
						SETTING_GIF_RESOLUTION_PLAYERSIZE --当前窗口尺寸
					) default:2
				)

				group "generate"   --生成
				(
					button generate SETTING_GIF_GENERATE_START \ --开始生成
					width:100 height:30 
					label progLabel ""
				)

				group "open"  --操作
				(
					button openGif  SETTING_GIF_OPEN_GIF \ --打开Gif
					across:2 enabled:false
					button openDir  SETTING_GIF_OPEN_DIR \ --打开路径
					enabled:false

				)
				
				on CreateGif_Rollout open do 
				(
					local GroupCtrls = for ctrl in CreateGif_Rollout.controls where classof ctrl == GroupStartControl collect ctrl

					GroupCtrls[1].Text = SETTING_GIF_QUALITY_GROUP
					GroupCtrls[2].Text = SETTING_GIF_RESOLUTION_GROUP
					GroupCtrls[3].Text = SETTING_GIF_GENERATE_GROUP
					GroupCtrls[4].Text = SETTING_GIF_OPEN_GROUP
					
					local GifCreator = dotnetclass "RefPlayer.GifCreator"
					GifCreator.GIF_INIT_COMPLETE         = GIF_INIT_COMPLETE
					GifCreator.GIF_PROCESSING_FRAME      = GIF_PROCESSING_FRAME
					GifCreator.GIF_CACULATE_VALID_REGION = GIF_CACULATE_VALID_REGION
					GifCreator.GIF_PREPARE_TO_ADD_FRAME  = GIF_PREPARE_TO_ADD_FRAME
					GifCreator.GIF_ADDING_FRAME          = GIF_ADDING_FRAME
					GifCreator.GIF_GENERATING_GIF        = GIF_GENERATING_GIF
					GifCreator.GIF_SAVEGIF_TO_FILE       = GIF_SAVEGIF_TO_FILE
					
				)

				local GifSaveDir
				local GifFullPath
				

                fn ShowProg s = 
                (
                    progLabel.text = s.ToString()
                    windows.processPostedMessages()
                )
				
				fn GenerateGif =
				(
                    local GifName = "MyGif"

					if m_RecorderMode == MODE_RECORDER_PREVIEWING then
					(
						local files = dRec_GetRecordFiles()
						local saveDir = dRec_GetRecordFolder()
					)
					else if m_PlayerMode == MODE_PLAYER_NORMAL then
					(
						local files = for d in dFile_GetImageDatas() collect d.ImageFile
						local saveDir = dFile_GetCurrFolder()
					)
					else return false

					GifSaveDir = saveDir
					GifFullPath = (saveDir + "\\" + GifName + ".gif")	
					
                    GifCreator = dotnetclass "RefPlayer.GifCreator"
                    dotNet.removeAllEventHandlers GifCreator
                    dotnet.addeventHandler GifCreator #SendMessageToMax ShowProg

                    local High = 1,Medium = 2,Low = 3
                    case quality.state of(
						/*  GifCreator.Init(int fps, float colorTolerance)*/
                        High:  GifCreator.Init 30 1
                        Medium:GifCreator.Init 30 4
                        Low:   GifCreator.Init 30 10
                    )
					
					local UseWindowSize = 
					(
						if m_RecorderMode == MODE_RECORDER_PREVIEWING then false 
						else (m_PlayerMode == MODE_PLAYER_NORMAL and res.state == 2)
					)
						
					if UseWindowSize then
						GifCreator.Start files GifFullPath ui_PlayerWindow.Width ui_PlayerWindow.Height
					else
						GifCreator.Start files GifFullPath

                    gc light:true
					(dotnetclass "System.GC").Collect 2 

					local FileSize = getFileSize GifFullPath
					FileSize = (dotnetclass "System.String").Format "{0:f2}" (FileSize /1024/1024.)
					progLabel.text = SETTING_GIF_SHOW_FILE_SIZE + FileSize + "MB"

					true	
				)
				
				on generate pressed do 
				(
					openGif.Enabled = false
					openDir.Enabled = false
					
					if GenerateGif() do 
					(
						openGif.Enabled = true
						openDir.Enabled = true
					)
				)

				on openGif pressed do 
				(
					ShellLaunch GifFullPath ""
				)

				on openDir pressed do 
				(
					ShellLaunch GifSaveDir ""
				)

			)


			
			fn uifn_CloseGifRollout = 
			(
				try(DestroyDialog CreateGif_Rollout)catch()
			)

			fn uifn_OpenGifRollout parent: =
			(
				uifn_CloseGifRollout()
				createDialog CreateGif_Rollout parent:parent
			)


		)
		

		/* Debug */Debug_LogTime "Load Functions"
	)

	(----- Controls ↓ ------

		(---- TimeCtrl ----
			local _StartTime = 30
			local _Fps = 30

			fn dTime_GetStartTime = _StartTime
			fn dTime_SetStartTime val = _StartTime = val
            fn dTime_GetPlayerFps = _Fps
            fn dTime_SetPlayerFps val = _Fps = val

            fn GetSeuqenceRange =
			(
				local start = _StartTime
				local end   = dFile_GetImageCount() + start
				
				interval start end
			)

			fn GetProgressString =
			(
				PLAYER_TIME_CURRENT + cTime_GetCurrTimeImgIndex() as string + "/" + dFile_GetImageCount() as string
			)
			
			fn GetTimeInfoString =
			(
				local range = GetSeuqenceRange()
				
				local start = (range.start.frame as integer) as string
				local end   = (range.end.frame as integer) as string
				
				result = PLAYER_TIME_STARTFRAME + start + PLAYER_TIME_ENDFRAME + end

			)

			fn GetTimeState =
			(
				GetProgressString() + "\n" +  GetTimeInfoString()
			)


			fn cTime_GetCurrTimeImgIndex =
			(
				local t = ((currentTime.frame + 1 - _StartTime)*_Fps/frameRate) as integer	
				local ImageCount = dFile_GetImageCount()
				
				if t < 1 then t = 1
				else if t >ImageCount then t = ImageCount
					
				t
			)
			
			fn cTime_SyncMaxTimeRange =
			(
				animationrange = GetSeuqenceRange()
				
				Des = GetTimeInfoString()
				uifn_SetTempPlayerDes Des duration:1000
			)
			

			fn cTime_Forward  =
			(
				_StartTime += 1
				RP_Update()
				
				Des = PLAYER_TIME_FORWARD + GetTimeState()
                uifn_SetTempPlayerDes Des duration:1200
			)
			
			fn cTime_Backward =
			(
				_StartTime -= 1
				RP_Update()
				
				Des = PLAYER_TIME_BACKWARD + GetTimeState()
				uifn_SetTempPlayerDes Des duration:1200
			)
			
			fn cTime_SetCurrImgAsFirstFrame =
			(
				local index  = cTime_GetCurrTimeImgIndex()
				--local Offset = (currentTime.frame - _StartTime) as integer
				_StartTime = - index + 1
				
				RP_Update()
			)

			fn cTime_SetCurrFrameAsStartTime =
			(
                dTime_SetStartTime currentTime.frame
                RP_Update()
			)
			
			fn dTime_GetTimeDatas  = 
			(
                struct TimeData(CurrentFrame,FrameCount,startFrame,endFrame)

				local range = GetSeuqenceRange()
				
				local CurrentFrame =  cTime_GetCurrTimeImgIndex()
				local FrameCount = (dFile_GetImageDatas()).count
				local startFrame = range.start.frame as integer
				local endFrame   = range.end.frame   as integer
				
				TimeData CurrentFrame:CurrentFrame FrameCount:FrameCount startFrame:startFrame endFrame:endFrame
			)
			
		)

		(---- DisplayCtrl ----

			fn cDisplay_UpdateGrid =
			(
				uifn_SetGridVisible (*s_Grid.Enabled)
				if ui_PlayerGridPictureBox.visible == false do return()

				local width  = ui_PlayerGridPictureBox.ClientSize.Width 
				local height = ui_PlayerGridPictureBox.ClientSize.Height
				local GridImg = fGrid_GenerateGridImage width height

				ui_PlayerGridPictureBox.image = GridImg
				ui_PlayerGridPictureBox.Refresh()
			)

			fn cDisplay_IsGridOn = *s_Grid.Enabled
			
			fn cDisplay_ToggleGridOn =
			(
				*s_Grid.Enabled = not *s_Grid.Enabled
				SettingCtrl.Save s_Grid
				cDisplay_UpdateGrid()
				
				if cDisplay_IsGridOn() 
				then uifn_SetTempPlayerDes PLAYER_GRID_ON  duration:700
				else uifn_SetTempPlayerDes PLAYER_GRID_OFF duration:700

				if GridSetting_Rollout.open do GridSetting_Rollout.Load()
				
			)
			
			fn cDisplay_IsAlwaysOnTop = ui_PlayerWindow.TopMost
			
			fn cDisplay_ToggleAlwaysOnTop = 
			(
				ui_PlayerWindow.TopMost = not ui_PlayerWindow.TopMost
				local Des = if ui_PlayerWindow.TopMost then PLAYER_ALWAYS_ON_TOP_ON else PLAYER_ALWAYS_ON_TOP_OFF
				
				uifn_SetTempPlayerDes Des duration:700
			)
			
			fn cDisplay_GetOpacity = ui_PlayerWindow.Opacity
			
			fn cDisplay_SetOpacity opacity = 
			(
				ui_PlayerWindow.Opacity = opacity
				local Des = PLAYER_OPACITY + ((opacity * 100) as integer) as string + "%"
				uifn_SetTempPlayerDes Des duration:700
			)
				
			fn cDisplay_ScaleToRatio ratio = 
			(
				uifn_ResizeToRatio ratio
				cDisplay_UpdateGrid()
			)
			
            fn GetRect = 
            (
                local x = ui_PlayerWindow.location.x
                local y = ui_PlayerWindow.location.y 
                local z = dDisplay_GetScaleRatio()
                
                point3  x y z
            )
            
            fn SetRect input_point3 =
            (
                if classof input_point3 == Point3 do
                (
                    ui_PlayerWindow.location = 
						dotnetobject "System.Drawing.Point" input_point3[1] input_point3[2]
                    
                    uifn_ResizeToRatio input_point3[3]
                )
            )
            
            fn GetTargetRect = 
            (
                local ViewSize = getviewsize() * ScaleFactor
                local ViewportPos = (mouse.screenpos - mouse.pos) * ScaleFactor
				local LoadRes = dFile_GetImageLoadRes()

                local ratio = LoadRes.x as float/LoadRes.y
                local viewRatio = ViewSize.x as float /ViewSize.y
                
                local x,y,width,height
                
                if ratio > viewRatio then 
                (
                    width  = viewSize.x
                    height = viewSize.x / ratio
                    
                    x = ViewportPos.x 
                    y = ViewportPos.y + (viewSize.y - height)/2
                )else
                (
                    width  = viewSize.y * ratio
                    height = viewSize.y
                    
                    x = ViewportPos.x + (viewSize.x - width)/2
                    y = ViewportPos.y 
                )
                
                ScaleRatio = width as float / LoadRes.x

                point3 x y ScaleRatio
            )

            local PosAndRatio_Before

			fn cDisplay_FillViewport =
			(
                fn SaveRectBefore = PosAndRatio_Before = GetRect()
                fn LoadRectBefore = SetRect PosAndRatio_Before

				TargetRect  = GetTargetRect()
				CurrentRect = GetRect()
				
				if distance TargetRect CurrentRect < 2 and abs(TargetRect.z - CurrentRect.z) < .01 then 
				(
					LoadRectBefore()
					uifn_SetTempPlayerDes PLAYER_FILL_VIEWPORT_OFF duration:700
				)
				else 
				(
					SaveRectBefore()
					SetRect TargetRect
					uifn_SetTempPlayerDes PLAYER_FILL_VIEWPORT_ON duration:700
				)

				cDisplay_UpdateGrid()
			)
		)

		(---- RecordCtrl ----
			fn cRec_StartRecord =
			(
				uifn_RecorderRecordMode()

				local pos = ui_RecordWindow.GetRecordPos() 
				local size = ui_RecordWindow.GetRecordRes()

				fRec_StartRecord pos size
			)

			fn cRec_StopRecord =
			(
				fRec_StopRecord()--Record = false , RecordAssit

				uifn_RecorderPreviewMode()
			)


			local PreviewPictureBox
			local PreviewTimer
			local PreviewPosition = 1
			local PreviewImages
			local PreviewingImage

			fn cRec_StartPreview =
			(
				PreviewImages = dRec_GetRecordFiles()
				if PreviewImages.count == 0 do return()

				util_DisableSceneRedraw()

				(/* Create PictureBox , SetPosAndSize */

					PreviewPictureBox = dotnetobject "PictureBox"
					ui_RecordWindow.Controls.Add PreviewPictureBox

					local borderWidth = 3
					local posX = borderWidth
					local posY = borderWidth + ui_RecordToolStrip.Height
					PreviewPictureBox.Location = dotnetobject "System.Drawing.Point" posX posY
					PreviewPictureBox.Size     = ui_RecordWindow.GetRecordRes()

                    ui_RecordWindow.MinimumSize = ui_RecordWindow.Size
                	ui_RecordWindow.MaximumSize = ui_RecordWindow.Size	
				)

				PreviewTimer = dotnetobject "Timer"
				PreviewTimer.interval = 18

				dotnet.addeventHandler PreviewTimer #Tick (fn _PreviewUpdate =
				(
					try(
						try(PreviewingImage.Dispose())catch()

						PreviewingImage = (dotnetclass "System.Drawing.Image").FromFile PreviewImages[PreviewPosition]
						PreviewPictureBox.image = PreviewingImage
						PreviewPictureBox.Refresh()
						
						PreviewPosition += 1
						if PreviewPosition > PreviewImages.count do PreviewPosition = 1
					)catch(
						MessageBox (getcurrentException())
						PreviewTimer.Stop()
					)
				))

				PreviewTimer.Start()

				 
			)

			fn cRec_StopPreview =
			(
				if PreviewImages.count == 0 do return()

				util_EnableSceneRedraw()

				PreviewPictureBox.Dispose()
				PreviewTimer.Stop()
				PreviewTimer.Dispose()
				PreviewPosition = 1

				try(PreviewingImage.Dispose())catch()

				uifn_RecorderIdleMode()
                uifn_SetRecorderMinMaxSize()

			)

		)

		/* Debug */Debug_LogTime "Controls"

	)

	(------ UI Events ↓ -----
		
		(---- Player MouseEvents ----
            local ResizeEvents
            
            struct sResizeEvents
            (
                winForm,--ctor
                
                OpenRCMenu = true,
                
                -------SETTING----------
                
                ScaleAndTimeOffsetTolerance = 10,
                ScaleAndTimeOffsetDragStart = false,
                
                ImgOriginalRes  = [1280,720],
                ScaleRatio   = 1.0,
                
                CanZoom        = true,
                Dragging       = false,
                Mouse_StartPos = [0,0],
                Form_StartPos  = [0,0],
                ScaleRatio_Start = 1,
                Mode = #Pos,

				fn GetMousePos = 
				(
					if ScaleFactor == 1 then mouse.pos
					else 
					(
						local pos = (dotnetclass "Cursor").Position
						[pos.x,pos.y]
					)
				),

				fn UpdateImgInfo =
				(
					if m_PlayerMode == MODE_PLAYER_NORMAL do
					(
						this.ImgOriginalRes = dFile_GetImageLoadRes()
						this.ScaleRatio = ui_PlayerWindow.width as float / ImgOriginalRes.x
					)
						
				),
                
                fn DragStart sender eventArgs =
                (
					UpdateImgInfo()

                    Mode = case eventArgs.Button.ToString() of
					(
						"Left" :#Pos
						"Middle":#Scale
					)
                    
                    Mouse_StartPos = GetMousePos()
                    Form_StartPos  = winForm.location
                    ScaleRatio_Start = scaleRatio
                    
                    Dragging = true
                ),

                fn DragUpdatePos =
                (
                    if Dragging do
                    (
						local MousePos = GetMousePos()
                        MouseOffSet_X = (MousePos.x - Mouse_StartPos.x) 
                        MouseOffSet_Y = (MousePos.y - Mouse_StartPos.y) 
                        
                        if Mode == #Pos do
                        (
                            winForm.location.x = Form_StartPos.x + MouseOffSet_X
                            winForm.location.y = Form_StartPos.y + MouseOffSet_Y
                        )
                        
                        if not m_PlayerMode == MODE_PLAYER_NORMAL do return()
                        
                        if ScaleAndTimeOffsetDragStart or abs MouseOffSet_X > ScaleAndTimeOffsetTolerance/2 do
                        (
                            OpenRCMenu = false
                            ScaleAndTimeOffsetDragStart = true
                            
                            if Mode == #Scale do
                            (
                                local ScaleRatio = ScaleRatio_Start + MouseOffSet_X/800.0
                                TargetRes  = ImgOriginalRes * ScaleRatio
                            
                                local width  = TargetRes.x + 0.5
                                local height = TargetRes.y + 0.5
                                
                                if width < RPMinPlayerReslotion.x or height < RPMinPlayerReslotion.y do return()
                                
                                this.ScaleRatio = ScaleRatio
                                
                                winForm.Size = dotnetobject "System.Drawing.Size" width height
                                
                                winForm.Refresh()
                            )
                            
                        )
                    )
                ),

				fn ShowRes = 
				(
					Des = ((ScaleRatio * 100) as integer) as string + "%"
					if ScaleRatio > 1 
						then uifn_SetTempPlayerDes Des color:(RGBColor 255 240 120) duration:700
						else uifn_SetTempPlayerDes Des 
				),
                
                fn DragEnd = 
                (
                    Dragging = false
                    
                    if m_PlayerMode != MODE_PLAYER_NORMAL do return()
                    if OpenRCMenu == true do return()
                    
                    OpenRCMenu = true
                    ScaleAndTimeOffsetDragStart = false
                    
                    if Mode == #Scale do 
                    (
						ShowRes()
						cDisplay_UpdateGrid()
                    )
                    
                    if Mode == #Time do
                    (
                        uifn_HidePlayerDes()
                    )
                    
                ),
                
                fn Resize Multiplier =
                (
                    UpdateImgInfo()

                    if m_PlayerMode != MODE_PLAYER_NORMAL do return()

                    local ScaleRatio =  this.ScaleRatio * Multiplier

                    if ScaleRatio >= 0.98 and ScaleRatio <= 1.02 then ScaleRatio = 1.0
                    else if ScaleRatio >= 0.49 and ScaleRatio <= 0.51 then ScaleRatio = 0.5
                    else if ScaleRatio >= 1.96 and ScaleRatio <= 2.04 then ScaleRatio = 2.0
                        
                    local TargetRes  = ImgOriginalRes * ScaleRatio
                    local width  = TargetRes.x
                    local height = TargetRes.y
                    
					local ScaleRatioChanged = false
                    if width < RPMinPlayerReslotion.x do
					(
						ScaleRatioChanged = true
						height = (RPMinPlayerReslotion.x / width) * height
						width  = RPMinPlayerReslotion.x
					)
					if height < RPMinPlayerReslotion.y do
					(
						ScaleRatioChanged = true
						width  = (RPMinPlayerReslotion.y / height) * width
						height = RPMinPlayerReslotion.y
					)

					if ScaleRatioChanged do
						ScaleRatio = (width + height) / (ImgOriginalRes.x + ImgOriginalRes.y)

					width += 0.5;height += 0.5
                    this.ScaleRatio = ScaleRatio
                    
                    winForm.Size = dotnetobject "System.Drawing.Size" width height
                    
					ShowRes()
                ),
                
                fn ResizeToRatio ratio =
                (
                    UpdateImgInfo()

                    Resize (ratio/ScaleRatio)
                ),


				fn ResizeUp   = if MouseInForm() do Resize 1.04,
				fn ResizeDown = if MouseInForm() do Resize 0.96
                
            )

            ResizeEvents = sResizeEvents winform:ui_PlayerWindow
			fn dDisplay_SetLoadRes val = ResizeEvents.ImgOriginalRes = val
			fn dDisplay_SetScaleRatio val = ResizeEvents.ScaleRatio = val
            fn dDisplay_GetScaleRatio     = ResizeEvents.ScaleRatio
            fn uifn_ResizeToRatio ratio = ResizeEvents.ResizeToRatio ratio
            fn uifn_EnablePlayerZoom  = ResizeEvents.CanZoom = true
            fn uifn_DisablePlayerZoom = ResizeEvents.CanZoom = false
			
			fn dUI_IsDragging = ResizeEvents.Dragging

			---------------------------------------
			/*        ADDEVENT HANDLERS         */
			---------------------------------------
            winform = ui_PlayerWindow
            
            dotnet.addEventHandler winForm #MouseDown  (fn _PlayerMouseDown sender eventArgs = ResizeEvents.DragStart sender eventArgs)
            dotnet.addEventHandler winForm #MouseMove  (fn _PlayerMouseMove = ResizeEvents.DragUpdatePos())
            dotnet.addEventHandler winForm #MouseUp    (fn _PlayerMouseUp   = ResizeEvents.DragEnd())
            
            dotnet.addEventHandler winForm #MouseWheel (fn _PlayerMouseWheel sender eventArgs =
                (
                    if EventArgs.Delta > 0 
                        then ResizeEvents.ResizeUp() 
                        else ResizeEvents.ResizeDown()
					
					cDisplay_UpdateGrid()
                ))

            dotnet.addEventHandler winForm #MouseDoubleClick (fn _PlayerMouseDoubleClick sender EventArgs = 
                RP_Quit() )
            
            dotnet.addEventHandler winForm #MouseClick (fn _PlayerMouseClick sender EventArgs = 
                (
                    if not m_PlayerMode == MODE_PLAYER_NORMAL do return()
                    if not ResizeEvents.OpenRCMenu do return()
                    
                    if isAnimPlaying() do StopAnimation()
                    
                    if EventArgs.Button.ToString() == "Right" do 
                    popUpMenu rcMenu_Time align:#align_topleft
                    
                    if EventArgs.Button.ToString() == "Middle" do
                    popUpMenu rcMenu_Display align:#align_topleft 
                )
            )
            
            ----DRAGDROP FILE---------
            
            local DataFormats = dotnetclass "System.Windows.DataFormats"
            
            fn GetFileFolderPath dir = 
            (
                local IsFolder  = getFilenameType dir == ""
                local folderPath = if IsFolder then dir else getFileNamePath dir
                
                if folderPath[folderPath.count] ==  @"\" do
                folderPath = substring folderPath 1 (folderPath.count - 1)
				
				folderPath
            )


			fn AllowFileDrop file =
			(
				local AllowFileDrop = false
				local fileType = getFilenameType file
				local folderPath = GetFileFolderPath file 
				
				if fileType == ".jpg" or fileType == ".png" then AllowFileDrop = true
				else if fileType == "" then
				(
					local imgFiles = GetFiles (folderPath + "\\*.jpg")
					imgfiles += GetFiles (folderPath + "\\*.png")

					if imgfiles.count != 0 do AllowFileDrop = true
				)

				bool_Result 
			)
            
            dotnet.addEventHandler winForm #DragEnter (fn _PlayerDragEnter sender EventArgs = 
                (
                    local file = (EventArgs.Data.GetData(DataFormats.FileDrop))[1]
					local folderPath = GetFileFolderPath file 
					local fileType = getFilenameType file

					(/* if file is image or folder of image, allow file drop */
						local AllowFileDrop = false
						if fileType == ".jpg" or fileType == ".png" then AllowFileDrop = true
						else if fileType == "" then
						(
							local imgFiles = GetFiles (folderPath + "\\*.jpg")
							imgfiles += GetFiles (folderPath + "\\*.png")

							if imgfiles.count != 0 do AllowFileDrop = true
						)
					)

					if AllowFileDrop then 
					(
						EventArgs.Effect = EventArgs.Effect.Copy
						uifn_SetPlayerDes (PLAYER_FILE_OPEN /*打开:*/ + folderPath)
					)else 
					(
						EventArgs.Effect = EventArgs.Effect.None
					)
                
                )
            )
            
            
            dotnet.addEventHandler winForm #DragDrop (fn _PlayerDragDrop  sender EventArgs = 
                (
                    local file = (EventArgs.Data.GetData(DataFormats.FileDrop))[1]
                    local folderPath = GetFileFolderPath file
                    
                    if RP_OpenFile folderPath do
					(
						dTime_SetStartTime 0
						cDisplay_ScaleToRatio 1
						fFile_SavePlayList()
					)

					uifn_HidePlayerDes()
                )
            )
            
            
            dotnet.addEventHandler winForm #DragLeave (fn _PlayerDragLeave sender EventArgs =
                uifn_HidePlayerDes() )


            dotnet.addeventhandler winForm #FormClosed (fn _PlayerClose sender EventArgs =
                    RP_Quit())
        
			

		)

		(---- Player ToolStrip AutoHide ----
            local PlayerTSAutoHide

			struct sPlayerTSAutoHide
            (
                winform,toolStrip,--ctor
                
                TimeFromEnterToShow = RPToolStripShowDelay,
                TimeFromLeaveToHide = RPToolStripHideDelay,

                TimeIn  = 0,
                TimeOut = 0,

                Enabled = true,

                fn MouseCloseToToolStip =
                (
                    CursorPos = ui_PlayerPictureBox.PointToClient (DotnetClass "Cursor").Position
                    
                    FormRect = ui_PlayerPictureBox.ClientRectangle
                    CloseRect = dotnetobject "System.Drawing.Rectangle" FormRect.x FormRect.y (FormRect.width/4) FormRect.height
                    
                    bool_result = CloseRect.Contains CursorPos
                ),

				firstShow = true,

				fn InitToolStrip = 
				(
					local PlayerToolStripWidth = ui_PlayerToolStrip.Width 
					ui_PlayerToolStrip.AutoSize = false
					ui_PlayerToolStrip.Width   = PlayerToolStripWidth

					this.firstShow = false
				),

				toolStripShowen = false,

                TimerEvent,
	
                fn ShowToolStrip =
                (
                    if this.Enabled do
                    (
						TimerIn = 0;TimeOut = 0
						if not toolStripShowen do uifn_ShowToolStrip()

                        if firstShow do InitToolStrip()
                        toolStripShowen = true
                    )
                ),
                
                fn HideToolStrip =
                (
                    
                    if this.Enabled do
                    (
                        TimerIn = 0;TimeOut = 0

                        if toolStripShowen and not m_PlayerMode == MODE_PLAYER_MINIMIZED do 
                        (
                            uifn_HideToolStrip()
							toolStripShowen = false
                        )

                        if not MouseInForm() do 
                        (
                            TimerEvent.Enabled = false
                        )
                    )
                ),

                fn TickEvent =
                (
                    if MouseCloseToToolStip() 
                    then (TimeIn  += util_TimerInterval;TimeOut = 0)
                    else (TimeOut += util_TimerInterval;TimeIn  = 0)
                    
                    if TimeIn  > TimeFromEnterToShow do ShowToolStrip()
                    if TimeOut > TimeFromLeaveToHide do HideToolStrip()
                    
                    --format "TimeIn:% TimeOut:%\n" TimeIn TimeOut                    
                ),

                fn Init =
                (
					/* This does not work in Max 2019,move them outside would work,why ?
						dotnet.addeventHandler winform    #MouseEnter    (fn _PlayerMouseEnter =
						(
							PlayerTSAutoHide.TimerEvent.Enabled = true
							util_StartTimer()
						))
						dotnet.addeventHandler toolStrip   #MouseEnter   (fn _PlayerTSMouseEnter = 
						(
							PlayerTSAutoHide.TimerEvent.Enabled = true
							util_StartTimer()
						))
					*/

                    dotnet.addeventHandler winform #Closed util_StopTimer

                    this.TimerEvent = util_RegisterTimerEvent  (fn _PlayerTSTimerTick  = PlayerTSAutoHide.TickEvent())
                    
                    if MouseInForm() do util_StopTimer()
                )
            )


			fn init_RegisterTSAutoHide =
			(
                PlayerTSAutoHide = sPlayerTSAutoHide winform:ui_PlayerWindow toolStrip:ui_PlayerToolStrip
				PlayerTSAutoHide.init()

				dotnet.addeventHandler ui_PlayerWindow    #MouseEnter    (fn _PlayerMouseEnter =
				(
					PlayerTSAutoHide.TimerEvent.Enabled = true
					util_StartTimer()
				))
				
				dotnet.addeventHandler ui_PlayerWindow #Closed util_StopTimer
			)

            fn uifn_EnableTSAutoHide  = PlayerTSAutoHide.Enabled = true
            fn uifn_DisableTSAutoHide = PlayerTSAutoHide.Enabled = false
		)

		(---- Player Minimize ----
            local PlayerMinimize

			struct sPlayerMinimize
            (
                --ctor 
                Form,PictureBox,

                TimerEvent,
                maxWidth,
                maxHeight,
                minWidth  = 40,
                minHeight = 52, 
                ScaleSpeed = 0.3,
                MaxTickCount = 15,
                
                AnimPlaying  = false,
                Minimize = false,
                TickCount = 0,
                
                PBClientSize,

                fn StartAnim =
                (
                    if Minimize then
                    (
                        PBClientSize = PictureBox.ClientSize
                        
                        PictureBox.Dock = PictureBox.Dock.None
                        PictureBox.ClientSize = PBClientSize
                    )
                    else 
                    (
                        m_PlayerMode = MODE_PLAYER_NORMAL
                        RP_Update()
                    )
                    
                    if not AnimPlaying do util_DisableSceneRedraw()
                    
                    AnimPlaying = true
                    TickCount = 0

                    TimerEvent.Enabled = true
                    util_StartTimer()
                ),
                
                fn StopAnim =
                (
                    util_EnableSceneRedraw()
                    
                    TimerEvent.Enabled = false
                    AnimPlaying = false

                    if Minimize then
                    (
                        m_PlayerMode = MODE_PLAYER_MINIMIZED

                    )else
                    (
                        PictureBox.Dock = PictureBox.Dock.Fill
                    )
                ),
                
                fn ResizeForm =
                (
                    TickCount += 1
                    
                    targetWidth  = if Minimize then minWidth  else maxWidth
                    targetHeight = if Minimize then minHeight else maxHeight
                    
                    if TickCount >= MaxTickCount do
                    (
                        Form.width  = targetWidth
                        Form.height = targetHeight
                        
                        StopAnim();return()
                    )
                    
                    Form.width  += (targetWidth  - Form.Width)*ScaleSpeed
                    Form.Height += (targetHeight - Form.Height)*ScaleSpeed
                    
                ),

				fn Toggle_NoAnim =
				(
					Minimize = not Minimize

					if Minimize == true  do 
					(
						uifn_CaculateMinimizeSize &minWidth &minHeight 
						maxHeight = winForm.Height
                        maxWidth  = winForm.Width

						PBClientSize = PictureBox.ClientSize
                        PictureBox.Dock = PictureBox.Dock.None
                        PictureBox.ClientSize = PBClientSize

						winForm.Height = minHeight
						winForm.Width  = minWidth 
						m_PlayerMode = MODE_PLAYER_MINIMIZED
					)

					if Minimize == false  do 
					(
						m_PlayerMode = MODE_PLAYER_NORMAL
						PictureBox.Dock = PictureBox.Dock.Fill

						winForm.Height = maxHeight
						winForm.Width  = maxWidth 
						RP_Update()
					)
				),

                fn Toggle = 
                (
                    Minimize = not Minimize

					if not AnimPlaying do
					(
						if Minimize do
						(
							uifn_CaculateMinimizeSize &minWidth &minHeight 
							
							maxHeight = winForm.Height
							maxWidth  = winForm.Width
						)
					)
					
                    StartAnim()
                ),

                fn Init =
                (
                    maxHeight = ui_PlayerWindow.Height
                    maxWidth  = ui_PlayerWindow.Width

                   this.TimerEvent = util_RegisterTimerEvent (fn _MinimizeTimerTick = 
                    (
                        PlayerMinimize.ResizeForm()
                    ))
                )
            )

			fn init_RegisterMinimize = 
            (
                PlayerMinimize = sPlayerMinimize Form:ui_PlayerWindow PictureBox:ui_PlayerPictureBox
                PlayerMinimize.Init()
            )
 			fn uifn_MinimizePlayer = (
				if RPMinimizeAnimation 
					then PlayerMinimize.Toggle()
					else PlayerMinimize.Toggle_NoAnim()
			 )
			fn uifn_PlayerIsMinimize = 
			(
				if PlayerMinimize == undefined 
					then false 
					else PlayerMinimize.Minimize
			)
			fn uifn_MinimizeAnimPlaying = 
			(
				if PlayerMinimize == undefined 
					then false
					else PlayerMinimize.AnimPlaying
			)
		)

		(---- PlayerRecorder Switch ----
			--need PlayerForm RecorderForm

            local PlayerRecorderSwitch

            struct sPlayerRecorderSwitch
            (
                PlayerWindow,RecordWindow, --ctor

                TimerEvent,
                AnimSpeed    = 0.15,
                MaxTickCount = 40,
                
                TickCount = 0,
                PlayerOpacity,
                PlayerTargetOp,
                RecordTargetOp,
                
                fn SetRecordRect =
                (
					RecordWindow.SuspendLayout()

                    RecordWindow.SetRecordRes playerWindow.size
					RecordWindow.SetRecordPos playerWindow.location
					RecordWindow.Show()

					RecordWindow.ResumeLayout true 
                ),
                
                fn SetPlayerRect =
                (
					PlayerWindow.SuspendLayout()
                    playerWindow.Location = RecordWindow.GetRecordPos()
					PlayerWindow.ResumeLayout true
                ),

                fn StartAnim =
                (
                    TickCount = 0
                    PlayerWindow.Show()
                    RecordWindow.Show()
                    
                    TimerEvent.Enabled = true
                    util_StartTimer()
                ),
                
                fn AnimateOpacity =
                (
                    if TickCount <= MaxTickCount/4
                    then RecordWindow.Opacity += (RecordTargetOp - RecordWindow.Opacity)*AnimSpeed
                    else 
                    (
                        RecordWindow.Opacity += (RecordTargetOp - RecordWindow.Opacity)*AnimSpeed
                        PlayerWindow.Opacity += (PlayerTargetOp - PlayerWindow.Opacity)*AnimSpeed
                    )
                    
                    TickCount += 1
                    
                    if TickCount >= MaxTickCount do
                    (
                        PlayerWindow.Opacity = PlayerTargetOp
                        RecordWindow.Opacity = RecordTargetOp
                        
                        if PlayerTargetOp == 0 do PlayerWindow.Hide()
                        if RecordTargetOp == 0 do RecordWindow.Hide()
                        
                        TimerEvent.Enabled = false
                    )
                ),
                
                fn Init = 
                (
                    TimerEvent = util_RegisterTimerEvent  (fn _AnimateOpacity =
                    (
                        PlayerRecorderSwitch.AnimateOpacity()
                    ))

                ),

                function PlayerToRecorder =
                (
                    PlayerOpacity = PlayerWindow.Opacity
                    
                    PlayerTargetOp = 0
                    RecordTargetOp = 1
                    
                    SetRecordRect()
                    StartAnim()
                    
                ),

                function RecorderToPlayer =
                (
                    PlayerTargetOp = PlayerOpacity
                    RecordTargetOp = 0
                    
                    SetPlayerRect()
                    StartAnim()

					RP_Update()
                )

            )

            PlayerRecorderSwitch = sPlayerRecorderSwitch PlayerWindow:ui_PlayerWindow RecordWindow:ui_RecordWindow


            fn init_RegisterSwitchUI = PlayerRecorderSwitch.init()

            fn uifn_PlayerToRecorder = PlayerRecorderSwitch.PlayerToRecorder()
            fn uifn_RecorderToPlayer = PlayerRecorderSwitch.RecorderToPlayer()

		)

		(---- Set Description -----

            (---- Player ----
				local PlayerDesLabel
				local PlayerDesTimer = dotnetobject "Timer"
				
				fn CreatePlayerDesLabel =
				(
                    local NewLabel = dotnetobject "Label"
                    local AnchorStyles = dotNetClass "AnchorStyles"

					local font = "Microsoft YaHei"
					local fontSize = 10


					NewLabel.Anchor = dotnet.combineEnums AnchorStyles.Right AnchorStyles.Bottom
					NewLabel.Font   = dotnetobject "system.drawing.font" (dotnetobject "system.drawing.fontfamily" font) fontSize
					NewLabel.TextAlign = (dotnetClass "System.Drawing.ContentAlignment").MiddleCenter

                    NewLabel.AutoSize = true
                    NewLabel.visible = false
					NewLabel.Enabled  = false

                    ui_PlayerWindow.controls.add NewLabel
                    NewLabel.BringToFront()

                    PlayerDesLabel = NewLabel
				)
				
				CreatePlayerDesLabel()
				
				fn uifn_SetPlayerDes s =
				(
					PlayerDesLabel.Enabled  = true
					PlayerDesLabel.visible = true
					PlayerDesLabel.Text = s
					
					(/* SetPos */
						local border_x = 10
						local border_y = 10
						local Pos_x = ui_PlayerWindow.width - PlayerDesLabel.width  - border_x
						local Pos_y = ui_PlayerWindow.height- PlayerDesLabel.height - border_y
						PlayerDesLabel.location = dotnetobject "System.Drawing.Point" Pos_x Pos_y
					)

                    PlayerDesLabel.BringToFront()
				)
				
				fn uifn_HidePlayerDes =
				(
					PlayerDesLabel.visible = false
					PlayerDesLabel.Enabled  = false
					PlayerDesLabel.Text = ""
				)


				fn uifn_SetTempPlayerDes s color:DNColor.White duration:500 =
				(
					PlayerDesTimer.Stop()
					
					uifn_SetPlayerDes s
					PlayerDesLabel.ForeColor = color
					PlayerDesLabel.Refresh()
					
					PlayerDesTimer.Interval = Duration
					PlayerDesTimer.Start()

				)

				dotnet.addeventhandler PlayerDesTimer #Tick (fn _PlayerDesTimerTick = 
                (
					uifn_HidePlayerDes()
					PlayerDesTimer.Stop()
                ))
            )
				
			(---- Recorder ----

				fn uifn_SetRecorderDes s =
				(
					ui_RecordWindow.ResLabel.text = s
				)

				fn uifn_ResumeRecorderDes =
				(
					ui_RecordWindow.SetResText()
				)

		    )

	    )

		/* Debug */Debug_LogTime "UI Events"
    )

	(------ Extra UI Elements ↓ ------

		(---- Setting Rollout ----
			local GetRolloutHeight
			local SetRolloutHeight

			rollout RecordSetting_Rollout SETTING_REC_TITLE category:1 --录制设置
			(
				label SavePathLabel SETTING_REC_OUTPUT_FOLDER \ --输出文件夹
				 align:#left across:2
				button OpenSavePath SETTING_REC_OPEN \ --打开
				 width:30 height:17 offset:[-90,-1]

				edittext SavePath   across:2 width:215 offset:[-5,2]
				button SetNewPath "..." offset:[55,0]

				label RecordMouseLabel SETTING_REC_RECORDMOUSE \ --录制鼠标
				across:2 align:#left offset:[0,5]
				checkbox RecordMouse SETTING_REC_RECORDMOUSE_ON \ --开启
				align:#left offset:[-50,5] checked:false
				
				--label RecordFinishLabel "录制结束后:" align:#left offset:[0,8]
				-- radiobuttons OnRecordFinish align:#left labels:#("什么也不做","播放录制") --columns:1
				
				label AssistanceTypeLabel SETTING_REC_ASSIST \ --录制辅助:
				align:#left offset:[0,8]
				radiobuttons AssistanceMode align:#left labels:#(
					SETTING_REC_ASSIST_NONE,    --无
					SETTING_REC_ASSIST_SPACEKEY,--空格键
					SETTING_REC_ASSIST_MEDIAKEY --媒体播放键
				)--columns:1
				label DescriptionLabel "" align:#left width:240 height:35	
				
				
				----------------------Save&Load-------------------------------------
				
				fn Save =
				(
					*s_Recorder.RecordSavePath = SavePath.text
					*s_Recorder.AssistanceMode = AssistanceMode.state
					*s_Recorder.RecordMouse    = RecordMouse.checked 
					
					SettingCtrl.Save s_Recorder
				)
				
				fn Load =
				(
					SavePath.text = *s_Recorder.RecordSavePath 
					AssistanceMode.state = *s_Recorder.AssistanceMode
					RecordMouse.checked  = *s_Recorder.RecordMouse
				)
				--------------------------------------------------------------------
				
				fn UpdateDescriptionLabel =
				(
					case AssistanceMode.state of
					(
						(1):DescriptionLabel.text =  ""
						(2):DescriptionLabel.text = SETTING_REC_ASSIST_SPACEKEY_DESCRIPTION
						(3):DescriptionLabel.text = SETTING_REC_ASSIST_MEDIAKEY_DESCRIPTION
					)
				)
				
				on SavePath entered txt do
				(
					if doesFileExist txt do Save()
				)
				
				on OpenSavePath pressed do 
				(
					ShellLaunch SaveDir ""
				)
				
				on SetNewPath pressed do
				(
					newFolder = getSavePath initialDir:"C:\\"
					
					if newFolder!= undefined do
					(
						SavePath.Text = newFolder
						Save()
					)
				)

				on RecordMouse changed arg do Save()
				
				on AssistanceMode changed  arg do 
				(
					UpdateDescriptionLabel()
					Save()
				)
				
				on RecordSetting_Rollout open do
				(
					Load()
					UpdateDescriptionLabel()
				)

				on RecordSetting_Rollout rolledUp state do SetRolloutHeight()
				
			)
            
			rollout PlayerSetting_Rollout SETTING_PLAYER_TITLE category:2 --播放设置
			(
				group "Max Ram" --最高内存占用:
				(
					radiobuttons RAMMode  labels:#(
						SETTING_PLAYER_RAM_DYNAMIC,--动态
						SETTING_PLAYER_RAM_STATIC  --固定
					) offset:[-55,0] --columns:1
					
					spinner MaxRAMPercentage SETTING_PLAYER_RAM_MAXPERCENTAGE \ --剩余内存的百分之
					range:[30,100,50] enabled:false  fieldwidth:60  offset:[-30,0]

					spinner MaxRAM  SETTING_PLAYER_RAM_MAXRAM \ --最大内存占用(MB)
					range:[200,99999,1000] scale:10 enabled:false fieldwidth:60 offset:[-30,0] 
				)
				--label des "(读取新文件生效)"
				
				group "Opacity:" --不透明度:
				(
					slider Opacity  range:[20,100,100] 
				)
				
				fn Load =
				(
					RAMMode.state          = *s_RAM.MaxRAM_Mode
					MaxRAMPercentage.value = *s_RAM.MaxRAM_Percentage * 100 
					MaxRAM.value           = *s_RAM.MaxRAM_Usage
				)
					
				fn Save =
				(
					*s_RAM.MaxRAM_Mode        = RAMMode.state
					*s_RAM.MaxRAM_Percentage = MaxRAMPercentage.value / 100.0
					*s_RAM.MaxRAM_Usage      = MaxRAM.value
					
					SettingCtrl.Save s_RAM
				)
				
				fn UpdateUI =
				(
					case RAMMode.state of
					(
						1:(MaxRAMPercentage.enabled = true;MaxRAM.enabled = false)
						2:(MaxRAMPercentage.enabled = false;MaxRAM.enabled = true)
					)
				)
				
				on RAMMode changed arg do 
				(
					Save();UpdateUI()
				)
				
				on MaxRAM buttonup inCancel do 
					if not inCancel do Save()
				
				on MaxRAM entered val inCancel do
					if not inCancel do Save()
				
				on MaxRAMPercentage buttonup inCancel do  
					if not inCancel do Save()
				
				on MaxRAMPercentage entered val inCancel do
					if not inCancel do Save()

				on Opacity changed val do cDisplay_SetOpacity (val/100)
				

				on PlayerSetting_Rollout open do
				(
					local GroupCtrls = for ctrl in PlayerSetting_Rollout.controls where classof ctrl == GroupStartControl collect ctrl
					GroupCtrls[1].Text = SETTING_PLAYER_RAM_GROUP
					GroupCtrls[2].Text = SETTING_PLAYER_OPACITY_GROUP

					Opacity.value = cDisplay_GetOpacity() * 100
					
					Load();UpdateUI()
				)
				
				on PlayerSetting_Rollout close do
				(
					Save()
				)

				on PlayerSetting_Rollout rolledUp state do SetRolloutHeight()

				
			)

			rollout TimeSetting_Rollout SETTING_TIME_TITLE category:3 --时间设置
			(
				group "Time Status:" --状态:
				(
					label ofAllFrame "/   100"  across:2
					label endFrame "" --type:#integer   range:[-99999,99999,0] scale:1 
				)
				
				button SyncTimeRange SYNC_MAX_TIMERANGE \ --同步时间轴
				width:140 height:25 align:#right offset:[0,10] 
				button SetStartKey1  SYNC_SET_CURRENT_FRAME_AS_START_TIME \ --将首张图像同步到此帧
				width:140 height:25 align:#right
				button SetStartKey2  SYNC_SET_CURRENT_IMG_AS_ZERO_FRAME \  --将当前图像同步到0帧
				width:140 height:25 align:#right
				
				spinner currFrameSp  SETTING_TIME_CURRENT_FRAME \ --当前帧:
				type:#integer range:[-99999,99999,0] scale:1 fieldwidth:40 pos:[10,80]
				spinner startFrameSp SETTING_TIME_START_FRAME \  --起始帧:
				type:#integer range:[-99999,99999,0] scale:1 fieldwidth:40 pos:[10,110]
				
				groupbox syncGroup       SETTING_TIME_SYNC_GROUP \ --同步:
				pos:[5,50] width:255 height:100
				
				
				fn ToString inputfloat =
				(
					(inputfloat as integer) as string
				)
				
				--local lastUpdateTime = (currentTime.frame as integer)
				
				fn UpdateUI =
				(
					local d = dTime_GetTimeDatas() --CurrentFrame FrameCount startFrame endFrame
					
					currFrameSp.range = [1,d.FrameCount,d.CurrentFrame]
                    startFrameSp.value = d.startFrame

					ofAllFrame.text = SETTING_TIME_CURRENT_FRAME + " " + (ToString d.CurrentFrame) + "/" +  (ToString d.FrameCount)
					endFrame.text   = SETTING_TIME_STATUS_START  + (ToString d.startFrame) + SETTING_TIME_STATUS_END + (ToString d.endFrame)
				)
				
				on currFrameSp changed val do
				(
					if val < currFrameSp.range[1] or val > currFrameSp.range[2] do return()
					
					local Offset = val - cTime_GetCurrTimeImgIndex()
                    dTime_SetStartTime (dTime_GetStartTime() - Offset)
                    
                    RP_Update();UpdateUI()
				)
				
				on startFrameSp changed val do
				(
                    local timeData = dTime_GetTimeDatas()
                    local Offset = val - timeData.startFrame

                    dTime_SetStartTime (dTime_GetStartTime() + Offset)
                    
                    RP_Update();UpdateUI()
				)
				
				on SyncTimeRange pressed do
				(
                    cTime_SyncMaxTimeRange()
				)
				
				on SetStartKey1 pressed do 
				(
                    cTime_SetCurrFrameAsStartTime()

					UpdateUI()
				)
				on SetStartKey2 pressed do 
				(
					cTime_SetCurrImgAsFirstFrame()
					
					UpdateUI()
				)

				on TimeSetting_Rollout open do
				(
					local GroupCtrls = for ctrl in TimeSetting_Rollout.controls where classof ctrl == GroupStartControl collect ctrl
					GroupCtrls[1].Text = SETTING_TIME_STATUS_GROUP

					UpdateUI()
					registerTimeCallback UpdateUI
				)
				
				on TimeSetting_Rollout close do
				(
					unregisterTimeCallback UpdateUI
				)

				on TimeSetting_Rollout rolledUp state do SetRolloutHeight()
				
				--spinner FPS "播放FPS" range:[15,60,30] type:#integer offset:[0,20]
			)
			
			rollout GridSetting_Rollout SETTING_GRID_TITILE category:4  --参考线设置
			(
				
				checkbox GridEnabled SETTING_GRID_ENABLE -- 开启参考线
				
				spinner GridOpacity  SETTING_GRID_OPACITY \ -- 不透明度:
				range:[0,1,0.5] scale:0.01 align:#left offset:[0,10]  across:2 
				
				spinner HorizontalCount SETTING_GRID_HORIZONTAL \ --横:
				type:#integer  range:[1,20,4] align:#right offset:[-10,10]
				
				colorpicker GridColor SETTING_GRID_COLOR \ --颜色:
				color:white align:#left across:2
				
				spinner VerticalCount  SETTING_GRID_VERTICAL \ --竖:
				 type:#integer  range:[1,20,3] align:#right offset:[-10,0]
		
				groupbox gb SETTING_GRID_COUNT_GROUP \ --格子数量:
				pos:[150,10] width:110 height:80
				
				--spinner LineWidth    "线宽(px):" type:#integer range:[1,10,2] 
				
				fn Update =
				(
					*s_Grid.Enabled   = GridEnabled.checked
					*s_Grid.HorizontalCount = HorizontalCount.value
					*s_Grid.VerticalCount   = VerticalCount.value
					*s_Grid.Opacity     = GridOpacity.value
					--*s_Grid.LineWidth       = LineWidth.value
					*s_Grid.Color       = GridColor.color

                    cDisplay_UpdateGrid()
				)


                fn Load = 
                (
                    try(
                        GridEnabled.checked   = *s_Grid.Enabled
                        HorizontalCount.value = *s_Grid.HorizontalCount
                        VerticalCount.value   = *s_Grid.VerticalCount
                        GridOpacity.value     = *s_Grid.Opacity
                        --LineWidth.value       = *s_Grid.LineWidth
                        GridColor.color       = *s_Grid.Color 
                    )catch()

                )
				
				on GridEnabled     changed val do Update()
				on HorizontalCount changed val do Update()
				on VerticalCount   changed val do Update()
				on GridOpacity     changed val do Update()
				--on LineWidth       changed val do Update()
				on GridColor       changed val do Update()
				
				on GridSetting_Rollout open do Load()
				on GridSetting_Rollout close do (SettingCtrl.Save s_Grid)
				on GridSetting_Rollout rolledUp state do SetRolloutHeight()

			)

			rollout About_Rollout "About" category:5 --About
			(
				label l1 ABOUT_AUTHOR    -- By: 永泽
                label l2 ABOUT_COPYRIGHT -- CopyRight: 长春伯仲
				label l3 ABOUT_BUSINESS_1 offset:[0,5] --"本插件仅供学习交流使用"
				label l4 ABOUT_BUSINESS_2 --"如需商业授权及合作 联系QQ:138988114"
                --label l3 "免责声明:免责免责免责免责免责"

				on About_Rollout rolledUp state do SetRolloutHeight()
			)


            rollout RefPlayerSettingRollout SETTING_TITILE --设置
            (
                subRollout sub width:280 height:300
            )


			fn GetRolloutHeight_All =
			(
				local height = 140 * ScaleFactor

				if RecordSetting_Rollout.open do height += RecordSetting_Rollout.height
				if PlayerSetting_Rollout.open do height += PlayerSetting_Rollout.height
				if TimeSetting_Rollout.open   do height += TimeSetting_Rollout.height
				if GridSetting_Rollout.open   do height += GridSetting_Rollout.height
				if About_Rollout.open         do height += About_Rollout.height

				height 
			)

			fn GetRolloutHeight_Record =
			(
				local height = 80 * ScaleFactor

				if RecordSetting_Rollout.open do height += RecordSetting_Rollout.height
				if About_Rollout.open         do height += About_Rollout.height

				height 
			)

			fn SetRolloutHeight =
			(
				local height = GetRolloutHeight() / ScaleFactor 

				RefPlayerSettingRollout.sub.height = height - (20 * ScaleFactor)
				RefPlayerSettingRollout.height = height
			)

			fn uifn_CloseSetting =
            (
                try(DestroyDialog RefPlayerSettingRollout)catch()
            )

            fn uifn_OpenSetting open:#All hwnd: =
            (
                uifn_CloseSetting()

				if open == #Record then
				(
					GetRolloutHeight = GetRolloutHeight_Record
					createDialog RefPlayerSettingRollout width:300 height:200 parent:hwnd

					addsubRollout RefPlayerSettingRollout.sub  RecordSetting_Rollout  
					addsubRollout RefPlayerSettingRollout.sub  About_Rollout  
				)else
				(
					GetRolloutHeight = GetRolloutHeight_All
					createDialog RefPlayerSettingRollout width:300 height:800 parent:hwnd

					addsubRollout RefPlayerSettingRollout.sub  RecordSetting_Rollout    
					addsubRollout RefPlayerSettingRollout.sub  PlayerSetting_Rollout   
					addsubRollout RefPlayerSettingRollout.sub  TimeSetting_Rollout 
					addsubRollout RefPlayerSettingRollout.sub  GridSetting_Rollout 
					addsubRollout RefPlayerSettingRollout.sub  About_Rollout  
				)

				RecordSetting_Rollout.open = open == #All or open == #Record 
                PlayerSetting_Rollout.open = open == #All or open == #Player 
                TimeSetting_Rollout.open   = open == #All or open == #Time  
                GridSetting_Rollout.open   = open == #All or open == #GridLine
                About_Rollout.open = open == #All

				SetRolloutHeight()
            )
        )

        (---- RC Menus ----
			rcMenu rcMenu_Time
			(
				--menuItem TimeCategory   "-----时间设置-----" enabled:false
				
				menuItem SyncTimeRange "SyncTimeRange" -- "同步时间轴" 

				separator sp1-------------------------------
				
				menuItem SetStartKey1   "SetStartKey1" -- "将首张图像同步到此帧"
				menuItem SetStartKey2   "SetStartKey2" -- "将当前图像同步到0帧"
				
				on SetStartKey1    picked do  cTime_SetCurrFrameAsStartTime()
				on SetStartKey2    picked do  cTime_SetCurrImgAsFirstFrame()

				on SyncTimeRange picked do  cTime_SyncMaxTimeRange()
				
				on rcMenu_Time open do
				(
					SyncTimeRange.Text = SYNC_MAX_TIMERANGE
					SetStartKey1.Text  = SYNC_SET_CURRENT_FRAME_AS_START_TIME
					SetStartKey2.Text  = SYNC_SET_CURRENT_IMG_AS_ZERO_FRAME
				)
			)
			
			rcMenu rcMenu_Display
			(
					
				menuItem SetOriginalRes "SetOriginalRes"    --"原始分辨率"
				menuItem FillViewport   "FillViewport" --"覆盖视口"
				
				separator sp1-------------------------------
				
				menuItem GridLine "GridLine" --"显示参考线"
				
				separator sp2-------------------------------
				
				menuItem SetOpacity1 "SetOpacity1" --"不透明度100%"
				menuItem SetOpacity2 "SetOpacity2" --"不透明度75%"
				menuItem SetOpacity3 "SetOpacity3" --"不透明度50%"
				menuItem SetOpacity4 "SetOpacity4" --"不透明度25%"
				
				separator sp3-------------------------------
				
				menuItem AlwaysOnTop "AlwaysOnTop" --"总在最前"

				on SetOpacity1 picked do cDisplay_SetOpacity 1
				on SetOpacity2 picked do cDisplay_SetOpacity 0.75
				on SetOpacity3 picked do cDisplay_SetOpacity 0.5
				on SetOpacity4 picked do cDisplay_SetOpacity 0.25
				
				on GridLine picked do cDisplay_ToggleGridOn()

				on AlwaysOnTop picked do cDisplay_ToggleAlwaysOnTop()
				
				on SetOriginalRes picked do  uifn_ResizeToRatio 1
            
				on FillViewport picked do cDisplay_FillViewport()
				
				on rcMenu_Display open do 
				(
					SetOriginalRes.Text = PLAYER_ORIGINALRES
					FillViewport.Text   = PLAYER_FILL_VIEWPORT_ON
					SetOpacity1.Text    = PLAYER_OPACITY_1
					SetOpacity2.Text    = PLAYER_OPACITY_2
					SetOpacity3.Text    = PLAYER_OPACITY_3
					SetOpacity4.Text    = PLAYER_OPACITY_4
					
					AlwaysOnTop.text = if cDisplay_IsAlwaysOnTop() then PLAYER_ALWAYS_ON_TOP_OFF else PLAYER_ALWAYS_ON_TOP_ON
					GridLine.text    = if cDisplay_IsGridOn()      then PLAYER_GRID_OFF          else PLAYER_GRID_ON
				)
			)
		)

		(---- HotKey ----
			fn ExtraHotKeys keyCode =
			(
				case keyCode of
				(
					"D1":cDisplay_SetOpacity 1
					"D2":cDisplay_SetOpacity 0.75
					"D3":cDisplay_SetOpacity 0.5
					"D4":cDisplay_SetOpacity 0.25
					
					"R":cDisplay_ScaleToRatio 1
					
					"A":cTime_Forward()
					"D":cTime_Backward()
					"S":cTime_SyncMaxTimeRange()
					"G":cDisplay_ToggleGridOn()
					"T":cDisplay_ToggleAlwaysOnTop()
					"F":cDisplay_FillViewport()
					
					"Q":HistoryButton.ShowDropDown()
					"H":HistoryButton.ShowDropDown()

					"Oemtilde":shellLaunch (dFile_GetCurrFolder()) ""
				)
			)


			fn RefPlayerHotKey sender eventArgs =
			(
				if not m_PlayerMode == MODE_PLAYER_NORMAL do return()

				--print ( eventArgs.KeyCode.ToString())
				KeyCode = eventArgs.KeyCode.ToString()

				case KeyCode of 
				(
					"Oemcomma":max time back
					"OemPeriod":max time forward

					"OemQuestion":if not isAnimPlaying() then playAnimation() else StopAnimation()
					"Space":if not isAnimPlaying() then playAnimation() else StopAnimation()
					
					default:if RPUseHotKey do ExtraHotKeys KeyCode
				)

			)
			
			
			fn init_RegisterHotKey =
			(
				dotnet.addeventhandler ui_PlayerWindow #KeyDown RefPlayerHotKey
			)

		)

		/* Debug */Debug_LogTime "Extra UI Elements"

	)
	
	RP_Start() 

	(/*  Debug  */ DebugMode = off

		if DebugMode do
		(
			print DebugInfoString

			global Player = ui_PlayerWindow
			global PlayerTS = ui_PlayerToolStrip
			global PlayerPB = ui_PlayerPictureBox
			global PlayerGrid = ui_PlayerGridPictureBox
            global TSShadow = ui_PlayerTSShadow

			global Rec = ui_RecordWindow
			global RecTS = ui_RecordToolStrip

			global RecordMax = RecordMax
			global GifRollout = uifn_OpenGifRollout

			global UpdateGrid = cDisplay_UpdateGrid

			global ReadPL = fFile_ReadPlayList

			global HistoryButton = HistoryButton

            global Min = PlayerMinimize
            global TimerEvents = TimerEvents
            global LogTimer = Debug_TimerStatus


            lastLog = #()

            fn LogInfo dnobject = 
            (
                logString = dnobject.ToString() + ":\n"

                props = getpropnames dnobject

                for i = props.count to 1 by -1 do
                (
                    try(
                        prop = props[i]
                        val = getproperty dnobject prop
                        if classof val == dotnetobject do val = val.ToString()

                        LogProp = stringStream ""
                        format "%:%\n" prop val to:LogProp
                        LogProp = LogProp as string
                        
                        if lastLog[i] != LogProp do
                        (
                            logString += LogProp
                            lastLog[i] = LogProp
                        )
                    )catch()
                )

                print logString
            )

            fn DebugHotKey sender eventArgs =
			(
				if m_PlayerMode != MODE_PLAYER_NORMAL do return()
				KeyCode = eventArgs.KeyCode.ToString()

				case KeyCode of 
				(
					"B":LogInfo ui_PlayerWindow
                    "C":LogInfo ui_PlayerToolStrip
                    "V":Debug_TimerStatus()
				)

			)

            dotnet.addeventhandler ui_PlayerWindow #KeyDown DebugHotKey  


			--stack()
		)
	)

)
