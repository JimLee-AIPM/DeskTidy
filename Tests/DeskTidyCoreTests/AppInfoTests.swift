import XCTest
@testable import DeskTidyCore

final class AppInfoTests: XCTestCase {
    func testDisplayNameIsSet() {
        XCTAssertEqual(AppInfo.displayName, "DeskTidy")
    }

    func testVersionHasThreeParts() {
        XCTAssertEqual(AppInfo.version.split(separator: ".").count, 3)
    }
}
