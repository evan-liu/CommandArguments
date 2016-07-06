import XCTest
@testable import CommandArguments

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
    
}
