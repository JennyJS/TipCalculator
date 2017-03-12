//
//  ViewController.swift
//  TipCalculator
//
//  Created by Manhong Ren on 3/4/17.
//  Copyright © 2017 Manhong Ren. All rights reserved.
//

import UIKit
import SnapKit

let BILL_AMOUNT_KEY = "BILL_AMOUNT_KEY"
let BILL_AMOUNT_CACHED_TS_KEY = "BILL_AMOUNT_CACHED_TS_KEY"
let REMEMBER_BILL_AMOUNT_TIME_WINDOW_SEC = 10 * 60

class ViewController: UIViewController, UITextFieldDelegate {
    
    let HORIZONTAL_MARGIN = 12;
    
    var billContainer = UIView();
    var billTextField = UITextField();
    var billLabel = UILabel();
    
    var tipContainer = UIView();
    var tipLabel = UILabel();
    var tipAmountLabel = UILabel();
    
    var lineSeparator = UIView();
    
    var totalContainer = UIView();
    var totalLabel = UILabel();
    var totalAmountLabel = UILabel();
    
    var billAmount: Double = 0.0
    var tipPercent: Double = 0.0
    var tipAmount: Double = 0.0
    var totalAmount: Double = 0.0
    
    var tipPercentSegmentControl = UISegmentedControl(items: OPTIONAL_TIP_PERCENT_STRING);

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white;
        
        _addSettingBarButtonItem()
        _addBillingSection()
        _addTipSection()
        _addTipSegmentControll()
        _addLineSeparator()
        _addTotalSection()
        
