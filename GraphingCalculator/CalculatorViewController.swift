//
//  GraphingView.swift
//  GraphingCalculator
//
//  Created by Daniel Man on 03/13/16
//  Copyright © 2016 DanielManApps All rights reserved.
//

import UIKit

class CalculatorViewController: UIViewController {
    @IBOutlet weak var display: UILabel!
    @IBOutlet weak var history: UILabel!
    
    private struct DefaultDisplayResult {
        static let Startup: Double = 0
        static let Error = "Error!"
    }
    
    private var userTyping = false
    private let defaultHistoryText = " "
    
    private var brain = CalculatorBrain()

    @IBAction func clearButton() {
        brain.clearStack()
        brain.variableValues.removeAll()
        displayResult = CalculatorBrainEvaluationResult.Success(DefaultDisplayResult.Startup)
        history.text = defaultHistoryText
    }
    
    @IBAction func appendDigit(sender: UIButton) {
        let digit = sender.currentTitle!
        if userTyping {
            if digit != "." || display.text!.rangeOfString(".") == nil {
                display.text = display.text! + digit
            }
        } else {
            display.text = digit
            userTyping = true
        }
    }

    @IBAction func undoButton() {
        if userTyping == true {
            if display.text!.characters.count > 1 {
                display.text = String(display.text!.characters.dropLast())
            } else {
                displayResult = CalculatorBrainEvaluationResult.Success(DefaultDisplayResult.Startup)
            }
        } else {
            brain.removeLastOpFromStack()
            displayResult = brain.evaluateAndReportErrors()
        }
    }
    
    @IBAction func changeSignButton() {
        if userTyping {
            if displayValue != nil {
                displayResult = CalculatorBrainEvaluationResult.Success(displayValue! * -1)
                
                userTyping = true
            }
        } else {
            displayResult = brain.performOperation("ᐩ/-")
        }
    }
    
    @IBAction func pi() {
        if userTyping {
            enterButton()
        }
        displayResult = brain.pushConstant("π")
    }
    
    @IBAction func setM() {
        userTyping = false
        if displayValue != nil {
            brain.variableValues["M"] = displayValue!
        }
        displayResult = brain.evaluateAndReportErrors()
    }
    
    @IBAction func getM() {
        if userTyping {
            enterButton()
        }
        displayResult = brain.pushOperand("M")
    }    
    
    @IBAction func operate(sender: UIButton) {
        if userTyping {
            enterButton()
        }
        if let operation = sender.currentTitle {
            displayResult = brain.performOperation(operation)
        }
    }
    
    @IBAction func enterButton() {
        userTyping = false
        if displayValue != nil {
            displayResult = brain.pushOperand(displayValue!)
        }
    }
    
    private var displayValue: Double? {
        if let displayValue = NSNumberFormatter().numberFromString(display.text!) {
            return displayValue.doubleValue
        }
        return nil
    }
    
    private var displayResult: CalculatorBrainEvaluationResult? {
        get {
            if let displayValue = displayValue {
                return .Success(displayValue)
            }
            if display.text != nil {
                return .Failure(display.text!)
            }
            return .Failure("Error")
        }
        set {
            if newValue != nil {
                switch newValue! {
                case let .Success(displayValue):
                    display.text = "\(displayValue)"
                case let .Failure(error):
                    display.text = error
                }
            } else {
                display.text = DefaultDisplayResult.Error
            }
            userTyping = false
            
            if !brain.description.isEmpty {
                history.text = " \(brain.description.joinWithSeparator(", ")) ="
            } else {
                history.text = defaultHistoryText
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        var destination: UIViewController? = segue.destinationViewController
        if let navCon = destination as? UINavigationController {
            destination = navCon.visibleViewController
        }
        if let gvc = destination as? GraphingViewController {
            gvc.program = brain.program
            if let graphLabel = brain.description.last {
                gvc.graphLabel = graphLabel
            }
        }
    }

}

