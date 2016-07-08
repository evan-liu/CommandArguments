import Foundation

public protocol ArgumentEnum {
    init?(rawValue: String)
}

public class EnumArgument<T: ArgumentEnum>: Argument {
    public var value: T!
    
    public init() {
    }
}

class EnumArgumentParser<T: ArgumentEnum>: Parser {
    let argument: EnumArgument<T>
    init(argument: EnumArgument<T>) {
        self.argument = argument
    }
    
    var canTakeValue: Bool {
        return argument.value == nil
    }
    func parseValue(_ value: String) {
        argument.value = T.init(rawValue: value)
    }
    func finishParsing() throws {
        guard !canTakeValue else {
            throw ParseError.missingRequiredArgument(argument)
        }
    }
}

extension EnumArgument: Parsable {
    var parser: Parser {
        return EnumArgumentParser(argument: self)
    }
}

public class EnumOption<T: ArgumentEnum>: Option {
    public var value: T!
    
    public init() {
    }
}

class EnumOptionParser<T: ArgumentEnum>: Parser {
    let option: EnumOption<T>
    init(option: EnumOption<T>) {
        self.option = option
    }
    
    var canTakeValue: Bool {
        return option.value == nil
    }
    func parseValue(_ value: String) {
        option.value = T.init(rawValue: value)
    }
    func finishParsing() throws {
        guard !canTakeValue else {
            throw ParseError.missingRequiredOption(option)
        }
    }
}

extension EnumOption: Parsable {
    var parser: Parser {
        return EnumOptionParser(option: self)
    }
}
