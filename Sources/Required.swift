import Foundation

public class OptionT<T: ArgumentConvertible> {
    public var value: T!
    
    var name: OptionName
    let usage: String?
    public init(longName: String? = nil, shortName: String? = nil, usage: String? = nil) {
        self.name = (longName, shortName)
        self.usage = usage
    }
}

public final class Option: OptionT<String> {
    public override init(longName: String? = nil, shortName: String? = nil, usage: String? = nil) {
        super.init(longName: longName, shortName: shortName, usage: usage)
    }
}

public class OperandT<T: ArgumentConvertible> {
    public var value: T!
    
    var name: String?
    let usage: String?
    public init(name: String? = nil, usage: String? = nil) {
        self.name = name
        self.usage = usage
    }
    
}

public final class Operand: OperandT<String> {
    public override init(name: String? = nil, usage: String? = nil) {
        super.init(name: name, usage: usage)
    }
}

// ----------------------------------------
// MARK: Internal
// ----------------------------------------
protocol RequiredArgumentProtocol: Parsable {
    associatedtype Value: ArgumentConvertible
    var value: Value! { get set }
}

class RequiredArgumentParser<Target: RequiredArgumentProtocol>: Parser {
    let target: Target
    init(target: Target) {
        self.target = target
    }
    
    var canTakeValue = true
    func parseValue(_ value: String) {
        target.value = Target.Value.parseArgument(value)
        canTakeValue = false
    }
    func validate() throws {
        if canTakeValue { throw target.missingError }
    }
}

extension RequiredArgumentProtocol {
    var parser: Parser {
        return RequiredArgumentParser(target: self)
    }
}

extension OptionT: OptionProtocol, RequiredArgumentProtocol { }
extension OperandT: OperandProtocol, RequiredArgumentProtocol { }
