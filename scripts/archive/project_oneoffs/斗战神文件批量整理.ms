try(DestroyDialog ModelStandardRollout) catch()

struct ModelStandardConfig
(
    RenderSize = [1600, 1200],
    BgColor = color 97 97 97,
    AmbientColor = color 255 255 255,
    ValidTextureSuffixes = #("_h.dds", "_s.dds", "_g.dds"),
    LayoutType = #layout_1,
    DefaultView = #view_front,
    MaterialSlots = 24
)

struct FileProcessor
(
    config = ModelStandardConfig(),
    
    fn IsValidTexturePath path =
    (
        for suffix in config.ValidTextureSuffixes do
        (
            if matchPattern path pattern:("*" + suffix) do return false
        )
        true
    ),
    
    fn DeleteNoSkinObjects =
    (
        max unfreeze all
        local deleteCandidates = for obj in geometry where obj.modifiers[#skin] == undefined and (classof obj == Box or classof obj == Editable_mesh or classof obj == Plane ) collect obj
        delete deleteCandidates
        clearSelection()
    ),
    
    fn SetupViewport =
    (
        viewport.setLayout config.LayoutType
        viewport.setGridVisibility #all off
        hideByCategory.bones = on
        hideByCategory.helpers = on 
        actionMan.executeAction -844228238 "12"  -- 高质量模式
        actionMan.executeAction 0 "554"         -- Flat Color显示
    ),
    
    fn SetupMaterials dirPath =
    (
        local ddsFiles = getFiles (dirPath + "\\*.dds")
        local mainMaterial = Standardmaterial()
        
        if ddsFiles.count > 0 do
        (
            for f in ddsFiles where IsValidTexturePath f do
            (
                mainMaterial.diffuseMap = Bitmaptexture fileName:f
                mainMaterial.opacityMap = Bitmaptexture fileName:f
                mainMaterial.opacityMap.monoOutput = 1
                exit  -- 只使用第一个有效纹理
            )
        )
        
        for i = 1 to config.MaterialSlots do meditMaterials[i] = mainMaterial
        geometry.material = mainMaterial
    ),
    
    fn ProcessMaxFile filePath =
    (
        local success = false
        try
        (
            resetMaxFile #noPrompt
			loadMaxFile filePath quiet:true 
			tempRange =Interval animationRange.start animationRange.end
			resetMaxFile #noPrompt
            mergeMAXFile filePath quiet:true
			
            animationRange = tempRange
            DeleteNoSkinObjects()
            SetupViewport()
            SetupMaterials (getFilenamePath filePath)
            
            local objName = getFilenameFile filePath
            local isAtStand = matchPattern objName pattern:"*atstand*"
            local isStand = matchPattern objName pattern:"*stand*"
            
            case of
            (
                (isAtStand):
                (
                    viewport.setType config.DefaultView
                    renderers.current = ART_Renderer()
                    render outputFile:(objName + ".jpg") vfb:off outputSize:config.RenderSize
                )
                (isStand):
                (
                    viewport.setType config.DefaultView
                    renderers.current = Default_Scanline_Renderer()
                    render outputFile:(objName + ".jpg") vfb:off outputSize:config.RenderSize
                )
                default:
                (
                    viewport.setType #view_left
                    max tool zoomextents
                )
            )
            
            saveMaxFile filePath saveAsVersion:((maxVersion())[8]-3)
            success = true
        )
        catch
        (
            format "Error processing file: %\n" filePath
            resetMaxFile #noPrompt
        )
        success
    ),
    
    fn ProcessDirectory dirPath =
    (
        local maxFiles = getFiles (dirPath + "\\*.max")
        for f in maxFiles do ProcessMaxFile f
        
        local subDirs = getDirectories (dirPath + "\\*")
        for d in subDirs do ProcessDirectory d
    )
)

rollout ModelStandardRollout "模型规范整理 v2.0"
(
    edittext edtPath "项目路径:" fieldWidth:200 height:30 labelOnTop:true  across:2
    button btnBrowse "浏览..." width:60  height:30  offset:[40,18]
    button btnProcess "开始处理" width:300 height:40
    
    on btnBrowse pressed do
    (
        local path = getSavePath()
        if path != undefined do edtPath.text = path
    )
    
    on btnProcess pressed do
    (
        if doesFileExist edtPath.text do
        (
            disableSceneRedraw()
            local processor = FileProcessor()
            processor.ProcessDirectory edtPath.text
            enableSceneRedraw()
            redrawViews()
            messageBox "处理完成!"
        )
    )
)

createDialog ModelStandardRollout 320 115