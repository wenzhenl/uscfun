//
//  StartEventViewController.swift
//  uscfun
//
//  Created by Wenzheng Li on 9/4/16.
//  Copyright © 2016 Wenzheng Li. All rights reserved.
//

import UIKit
import Eureka

class StartEventViewController: FormViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // UI
        self.navigationController!.navigationBar.barTintColor = UIColor.buttonBlue()
        self.navigationController!.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: UIFont.systemFontOfSize(20)]
        self.view.backgroundColor = UIColor.backgroundGray()
        
        form +++ Section("活动名称")
            <<< TextAreaRow(){ row in
                row.placeholder = "Enter text here"
            }
            +++ Section("活动人数")
            <<< IntRow() {
                $0.title = "活动计划总人数"
                $0.placeholder = "不限"
            }
            <<< IntRow() {
                $0.title = "已经决定参与的人数"
                $0.placeholder = "1"
            }
            <<< IntRow() {
                $0.title = "至少还需要报名的人数"
                $0.placeholder = "1"
            }
            +++ Section("报名截止时间")
            <<< DateTimeRow(){
                $0.title = "报名截止时间"
                $0.value = NSDate(timeIntervalSinceReferenceDate: 0)
            }
            +++ Section("高级设置")
            <<< DateRow(){
                $0.title = "活动时间"
                $0.value = NSDate(timeIntervalSinceReferenceDate: 0)
            }
            <<< DecimalRow() {
                $0.title = "预计费用"
                $0.placeholder = "0.0"
            }
            <<< SwitchRow() {
                $0.title = "出行方式"
            }
            +++ Section("其他需要说明的情况")
            <<< TextAreaRow(){ row in
                row.placeholder = "Enter text here"
            }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func close() {
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
}