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
        let Argument: RequiredArgument
        init(Argument: RequiredArgument) {
            self.Argument = Argument
        }
        
        var canTakeValue: Bool {
            return Argument.value == nil
        }
        func parseValue(_ value: String) {
            Argument.value = value
        }
        func finishParsing() throws {
            guard !canTakeValue else {
                throw ParseError.missingRequiredArgument(Argument)
            }
        }
    }
    
    var parser: Parser {
        return RequiredArgumentParser(Argument: self)
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
        let Argument: MultiArgument
        init(Argument: MultiArgument) {
            self.Argument = Argument
        }
        
        var canTakeValue: Bool {
            return Argument.value.count < Argument.count
        }
        func parseValue(_ value: String) {
            Argument.value.append(value)
        }
        func finishParsing() throws {
            guard !canTakeValue else {
                throw ParseError.missingRequiredArgument(Argument)
            }
        }
    }
    
    var parser: Parser {
        return MultiArgumentParser(Argument: self)
    }
}

public class OptionalArgument: Argument {
    public var value: String?
}

extension OptionalArgument: Parsable {
    class OptionalArgumentParser: Parser {
        let Argument: OptionalArgument
        init(Argument: OptionalArgument) {
            self.Argument = Argument
        }
        
        var canTakeValue: Bool {
            return Argument.value == nil
        }
        func parseValue(_ value: String) {
            Argument.value = value
        }
    }
    
    var parser: Parser {
        return OptionalArgumentParser(Argument: self)
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
        let Argument: VariadicArgument
        init(Argument: VariadicArgument) {
            self.Argument = Argument
        }
        
        var canTakeValue: Bool {
            if let maxCount = Argument.maxCount where maxCount > 0 {
                return Argument.value.count < maxCount
            } else {
                return true
            }
        }
        func parseValue(_ value: String) {
            Argument.value.append(value)
        }
        func finishParsing() throws {
            if let minCount = Argument.minCount where minCount > Argument.value.count {
                throw ParseError.missingRequiredArgument(Argument)
            }
        }
    }
    
    var parser: Parser {
        return VariadicArgumentParser(Argument: self)
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
