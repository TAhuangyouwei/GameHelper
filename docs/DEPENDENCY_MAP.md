# 脚本依赖关系

本文件记录第一轮目录整理后的真实加载关系。

## 主入口

    scripts/AnimTools.ms
    └─ scripts/公共模块/CGH_ToolRegistry.ms
       ├─ scripts/HYW_Scripts_Library.ms
       ├─ scripts/实用工具/导出/查看合并导出插件.ms
       ├─ scripts/实用工具/导出/FBX批量导出.ms             # 已注册，尚未加入主面板按钮
       ├─ scripts/加密与封装工具/FBX转Biped/AutoFbxtoBip v1.4.mse
       ├─ scripts/实用工具/动画/Process_text_file_for_animation_range.ms
       ├─ scripts/实用工具/骨骼绑定/bonedivider.ms
       ├─ scripts/实用工具/动画/复制物体运动轨迹.ms
       ├─ scripts/实用工具/动画/参考大师v1.06.ms
       ├─ scripts/AnimTools.ms                             # 切换语言时重新加载自身
       ├─ scripts/实用工具/蒙皮/重置蒙皮pose V1.1.ms
       ├─ scripts/实用工具/蒙皮/Rigging_CombineSkin.ms
       ├─ scripts/实用工具/面部绑定/facialRig_UI.ms
       ├─ scripts/实用工具/骨骼绑定/自定义骨骼绑定.ms
       ├─ scripts/实用工具/蒙皮/add_Skin_Bones.ms
       ├─ scripts/实用工具/蒙皮/skinTools.ms
       ├─ scripts/实用工具/蒙皮/copy_paste_skin_weight.ms
       ├─ scripts/第三方工具/扭转骨骼/TwistBones.ms
       ├─ scripts/加密与封装工具/还原Biped外观与修改器/还原bip的外观和修改器.mse
       ├─ scripts/实用工具/场景/选择同名物体.ms
       └─ scripts/实用工具/面部绑定/animcraft_float_Script_edit.ms

所有主面板子工具路径集中在 `CGH_ToolRegistry.ms`。以后移动脚本时只修改注册表，不改按钮事件中的工具编号。

参考大师和重置蒙皮姿态已改为加载上述可读 `.ms`，修改这些源码即可影响对应按钮。FBX 转 Biped、还原 Biped 的同名 `.ms` 仍是二进制封装，目前继续加载原 `.mse`，尚无可切换的可读源码。

## 面部绑定

    scripts/实用工具/面部绑定/facialRig_UI.ms
    ├─ createFacialControl_UI_Layout.ms
    ├─ faceBones.ms
    ├─ createFacialExpressionUnit.ms
    └─ SalPoseManager.ms

这五个文件已经作为一个整体迁移，内部仍使用同目录相对路径加载。

## 公共库依赖

    scripts/实用工具/骨骼绑定/自定义骨骼绑定.ms ───────────────┐
                                                          ├─> scripts/HYW_Scripts_Library.ms
    scripts/AnimTools.ms ─> CGH_ToolRegistry.ms ──────────┘                    │
                                                                               ├─> 公共模块/材质/MaterialUtilities.ms
                                                                               ├─> 公共模块/骨骼绑定/BipedFunctions.ms
                                                                               ├─> 公共模块/骨骼绑定/CustomIKHISolver.ms
                                                                               ├─> 公共模块/骨骼绑定/BoneUtilities.ms
                                                                               ├─> 公共模块/模型/ModelUtilities.ms
                                                                               ├─> 公共模块/模型/ObjectProcessing.ms
                                                                               ├─> 公共模块/视口/ViewportUtilities.ms
                                                                               ├─> 公共模块/场景/SceneUtilities.ms
                                                                               ├─> 公共模块/场景/LayerUtilities.ms
                                                                               ├─> 公共模块/界面交互/InterfaceUtilities.ms
                                                                               ├─> 公共模块/动画/AnimationUtilities.ms
                                                                               ├─> 公共模块/蒙皮/BoneSkinUtilities.ms
                                                                               ├─> 公共模块/界面组件/RolloutUiUtilities.ms
                                                                               └─> 公共模块/界面组件/EmbeddedImageData.ms

`HYW_Scripts_Library.ms` 只负责加载公共模块。`自定义骨骼绑定.ms` 从 `实用工具/骨骼绑定/` 向上解析到这个兼容入口。

公共库先检查全部必要模块，再依次执行；缺失模块或模块执行错误会抛出包含文件路径的错误，全部加载完成后返回 `true`。主面板检查注册表初始化及公共库加载结果，失败时不创建面板。

## 独立工具

`实用工具/导出/FBX批量导出.ms`、`实用工具/动画/同步武器动画.ms` 和 `实用工具/动画/bone动画批量导出合并.ms` 暂未加入主面板。项目批处理脚本已归档，第三方工具已与自维护工具分离；后续再决定哪些独立工具加入主面板。
