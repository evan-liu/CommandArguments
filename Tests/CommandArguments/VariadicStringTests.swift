import XCTest
import CommandArguments

class VariadicStringTests: XCTestCase {
    
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
    
    func testVariadicStringOption() {
        struct TestArgs: CommandArguments {
            var a = StringOption()
            var b = VariadicStringOption(minCount: 3)
            var c = BoolOption()
        }
        
        var args = TestArgs()
        try! args.parse(["-a=x", "-b", "1", "-c", "-b", "2", "3"])
        XCTAssertEqual(args.b.value, ["1", "2", "3"])
    }
    
    func testVariadicStringOptionThrows() {
        struct TestArgs: CommandArguments {
            var a = VariadicStringOption(minCount: 3, maxCount: 4)
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
                XCTFail()
            } catch ParseError.missingRequiredOption(_) {
            } catch { XCTFail() }
        }
        
        // More than maxCount
        var args = TestArgs()
        do {
            try args.parse(["-a", "1", "2", "3", "4", "5"])
            XCTFail()
        } catch ParseError.invalidArgument(_) {
        } catch {
            XCTFail()
        }
    }

}
