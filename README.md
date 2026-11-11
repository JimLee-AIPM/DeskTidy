# DeskTidy

Mac 菜单栏小工具：一键收起眼前用不到的应用，让屏幕只留下此刻要用的。

当前版本：**1.0.0**　·　系统要求：macOS 13 或更高版本（Apple 芯片和 Intel 芯片都支持）

## 能做什么

- **一键清理**：一个快捷键（默认 ⌥⌘K，可自定义），把用不到的应用收起来。只隐藏，不关闭，应用在后台照常运行。
- **一键恢复**：把刚才收起的应用全部放回原处。
- **工作场景**：每个场景记着清理时要保留哪些应用，内置"AI 工作""做设计""开会"三个，可以自己增删。
- **番茄钟**：专注时屏幕角落有小时钟，到点提醒休息，休息时毛玻璃铺满屏幕，随时可以跳过。
- **外观**：浅色、深色跟随系统，也可以在圆盘上自选底色。

DeskTidy 不联网，不收集任何数据，详见[隐私政策](https://github.com/JimLee-AIPM/DeskTidy-Release/blob/main/PRIVACY.md)。

## 下载

安装包、版本区别和问题反馈都在 [DeskTidy-Release](https://github.com/JimLee-AIPM/DeskTidy-Release)。

DeskTidy 有两个版本，核心功能一样：

| | App Store 版 | 完整版 |
| --- | :---: | :---: |
| 一键清理、一键恢复、工作场景、番茄钟 | ✓ | ✓ |
| 在面板里直接退出其他应用 | — | ✓ |
| "很久没用的应用"提醒 | — | ✓ |

App Store 要求应用运行在沙盒里，沙盒不允许一个应用退出其他应用，所以后两项只有完整版有（见 `Sources/DeskTidy/Distribution.swift`）。

## 许可证

源码公开，但**仅限非商业使用**，采用 [PolyForm Noncommercial 1.0.0](LICENSE.md)。商业使用请先联系作者获得授权。

`Vendor/KeyboardShortcuts` 是第三方开源库，仍按它自己的 MIT 许可证发布。

---

## 开发

需要 Xcode 15.3 或更高版本。第一次使用时，让终端用 Xcode 自带的工具：

```bash
sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -license accept
```

快捷键库 KeyboardShortcuts 已放在 `Vendor/` 里，不需要联网下载。

### 装到自己的电脑上

```bash
./scripts/build-app.sh
```

编译、打包出 `DeskTidy.app`，装进"应用程序"文件夹并启动。改了代码后重新运行即可更新。

### 打包

| 命令 | 用途 | 产物 |
| --- | --- | --- |
| `./scripts/package-release.sh` | 完整版安装包，发给别人或放到 Releases | `build/DeskTidy（测试版）.dmg` |
| `./scripts/package-appstore.sh` | App Store 版（开启 App 沙盒） | `build/appstore/DeskTidy.app`，有证书时另有 `.pkg` |

**完整版签名与公证**：没有开发者证书时用临时签名，对方第一次打开需要在"系统设置 → 隐私与安全性"里点"仍要打开"。有 "Developer ID Application" 证书时：

```bash
xcrun notarytool store-credentials desktidy --apple-id 你的AppleID --team-id 团队ID
DEVELOPER_ID="Developer ID Application: 你的名字 (团队ID)" NOTARY_PROFILE=desktidy ./scripts/package-release.sh
```

**App Store 版**：钥匙串里有 "Apple Distribution" 和 "Mac Installer Distribution" 证书时，会生成可以拖进 Transporter 上传的 `build/appstore/DeskTidy-版本号.pkg`；没有证书时只生成本地签名的 `.app`，可以先双击自测。构建号按打包时间自动生成，每次上传递增。Bundle ID 读 `Packaging/Info.plist`，要换就用 `BUNDLE_ID=新ID ./scripts/package-appstore.sh`。

版本号写在 `Sources/DeskTidyCore/AppInfo.swift` 的 `AppInfo.version`，打包时会写进安装包。

### 开发时直接运行

```bash
swift run DeskTidy
```

这种方式启动的 DeskTidy 挂在终端下面，关掉终端它也会退出。也可以 `open Package.swift` 用 Xcode 打开，选 `DeskTidy` 和 `My Mac` 后点运行。

### 运行测试

```bash
swift test
```

看到 `Executed N tests, with 0 failures` 即为通过。

### 应用图标

原图是 `Packaging/AppIcon.png`，由 `scripts/make-icon.py` 画出（需要 `pip install pillow`），打包时自动转成 Mac 图标格式。

### 目录结构

```text
Package.swift              项目配置：名字、支持的系统版本、依赖库
Sources/
  DeskTidy/                应用本体：菜单栏图标、面板、设置窗口、番茄钟界面
    Distribution.swift     App Store 版和完整版的功能差别
    Views/                 界面
  DeskTidyCore/            核心逻辑：清理规则、场景、番茄钟计时、数据存储（不含界面）
Tests/DeskTidyCoreTests/   核心逻辑的自动测试
Vendor/KeyboardShortcuts/  快捷键库（MIT，改了一处资源查找位置，见其中的 README）
Packaging/                 Info.plist、沙盒配置、图标原图、安装说明
scripts/                   安装和打包脚本
docs/                      需求文档、技术方案、任务清单
```
