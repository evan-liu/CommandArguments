import Foundation
import CommandArguments

//: Example 1:

struct BuildArguments: CommandArguments {
    var platform = Operand()
    var version = Option()
    var clean = Flag()
}

var buildArgs = BuildArguments()
do {
    try buildArgs.parse("build ios --version=1.0 --clean", from: 1)
} catch {
    print(error)
}

buildArgs.platform.value    // "ios"
buildArgs.version.value     // "1.0"
buildArgs.clean.value       // true

//: Example 2:

struct DeployArguments: CommandArguments {
    enum Platform: String, ArgumentConvertible {
        case iOS, watchOS, macOS
    }
    enum Server: String, ArgumentConvertible {
        case dev, staging, prod
    }
    
    var platform = OperandT<Platform>()
    var server = DefaultedOptionT<Server>(.dev, shortName: "s")
    var clean = Flag(shortName: "c")
}

var deployArgs = DeployArguments()
do {
    try deployArgs.parse("deploy -cs prod watchOS", from: 1)
} catch {
    print(error)
}

deployArgs.platform.value   // .watchOS
deployArgs.server.value     // .prod
deployArgs.clean.value      // true

//: Example 3: 

struct ReportArguments: CommandArguments {
    var format = DefaultedOption("html", shortName: "f", usage: "Report format (html by default)")
    var coverage = Flag(shortName: "c", usage: "If include test coverage in the report")

    var project = Operand(usage: "Project name for the report")
    var email = VariadicOperand(minCount: 1, usage: "Email address to receive the report (at least 1)")
}

print(ReportArguments().usage(commandName: "report"))
