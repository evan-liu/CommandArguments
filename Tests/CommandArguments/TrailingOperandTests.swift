import XCTest
import CommandArguments

class TrailingOperandTests: XCTestCase {

    func testTrailingOperand() {
        struct TestArgs: CommandArguments {
            var a = VariadicOperand()
            var b = Operand()
        }
        
        var args = TestArgs()
        try! args.parse(["1", "2", "3", "4"])
        XCTAssertEqual(args.a.value, ["1", "2", "3"])
        XCTAssertEqual(args.b.value, "4")
    }
    
    func testTrailingMultiOperand() {
        struct TestArgs: CommandArguments {
            var a = VariadicOperand()
            var b = MultipleOperand(count: 2)
        }
        
        var args = TestArgs()
        try! args.parse(["1", "2", "3", "4"])
        XCTAssertEqual(args.a.value, ["1", "2"])
        XCTAssertEqual(args.b.value, ["3", "4"])
    }
    
    func testTrailingOperandThrows() {
        struct TestArgs: CommandArguments {
            var a = VariadicOperand()
            var b = Operand()
        }
        
        var args = TestArgs()
        do {
            try args.parse([])
            XCTFail()
        } catch ParseError.missingRequiredOperand(_) {
        } catch { XCTFail() }
    }

}
