//
//  CustomTabBarController.swift
//  uscfun
//
//  Created by Wenzheng Li on 2/27/17.
//  Copyright © 2017 Wenzheng Li. All rights reserved.
//

import UIKit

class CustomTabBarController: UITabBarController {
    
    @IBOutlet weak var customTabBar: CustomTabBar!
    var lastSelectedTag = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        customTabBar.postButton.addTarget(self, action: #selector(startEvent), for: .touchUpInside)
        
        var i = 0
        for item in customTabBar.items! {
            item.tag = i
            i += 1
        }
    }
    
    func startEvent() {
        performSegue(withIdentifier: "BeginStartingANewEvent", sender: self)
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if item.tag == lastSelectedTag {
            switch item.tag {
            case 0:
                print("notification home")
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "homeRefresh"), object: nil, userInfo: nil)
            case 1:
                print("notification find")
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "findRefresh"), object: nil, userInfo: nil)
            case 2:
                print("notification notification")
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "notificationRefresh"), object: nil, userInfo: nil)
            default:
                break
            }
        }
        lastSelectedTag = item.tag
    }
}

extension UIViewController {
    var contentViewController: UIViewController {
        if let navcon = self as? UINavigationController {
            return navcon.visibleViewController!
        } else {
            return self
        }
    }
}
