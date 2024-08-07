import XCTest
@testable import SystemSound

final class SystemSoundTests: XCTestCase {
    override class func setUp() {
        super.setUp()
        SystemSound.global.load()
    }

    func testToggleMuted() throws {
        let old = SystemSound.global.value.muted
        SystemSound.global.value.muted.toggle()
        let new = SystemSound.global.value.muted
        XCTAssertNotEqual(old, new)
    }

    func testIncreaseVolume() throws {
        let old = SystemSound.global.value.volume
        SystemSound.global.increaseVolume()
        let new = SystemSound.global.value.volume
        XCTAssertLessThanOrEqual(old, new)
    }

    func testDecreaseVolume() throws {
        let old = SystemSound.global.value.volume
        SystemSound.global.decreaseVolume()
        let new = SystemSound.global.value.volume
        XCTAssertGreaterThanOrEqual(old, new)
    }
}
