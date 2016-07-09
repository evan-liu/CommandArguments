import Foundation

protocol Parsable: class {
    var parser: Parser { get }
    
    var missingError: ErrorProtocol { get }
}

extension Argument {
    var missingError: ErrorProtocol {
        return ParseError.missingRequiredArgument(name!)
    }
}

extension Option {
    var missingError: ErrorProtocol {
        return ParseError.missingRequiredOption(longName ?? shortName!)
    }
}

protocol Parser {
    
    /// If the receiver can take more values
    var canTakeValue: Bool { get }
    
    /// Parse and take current value
    func parseValue(_ value: String) throws
    
    /// Finish current parsing when `!canTakeValue` or another argument parsing starts
    func finishParsing() throws
    
    /// Validate the receiver after all arguments are parsed
    func validate() throws
}

extension Parser {
    
    func finishParsing() throws { }
    
    func validate() throws { }
}

extension CommandArguments {

    mutating func _parse(_ args: ArraySlice<String>) throws {
        let fields = Mirror(reflecting: self).children.filter { $0.value is Parsable }
        let (options, arguments) = try parseFields(fields)
        
        var argumentValues = [String]()
        try parseOptions(options, withArgs: args, argumentValues: &argumentValues)
        try parseArguments(arguments, withValues: argumentValues)
    }
    
    /// Parse fileds and return `Parser`s
    private func parseFields(_ fields: [Mirror.Child]) throws -> ([Option], [Argument]) {
        var knownOptionNames = Set<String>()
        var knownArgumentNames = Set<String>()
        
        var optionFields = [(String?, Option)]()
        var argumentFields = [(String?, Argument)]()
        
        // Parse options and arguments
        try fields.forEach { (name, value) in
            if value is Option {
                let option = value as! Option
                try checkOptionNames(long: option.longName, short: option.shortName, withKnown: &knownOptionNames)
                optionFields.append((name, option))
            } else {
                let argument = value as! Argument
                try checkArgumentName(argument.name, withKnown: &knownArgumentNames)
                argumentFields.append((name, argument))
            }
        }
        
        // Check option default names (using filed name) and name missing error
        try optionFields.forEach { (name, option) in
            checkFieldName(name, ofOption: option, withKnown: &knownOptionNames)
            if option.longName == nil && option.shortName == nil {
                throw TypeError.missingOptionName(name)
            }
        }
        
        // Check argument default names (using filed name) and name missing error
        try argumentFields.forEach { (name, argument) in
            checkFieldName(name, ofArgument: argument, withKnown: &knownArgumentNames)
            if argument.name == nil {
                throw TypeError.missingArgumentName(name)
            }
        }
        
        return (optionFields.map { $0.1 }, argumentFields.map { $0.1 } )
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
    
    /// Check duplicated argument names
    private func checkArgumentName(_ name: String?, withKnown names: inout Set<String>) throws {
        guard let name = name else { return }
        guard !names.contains(name) else {
            throw TypeError.duplicatedArgumentName(name)
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
    
    /// Use field name as default argument name
    private func checkFieldName(_ name: String?, ofArgument argument: Argument, withKnown names: inout Set<String>) {
        guard let name = name where !name.isEmpty && !names.contains(name) else { return }
        guard argument.name == nil else { return }
        argument.name = name
        names.insert(name)
    }
    
    /// Parse options and return argument values
    private func parseOptions(_ options: [Option], withArgs args: ArraySlice<String>, argumentValues: inout [String]) throws {
        
        var parsers = [String: Parser]()
        options.forEach { option in
            let parser = (option as! Parsable).parser
            if let longName = option.longName {
                parsers[longName] = parser
            }
            if let shortName = option.shortName {
                parsers[shortName] = parser
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
            try characters.forEach {
                try checkActiveOption() // Finish previous one
                try activateOption(withName: String($0))
            }
        }
        
        let endIndex = args.endIndex
        for i in args.startIndex..<endIndex {
            var arg = args[i]
            guard !arg.isEmpty else { continue }
            
            var characters = arg.characters
            
            // Argument or option value (not start with `-`)
            if characters.first != "-" {
                if activeOptionParser != nil {
                    try checkActiveOption(with: arg)
                } else {
                    argumentValues.append(arg)
                }
                continue
            }
            
            // `--` stops parsing options
            if arg == "--" {
                let nextIndex = i + 1
                if nextIndex < endIndex {
                    argumentValues.append(contentsOf: args[nextIndex..<endIndex])
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
        try parsers.forEach { (_, parser) in
            try parser.validate()
        }
    }
    
    private func parseArguments(_ arguments: [Argument], withValues values: [String]) throws {
        if values.isEmpty && arguments.isEmpty { return } // No arguments
        if arguments.isEmpty {
            throw ParseError.invalidArgument(values[0])
        }
        if values.isEmpty {
            throw arguments[0].missingError
        }
        
        let parsers = arguments.map { ($0 as! Parsable).parser }
        
        var nextArgumentIndex = 0
        var lastArgumentIndex = arguments.endIndex - 1
        var activeArgumentIndex: Int?
        
        func checkActiveArgument(with value: String? = nil) throws {
            guard let index = activeArgumentIndex else { return }
            let parser = parsers[index]
            
            if let value = value {
                try parser.parseValue(value)
                if !parser.canTakeValue {
                    try parser.finishParsing()
                    activeArgumentIndex = nil
                }
            } else {
                try parser.finishParsing()
                activeArgumentIndex = nil
            }
        }
        
        func parseArgument(_ value: String) throws {
            guard nextArgumentIndex <= lastArgumentIndex else {
                throw ParseError.invalidArgument(value)
            }
            
            let parser = parsers[nextArgumentIndex]
            try parser.parseValue(value)
            if parser.canTakeValue {
                activeArgumentIndex = nextArgumentIndex
            } else {
                try parser.finishParsing()
            }
            
            nextArgumentIndex += 1
        }
        
        var valueEndIndex = values.endIndex
        func checkTrainingArgument() throws {
            guard arguments.count > 1 else { return }
            guard let argument = arguments.last! as? TrailingArgument else { return }
            
            let count = argument.valueCount
            guard values.count >= count else {
                throw arguments.last!.missingError
            }
            
            let parser = parsers.last!
            for i in valueEndIndex - count ..< valueEndIndex {
                try parser.parseValue(values[i])
            }
            try parser.finishParsing()
            
            valueEndIndex -= count
            lastArgumentIndex -= 1
        }
        try checkTrainingArgument()
        
        for i in 0 ..< valueEndIndex {
            let value = values[i]
            if activeArgumentIndex != nil {
                try checkActiveArgument(with: value)
            } else {
                try parseArgument(value)
            }
        }
        
        try checkActiveArgument()
        try parsers.forEach {
            try $0.validate()
        }
    }
}

