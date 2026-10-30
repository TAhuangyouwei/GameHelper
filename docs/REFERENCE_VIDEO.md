# 参考大师视频支持

将 MP4、MOV、AVI、MKV、WebM、M4V、WMV、MPG 或 MPEG 文件拖入参考窗口。
导入时按当前 Max 帧率生成 JPEG 序列，随后由现有播放器跟随 Max 时间轴显示，不播放音频。
导入进度窗口支持取消；导入失败或取消时保留原参考内容并移除未完成缓存。
视频缓存使用设置中的图片缓存目录，可用“清理缓存”删除闲置视频；正在打开的视频会保留。
视频较长时，转换和磁盘占用也会增加。

解码器随仓库提供，位置为项目根目录 `.local/refplayer/ffmpeg.exe`。
正常拉取或下载完整工程即可使用，无需另行安装 FFmpeg 或设置 PATH。
请保留该目录及其许可证、来源说明；此二进制使用普通 Git 文件存储，不依赖 Git LFS。
本次使用已有的 imageio-ffmpeg 0.6.0 所带 FFmpeg 7.1 essentials Windows 构建。
FFmpeg 项目：https://ffmpeg.org/；构建来源：https://www.gyan.dev/ffmpeg/builds/。
此构建启用了 GPLv3；许可证见 `.local/refplayer/COPYING.GPLv3`，版本、来源及源码链接见同目录 `README.md`。

验证：`python tests/unit_tests/test_reference_master_multiview.py` 检查现有功能；
`python tests/unit_tests/test_reference_master_video.py` 使用本地解码器生成短视频，验证转换、帧率、取消、错误和缓存清理。
