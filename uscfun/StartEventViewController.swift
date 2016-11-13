//
//  StartEventViewController.swift
//  uscfun
//
//  Created by Wenzheng Li on 9/4/16.
//  Copyright © 2016 Wenzheng Li. All rights reserved.
//

import UIKit
import AVOSCloud
import SVProgressHUD
import Eureka

class StartEventViewController: FormViewController {
    @IBOutlet weak var cancleButton: UIBarButtonItem!
    @IBOutlet weak var postButton: UIBarButtonItem!
    
    var delegate: EventMemberStatusDelegate?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.navigationController!.navigationBar.tintColor = UIColor.darkGray
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.darkGray]
        
        self.postButton.isEnabled = false
        
        var nameRules = RuleSet<String>()
        nameRules.add(rule: RuleMinLength(minLength: 1))
        nameRules.add(rule: RuleMaxLength(maxLength: 140))
        form +++ Section(header: "微活动名称", footer: "活动名称请控制在140个字符之内")
            <<< TextAreaRow("eventTitle") {
                $0.placeholder = "请给出一个简洁的活动名称！"
                $0.add(ruleSet: nameRules)
                $0.validationOptions = .validatesOnBlur
                }
                .cellUpdate {
                    cell, row in
                    if !row.isValid {
                        cell.textView.textColor = .red
                        self.postButton.isEnabled = false
                    } else if cell.textView.text.characters.count > 0 {
                        cell.textView.textColor = UIColor.darkGray
                        self.postButton.isEnabled = true
                    }
                }
            
            +++ Section()
            <<< AlertRow<String> ("eventType") {
                $0.title = "微活动类型"
                $0.selectorTitle = "微活动类型"
                $0.options = EventType.allRawValues
                $0.value = EventType.other.rawValue
                }
                .cellSetup {
                    cell, row in
                    cell.textLabel?.textColor = UIColor.darkGray
                }
                .cellUpdate {
                    cell, row in
                    cell.detailTextLabel?.textColor = UIColor.darkGray
                }
            
            +++ Section(header: "微活动人数", footer: "任意时刻剩余席位为零，活动自动完成约定")
            <<< StepperRow("totalSeats") {
                $0.title = "全部席位(包括自己)"
                $0.value = 2
                $0.add(rule: RuleGreaterThan(min: 1))
                $0.validationOptions = .validatesOnChange
                }
                .cellSetup {
                    cell, row in
                    cell.valueLabel.textColor = UIColor.darkGray
                    cell.stepper.tintColor = UIColor.avatarBlue
                }
                .cellUpdate {
                    cell, row in
                    cell.valueLabel.text = String(Int(row.value!))
                    if !row.isValid {
                        row.value = 2
                    }
                }
            
            
            <<< StepperRow("remainingSeats") {
                $0.title = "剩余席位"
                $0.value = 1
                $0.add(rule: RuleGreaterThan(min: 0))
                $0.validationOptions = .validatesOnChange
                }
                .cellSetup {
                    cell, row in
                    cell.valueLabel.textColor = UIColor.darkGray
                    cell.stepper.tintColor = UIColor.avatarBlue
                }
                .cellUpdate {
                    cell, row in
                    cell.valueLabel.text = String(Int(row.value!))
                    if !row.isValid {
                        row.value = 1
                    }
                }
            
            <<< StepperRow("minimumMoreAttendingPeople") {
                $0.title = "至少还需要报名人数"
                $0.value = 1
                $0.add(rule: RuleGreaterThan(min: 0))
                $0.validationOptions = .validatesOnChange
                }
                .cellSetup {
                    cell, row in
                    cell.valueLabel.textColor = UIColor.darkGray
                    cell.stepper.tintColor = UIColor.avatarBlue
                }
                .cellUpdate {
                    cell, row in
                    cell.valueLabel.text = String(Int(row.value!))
                    if !row.isValid {
                        row.value = 1
                    }
                }
            
            +++ Section(header: "", footer: "报名截止后没有达到最少报名人数的微活动会自动解散，达到了的自动完成约定")
            <<< DateTimeRow("due"){
                $0.title = "报名截止时间"
                $0.value = Date()
                $0.add(rule: RuleGreaterThan(min: Date()))
                $0.validationOptions = .validatesOnChange
                }
                .cellSetup {
                    cell, row in
                    cell.textLabel?.textColor = UIColor.darkGray
                }
                .cellUpdate {
                    cell, row in
                    if !row.isValid {
                        row.value = Date()
                    } else {
                        cell.detailTextLabel?.textColor = UIColor.darkGray
                    }
                }
            
            +++ Section("高级设置(选填)")
            <<< DateTimeRow("eventStartTime"){
                $0.title = "开始时间"
                $0.value = Date()
                $0.add(rule: RuleGreaterThan(min: Date()))
                $0.validationOptions = .validatesOnChange
                }
                .cellSetup {
                    cell, row in
                    cell.textLabel?.textColor = UIColor.darkGray
                }
                .cellUpdate {
                    cell, row in
                    if !row.isValid {
                        row.value = Date()
                    } else {
                        cell.detailTextLabel?.textColor = UIColor.darkGray
                    }
                }

            <<< DateTimeRow("eventEndTime"){
                $0.title = "结束时间"
                $0.value = Date()
                $0.add(rule: RuleGreaterThan(min: Date()))
                $0.validationOptions = .validatesOnChange
                }
                .cellSetup {
                    cell, row in
                    cell.textLabel?.textColor = UIColor.darkGray
                }
                .cellUpdate {
                    cell, row in
                    if !row.isValid {
                        row.value = Date()
                    } else {
                        cell.detailTextLabel?.textColor = UIColor.darkGray
                    }
                }

            <<< TextRow("eventLocation") {
                $0.title = "活动地点"
                $0.placeholder = "待定"
                }
            <<< DecimalRow("expectedFee") {
                $0.title = "预计费用"
                $0.placeholder = "0.0"
                }

            <<< AlertRow<String> ("transportationMethod") {
                $0.title = "出行方式"
                $0.selectorTitle = "出行方式"
                $0.options = TransportationMethod.allRawValues
                $0.value = TransportationMethod.other.rawValue
                }
            
            +++ Section("其他需要说明的情况(选填)")
            <<< TextAreaRow("note"){ row in
                row.placeholder = "比如需不需要带现金，户外活动需要什么样的装备等等"
                }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        UIApplication.shared.statusBarStyle = .default
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    //MARK: - values for all rows
    var name: String? {
        get {
            return (form.rowBy(tag: "eventTitle") as! TextAreaRow).value
        }
        set {
            (form.rowBy(tag: "eventTitle") as! TextAreaRow).value = newValue
        }
    }

    var type: EventType {
        get {
            return EventType(rawValue: (form.rowBy(tag: "eventType") as! AlertRow).value!)!
        }
        set {
            (form.rowBy(tag: "eventType") as! AlertRow).value = newValue.rawValue
        }
    }

    var totalSeats: Double {
        get {
            return (form.rowBy(tag: "totalSeats") as! StepperRow).value!
        }
        set {
            (form.rowBy(tag: "totalSeats") as! StepperRow).value = newValue
        }
    }

    var remainingSeats: Double {
        get {
            return (form.rowBy(tag: "remainingSeats") as! StepperRow).value!
        }
        set {
            (form.rowBy(tag: "remainingSeats") as! StepperRow).value = newValue
        }
    }

    var minimumAttendingPeople: Double {
        get {
            return (form.rowBy(tag: "minimumMoreAttendingPeople") as! StepperRow).value! + totalSeats - remainingSeats
        }
        set {
            (form.rowBy(tag: "minimumMoreAttendingPeople") as! StepperRow).value = newValue + remainingSeats - totalSeats
        }
    }

    var due: Date {
        get {
            return (form.rowBy(tag: "due") as! DateTimeRow).value!
        }
        set {
            (form.rowBy(tag: "due") as! DateTimeRow).value = newValue
        }
    }

    var eventStartTime: Date {
        get {
            return (form.rowBy(tag: "eventStartTime") as! DateTimeRow).value!
        }
        set {
            (form.rowBy(tag: "eventStartTime") as! DateTimeRow).value = newValue
        }
    }

    var eventEndTime: Date {
        get {
            return (form.rowBy(tag: "eventEndTime") as! DateTimeRow).value!
        }
        set {
            (form.rowBy(tag: "eventEndTime") as! DateTimeRow).value = newValue
        }
    }

    var eventLocation: String? {
        get {
            return (form.rowBy(tag: "eventLocation") as! TextRow).value
        }
        set {
            (form.rowBy(tag: "eventLocation") as! TextRow).value = newValue
        }
    }

    var expectedFee: Double? {
        get {
            return (form.rowBy(tag: "expectedFee") as! DecimalRow).value
        }
        set {
            (form.rowBy(tag: "expectedFee") as! DecimalRow).value = newValue
        }
    }

    var transportationMethod: TransportationMethod {
        get {
            return TransportationMethod(rawValue: (form.rowBy(tag: "transportationMethod") as! AlertRow).value!)!
        }
        set {
            (form.rowBy(tag: "transportationMethod") as! AlertRow).value = newValue.rawValue
        }
    }
    
    var note: String? {
        get {
            return (form.rowBy(tag: "note") as! TextAreaRow).value
        }
        set {
            (form.rowBy(tag: "note") as! TextAreaRow).value = newValue
        }
    }

    @IBAction func close() {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func postEvent() {
        guard let name = name else { return }
        let event = Event(name: name, type: type, totalSeats: Int(totalSeats), remainingSeats: Int(remainingSeats), minimumAttendingPeople: Int(minimumAttendingPeople), due: due, creator: AVUser.current())
        if eventStartTime > Date() {
            event.startTime = eventStartTime
        }
        if eventEndTime > Date() {
            event.endTime = eventEndTime
        }
   
        event.note = note
        event.expectedFee = expectedFee
        event.transportationMethod = transportationMethod
        event.locationName = eventLocation
        event.location = AVGeoPoint(latitude: 34.0090, longitude: -118.4974)
        event.post() {
            succeeded, error in
            SVProgressHUD.dismiss()
            if succeeded {
                self.delegate?.userDidPostEvent()
                self.presentingViewController?.dismiss(animated: true, completion: nil)
            } else {
                self.cancleButton.isEnabled = true
                self.postButton.isEnabled = true
            }
        }
        cancleButton.isEnabled = false
        postButton.isEnabled = false
        SVProgressHUD.show()
    }
}
