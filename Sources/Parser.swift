import Foundation

public enum TypeError: ErrorProtocol {
    
    case missingOptionName(String?)
    
    case missingArgumentName(String?)
    
    case invalidShortOptionName(String)
    
    case duplicatedOptionName(String)
    
    case duplicatedArgumentName(String)
}

public enum ParseError: ErrorProtocol {
    
    case invalidOption(String)
    
    case invalidArgument(String)
    
    case missingRequiredOption(Option)
    
    case missingRequiredArgument(Argument)
}

protocol Parsable: class {
    var parser: Parser { get }
}

protocol Parser {
    
    /// If the receiver can take more values
    var canTakeValue: Bool { get }
    
    /// Parse and take current value
    func parseValue(_ value: String) throws
    
    /// Finish current parsing when `canTakeValue==false` or another argument parsing starts
    func finishParsing() throws
    
    /// Validate the receiver after all arguments are parsed
    func validate() throws
}

extension Parser {
    func finishParsing() { }
    func validate() { }
}
