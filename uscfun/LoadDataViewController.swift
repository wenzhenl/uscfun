//
//  LoadDataViewController.swift
//  uscfun
//
//  Created by Wenzheng Li on 4/7/17.
//  Copyright © 2017 Wenzheng Li. All rights reserved.
//

import UIKit

class LoadDataViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("clean public events starts")
        EventRequest.cleanEventsInBackground(for: .mypublic) {
            UserDefaults.lastPublicEventsCleanedAt = Date()
            let appDelegate = UIApplication.shared.delegate! as! AppDelegate
            let initialVC = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()
            appDelegate.window?.rootViewController = initialVC
            appDelegate.window?.makeKeyAndVisible()
            print("clean public events ends")
        }
    }
}
