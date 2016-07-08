import XCTest
import CommandArguments

class ArgumentTests: XCTestCase {
    
    func testDefaultNames() {
        struct TestArgs: CommandArguments {
            var a = RequiredArgument()
            var b = RequiredArgument()
        }
        
        var args = TestArgs()
        try! args.parse(["x", "y"])
        
        XCTAssertEqual(args.a.name, "a")
        XCTAssertEqual(args.b.name, "b")
    }
    
    func testDuplicatedNames() {
        struct TestArgs: CommandArguments {
            var a = RequiredArgument(name: "b")
            var b = RequiredArgument(name: "b")
        }
        var args = TestArgs()
        do {
            try args.parse([])
            XCTFail()
        } catch TypeError.duplicatedArgumentName(_) {
        } catch { XCTFail() }
    }

    func testRequiredArgument() {
        struct TestArgs: CommandArguments {
            var a = RequiredArgument()
            var b = RequiredArgument()
        }
        
        var args = TestArgs()
        try! args.parse(["x", "y"])
        
        XCTAssertEqual(args.a.value, "x")
        XCTAssertEqual(args.b.value, "y")
    }
    
    func testRequiredArgumentThrows() {
        struct TestArgs: CommandArguments {
            var a = RequiredArgument()
        }
        
        var args = TestArgs()
        do {
            try args.parse([])
            XCTFail()
        } catch ParseError.missingRequiredArgument(_) {
        } catch { XCTFail() }
    }
    
    func testMissingArguments() {
        struct TestArgs: CommandArguments {
            var a = RequiredArgument()
            var b = RequiredArgument()
        }
        
        var args = TestArgs()
        do {
            try args.parse(["1"])
            XCTFail()
        } catch ParseError.missingRequiredArgument(_) {
        } catch { XCTFail() }
    }
    
    func testTrailingArgument() {
        struct TestArgs: CommandArguments {
            var a = VariadicArgument()
            var b = RequiredArgument()
        }
        
        var args = TestArgs()
        try! args.parse(["1", "2", "3", "4"])
        XCTAssertEqual(args.a.value, ["1", "2", "3"])
        XCTAssertEqual(args.b.value, "4")
    }
    
    func testTrailingMultiArgument() {
        struct TestArgs: CommandArguments {
            var a = VariadicArgument()
            var b = MultiArgument(count: 2)
        }
        
        var args = TestArgs()
        try! args.parse(["1", "2", "3", "4"])
        XCTAssertEqual(args.a.value, ["1", "2"])
        XCTAssertEqual(args.b.value, ["3", "4"])
    }
    
}
