import XCTest
import CommandArguments

class OptionalTests: XCTestCase {

    static let allTests = [
        ("testOptionalOperand", testOptionalOperand),
        ("testOptionalStringOption", testOptionalStringOption),
    ]

    func testOptionalOperand() {
        struct TestArgs: CommandArguments {
            var a = Operand()
            var b = OptionalOperand()
        }
        
        var args1 = TestArgs()
        try! args1.parse(["1"])
        XCTAssertNil(args1.b.value)
        
        var args2 = TestArgs()
        try! args2.parse(["1", "2"])
        XCTAssertEqual(args2.b.value, "2")
    }
    
    func testOptionalStringOption() {
        struct TestArgs: CommandArguments {
            var a = Option()
            var b = OptionalOption()
        }
        
        var args1 = TestArgs()
        try! args1.parse(["-a=x"])
        XCTAssertNil(args1.b.value)
        
        var args2 = TestArgs()
        try! args2.parse(["-a=x", "-b"])
        XCTAssertNil(args2.b.value)
        
        var args3 = TestArgs()
        try! args3.parse(["-a=x", "-b="])
        XCTAssertNil(args3.b.value)
        
        var args4 = TestArgs()
        try! args4.parse(["-a=x", "-b=4"])
        XCTAssertEqual(args4.b.value, "4")
        
        var args5 = TestArgs()
        try! args5.parse(["-a=x", "-b", "5"])
        XCTAssertEqual(args5.b.value, "5")
    }

}
