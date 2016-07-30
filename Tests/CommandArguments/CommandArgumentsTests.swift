import XCTest
import CommandArguments

class CommandArgumentsTests: XCTestCase {

    static let allTests = [
        ("testInheritance", testInheritance),
        ("testOperandDefaultNames", testOperandDefaultNames),
        ("testOperandDuplicatedNames", testOperandDuplicatedNames),
        ("testOperandNoNames", testOperandNoNames),
        ("testOptionDefaultNames", testOptionDefaultNames),
        ("testOptionDuplicatedNames", testOptionDuplicatedNames),
        ("testInvalidShortOptionName", testInvalidShortOptionName),
        ("testOptionNoNames", testOptionNoNames),
    ]

    func testInheritance() {

        class Args1: CommandArguments {
            var a = Flag()
        }

        class Args2: Args1 {
            var b = Flag()
        }

        class Args3: Args2 {
            var c = Flag()
        }

        var args = Args3()
        do {
            try args.parse("-a -b -c")
            XCTAssertTrue(args.a.value)
            XCTAssertTrue(args.b.value)
            XCTAssertTrue(args.c.value)
        } catch {
            XCTFail("\(error)")
        }

        let usage = args.usage()
        XCTAssert(usage.contains("-a"))
        XCTAssert(usage.contains("-b"))
        XCTAssert(usage.contains("-c"))
    }

    // ----------------------------------------
    // MARK: Operand Names
    // ----------------------------------------
    func testOperandDefaultNames() {
        struct TestArgs: CommandArguments {
            var a = Operand()
            var b = Operand()
        }

        var args = TestArgs()
        try! args.parse(["x", "y"])

        XCTAssertEqual(args.a.value, "x")
        XCTAssertEqual(args.b.value, "y")
    }

    func testOperandDuplicatedNames() {
        struct TestArgs: CommandArguments {
            var a = Operand(name: "b")
            var b = Operand(name: "b")
        }
        var args = TestArgs()
        do {
            try args.parse([])
            XCTFail("should throw error")
        } catch TypeError.duplicatedOperandName(_) {
        } catch { XCTFail() }
    }

    func testOperandNoNames() {
        struct TestArgs: CommandArguments {
            var a = Operand(name: "b")
            var b = Operand()
        }

        var args = TestArgs()
        do {
            try args.parse([])
            XCTFail()
        } catch TypeError.missingOperandName(_) {
        } catch {
            XCTFail("Wrong error type \(error)")
        }
    }

    // ----------------------------------------
    // MARK: Option Names
    // ----------------------------------------
    func testOptionDefaultNames() {
        struct TestArgs: CommandArguments {
            var a = Option()
            var bb = Option()
        }

        var args = TestArgs()
        try! args.parse("-a x --bb y")

        XCTAssertEqual(args.a.value, "x")
        XCTAssertEqual(args.bb.value, "y")
    }

    func testOptionDuplicatedNames() {
        struct LongNames: CommandArguments {
            var a = Option(longName: "xx")
            var b = Option(longName: "xx")
        }
        var longArgs = LongNames()
        do {
            try longArgs.parse([])
            XCTFail()
        } catch TypeError.duplicatedOptionName(_) {
        } catch { XCTFail() }

        struct ShortNames: CommandArguments {
            var a = Option(shortName: "x")
            var b = Option(shortName: "x")
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
            var a = Option(shortName: "1")
        }
        struct Args2: CommandArguments {
            var a = Option(shortName: "")
        }
        struct Args3: CommandArguments {
            var a = Option(shortName: " ")
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

    func testOptionNoNames() {
        struct TestArgs: CommandArguments {
            var a = Option(shortName: "b")
            var b = Option()
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

}
