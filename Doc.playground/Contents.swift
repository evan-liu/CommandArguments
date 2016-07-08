import Foundation
import CommandArguments

// Example

struct BuildArguments: CommandArguments {
    var platform = VariadicArgument(minCount: 1)
    var buildConfig = OptionalStringOption(longName: "build-config")
    var release = BoolOption(shortName: "r")
}

var buildArgs = BuildArguments()
do {
    try buildArgs.parse("ios android --build-config=build.json -r")
} catch {
    print(error)
}

buildArgs.platform.value    // ["ios", "android"]
buildArgs.buildConfig.value // "build.json"
buildArgs.release.value     // true

// Usage

struct MyArgs: CommandArguments {
    var src = VariadicArgument(minCount: 1)
    var dest = RequiredArgument()
    var force = BoolOption(shortName: "f")
}

var myArgs = MyArgs()
do {
    try myArgs.parse("input1 input2 input3 output -f")
} catch {
    print(error)
}

myArgs.src.value    // ["input1", "input2", "input3"]
myArgs.dest.value   // "output"
myArgs.force.value  // true


