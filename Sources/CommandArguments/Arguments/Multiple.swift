import Foundation

public class MultipleOptionT<T: ArgumentConvertible> {
    public var value = [T]()
    
    let count: Int
    
    var name: OptionName
    let usage: String?
    public init(count: Int, longName: String? = nil, shortName: String? = nil, usage: String? = nil) {
        self.count = count
        self.name = (longName, shortName)
        self.usage = usage
    }
    
}

public final class MultipleOption: MultipleOptionT<String> {
    public override init(count: Int, longName: String? = nil, shortName: String? = nil, usage: String? = nil) {
        super.init(count: count, longName: longName, shortName: shortName, usage: usage)
    }
}

public class MultipleOperandT<T: ArgumentConvertible> {
    public var value = [T]()
    
    let count: Int
    
    var name: String?
    let usage: String?
    public init(count: Int, name: String? = nil, usage: String? = nil) {
        self.count = count
        self.name = name
        self.usage = usage
    }
    
    var synopsis: String {
        return "\(name!) ..."
    }
}

public final class MultipleOperand: MultipleOperandT<String> {
    public override init(count: Int, name: String? = nil, usage: String? = nil) {
        super.init(count: count, name: name, usage: usage)
    }
}

// ----------------------------------------
// MARK: Internal
// ----------------------------------------
protocol MultipleArgumentProtocol: Parsable, Missable {
    associatedtype Value: ArgumentConvertible
    var value: [Value] { get set }
    var count: Int { get }
}

extension MultipleArgumentProtocol {
    var isMissing: Bool { return value.count < count }
}

final class MultipleArgumentParser<Target: MultipleArgumentProtocol>: Parser {
    let target: Target
    init(target: Target) {
        self.target = target
    }
    
    var parseCount = 0
    var canTakeValue: Bool {
        return parseCount < target.count
    }
    func parseValue(_ value: String) {
        if let value = Target.Value(rawValue: value) {
            target.value.append(value)
        }
        parseCount += 1
    }
    func validate() throws {
        if target.isMissing { throw target.missingError }
    }

}

extension MultipleArgumentProtocol {
    var parser: Parser {
        return MultipleArgumentParser(target: self)
    }
}

extension MultipleOptionT: OptionProtocol, MultipleArgumentProtocol {
    var missingError: ErrorProtocol {
        return ParseError.missing("Missing or invalid values (need \(count)) for option \(missingName)")
    }
}

extension MultipleOperandT: OperandProtocol, MultipleArgumentProtocol {
    var missingError: ErrorProtocol {
        return ParseError.missing("Missing or invalid values (need \(count)) for operand \(missingName)")
    }
}

extension MultipleOperandT: TrailingOperand {
    var valueCount: Int { return count }
}
