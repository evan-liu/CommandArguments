import Foundation

/// Base class for `Argument`s
public class Argument {
    
    /// Name of the argument. Field name will be used by default.
    public var name: String?
    
    /// Usage message of this argument
    public let usage: String?
    
    public init(name: String? = nil, usage: String? = nil) {
        self.name = name
        self.usage = usage
    }
}

// ----------------------------------------
// MARK: Internal
// ----------------------------------------
protocol TrailingArgument {
    var valueCount: Int { get }
}

extension RequiredArgument: TrailingArgument {
    var valueCount: Int { return 1 }
}

extension MultiArgument: TrailingArgument {
    var valueCount: Int { return count }
}
