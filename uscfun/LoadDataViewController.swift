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
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "finishedCleanEvents"), object: nil, userInfo: nil)
            print("clean public events ends")

//            let appDelegate = UIApplication.shared.delegate! as! AppDelegate
//            let storyboard = UIStoryboard(name: "Main", bundle: nil)
//            let initialViewController = storyboard.instantiateInitialViewController()
//            appDelegate.window?.rootViewController = initialViewController
//            appDelegate.window?.makeKeyAndVisible()
        }
    }
}
