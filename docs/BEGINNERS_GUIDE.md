# GameHelper 新手接手与修改指南

这份说明写给“代码基础不强、很久没有看过旧脚本、需要重新接手”的情况。你不需要一次读懂仓库里的所有代码。先建立整体认识，再只围绕一个按钮、一项功能做小修改，就不容易乱。

## 1. 先记住一句话

当前这轮整理没有重写你的工具功能，主要是在 `AnimTools.ms` 和各个子工具之间增加了一个统一的“地址簿”。

可以把几个文件想成下面这样：

```text
AnimTools.ms                   主面板，类似遥控器
    |
    +-- CGH_ToolRegistry.ms    地址簿，记录每个工具文件在哪里
    |
    +-- HYW_Scripts_Library.ms 公共库加载入口
            |
            +-- modules/       按材质、绑定、场景等职责保存公共能力
    |
    +-- tools/vendor/opaque/   被按钮打开的具体子工具和外部依赖
```

- `AnimTools.ms` 负责显示按钮，以及决定点击按钮后做什么。
- `CGH_ToolRegistry.ms` 只负责把工具编号对应到脚本路径。
- `HYW_Scripts_Library.ms` 只负责依次加载公共模块，保留旧脚本的入口兼容性。
- `scripts/modules/` 下的分类文件保存材质、骨骼、界面和动画等真正的公共功能。
- `scripts/tools/export/FBX批量导出.ms`、`scripts/tools/export/查看合并导出插件.ms` 等文件仍然保存各自真正的业务逻辑。

所以，这次增加注册表不会改变导出规则、合并规则、蒙皮算法或动画算法。

## 2. 当前优先维护的三个核心工具

### 2.1 `scripts/AnimTools.ms`

这是主入口和工具集合面板。它包含两种按钮。

第一种按钮直接调用公共函数，例如：

```maxscript
on btResetMat pressed do
(
    MaterialUtilities.resetCompactMaterialSlots()
)
```

这表示点击按钮后，调用已经加载到内存中的公共函数。

第二种按钮打开另一个脚本，例如：

```maxscript
on btQuickLook pressed do
(
    ::CGH_ToolRegistry.loadTool #viewerExporter
)
```

这表示点击“查看导出合并文件”后，让注册表找到并运行对应脚本。

### 2.2 `scripts/tools/export/FBX批量导出.ms`

这是独立的批量导出界面。目前它已经登记到注册表，编号是 `#fbxBatchExporter`，但没有擅自给 `AnimTools` 增加新按钮。

这个脚本会涉及打开 Max 文件和导出 FBX。以后修改它时，必须先使用测试场景副本，不要直接拿正式项目文件试验。

### 2.3 `scripts/tools/export/查看合并导出插件.ms`

这是 `AnimTools` 中“查看导出合并文件”按钮打开的脚本，注册编号是 `#viewerExporter`。

它包含打开、合并和保存 Max 文件的操作，风险比普通界面按钮高。目前它的旧编码中文仍有乱码，内部逻辑还没有在本轮整理中重写。

## 3. 这次到底改了什么

### 3.1 将 `AnimTools.ms` 转为 UTF-8 BOM

目的：让现代编辑器和 3ds Max 更稳定地识别中文。

这一步会导致 Git 把许多中文行显示成“删除后重新增加”，看起来改动很大。实际转换前后做过文字往返检查，中文内容没有因为转码被改写。

以后保存 `AnimTools.ms` 时，继续使用 UTF-8 with BOM。不要随意在 ANSI、GBK 和 UTF-8 之间反复切换。

### 3.2 新增统一工具注册表

新增文件：

```text
scripts/modules/CGH_ToolRegistry.ms
```

以前每个按钮都自己获取目录、拼接路径、再加载脚本。类似：

```maxscript
currentFolder = getFilenamePath (getThisScriptFilename())
rulesScript = pathConfig.appendPath currentFolder "查看合并导出插件.ms"
fileIn rulesScript
```

这种写法没有错，但重复很多次。将来一旦移动文件，每一个相关按钮都可能需要修改。

