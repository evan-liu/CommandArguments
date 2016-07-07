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
        
        var canTakeValue: Bool {
            return parameter.value == nil
        }
        func parseValue(_ value: String) {
            parameter.value = value
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

public class MultiParameter: Parameter {
    public var value = [String]()
    public let count: Int
    
    public init(count: Int, name: String? = nil, usage: String? = nil) {
        self.count = count
        super.init(name: name, usage: usage)
    }
}

extension MultiParameter: Parsable {
    class MultiParameterParser: Parser {
        let parameter: MultiParameter
        init(parameter: MultiParameter) {
            self.parameter = parameter
        }
        
        var canTakeValue: Bool {
            return parameter.value.count < parameter.count
        }
        func parseValue(_ value: String) {
            parameter.value.append(value)
        }
        func finishParsing() throws {
            guard !canTakeValue else {
                throw ParseError.missingRequiredParameter(parameter)
            }
        }
    }
    
    var parser: Parser {
        return MultiParameterParser(parameter: self)
    }
}

public class OptionalParameter: Parameter {
    public var value: String?
}

extension OptionalParameter: Parsable {
    class OptionalParameterParser: Parser {
        let parameter: OptionalParameter
        init(parameter: OptionalParameter) {
            self.parameter = parameter
        }
        
        var canTakeValue: Bool {
            return parameter.value == nil
        }
        func parseValue(_ value: String) {
            parameter.value = value
        }
    }
    
    var parser: Parser {
        return OptionalParameterParser(parameter: self)
    }
}

public class VariadicParameter: Parameter {
    public var value = [String]()
    public let minCount: Int?
    public let maxCount: Int?
    
    public init(minCount: Int? = nil, maxCount: Int? = nil, name: String? = nil, usage: String? = nil) {
        self.minCount = minCount
        self.maxCount = maxCount
        super.init(name: name, usage: usage)
    }
}

extension VariadicParameter: Parsable {
    class VariadicParameterParser: Parser {
        let parameter: VariadicParameter
        init(parameter: VariadicParameter) {
            self.parameter = parameter
        }
        
        var canTakeValue: Bool {
            if let maxCount = parameter.maxCount where maxCount > 0 {
                return parameter.value.count < maxCount
            } else {
                return true
            }
        }
        func parseValue(_ value: String) {
            parameter.value.append(value)
        }
        func finishParsing() throws {
            if let minCount = parameter.minCount where minCount > parameter.value.count {
                throw ParseError.missingRequiredParameter(parameter)
            }
        }
    }
    
    var parser: Parser {
        return VariadicParameterParser(parameter: self)
    }
}

protocol TrailingParameter {
    var valueCount: Int { get }
}

extension RequiredParameter: TrailingParameter {
    var valueCount: Int { return 1 }
}

extension MultiParameter: TrailingParameter {
    var valueCount: Int { return count }
}
