import Foundation

/// `Argument` with `enum`
public class CustomArgument<T: RawRepresentable where T.RawValue == String>: Argument {
    public var value: T!
    
    public init() { }
}

/// `Option` with `enum`
public class CustomOption<T: RawRepresentable where T.RawValue == String>: Option {
    public var value: T!
    
    public init() { }
}

// ----------------------------------------
// MARK: Internal
// ----------------------------------------

protocol CustomArgumentProtocol: Parsable {
    associatedtype CustomType
    
    var value: CustomType! { get set }
    
    func parseValue(_ value: String)
}

class CustomArgumentParser<T: CustomArgumentProtocol>: Parser {
    var target: T
    init(target: T) {
        self.target = target
    }
    
    var canTakeValue = true
    func parseValue(_ value: String) {
        target.parseValue(value)
        canTakeValue = false
    }
    func validate() throws {
        if target.value == nil { throw target.missingError }
    }
}

extension CustomArgumentProtocol {
    var parser: Parser {
        return CustomArgumentParser(target: self)
    }
}

extension CustomArgument: CustomArgumentProtocol {
    func parseValue(_ value: String) {
        self.value = T(rawValue: value)
    }
}
extension CustomOption: CustomArgumentProtocol {
    func parseValue(_ value: String) {
        self.value = T(rawValue: value)
    }
}
