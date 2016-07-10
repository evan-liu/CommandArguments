import Foundation

/// `Arguments` type with `Argument` and/or `Option` fields
public protocol CommandArguments {
    
    /// `Mirror` API requires `init()`
    init()
}

extension CommandArguments {
    
    /**
     Parse from space separated `String`
     
     `try args.parse("build ios")`
     */
    public mutating func parse(_ args: String, from startIndex: Int = 0) throws {
        try parse(args.components(separatedBy: " "), from: startIndex)
    }
    
    /**
     Parse from `Array` of `String`s
     
     `try args.parse(Process.arguments, from: 1)`
     */
    public mutating func parse(_ args: [String], from startIndex: Int = 0) throws {
        try parse(args[startIndex..<args.endIndex])
    }
    
    /**
     Parse from `ArraySlice` of `String`
     
     `try args.parse(Process.arguments.dropFirst())`
     */
    public mutating func parse(_ args: ArraySlice<String>) throws {
        try _parse(args)
    }
    
}

/// A type that can be initialized with an argument value.
public protocol ArgumentConvertible {
    static func parseArgument(_ value: String) -> Self?
}

extension RawRepresentable where RawValue == String {
    public static func parseArgument(_ value: String) -> Self? {
        return Self.init(rawValue: value)
    }
}

extension String: ArgumentConvertible {
    public static func parseArgument(_ value: String) -> String? {
        return value.isEmpty ? nil : value
    }
}
