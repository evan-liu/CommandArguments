import Foundation

public enum TypeError: ErrorProtocol {
    
    case invalidShortOptionName(String)
    
    case duplicatedOptionName(String)
    
    case duplicatedParameterName(String)
    
    case unknownType
}

public enum ParseError: ErrorProtocol {
    
    case invalidOption(String)
    
    case missingRequiredOption(Option)
    
    case invalidParameter(String)
    
    case missingRequiredParameter(Parameter)
}

protocol Parsable: class {
    var parser: Parser { get }
}

protocol Parser {
    
    var canTakeValue: Bool { get }
    
    func parseValue(_ value: String) throws
    
    func finishParsing() throws
}

extension Parser {
    // Do nothing by default
    func finishParsing() { }
}
