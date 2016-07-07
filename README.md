# CommandArguments

Strong typed arguments parsing library based on Swift reflection (`Mirror`) API. 

**Requirements**: `Swift 3.0 Preview 1` (`Xcode-beta 1`) 

[![Build Status](https://travis-ci.org/evan-liu/CommandArguments.svg)](https://travis-ci.org/evan-liu/CommandArguments)

## Example

```swift
struct BuildArguments: CommandArguments {
  var platform = VariadicArgument(minCount: 1)
  var config = OptionalStringOption()
  var release = BoolOption(shortName: "r")
}

var buildArgs = BuildArguments()
do {
  try buildArgs.parse(Process.arguments.dropFirst())
} catch {
  print(error)
}

// Build these platforms
buildArgs.platform.value.forEach { platform in
  if let config = buildArgs.config.value {
    // Config file to use
  }
  if buildArgs.release.value {
    // This is a release build
  }
}
```

```sh
$ build ios android --config=buildConfig.json -r
```

## TODO 

- [ ] Usage message
- [ ] Documentation
- [ ] Enum options
- [ ] Number options
