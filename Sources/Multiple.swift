import Foundation

public class MultipleOption {
    public var value = [String]()
    
    let count: Int
    
    var name: OptionName
    let usage: String?
    public init(count: Int, longName: String? = nil, shortName: String? = nil, usage: String? = nil) {
        self.count = count
        self.name = (longName, shortName)
        self.usage = usage
    }
    
}

public class MultipleOperand {
    public var value = [String]()
    
    let count: Int
    
    var name: String?
    let usage: String?
    public init(count: Int, name: String? = nil, usage: String? = nil) {
        self.count = count
        self.name = name
        self.usage = usage
    }
    
}

// ----------------------------------------
// MARK: Internal
// ----------------------------------------
protocol MultipleArgumentProtocol: Parsable {
    associatedtype Value: ArgumentConvertible
    var value: [Value] { get set }
    var count: Int { get }
}

class MultipleArgumentParser<Target: MultipleArgumentProtocol>: Parser {
    let target: Target
    init(target: Target) {
        self.target = target
    }
    
    var parseCount = 0
    var canTakeValue: Bool {
        return parseCount < target.count
    }
    func parseValue(_ value: String) {
        if let value = Target.Value.parseArgument(value) {
            target.value.append(value)
        }
        parseCount += 1
    }
    func validate() throws {
        if target.value.count < target.count {
            throw target.missingError
        }
    }

}

extension MultipleArgumentProtocol {
    var parser: Parser {
        return MultipleArgumentParser(target: self)
    }
}

extension MultipleOption: OptionProtocol, MultipleArgumentProtocol { }
extension MultipleOperand: OperandProtocol, MultipleArgumentProtocol { }
