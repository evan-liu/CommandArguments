import Foundation

/// Optional `Argument` taking 0 or 1 `String`
public class OptionalArgument: Argument {
    public var value: String?
    
    public init(`default`: String? = nil, name: String? = nil, usage: String? = nil) {
        self.value = `default`
        super.init(name: name, usage: usage)
    }
}

/// Optional `Option` taking 0 or 1 `String`
public class OptionalStringOption: Option {
    public var value: String?
    
    public init(`default`: String? = nil, longName: String? = nil, shortName: String? = nil, usage: String? = nil) {
        self.value = `default`
        super.init(longName: longName, shortName: shortName, usage: usage)
    }
}

// ----------------------------------------
// MARK: Internal
// ----------------------------------------

protocol OptionalStringArgumentProtocol: Parsable {
    var value: String? { get set }
}

class OptionalStringArgumentParser: Parser {
    let target: OptionalStringArgumentProtocol
    init(target: OptionalStringArgumentProtocol) {
        self.target = target
    }
    
    var canTakeValue: Bool = true
    func parseValue(_ value: String) {
        if !value.isEmpty {
            target.value = value
        }
        canTakeValue = false
    }
}

extension OptionalStringArgumentProtocol {
    var parser: Parser {
        return OptionalStringArgumentParser(target: self)
    }
}

extension OptionalArgument: OptionalStringArgumentProtocol { }
extension OptionalStringOption: OptionalStringArgumentProtocol { }
