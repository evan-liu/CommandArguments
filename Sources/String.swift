import Foundation

/// Required `Argument` taking one `String`
public class RequiredArgument: Argument {
    public var value: String!
}

/// Required `Option` taking one `String`
public class StringOption: Option {
    public var value: String!
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

extension RequiredArgument: StringArgumentProtocol { }
extension StringOption: StringArgumentProtocol { }
