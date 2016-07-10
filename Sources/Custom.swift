import Foundation

/// A type that can be initialized with an argument value.
public protocol ArgumentConvertible {
    static func parseArgument(_ value: String) -> Self?
}

extension RawRepresentable where RawValue == String {
    public static func parseArgument(_ value: String) -> Self? {
        return Self.init(rawValue: value)
    }
}

/// `Operand` with `enum`
public class CustomOperand<T: ArgumentConvertible>: Operand {
    public var value: T!
    
    public init() { }
}

/// `Option` with `enum`
public class CustomOption<T: ArgumentConvertible>: Option {
    public var value: T!
    
    public init() { }
}

// ----------------------------------------
// MARK: Internal
// ----------------------------------------

protocol CustomArgumentProtocol: Parsable {
    associatedtype CustomType: ArgumentConvertible
    
    var value: CustomType! { get set }
}

class CustomArgumentParser<T: CustomArgumentProtocol>: Parser {
    var target: T
    init(target: T) {
        self.target = target
    }
    
    var canTakeValue = true
    func parseValue(_ value: String) {
        target.value = T.CustomType.parseArgument(value)
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

extension CustomOperand: CustomArgumentProtocol { }
extension CustomOption: CustomArgumentProtocol { }
