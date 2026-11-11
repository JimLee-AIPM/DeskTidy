# DeskTidy 正式版（完整版）

这个文件夹放正式版（完整版）的说明。源码在仓库根目录（`Sources/` 等），和 App Store 版共用同一份。

## 这个版本是什么

- 功能完整：一键清理、一键恢复、工作场景、番茄钟、快捷键，**加上**在面板里直接退出其他应用、"很久没用的应用"提醒。
- 发布渠道：GitHub 仓库 DeskTidy-Release 的 Releases（https://github.com/JimLee-AIPM/DeskTidy-Release），免费下载。
- 不经过 App Store，不受沙盒限制。

## 当前状态

安装包不放在源码仓库里，打好后发布到 DeskTidy-Release 的 Releases。目前还没有发布。

## 怎么打安装包

在终端运行：

```bash
./scripts/package-release.sh
```

会生成 `build/DeskTidy（测试版）.dmg`，上传到 DeskTidy-Release 的 Releases。

- 没有 Developer ID 证书：也能打，但别人第一次打开要到"系统设置 → 隐私与安全性"里点"仍要打开"。
- 有 Developer ID Application 证书（推荐）：签名并公证后，别人双击就能打开。命令见源码仓库 README 的"打包"一节。

## 只装到自己电脑上

```bash
./scripts/build-app.sh
```

装到"应用程序"文件夹，功能和完整版一样。
