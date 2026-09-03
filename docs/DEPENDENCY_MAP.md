# 脚本依赖关系

本文件只记录当前真实加载关系，不代表最终目录设计。

## 主入口

    AnimTools.ms
    ├─ HYW_Scripts_Library.ms
    ├─ 查看合并导出插件.ms
    ├─ AutoFbxtoBip v1.4.mse
    ├─ Process_text_file_for_animation_range.ms
    ├─ bonedivider.ms
    ├─ 复制物体运动轨迹.ms
    ├─ 参考大师v1.06.mse
    ├─ AnimTools.ms                  # 切换语言时重新加载自身
    ├─ 重置蒙皮pose V1.1.mse
    ├─ Rigging_CombineSkin.ms
    ├─ facialRig_UI.ms
    ├─ 自定义骨骼绑定.ms
    ├─ add_Skin_Bones.ms
    ├─ skinTools.ms
    ├─ copy_paste_skin_weight.ms
    ├─ TwistBones.ms
    ├─ 还原bip的外观和修改器.mse
    ├─ 选择同名物体.ms
    └─ animcraft_float_Script_edit.ms

AnimTools.ms 使用当前脚本目录拼接相对文件名，所以现在直接移动上述文件会导致按钮失效。必须先建立集中式路径注册表，或者在每次移动文件的同一个提交中更新路径并验证按钮。

## 面部绑定

    facialRig_UI.ms
    ├─ createFacialControl_UI_Layout.ms
    ├─ faceBones.ms
    ├─ createFacialExpressionUnit.ms
    └─ SalPoseManager.ms

这五个文件应作为一个整体移动和测试，不应分散处理。

## 公共库依赖

    自定义骨骼绑定.ms ──> HYW_Scripts_Library.ms
    AnimTools.ms        ──> HYW_Scripts_Library.ms

查看合并导出插件.ms 顶部的公共库加载代码目前被注释，说明它可能默认由 AnimTools.ms 启动。后续需要决定它是：

1. 只能从主入口打开；或
2. 支持独立运行，并自行检查/加载公共库。

## 当前没有显式入口关系的脚本

FBX批量导出.ms、同步武器动画.ms、bone动画批量导出合并.ms、项目批处理脚本及部分第三方工具目前未被 AnimTools.ms 显式加载。它们应先按“独立工具、历史脚本或未来入口”分类，再决定是否加入主面板。

