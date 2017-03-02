//
//  NewEventOptionalsViewController.swift
//  uscfun
//
//  Created by Wenzheng Li on 2/27/17.
//  Copyright © 2017 Wenzheng Li. All rights reserved.
//

import UIKit
import Eureka

class NewEventOptionalsViewController: FormViewController {
    
    @IBOutlet weak var postButton: UIBarButtonItem!

    var eventStartTime: Date {
        get {
            return (form.rowBy(tag: "eventStartTime") as! DateTimeRow).value!
        }
        set {
            (form.rowBy(tag: "eventStartTime") as! DateTimeRow).value = newValue
            UserDefaults.newEventStartTime = eventStartTime
        }
    }
    
    var eventEndTime: Date {
        get {
            return (form.rowBy(tag: "eventEndTime") as! DateTimeRow).value!
        }
        set {
            (form.rowBy(tag: "eventEndTime") as! DateTimeRow).value = newValue
            UserDefaults.newEventEndTime = eventEndTime
        }
    }
    
    var eventLocation: String? {
        get {
            return (form.rowBy(tag: "eventLocation") as! LocationAddressRow).value
        }
        set {
            (form.rowBy(tag: "eventLocation") as! LocationAddressRow).value = newValue
            UserDefaults.newEventLocationName = newValue
        }
    }
    
    var eventCoordinate: AVGeoPoint? {
        get {
            guard let latitude = (form.rowBy(tag: "eventLocation") as! LocationAddressRow).latitude else { return nil }
            guard let longitude = (form.rowBy(tag: "eventLocation") as! LocationAddressRow).longitude else { return nil }
            return AVGeoPoint(latitude: latitude, longitude: longitude)
        }
        set {
            UserDefaults.newEventLocationLatitude = newValue?.latitude ?? 0
            UserDefaults.newEventLocationLongitude = newValue?.longitude ?? 0
            (form.rowBy(tag: "eventLocation") as! LocationAddressRow).latitude = newValue?.latitude
            (form.rowBy(tag: "eventLocation") as! LocationAddressRow).longitude = newValue?.longitude
        }
    }
    
    var note: String? {
        get {
            return (form.rowBy(tag: "note") as! TextAreaRow).value
        }
        set {
            (form.rowBy(tag: "note") as! TextAreaRow).value = newValue
            UserDefaults.newEventNote = newValue
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = ""
        
        form +++ Section("时间地点(选填)")
        <<< DateTimeRow("eventStartTime"){
            $0.title = "开始时间"
            }
            .cellSetup {
                cell, row in
                cell.textLabel?.text = "待定"
            }
            .cellUpdate {
                cell, row in
                self.eventStartTime = row.value ?? Date()
            }
            
        <<< DateTimeRow("eventEndTime"){
            $0.title = "结束时间"
            }
            .cellSetup {
                cell, row in
                cell.textLabel?.text = "待定"
            }
            .cellUpdate {
                cell, row in
                self.eventEndTime = row.value ?? Date()
            }
            
        <<< LocationAddressRow("eventLocation") {
            $0.title = "活动地点"
            }
            .cellSetup {
                cell, row in
                cell.textLabel?.text = "待定"
            }
            .cellUpdate {
                cell, row in
                self.eventLocation = row.value
                self.eventCoordinate = AVGeoPoint(latitude: row.latitude ?? 0, longitude: row.longitude ?? 0)
            }
            
        +++ Section("补充说明(选填)")
        <<< TextAreaRow("note"){ row in
            row.placeholder = "比如预计费用，出行方式，是否需要带现金等等"
            }
            .cellUpdate {
                cell, row in
                self.note = row.value
            }
        
        if UserDefaults.newEventStartTime > Date() {
            eventStartTime = UserDefaults.newEventStartTime
            if UserDefaults.newEventEndTime > UserDefaults.newEventStartTime {
                eventEndTime = UserDefaults.newEventEndTime
            }
        }
        
        eventLocation = UserDefaults.newEventLocationName
        
        if eventLocation != nil && (UserDefaults.newEventLocationLongitude != 0 || UserDefaults.newEventLocationLatitude != 0) {
            eventCoordinate = AVGeoPoint(latitude: UserDefaults.newEventLocationLatitude, longitude: UserDefaults.newEventLocationLongitude)
        }
        note = UserDefaults.newEventNote
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.navigationBar.isTranslucent = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        self.navigationController?.navigationBar.isTranslucent = true
    }
}
