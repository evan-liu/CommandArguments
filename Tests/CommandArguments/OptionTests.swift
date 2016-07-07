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
        try! args.parse([
            "-a", "--bb",
            "-c", "x", "--dd=y"
            ])
        
        XCTAssertTrue(args.a.value)
        XCTAssertTrue(args.bb.value)
        
        XCTAssertEqual(args.c.value, "x")
        XCTAssertEqual(args.dd.value, "y")
    }
    
    func testDuplicatedNames() {
        struct LongNames: CommandArguments {
            var a = BoolOption(longName: "xx")
            var b = BoolOption(longName: "xx")
        }
        var longArgs = LongNames()
        do {
            try longArgs.parse([])
            XCTFail()
        } catch TypeError.duplicatedOptionName(_) {
        } catch { XCTFail() }
        
        struct ShortNames: CommandArguments {
            var a = BoolOption(shortName: "x")
            var b = BoolOption(shortName: "x")
        }
        var shortArgs = ShortNames()
        do {
            try shortArgs.parse([])
            XCTFail()
        } catch TypeError.duplicatedOptionName(_) {
        } catch { XCTFail() }
    }
    
    func testInvalidShortOptionName() {
        struct Args1: CommandArguments {
            var a = BoolOption(shortName: "1")
        }
        struct Args2: CommandArguments {
            var a = BoolOption(shortName: "")
        }
        struct Args3: CommandArguments {
            var a = BoolOption(shortName: " ")
        }
        
        var args1 = Args1()
        do {
            try args1.parse([])
            XCTFail()
        } catch TypeError.invalidShortOptionName(_) {
        } catch { XCTFail() }
        
        var args2 = Args2()
        do {
            try args2.parse([])
            XCTFail()
        } catch TypeError.invalidShortOptionName(_) {
        } catch { XCTFail() }
        
        var args3 = Args3()
        do {
            try args3.parse([])
            XCTFail()
        } catch TypeError.invalidShortOptionName(_) {
        } catch { XCTFail() }
    }
    
    func testNoNames() {
        struct TestArgs: CommandArguments {
            var a = StringOption(shortName: "b")
            var b = StringOption()
        }
        
        var args = TestArgs()
        do {
            try args.parse([])
            XCTFail()
        } catch TypeError.missingOptionName(_) {
        } catch {
            XCTFail("Wrong error type \(error)")
        }
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
        
        
        var shortNames = TestArgs()
        try! shortNames.parse([
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
        try! combinedShortNames.parse(["-abd"])
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
            XCTFail()
        } catch ParseError.missingRequiredOption(_) {
        } catch {
            XCTFail()
        }
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
    
    func testOptionalStringOption() {
        struct TestArgs: CommandArguments {
            var a = StringOption()
            var b = OptionalStringOption()
        }
        
        var args1 = TestArgs()
        try! args1.parse(["-a=x"])
        XCTAssertNil(args1.b.value)
        
        var args2 = TestArgs()
        try! args2.parse(["-a=x", "-b"])
        XCTAssertNil(args2.b.value)
        
        var args3 = TestArgs()
        try! args3.parse(["-a=x", "-b="])
        XCTAssertNil(args3.b.value)
        
        var args4 = TestArgs()
        try! args4.parse(["-a=x", "-b=4"])
        XCTAssertEqual(args4.b.value, "4")
        
        var args5 = TestArgs()
        try! args5.parse(["-a=x", "-b", "5"])
        XCTAssertEqual(args5.b.value, "5")
    }
    
    func testOptionalStringOptionDefaultValue() {
        struct TestArgs: CommandArguments {
            var a = OptionalStringOption(default: "x")
        }
        
        var args1 = TestArgs()
        try! args1.parse([])
        XCTAssertEqual(args1.a.value, "x")
        
        var args2 = TestArgs()
        try! args2.parse(["-a", "y"])
        XCTAssertEqual(args2.a.value, "y")
        
        var args3 = TestArgs()
        try! args3.parse(["-a=z"])
        XCTAssertEqual(args3.a.value, "z")
        
        var args4 = TestArgs()
        try! args4.parse(["-a="])
        XCTAssertEqual(args4.a.value, "x")
    }
    
    func testVariadicStringOption() {
        struct TestArgs: CommandArguments {
            var a = StringOption()
            var b = VariadicStringOption()
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
    
    func testOptionStopper() {
        struct TestArgs: CommandArguments {
            var a = BoolOption()
            var b = VariadicArgument()
        }
        
        var args = TestArgs()
        try! args.parse(["-a", "--", "-1", "-2", "-3"])
        XCTAssertTrue(args.a.value)
        XCTAssertEqual(args.b.value, ["-1", "-2", "-3"])
    }
    
    func testInvalidOption() {
        struct TestArgs: CommandArguments {
            var a = StringOption()
        }
        
        var args = TestArgs()
        do {
            try args.parse(["-a=b", "-c"])
            XCTFail()
        } catch ParseError.invalidOption(_) {
        } catch {
            XCTFail()
        }

    }
}
