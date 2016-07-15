import Foundation

public class Flag {
    public var value = false
    
    var name: OptionName
    let usage: String?
    public init(longName: String? = nil, shortName: String? = nil, usage: String? = nil) {
        self.name = (longName, shortName)
        self.usage = usage
    }
}

// ----------------------------------------
// MARK: Internal
// ----------------------------------------
extension Flag: OptionProtocol, Parsable {
    class FlagParser: Parser {
        let target: Flag
        init(target: Flag) {
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
    var parser: Parser {
        return FlagParser(target: self)
    }
}
