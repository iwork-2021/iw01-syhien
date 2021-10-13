//
//  Calculator.swift
//  calculator
//
//  Created by nju on 2021/10/10.
//

import UIKit

class Calculator: NSObject {
    enum Operations {
        case UnaryOperation((Double)->Double)
        case BinaryOperation((Double,Double)->Double)
        case EqualOperation
        case Constant(Double)
        case MemoryOperation
    }
    
    struct Intermediate {
        var firstOperand: Double
        var waitingOperation: (Double, Double)->Double
    }
    var pendingOperation: Intermediate? = nil
    var memorizedResult = 0.0
 
    var operations = [
        "+": Operations.BinaryOperation { $0 + $1 },
        "-": Operations.BinaryOperation { $0 - $1 },
        "*": Operations.BinaryOperation { $0 * $1 },
        "/": Operations.BinaryOperation { $0 / $1 },
        "%": Operations.UnaryOperation { $0 / 100.0},
        "+ / -": Operations.UnaryOperation { -$0 },
        "AC": Operations.Constant(0),
        "=": Operations.EqualOperation,
        "x^2": Operations.UnaryOperation { pow($0, 2) },
        "x^3": Operations.UnaryOperation { pow($0, 3) },
        "x^y": Operations.BinaryOperation { pow($0, $1) },
        "e^x": Operations.UnaryOperation { exp($0) },
        "10^x": Operations.UnaryOperation { pow(10, $0) },
        "1/x": Operations.UnaryOperation { 1 / $0 },
        "square(x)": Operations.UnaryOperation { sqrt($0) },
        "cube(x)": Operations.UnaryOperation { pow($0, 1/3) },
        "x^(1/y)": Operations.BinaryOperation { pow($0, 1/$1) },
        "Ln": Operations.UnaryOperation { log($0) },
        "Lg": Operations.UnaryOperation { log10($0) },
        "x!": Operations.UnaryOperation {
            x in
            switch x {
            case 0:
                return 1
            case 1:
                return 1
            case 2:
                return 2
            case 3:
                return 6
            case 4:
                return 24
            case 5:
                return 120
            case 6:
                return 720
            case 7:
                return 5040
            case 8:
                return 40320
            case 9:
                return 362880
            case 10:
                return 3628800
            case 11:
                return 39916800
            default:
                return -1
            }
            return -1
        },
        "sin": Operations.UnaryOperation { sin($0) },
        "cos": Operations.UnaryOperation { cos($0) },
        "tan": Operations.UnaryOperation { tan($0) },
        "e": Operations.Constant(exp(1)),
        "EE": Operations.BinaryOperation { $0 * pow(10, $1) },
        "sinh": Operations.UnaryOperation { sinh($0) },
        "cosh": Operations.UnaryOperation { cosh($0) },
        "tanh": Operations.UnaryOperation { tanh($0) },
        "π": Operations.Constant(Double.pi),
        "mr": Operations.MemoryOperation,
        "mc": Operations.MemoryOperation,
        "m+": Operations.BinaryOperation { $0 + memorizedResult },
        "m-": Operations.BinaryOperation { $0 - memorizedResult }
    ]
    
   
    func performOperation (operation: String, operand: Double) -> Double? {
        if let op = operations[operation] {
            switch op {
            case .BinaryOperation(let function):
                pendingOperation = Intermediate(firstOperand: operand, waitingOperation: function)
                return nil
            case .Constant(let value):
                return value
            case .EqualOperation:
                return pendingOperation?.waitingOperation(pendingOperation!.firstOperand, operand)
            case .UnaryOperation(let function):
                return function(operand)
            case .MemoryOperation:
                switch operation {
                case "mr":
                    memorizedResult = operand
                case "mc":
                    memorizedResult = 0.0
                }
            }
        }
        return nil
    }
}
