//
//  ViewController.swift
//  calculator
//
//  Created by nju on 2021/10/8.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var resultDisplay: UILabel!
    @IBOutlet weak var radButtom: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        resultDisplay.text = ""
    }

    var typingNow = false
    
    @IBAction func numberTouched(_ sender: UIButton) {
        if typingNow {
            resultDisplay.text = resultDisplay.text! +  sender.currentTitle!
        }
        else {
            resultDisplay.text = sender.currentTitle!
            typingNow = true
        }
    }
    
    
    let calculator = Calculator()
    @IBAction func operatorTouched(_ sender: UIButton) {
//        print("Buttom \(sender.currentTitle!) touched")
        if let operation  = sender.currentTitle {
            if let result = calculator.performOperation(operation: operation, operand: Double(resultDisplay.text!)!) {
                resultDisplay.text = String(result)
            }
            typingNow = false
        }
    }
    
    @IBAction func radTouched(_ sender: UIButton) {
        if sender.currentTitle! == "Rad now" {
            radButtom.setTitle("Deg now", for: .normal)
        }
        else {
            radButtom.setTitle("Rad now", for: .normal)
        }
    }
    
    @IBAction func randTouched(_ sender: UIButton) {
        resultDisplay.text = String(Double.random(in: 0...1))
    }
}

