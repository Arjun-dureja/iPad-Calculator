//
//  ViewController.swift
//  Calculator
//
//  Created by Arjun Dureja on 2020-07-11.
//  Copyright © 2020 Arjun Dureja. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var buttons = [UIButton]()
    var titles = [
        ["AC", "+/-", "%", "÷"],
        ["7", "8", "9", "×"],
        ["4", "5", "6", "-"],
        ["1", "2", "3", "+"],
        ["0", "0", ".", "="]
    ]
    var colors: [[UIColor]] = [
        [.lightGray, .lightGray, .lightGray, .systemOrange],
        [.calcGray, .calcGray, .calcGray, .systemOrange]
    ]
    var tags: [[Int]] = [
        [1, 1, 1, 2],
        [3, 3, 3, 2]
    ]
    
    var textColors: [UIColor] = [.black, .black, .black, . white]
    
    var label: UILabel!
    
    var number: String? = "0"
    
    var prevNum = "0"
    var prevTapped = "0"
    
    var isOperationActive = false
    
    enum Operation {
        case addition
        case subtraction
        case multiplication
        case division
    }
    
    var currentOperation: Operation!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        for row in 0..<5 {
            for col in 0..<4 {
                let button = UIButton(type: .custom)
                button.frame = CGRect(x: 45 + col*200, y: 285 + row*165, width: 140, height: 140)
                button.layer.cornerRadius = button.frame.width/2
                
                if row == 4 && col == 1 {
                    continue
                }
                
                if row == 0 {
                    button.backgroundColor = colors[0][col]
                    button.setTitleColor(textColors[col], for: .normal)
                    button.tag = tags[0][col]
                } else {
                    button.backgroundColor = colors[1][col]
                    button.setTitleColor(.white, for: .normal)
                    button.tag = tags[1][col]
                }

                button.setTitle(titles[row][col], for: .normal)
                
                if button.titleLabel?.text == "=" {
                    button.tag = 4
                }

                button.titleLabel?.font = UIFont.systemFont(ofSize: 58)
                if row == 4 && col == 0 {
                    button.frame.size.width *= 2.45
                    button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 200)
                }
                button.addTarget(self, action: #selector(btnTapped(_:)), for: .touchUpInside)
                button.addTarget(self, action: #selector(touchDown(_:)), for: [.touchDown, .touchDragEnter])
                button.addTarget(self, action: #selector(touchUp(_:)), for: [.touchUpInside, .touchDragExit, .touchCancel])

                buttons.append(button)
            }
        }
        for i in 0..<buttons.count {
            view.addSubview(buttons[i])
        }
        
        label = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        label.sizeToFit()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "0"
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 120, weight: .light)
        view.addSubview(label)
        
        label.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 105).isActive = true
        label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -80).isActive = true
    }
    private var animator = UIViewPropertyAnimator()
    var prevBtn: UIButton!
    @objc private func touchDown(_ sender: UIButton) {
        if sender == prevBtn {
            animator.stopAnimation(true)
        } else {
            prevBtn = sender
        }
        switch sender.tag {
        case 3:
            sender.backgroundColor = .highlightedCalcGray
        case 1:
            sender.backgroundColor = .highlightedLightGray
        case 2:
            sender.backgroundColor = .highlightedOrange
        case 4:
            sender.backgroundColor = .highlightedOrange
        default:
            break
        }
    }
    @objc private func touchUp(_ sender: UIButton) {
        animator = UIViewPropertyAnimator(duration: 0.5, curve: .easeOut, animations: {
            switch sender.backgroundColor! {
            case .highlightedCalcGray:
                sender.backgroundColor = .calcGray
            case .highlightedLightGray:
                sender.backgroundColor = .lightGray
            case .highlightedOrange:
                if sender.tag == 2 {
                    for button in self.buttons {
                        if button.backgroundColor == .white {
                            button.backgroundColor = .systemOrange
                            button.setTitleColor(.white, for: .normal)
                        }
                    }
                    sender.backgroundColor = .white
                    sender.setTitleColor(.systemOrange, for: .normal)
                } else {
                    sender.backgroundColor = .systemOrange
                }
            default:
                break
            }
        })
        animator.startAnimation()
    }
    
    @objc func btnTapped(_ sender: UIButton) {
        prevTapped = sender.titleLabel!.text!
        if number!.count >= 9 && sender.titleLabel?.text != "+/-" && sender.titleLabel?.text != "C" {
            return
        }
        // ALL Clear tapped
        if sender.titleLabel?.text == "AC" {
            number = "0"
            prevNum = "0"
            for button in self.buttons {
                if button.backgroundColor == .white {
                    UIView.animate(withDuration: 0.5) {
                        button.backgroundColor = .systemOrange
                        button.setTitleColor(.white, for: .normal)
                    }
                }
            }
        }
        // Clear tapped
        else if sender.titleLabel?.text == "C" {
            number = "0"
            buttons[0].setTitle("AC", for: .normal)
        }
        // Plus or minus tapped
        else if sender.titleLabel?.text == "+/-" {
            if label.text?.first != "-" {
                number = "-" + number!
            } else {
                number!.remove(at: number!.startIndex)
            }
        }
        // Percent button tapped
        else if sender.titleLabel?.text == "%" {
            number = String(Double(number!)! / 100)
        }
        // Plus button tapped
        else if sender.titleLabel?.text == "+" {
            isOperationActive = true
            currentOperation = .addition
            prevNum = number!
        }
        else if sender.titleLabel?.text == "-" {
            isOperationActive = true
            currentOperation = .subtraction
            prevNum = number!
        }
        else if sender.titleLabel?.text == "×" {
            isOperationActive = true
            currentOperation = .multiplication
            prevNum = number!
        }
        else if sender.titleLabel?.text == "÷" {
            isOperationActive = true
            currentOperation = .division
            prevNum = number!
        }
        // Equals button tapped
        else if sender.titleLabel?.text == "=" {
            if isOperationActive {
                isOperationActive = false
                for button in buttons {
                    if button.backgroundColor == .white {
                        prevNum = number!
                        UIView.animate(withDuration: 0.5) {
                            button.backgroundColor = .systemOrange
                            button.setTitleColor(.white, for: .normal)
                        }
                    }
                }
                switch currentOperation {
                case .addition:
                    let tempNum = number
                    number = String(Double(prevNum)! + Double(number!)!)
                    prevNum = tempNum!
                case .subtraction:
                    let tempNum = number
                    number = String(Double(prevNum)! - Double(number!)!)
                    prevNum = tempNum!
                case .multiplication:
                    let tempNum = number
                    number = String(Double(prevNum)! * Double(number!)!)
                    prevNum = tempNum!
                case .division:
                    if number == "0" {
                        label.text = "Error"
                        return
                    }
                    let tempNum = number
                    number = String(Double(prevNum)! / Double(number!)!)
                    prevNum = tempNum!
                default:
                    break
                }
            } else {
                switch currentOperation {
                case .addition:
                    number = String(Double(prevNum)! + Double(number!)!)
                case .subtraction:
                    number = String(Double(prevNum)! - Double(number!)!)
                case .multiplication:
                    number = String(Double(prevNum)! * Double(number!)!)
                case .division:
                    if number == "0" {
                        label.text = "Error"
                        return
                    }
                    number = String(Double(prevNum)! / Double(number!)!)
                default:
                    break
                }
            }
        }
        // Any other button tapped
        else {
            // Tapped while label is empty
            if label.text == "0" {
                if sender.titleLabel?.text != "0" {
                    UIView.performWithoutAnimation {
                        buttons[0].setTitle("C", for: .normal)
                        buttons[0].layoutIfNeeded()
                    }
                }
                number = sender.titleLabel?.text!
                
                if isOperationActive {
                    switch currentOperation {
                    case .addition:
                        for button in buttons {
                            if button.titleLabel?.text == "+" {
                                UIView.animate(withDuration: 0.5) {
                                    button.backgroundColor = .systemOrange
                                    button.setTitleColor(.white, for: .normal)
                                }
                            }
                        }
                    case .subtraction:
                        for button in buttons {
                            if button.titleLabel?.text == "-" {
                                UIView.animate(withDuration: 0.5) {
                                    button.backgroundColor = .systemOrange
                                    button.setTitleColor(.white, for: .normal)
                                }
                            }
                        }
                    case .multiplication:
                        for button in buttons {
                            if button.titleLabel?.text == "×" {
                                UIView.animate(withDuration: 0.5) {
                                    button.backgroundColor = .systemOrange
                                    button.setTitleColor(.white, for: .normal)
                                }
                            }
                        }
                    default:
                        for button in buttons {
                            if button.titleLabel?.text == "÷" {
                                UIView.animate(withDuration: 0.5) {
                                    button.backgroundColor = .systemOrange
                                    button.setTitleColor(.white, for: .normal)
                                }
                            }
                        }
                    }
                }
            }
            // Tapped with other numbers present
            else {
                if prevNum == "0" {
                    number!.append((sender.titleLabel?.text)!)
                } else {
                    if number == prevNum {
                        number = sender.titleLabel?.text
                        switch currentOperation {
                        case .addition:
                            for button in buttons {
                                if button.titleLabel?.text == "+" {
                                    UIView.animate(withDuration: 0.5) {
                                        button.backgroundColor = .systemOrange
                                        button.setTitleColor(.white, for: .normal)
                                    }
                                }
                            }
                        case .subtraction:
                            for button in buttons {
                                if button.titleLabel?.text == "-" {
                                    UIView.animate(withDuration: 0.5) {
                                        button.backgroundColor = .systemOrange
                                        button.setTitleColor(.white, for: .normal)
                                    }
                                }
                            }
                        case .multiplication:
                            for button in buttons {
                                if button.titleLabel?.text == "×" {
                                    UIView.animate(withDuration: 0.5) {
                                        button.backgroundColor = .systemOrange
                                        button.setTitleColor(.white, for: .normal)
                                    }
                                }
                            }
                        default:
                            for button in buttons {
                                if button.titleLabel?.text == "÷" {
                                    UIView.animate(withDuration: 0.5) {
                                        button.backgroundColor = .systemOrange
                                        button.setTitleColor(.white, for: .normal)
                                    }
                                }
                            }
                        }
                    } else {
                        number!.append((sender.titleLabel?.text)!)
                    }
                }
            }
        }
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumFractionDigits = 8
        
        let formattedNumber = numberFormatter.string(from: NSNumber(value: Double(number!) ?? 0))
        
        label.text = formattedNumber
    }

}

extension UIColor {
    static let calcGray = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1)
    static let highlightedCalcGray = UIColor(red: 107/255, green: 108/255, blue: 109/255, alpha: 1)
    static let highlightedLightGray = UIColor(red: 216/255, green: 217/255, blue: 218/255, alpha: 1)
    static let highlightedOrange = UIColor(red: 250/255, green: 197/255, blue: 141/255, alpha: 1)
}

