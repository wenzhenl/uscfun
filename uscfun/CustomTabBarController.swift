//
//  CustomTabBarController.swift
//  uscfun
//
//  Created by Wenzheng Li on 2/27/17.
//  Copyright © 2017 Wenzheng Li. All rights reserved.
//

import UIKit

class CustomTabBarController: UITabBarController {
    var postButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let windowHeight = self.view.frame.height
        let barHeight = self.tabBar.frame.height
        let gridWidth = self.view.frame.width / 5
        let margin = CGFloat(3)
        let buttonWidth = barHeight - margin * 2
        let buttonHeight = barHeight - margin * 2
        
        let modalView = UIView(frame: CGRect(x: gridWidth * 2, y: windowHeight - barHeight, width: gridWidth, height: barHeight))
        self.view.addSubview(modalView)
        
        postButton = UIButton(frame: CGRect(x: gridWidth * 2 + (gridWidth - buttonWidth) / 2, y: windowHeight - barHeight + margin, width: buttonWidth, height: buttonHeight))
        postButton.setBackgroundImage(#imageLiteral(resourceName: "plus"), for: .normal)
        self.view.addSubview(postButton)
        
        postButton.addTarget(self, action: #selector(startEvent), for: .touchUpInside)
    }
    
    func startEvent() {
        performSegue(withIdentifier: "BeginStartingANewEvent", sender: self)
    }
}
