import XCTest
import CommandArguments

class DefaultedTests: XCTestCase {

    static let allTests = [
        ("testDefaultedOperand", testDefaultedOperand),
        ("testDefaultedStringOption", testDefaultedStringOption),
    ]

    func testDefaultedOperand() {
        struct TestArgs: CommandArguments {
            var a = Operand()
            var b = DefaultedOperand("x")
        }
        
        var args1 = TestArgs()
        try! args1.parse(["1"])
        XCTAssertEqual(args1.b.value, "x")
        
        var args2 = TestArgs()
        try! args2.parse(["1", "2"])
        XCTAssertEqual(args2.b.value, "2")
    }
    
    func testDefaultedStringOption() {
        struct TestArgs: CommandArguments {
            var a = Option()
            var b = DefaultedOption("y")
        }
        
        var args1 = TestArgs()
        try! args1.parse(["-a=x"])
        XCTAssertEqual(args1.b.value, "y")
        
        var args2 = TestArgs()
        try! args2.parse(["-a=x", "-b"])
        XCTAssertEqual(args1.b.value, "y")
        
        var args3 = TestArgs()
        try! args3.parse(["-a=x", "-b="])
        XCTAssertEqual(args1.b.value, "y")
        
        var args4 = TestArgs()
        try! args4.parse(["-a=x", "-b=4"])
        XCTAssertEqual(args4.b.value, "4")
        
        var args5 = TestArgs()
        try! args5.parse(["-a=x", "-b", "5"])
        XCTAssertEqual(args5.b.value, "5")
    }

    
}
