import XCTest
import CommandArguments

class ParameterTests: XCTestCase {
    
    func testDefaultNames() {
        struct TestArgs: CommandArguments {
            var a = RequiredParameter()
            var b = RequiredParameter()
        }
        
        var args = TestArgs()
        try! args.parse(args: ["x", "y"])
        
        XCTAssertEqual(args.a.name, "a")
        XCTAssertEqual(args.b.name, "b")
    }

    func testRequiredParameter() {
        struct TestArgs: CommandArguments {
            var a = RequiredParameter()
            var b = RequiredParameter()
        }
        
        var args = TestArgs()
        try! args.parse(args: ["x", "y"])
        
        XCTAssertEqual(args.a.value, "x")
        XCTAssertEqual(args.b.value, "y")
    }
    
    func testMultiParameter() {
        struct TestArgs: CommandArguments {
            var a = MultiParameter(count: 2)
            var b = MultiParameter(count: 3)
        }
        
        var args = TestArgs()
        try! args.parse(args: ["1", "2", "3", "4", "5"])
        
        XCTAssertEqual(args.a.value, ["1", "2"])
        XCTAssertEqual(args.b.value, ["3", "4", "5"])
    }
    
    func testOptionalParameter() {
        struct TestArgs: CommandArguments {
            var a = RequiredParameter()
            var b = OptionalParameter()
        }
        
        var args1 = TestArgs()
        try! args1.parse(args: ["1"])
        XCTAssertNil(args1.b.value)
        
        var args2 = TestArgs()
        try! args2.parse(args: ["1", "2"])
        XCTAssertEqual(args2.b.value, "2")
    }
    
    func testVariadicParameter() {
        struct TestArgs: CommandArguments {
            var a = RequiredParameter()
            var b = VariadicParameter()
        }
        
        var args = TestArgs()
        try! args.parse(args: ["1", "2", "3", "4"])
        XCTAssertEqual(args.b.value, ["2", "3", "4"])
    }
    
}
