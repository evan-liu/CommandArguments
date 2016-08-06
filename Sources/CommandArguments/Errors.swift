import Foundation

/// Errors when parsing the arguments type
public enum TypeError: Error {
    
    /// Throws when option field has no names and field name is used by other option
    case missingOptionName(String?)
    
    /// Throws when operand field has no names and field name is used by other operand
    case missingOperandName(String?)
    
    /// Throws when short option name is not single-letter (`a-zA-Z`)
    case invalidShortOptionName(String)
    
    /// Throws when two or more options have the same names
    case duplicatedOptionName(String)
    
    /// Throws when two or more operands have the same names
    case duplicatedOperandName(String)
}

/// Errors when parsing arguments
public enum ParseError: Error {
    
    /// Throws when parsing an unknown option
    case invalidOption(String)
    
    /// Throws when parsing an unknown operand
    case invalidOperand(String)
    
    /// Throws when missing some option or operand
    case missing(String)
}

extension TypeError: CustomStringConvertible {
    public var description: String {
        switch self {
        case .missingOptionName(let name):
            return "Missing name for option field \(name ?? "?")"
        case .missingOperandName(let name):
            return "Missing name for argument field \(name ?? "?")"
        case .invalidShortOptionName(let name):
            return "Invalid short option name \(name)"
        case .duplicatedOptionName(let name):
            return "Duplicated option name \(name)"
        case .duplicatedOperandName(let name):
            return "Duplicated operand name \(name)"
        }
    }
}

extension ParseError: CustomStringConvertible {
    public var description: String {
        switch self {
        case .invalidOption(let name):
            return "Invalid option \(name)"
        case .invalidOperand(let value):
            return "Invalid operand value \(value)"
        case .missing(let desc):
            return desc
        }
    }
}
