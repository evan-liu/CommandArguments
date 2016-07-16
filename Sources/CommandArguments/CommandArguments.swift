import Foundation

/**
 `Arguments` type with `Flag`, `Option` or `Operand` fields.
 
 Usage:
 
 - Make a struct or class confirm to `CommandArguments` protocol
 - Add instance variables of `Flag`, `Option` or `Operand`
 - Create an instance `yourArgs`
 - `try yourArgs.parse()`
 
 Example: 
 
 ````
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
 ````
 
 */
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

