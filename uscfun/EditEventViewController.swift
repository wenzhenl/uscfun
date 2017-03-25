//
//  EditEventViewController.swift
//  uscfun
//
//  Created by Wenzheng Li on 3/6/17.
//  Copyright © 2017 Wenzheng Li. All rights reserved.
//

import UIKit
import Eureka
import SVProgressHUD

protocol EditEventViewControllerDelegate {
    func userDidUpdatedEvent(event: Event)
}

class EditEventViewController: FormViewController {

    @IBOutlet weak var saveButtonItem: UIBarButtonItem!
    
    var event: Event!
    var delegate: EditEventViewControllerDelegate?
    
    var errorLabel: UILabel!
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.errorLabel.isHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "修改微活动"
        
        if let navigationBar = self.navigationController?.navigationBar {
            errorLabel = UILabel(frame: CGRect(x: navigationBar.frame.width/4, y: 0, width: navigationBar.frame.width/2, height: navigationBar.frame.height))
            errorLabel.textAlignment = .center
            errorLabel.textColor = UIColor.red
            errorLabel.font = UIFont.systemFont(ofSize: 13)
            errorLabel.numberOfLines = 0
            navigationBar.addSubview(errorLabel)
            errorLabel.isHidden = true
        }
        
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
                if row.value! > self.event.due {
                    self.saveButtonItem.isEnabled = true
                }
                self.errorLabel.isHidden = true
                self.title = "修改微活动"
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
                
