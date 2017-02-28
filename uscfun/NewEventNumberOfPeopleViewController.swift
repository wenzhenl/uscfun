//
//  NewEventNumberOfPeopleViewController.swift
//  uscfun
//
//  Created by Wenzheng Li on 2/27/17.
//  Copyright © 2017 Wenzheng Li. All rights reserved.
//

import UIKit

class NewEventNumberOfPeopleViewController: UIViewController {

    @IBOutlet weak var maxLabel: UILabel!
    @IBOutlet weak var minLabel: UILabel!
    @IBOutlet weak var maxStepper: UIStepper!
    @IBOutlet weak var minStepper: UIStepper!
    @IBOutlet weak var nextBarButton: UIBarButtonItem!
    
    var maxPeople: Int {
        get {
            return Int(maxStepper.value)
        }
        set {
            maxStepper.value = Double(newValue)
            maxLabel.text = String(newValue) + "人"
            UserDefaults.newEventMaxPeople = newValue
            nextBarButton.isEnabled = newValue > 1 && minPeople > 1 && newValue >= minPeople
        }
    }
    
    var minPeople: Int {
        get {
           return Int(minStepper.value)
        }
        set {
            minStepper.value = Double(newValue)
            minLabel.text = String(newValue) + "人"
            UserDefaults.newEventMinPeople = newValue
            nextBarButton.isEnabled = maxPeople > 1 && newValue > 1 && maxPeople >= newValue
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = ""
        maxStepper.isContinuous = false
        minStepper.isContinuous = false
        maxPeople = UserDefaults.newEventMaxPeople
        minPeople = UserDefaults.newEventMinPeople
    }
    
    @IBAction func maxValChanged(_ sender: UIStepper) {
        maxPeople = Int(sender.value)
    }
    
    @IBAction func minValChanged(_ sender: UIStepper) {
        minPeople = Int(sender.value)
    }
    
    @IBAction func goNext(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "GoNewEventNumberReserved", sender: self)
    }
}
