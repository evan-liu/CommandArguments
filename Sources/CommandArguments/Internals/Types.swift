import Foundation

typealias OptionName = (long: String?, short: String?)

protocol OptionProtocol {
    var name: OptionName { get set }
    var usage: String? { get }
}

protocol OperandProtocol {
    var name: String? { get set }
    var usage: String? { get }
}

extension OptionProtocol where Self: Parsable {
    var missingError: ErrorProtocol {
        return ParseError.missingRequiredOption(name.long ?? name.short!)
    }
}

extension OperandProtocol where Self: Parsable {
    var missingError: ErrorProtocol {
        return ParseError.missingRequiredOperand(name!)
    }
}

protocol TrailingOperand {
    var valueCount: Int { get }
}

extension Operand: TrailingOperand {
    var valueCount: Int { return 1 }
}

extension MultipleOperand: TrailingOperand {
    var valueCount: Int { return count }
}
