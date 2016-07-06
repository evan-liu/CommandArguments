# CommandArguments

Strong typed arguments parsing library based on Swift reflection (`Mirror`) API. 

## Example

```swift
struct BuildArguments: CommandArguments {
  var platform = VariadicParameter(minCount: 1)
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
build ios android --config=buildConfig.json -r
```
