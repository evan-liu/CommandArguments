import XCTest
@testable import CommandArguments

class CommandArgumentsTests: XCTestCase {
    
    // ----------------------------------------
    // MARK: Operand Names
    // ----------------------------------------
    func testOperandDefaultNames() {
        struct TestArgs: CommandArguments {
            var a = Operand()
            var b = Operand()
        }
        
        var args = TestArgs()
        try! args.parse(["x", "y"])
        
        XCTAssertEqual(args.a.name, "a")
        XCTAssertEqual(args.b.name, "b")
    }
    
    func testOperandDuplicatedNames() {
        struct TestArgs: CommandArguments {
            var a = Operand(name: "b")
            var b = Operand(name: "b")
        }
        var args = TestArgs()
        do {
            try args.parse([])
            XCTFail("should throw error")
        } catch TypeError.duplicatedOperandName(_) {
        } catch { XCTFail() }
    }
    
    // ----------------------------------------
    // MARK: Option Names
    // ----------------------------------------
    func testDefaultNames() {
        struct TestArgs: CommandArguments {
            var a = Option()
            var bb = Option()
        }
        
        var args = TestArgs()
        try! args.parse("-a x --bb y")
        
        XCTAssertEqual(args.a.name.short, "a")
        XCTAssertEqual(args.bb.name.long, "bb")
    }
    
    func testDuplicatedNames() {
        struct LongNames: CommandArguments {
            var a = Option(longName: "xx")
            var b = Option(longName: "xx")
        }
        var longArgs = LongNames()
        do {
            try longArgs.parse([])
            XCTFail()
        } catch TypeError.duplicatedOptionName(_) {
        } catch { XCTFail() }
        
        struct ShortNames: CommandArguments {
            var a = Option(shortName: "x")
            var b = Option(shortName: "x")
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
            var a = Option(shortName: "1")
        }
        struct Args2: CommandArguments {
            var a = Option(shortName: "")
        }
        struct Args3: CommandArguments {
            var a = Option(shortName: " ")
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
            var a = Option(shortName: "b")
            var b = Option()
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


}
