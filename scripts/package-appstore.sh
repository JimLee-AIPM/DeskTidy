#!/bin/bash
# 做成 App Store 上架用的版本：build/appstore/DeskTidy.app，有证书时再加上 build/appstore/DeskTidy-<版本>.pkg
#
# 和 package-release.sh（发 dmg）的区别：
#   - 开启 App 沙盒（App Store 强制要求）
#   - 用 APP_STORE 编译开关藏起"退出别的应用"相关界面（沙盒里做不到，见 Sources/DeskTidy/Distribution.swift）
#   - 用 App Store 证书签名，打成 .pkg（用 Transporter 上传）
#
# 证书：钥匙串里有 "Apple Distribution" 和 "Mac Installer Distribution" 时自动使用，生成可上传的 .pkg。
#      没有时也能跑完，只生成格式正确、本地签名的 .app（可以双击自测），不生成 .pkg。
# 可选环境变量：
#   BUNDLE_ID   默认读 Packaging/Info.plist 里的（现在是 com.desktidy.app），要和 App Store Connect 里建的 App 一致
#   BUILD       构建号，每次上传必须比上次大，默认用当前时间自动递增
# 可选文件：Packaging/embedded.provisionprofile（要用 TestFlight 时放进去，会自动嵌入）
set -euo pipefail

cd "$(dirname "$0")/.."
EXTRA_BUILD_FLAGS="-Xswiftc -DAPP_STORE --scratch-path .build-appstore"
source scripts/lib/make-app.sh

BUNDLE_ID="${BUNDLE_ID:-$(/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' Packaging/Info.plist)}"
BUILD="${BUILD:-$(date +%Y%m%d%H%M)}"
ENT="Packaging/DeskTidy-AppStore.entitlements"
OUT="build/appstore"

say() { printf "\n\033[1;34m▶ %s\033[0m\n" "$1"; }
die() { printf "\n\033[1;31m✖ %s\033[0m\n" "$1"; exit 1; }

say "查找 App Store 签名证书"
APP_SIGN=$(security find-identity -v -p codesigning | grep -E '"(Apple Distribution|3rd Party Mac Developer Application):' | head -1 | sed -E 's/.*"(.*)"/\1/' || true)
PKG_SIGN=$(security find-identity -v | grep -E '"(3rd Party Mac Developer Installer|Mac Installer Distribution):' | head -1 | sed -E 's/.*"(.*)"/\1/' || true)
if [ -n "$APP_SIGN" ] && [ -n "$PKG_SIGN" ]; then
    RELEASE=1
    echo "  App 签名：$APP_SIGN"
    echo "  安装包签名：$PKG_SIGN"
else
    RELEASE=0
    echo "  没找到 App Store 证书 → 这次只生成格式正确的 DeskTidy.app（本地签名），不生成 .pkg"
    echo "  以后在 Xcode → Settings → Apple Accounts 登录，Manage Certificates 里添加"
    echo "  Apple Distribution 和 Mac Installer Distribution，再跑本脚本即可"
fi

say "编译 App Store 版（苹果芯片 + Intel）"
make_app universal

# App Store 版的应用信息：Bundle ID、构建号
/usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier $BUNDLE_ID" "$APP/Contents/Info.plist"
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $BUILD" "$APP/Contents/Info.plist"
printf "APPL????" > "$APP/Contents/PkgInfo"

rm -rf "$OUT"
mkdir -p "$OUT"
mv "$APP" "$OUT/DeskTidy.app"
APP="$OUT/DeskTidy.app"

if [ -f Packaging/embedded.provisionprofile ]; then
    say "嵌入描述文件"
    cp Packaging/embedded.provisionprofile "$APP/Contents/embedded.provisionprofile"
    TEAM_ID=$(security cms -D -i Packaging/embedded.provisionprofile | plutil -extract TeamIdentifier.0 raw -)
    ENT_WITH_ID="$(mktemp -d)/DeskTidy.entitlements"
    cp "$ENT" "$ENT_WITH_ID"
    plutil -insert com.apple.application-identifier -string "$TEAM_ID.$BUNDLE_ID" "$ENT_WITH_ID"
    plutil -insert com.apple.developer.team-identifier -string "$TEAM_ID" "$ENT_WITH_ID"
    ENT="$ENT_WITH_ID"
fi

if [ "$RELEASE" = 1 ]; then
    say "签名（App Store 证书 + App 沙盒）"
    for bundle in "$APP"/Contents/Resources/*.bundle; do
        [ -e "$bundle" ] && codesign --force --timestamp --sign "$APP_SIGN" "$bundle"
    done
    codesign --force --timestamp --options runtime --entitlements "$ENT" --sign "$APP_SIGN" "$APP"
else
    say "签名（本地签名 + App 沙盒）"
    for bundle in "$APP"/Contents/Resources/*.bundle; do
        [ -e "$bundle" ] && codesign --force --sign - "$bundle"
    done
    codesign --force --options runtime --entitlements "$ENT" --sign - "$APP"
fi
codesign --verify --strict --deep "$APP"
codesign -d --entitlements - "$APP" 2>/dev/null | grep -q app-sandbox || die "沙盒权限没写进签名"

if [ "$RELEASE" = 1 ]; then
    PKG="$OUT/DeskTidy-$VERSION.pkg"
    say "生成上传用安装包"
    productbuild --component "$APP" /Applications --sign "$PKG_SIGN" "$PKG"
    pkgutil --check-signature "$PKG" | head -3
fi

say "完成 ✅"
echo "  App：$(pwd)/$APP"
[ "$RELEASE" = 1 ] && echo "  上传用安装包：$(pwd)/$PKG（拖进 Transporter 即可）"
echo "  版本 $VERSION，构建号 $BUILD，Bundle ID $BUNDLE_ID"
echo "  支持的芯片：$(lipo -archs "$APP/Contents/MacOS/DeskTidy")"
open "$OUT"
