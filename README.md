# CommandArguments

Strong typed arguments parsing library based on Swift reflection (`Mirror`) API. 

[![Build Status](https://travis-ci.org/evan-liu/CommandArguments.svg)](https://travis-ci.org/evan-liu/CommandArguments)
Swift 3.0-PREVIEW-2 (Xcode 8.0 Beta 2)

## Example 1

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

## Example 2

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

## Example 3

```swift
struct ReportArguments: CommandArguments {
    var format = DefaultedOption("html", shortName: "f", usage: "Report format (html by default)")
    var coverage = Flag(shortName: "c", usage: "If include test coverage in the report")

    var project = Operand(usage: "Project name for the report")
    var email = VariadicOperand(minCount: 1, usage: "Email address to receive the report (at least 1)")
}

print(ReportArguments().usage(commandName: "report"))
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
