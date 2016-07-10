import Foundation

/// Required `Operand` taking multiple `String`s
public class MultiOperand: Operand {
    public var value = [String]()
    public let count: Int
    
    public init(count: Int, name: String? = nil, usage: String? = nil) {
        self.count = count
        super.init(name: name, usage: usage)
    }
}

/// Required `Option` taking multiple `String`s
public class MultiStringOption: Option {
    public var value = [String]()
    public let count: Int
    
    public init(count: Int, longName: String? = nil, shortName: String? = nil, usage: String? = nil) {
        self.count = count
        super.init(longName: longName, shortName: shortName, usage: usage)
    }
}

// ----------------------------------------
// MARK: Internal
// ----------------------------------------

protocol MultiStringArgumentProtocol: Parsable {
    var value: [String] { get set }
    var count: Int { get }
}

class MultiStringArgumentParser: Parser {
    let target: MultiStringArgumentProtocol
    init(target: MultiStringArgumentProtocol) {
        self.target = target
    }
    
    var canTakeValue: Bool {
        return target.value.count < target.count
    }
    func parseValue(_ value: String) {
        target.value.append(value)
    }
    func validate() throws {
        if canTakeValue { throw target.missingError }
    }
}

extension MultiStringArgumentProtocol {
    var parser: Parser {
        return MultiStringArgumentParser(target: self)
    }
}

extension MultiOperand: MultiStringArgumentProtocol { }
extension MultiStringOption: MultiStringArgumentProtocol { }
