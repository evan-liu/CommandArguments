import Foundation

extension CommandArguments {
    
    /// Parse fields. Validate names and throw `TypeError`.
    func parseFields() throws -> ([OptionProtocol], [OperandProtocol]) {
        var knownOptionNames = Set<String>()
        var knownOperandNames = Set<String>()
        
        var optionFields = [(String?, OptionProtocol)]()
        var operandFields = [(String?, OperandProtocol)]()
        
        // Check duplicated option names
        func checkOptionName(_ name: OptionName) throws {
            if let long = name.long {
                guard !knownOptionNames.contains(long) else {
                    throw TypeError.duplicatedOptionName(long)
                }
                knownOptionNames.insert(long)
            }
            if let short = name.short {
                guard short.characters.count == 1 else {
                    throw TypeError.invalidShortOptionName(short)
                }
                guard let _ = short.rangeOfCharacter(from: .letters) else {
                    throw TypeError.invalidShortOptionName(short)
                }
                guard !knownOptionNames.contains(short) else {
                    throw TypeError.duplicatedOptionName(short)
                }
                knownOptionNames.insert(short)
            }
        }
        
        // Check duplicated operand names
        func checkOperandName(_ name: String?) throws {
            guard let name = name else { return }
            guard !knownOperandNames.contains(name) else {
                throw TypeError.duplicatedOperandName(name)
            }
            knownOperandNames.insert(name)
        }
        
        // Use filed name as default option names
        func checkFieldName(_ name: String?, ofOption option: inout OptionProtocol) {
            guard let name = name where !name.isEmpty && !knownOptionNames.contains(name) else { return }
            if name.characters.count == 1 {
                if option.name.short == nil {
                    option.name.short = name
                    knownOptionNames.insert(name)
                }
            } else {
                if option.name.long == nil {
                    option.name.long = name
                    knownOptionNames.insert(name)
                }
            }
        }
        
        // Use field name as default operand name
        func checkFieldName(_ name: String?, ofOperand operand: inout OperandProtocol) {
            guard let name = name where !name.isEmpty && !knownOperandNames.contains(name) else { return }
            guard operand.name == nil else { return }
            operand.name = name
            knownOperandNames.insert(name)
        }
        
        // Parse options and operands
        let fields = Mirror(reflecting: self).children.filter { $0.value is Parsable }
        for (name, value) in fields {
            if value is OptionProtocol {
                let option = value as! OptionProtocol
                try checkOptionName(option.name)
                optionFields.append((name, option))
            } else {
                let operand = value as! OperandProtocol
                try checkOperandName(operand.name)
                operandFields.append((name, operand))
            }
        }
        
        // Check option default names (using filed name) and name missing error
        for (name, var option) in optionFields {
            checkFieldName(name, ofOption: &option)
            if option.name.long == nil && option.name.short == nil {
                throw TypeError.missingOptionName(name)
            }
        }
        
        // Check operand default names (using filed name) and name missing error
        for (name, var operand) in operandFields {
            checkFieldName(name, ofOperand: &operand)
            if operand.name == nil {
                throw TypeError.missingOperandName(name)
            }
        }
        
        return (optionFields.map { $0.1 }, operandFields.map { $0.1 } )
    }

}
