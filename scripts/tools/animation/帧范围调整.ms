
try(destroyDialog KeyRangeTool)catch()


rollout KeyRangeTool "动画范围工具" width:280 height:350
(

    button btn_select "选择场景所有物体" width:250 height:30
    button btn_range "调整时间轴到关键帧范围" width:250 height:30



    ------------------------------------------------
    -- 渲染参数预设
    ------------------------------------------------

    group "渲染参数预设"
    (
        spinner sp_width "Width:" range:[1,8000,1920] type:#integer fieldwidth:70 width:120 across:2


        spinner sp_height "Height:" range:[1,8000,1080]  type:#integer fieldwidth:70 width:120
    )





    ------------------------------------------------
    -- MAX文件列表
    ------------------------------------------------

    group "MAX文件合并列表"
    (
        button btn_add "添加MAX文件" width:250 height:30

        button btn_clear "清空文件列表" width:250 height:30


        listbox lb_files "" width:250 height:6


        button btn_merge "合并MAX文件到当前场景" width:250 height:30
    )





    -- 保存MAX路径
    local mergeFiles = #()






    ------------------------------------------------
    -- 设置渲染参数
    ------------------------------------------------

    fn loadAnimeRenderPreset =
    (
        local dialogState = renderSceneDialog.isOpen()



        -- 关闭Render Setup
        if dialogState do
        (
            renderSceneDialog.close()
        )



        -- 设置尺寸
        renderWidth = sp_width.value
        renderHeight = sp_height.value



        format "渲染参数设置完成\n"
        format "Width:% Height:%\n" renderWidth renderHeight



    )






    ------------------------------------------------
    -- 选择所有物体
    ------------------------------------------------

    on btn_select pressed do
    (
        select objects

        format "已选择场景所有物体: % 个\n" selection.count
    )









    ------------------------------------------------
    -- 获取Controller关键帧
    ------------------------------------------------

    fn getControllerKeys ctrl =
    (
        local times = #()



        if ctrl != undefined do
        (
            try
            (
                if numKeys ctrl > 0 then
                (
                    for i = 1 to numKeys ctrl do
                    (
                        append times (getKeyTime ctrl i)
                    )
                )
            )
            catch()



            try
            (
                for subCtrl in ctrl do
                (
                    join times (getControllerKeys subCtrl)
                )
            )
            catch()
        )


        times
    )








    ------------------------------------------------
    -- 调整动画范围
    ------------------------------------------------

    on btn_range pressed do
    (
        local allTimes = #()



        for obj in objects do
        (
            if obj.controller != undefined do
            (
                join allTimes (getControllerKeys obj.controller)
            )
        )



        if allTimes.count > 0 then
        (
            local minTime = amin allTimes
            local maxTime = amax allTimes



            animationRange = interval minTime maxTime

            sliderTime = minTime



            format "动画范围调整完成\n"
            format "开始帧:%\n" minTime
            format "结束帧:%\n" maxTime
        )
        else
        (
            messageBox "没有找到动画关键帧"
        )
    )










    ------------------------------------------------
    -- 添加MAX文件
    ------------------------------------------------

    on btn_add pressed do
    (
        local files = getOpenFileName \
            caption:"选择MAX文件" \
            types:"3ds Max File (*.max)|*.max|" \
            multiSelect:true



        if files != undefined then
        (

            if classOf files == String do
            (
                files = #(files)
            )



            for f in files do
            (
                if findItem mergeFiles f == 0 then
                (
                    append mergeFiles f
                )
            )



            lb_files.items = mergeFiles



            format "当前MAX列表:\n"
            print mergeFiles
        )
    )









    ------------------------------------------------
    -- 清空文件列表
    ------------------------------------------------

    on btn_clear pressed do
    (
        mergeFiles = #()

        lb_files.items = #()
    )









    ------------------------------------------------
    -- 合并MAX
    ------------------------------------------------

    on btn_merge pressed do
    (

        -- 合并前设置渲染尺寸
        loadAnimeRenderPreset ()

		

        if mergeFiles.count == 0 then
        (
            messageBox "没有选择需要合并的MAX文件"
        )
        else
        (
            local successCount = 0



            for f in mergeFiles do
            (
                try
                (
                    mergeMAXFile f #select


                    successCount += 1


                    format "合并成功:%\n" f
                )
                catch
                (
                    format "合并失败:%\n" f
                )
            )



            local msg = "合并完成\n成功合并 "

            msg += (successCount as string)

            msg += " 个MAX文件"



            messageBox msg
        )
		hideByCategory.bones  = on 
		viewport.setCamera cameras[1]
		
    )

)



createDialog KeyRangeTool