现在按钮只写：

```maxscript
::CGH_ToolRegistry.loadTool #viewerExporter
```

文件名和路径集中写在注册表里：

```maxscript
#viewerExporter: "tools/export/查看合并导出插件.ms"
```

将来移动文件时，通常只需要改注册表中的一行。

### 3.3 修改 `AnimTools.ms` 的启动部分

现在文件开头按以下顺序工作：

```text
1. 找到 AnimTools.ms 自己所在的目录
2. 拼出 modules/CGH_ToolRegistry.ms 的完整路径
3. 检查注册表文件是否存在
4. 加载注册表
5. 把 scripts 目录交给注册表作为根目录
6. 通过注册表加载 HYW_Scripts_Library.ms
7. HYW_Scripts_Library.ms 依次加载 modules 下的公共模块
8. 创建 AnimTools 面板
```

对应代码是：

```maxscript
currentFolder = getFilenamePath (getThisScriptFilename())
toolRegistryScript = pathConfig.appendPath currentFolder "modules/CGH_ToolRegistry.ms"

if doesFileExist toolRegistryScript then
(
    fileIn toolRegistryScript
    if ::CGH_ToolRegistry != undefined do
    (
        ::CGH_ToolRegistry.initialize currentFolder
        ::CGH_ToolRegistry.loadTool #library
    )
)
else
    messageBox ("GameHelper registry was not found:" + "\n" + toolRegistryScript)
```

### 3.4 替换重复的按钮加载代码

`AnimTools.ms` 中原先分散的子工具加载代码，被替换成 `loadTool` 调用。按钮名称、界面布局和子工具功能没有因此改变。

当前注册了 20 个工具编号，`AnimTools` 使用其中 19 个。剩下的 `#fbxBatchExporter` 是为核心导出工具预留的登记项。

### 3.5 增加路径检查脚本

新增：

```text
tests/unit_tests/test_tool_registry.ms
```

它只检查 20 个登记路径能否找到文件：

- 不打开 `.max`；
- 不保存 `.max`；
- 不导出 FBX；
- 不修改场景。

路径静态检查已经通过，但还需要在交互式 3ds Max 中逐个点击核心按钮进行人工验证。

### 3.6 保护本地测试场景

`.gitignore` 中加入了：

```gitignore
/tests/test_scenes/*.max
```

因此该目录中的四个 `.max` 只留在本地，不会加入公开 GitHub。当前已经确认这些文件没有被 Git 跟踪。

注意：`.gitattributes` 中的 `*.max` Git LFS 规则只适用于其他将来允许提交的 Max 文件；被 `.gitignore` 排除的这四个测试场景仍然不会上传。

## 4. 注册表代码怎么理解

注册表文件的核心是一个 `struct`。现在不需要深入学习面向对象，只要把它理解成“把相关变量和函数装在一起的盒子”。

### 4.1 `rootPath`

```maxscript
rootPath = undefined
```

用来保存 `scripts` 文件夹路径。`undefined` 表示还没有设置。

### 4.2 `initialize`

```maxscript
fn initialize value = (...)
```

负责接收并保存 `scripts` 根目录。正常初始化后，其他工具路径都以这里为起点。

### 4.3 `getRelativePath`

```maxscript
fn getRelativePath toolId =
(
    case toolId of
    (
        #viewerExporter: "tools/export/查看合并导出插件.ms"
        #fbxBatchExporter: "tools/export/FBX批量导出.ms"
        default: undefined
    )
)
```

这是地址簿正文：左边是程序使用的固定编号，右边是真实文件相对路径。

`#viewerExporter` 是 MAXScript 的 Name 值。可以把前面的 `#` 理解为“内部编号标记”，它不是文件名。

### 4.4 `getPath`

这个函数先查询相对路径，再把根目录和相对路径合成完整路径。

例如：

```text
根目录：D:\UGit\GameHelper\scripts\
相对路径：tools/export/查看合并导出插件.ms
完整路径：D:\UGit\GameHelper\scripts\tools\export\查看合并导出插件.ms
```

