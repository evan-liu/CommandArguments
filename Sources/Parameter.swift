import Foundation

/// Base class for `Parameter`s
public class Parameter {
    public var name: String?
    public let usage: String?
    
    public init(name: String? = nil, usage: String? = nil) {
        self.name = name
        self.usage = usage
    }
}

public class RequiredParameter: Parameter {
    public var value: String!
}

extension RequiredParameter: Parsable {
    class RequiredParameterParser: Parser {
        let parameter: RequiredParameter
        init(parameter: RequiredParameter) {
            self.parameter = parameter
        }
        
        var canTakeValue = true
        func parseValue(_ value: String) {
            parameter.value = value
            canTakeValue = false
        }
        func finishParsing() throws {
            guard !canTakeValue else {
                throw ParseError.missingRequiredParameter(parameter)
            }
        }
    }
    
    var parser: Parser {
        return RequiredParameterParser(parameter: self)
    }
}
