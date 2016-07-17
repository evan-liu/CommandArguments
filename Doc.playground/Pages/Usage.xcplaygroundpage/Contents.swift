//: [Previous](@previous)

import Foundation
import CommandArguments

struct ReportArguments: CommandArguments {
    let commandName = "report"
    
    var format = DefaultedOption("html", shortName: "f", usage: "Report format (html by default)")
    var coverage = Flag(shortName: "c", usage: "If include test coverage in the report")
    
    var project = Operand(usage: "Project name for the report")
    var email = VariadicOperand(minCount: 1, usage: "Email address to receive the report (at least 1)")
}

print(ReportArguments().usage())

//: [Next](@next)