### 4.5 `loadTool`

它按以下顺序处理：

1. 根据工具编号获取完整路径；
2. 编号没有登记时弹出 `not registered`；
3. 文件存在时使用 `fileIn` 执行；
4. 文件不存在时弹出 `script was not found`；
5. 成功返回 `true`，失败返回 `false`。

这里的 `fileIn` 可以理解为“读取并执行另一个 MAXScript 文件”。

## 5. 看懂 MAXScript 所需的最少语法

你暂时只需要认识下面这些：

| 写法 | 含义 |
| --- | --- |
| `-- 文字` | 单行注释，不会执行 |
| `/* ... */` | 多行注释 |
| `local a = 1` | 建立只在当前范围使用的变量 |
| `global a` | 建立多个脚本都可能访问的全局变量 |
| `fn 名称 参数 = (...)` | 定义一个函数 |
| `rollout AniTools "动作工具" (...)` | 定义一个 Max 工具面板 |
| `button btnName "按钮文字"` | 创建按钮 |
| `on btnName pressed do (...)` | 定义左键点击后的操作 |
| `on btnName rightClick do (...)` | 定义右键点击后的操作 |
| `fileIn path` | 加载并执行另一个脚本 |
| `doesFileExist path` | 检查文件是否存在 |
| `#viewerExporter` | 一个固定的 Name 编号 |
| `::CGH_ToolRegistry` | 明确访问全局注册表变量 |
| `try (...) catch (...)` | 出错时进入备用处理，避免直接中断 |

括号非常重要。修改时建议先只改括号内部的一两行，不要一次移动很大一段代码。

## 6. 以后修改时先判断属于哪一类

### 情况 A：只想改按钮显示文字

例如：

```maxscript
button btQuickLook "查看导出合并文件" height:21 width:200
```

只修改引号中的中文：

```maxscript
button btQuickLook "查看、合并与导出" height:21 width:200
```

不要同时修改 `btQuickLook`。它是代码内部名称，下面的点击事件还要靠它对应按钮。

### 情况 B：只想修改一个工具的功能

先找按钮加载的是哪个编号：

```maxscript
::CGH_ToolRegistry.loadTool #viewerExporter
```

再到注册表查询：

```maxscript
#viewerExporter: "tools/export/查看合并导出插件.ms"
```

然后只修改 `查看合并导出插件.ms`。这种情况下通常不需要改 `AnimTools.ms` 和注册表。

### 情况 C：脚本改名或移动目录

当前文件已经移动到：

```text
scripts/tools/export/查看合并导出插件.ms
```

对应修改注册表：

```maxscript
#viewerExporter: "tools/export/查看合并导出插件.ms"
```

`AnimTools.ms` 中的 `#viewerExporter` 不需要改变。

移动文件和修改功能要分两次进行：第一次只移动并更新路径，确认能打开后，再做逻辑修改。

### 情况 D：给 `AnimTools` 增加一个新工具按钮

假设新脚本叫 `我的检查工具.ms`。

第一步，在注册表 `case toolId of` 中增加：

```maxscript
#myCheckTool: "我的检查工具.ms"
```

第二步，在 `AnimTools.ms` 合适的 `group` 中增加按钮：

```maxscript
button btnMyCheck "我的检查" width:200

on btnMyCheck pressed do
(
    ::CGH_ToolRegistry.loadTool #myCheckTool
)
```

第三步，在 `tests/unit_tests/test_tool_registry.ms` 的 `toolIds` 数组中增加：

```maxscript
#myCheckTool,
```

第四步，先确认路径检查通过，再打开 3ds Max 点击按钮。

名称需要保持三处一致：

```text
注册表中的 #myCheckTool
AnimTools 按钮事件中的 #myCheckTool
测试数组中的 #myCheckTool
```

### 情况 E：把 `FBX批量导出.ms` 加到主面板

注册表已经有：

```maxscript
#fbxBatchExporter: "tools/export/FBX批量导出.ms"
```

