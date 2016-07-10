import Foundation

public class VariadicOptionT<T: ArgumentConvertible> {
    public var value = [T]()
    
    let minCount: Int?
    let maxCount: Int?
    
    var name: OptionName
    let usage: String?
    
    public init(minCount: Int? = nil, maxCount: Int? = nil, longName: String? = nil, shortName: String? = nil, usage: String? = nil) {
        self.minCount = minCount
        self.maxCount = maxCount
        self.name = (longName, shortName)
        self.usage = usage
    }

}

public final class VariadicOption: VariadicOptionT<String> {
    public override init(minCount: Int? = nil, maxCount: Int? = nil, longName: String? = nil, shortName: String? = nil, usage: String? = nil) {
        super.init(minCount: minCount, maxCount: maxCount, longName: longName, shortName: shortName, usage: usage)
    }
}

public class VariadicOperandT<T: ArgumentConvertible> {
    public var value = [T]()
    
    public let minCount: Int?
    public let maxCount: Int?
    
    var name: String?
    let usage: String?
    public init(minCount: Int? = nil, maxCount: Int? = nil, name: String? = nil, usage: String? = nil) {
        self.minCount = minCount
        self.maxCount = maxCount
        self.name = name
        self.usage = usage
    }
}

public final class VariadicOperand: VariadicOperandT<String> {
    public override init(minCount: Int? = nil, maxCount: Int? = nil, name: String? = nil, usage: String? = nil) {
        super.init(minCount: minCount, maxCount: maxCount, name: name, usage: usage)
    }
}

// ----------------------------------------
// MARK: Internal
// ----------------------------------------
protocol VariadicArgumentProtocol: Parsable {
    associatedtype Value: ArgumentConvertible
    var value: [Value] { get set }
    var minCount: Int? { get }
    var maxCount: Int? { get }
}

class VariadicArgumentParser<Target: VariadicArgumentProtocol>: Parser {
    let target: Target
    init(target: Target) {
        self.target = target
    }
    
    var parseCount = 0
    var canTakeValue: Bool {
        if let maxCount = target.maxCount where maxCount > 0 {
            return parseCount < maxCount
        } else {
            return true
        }
    }
    func parseValue(_ value: String) {
        if let value = Target.Value(rawValue: value) {
            target.value.append(value)
        }
        parseCount += 1
    }
    func validate() throws {
        if let minCount = target.minCount where minCount > target.value.count {
            throw target.missingError
        }
    }
    
}

extension VariadicArgumentProtocol {
    var parser: Parser {
        return VariadicArgumentParser(target: self)
    }
}

extension VariadicOptionT: OptionProtocol, VariadicArgumentProtocol { }
extension VariadicOperandT: OperandProtocol, VariadicArgumentProtocol { }
