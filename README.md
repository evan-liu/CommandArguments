# CommandArguments

Strong typed arguments parsing library based on Swift reflection (`Mirror`) API. 

![Platform](https://img.shields.io/badge/platform-macos%20%7C%20linux-lightgrey.svg)
![Swift](https://img.shields.io/badge/swift-3.0--PREVIEW--3-yellowgreen.svg)
[![Test Coverage](https://img.shields.io/badge/coverage-95%25-green.svg)](https://github.com/evan-liu/CommandArguments/tree/master/Tests)
[![Build Status](https://travis-ci.org/evan-liu/CommandArguments.svg)](https://travis-ci.org/evan-liu/CommandArguments)

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

### Enum arguments

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
```

`print(BuildArgs().usage())`

```
Usage: build [options]

Options:
  --platform  Apple platform (iOS|watchOS|macOS)
  --clear
```

`print(DeployArgs().usage())`

```
Usage: deploy [options]

Options:
  --platform  Apple platform (iOS|watchOS|macOS)
  --report
```

### Combined short named options

`-abc xyz` is equal to `-a -b -c xyz`

### Option stopper `--`

All arguments after `--` will be parsed as `Operand`s

## API

### Argument categories

- Operand: Ordinary argument values. Like src and dest in `cp src dest`
- Option: -x (short name) or --xyz (long name) format option with values
- Flag: A `Bool` type `Option`. Be `true` with: `-x, --xyz, -x true, --xyz true, -x=true, --xyz=true`

### Requirements

- `Option` & `Operand`: Required. Value type: `String!`
- `MultipleOption` & `MultipleOperand`: Require `count` times. Value type: `[String]`
- `OptionalOption` & `OptionalOperand`: Not required. Value type: `String?`
- `DefaultedOption` & `DefaultedOperand`: Not required. Value type: `String`
- `VariadicOption` & `VariadicOperand`: Required if `minCount > 0`. Value type: `[String]`

`ParseError.missing` will be threw if requirements not match. 

### Generic Types

Any type confirm to `ArgumentConvertible` protocol (see Enum example above) can be used in `Generic T` versions. Value types: 

- `OptionT` & `OperandT`: `T!`
- `MultipleOptionT` & `MultipleOperandT`: `[T]`
- `OptionalOptionT` & `OptionalOperandT`: `T?`
- `DefaultedOptionT` & `DefaultedOperandT`: `T`
- `VariadicOptionT` & `VariadicOperandT`: `[T]`

## Install 

### Swift Package Manager: 

Add to dependencies: 

`.Package(url: "https://github.com/evan-liu/CommandArguments.git", majorVersion: 0, minor: 1)`
