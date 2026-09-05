files = getFiles @"D:\UNITY版本美术资源\动作\show\show_female\Xiu_g_01\home\*.max" recurse:true 

for File in files do 
(
    loadMaxFile File quiet:true 
    
    -- 创建一个标志变量，表示是否有父子关系被修改
    local isModified = false
    
    -- 检查并修改父子关系
    if isValidNode $B_Qiang01 and $B_Qiang01.parent != $'Bip001 R Hand' then
    (
        $B_Qiang01.parent = $'Bip001 R Hand'
        isModified = true
    )
    
    if isValidNode $B_R_sd and $B_R_sd.parent != $'Bip001 R Hand' then
    (
        $B_R_sd.parent = $'Bip001 R Hand'
        isModified = true
    )
    
    if isValidNode $B_Dao and $B_Dao.parent != $'Bip001 R Hand' then
    (
        $B_Dao.parent = $'Bip001 R Hand'
        isModified = true
    )
    
    if isValidNode $B_r_Zhua and $B_r_Zhua.parent != $'Bip001 R Hand' then
    (
        $B_r_Zhua.parent = $'Bip001 R Hand'
        isModified = true
    )
    
    if isValidNode $B_l_Zhua and $B_l_Zhua.parent != $'Bip001 L Hand' then
    (
        $B_l_Zhua.parent = $'Bip001 L Hand'
        isModified = true
    )
    
    if isValidNode $B_L_sd and $B_L_sd.parent != $'Bip001 L Hand' then
    (
        $B_L_sd.parent = $'Bip001 L Hand'
        isModified = true
    )
    
    if isValidNode $B_Jian and $B_Jian.parent != $'Bip001 R Hand' then
    (
        $B_Jian.parent = $'Bip001 R Hand'
        isModified = true
    )
    
    if isValidNode $B_Gun01 and $B_Gun01.parent != $'Bip001 R Hand' then
    (
        $B_Gun01.parent = $'Bip001 R Hand'
        isModified = true
    )
    
    -- 如果有父子关系被修改，保存文件
    if isModified do
    (
        saveMaxFile File saveAsVersion:2021
    )
)
