import XCTest
import CommandArguments

class StringTests: XCTestCase {

    func testStringOption() {
        struct TestArgs: CommandArguments {
            var a = StringOption(longName: "aa", shortName: "a")
            var b = StringOption(longName: "bb", shortName: "b")
            
            var c = StringOption(longName: "cc", shortName: "c")
            var d = StringOption(longName: "dd", shortName: "d")
        }
        
        var args = TestArgs()
        try! args.parse([
            "--aa", "xx", "--bb=yy",
            "-c", "x", "-d=y"
            ])
        
        XCTAssertEqual(args.a.value, "xx")
        XCTAssertEqual(args.b.value, "yy")
        
        XCTAssertEqual(args.c.value, "x")
        XCTAssertEqual(args.d.value, "y")
    }
    
    func testStringOptionThrows() {
        struct TestArgs: CommandArguments {
            var a = StringOption()
        }
        
        var args = TestArgs()
        do {
            try args.parse([])
            XCTFail("no error throws")
        } catch ParseError.missingRequiredOption(_) {
        } catch {
            XCTFail("wrong error type \(error)")
        }
    }

}
