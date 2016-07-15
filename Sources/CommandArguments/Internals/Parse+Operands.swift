import Foundation

extension CommandArguments {
    
    /// Parse operands. Throw `ParseError` for missing or invalid values.
    func parseOperands(_ operands: [OperandProtocol], withValues values: [String]) throws {
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
        
        func checkActiveOperand(index: Int, value: String) throws {
            let parser = parsers[index]
            try parser.parseValue(value)
            if !parser.canTakeValue {
                try parser.finishParsing()
                activeOperandIndex = nil
            }
        }
        
        func finishActiveOperand() throws {
            if let index = activeOperandIndex {
                try parsers[index].finishParsing()
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
            if let index = activeOperandIndex {
                try checkActiveOperand(index: index, value: value)
            } else {
                try parseOperand(value)
            }
        }
        
        try finishActiveOperand()
        for parser in parsers {
            try parser.validate()
        }
    }
}
