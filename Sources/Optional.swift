import Foundation

public class OptionalOption {
    public var value: String?
    
    var name: OptionName
    let usage: String?
    public init(longName: String? = nil, shortName: String? = nil, usage: String? = nil) {
        self.name = (longName, shortName)
        self.usage = usage
    }
    
}

public class OptionalOperand {
    public var value: String?
    
    var name: String?
    let usage: String?
    public init(name: String? = nil, usage: String? = nil) {
        self.name = name
        self.usage = usage
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
        target.value = Target.Value.parseArgument(value)
        canTakeValue = false
    }
}

extension OptionalArgumentProtocol {
    var parser: Parser {
        return OptionalArgumentParser(target: self)
    }
}

extension OptionalOption: OptionProtocol, OptionalArgumentProtocol { }
extension OptionalOperand: OperandProtocol, OptionalArgumentProtocol { }
