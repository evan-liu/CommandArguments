import Foundation

public class DefaultedOptionT<T: ArgumentConvertible> {
    public var value: T
    
    var name: OptionName
    let usage: String?
    public init(_ defaultValue: T, longName: String? = nil, shortName: String? = nil, usage: String? = nil) {
        value = defaultValue
        self.name = (longName, shortName)
        self.usage = usage
    }
}

public final class DefaultedOption: DefaultedOptionT<String> {
    public override init(_ defaultValue: String, longName: String? = nil, shortName: String? = nil, usage: String? = nil) {
        super.init(defaultValue, longName: longName, shortName: shortName, usage: usage)
    }
}

public class DefaultedOperandT<T: ArgumentConvertible> {
    public var value: T
    
    var name: String?
    let usage: String?
    public init(_ defaultValue: T, name: String? = nil, usage: String? = nil) {
        value = defaultValue
        self.name = name
        self.usage = usage
    }
    
}

public final class DefaultedOperand: DefaultedOperandT<String> {
    public override init(_ defaultValue: String, name: String? = nil, usage: String? = nil) {
        super.init(defaultValue, name: name, usage: usage)
    }
}

// ----------------------------------------
// MARK: Internal
// ----------------------------------------
protocol DefaultedArgumentProtocol: Parsable {
    associatedtype Value: ArgumentConvertible
    var value: Value { get set }
}

final class DefaultedArgumentParser<Target: DefaultedArgumentProtocol>: Parser {
    let target: Target
    init(target: Target) {
        self.target = target
    }
    
    var canTakeValue = true
    func parseValue(_ value: String) {
        if let value = Target.Value(rawValue: value) {
            target.value = value
        }
        canTakeValue = false
    }
}

extension DefaultedArgumentProtocol {
    var parser: Parser {
        return DefaultedArgumentParser(target: self)
    }
}

extension DefaultedOptionT: OptionProtocol, DefaultedArgumentProtocol { }
extension DefaultedOperandT: OperandProtocol, DefaultedArgumentProtocol { }
