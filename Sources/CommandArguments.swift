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
        let (optionParsers, parameterParsers) = try parseFields(fields)
        
        var parameterValues = [String]()
        try parse(args, optionParsers: optionParsers, parameterValues: &parameterValues)
        try parseParameters(parameterValues, withParsers: parameterParsers)
    }
    
    /// Parse fileds and return `Parser`s
    private func parseFields(_ fields: [Mirror.Child]) throws -> ([String: Parser], [Parser]) {
        var knownOptionNames = Set<String>()
        var knownParameterNames = Set<String>()
        
        var options = [(String?, Option)]()
        var parameters = [(String?, Parameter)]()
        
        // Parse options and parameters
        try fields.forEach { (name, value) in
            if value is Option {
                let option = value as! Option
                try checkOptionNames(long: option.longName, short: option.shortName, withKnown: &knownOptionNames)
                options.append((name, option))
            } else {
                let parameter = value as! Parameter
                try checkParameterName(parameter.name, withKnown: &knownParameterNames)
                parameters.append((name, parameter))
            }
        }
        
        // Option default names
        try options.forEach { (name, option) in
            checkFieldName(name, ofOption: option, withKnown: &knownOptionNames)
            if option.longName == nil && option.shortName == nil {
                throw TypeError.missingOptionName(name)
            }
        }
        
        // Parameters default names
        parameters.forEach { (name, parameter) in
            checkFieldName(name, ofParameter: parameter, withKnown: &knownParameterNames)
        }
        
        // Parsers
        var optionParsers = [String: Parser]()
        options.forEach { (name, option) in
            let parser = (option as! Parsable).parser
            if let longName = option.longName {
                optionParsers[longName] = parser
            }
            if let shortName = option.shortName {
                optionParsers[shortName] = parser
            }
        }
        return (optionParsers, parameters.map { ($0.1 as! Parsable).parser })
    }
    
    /// Check duplicated option names
    private func checkOptionNames(long: String?, short: String?, withKnown names: inout Set<String>) throws {
        if let long = long {
            guard !names.contains(long) else {
                throw TypeError.duplicatedOptionName(long)
            }
            names.insert(long)
        }
        if let short = short {
            guard short.characters.count == 1 else {
                throw TypeError.invalidShortOptionName(short)
            }
            guard let _ = short.rangeOfCharacter(from: .letters) else {
                throw TypeError.invalidShortOptionName(short)
            }
            guard !names.contains(short) else {
                throw TypeError.duplicatedOptionName(short)
            }
            names.insert(short)
        }
    }
    
    /// Check duplicated parameter names
    private func checkParameterName(_ name: String?, withKnown names: inout Set<String>) throws {
        guard let name = name else { return }
        guard !names.contains(name) else {
            throw TypeError.duplicatedParameterName(name)
        }
        names.insert(name)
    }
    
    /// Use filed name as default option names
    private func checkFieldName(_ name: String?, ofOption option: Option, withKnown names: inout Set<String>) {
        guard let name = name where !name.isEmpty && !names.contains(name) else { return }
        if name.characters.count == 1 {
            if option.shortName == nil {
                option.shortName = name
                names.insert(name)
            }
        } else {
            if option.longName == nil {
                option.longName = name
                names.insert(name)
            }
        }
    }
    
    /// Use field name as default parameter name
    private func checkFieldName(_ name: String?, ofParameter parameter: Parameter, withKnown names: inout Set<String>) {
        guard let name = name where !name.isEmpty && !names.contains(name) else { return }
        guard parameter.name == nil else { return }
        parameter.name = name
        names.insert(name)
    }
    
    /// Parse options and return parameter values
    private func parse(_ args: ArraySlice<String>, optionParsers: [String: Parser], parameterValues: inout [String]) throws {
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
    }
    
    private func parseParameters(_ parameterValues: [String], withParsers parameterParsers: [Parser]) throws {
        var activeParameterParser: Parser?
        var nextParserIndex = 0
        
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
            guard nextParserIndex < parameterParsers.endIndex else {
                throw ParseError.invalidParameter(value)
            }
            
            let parser = parameterParsers[nextParserIndex]
            nextParserIndex += 1
            
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
