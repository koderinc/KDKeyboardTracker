import XCTest
@testable import KDKeyboardTracker

final class KDKeyboardTrackerTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(KDKeyboardTracker().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
