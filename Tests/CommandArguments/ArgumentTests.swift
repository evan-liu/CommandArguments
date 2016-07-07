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
    
    func testMultiArgument() {
        struct TestArgs: CommandArguments {
            var a = MultiArgument(count: 2)
            var b = MultiArgument(count: 3)
        }
        
        var args = TestArgs()
        try! args.parse(["1", "2", "3", "4", "5"])
        
        XCTAssertEqual(args.a.value, ["1", "2"])
        XCTAssertEqual(args.b.value, ["3", "4", "5"])
    }
    
    func testMultiArgumentThrows() {
        struct TestArgs: CommandArguments {
            var a = MultiArgument(count: 2)
        }
        
        var args1 = TestArgs()
        do {
            try args1.parse(["1"])
            XCTFail()
        } catch ParseError.missingRequiredArgument(_) {
        } catch { XCTFail() }
        
        var args2 = TestArgs()
        do {
            try args2.parse(["1", "2", "3"])
            XCTFail()
        } catch ParseError.invalidArgument(_) {
        } catch { XCTFail() }
    }
    
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
    
    func testVariadicArgument() {
        struct TestArgs: CommandArguments {
            var a = RequiredArgument()
            var b = VariadicArgument()
        }
        
        var args = TestArgs()
        try! args.parse(["1", "2", "3", "4"])
        XCTAssertEqual(args.b.value, ["2", "3", "4"])
    }
    
    func testVariadicArgumentThrows() {
        struct TestArgs: CommandArguments {
            var a = VariadicArgument(minCount: 2, maxCount: 3)
        }
        
        var args1 = TestArgs()
        do {
            try args1.parse(["1"])
            XCTFail()
        } catch ParseError.missingRequiredArgument(_) {
        } catch { XCTFail() }
        
        var args2 = TestArgs()
        do {
            try args2.parse(["1", "2", "3", "4"])
            XCTFail()
        } catch ParseError.invalidArgument(_) {
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
