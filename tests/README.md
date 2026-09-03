# 测试目录

    unit_tests/   MAXScript 测试和冒烟检查脚本
    test_scenes/  专门用于测试的 3ds Max 场景

test_scenes 中的 .max 文件是本地私有测试资产，不允许上传到当前公开 GitHub 仓库，已经通过 .gitignore 排除。不要使用 git add -f 强制加入这些文件。

测试脚本不得直接覆盖测试场景原件；需要保存时，应先复制到临时目录或 output。

## 当前测试

- unit_tests/test_tool_registry.ms：加载工具注册表并检查所有登记文件是否存在，不打开或保存场景。
