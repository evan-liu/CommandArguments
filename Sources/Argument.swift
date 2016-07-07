import Foundation

/// Base class for `Argument`s
public class Argument {
    public var name: String?
    public let usage: String?
    
    public init(name: String? = nil, usage: String? = nil) {
        self.name = name
        self.usage = usage
    }
}

public class RequiredArgument: Argument {
    public var value: String!
}

extension RequiredArgument: Parsable {
    class RequiredArgumentParser: Parser {
        let argument: RequiredArgument
        init(argument: RequiredArgument) {
            self.argument = argument
        }
        
        var canTakeValue: Bool {
            return argument.value == nil
        }
        func parseValue(_ value: String) {
            argument.value = value
        }
        func finishParsing() throws {
            guard !canTakeValue else {
                throw ParseError.missingRequiredArgument(argument)
            }
        }
    }
    
    var parser: Parser {
        return RequiredArgumentParser(argument: self)
    }
}

public class MultiArgument: Argument {
    public var value = [String]()
    public let count: Int
    
    public init(count: Int, name: String? = nil, usage: String? = nil) {
        self.count = count
        super.init(name: name, usage: usage)
    }
}

extension MultiArgument: Parsable {
    class MultiArgumentParser: Parser {
        let argument: MultiArgument
        init(argument: MultiArgument) {
            self.argument = argument
        }
        
        var canTakeValue: Bool {
            return argument.value.count < argument.count
        }
        func parseValue(_ value: String) {
            argument.value.append(value)
        }
        func finishParsing() throws {
            guard !canTakeValue else {
                throw ParseError.missingRequiredArgument(argument)
            }
        }
    }
    
    var parser: Parser {
        return MultiArgumentParser(argument: self)
    }
}

public class OptionalArgument: Argument {
    public var value: String?
}

extension OptionalArgument: Parsable {
    class OptionalArgumentParser: Parser {
        let argument: OptionalArgument
        init(argument: OptionalArgument) {
            self.argument = argument
        }
        
        var canTakeValue: Bool {
            return argument.value == nil
        }
        func parseValue(_ value: String) {
            argument.value = value
        }
    }
    
    var parser: Parser {
        return OptionalArgumentParser(argument: self)
    }
}

public class VariadicArgument: Argument {
    public var value = [String]()
    public let minCount: Int?
    public let maxCount: Int?
    
    public init(minCount: Int? = nil, maxCount: Int? = nil, name: String? = nil, usage: String? = nil) {
        self.minCount = minCount
        self.maxCount = maxCount
        super.init(name: name, usage: usage)
    }
}

extension VariadicArgument: Parsable {
    class VariadicArgumentParser: Parser {
        let argument: VariadicArgument
        init(argument: VariadicArgument) {
            self.argument = argument
        }
        
        var canTakeValue: Bool {
            if let maxCount = argument.maxCount where maxCount > 0 {
                return argument.value.count < maxCount
            } else {
                return true
            }
        }
        func parseValue(_ value: String) {
            argument.value.append(value)
        }
        func finishParsing() throws {
            if let minCount = argument.minCount where minCount > argument.value.count {
                throw ParseError.missingRequiredArgument(argument)
            }
        }
    }
    
    var parser: Parser {
        return VariadicArgumentParser(argument: self)
    }
}

protocol TrailingArgument {
    var valueCount: Int { get }
}

extension RequiredArgument: TrailingArgument {
    var valueCount: Int { return 1 }
}

extension MultiArgument: TrailingArgument {
    var valueCount: Int { return count }
}
