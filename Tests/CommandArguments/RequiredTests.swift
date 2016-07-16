import XCTest
import CommandArguments

class RequiredTests: XCTestCase {

    func testOption() {
        struct TestArgs: CommandArguments {
            var a = Option(longName: "aa")
            var b = Option(longName: "bb")
            
            var cc = Option(shortName: "c")
            var dd = Option(shortName: "d")
        }
        
        var args = TestArgs()
        try! args.parse([
            "--aa", "xx", "--bb=yy",
            "-c", "x", "-d=y"
        ])
        
        XCTAssertEqual(args.a.value, "xx")
        XCTAssertEqual(args.b.value, "yy")
        
        XCTAssertEqual(args.cc.value, "x")
        XCTAssertEqual(args.dd.value, "y")
    }
    
    func testOptionThrows() {
        struct TestArgs: CommandArguments {
            var a = Option()
        }
        
        var args = TestArgs()
        do {
            try args.parse([])
            XCTFail("no error throws")
        } catch ParseError.missing(_) {
        } catch {
            XCTFail("wrong error type \(error)")
        }
    }

    func testOperand() {
        struct TestArgs: CommandArguments {
            var a = Operand()
            var b = Operand()
        }
        
        var args = TestArgs()
        try! args.parse(["x", "y"])
        
        XCTAssertEqual(args.a.value, "x")
        XCTAssertEqual(args.b.value, "y")
    }
    
    func testOperandThrows() {
        struct TestArgs: CommandArguments {
            var a = Operand()
            var b = Operand()
        }
        
        var args1 = TestArgs()
        do {
            try args1.parse([])
            XCTFail("no error throws")
        } catch ParseError.missing(_) {
        } catch {
            XCTFail("wrong error type \(error)")
        }
        
        var args2 = TestArgs()
        do {
            try args2.parse(["x"])
            XCTFail("no error throws")
        } catch ParseError.missing(_) {
        } catch {
            XCTFail("wrong error type \(error)")
        }
        
        var args3 = TestArgs()
        try! args3.parse(["x", "y"])
    }
    
}
