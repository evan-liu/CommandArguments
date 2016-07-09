# CommandArguments

Strong typed arguments parsing library based on Swift reflection (`Mirror`) API. 

[![Build Status](https://travis-ci.org/evan-liu/CommandArguments.svg)](https://travis-ci.org/evan-liu/CommandArguments)
`Swift 3.0 Preview 1` (`Xcode-beta 1`) 

## Example

```swift
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
```

## Usage

### Define a type confirming `CommandArguments` protocol with `Argument` and/or `Option` fields

```swift
struct MyArgs: CommandArguments {
    var src = VariadicArgument(minCount: 1)
    var dest = RequiredArgument()
    var force = BoolOption(shortName: "f")
}
```

### Init and parse with arguments

```swift
var myArgs = MyArgs()
do {
    try myArgs.parse("input1 input2 input3 output -f")
} catch {
    print(error)
}
```

or

```swift
try myArgs.parse(Process.arguments.dropFirst())
```

or

```swift
try myArgs.parse(Process.arguments, from: 1)
```

### Read values

```swift
myArgs.src.value    // ["input1", "input2", "input3"]
myArgs.dest.value   // "output"
myArgs.force.value  // true
```
