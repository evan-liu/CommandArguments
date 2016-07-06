import Foundation

public protocol CommandArguments {
    init()
    
    mutating func parse<T: Collection where T.Iterator.Element == String, T.Index == Int>
    (args: T, from startIndex: Int) throws
}

extension CommandArguments {
    
    public mutating func parse<T: Collection where T.Iterator.Element == String, T.Index == Int>
        (args: T, from startIndex: Int = 0) throws {
        
        var optionParsers = [String: Parser]()
        
        Mirror(reflecting: self).children
            .flatMap { $0.value as? Parsable }
            .forEach { value in
                switch value {
                case let option as Option:
                    let parser = (option as! Parsable).parser
                    if let longName = option.longName {
                        optionParsers[longName] = parser
                    }
                    if let shortName = option.shortName {
                        optionParsers[shortName] = parser
                    }
                default: break
                }
        }
        
        var activeOptionParser: Parser?
        
        func checkActiveOption(with value: String? = nil) throws {
            guard let parser = activeOptionParser else { return }
            
            if let value = value {
                try parser.parseValue(value)
                if !parser.canTakeValue {
                    try parser.finishParsing()
                    activeOptionParser = nil
                }
            } else {
                try parser.finishParsing()
                activeOptionParser = nil
            }
        }
        
        func activateOption(withName name: String) throws {
            guard let parser = optionParsers[name] else {
                throw ParseError.invalidOption(name)
            }
            activeOptionParser = parser
        }
        
        func parseOptionWithEquals(_ characters: String.CharacterView) throws {
            guard let equalIndex = characters.index(of: "=") else { return }
            
            try activateOption(withName: String(characters[characters.startIndex..<equalIndex]))
            
            let valueIndex = characters.index(after: equalIndex)
            if valueIndex < characters.endIndex {
                try checkActiveOption(with: String(characters[valueIndex..<characters.endIndex]))
            } else {
                try checkActiveOption(with: "")
            }
        }
        
        func parseLongOption(_ characters: String.CharacterView) throws {
            if characters.contains("=") {
                try parseOptionWithEquals(characters)
            } else {
                try activateOption(withName: String(characters))
            }
        }
        
        func parseShortOption(_ characters: String.CharacterView) throws {
            if characters.contains("=") {
                return try parseOptionWithEquals(characters)
            }
            
            // -x: wait for next arg
            if characters.count == 1 {
                return try activateOption(withName: String(characters))
            }
            
            // -abc: a=true, b=true, c=true
            try characters.forEach {
                try activateOption(withName: String($0))
                try checkActiveOption()
            }
        }
        
        for i in startIndex..<args.endIndex {
            var arg = args[i]
            var characters = arg.characters
            
            // parameter or option value (not start with `-`)
            if characters.first != "-" {
                if activeOptionParser != nil {
                    try checkActiveOption(with: arg)
                }
                continue
            }
            
            // options (start with `-` or `--`)
            try checkActiveOption()
            
            // TODO `--` stop parsing options
            
            characters.removeFirst()
            
            // `-x`
            if characters.first != "-" {
                try parseShortOption(characters)
                continue
            }
            
            // `--x`
            characters.removeFirst()
            try parseLongOption(characters)
        }
        try checkActiveOption()
    }
    
}
