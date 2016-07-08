import XCTest
import CommandArguments

class OptionalStringTests: XCTestCase {

    func testOptionalArgument() {
        struct TestArgs: CommandArguments {
            var a = RequiredArgument()
            var b = OptionalArgument()
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
            var a = StringOption()
            var b = OptionalStringOption()
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
    
    func testOptionalStringOptionDefaultValue() {
        struct TestArgs: CommandArguments {
            var a = OptionalStringOption(default: "x")
        }
        
        var args1 = TestArgs()
        try! args1.parse([])
        XCTAssertEqual(args1.a.value, "x")
        
        var args2 = TestArgs()
        try! args2.parse(["-a", "y"])
        XCTAssertEqual(args2.a.value, "y")
        
        var args3 = TestArgs()
        try! args3.parse(["-a=z"])
        XCTAssertEqual(args3.a.value, "z")
        
        var args4 = TestArgs()
        try! args4.parse(["-a="])
        XCTAssertEqual(args4.a.value, "x")
    }

}
