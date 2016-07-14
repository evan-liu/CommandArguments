# CommandArguments

Strong typed arguments parsing library based on Swift reflection (`Mirror`) API. 

[![Build Status](https://travis-ci.org/evan-liu/CommandArguments.svg)](https://travis-ci.org/evan-liu/CommandArguments)
Swift 3.0-PREVIEW-2 (Xcode 8.0 Beta 2)

## Example 1

`$ build ios --version=1.0 --clean`

```swift
struct BuildArguments: CommandArguments {
    var platform = Operand()
    var version = Option()
    var clean = Flag()
}

var buildArgs = BuildArguments()
do {
    try buildArgs.parse(Process.arguments, from: 1)
} catch {
    print(error)
}

buildArgs.platform.value    // "ios"
buildArgs.version.value     // "1.0"
buildArgs.clean.value       // true
```

## Example 2

`$ deploy -cs prod watchOS`

```swift
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
    try deployArgs.parse(Process.arguments.dropFirst())
} catch {
    print(error)
}

deployArgs.platform.value   // .watchOS
deployArgs.server.value     // .prod
deployArgs.clean.value      // true
```