因此只需要在 `AnimTools.ms` 中增加按钮和事件：

```maxscript
button btnFbxBatch "FBX批量导出" width:200

on btnFbxBatch pressed do
(
    ::CGH_ToolRegistry.loadTool #fbxBatchExporter
)
```

是否增加、放在哪个分组，属于界面设计决定，所以本轮没有替你擅自添加。

## 7. 推荐的安全修改流程

以后每次修改都按同一个顺序。

### 第一步：只选一个小目标

好的目标：

- 修改一个按钮文字；
- 修复一个明确报错；
- 给一个输入框增加默认路径；
- 移动一个工具并更新注册表。

不建议把“改目录、修逻辑、重做界面、统一命名”放在同一次修改中。

### 第二步：开始前看 Git 状态

在 UGit 中确认当前有没有尚未提交的改动。如果有，先判断是不是你正在处理的内容，不要把两件无关的修改混在一次提交里。

### 第三步：准备测试副本

凡是代码中出现这些操作，都把它当成高风险脚本：

```maxscript
loadMaxFile
mergeMAXFile
saveMaxFile
exportFile
delete
```

测试时复制 `.max` 到 `tests/test_scenes`，再复制一份临时工作副本。不要让第一次试运行接触正式资产和唯一原件。

### 第四步：只改最少代码

先让一个小修改工作，再考虑整理格式。一次改动越小，出错时越容易定位。

### 第五步：在 3ds Max 中人工验证

对于 `AnimTools.ms`：

1. 打开一个空场景或测试场景副本；
2. 通过 MAXScript 的 Run Script 运行 `AnimTools.ms`；
3. 确认“动作工具”面板正常打开；
4. 点击本次涉及的按钮；
5. 确认对应子工具打开或功能执行；
6. 查看 MAXScript Listener 是否出现红色报错；
7. 关闭并再次打开面板，检查是否重复报错。

对于导出或合并工具：

1. 输出目录使用专门的临时文件夹；
2. 先只处理一个测试文件；
3. 记录运行前后的文件数量和修改时间；
4. 确认没有覆盖测试场景原件；
5. 单文件通过后才测试批量操作。

### 第六步：检查改动内容

提交前在 UGit 中逐个看变更文件：

- 是否只包含本次目标；
- 是否意外修改大量乱码或换行；
- 是否出现个人盘符、用户名、临时输出路径；
- 是否出现 `.max` 测试场景；
- 是否误改第三方作者信息。

### 第七步：用一句能看懂的话提交

例如：

```text
fix: 修复查看导出工具找不到脚本
ui: 调整 FBX 批量导出按钮文字
refactor: 将查看导出工具移动到 export 目录
docs: 补充 FBX 导出使用说明
```

一个提交只处理一个主题。出问题时，优先使用 Git 的“Revert/还原这个提交”生成反向提交，不要在不理解的情况下强制重置历史。

## 8. 三个核心工具的建议接手顺序

### 第一步：先熟悉 `AnimTools.ms`

暂时不修改业务逻辑，只完成这些练习：

1. 能运行并打开主面板；
2. 能从按钮找到对应的 `on ... pressed`；
3. 能从工具编号找到注册表中的真实文件；
4. 修改一个无风险按钮的显示文字；
5. 修改后重新运行并确认界面变化。

这一步能帮助你理解“界面—事件—函数/子脚本”的关系。

### 第二步：熟悉 `FBX批量导出.ms`

先只画出流程，不急着改：

```text
选择文件夹 -> 收集 Max 文件 -> 选择输出目录
-> 打开一个文件 -> 选择导出对象 -> 导出 FBX -> 处理下一个文件
```

优先补强的内容是：预览将要处理的文件、明确输出位置、避免覆盖、单文件日志、失败后继续或停止。不要一开始就重写整个界面。

### 第三步：最后处理 `查看合并导出插件.ms`

它代码较长，而且包含批量打开、合并、删除、保存等操作。建议按下面顺序：

