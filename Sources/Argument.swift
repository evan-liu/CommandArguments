import Foundation

/// Base class for `Argument`s
public class Argument {
    public var name: String?
    public let usage: String?
    
    public init(name: String? = nil, usage: String? = nil) {
        self.name = name
        self.usage = usage
    }
}

protocol TrailingArgument {
    var valueCount: Int { get }
}

extension RequiredArgument: TrailingArgument {
    var valueCount: Int { return 1 }
}

extension MultiArgument: TrailingArgument {
    var valueCount: Int { return count }
}
