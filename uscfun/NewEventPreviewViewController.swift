//
//  NewEventPreviewViewController.swift
//  uscfun
//
//  Created by Wenzheng Li on 3/1/17.
//  Copyright © 2017 Wenzheng Li. All rights reserved.
//

import UIKit
import AVOSCloud
import SVProgressHUD

class NewEventPreviewViewController: UIViewController {

    @IBOutlet weak var postButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func clearNewEventUserDefaults() {
        UserDefaults.newEventName = nil
        UserDefaults.newEventDue = Date(timeIntervalSince1970: 0)
        UserDefaults.newEventMaxPeople = 0
        UserDefaults.newEventMinPeople = 0
        UserDefaults.newEventNumReserved = 0
        UserDefaults.newEventStartTime = Date(timeIntervalSince1970: 0)
        UserDefaults.newEventEndTime = Date(timeIntervalSince1970: 0)
        UserDefaults.newEventLocationName = nil
        UserDefaults.newEventLocationLatitude = 0
        UserDefaults.newEventLocationLongitude = 0
        UserDefaults.newEventNote = nil
    }
    
    @IBAction func post(_ sender: UIBarButtonItem) {
        
        let event = Event(name: UserDefaults.newEventName!, type: EventType.foodAndDrink, totalSeats: UserDefaults.newEventMaxPeople, remainingSeats: UserDefaults.newEventMaxPeople - UserDefaults.newEventNumReserved, minimumAttendingPeople: UserDefaults.newEventMinPeople, due: UserDefaults.newEventDue, creator: AVUser.current())
        
        if UserDefaults.newEventStartTime > Date() {
            event.startTime = UserDefaults.newEventStartTime
        }
        
        if UserDefaults.newEventEndTime > Date() && UserDefaults.newEventEndTime > UserDefaults.newEventStartTime {
            event.endTime = UserDefaults.newEventEndTime
        }
        
        event.locationName = UserDefaults.newEventLocationName
        
        if UserDefaults.newEventLocationLatitude != 0 || UserDefaults.newEventLocationLongitude != 0 {
            event.location = AVGeoPoint(latitude: UserDefaults.newEventLocationLatitude, longitude: UserDefaults.newEventLocationLongitude)
        }
        
        event.note = UserDefaults.newEventNote
        
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
