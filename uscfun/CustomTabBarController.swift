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
        
        print("custom tab bar controller view did load")
        
        customTabBar.postButton.addTarget(self, action: #selector(startEvent), for: .touchUpInside)
        
        var i = 0
        for item in customTabBar.items! {
            item.tag = i
            i += 1
        }
        
        for vc in self.viewControllers! {
            if let vc = vc as? UINavigationController {
                _ = vc.visibleViewController?.view
            }
        }
        self.selectedIndex = USCFunConstants.indexOfEventList
        
        NotificationCenter.default.addObserver(self, selector: #selector(finishedCleanEvents), name: NSNotification.Name(rawValue: "finishedCleanEvents"), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func startEvent() {
        performSegue(withIdentifier: "BeginStartingANewEvent", sender: self)
    }
    
    func finishedCleanEvents() {
        let appDelegate = UIApplication.shared.delegate! as! AppDelegate
        appDelegate.window?.rootViewController = self
        appDelegate.window?.makeKeyAndVisible()
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "tabBarItemSelected"), object: nil, userInfo: nil)
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
