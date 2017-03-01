//
//  NewEventOptionalsViewController.swift
//  uscfun
//
//  Created by Wenzheng Li on 2/27/17.
//  Copyright © 2017 Wenzheng Li. All rights reserved.
//

import UIKit
import AVOSCloud
import SVProgressHUD
import Eureka

class NewEventOptionalsViewController: FormViewController {
    
    @IBOutlet weak var postButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = ""
        
        form +++ Section("时间地点(选填)")
        <<< DateTimeRow("eventStartTime"){
            $0.title = "开始时间"
            $0.value = Date()
            }
            .cellSetup {
                cell, row in
                cell.textLabel?.textColor = UIColor.darkGray
            }
            
        <<< DateTimeRow("eventEndTime"){
            $0.title = "结束时间"
            $0.value = Date()
            }
            .cellSetup {
                cell, row in
                cell.textLabel?.textColor = UIColor.darkGray
            }
            
        <<< LocationAddressRow("eventLocation") {
            $0.title = "活动地点"
            }
        +++ Section("补充说明(选填)")
        <<< TextAreaRow("note"){ row in
            row.placeholder = "比如预计费用，出行方式，是否需要带现金等等"
            }
    }

    func clearNewEventUserDefaults() {
        UserDefaults.newEventName = nil
        UserDefaults.newEventDue = Date(timeIntervalSince1970: 0)
        UserDefaults.newEventMaxPeople = 0
        UserDefaults.newEventMinPeople = 0
        UserDefaults.newEventNumReserved = 0
        UserDefaults.newEventStartTime = Date(timeIntervalSince1970: 0)
        UserDefaults.newEventEndTime = Date(timeIntervalSince1970: 0)
        UserDefaults.newEventNote = nil
    }
    
    @IBAction func post(_ sender: UIBarButtonItem) {
        let event = Event(name: UserDefaults.newEventName!, type: EventType.foodAndDrink, totalSeats: UserDefaults.newEventMaxPeople, remainingSeats: UserDefaults.newEventMaxPeople - UserDefaults.newEventNumReserved, minimumAttendingPeople: UserDefaults.newEventMinPeople, due: UserDefaults.newEventDue, creator: AVUser.current())
        event.post() {
            succeeded, error in
            SVProgressHUD.dismiss()
            if succeeded {
                self.clearNewEventUserDefaults()
                self.presentingViewController?.dismiss(animated: true, completion: nil)
            } else {
                self.postButton.isEnabled = true
            }
        }
        postButton.isEnabled = false
        SVProgressHUD.show()
    }
}
