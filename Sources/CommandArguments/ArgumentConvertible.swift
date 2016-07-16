import Foundation

/**
 A type that can be initialized with an argument value.
 
 To use custom argument types (like string enum) for `Option` or `Operand`,
 make it confirm to `ArgumentConvertible` protocol and use it as type parameter
 of the "Generic T" version of `Option` or `Operand`:
 
 ````
 enum Platform: String, ArgumentConvertible {
     case iOS, watchOS, maxOS
 }
 struct BuildArgs: CommandArguments {
     var platform = OperandT<Platform>()
 }
 ````
 
 */
public protocol ArgumentConvertible {
    init?(rawValue: String)
}

extension String: ArgumentConvertible {
    public init?(rawValue: String) {
        guard !rawValue.isEmpty else { return nil }
        self = rawValue
    }
}
