import XCTest
@testable import CommandArguments

class CommandArgumentsTests: XCTestCase {
    
    func testBoolOption() {
        struct TestArgs: CommandArguments {
            var a = BoolOption(longName: "aa", shortName: "a")
            var b = BoolOption(longName: "bb", shortName: "b")
            var c = BoolOption(longName: "cc", shortName: "c")
            var d = BoolOption(longName: "dd", shortName: "d")
            var e = BoolOption(longName: "ee", shortName: "e")
            var f = BoolOption(longName: "ff", shortName: "f")
            var g = BoolOption(longName: "gg", shortName: "g")
        }
        
        var longNames = TestArgs()
        try! longNames.parse(args: [
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
        
        
        var shortNames = TestArgs()
        try! shortNames.parse(args: [
            "-a",
            "-b", "true", "-c", "false",
            "-d=true", "-e=false", "-f="
        ])
        XCTAssertTrue(longNames.a.value)
        XCTAssertTrue(longNames.b.value)
        XCTAssertFalse(longNames.c.value)
        XCTAssertTrue(longNames.d.value)
        XCTAssertFalse(longNames.e.value)
        XCTAssertFalse(longNames.f.value)
        XCTAssertFalse(longNames.g.value)
        
        var combinedShortNames = TestArgs()
        try! combinedShortNames.parse(args: ["-abd"])
        XCTAssertTrue(longNames.a.value)
        XCTAssertTrue(longNames.b.value)
        XCTAssertFalse(longNames.c.value)
        XCTAssertTrue(longNames.d.value)
        XCTAssertFalse(longNames.e.value)
    }
    
    func testStringOption() {
        struct TestArgs: CommandArguments {
            var a = StringOption(longName: "aa", shortName: "a")
            var b = StringOption(longName: "bb", shortName: "a")
            
            var c = StringOption(longName: "cc", shortName: "c")
            var d = StringOption(longName: "dd", shortName: "d")
        }
        
        var args = TestArgs()
        try! args.parse(args: [
            "--aa", "xx", "--bb=yy",
            "-c", "x", "-d=y"
        ])
        
        XCTAssertEqual(args.a.value, "xx")
        XCTAssertEqual(args.b.value, "yy")
        
        XCTAssertEqual(args.c.value, "x")
        XCTAssertEqual(args.d.value, "y")
    }
    
}
