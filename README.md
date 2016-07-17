# CommandArguments

Strong typed arguments parsing library based on Swift reflection (`Mirror`) API. 

[![Build Status](https://travis-ci.org/evan-liu/CommandArguments.svg)](https://travis-ci.org/evan-liu/CommandArguments)
Swift 3.0-PREVIEW-2 (Xcode 8.0 Beta 2)

## Features

### Strong typed arguments 

```swift
struct BuildArguments: CommandArguments {
    var platform = Operand()
    var version = Option()
    var clean = Flag()
}

var buildArgs = BuildArguments()
do {
    try buildArgs.parse(Process.arguments.dropFirst())
} catch {
    print(error)
}

// $ build ios --version=1.0 --clean
buildArgs.platform.value    // "ios"
buildArgs.version.value     // "1.0"
buildArgs.clean.value       // true
```

### Enum (and other custom type) arguments

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
    try deployArgs.parse(Process.arguments, from: 1)
} catch {
    print(error)
}

// $ deploy -cs prod watchOS
deployArgs.platform.value   // .watchOS
deployArgs.server.value     // .prod
deployArgs.clean.value      // true
```

### Usage message

```swift
struct ReportArguments: CommandArguments {
    let commandName = "report"

    var format = DefaultedOption("html", shortName: "f", usage: "Report format (html by default)")
    var coverage = Flag(shortName: "c", usage: "If include test coverage in the report")

    var project = Operand(usage: "Project name for the report")
    var email = VariadicOperand(minCount: 1, usage: "Email address to receive the report (at least 1)")
}

print(ReportArguments().usage())
```

```
Usage: report [options] project email ...

Operands:
  project  Project name for the report
  email    Email address to receive the report (at least 1)

Options:
  -f, --format    Report format (html by default)
  -c, --coverage  If include test coverage in the report
```
 
### Class inheritance

```swift
enum Platform: String, ArgumentConvertible {
    case iOS, watchOS, macOS
}
class AppleArgs {
    var platform = OptionT<Platform>()
}
final class BuildArgs: AppleArgs, CommandArguments {
    let commandName = "build"
    var clear = Flag()
}
final class DeployArgs: AppleArgs, CommandArguments {
    let commandName = "deploy"
    var report = Flag()
}
```

`print(BuildArgs().usage())`

```
Usage: build [options]

Options:
  --platform
  --clear
```

`print(DeployArgs().usage())`

```
Usage: deploy [options]

Options:
  --platform
  --report
```
