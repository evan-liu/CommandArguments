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
protocol RequiredArgumentProtocol: Parsable, Missable {
    associatedtype Value: ArgumentConvertible
    var value: Value! { get set }
}

extension RequiredArgumentProtocol {
    var isMissing: Bool { return value == nil }
}

final class RequiredArgumentParser<Target: RequiredArgumentProtocol>: Parser {
    let target: Target
    init(target: Target) {
        self.target = target
    }
    
    var canTakeValue = true
    func parseValue(_ value: String) {
        target.value = Target.Value(rawValue: value)
        canTakeValue = false
    }
    func validate() throws {
        if target.isMissing { throw target.missingError }
    }
}

extension RequiredArgumentProtocol {
    var parser: Parser {
        return RequiredArgumentParser(target: self)
    }
}

extension OptionT: OptionProtocol, RequiredArgumentProtocol {
    var missingError: Error {
        return ParseError.missing("Missing or invalid value for option \(missingName)")
    }
}

extension OperandT: OperandProtocol, RequiredArgumentProtocol {
    var missingError: Error {
        return ParseError.missing("Missing or invalid value for operand \(missingName)")
    }
}

extension OperandT: TrailingOperand {
    var valueCount: Int { return 1 }
}
