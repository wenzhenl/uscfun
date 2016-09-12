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
        
        form +++ Section("活动名称(必填)")
            <<< TextAreaRow(){ row in
                row.placeholder = "例如: 中午去中国城吃饭有人去么"
            }
            +++ Section("活动类型(必填)")
            <<< SegmentedRow<String>() {
                $0.options = ["吃饭","购物","娱乐","学习","其他"]
                $0.value = "其他"
            }
            +++ Section("活动人数(必填)")
            <<< IntRow() {
                $0.title = "最多参与人数(包括自己)"
                $0.placeholder = "0"
            }
            <<< IntRow() {
                $0.title = "自己加上私下决定要去的人"
                $0.placeholder = "0"
            }
            <<< IntRow() {
                $0.title = "至少差几个人"
                $0.placeholder = "0"
            }
            +++ Section(header: "报名截止时间(必填)", footer: "报名截止后没有达到最少报名人数的活动会自动解散")
            <<< DateTimeRow(){
                $0.title = "报名截止时间"
                $0.value = NSDate()
            }
            +++ Section("高级设置(选填)")
            <<< DateRow(){
                $0.title = "活动时间"
                $0.value = NSDate()
            }
            <<< TextRow() {
                $0.title = "活动地点"
                $0.placeholder = "待定"
            }
            <<< DecimalRow() {
                $0.title = "预计费用"
                $0.placeholder = "0.0"
            }
            <<< SegmentedRow<String>() {
                $0.title = "出行方式"
                $0.options = ["我开","Uber","再说"]
                $0.value = "再说"
            }
            +++ Section("其他需要说明的情况(选填)")
            <<< TextAreaRow(){ row in
                row.placeholder = "比如需不需要带现金，户外活动需要什么样的装备等等"
            }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        UIApplication.sharedApplication().statusBarStyle = .Default
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(true)
        UIApplication.sharedApplication().statusBarStyle = .LightContent
        self.view.endEditing(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func close() {
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
}