        self.view.isUserInteractionEnabled = true
        _maybeSetCachedBillAmount()
    }
    
    // MARK: Calcualtion Logic
    
    func _formatBillAmount(billAmount: NSNumber) -> String? {
        let fmt = NumberFormatter()
        fmt.numberStyle = .decimal
        return fmt.string(from: billAmount)
    }
    
    // Remembering the bill amount across app restarts (if <10mins)
    func _maybeSetCachedBillAmount() {
        let prevBillAmount = UserDefaults.standard.string(forKey: BILL_AMOUNT_KEY)
        let prevBillAmountCachedTS = UserDefaults.standard.integer(forKey: BILL_AMOUNT_CACHED_TS_KEY)
        let currentTS = Int(NSDate().timeIntervalSince1970)
        if (currentTS - prevBillAmountCachedTS < REMEMBER_BILL_AMOUNT_TIME_WINDOW_SEC) {
            if (prevBillAmount != nil) {
                billTextField.text = prevBillAmount
                billAmount = Double(prevBillAmount!)!
                _recalcaulteTotalAndUpdateUI()
            }
        }
    }
    
    func _recalcaulteTotalAndUpdateUI() {
        tipAmount = billAmount * tipPercent
        totalAmount = billAmount + tipAmount
        
        UIView.transition(with: tipAmountLabel,
                          duration: 0.25,
                          options: [.transitionCrossDissolve],
                          animations: {
                            self.tipAmountLabel.text = String(self.tipAmount)
        }, completion: nil)
        
        UIView.transition(with: totalAmountLabel,
                          duration: 0.25,
                          options: [.transitionCrossDissolve],
                          animations: {
                            self.totalAmountLabel.text = String(self.totalAmount)
        }, completion: nil)
    }
    
    // MARK: Accessor
    
    func _setTipPercent(tipPercent: Double) {
        self.tipPercent = tipPercent
        _recalcaulteTotalAndUpdateUI()
    }
    
    // MARK: UI Event
    
    func _billDidChange(_ textField: UITextField) {
        let filteredString = textField.text?.replacingOccurrences(of: ",", with: "")
        billAmount = Double(filteredString ?? "0") ?? 0
        textField.text = _formatBillAmount(billAmount: NSNumber(value: billAmount))
        if (filteredString?.characters.last == ".") {
            textField.text = textField.text! + "."
        }
        UserDefaults.standard.set(filteredString, forKey: BILL_AMOUNT_KEY)
        UserDefaults.standard.set(Int(NSDate().timeIntervalSince1970), forKey: BILL_AMOUNT_CACHED_TS_KEY)
        _recalcaulteTotalAndUpdateUI()
    }
    
    func _tipPercentDidChanged(segment: UISegmentedControl) {
        tipPercent = OPTIONAL_TIP_PERCENT_VALUE[segment.selectedSegmentIndex]
        _recalcaulteTotalAndUpdateUI()
    }
    
    func _addSettingBarButtonItem() {
        let rightBarButtonItem = UIBarButtonItem(
            title: "Setting",
            style: .plain,
            target: self,
            action: #selector(_didTapSetting)
        )
        
        self.navigationItem.rightBarButtonItem = rightBarButtonItem;
    }
    
    func _didTapSetting() {
        let settingViewController = SettingViewController()
        self.navigationController?.pushViewController(settingViewController, animated: true);
    }
    
    // MARK: UI Setup
    
    func _addBillingSection() {
        view.addSubview(billContainer);
        billContainer.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(self.view.snp.top).offset(20);
            make.left.equalTo(self.view.snp.left).offset(HORIZONTAL_MARGIN);
            make.right.equalTo(self.view.snp.right).offset(-HORIZONTAL_MARGIN);
            make.height.equalTo(30);
        }
        
        billContainer.addSubview(billLabel);
        billLabel.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(billContainer.snp.left);
            make.centerY.equalTo(billContainer);
        }
        billLabel.text = "Billing Amount";
        billLabel.textColor = UIColor.gray;
        billLabel.font = UIFont.boldSystemFont(ofSize: 24);
        
        billContainer.addSubview(billTextField);
        billTextField.snp.makeConstraints { (make) -> Void in
            make.right.equalTo(billContainer);
            make.centerY.equalTo(billContainer)
            make.height.equalTo(30);
            make.width.equalTo(150);
        }
        billTextField.font = UIFont.systemFont(ofSize: 30)
        billTextField.textColor = UIColor.gray
        billTextField.keyboardType = UIKeyboardType.decimalPad
        billTextField.textAlignment = .right
        billTextField.becomeFirstResponder()
        billTextField.addTarget(self, action: #selector(_billDidChange), for: .editingChanged)
        
        let underline = UIView()
        billContainer.addSubview(underline)
        underline.snp.makeConstraints { (make) in
            make.right.equalTo(billContainer)
            make.bottom.equalTo(billContainer)
            make.height.equalTo(2)
            make.width.equalTo(billTextField.snp.width)
        }
        underline.backgroundColor = UIColor.lightGray
    }
    
    func _addTipSection() {
        view.addSubview(tipContainer);
        tipContainer.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(billContainer.snp.bottom).offset(20);
            make.left.equalTo(self.view.snp.left).offset(HORIZONTAL_MARGIN);
            make.right.equalTo(self.view.snp.right).offset(-HORIZONTAL_MARGIN);
            make.height.equalTo(30);
        }
        
        tipContainer.addSubview(tipLabel);
        tipLabel.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(tipContainer.snp.left);
            make.centerY.equalTo(tipContainer);
        }
        tipLabel.text = "Tip";
        tipLabel.textColor = UIColor.gray;
        tipLabel.font = UIFont.boldSystemFont(ofSize: 24);
        
        tipContainer.addSubview(tipAmountLabel);
        tipAmountLabel.snp.makeConstraints { (make) in
            make.right.equalTo(tipContainer.snp.right);
            make.centerY.equalTo(tipContainer);
        }
        tipAmountLabel.text = "0";
        tipAmountLabel.textColor = UIColor.gray;
        tipAmountLabel.font = UIFont.boldSystemFont(ofSize: 18);
    }
    
    func _addLineSeparator() {
        view.addSubview(lineSeparator);
        lineSeparator.snp.makeConstraints { (make) in
            make.top.equalTo(tipPercentSegmentControl.snp.bottom).offset(20);
            make.left.equalTo(self.view.snp.left).offset(HORIZONTAL_MARGIN);
            make.right.equalTo(self.view.snp.right).offset(-HORIZONTAL_MARGIN);
            make.height.equalTo(5);
        }
        lineSeparator.backgroundColor = UIColor.red;
    }
    
    func _addTipSegmentControll() {
        view.addSubview(tipPercentSegmentControl);
        tipPercentSegmentControl.snp.makeConstraints { (make) in
            make.top.equalTo(tipContainer.snp.bottom).offset(20);
            make.left.equalTo(self.view.snp.left).offset(HORIZONTAL_MARGIN);
            make.right.equalTo(self.view.snp.right).offset(-HORIZONTAL_MARGIN);
            make.height.equalTo(40);
        }
        tipPercentSegmentControl.addTarget(self, action: #selector(_tipPercentDidChanged), for: .valueChanged)
        
        _updateSelectedTipPercentage()
    }
    
    func _updateSelectedTipPercentage() {
        let currentDefaultTipPercent = UserDefaults.standard.double(forKey: TIP_PERCENT_KEY)
        
        for i in 0...OPTIONAL_TIP_PERCENT_VALUE.count - 1 {
            if (OPTIONAL_TIP_PERCENT_VALUE[i] == currentDefaultTipPercent) {
                tipPercentSegmentControl.selectedSegmentIndex = i
                tipPercent = currentDefaultTipPercent
                break
            }
        }
    }
    
    func _addTotalSection() {
        view.addSubview(totalContainer);
        totalContainer.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(tipPercentSegmentControl.snp.bottom).offset(20);
            make.left.equalTo(self.view.snp.left).offset(HORIZONTAL_MARGIN);
            make.right.equalTo(self.view.snp.right).offset(-HORIZONTAL_MARGIN);
            make.height.equalTo(100);
        }
        
        totalContainer.addSubview(totalLabel);
        totalLabel.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(totalContainer.snp.left);
            make.centerY.equalTo(totalContainer);
        }
        totalLabel.text = "Total";
        totalLabel.textColor = UIColor.darkGray;
        totalLabel.font = UIFont.boldSystemFont(ofSize: 38);
        
        totalContainer.addSubview(totalAmountLabel);
        totalAmountLabel.snp.makeConstraints { (make) in
            make.right.equalTo(totalContainer.snp.right);
            make.centerY.equalTo(totalContainer);
        }
        totalAmountLabel.text = "0";
        totalAmountLabel.textColor = UIColor.darkGray;
        totalAmountLabel.font = UIFont.boldSystemFont(ofSize: 38);
    }
    
}

