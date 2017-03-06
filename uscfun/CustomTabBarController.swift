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
    var lastSelectedIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        customTabBar.postButton.addTarget(self, action: #selector(startEvent), for: .touchUpInside)
    }
    
    func startEvent() {
        performSegue(withIdentifier: "BeginStartingANewEvent", sender: self)
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if selectedIndex == lastSelectedIndex {
            switch selectedIndex {
            case 0:
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "homeRefresh"), object: nil, userInfo: nil)
            case 1:
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "findRefresh"), object: nil, userInfo: nil)
            case 2:
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "notificationRefresh"), object: nil, userInfo: nil)
            default:
                break
            }
        }
        lastSelectedIndex = selectedIndex
    }
}
