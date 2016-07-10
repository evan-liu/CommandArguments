import Foundation

/// Abstract class for `Operand`s
public class Operand {
    
    /// Name of the receiver. Field name will be used by default.
    public var name: String?
    
    /// Usage message of the receiver.
    public let usage: String?
    
    /// Internal `init` for subclasses.
    init(name: String? = nil, usage: String? = nil) {
        self.name = name
        self.usage = usage
    }
}

// ----------------------------------------
// MARK: Internal
// ----------------------------------------
protocol TrailingOperand {
    var valueCount: Int { get }
}

extension RequiredOperand: TrailingOperand {
    var valueCount: Int { return 1 }
}

extension MultiOperand: TrailingOperand {
    var valueCount: Int { return count }
}
