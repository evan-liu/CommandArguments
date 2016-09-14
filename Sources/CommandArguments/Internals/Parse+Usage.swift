import Foundation

extension CommandArguments {
    
    func parseUsage(commandName: String?, options: [OptionProtocol], operands: [OperandProtocol]) -> String {
        let hasOption = options.count > 0
        let hasOperand = operands.count > 0
        guard hasOption || hasOperand else {
            return "Error: no option or operand defined"
        }
        
        var synopsis = "Usage: \(commandName ?? self.commandName)"
        if hasOption {
            synopsis += " [options]"
        }
        if hasOperand {
            synopsis += " " + operands.map { $0.synopsis }.joined(separator: " ")
        }
        
        var secions = [synopsis]
        if hasOperand {
            secions.append("Operands:\n" + parseOperands(operands))
        }
        if hasOption {
            secions.append("Options:\n" + parseOptions(options))
        }
        
        return secions.joined(separator: "\n\n")
    }
    
    private func parseOperands(_ operands: [OperandProtocol]) -> String {
        let maxNameLength = operands.reduce(0) { length, operand in
            return max(length, operand.name!.characters.count)
        }
        let nameSectionLength = maxNameLength + 4 // 4: title leading and trailing spaces
        
        func parseOperand(_ operand: OperandProtocol) -> String {
            let title = "  " + operand.name!
            if let usage = operand.usage {
                return title.appendingSpace(toLength: nameSectionLength) + usage
            }
            return title
        }
        return operands.map(parseOperand).joined(separator: "\n")
    }
    
    private func parseOptions(_ options: [OptionProtocol]) -> String {
        let maxNameLength = OptionMaxNameLength(options: options)
        let nameSectionLength = maxNameLength.total + 4 // 4: title leading and trailing spaces
        
        func parseOption(_ option: OptionProtocol) -> String {
            let title = "  " + option.usageTitle(maxLength: maxNameLength)
            if let usage = option.usage {
                return title.appendingSpace(toLength: nameSectionLength) + usage
            }
            return title
        }
        return options.map(parseOption).joined(separator: "\n")
    }
    
}

private struct OptionMaxNameLength {
    var short: Int
    var long: Int
    var total: Int
    
    init(options: [OptionProtocol]) {
        let hasShort = options.contains { $0.name.short != nil }
        short = hasShort ? 2 : 0 // -x
        long = options.reduce(0) { length, option in
            guard let longName = option.name.long else {
                return length
            }
            return max(length, longName.characters.count + 2) // --yy, +2 for --
        }
        if long == 0 {       // -x
            total = 2
        } else if hasShort { // -x, --yy
            total = 4 + long
        } else {             // --yy
            total = long
        }
    }
}

private extension OptionProtocol {
    
    /// -x
    var shortTitle: String {
        return "-\(name.short!)"
    }
    
    /// --yy
    var longTitle: String {
        return "--\(name.long!)"
    }
    
    func usageTitle(maxLength: OptionMaxNameLength) -> String {
        //-x
        if maxLength.long == 0 {
            return shortTitle
        }
        
        //--y
        if maxLength.short == 0 {
            return longTitle
        }
        
        //-x
        if name.long == nil {
            return shortTitle
        }
        
        //    --y
        if name.short == nil {
            return "    " + longTitle
        }
        
        //-x, --y
        return "\(shortTitle), \(longTitle)"
    }
}

private extension String {
    func appendingSpace(toLength length: Int) -> String {
        return appending(String(repeating: " ", count: length - characters.count))
    }
}
