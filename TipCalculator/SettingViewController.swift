//
//  SettingViewController.swift
//  TipCalculator
//
//  Created by Manhong Ren on 3/5/17.
//  Copyright © 2017 Manhong Ren. All rights reserved.
//

import Foundation
import UIKit

let TIP_PERCENT_KEY = "TIP_PERCENT_KEY"
let OPTIONAL_TIP_PERCENT_VALUE = [0.18, 0.2, 0.25]
let OPTIONAL_TIP_PERCENT_STRING = ["18%", "20%", "25%"]

class SettingViewController: UIViewController {
    
    let HORIZONTAL_MARGIN = 12

    var defaultTipPercentLabel = UILabel()
    var defaultTipPercentControl = UISegmentedControl(items: OPTIONAL_TIP_PERCENT_STRING);
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        
        self.view.addSubview(self.defaultTipPercentLabel)
        defaultTipPercentLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self.view.snp.top).offset(20)
            make.left.equalTo(self.view.snp.left).offset(HORIZONTAL_MARGIN)
            make.right.equalTo(self.view.snp.right).offset(-HORIZONTAL_MARGIN)
            make.height.equalTo(40);
        }
        self.defaultTipPercentLabel.text = "Default Tip percentage:"
        self.defaultTipPercentLabel.textColor = UIColor.gray
        self.defaultTipPercentLabel.font = UIFont.systemFont(ofSize: 20)
        
        self.view.addSubview(defaultTipPercentControl)
        defaultTipPercentControl.snp.makeConstraints { (make) in
            make.top.equalTo(defaultTipPercentLabel.snp.bottom).offset(20)
            make.left.equalTo(self.view.snp.left).offset(HORIZONTAL_MARGIN)
            make.right.equalTo(self.view.snp.right).offset(-HORIZONTAL_MARGIN)
        }
        defaultTipPercentControl.addTarget(
            self, action: #selector(_defaultTipPercentDidChanged), for: .valueChanged)
        
        _updateSelectedTipPercentage()
    }
    
    func _updateSelectedTipPercentage() {
        let currentDefaultTipPercent = UserDefaults.standard.double(forKey: TIP_PERCENT_KEY)
        
        for i in 0...OPTIONAL_TIP_PERCENT_VALUE.count - 1 {
            if (OPTIONAL_TIP_PERCENT_VALUE[i] == currentDefaultTipPercent) {
                defaultTipPercentControl.selectedSegmentIndex = i
                break
            }
        }
    }
    
    func _defaultTipPercentDidChanged(segment: UISegmentedControl) {
        UserDefaults.standard.set(
            OPTIONAL_TIP_PERCENT_VALUE[segment.selectedSegmentIndex],
            forKey: TIP_PERCENT_KEY)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
