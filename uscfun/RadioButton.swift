//
//  RadioButton.swift
//  uscfun
//
//  Created by Wenzheng Li on 9/9/16.
//  Copyright © 2016 Wenzheng Li. All rights reserved.
//

import UIKit

@IBDesignable
class RadioButton: UIButton {
    
    @IBInspectable
    var chosen = false { didSet { setNeedsDisplay() } }
    
    let RatioInnerCircleAndHeightForRadioButton = CGFloat(0.4)
    let RatioOuterCircleAndHeightForRadioButton = CGFloat(0.6)
    
    override func drawRect(rect: CGRect) {
        let color = UIColor.blackColor()
        if chosen {
            let innerFilledCircle = UIBezierPath(arcCenter: CGPoint(x: self.bounds.midX, y: self.bounds.midY), radius: self.bounds.height/2 * RatioInnerCircleAndHeightForRadioButton, startAngle: 0, endAngle: 360, clockwise: true)
            
            color.setFill()
            innerFilledCircle.fill()
        }
        
        
        let outerCircle = UIBezierPath(arcCenter: CGPoint(x: self.bounds.midX, y: self.bounds.midY), radius: self.bounds.height/2 * RatioOuterCircleAndHeightForRadioButton, startAngle: 0, endAngle: 360, clockwise: true)
        color.setStroke()
        outerCircle.lineWidth = 1
        outerCircle.stroke()
    }
}
