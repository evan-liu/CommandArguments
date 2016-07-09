import Foundation

/// Errors when parsing the arguments type
public enum TypeError: ErrorProtocol {
    
    /// Throws when option field has no names and field name is used by other option
    case missingOptionName(String?)
    
    /// Throws when argument field has no names and field name is used by other argument
    case missingArgumentName(String?)
    
    /// Throws when short option name is not one-letter (`a-zA-Z`)
    case invalidShortOptionName(String)
    
    /// Throws when two or more options have the same names
    case duplicatedOptionName(String)
    
    /// Throws when two or more arguments have the same names
    case duplicatedArgumentName(String)
}

/// Errors when parsing arguments
public enum ParseError: ErrorProtocol {
    
    /// Throws when parsing an unknown option
    case invalidOption(String)
    
    /// Throws when parsing an unknown argument
    case invalidArgument(String)
    
    /// Throws when required option is missing
    case missingRequiredOption(Option)
    
    /// Throws when required argument is missing
    case missingRequiredArgument(Argument)
}

extension TypeError: CustomStringConvertible {
    public var description: String {
        switch self {
        case .missingOptionName(let name):
            return "Missing name for option field \(name ?? "?")"
        case .missingArgumentName(let name):
            return "Missing name for argument field \(name ?? "?")"
        case .invalidShortOptionName(let name):
            return "Invalid short option name \(name)"
        case .duplicatedOptionName(let name):
            return "Duplicated option name \(name)"
        case .duplicatedArgumentName(let name):
            return "Duplicated argument name \(name)"
        }
    }
}

extension ParseError: CustomStringConvertible {
    public var description: String {
        switch self {
        case .invalidOption(let name):
            return "Invalid option \(name)"
        case .invalidArgument(let value):
            return "Invalid argument value \(value)"
        case .missingRequiredOption(let option):
            return "Missing required option \(option.longName ?? option.shortName!)"
        case .missingRequiredArgument(let argument):
            return "Missing required argument \(argument.name!)"
        }
    }
}
