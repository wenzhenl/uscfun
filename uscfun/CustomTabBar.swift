//
//  CustomTabBar.swift
//  uscfun
//
//  Created by Wenzheng Li on 3/3/17.
//  Copyright © 2017 Wenzheng Li. All rights reserved.
//

import UIKit

class CustomTabBar: UITabBar {
    lazy var postButton: UIButton = {
        let button = UIButton()
        button.setBackgroundImage(#imageLiteral(resourceName: "plus"), for: .normal)
        self.addSubview(button)
        return button
    }()
    
    private let buttonCount = 5
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let w = self.bounds.width / CGFloat(buttonCount)
        let h = self.bounds.height
        let margin = CGFloat(3)
        
        var index: CGFloat = 0
        for view in self.subviews {
            if view is UIControl && !(view is UIButton) {
                view.frame = CGRect(x: index * w, y: 0, width: w, height: h)
                index += (index == 1) ? 2 : 1
            }
        }
        self.postButton.frame = CGRect(x: 0, y: 0, width: h - margin * 2, height: h - margin * 2)
        self.postButton.center = CGPoint(x: self.bounds.width * 0.5, y: self.bounds.height * 0.5)
    }
}
