import XCTest
import CommandArguments

class MultiplepleTests: XCTestCase {

    func testMultipleOperand() {
        struct TestArgs: CommandArguments {
            var a = MultipleOperand(count: 2)
            var b = MultipleOperand(count: 3)
        }
        
        var args = TestArgs()
        try! args.parse(["1", "2", "3", "4", "5"])
        
        XCTAssertEqual(args.a.value, ["1", "2"])
        XCTAssertEqual(args.b.value, ["3", "4", "5"])
    }
    
    func testMultipleOptionThrows() {
        struct TestArgs: CommandArguments {
            var a = MultipleOption(count: 3)
            var b = Option()
        }
        
        // Less than count
        [
            ["-a"],
            ["-a", "1"],
            ["-a", "1", "2", "-b", "x"]
        ].forEach {
            var args = TestArgs()
            do {
                try args.parse($0)
                XCTFail("no error throws")
            } catch ParseError.missing(_) {
            } catch {
                XCTFail("wrong error type \(error)")
            }
        }
        
        // More than count
        var args = TestArgs()
        do {
            try args.parse(["-a", "1", "2", "3", "4", "-b", "x"])
            XCTFail("no error throws")
        } catch ParseError.invalidOperand(_) {
        } catch {
            XCTFail("wrong error type \(error)")
        }
    }
    
    func testMultipleOption() {
        struct TestArgs: CommandArguments {
            var a = MultipleOption(count: 2)
            var b = MultipleOption(count: 3)
        }
        
        var args = TestArgs()
        try! args.parse([
            "-a", "1", "2",
            "-b=3", "4", "5"
        ])
        
        XCTAssertEqual(args.a.value, ["1", "2"])
        XCTAssertEqual(args.b.value, ["3", "4", "5"])
    }
    
    func testMultipleOperandThrows() {
        struct TestArgs: CommandArguments {
            var a = MultipleOperand(count: 2)
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
            try args2.parse(["1"])
            XCTFail("no error throws")
        } catch ParseError.missing(_) {
        } catch {
            XCTFail("wrong error type \(error)")
        }
        
        var args3 = TestArgs()
        try! args3.parse(["1", "2"])
        
        var args4 = TestArgs()
        do {
            try args4.parse(["1", "2", "3"])
            XCTFail("no error throws")
        } catch ParseError.invalidOperand(_) {
        } catch {
            XCTFail("wrong error type \(error)")
        }
    }
    
}
