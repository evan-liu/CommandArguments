import Foundation

extension CommandArguments {
    
    /// Parse options and save other arguments to `operandValues`.
    func parseOptions(_ options: [OptionProtocol], withArgs args: ArraySlice<String>, operandValues: inout [String]) throws {
        
        var parsers = [String: Parser]()
        for option in options {
            let parser = (option as! Parsable).parser
            if let longName = option.name.long {
                parsers[longName] = parser
            }
            if let shortName = option.name.short {
                parsers[shortName] = parser
            }
        }
        var activeOptionParser: Parser?
        
        func checkActiveOption(with value: String) throws {
            guard let parser = activeOptionParser else { return }
            
            try parser.parseValue(value)
            if !parser.canTakeValue {
                try parser.finishParsing()
                activeOptionParser = nil
            }
        }
        
        func finishActiveOption() throws {
            if let parser = activeOptionParser {
                try parser.finishParsing()
                activeOptionParser = nil
            }
        }
        
        func activateOption(withName name: String) throws {
            guard let parser = parsers[name] else {
                throw ParseError.invalidOption(name)
            }
            activeOptionParser = parser
        }
        
        func parseOptionWithEquals(_ characters: String.CharacterView) throws {
            let equalIndex = characters.index(of: "=")!
            
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
            
            // -abc -> -a -b -c
            for character in characters {
                try finishActiveOption()
                try activateOption(withName: String(character))
            }
        }
        
        let endIndex = args.endIndex
        for i in args.startIndex..<endIndex {
            var arg = args[i]
            guard !arg.isEmpty else { continue }
            
            var characters = arg.characters
            
            // Operand or option value (not start with `-`)
            if characters.first != "-" {
                if activeOptionParser != nil {
                    try checkActiveOption(with: arg)
                } else {
                    operandValues.append(arg)
                }
                continue
            }
            
            // `--` stops parsing options
            if arg == "--" {
                let nextIndex = i + 1
                if nextIndex < endIndex {
                    operandValues.append(contentsOf: args[nextIndex..<endIndex])
                }
                break
            }
            
            // options (`-x` or `--x`)
            try finishActiveOption()
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
        try finishActiveOption()
        for (_, parser) in parsers {
            try parser.validate()
        }
    }
}
