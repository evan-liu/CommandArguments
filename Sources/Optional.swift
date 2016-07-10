import Foundation

public class OptionalOptionT<T: ArgumentConvertible> {
    public var value: T?
    
    var name: OptionName
    let usage: String?
    public init(longName: String? = nil, shortName: String? = nil, usage: String? = nil) {
        self.name = (longName, shortName)
        self.usage = usage
    }
}

public final class OptionalOption: OptionalOptionT<String> {
    public override init(longName: String? = nil, shortName: String? = nil, usage: String? = nil) {
        super.init(longName: longName, shortName: shortName, usage: usage)
    }
}

public class OptionalOperandT<T: ArgumentConvertible> {
    public var value: T?
    
    var name: String?
    let usage: String?
    public init(name: String? = nil, usage: String? = nil) {
        self.name = name
        self.usage = usage
    }
    
}

public final class OptionalOperand: OptionalOperandT<String> {
    public override init(name: String? = nil, usage: String? = nil) {
        super.init(name: name, usage: usage)
    }
}

// ----------------------------------------
// MARK: Internal
// ----------------------------------------
protocol OptionalArgumentProtocol: Parsable {
    associatedtype Value: ArgumentConvertible
    var value: Value? { get set }
}

class OptionalArgumentParser<Target: OptionalArgumentProtocol>: Parser {
    let target: Target
    init(target: Target) {
        self.target = target
    }
    
    var canTakeValue = true
    func parseValue(_ value: String) {
        target.value = Target.Value(rawValue: value)
        canTakeValue = false
    }
}

extension OptionalArgumentProtocol {
    var parser: Parser {
        return OptionalArgumentParser(target: self)
    }
}

extension OptionalOptionT: OptionProtocol, OptionalArgumentProtocol { }
extension OptionalOperandT: OperandProtocol, OptionalArgumentProtocol { }
