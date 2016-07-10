import Foundation

/// Optional `Option` taking 0 or many `String`s
public class VariadicOption {
    public var value = [String]()
    
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


/// Optional `Operand` taking 0 or many `String`s
public class VariadicOperand {
    public var value = [String]()
    
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
        if let value = Target.Value.parseArgument(value) {
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

extension VariadicOption: OptionProtocol, VariadicArgumentProtocol { }
extension VariadicOperand: OperandProtocol, VariadicArgumentProtocol { }
