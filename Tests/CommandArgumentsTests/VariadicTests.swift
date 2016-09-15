import XCTest
import CommandArguments

class VariadicTests: XCTestCase {

    static let allTests = [
        ("testVariadicOperand", testVariadicOperand),
        ("testVariadicOperandThrows", testVariadicOperandThrows),
        ("testVariadicOption", testVariadicOption),
        ("testVariadicOptionThrows", testVariadicOptionThrows),
    ]

    func testVariadicOperand() {
        struct TestArgs: CommandArguments {
            var a = Operand()
            var b = VariadicOperand()
        }
        
        var args = TestArgs()
        try! args.parse(["1", "2", "3", "4"])
        XCTAssertEqual(args.b.value, ["2", "3", "4"])
    }
    
    func testVariadicOperandThrows() {
        struct TestArgs: CommandArguments {
            var a = VariadicOperand(minCount: 2, maxCount: 3)
        }
        
        var args1 = TestArgs()
        do {
            try args1.parse(["1"])
            XCTFail("no error throws")
        } catch ParseError.missing(_) {
        } catch {
            XCTFail("wrong error type \(error)")
        }
        
        var args2 = TestArgs()
        do {
            try args2.parse(["1", "2", "3", "4"])
            XCTFail("no error throws")
        } catch ParseError.invalidOperand(_) {
        } catch {
            XCTFail("wrong error type \(error)")
        }
    }
    
    func testVariadicOption() {
        struct TestArgs: CommandArguments {
            var a = Option()
            var b = VariadicOption(minCount: 3)
            var c = OptionalOption()
        }
        
        var args = TestArgs()
        try! args.parse(["-a=x", "-b", "1", "-c", "-b", "2", "3"])
        XCTAssertEqual(args.b.value, ["1", "2", "3"])
    }
    
    func testVariadicOptionThrows() {
        struct TestArgs: CommandArguments {
            var a = VariadicOption(minCount: 3, maxCount: 4)
        }
        
        // Less than minCount
        [
            ["-a"],
            ["-a", "1"],
            ["-a", "1", "2"]
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
        
        // More than maxCount
        var args = TestArgs()
        do {
            try args.parse(["-a", "1", "2", "3", "4", "5"])
            XCTFail("no error throws")
        } catch ParseError.invalidOperand(_) {
        } catch {
            XCTFail("wrong error type \(error)")
        }
    }

}
