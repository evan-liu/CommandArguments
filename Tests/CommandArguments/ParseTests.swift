import XCTest
import CommandArguments

class ParseTests: XCTestCase {

    static let allTests = [
        ("testCombinedShortOptions", testCombinedShortOptions),
        ("testOptionStopper", testOptionStopper),
    ]

    func testCombinedShortOptions() {
        struct TestArgs: CommandArguments {
            var a = Flag()
            var b = Flag()
            var c = Option()
            var d = Flag()
        }
        
        var args1 = TestArgs()
        try! args1.parse("-abc x")
        
        XCTAssertTrue(args1.a.value)
        XCTAssertTrue(args1.b.value)
        XCTAssertEqual(args1.c.value, "x")
        XCTAssertFalse(args1.d.value)
        
        var args2 = TestArgs()
        try! args2.parse("-ab -c x")
        
        XCTAssertTrue(args2.a.value)
        XCTAssertTrue(args2.b.value)
        XCTAssertEqual(args2.c.value, "x")
        XCTAssertFalse(args2.d.value)
    }
    
    func testOptionStopper() {
        struct TestArgs: CommandArguments {
            var a = OptionalOption()
            var b = Operand()
        }
        
        var args1 = TestArgs()
        try! args1.parse("-a -- -x")
        
        XCTAssertNil(args1.a.value)
        XCTAssertEqual(args1.b.value, "-x")
    }

}
