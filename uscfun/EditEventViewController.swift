//
//  EditEventViewController.swift
//  uscfun
//
//  Created by Wenzheng Li on 3/6/17.
//  Copyright © 2017 Wenzheng Li. All rights reserved.
//

import UIKit
import Eureka

class EditEventViewController: FormViewController {

    @IBOutlet weak var saveButtonItem: UIBarButtonItem!
    
    var event: Event!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "修改微活动"
        
        saveButtonItem.isEnabled = false
        
        form +++ Section("延长报名截止时间")
            <<< DateTimeRow("due"){
                $0.title = "报名截止时间："
                $0.value = event.due
                $0.add(rule: RuleGreaterOrEqualThan(min: event.due))
                $0.validationOptions = .validatesOnChange
            }.cellUpdate {
                cell, row in
                if !row.isValid {
                    row.value = self.event.due
                }
            }
            
            +++ Section("增加最多容纳人数")
            <<< StepperRow("maxPeople") {
                $0.title = "最多容纳人数："
                $0.value = Double(event.maximumAttendingPeople)
                $0.add(rule: RuleGreaterOrEqualThan(min: Double(event.maximumAttendingPeople)))
                $0.validationOptions = .validatesOnChange
            }.cellSetup {
                cell, row in
                cell.stepper.isContinuous = false
                cell.valueLabel.text = String(Int(row.value!))
            }.cellUpdate {
                cell, row in
                if !row.isValid {
                    row.value = Double(self.event.maximumAttendingPeople)
                }
                cell.valueLabel.text = String(Int(row.value!))
            }
            
        form +++ Section("更新时间地点")
            <<< DateTimeRow("eventStartTime"){
                $0.title = "微活动开始时间："
                if event.startTime != nil {
                    $0.value = event.startTime!
                }
            }
            
            <<< DateTimeRow("eventEndTime"){
                $0.title = "微活动结束时间："
                if event.endTime != nil {
                    $0.value = event.endTime!
                }
            }
            
            <<< LocationAddressRow("eventLocation") {
                $0.title = "微活动地点："
                if event.location != nil {
                    $0.value = event.location!
                }
            }

            +++ Section("更新补充说明")
            <<< TextAreaRow("note"){ row in
                row.placeholder = "比如预计费用，出行方式，是否需要带现金等等"
                row.value = event.note
            }
    }

    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }

    @IBAction func save(_ sender: UIBarButtonItem) {
        let newDue = (form.rowBy(tag: "due") as! DateTimeRow).value!
        let newMaximumAttendingPeople = Int((form.rowBy(tag: "maxPeople") as! StepperRow).value!)
        let newStartTime = (form.rowBy(tag: "eventStartTime") as! DateTimeRow).value
        let newEndTime = (form.rowBy(tag: "eventEndTime") as! DateTimeRow).value
        let newLocation = (form.rowBy(tag: "eventLocation") as! LocationAddressRow).value
        let latitude = (form.rowBy(tag: "eventLocation") as! LocationAddressRow).latitude
        let longitude = (form.rowBy(tag: "eventLocation") as! LocationAddressRow).longitude
        let newWhereCreated = latitude != nil && longitude != nil ? AVGeoPoint(latitude: latitude!, longitude: longitude!) : nil
        let newNote = (form.rowBy(tag: "note") as! TextAreaRow).value
        
        event.update(newDue: newDue, newMaximumAttendingPeople: newMaximumAttendingPeople, newStartTime: newStartTime, newEndTime: newEndTime, newLocation: newLocation, newWhereCreated: newWhereCreated, newNote: newNote) {
            succeeded, error in
            
        }
    }
}
