import Foundation
import CommandArguments

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

//: [Next](@next)