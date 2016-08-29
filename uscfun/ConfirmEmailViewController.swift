//
//  ConfirmEmailViewController.swift
//  uscfun
//
//  Created by Wenzheng Li on 8/27/16.
//  Copyright © 2016 Wenzheng Li. All rights reserved.
//

import UIKit

class ConfirmEmailViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor.backgroundGray()
        self.navigationItem.hidesBackButton = true
        
        let delay = 4 * Double(NSEC_PER_SEC)
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        dispatch_after(time, dispatch_get_main_queue()) {
            // After 5 seconds this line will be executed
            self.performSegueWithIdentifier("from confirm to signin", sender: self)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
