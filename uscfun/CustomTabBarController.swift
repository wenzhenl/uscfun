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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        customTabBar.postButton.addTarget(self, action: #selector(startEvent), for: .touchUpInside)
    }
    
    func startEvent() {
        performSegue(withIdentifier: "BeginStartingANewEvent", sender: self)
    }
}
