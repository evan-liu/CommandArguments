import Foundation

/// Base class for `Option`s
public class Option {
    public var longName: String?
    public var shortName: String?
    
    public let usage: String?
    
    public init(longName: String? = nil, shortName: String? = nil, usage: String? = nil) {
        self.longName = longName
        self.shortName = shortName
        self.usage = usage
    }
}
