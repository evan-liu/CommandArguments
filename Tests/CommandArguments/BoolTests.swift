import XCTest
import CommandArguments

class BoolTests: XCTestCase {

    func testBoolOption() {
        struct TestArgs: CommandArguments {
            var a = BoolOption(longName: "aa")
            var b = BoolOption(longName: "bb")
            var c = BoolOption(longName: "cc")
            var d = BoolOption(longName: "dd")
            var e = BoolOption(longName: "ee")
            var f = BoolOption(longName: "ff")
            var g = BoolOption(longName: "gg")
        }
        
        var shortNames = TestArgs()
        try! shortNames.parse([
            "-a",
            "-b", "true", "-c", "false",
            "-d=true", "-e=false", "-f="
        ])
        XCTAssertTrue(shortNames.a.value)
        XCTAssertTrue(shortNames.b.value)
        XCTAssertFalse(shortNames.c.value)
        XCTAssertTrue(shortNames.d.value)
        XCTAssertFalse(shortNames.e.value)
        XCTAssertFalse(shortNames.f.value)
        XCTAssertFalse(shortNames.g.value)
        
        var longNames = TestArgs()
        try! longNames.parse([
            "--aa",
            "--bb", "true", "--cc", "false",
            "--dd=true", "--ee=false", "--ff="
        ])
        XCTAssertTrue(longNames.a.value)
        XCTAssertTrue(longNames.b.value)
        XCTAssertFalse(longNames.c.value)
        XCTAssertTrue(longNames.d.value)
        XCTAssertFalse(longNames.e.value)
        XCTAssertFalse(longNames.f.value)
        XCTAssertFalse(longNames.g.value)
    }

}
