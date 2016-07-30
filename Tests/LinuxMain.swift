import XCTest

@testable import CommandArgumentsTestSuite

XCTMain([
    testCase(CommandArgumentsTests.allTests),
    testCase(DefaultedTests.allTests),
    testCase(EnumTests.allTests),
    testCase(FlagTests.allTests),
    testCase(MultipleTests.allTests),
    testCase(OptionalTests.allTests),
    testCase(ParseTests.allTests),
    testCase(RequiredTests.allTests),
    testCase(TrailingOperandTests.allTests),
    testCase(UsageTests.allTests),
    testCase(VariadicTests.allTests),
])
