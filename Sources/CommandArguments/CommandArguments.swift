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
        let fields = Mirror(reflecting: self).children.filter { $0.value is Parsable }
        let (options, operands) = try parseFields(fields)
        
        var operandValues = [String]()
        try parseOptions(options, withArgs: args, operandValues: &operandValues)
        try parseOperands(operands, withValues: operandValues)
    }
    
}

/// A type that can be initialized with an argument value.
public protocol ArgumentConvertible {
    init?(rawValue: String)
}

extension String: ArgumentConvertible {
    public init?(rawValue: String) {
        guard !rawValue.isEmpty else { return nil }
        self = rawValue
    }
}