                if row.value! > Double(self.event.maximumAttendingPeople) {
                    self.saveButtonItem.isEnabled = true
                }
                self.errorLabel.isHidden = true
                self.title = "修改微活动"
            }
            
            +++ Section("减少最低成行人数") {
                $0.hidden = Condition.function(["hideMinPeople"]) {
                    _ in
                    return self.event.minimumAttendingPeople == 2
                }
            }
            <<< StepperRow("minPeople") {
                $0.title = "最低成行人数："
                $0.value = Double(event.minimumAttendingPeople)
                $0.add(rule: RuleSmallerOrEqualThan(max: Double(event.minimumAttendingPeople)))
                $0.add(rule: RuleGreaterOrEqualThan(min: 2.0))
                $0.validationOptions = .validatesOnChange
                }.cellSetup {
                    cell, row in
                    cell.stepper.isContinuous = false
                    cell.valueLabel.text = String(Int(row.value!))
                }.cellUpdate {
                    cell, row in
                    if !row.isValid {
                        if row.value! < 2.0 {
                            row.value = 2.0
                        }
                        if row.value! > Double(self.event.minimumAttendingPeople) {
                            row.value = Double(self.event.minimumAttendingPeople)
                        }
                    }
                    cell.valueLabel.text = String(Int(row.value!))
                    
                    if row.value! < Double(self.event.minimumAttendingPeople) {
                        self.saveButtonItem.isEnabled = true
                    }
                    self.errorLabel.isHidden = true
                    self.title = "修改微活动"
            }
            
            +++ Section("更新时间地点")
            <<< DateTimeRow("eventStartTime"){
                $0.title = "微活动开始时间："
                if event.startTime != nil {
                    $0.value = event.startTime!
                }
                }.cellUpdate {
                    cell, row in
                    if row.value != self.event.startTime {
                        self.saveButtonItem.isEnabled = true
                    }
                    self.errorLabel.isHidden = true
                    self.title = "修改微活动"
            }
            
            <<< DateTimeRow("eventEndTime"){
                $0.title = "微活动结束时间："
                if event.endTime != nil {
                    $0.value = event.endTime!
                }
                }.cellUpdate {
                    cell, row in
                    if row.value != self.event.endTime {
                        self.saveButtonItem.isEnabled = true
                    }
                    self.errorLabel.isHidden = true
                    self.title = "修改微活动"
            }
            
            <<< LocationAddressRow("eventLocation") {
                $0.title = "微活动地点："
                if event.location != nil {
                    $0.value = event.location!
                }
                
                if event.whereCreated != nil {
                    $0.latitude = event.whereCreated!.latitude
                    $0.longitude = event.whereCreated!.longitude
                }
                }.cellUpdate {
                    cell, row in
                    if row.value != self.event.location || row.latitude != self.event.whereCreated?.latitude || row.longitude != self.event.whereCreated?.longitude {
                        self.saveButtonItem.isEnabled = true
                    }
                    self.errorLabel.isHidden = true
                    self.title = "修改微活动"
            }

            +++ Section("更新补充说明")
            <<< TextAreaRow("note"){ row in
                row.placeholder = "比如预计费用，出行方式，是否需要带现金等等"
                row.value = event.note
                }.cellUpdate {
                    cell, row in
                    if row.value != self.event.note {
                        self.saveButtonItem.isEnabled = true
                    }
                    self.errorLabel.isHidden = true
                    self.title = "修改微活动"
            }
        
            +++ Section() {
                $0.hidden = Condition.function(["hideDelete"]) {
                    _ in
                    return self.event.members.count > 1
                }
            }
            <<< ButtonRow("delete") {
                $0.title = "删除微活动"
                }.cellSetup {
                    cell, row in
                    cell.tintColor = UIColor.red
                }
                .onCellSelection {
                    [weak self] (cell, row) in
                    self?.showAlert()
            }
    }

    func showAlert() {
        let alertController = UIAlertController(title: "确定要删除微活动么? 只有还没有人报名的微活动可以删除", message: nil, preferredStyle: .actionSheet)
        let okay = UIAlertAction(title: "确定删除", style: .destructive) {
            _ in
            SVProgressHUD.show()
            self.event.cancel {
                succeeded, error in
                SVProgressHUD.dismiss()
                if succeeded {
                    print("delete successfully")
                    EventRequest.removeMyOngoingEvent(with: self.event.objectId!) {
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "userDidCancelEvent"), object: nil, userInfo: ["eventId": self.event.objectId!])

                        self.presentingViewController?.dismiss(animated: true, completion: nil)
                    }
                }
                
                if error != nil {
                    self.errorLabel.text = error!.localizedDescription
                    self.title = ""
                    self.errorLabel.isHidden = false
                    print(error!.localizedDescription)
                }
            }
        }
        let cancel = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        alertController.addAction(okay)
        alertController.addAction(cancel)
        present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }

    @IBAction func save(_ sender: UIBarButtonItem) {
        let newDue = (form.rowBy(tag: "due") as! DateTimeRow).value!
        let newMaximumAttendingPeople = Int((form.rowBy(tag: "maxPeople") as! StepperRow).value!)
        let newMinimumAttendingPeople = Int((form.rowBy(tag: "minPeople") as! StepperRow).value!)
        let newStartTime = (form.rowBy(tag: "eventStartTime") as! DateTimeRow).value
        let newEndTime = (form.rowBy(tag: "eventEndTime") as! DateTimeRow).value
        let newLocation = (form.rowBy(tag: "eventLocation") as! LocationAddressRow).value
        let latitude = (form.rowBy(tag: "eventLocation") as! LocationAddressRow).latitude
        let longitude = (form.rowBy(tag: "eventLocation") as! LocationAddressRow).longitude
        let newWhereCreated = latitude != nil && longitude != nil ? AVGeoPoint(latitude: latitude!, longitude: longitude!) : nil
        let newNote = (form.rowBy(tag: "note") as! TextAreaRow).value
        
        SVProgressHUD.show()
        self.saveButtonItem.isEnabled = false
        
        event.update(newDue: newDue, newMaximumAttendingPeople: newMaximumAttendingPeople, newMinimumAttendingPeople: newMinimumAttendingPeople, newStartTime: newStartTime, newEndTime: newEndTime, newLocation: newLocation, newWhereCreated: newWhereCreated, newNote: newNote) {
            succeeded, error in
            SVProgressHUD.dismiss()
            if succeeded {
                delegate?.userDidUpdatedEvent(event: event)
                EventRequest.setMyOngoingEvent(event: event, for: event.objectId!) {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "userDidUpdateEvent"), object: nil, userInfo: nil)
                    self.presentingViewController?.dismiss(animated: true, completion: nil)
                }
            }
            else if error != nil {
                self.saveButtonItem.isEnabled = true
                self.errorLabel.text = error!.localizedDescription
                self.title = ""
                self.errorLabel.isHidden = false
                print(error!.localizedDescription)
            }
        }
    }
}
