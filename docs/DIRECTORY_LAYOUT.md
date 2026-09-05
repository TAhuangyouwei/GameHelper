# 当前目录结构

本文件记录 2026-09-05 第一轮目录整理后的真实结构。

```text
scripts/
├─ AnimTools.ms                       主工具面板，稳定入口
├─ HYW_Scripts_Library.ms             公共库兼容入口
├─ modules/                           公共函数和工具注册表
├─ tools/                             继续维护的业务工具
│  ├─ animation/
│  ├─ export/
│  ├─ facial/
│  ├─ rigging/
│  ├─ scene/
│  └─ skin/
├─ vendor/                            第三方脚本
├─ opaque/                            .mse、载荷和混淆脚本
└─ archive/project_oneoffs/           旧项目一次性脚本
```

## 约束

- `AnimTools.ms` 和 `HYW_Scripts_Library.ms` 保留在根目录，入口位置不变。
- 主面板加载的工具统一登记在 `modules/CGH_ToolRegistry.ms`。
- `tools/facial/` 内的面部绑定文件必须保持在同一目录。
- `vendor/` 文件不做批量格式化或无关改写。
- `opaque/` 文件不作为可维护源码；来源不明的载荷不执行。
- `archive/project_oneoffs/` 文件不进入通用入口，重新使用前必须检查路径与保存行为。
