import XCTest
import CommandArguments

class ArgumentTests: XCTestCase {
    
    func testDefaultNames() {
        struct TestArgs: CommandArguments {
            var a = RequiredOperand()
            var b = RequiredOperand()
        }
        
        var args = TestArgs()
        try! args.parse(["x", "y"])
        
        XCTAssertEqual(args.a.name, "a")
        XCTAssertEqual(args.b.name, "b")
    }
    
    func testDuplicatedNames() {
        struct TestArgs: CommandArguments {
            var a = RequiredOperand(name: "b")
            var b = RequiredOperand(name: "b")
        }
        var args = TestArgs()
        do {
            try args.parse([])
            XCTFail()
        } catch TypeError.duplicatedOperandName(_) {
        } catch { XCTFail() }
    }

    func testRequiredArgument() {
        struct TestArgs: CommandArguments {
            var a = RequiredOperand()
            var b = RequiredOperand()
        }
        
        var args = TestArgs()
        try! args.parse(["x", "y"])
        
        XCTAssertEqual(args.a.value, "x")
        XCTAssertEqual(args.b.value, "y")
    }
    
    func testRequiredArgumentThrows() {
        struct TestArgs: CommandArguments {
            var a = RequiredOperand()
        }
        
        var args = TestArgs()
        do {
            try args.parse([])
            XCTFail()
        } catch ParseError.missingRequiredOperand(_) {
        } catch { XCTFail() }
    }
    
    func testMissingArguments() {
        struct TestArgs: CommandArguments {
            var a = RequiredOperand()
            var b = RequiredOperand()
        }
        
        var args = TestArgs()
        do {
            try args.parse(["1"])
            XCTFail()
        } catch ParseError.missingRequiredOperand(_) {
        } catch { XCTFail() }
    }
    
    func testTrailingArgument() {
        struct TestArgs: CommandArguments {
            var a = VariadicOperand()
            var b = RequiredOperand()
        }
        
        var args = TestArgs()
        try! args.parse(["1", "2", "3", "4"])
        XCTAssertEqual(args.a.value, ["1", "2", "3"])
        XCTAssertEqual(args.b.value, "4")
    }
    
    func testTrailingMultiArgument() {
        struct TestArgs: CommandArguments {
            var a = VariadicOperand()
            var b = MultiOperand(count: 2)
        }
        
        var args = TestArgs()
        try! args.parse(["1", "2", "3", "4"])
        XCTAssertEqual(args.a.value, ["1", "2"])
        XCTAssertEqual(args.b.value, ["3", "4"])
    }
    
}
