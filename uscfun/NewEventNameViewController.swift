//
//  NewEventNameViewController.swift
//  uscfun
//
//  Created by Wenzheng Li on 2/27/17.
//  Copyright © 2017 Wenzheng Li. All rights reserved.
//

import UIKit

class NewEventNameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = ""

    }
    
    @IBAction func close() {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
}
