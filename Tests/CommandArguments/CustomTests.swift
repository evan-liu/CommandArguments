import XCTest
import CommandArguments

class EnumTests: XCTestCase {
    
    enum Platform: String, ArgumentConvertible {
        case iOS, watchOS, maxOS
    }
    enum Server: String, ArgumentConvertible {
        case dev, staging, production
    }
    struct TestArgs: CommandArguments {
        var platform = CustomArgument<Platform>()
        var server = CustomOption<Server>()
    }
    
    func testEnumArguments() {
        var args = TestArgs()
        try! args.parse(["watchOS", "--server=staging"])
        
        XCTAssertEqual(args.platform.value, .watchOS)
        XCTAssertEqual(args.server.value, .staging)
    }
    
    func testEnumArgumentsThrows() {
        var args1 = TestArgs()
        do {
            try args1.parse(["--server=dev"])
            XCTFail("no error throws")
        } catch ParseError.missingRequiredArgument(_) {
        } catch {
            XCTFail("wrong error type \(error)")
        }
        
        var args2 = TestArgs()
        do {
            try args2.parse(["watchOS"])
            XCTFail("no error throws")
        } catch ParseError.missingRequiredOption(_) {
        } catch {
            XCTFail("wrong error type \(error)")
        }
        
        var args3 = TestArgs()
        do {
            try args3.parse(["watchOS", "--server=abc"])
            XCTFail("no error throws")
        } catch ParseError.missingRequiredOption(_) {
        } catch {
            XCTFail("wrong error type \(error)")
        }
    }

}
