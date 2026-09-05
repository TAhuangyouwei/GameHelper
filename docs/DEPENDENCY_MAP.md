# 脚本依赖关系

本文件记录第一轮目录整理后的真实加载关系。

## 主入口

    scripts/AnimTools.ms
    └─ scripts/modules/CGH_ToolRegistry.ms
       ├─ scripts/HYW_Scripts_Library.ms
       ├─ scripts/tools/export/查看合并导出插件.ms
       ├─ scripts/tools/export/FBX批量导出.ms             # 已注册，尚未加入主面板按钮
       ├─ scripts/opaque/auto_fbx_to_bip/AutoFbxtoBip v1.4.mse
       ├─ scripts/tools/animation/Process_text_file_for_animation_range.ms
       ├─ scripts/tools/rigging/bonedivider.ms
       ├─ scripts/tools/animation/复制物体运动轨迹.ms
       ├─ scripts/opaque/reference_master/参考大师v1.06.mse
       ├─ scripts/AnimTools.ms                             # 切换语言时重新加载自身
       ├─ scripts/opaque/reset_skin_pose/重置蒙皮pose V1.1.mse
       ├─ scripts/tools/skin/Rigging_CombineSkin.ms
       ├─ scripts/tools/facial/facialRig_UI.ms
       ├─ scripts/tools/rigging/自定义骨骼绑定.ms
       ├─ scripts/tools/skin/add_Skin_Bones.ms
       ├─ scripts/tools/skin/skinTools.ms
       ├─ scripts/tools/skin/copy_paste_skin_weight.ms
       ├─ scripts/vendor/twist_bones/TwistBones.ms
       ├─ scripts/opaque/restore_biped/还原bip的外观和修改器.mse
       ├─ scripts/tools/scene/选择同名物体.ms
       └─ scripts/tools/facial/animcraft_float_Script_edit.ms

所有主面板子工具路径集中在 `CGH_ToolRegistry.ms`。以后移动脚本时只修改注册表，不改按钮事件中的工具编号。

## 面部绑定

    scripts/tools/facial/facialRig_UI.ms
    ├─ createFacialControl_UI_Layout.ms
    ├─ faceBones.ms
    ├─ createFacialExpressionUnit.ms
    └─ SalPoseManager.ms

这五个文件已经作为一个整体迁移，内部仍使用同目录相对路径加载。

## 公共库依赖

    scripts/tools/rigging/自定义骨骼绑定.ms ───────────────┐
                                                          ├─> scripts/HYW_Scripts_Library.ms
    scripts/AnimTools.ms ─> CGH_ToolRegistry.ms ──────────┘                    │
                                                                               ├─> modules/material/MaterialUtilities.ms
                                                                               ├─> modules/rigging/BipedFunctions.ms
                                                                               ├─> modules/rigging/CustomIKHISolver.ms
                                                                               ├─> modules/rigging/BoneUtilities.ms
                                                                               ├─> modules/model/ModelUtilities.ms
                                                                               ├─> modules/model/ObjectProcessing.ms
                                                                               ├─> modules/viewport/ViewportUtilities.ms
                                                                               ├─> modules/scene/SceneUtilities.ms
                                                                               ├─> modules/scene/LayerUtilities.ms
                                                                               ├─> modules/interface/InterfaceUtilities.ms
                                                                               ├─> modules/animation/AnimationUtilities.ms
                                                                               ├─> modules/skin/BoneSkinUtilities.ms
                                                                               ├─> modules/ui/RolloutUiUtilities.ms
                                                                               └─> modules/ui/EmbeddedImageData.ms

`HYW_Scripts_Library.ms` 只负责加载公共模块。`自定义骨骼绑定.ms` 从 `tools/rigging/` 向上解析到这个兼容入口。

## 独立工具

`tools/export/FBX批量导出.ms`、`tools/animation/同步武器动画.ms` 和 `tools/animation/bone动画批量导出合并.ms` 暂未加入主面板。项目批处理脚本已归档，第三方工具已与自维护工具分离；后续再决定哪些独立工具加入主面板。
