import XCTest
import CommandArguments

class MultiStringTests: XCTestCase {

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
    
    func testMultiStringOption() {
        struct TestArgs: CommandArguments {
            var a = MultiStringOption(count: 2)
            var b = MultiStringOption(count: 3)
        }
        
        var args = TestArgs()
        try! args.parse([
            "-a", "1", "2",
            "-b=3", "4", "5"
        ])
        
        XCTAssertEqual(args.a.value, ["1", "2"])
        XCTAssertEqual(args.b.value, ["3", "4", "5"])
    }
    
    func testMultiStringOptionThrows() {
        struct TestArgs: CommandArguments {
            var a = MultiStringOption(count: 3)
            var b = BoolOption()
        }
        
        // Less than count
        [
            ["-a"],
            ["-a", "1"],
            ["-a", "1", "2", "-b"]
        ].forEach {
            var args = TestArgs()
            do {
                try args.parse($0)
                XCTFail()
            } catch ParseError.missingRequiredOption(_) {
            } catch {
                print(error)
                XCTFail()
            }
        }
        
        // More than count
        var args = TestArgs()
        do {
            try args.parse(["-a", "1", "2", "3", "4"])
            XCTFail()
        } catch ParseError.invalidArgument(_) {
        } catch { XCTFail() }
    }
    
}
