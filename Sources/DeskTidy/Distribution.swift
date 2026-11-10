/// 不同发行渠道的功能差异。
///
/// App Store 版必须开 App 沙盒，沙盒里不能退出别的应用（NSRunningApplication.terminate() 直接返回 false，
/// 见苹果文档）。按钮留着却点了没反应，审核会按"功能不可用"拒绝，所以 App Store 版把退出相关的界面整个藏起来，
/// 只保留收起/恢复。自己用（build-app.sh）和发 dmg（package-release.sh）的版本不受影响。
///
/// App Store 版由 scripts/package-appstore.sh 用 `-Xswiftc -DAPP_STORE` 编译。
enum Distribution {
#if APP_STORE
    static let canQuitOtherApps = false
#else
    static let canQuitOtherApps = true
#endif
}
