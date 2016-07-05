import Foundation

/// Base class for `Option`s
public class Option {
    public let longName: String?
    public let shortName: String?
    
    public let usage: String?
    
    public init(longName: String? = nil, shortName: String? = nil, usage: String? = nil) {
        self.longName = longName
        self.shortName = shortName
        self.usage = usage
    }
}

public class StringOption: Option {
    public var value: String
    
    public init(longName: String? = nil, shortName: String? = nil, usage: String? = nil, `default`: String = "") {
        value = `default`
        super.init(longName: longName, shortName: shortName, usage: usage)
    }
}

extension StringOption: Parsable {
    class StringParser: Parser {
        let option: StringOption
        init(option: StringOption) {
            self.option = option
        }
        
        var canTakeValue = true
        func parseValue(_ value: String) {
            option.value = value
            canTakeValue = false
        }
    }
    
    var parser: Parser {
        return StringParser(option: self)
    }
}
