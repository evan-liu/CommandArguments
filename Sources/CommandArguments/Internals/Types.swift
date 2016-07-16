import Foundation

typealias OptionName = (long: String?, short: String?)

protocol OptionProtocol {
    var name: OptionName { get set }
    var usage: String? { get }
}

protocol OperandProtocol {
    var name: String? { get set }
    var usage: String? { get }
}

/// Argument type that may throw `missingError`.
protocol Missable {
    
    var isMissing: Bool { get }
    var missingError: ErrorProtocol { get }
    
}

/**
 A `TrailingOperand` will be parsed before `OptionalOption` and `VariadicOption`.
 
 Example:
 
 ````
 /// Join 2 or more `src` into `dest`
 struct JoinArgs: CommandArguments {
 var src = VariadicOperand(minCount: 2)
 var dest = Operand()
 }
 ````
 
 */
protocol TrailingOperand: Missable {
    /// Count of trailing values to be parsed first.
    var valueCount: Int { get }
}

// ----------------------------------------
// MARK: Helper extensions
// ----------------------------------------
extension OptionProtocol where Self: Missable {
    var missingName: String {
        return name.long ?? name.short!
    }
}
extension OperandProtocol where Self: Missable {
    var missingName: String {
        return name!
    }
}
