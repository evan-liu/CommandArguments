import Foundation

/// Optional `Operand` taking 0 or many `String`s
public class VariadicOperand: Operand {
    public var value = [String]()
    public let minCount: Int?
    public let maxCount: Int?
    
    public init(minCount: Int? = nil, maxCount: Int? = nil, name: String? = nil, usage: String? = nil) {
        self.minCount = minCount
        self.maxCount = maxCount
        super.init(name: name, usage: usage)
    }
}

/// Optional `Option` taking 0 or many `String`s
public class VariadicStringOption: Option {
    public var value = [String]()
    public let minCount: Int?
    public let maxCount: Int?
    
    public init(minCount: Int? = nil, maxCount: Int? = nil, longName: String? = nil, shortName: String? = nil, usage: String? = nil) {
        self.minCount = minCount
        self.maxCount = maxCount
        super.init(longName: longName, shortName: shortName, usage: usage)
    }
}

// ----------------------------------------
// MARK: Internal
// ----------------------------------------

protocol VariadicStringArgumentProtocol: Parsable {
    var value: [String] { get set }
    var minCount: Int? { get }
    var maxCount: Int? { get }
}

class VariadicStringArgumentParser: Parser {
    let target: VariadicStringArgumentProtocol
    init(target: VariadicStringArgumentProtocol) {
        self.target = target
    }
    
    var canTakeValue: Bool {
        if let maxCount = target.maxCount where maxCount > 0 {
            return target.value.count < maxCount
        } else {
            return true
        }
    }
    func parseValue(_ value: String) {
        target.value.append(value)
    }
    func validate() throws {
        if let minCount = target.minCount where minCount > target.value.count {
            throw target.missingError
        }
    }
}

extension VariadicStringArgumentProtocol {
    var parser: Parser {
        return VariadicStringArgumentParser(target: self)
    }
}

extension VariadicOperand: VariadicStringArgumentProtocol { }
extension VariadicStringOption: VariadicStringArgumentProtocol { }
