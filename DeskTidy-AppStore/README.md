# DeskTidy App Store 版

这个文件夹放 App Store 版的上架材料。源码在仓库根目录（`Sources/` 等），和正式版共用同一份。

## 这个版本是什么

- 功能：一键清理、一键恢复、工作场景、番茄钟、快捷键。
- **没有**"退出其他应用"和"很久没用的应用"提醒：App Store 要求沙盒，沙盒不允许退出别的应用。
- 发布渠道：Mac App Store，免费。目标地区：中国大陆、中国香港、中国澳门。

## 文件夹里有什么

| 文件 | 用途 |
| --- | --- |
| `商店截图/` | 5 张商店截图，2880×1800（表格第 16 条） |
| `宣传图/` | 3 张宣传图，2880×1800，也可以当商店截图用 |
| `DeskTidy_资质与素材授权说明.pdf` | 表格第 27 条的附件 |
| `上架资料35条.md` | 上架表格 35 条的最终内容 |

图标用仓库里的 `Packaging/AppIcon.png`（1024×1024）。安装包不放在源码仓库里，用下面的脚本生成。

## 当前状态

- 上架表格 35 条：内容已备齐。
- 安装包：已能打出 `.app`；**还不能上传**，缺两个证书。
- 中国大陆 App 备案：待办理。

## 接下来要做的

1. 在苹果开发者账号里创建 Apple Distribution 和 Mac Installer Distribution 两个证书。
2. 重新打包，生成能上传的 `.pkg`：
   ```bash
   ./scripts/package-appstore.sh
   ```
   产物在 `build/appstore/`。
3. 在 App Store Connect 用 Bundle ID `com.desktidy.app` 创建 App，用 Transporter 上传 `.pkg`。
4. 办理中国大陆 App 备案，拿到备案号后填进 App Store Connect。
5. 填完隐私、年龄分级、出口合规问卷，提交审核。审核通过后手动发布。

注意：每次上传的构建号必须比上一次大，脚本会按打包时间自动生成。
