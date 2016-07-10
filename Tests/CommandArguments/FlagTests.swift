import XCTest
import CommandArguments

class FlagTests: XCTestCase {

    func testFlag() {
        struct TestArgs: CommandArguments {
            var a = Flag(longName: "aa")
            var b = Flag(longName: "bb")
            var c = Flag(longName: "cc")
            var d = Flag(longName: "dd")
            var e = Flag(longName: "ee")
            var f = Flag(longName: "ff")
            var g = Flag(longName: "gg")
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
