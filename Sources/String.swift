import Foundation

/// Required `Operand` taking one `String`
public class RequiredOperand: Operand {
    public var value: String!
    
    public override init(name: String? = nil, usage: String? = nil) {
        super.init(name: name, usage: usage)
    }
}

/// Required `Option` taking one `String`
public class StringOption: Option {
    public var value: String!
    
    public override init(longName: String? = nil, shortName: String? = nil, usage: String? = nil) {
        super.init(longName: longName, shortName: shortName, usage: usage)
    }
}

// ----------------------------------------
// MARK: Internal
// ----------------------------------------

protocol StringArgumentProtocol: Parsable {
    var value: String! { get set }
}

class StringArgumentParser: Parser {
    let target: StringArgumentProtocol
    init(target: StringArgumentProtocol) {
        self.target = target
    }
    
    var canTakeValue = true
    func parseValue(_ value: String) {
        target.value = value
        canTakeValue = false
    }
    func validate() throws {
        if canTakeValue { throw target.missingError }
    }
}

extension StringArgumentProtocol {
    var parser: Parser {
        return StringArgumentParser(target: self)
    }
}

extension RequiredOperand: StringArgumentProtocol { }
extension StringOption: StringArgumentProtocol { }
