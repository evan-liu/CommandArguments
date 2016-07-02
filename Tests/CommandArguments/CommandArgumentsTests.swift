import XCTest
@testable import CommandArguments

class CommandArgumentsTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        XCTAssertEqual(CommandArguments().text, "Hello, World!")
    }


    static var allTests : [(String, (CommandArgumentsTests) -> () throws -> Void)] {
        return [
            ("testExample", testExample),
        ]
    }
}
