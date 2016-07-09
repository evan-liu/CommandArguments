import XCTest
import CommandArguments

class CommandArgumentsTests: XCTestCase {
    struct TestArgs: CommandArguments {
        var a = BoolOption()
        var b = BoolOption()
    }
    
    func testParseArraySlice() {
        let args = ["test", "-a", "-b"]
        
        var args1 = TestArgs()
        try! args1.parse(args.dropFirst())
        XCTAssertTrue(args1.a.value)
        XCTAssertTrue(args1.b.value)
        
        var args2 = TestArgs()
        try! args2.parse(args.dropFirst(2))
        XCTAssertFalse(args2.a.value)
        XCTAssertTrue(args2.b.value)
        
        var args3 = TestArgs()
        try! args3.parse(args.dropFirst(3))
        XCTAssertFalse(args3.a.value)
        XCTAssertFalse(args3.b.value)
    }

    func testParseArray() {
        var args1 = TestArgs()
        try! args1.parse(["test", "-a", "-b"], from: 1)
        XCTAssertTrue(args1.a.value)
        XCTAssertTrue(args1.b.value)
        
        var args2 = TestArgs()
        try! args2.parse(["test", "-a", "-b"], from: 2)
        XCTAssertFalse(args2.a.value)
        XCTAssertTrue(args2.b.value)
        
        var args3 = TestArgs()
        try! args3.parse(["test", "-a", "-b"], from: 3)
        XCTAssertFalse(args3.a.value)
        XCTAssertFalse(args3.b.value)
    }
    
    func testParseString() {
        var args1 = TestArgs()
        try! args1.parse("test -a  -b", from: 1)
        XCTAssertTrue(args1.a.value)
        XCTAssertTrue(args1.b.value)
    }

}
