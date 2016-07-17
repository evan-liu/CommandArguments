//: [Previous](@previous)

import Foundation
import CommandArguments

enum Platform: String, ArgumentConvertible {
    case iOS, watchOS, macOS
}
class AppleArgs {
    var platform = OptionT<Platform>(usage: "Apple platform (iOS|watchOS|macOS)")
}
final class BuildArgs: AppleArgs, CommandArguments {
    let commandName = "build"
    var clear = Flag()
}
final class DeployArgs: AppleArgs, CommandArguments {
    let commandName = "deploy"
    var report = Flag()
}

print(BuildArgs().usage())
print(DeployArgs().usage())

//: [Next](@next)
