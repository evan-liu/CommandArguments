import Foundation

/// `Bool` flags
public class BoolOption: Option {
    public var value: Bool = false
}

// ----------------------------------------
// MARK: Internal
// ----------------------------------------
class BoolParser: Parser {
    let target: BoolOption
    init(target: BoolOption) {
        self.target = target
    }
    
    var canTakeValue = true
    func parseValue(_ value: String) {
        target.value = value == "true"
        canTakeValue = false
    }
    func finishParsing() {
        if canTakeValue { // -x or --yz without values
            target.value = true
        }
    }
}

extension BoolOption: Parsable {
    var parser: Parser {
        return BoolParser(target: self)
    }
}
