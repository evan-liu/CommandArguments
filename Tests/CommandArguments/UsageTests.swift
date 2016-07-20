import XCTest
import CommandArguments

class UsageTests: XCTestCase {

    func testTypeError() {
        struct TestArgs: CommandArguments {
            var a = Option(shortName: "b")
            var b = Option()
        }
        XCTAssert(TestArgs().usage().hasPrefix("Error: "))
    }
    
    func testEmptyType() {
        struct TestArgs: CommandArguments {
        }
        XCTAssert(TestArgs().usage().hasPrefix("Error: "))
    }
    
    func testUsage() {
        struct TestArgs: CommandArguments {
            var a = Option(usage: "a option")
            var bbbb = Option(usage: "bbbb option")
            var c = Option(longName: "cc", usage: "c--cc option")
            var x = Operand(usage: "x")
            var y = Operand(usage: "y")
        }
        
        let usage = TestArgs().usage(commandName: "test")
        let secions = usage.components(separatedBy: "\n\n")
        XCTAssert(secions[0].hasSuffix("test [options] x y"))
        XCTAssert(secions[1].contains("  x  x"))
        XCTAssert(secions[2].contains("  -c, --cc    c"))
    }
    
    func testOperandOnly() {
        struct TestArgs: CommandArguments {
            var x = Operand()
        }
        
        let usage = TestArgs().usage()
        XCTAssertTrue(usage.contains("Operands:"))
        XCTAssertFalse(usage.contains("Options:"))
    }
    
    func testOptionOnly() {
        struct TestArgs: CommandArguments {
            var a = Option()
        }
        
        let usage = TestArgs().usage()
        XCTAssertFalse(usage.contains("Operands:"))
        XCTAssertTrue(usage.contains("Options:"))
    }
    
    func testMultipleOperand() {
        struct TestArgs: CommandArguments {
            var x = MultipleOperand(count: 2)
        }
        
        let usage = TestArgs().usage()
        XCTAssert(usage.contains("x ..."))
    }
    
    func testOptionalOperand() {
        struct TestArgs: CommandArguments {
            var x = OptionalOperand()
        }
        
        let usage = TestArgs().usage()
        XCTAssert(usage.contains("<x>"))
    }
    
    func testVariadicOperand() {
        struct TestArgs: CommandArguments {
            var x = VariadicOperand()
        }
        
        let usage = TestArgs().usage()
        XCTAssert(usage.contains("x ..."))
    }
    
    func testTrainingOperand() {
        struct TestArgs: CommandArguments {
            var x = VariadicOperand()
            var y = Operand()
        }
        
        let usage = TestArgs().usage()
        XCTAssert(usage.contains("x ... y"))
    }
    
    func testShortNameOnlyOption() {
        struct TestArgs: CommandArguments {
            var a = Option(usage: "a")
        }
        
        let usage = TestArgs().usage()
        XCTAssert(usage.contains("-a  a"))
    }
    
    func testLongNameOnlyOption() {
        struct TestArgs: CommandArguments {
            var aa = Option(usage: "aa")
        }
        
        let usage = TestArgs().usage()
        XCTAssert(usage.contains("--aa  aa"))
    }
    
}
