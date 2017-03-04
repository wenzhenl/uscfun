//
//  NewEventNumberReservedViewController.swift
//  uscfun
//
//  Created by Wenzheng Li on 2/27/17.
//  Copyright © 2017 Wenzheng Li. All rights reserved.
//

import UIKit

class NewEventNumberReservedViewController: UIViewController {

    @IBOutlet weak var nextBarButton: UIBarButtonItem!
    @IBOutlet weak var stepper: UIStepper!
    @IBOutlet weak var reservedLabel: UILabel!
    
    var numberReserved: Int {
        get {
            return Int(stepper.value)
        }
        set {
            stepper.value = Double(newValue)
            reservedLabel.text = String(newValue) + "人"
            UserDefaults.newEventNumReserved = newValue
        }
    }
    
    var errorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = ""
        numberReserved = UserDefaults.newEventNumReserved > 0 ? UserDefaults.newEventNumReserved : 1
        stepper.minimumValue = 1
        stepper.isContinuous = false
        
        if let navigationBar = self.navigationController?.navigationBar {
            errorLabel = UILabel(frame: CGRect(x: navigationBar.frame.width/4, y: 0, width: navigationBar.frame.width/2, height: navigationBar.frame.height))
            errorLabel.textAlignment = .center
            errorLabel.textColor = UIColor.red
            errorLabel.font = UIFont.systemFont(ofSize: 13)
            errorLabel.numberOfLines = 0
            navigationBar.addSubview(errorLabel)
            errorLabel.isHidden = true
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        errorLabel.isHidden = true
    }
    
    @IBAction func numReservedChanged(_ sender: UIStepper) {
        errorLabel.isHidden = true
        numberReserved = Int(sender.value)
    }
    
    @IBAction func goNext(_ sender: UIBarButtonItem) {
        if numberReserved < UserDefaults.newEventMaxPeople {
            performSegue(withIdentifier: "GoNewEventOptionals", sender: self)
        } else {
            errorLabel.text = "预留人数必须小于最多容纳人数"
            errorLabel.isHidden = false
        }
    }
}