1. 单独做编码转换，并确认中文内容没有变化；
2. 标记所有 `loadMaxFile`、`mergeMAXFile`、`saveMaxFile` 和 `exportFile`；
3. 给危险入口增加预检和确认；
4. 改成默认另存到输出目录；
5. 增加日志；
6. 最后才整理重复函数和界面。

## 9. 常见报错怎么判断

### `GameHelper registry was not found`

含义：`AnimTools.ms` 旁边没有找到 `modules/CGH_ToolRegistry.ms`。

检查：

- 是否只复制了 `AnimTools.ms`，没有复制 `modules` 文件夹；
- 是否把注册表改名；
- `AnimTools.ms` 是否还在 `scripts` 目录。

### `GameHelper tool is not registered`

含义：按钮使用了一个注册表中不存在的 `#工具编号`。

检查按钮事件、注册表和测试数组中的编号拼写是否完全一致。

### `GameHelper script was not found`

含义：编号已经登记，但登记路径上没有文件。

检查文件是否改名、移动，或注册表相对路径是否写错。

### `Unknown property`、`undefined` 或函数找不到

可能原因：

- `HYW_Scripts_Library.ms` 没有成功加载；
- `HYW_Scripts_Library.ms` 提示某个 modules 文件不存在；
- 公共函数名被修改；
- 运行了单独代码片段，但没有先运行完整入口；
- 脚本前面已经报错，后面没有继续执行。

先看 Listener 中最早出现的红色报错，不要只看最后一条。

### 中文乱码

先不要直接全选后另存。先复制文件做备份，确认原编码，再单独进行编码转换。编码转换应作为独立提交，不要同时修改逻辑。

### 点击按钮没有反应

依次检查：

1. Listener 有没有报错；
2. `on 按钮名 pressed` 是否与按钮内部名一致；
3. 工具编号是否登记；
4. 路径是否存在；
5. 子脚本是否只定义界面但没有执行 `CreateDialog`；
6. 界面是否已经在屏幕外或被其他窗口遮挡。

## 10. 当前已知但本轮未处理的问题

- `查看合并导出插件.ms` 仍是旧编码，中文在现代编辑器中可能显示乱码。
- `AnimTools.ms` 的“工具书”按钮仍写有本机绝对路径 `D:\3dsmax-2021.1-maxscript-help-chm\maxscript-2021.chm`，换电脑可能失效。
- `FBX转Bip` 按钮事件中的孤立旧代码 `1` 已在目录整理时移除。
- 主面板和常用按钮已完成交互式冒烟测试；移动目录后仍需复测受影响的子工具按钮。
- `.mse` 是加密或不透明产物，不适合当作可维护源码直接修改。

这些问题应该分别建立小任务、分别测试、分别提交。

## 11. 你现在最适合做的第一个练习

先不要碰批量导出和自动保存。建议只做下面这一项：

1. 运行 `AnimTools.ms`，截一张当前面板图；
2. 在代码里找到一个无风险按钮；
3. 只修改它的中文显示文字；
4. 保存并重新运行；
5. 确认按钮文字变化；
6. 在 UGit 中只检查这一处差异；
7. 提交为 `ui: 调整动作工具按钮文字`。

完成这一步后，再练习“从按钮编号找到子脚本”。不需要先读懂一千多行旧代码。

## 12. 每次修改前后的简短清单

修改前：

- [ ] 本次只解决一个问题
- [ ] Git 中没有混入不相关改动
- [ ] 正式 `.max` 已备份，测试使用副本
- [ ] 知道按钮对应的是公共函数还是子脚本

修改后：

- [ ] 主面板可以重新打开
- [ ] 本次涉及的按钮可以工作
- [ ] Listener 没有新增红色报错
- [ ] 没有新增个人绝对路径
- [ ] 没有覆盖测试场景原件
- [ ] `tests/test_scenes/*.max` 没有进入提交
- [ ] 提交说明能直接看懂改了什么

只要坚持“小目标、小改动、先测试、再提交”，即使暂时不熟悉 MAXScript，也可以安全地重新接手这些工具。
