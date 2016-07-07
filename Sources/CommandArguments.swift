import Foundation

public protocol CommandArguments {
    init()
    
    mutating func parse(_ args: ArraySlice<String>) throws
}

extension CommandArguments {
    public mutating func parse(_ args: [String], from startIndex: Int = 0) throws {
        try parse(args[startIndex..<args.endIndex])
    }
    
    public mutating func parse(_ args: ArraySlice<String>) throws {
        
        let fields = Mirror(reflecting: self).children.filter { $0.value is Parsable }
        
        //-- Check type
        
        var knownOptionNames = Set<String>()
        var knownParameterNames = Set<String>()
        
        var options = [(String?, Option)]()
        var parameters = [(String?, Parameter)]()
        
        try fields.forEach { (name, value) in
            if value is Option {
                let option = value as! Option
                if let longName = option.longName {
                    guard !knownOptionNames.contains(longName) else {
                        throw TypeError.duplicatedOptionName(longName)
                    }
                    knownOptionNames.insert(longName)
                }
                if let shortName = option.shortName {
                    guard shortName.characters.count == 1 else {
                        throw TypeError.invalidShortOptionName(shortName)
                    }
                    guard let _ = shortName.rangeOfCharacter(from: .letters) else {
                        throw TypeError.invalidShortOptionName(shortName)
                    }
                    guard !knownOptionNames.contains(shortName) else {
                        throw TypeError.duplicatedOptionName(shortName)
                    }
                    knownOptionNames.insert(shortName)
                }
                options.append((name, option))
            } else {
                let parameter = value as! Parameter
                if let name = parameter.name {
                    guard !knownParameterNames.contains(name) else {
                        throw TypeError.duplicatedParameterName(name)
                    }
                    knownParameterNames.insert(name)
                }
                parameters.append((name, parameter))
            }
        }
        
        var optionParsers = [String: Parser]()
        try options.forEach { (name, option) in
            if let name = name where !name.isEmpty && !knownOptionNames.contains(name) {
                if name.characters.count == 1 {
                    if option.shortName == nil {
                        option.shortName = name
                        knownOptionNames.insert(name)
                    }
                } else {
                    if option.longName == nil {
                        option.longName = name
                        knownOptionNames.insert(name)
                    }
                }
            }
            
            guard option.longName != nil || option.shortName != nil else {
                throw TypeError.missingOptionName(name)
            }
            
            let parser = (option as! Parsable).parser
            if let longName = option.longName {
                optionParsers[longName] = parser
            }
            if let shortName = option.shortName {
                optionParsers[shortName] = parser
            }
        }
        
        var parameterParsers = [Parser]()
        parameters.forEach { (name, parameter) in
            if parameter.name == nil {
                if let name = name where !name.isEmpty && !knownParameterNames.contains(name) {
                    parameter.name = name
                    knownParameterNames.insert(name)
                }
            }
            parameterParsers.append((parameter as! Parsable).parser)
        }
        
        //-- Parse arguments
        
        var parameterValues = [String]()
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
            
            // -abc: a=true, b=true, c=true
            try characters.forEach {
                try activateOption(withName: String($0))
                try checkActiveOption()
            }
        }
        
        let endIndex = args.endIndex
        for i in args.startIndex..<endIndex {
            var arg = args[i]
            var characters = arg.characters
            
            // parameter or option value (not start with `-`)
            if characters.first != "-" {
                if activeOptionParser != nil {
                    try checkActiveOption(with: arg)
                } else {
                    parameterValues.append(arg)
                }
                continue
            }
            
            // `--` stops parsing options
            if arg == "--" {
                let nextIndex = i + 1
                if nextIndex < endIndex {
                    parameterValues.append(contentsOf: args[nextIndex..<endIndex])
                }
                break
            }
            
            // options (`-x` or `--x`)
            try checkActiveOption()
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
        try optionParsers.forEach { (_, parser) in
            try parser.validate()
        }
        
        var activeParameterParser: Parser?
        
        func checkActiveParameter(with value: String? = nil) throws {
            guard let parser = activeParameterParser else { return }
            
            if let value = value {
                try parser.parseValue(value)
                if !parser.canTakeValue {
                    try parser.finishParsing()
                    activeParameterParser = nil
                }
            } else {
                try parser.finishParsing()
                activeParameterParser = nil
            }
        }
        
        func parseParameter(_ value: String) throws {
            guard parameterParsers.count > 0 else {
                throw ParseError.invalidParameter(value)
            }
            
            let parser = parameterParsers.removeFirst()
            try parser.parseValue(value)
            if parser.canTakeValue {
                activeParameterParser = parser
            } else {
                try parser.finishParsing()
            }
        }

        try parameterValues.forEach { value in
            if activeParameterParser != nil {
                try checkActiveParameter(with: value)
            } else {
                try parseParameter(value)
            }
        }
        
        try checkActiveParameter()
        try parameterParsers.forEach {
            try $0.finishParsing()
        }
        
    }
    
}
