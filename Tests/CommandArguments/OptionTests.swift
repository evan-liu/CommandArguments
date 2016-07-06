import XCTest
import CommandArguments

class OptionTests: XCTestCase {
    
    func testDefaultNames() {
        struct TestArgs: CommandArguments {
            var a = BoolOption()
            var bb = BoolOption()
            var c = StringOption()
            var dd = StringOption()
        }
        
        var args = TestArgs()
        try! args.parse(args: [
            "-a", "--bb",
            "-c", "x", "--dd=y"
            ])
        
        XCTAssertTrue(args.a.value)
        XCTAssertTrue(args.bb.value)
        
        XCTAssertEqual(args.c.value, "x")
        XCTAssertEqual(args.dd.value, "y")
    }
    
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
            var b = StringOption(longName: "bb", shortName: "b")
            
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
    
    func testMultiStringOption() {
        struct TestArgs: CommandArguments {
            var a = MultiStringOption(count: 2)
            var b = MultiStringOption(count: 3)
        }
        
        var args = TestArgs()
        try! args.parse(args: [
            "-a", "1", "2",
            "-b=3", "4", "5"
        ])
        
        XCTAssertEqual(args.a.value, ["1", "2"])
        XCTAssertEqual(args.b.value, ["3", "4", "5"])
    }
    
    func testOptionalStringOption() {
        struct TestArgs: CommandArguments {
            var a = StringOption()
            var b = OptionalStringOption()
        }
        
        var args1 = TestArgs()
        try! args1.parse(args: ["-a=x"])
        XCTAssertNil(args1.b.value)
        
        var args2 = TestArgs()
        try! args2.parse(args: ["-a=x", "-b"])
        XCTAssertNil(args2.b.value)
        
        var args3 = TestArgs()
        try! args3.parse(args: ["-a=x", "-b="])
        XCTAssertEqual(args3.b.value, "")
        
        var args4 = TestArgs()
        try! args4.parse(args: ["-a=x", "-b=4"])
        XCTAssertEqual(args4.b.value, "4")
        
        var args5 = TestArgs()
        try! args5.parse(args: ["-a=x", "-b", "5"])
        XCTAssertEqual(args5.b.value, "5")
    }
    
    func testVariadicStringOption() {
        struct TestArgs: CommandArguments {
            var a = StringOption()
            var b = VariadicStringOption()
        }
        
        var args = TestArgs()
        try! args.parse(args: ["-a=x", "-b", "1", "2", "3"])
        XCTAssertEqual(args.b.value, ["1", "2", "3"])
    }
    
    func testOptionStopper() {
        struct TestArgs: CommandArguments {
            var a = BoolOption()
            var b = VariadicParameter()
        }
        
        var args = TestArgs()
        try! args.parse(args: ["-a", "--", "-1", "-2", "-3"])
        XCTAssertTrue(args.a.value)
        XCTAssertEqual(args.b.value, ["-1", "-2", "-3"])
    }
}
