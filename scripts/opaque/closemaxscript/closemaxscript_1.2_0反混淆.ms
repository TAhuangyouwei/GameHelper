--CloseMaxscript_1.2反混淆
--YYP
--2018.12.25
try(destroyDialog fanhunxiao)catch()
global fuck
fn check_base64 encryption_mse =
(
        file_open = openfile encryption_mse mode:"r"
         while  not eof file_open do
        (
                lintext = readline file_open
                if (findString lintext "undefined" != undefined)  then
                (
                        close file_open
                        return (filterString lintext "\"")[2]
                )
        )
)

fn decrypter_base64 scr_base64 =
(
        Encoding = dotnetclass "system.text.Encoding"
        strArray2 = #("00000000", "FgCwc7Xy", "nrJHxVb3", "dbU5EhaC", "btKvH6re", "ihpPqH3K", "E8F2uhjB", "fiRSNIEA", "deRXDE3H", "O3RCzYaO", "cTHCaC4v", "nB8qbgBT", "SPcTnhkG", "cKQpCh1V", "cz3RNCCZ", "CFCdE1P6", "KHKf2S11", "uHhczEMH", "Tnh5zOjd", "R6txx1wG", "SHZqMv49")
        bytes = Encoding.ASCII.GetBytes(strArray2[11+1]);
        rgbIV = Encoding.ASCII.GetBytes(strArray2[3+1]);
        buffer = (dotnetclass "system.Convert").FromBase64String(scr_base64);
        provider = dotnetobject "System.Security.Cryptography.DESCryptoServiceProvider"
        stream = dotnetobject "System.IO.MemoryStream" buffer
        stream2 = dotnetobject "System.Security.Cryptography.CryptoStream" stream (provider.CreateDecryptor bytes rgbIV) (dotnetclass "System.Security.Cryptography.CryptoStreamMode").Read
    code = (dotnetobject "System.IO.StreamReader" stream2 ).ReadToEnd()
        buffer = undefined;
        stream2 = undefined;
        return code
)
rollout fanhunxiao "CloseMaxscript_1.2反混淆" width:430 height:200
(
        dotNetControl button1 "button" pos:[8,38] width:409 height:22
        GroupBox grp1 "反混淆" pos:[4,3] width:421 height:186
        button btn_fhx "反混淆：Open My Code" pos:[10,70] width:410 height:36
        label lbl1 "本脚本只适合特定加密工具:CloseMaxscript_1.2加密的脚本的反混淆!" pos:[29,117] width:370 height:25
        label lbl3 "By yyp 872564172@qq.com" pos:[117,142] width:148 height:22
--     on button1 click sender do
--     (
--     )

        on fanhunxiao open do
        (
            button1.Location = dotNetObject "System.Drawing.Point" 0 0
            button1.Name = ""
            button1.TabIndex = 0
            button1.Text = "拖入已被混淆的文件到此框！"
            button1.UseVisualStyleBackColor = false
            button1.allowdrop = true
        )
        on button1 DragDrop sender do
        (
            maxfiles_arr = sender.Data.GetData((dotNetClass "System.Windows.Forms.DataFormats").FileDrop)
            bb = maxfiles_arr as string
            for i in maxfiles_arr do( fuck = i as string)
            --dd = filenameFromPath fuck
            button1.text = fuck   --dd
        )
        on button1 DragEnter sender do
        (
            sender.Effect = (dotNetClass "System.Windows.Forms.DragDropEffects").link
        )
        on btn_fhx pressed do
                (
                        if (doesFileExist fuck == true) and (getFilenameType  fuck == ".ms") then
                        (
                                the_code = decrypter_base64 (check_base64 fuck)
                                new_de = (getFilenamePath  fuck) + (getFilenameFile   fuck) +"_de" + (getFilenameType fuck)
                                f = createFile new_de
                                format "%" the_code to:f
                                close f
                                messageBox "反混淆完成！" title:"提示："
                        )
                )
)
CreateDialog fanhunxiao