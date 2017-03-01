//
//  NewEventDueViewController.swift
//  uscfun
//
//  Created by Wenzheng Li on 2/27/17.
//  Copyright © 2017 Wenzheng Li. All rights reserved.
//

import UIKit

class NewEventDueViewController: UIViewController {

    
    @IBOutlet weak var nextBarButton: UIBarButtonItem!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    var eventDue: Date {
        get {
            return datePicker.date
        }
        set {
            datePicker.setDate(newValue, animated: true)
            nextBarButton.isEnabled = newValue > Date(timeIntervalSinceNow: 0)
            UserDefaults.newEventDue = newValue
            let fullTime = newValue.fullStyle
            print(fullTime)
            
            if NSLocale.preferredLanguages.first == "zh-Hans-US" {
                let dateAndTime = fullTime.components(separatedBy: " ")
                dateLabel.text = dateAndTime[0] + " " + dateAndTime[1]
                timeLabel.text = dateAndTime[2]
            }
            else if NSLocale.preferredLanguages.first == "en-US" {
                let dateAndTime = fullTime.components(separatedBy: " at ")
                let date = dateAndTime.first!
                let deleteYear = date.components(separatedBy: ", ")
                dateLabel.text = deleteYear.first! + ", " + deleteYear[1]
                let time = dateAndTime.last
                timeLabel.text = time
            } else {
                
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = ""
        eventDue = UserDefaults.newEventDue > Date(timeIntervalSinceNow: 0) ? UserDefaults.newEventDue : Date(timeIntervalSinceNow: 0)
        datePicker.addTarget(self, action: #selector(handleDatePicker(_:)), for: .valueChanged)
    }
    
    @IBAction func goNext(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "GoNewEventNumberOfPeople", sender: self)
    }
    
    @IBAction func handleDatePicker(_ sender: UIDatePicker) {
        eventDue = sender.date
    }
}
