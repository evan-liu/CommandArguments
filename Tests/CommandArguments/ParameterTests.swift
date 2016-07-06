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
    
    func testDuplicatedNames() {
        struct TestArgs: CommandArguments {
            var a = RequiredParameter(name: "b")
            var b = RequiredParameter(name: "b")
        }
        var args = TestArgs()
        do {
            try args.parse(args: [])
            XCTFail()
        } catch TypeError.duplicatedParameterName(_) {
        } catch { XCTFail() }
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
    
    func testRequiredParameterThrows() {
        struct TestArgs: CommandArguments {
            var a = RequiredParameter()
        }
        
        var args = TestArgs()
        do {
            try args.parse(args: [])
            XCTFail()
        } catch ParseError.missingRequiredParameter(_) {
        } catch { XCTFail() }
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
    
    func testMultiParameterThrows() {
        struct TestArgs: CommandArguments {
            var a = MultiParameter(count: 2)
        }
        
        var args1 = TestArgs()
        do {
            try args1.parse(args: ["1"])
            XCTFail()
        } catch ParseError.missingRequiredParameter(_) {
        } catch { XCTFail() }
        
        var args2 = TestArgs()
        do {
            try args2.parse(args: ["1", "2", "3"])
            XCTFail()
        } catch ParseError.invalidParameter(_) {
        } catch { XCTFail() }
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
    
    func testVariadicParameterThrows() {
        struct TestArgs: CommandArguments {
            var a = VariadicParameter(minCount: 2, maxCount: 3)
        }
        
        var args1 = TestArgs()
        do {
            try args1.parse(args: ["1"])
            XCTFail()
        } catch ParseError.missingRequiredParameter(_) {
        } catch { XCTFail() }
        
        var args2 = TestArgs()
        do {
            try args2.parse(args: ["1", "2", "3", "4"])
            XCTFail()
        } catch ParseError.invalidParameter(_) {
        } catch { XCTFail() }
    }
    
    func testMissingParameters() {
        struct TestArgs: CommandArguments {
            var a = RequiredParameter()
            var b = RequiredParameter()
        }
        
        var args = TestArgs()
        do {
            try args.parse(args: ["1"])
            XCTFail()
        } catch ParseError.missingRequiredParameter(_) {
        } catch { XCTFail() }
    }
    
}
