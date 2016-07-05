import XCTest
@testable import CommandArguments

class CommandArgumentsTests: XCTestCase {
    
    func testStringOption() {
        struct TestArgs: CommandArguments {
            var a = StringOption(longName: "a")
            var c = StringOption(longName: "c")
        }
        
        var args = TestArgs()
        try! args.parse(args: ["--a", "b", "--c=d"])
        
        XCTAssertEqual(args.a.value, "b")
        XCTAssertEqual(args.c.value, "d")
    }
    
}
