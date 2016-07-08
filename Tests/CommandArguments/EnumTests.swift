import XCTest
import CommandArguments

class EnumTests: XCTestCase {

    func testEnumArguments() {
        struct TestArgs: CommandArguments {
            enum Platform: String, ArgumentEnum {
                case iOS, watchOS, maxOS
            }
            enum Server: String, ArgumentEnum {
                case dev, staging, production
            }
            
            var platform = EnumArgument<Platform>()
            var server = EnumOption<Server>()
        }
        
        var args = TestArgs()
        try! args.parse(["watchOS", "--server=staging"])
        
        XCTAssertEqual(args.platform.value, .watchOS)
        XCTAssertEqual(args.server.value, .staging)
    }

}
