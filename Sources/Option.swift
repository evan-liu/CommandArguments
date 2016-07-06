import Foundation

/// Base class for `Option`s
public class Option {
    public var longName: String?
    public var shortName: String?
    
    public let usage: String?
    
    public init(longName: String? = nil, shortName: String? = nil, usage: String? = nil) {
        self.longName = longName
        self.shortName = shortName
        self.usage = usage
    }
}

/// `Bool` flags
public class BoolOption: Option {
    public var value: Bool = false
}

extension BoolOption: Parsable {
    class BoolParser: Parser {
        let option: BoolOption
        init(option: BoolOption) {
            self.option = option
        }
        
        var canTakeValue = true
        func parseValue(_ value: String) {
            option.value = value == "true"
            canTakeValue = false
        }
        func finishParsing() {
            if canTakeValue { // -x or --yz without values
                option.value = true
            }
        }
    }
    
    var parser: Parser {
        return BoolParser(option: self)
    }
}

public class StringOption: Option {
    public var value: String!
}

extension StringOption: Parsable {
    class StringParser: Parser {
        let option: StringOption
        init(option: StringOption) {
            self.option = option
        }
        
        var canTakeValue: Bool {
            return option.value == nil
        }
        func parseValue(_ value: String) {
            option.value = value
        }
        func validate() throws {
            if canTakeValue {
                throw ParseError.missingRequiredOption(option)
            }
        }
    }
    
    var parser: Parser {
        return StringParser(option: self)
    }
}

public class MultiStringOption: Option {
    public var value = [String]()
    public let count: Int
    
    public init(count: Int, longName: String? = nil, shortName: String? = nil, usage: String? = nil) {
        self.count = count
        super.init(longName: longName, shortName: shortName, usage: usage)
    }
}

extension MultiStringOption: Parsable {
    class MultiStringOptionParser: Parser {
        let option: MultiStringOption
        init(option: MultiStringOption) {
            self.option = option
        }
        
        var canTakeValue: Bool {
            return option.value.count < option.count
        }
        func parseValue(_ value: String) {
            option.value.append(value)
        }
        func validate() throws {
            if canTakeValue {
                throw ParseError.missingRequiredOption(option)
            }
        }
    }
    
    var parser: Parser {
        return MultiStringOptionParser(option: self)
    }
}

public class OptionalStringOption: Option {
    public var value: String?
    
    public init(`default`: String? = nil, longName: String? = nil, shortName: String? = nil, usage: String? = nil) {
        self.value = `default`
        super.init(longName: longName, shortName: shortName, usage: usage)
    }
}

extension OptionalStringOption: Parsable {
    class OptionalStringParser: Parser {
        let option: OptionalStringOption
        init(option: OptionalStringOption) {
            self.option = option
        }
        
        var canTakeValue: Bool = true
        func parseValue(_ value: String) {
            if !value.isEmpty {
                option.value = value
            }
            canTakeValue = false
        }
    }
    
    var parser: Parser {
        return OptionalStringParser(option: self)
    }
}

public class VariadicStringOption: Option {
    public var value = [String]()
    public let minCount: Int?
    public let maxCount: Int?
    
    public init(minCount: Int? = nil, maxCount: Int? = nil, longName: String? = nil, shortName: String? = nil, usage: String? = nil) {
        self.minCount = minCount
        self.maxCount = maxCount
        super.init(longName: longName, shortName: shortName, usage: usage)
    }
}

extension VariadicStringOption: Parsable {
    class VariadicStringParser: Parser {
        let option: VariadicStringOption
        init(option: VariadicStringOption) {
            self.option = option
        }
        
        var canTakeValue: Bool {
            if let maxCount = option.maxCount where maxCount > 0 {
                return option.value.count < maxCount
            } else {
                return true
            }
        }
        func parseValue(_ value: String) {
            option.value.append(value)
        }
        func validate() throws {
            if let minCount = option.minCount where minCount > option.value.count {
                throw ParseError.missingRequiredOption(option)
            }
        }
    }
    
    var parser: Parser {
        return VariadicStringParser(option: self)
    }
}
