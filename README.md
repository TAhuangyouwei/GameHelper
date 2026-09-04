# GameHelper

GameHelper 是一组用于 3ds Max 的 MAXScript 工具，涵盖动画、绑定、蒙皮、场景检查、批处理与导出。

仓库当前处于“盘点与整理”阶段。现有脚本暂时保留原位置和原文件名，避免在依赖关系尚未梳理清楚时破坏入口。

## 当前入口

- 主工具面板：scripts/AnimTools.ms
- 公共函数库：scripts/HYW_Scripts_Library.ms
- 独立导出工具：scripts/FBX批量导出.ms

## 整理文档

- [新手接手与修改指南](docs/BEGINNERS_GUIDE.md)
- [脚本清单](docs/SCRIPT_CATALOG.md)
- [依赖关系](docs/DEPENDENCY_MAP.md)
- [分阶段整理计划](docs/REORGANIZATION_PLAN.md)

## 当前安全规则

1. 不在同一个提交中同时移动文件和重写逻辑。
2. 不删除来源未确认的脚本，先移动到归档或第三方区域。
3. 会批量打开、修改并保存 .max 的脚本，完成备份、预检和日志功能前，不直接对正式资产运行。
4. .mse 和混淆脚本视为发布产物或不透明依赖，不当作可维护源码。
5. tests/test_scenes 下的测试场景只保存在本地并由 .gitignore 排除，不上传到公开仓库；其他允许提交的 .max 才使用 Git LFS。

## 当前目录

    assets/    图标、贴图和数据
    docs/      清单、设计与使用说明
    examples/  示例
    output/    生成结果，不提交具体输出文件
    scenes/    场景资料
    scripts/   当前脚本源码与历史脚本
    tests/     自动化脚本和测试场景
