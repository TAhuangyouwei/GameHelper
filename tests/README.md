# 测试目录

    unit_tests/   MAXScript 测试和冒烟检查脚本
    test_scenes/  专门用于测试的 3ds Max 场景

test_scenes 中的 .max 文件是本地私有测试资产，不允许上传到当前公开 GitHub 仓库，已经通过 .gitignore 排除。不要使用 git add -f 强制加入这些文件。

测试脚本不得直接覆盖测试场景原件；需要保存时，应先复制到临时目录或 output。

## 当前测试

- unit_tests/test_render_to_mp4.py：使用随工程提供的 FFmpeg 验证实际 AVI 到 MP4 转换、帧数/帧率、音频、特殊路径、重名保护和错误处理。
- unit_tests/test_render_to_mp4.ms：在独立 Max 2024 批处理进程中检查自动转 MP4 脚本的加载、回调注册、筛选和关闭，不打开或保存场景。
- unit_tests/test_tool_registry.ms：加载工具注册表并检查所有登记文件是否存在，以及参考大师、重置蒙皮姿态是否使用可读源码；不打开或保存场景。
- unit_tests/test_library_initialization.ms：在临时目录中使用替身模块，检查公共库成功返回、模块缺失时提前停止、模块执行错误，以及主面板正确处理加载成功或失败。只执行实际初始化函数，不创建工具界面，不打开或保存场景；测试后恢复相关全局变量并清理临时文件。
