import Foundation

// ----------------------------------------
// MARK: Internal
// ----------------------------------------

protocol Parsable: class {
    var parser: Parser { get }
    
    var missingError: ErrorProtocol { get }
}

extension Argument {
    var missingError: ErrorProtocol {
        return ParseError.missingRequiredArgument(self)
    }
}

extension Option {
    var missingError: ErrorProtocol {
        return ParseError.missingRequiredOption(self)
    }
}

protocol Parser {
    
    /// If the receiver can take more values
    var canTakeValue: Bool { get }
    
    /// Parse and take current value
    func parseValue(_ value: String) throws
    
    /// Finish current parsing when `!canTakeValue` or another argument parsing starts
    func finishParsing() throws
    
    /// Validate the receiver after all arguments are parsed
    func validate() throws
}

extension Parser {
    
    func finishParsing() throws { }
    
    func validate() throws { }
}
