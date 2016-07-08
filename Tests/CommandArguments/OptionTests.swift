import XCTest
import CommandArguments

class OptionTests: XCTestCase {
    
    func testDefaultNames() {
        struct TestArgs: CommandArguments {
            var a = BoolOption()
            var bb = BoolOption()
            var c = StringOption()
            var dd = StringOption()
        }
        
        var args = TestArgs()
        try! args.parse([
            "-a", "--bb",
            "-c", "x", "--dd=y"
            ])
        
        XCTAssertTrue(args.a.value)
        XCTAssertTrue(args.bb.value)
        
        XCTAssertEqual(args.c.value, "x")
        XCTAssertEqual(args.dd.value, "y")
    }
    
    func testDuplicatedNames() {
        struct LongNames: CommandArguments {
            var a = BoolOption(longName: "xx")
            var b = BoolOption(longName: "xx")
        }
        var longArgs = LongNames()
        do {
            try longArgs.parse([])
            XCTFail()
        } catch TypeError.duplicatedOptionName(_) {
        } catch { XCTFail() }
        
        struct ShortNames: CommandArguments {
            var a = BoolOption(shortName: "x")
            var b = BoolOption(shortName: "x")
        }
        var shortArgs = ShortNames()
        do {
            try shortArgs.parse([])
            XCTFail()
        } catch TypeError.duplicatedOptionName(_) {
        } catch { XCTFail() }
    }
    
    func testInvalidShortOptionName() {
        struct Args1: CommandArguments {
            var a = BoolOption(shortName: "1")
        }
        struct Args2: CommandArguments {
            var a = BoolOption(shortName: "")
        }
        struct Args3: CommandArguments {
            var a = BoolOption(shortName: " ")
        }
        
        var args1 = Args1()
        do {
            try args1.parse([])
            XCTFail()
        } catch TypeError.invalidShortOptionName(_) {
        } catch { XCTFail() }
        
        var args2 = Args2()
        do {
            try args2.parse([])
            XCTFail()
        } catch TypeError.invalidShortOptionName(_) {
        } catch { XCTFail() }
        
        var args3 = Args3()
        do {
            try args3.parse([])
            XCTFail()
        } catch TypeError.invalidShortOptionName(_) {
        } catch { XCTFail() }
    }
    
    func testNoNames() {
        struct TestArgs: CommandArguments {
            var a = StringOption(shortName: "b")
            var b = StringOption()
        }
        
        var args = TestArgs()
        do {
            try args.parse([])
            XCTFail()
        } catch TypeError.missingOptionName(_) {
        } catch {
            XCTFail("Wrong error type \(error)")
        }
    }
    
    func testOptionStopper() {
        struct TestArgs: CommandArguments {
            var a = BoolOption()
            var b = VariadicArgument()
        }
        
        var args = TestArgs()
        try! args.parse(["-a", "--", "-1", "-2", "-3"])
        XCTAssertTrue(args.a.value)
        XCTAssertEqual(args.b.value, ["-1", "-2", "-3"])
    }
    
    func testInvalidOption() {
        struct TestArgs: CommandArguments {
            var a = StringOption()
        }
        
        var args = TestArgs()
        do {
            try args.parse(["-a=b", "-c"])
            XCTFail()
        } catch ParseError.invalidOption(_) {
        } catch {
            XCTFail()
        }

    }
}
