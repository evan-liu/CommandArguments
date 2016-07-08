import Foundation

/// `enum` type can be used by `Argument` and `Option`
public protocol ArgumentEnum {
    init?(rawValue: String)
}

/// `Argument` with `enum`
public class EnumArgument<T: ArgumentEnum>: Argument {
    public var value: T!
    
    public init() { }
}

/// `Option` with `enum`
public class EnumOption<T: ArgumentEnum>: Option {
    public var value: T!
    
    public init() { }
}

// ----------------------------------------
// MARK: Internal
// ----------------------------------------

protocol EnumArgumentProtocol: Parsable {
    associatedtype Enum: ArgumentEnum
    
    var value: Enum! { get set }
}

class EnumArgumentParser<T: EnumArgumentProtocol>: Parser {
    var target: T
    init(target: T) {
        self.target = target
    }
    
    var canTakeValue = true
    func parseValue(_ value: String) {
        target.value = T.Enum.init(rawValue: value)
        canTakeValue = false
    }
    func validate() throws {
        if target.value == nil { throw target.missingError }
    }
}

extension EnumArgument: EnumArgumentProtocol {
    var parser: Parser {
        return EnumArgumentParser(target: self)
    }
}

extension EnumOption: EnumArgumentProtocol {
    var parser: Parser {
        return EnumArgumentParser(target: self)
    }
}
