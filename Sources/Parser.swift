import Foundation

public enum ParseError: ErrorProtocol {
    case invalidOption
}

protocol Parsable: class {
    var parser: Parser { get }
}

protocol Parser {
    var canTakeValue: Bool { get }
    func parseValue(_ value: String) throws
    func finishParsing() throws
}

extension Parser {
    func finishParsing() { }
}
