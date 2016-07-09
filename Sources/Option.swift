import Foundation

/// Abstract class for `Option`s
public class Option {
    
    /// Long name of the option as in `--x`
    public var longName: String?
    
    /// One-letter short name of the option as in `-x`
    public var shortName: String?
    
    /// Usage message of this option
    public let usage: String?
    
    /// Internal `init` for subclasses
    init(longName: String? = nil, shortName: String? = nil, usage: String? = nil) {
        self.longName = longName
        self.shortName = shortName
        self.usage = usage
    }
}
