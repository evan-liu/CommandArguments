import XCTest
@testable import CommandArguments

class CommandArgumentsTests: XCTestCase {
    
    func testBoolOption() {
        struct TestArgs: CommandArguments {
            var a = BoolOption(longName: "a")
            var b = BoolOption(longName: "b")
            var c = BoolOption(longName: "c")
            var d = BoolOption(longName: "d")
        }
        
        var args = TestArgs()
        try! args.parse(args: ["--a", "--b=true", "--c=", "--d=false"])
        XCTAssertTrue(args.a.value)
        XCTAssertTrue(args.b.value)
        XCTAssertFalse(args.c.value)
        XCTAssertFalse(args.d.value)
    }
    
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
