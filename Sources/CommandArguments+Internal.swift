import Foundation

// ----------------------------------------
// MARK: Types
// ----------------------------------------
typealias OptionName = (long: String?, short: String?)

protocol OptionProtocol {
    var name: OptionName { get set }
    var usage: String? { get }
}

protocol OperandProtocol {
    var name: String? { get set }
    var usage: String? { get }
}

extension OptionProtocol where Self: Parsable {
    var missingError: ErrorProtocol {
        return ParseError.missingRequiredOption(name.long ?? name.short!)
    }
}

extension OperandProtocol where Self: Parsable {
    var missingError: ErrorProtocol {
        return ParseError.missingRequiredOperand(name!)
    }
}

protocol TrailingOperand {
    var valueCount: Int { get }
}

extension Operand: TrailingOperand {
    var valueCount: Int { return 1 }
}

extension MultipleOperand: TrailingOperand {
    var valueCount: Int { return count }
}

// ----------------------------------------
// MARK: Parser
// ----------------------------------------
protocol Parsable: class {
    var parser: Parser { get }
    var missingError: ErrorProtocol { get }
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
        let (options, operands) = try parseFields(fields)
        
        var operandValues = [String]()
        try parseOptions(options, withArgs: args, operandValues: &operandValues)
        try parseOperands(operands, withValues: operandValues)

    }
    
    // ----------------------------------------
    // MARK: Parse fields (and check names)
    // ----------------------------------------
    private func parseFields(_ fields: [Mirror.Child]) throws -> ([OptionProtocol], [OperandProtocol]) {
        var knownOptionNames = Set<String>()
        var knownOperandNames = Set<String>()
        
        var optionFields = [(String?, OptionProtocol)]()
        var operandFields = [(String?, OperandProtocol)]()
        
        // Parse options and operands
        try fields.forEach { (name, value) in
            if value is OptionProtocol {
                let option = value as! OptionProtocol
                try checkOptionName(option.name, withKnown: &knownOptionNames)
                optionFields.append((name, option))
            } else {
                let operand = value as! OperandProtocol
                try checkOperandName(operand.name, withKnown: &knownOperandNames)
                operandFields.append((name, operand))
            }
        }
        
        // Check option default names (using filed name) and name missing error
        try optionFields.forEach { (name, var option) in
            checkFieldName(name, ofOption: &option, withKnown: &knownOptionNames)
            if option.name.long == nil && option.name.short == nil {
                throw TypeError.missingOptionName(name)
            }
        }
        
        // Check operand default names (using filed name) and name missing error
        try operandFields.forEach { (name, var operand) in
            checkFieldName(name, ofOperand: &operand, withKnown: &knownOperandNames)
            if operand.name == nil {
                throw TypeError.missingOperandName(name)
            }
        }
        
        return (optionFields.map { $0.1 }, operandFields.map { $0.1 } )
    }
    
    /// Check duplicated option names
    private func checkOptionName(_ name: OptionName, withKnown names: inout Set<String>) throws {
        if let long = name.long {
            guard !names.contains(long) else {
                throw TypeError.duplicatedOptionName(long)
            }
            names.insert(long)
        }
        if let short = name.short {
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
    
    /// Check duplicated operand names
    private func checkOperandName(_ name: String?, withKnown names: inout Set<String>) throws {
        guard let name = name else { return }
        guard !names.contains(name) else {
            throw TypeError.duplicatedOperandName(name)
        }
        names.insert(name)
    }
    
    /// Use filed name as default option names
    private func checkFieldName(_ name: String?, ofOption option: inout OptionProtocol, withKnown names: inout Set<String>) {
        guard let name = name where !name.isEmpty && !names.contains(name) else { return }
        if name.characters.count == 1 {
            if option.name.short == nil {
                option.name.short = name
                names.insert(name)
            }
        } else {
            if option.name.long == nil {
                option.name.long = name
                names.insert(name)
            }
        }
    }
    
    /// Use field name as default operand name
    private func checkFieldName(_ name: String?, ofOperand operand: inout OperandProtocol, withKnown names: inout Set<String>) {
        guard let name = name where !name.isEmpty && !names.contains(name) else { return }
        guard operand.name == nil else { return }
        operand.name = name
        names.insert(name)
    }
    
    // ----------------------------------------
    // MARK: Parse
    // ----------------------------------------
    
    /// Parse options and return operand values
    private func parseOptions(_ options: [OptionProtocol], withArgs args: ArraySlice<String>, operandValues: inout [String]) throws {
        
        var parsers = [String: Parser]()
        options.forEach { option in
            let parser = (option as! Parsable).parser
            if let longName = option.name.long {
                parsers[longName] = parser
            }
            if let shortName = option.name.short {
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
    
    private func parseOperands(_ operands: [OperandProtocol], withValues values: [String]) throws {
        if values.isEmpty && operands.isEmpty { return } // No operands
        if operands.isEmpty {
            throw ParseError.invalidOperand(values[0])
        }
        if values.isEmpty {
            throw (operands[0] as! Parsable).missingError
        }
        
        let parsers = operands.map { ($0 as! Parsable).parser }
        
        var nextOperandIndex = 0
        var lastOperandIndex = operands.endIndex - 1
        var activeOperandIndex: Int?
        
        func checkActiveOperand(with value: String? = nil) throws {
            guard let index = activeOperandIndex else { return }
            let parser = parsers[index]
            
            if let value = value {
                try parser.parseValue(value)
                if !parser.canTakeValue {
                    try parser.finishParsing()
                    activeOperandIndex = nil
                }
            } else {
                try parser.finishParsing()
                activeOperandIndex = nil
            }
        }
        
        func parseOperand(_ value: String) throws {
            guard nextOperandIndex <= lastOperandIndex else {
                throw ParseError.invalidOperand(value)
            }
            
            let parser = parsers[nextOperandIndex]
            try parser.parseValue(value)
            if parser.canTakeValue {
                activeOperandIndex = nextOperandIndex
            } else {
                try parser.finishParsing()
            }
            
            nextOperandIndex += 1
        }
        
        var valueEndIndex = values.endIndex
        func checkTrainingOperand() throws {
            guard operands.count > 1 else { return }
            guard let operand = operands.last! as? TrailingOperand else { return }
            
            let count = operand.valueCount
            guard values.count >= count else {
                throw (operands.last as! Parsable).missingError
            }
            
            let parser = parsers.last!
            for i in valueEndIndex - count ..< valueEndIndex {
                try parser.parseValue(values[i])
            }
            try parser.finishParsing()
            
            valueEndIndex -= count
            lastOperandIndex -= 1
        }
        try checkTrainingOperand()
        
        for i in 0 ..< valueEndIndex {
            let value = values[i]
            if activeOperandIndex != nil {
                try checkActiveOperand(with: value)
            } else {
                try parseOperand(value)
            }
        }
        
        try checkActiveOperand()
        try parsers.forEach {
            try $0.validate()
        }
    }
    
}