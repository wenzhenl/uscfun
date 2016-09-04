//
//  EventHangingView.swift
//  uscfun
//
//  Created by Wenzheng Li on 9/3/16.
//  Copyright © 2016 Wenzheng Li. All rights reserved.
//

import UIKit

class EventHangingView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clearColor()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func drawRect(rect: CGRect) {
        let path = UIBezierPath()
        UIColor.lightGrayColor().set()
        path.lineWidth = 2
        let topLeft = CGPoint(x: self.bounds.minX, y: self.bounds.minY)
        let topRight = CGPoint(x: self.bounds.maxX, y: self.bounds.minY)
        let top_1_of_4 = CGPoint(x: self.bounds.minX + self.bounds.size.width / 4.0, y: self.bounds.minY)
        let top_3_of_4 = CGPoint(x: self.bounds.minX + self.bounds.size.width / 4.0 * 3.0, y: self.bounds.minY)
        let btm_1_of_4 = CGPoint(x: self.bounds.minX + self.bounds.size.width / 4.0, y: self.bounds.maxY)
        let btm_3_of_4 = CGPoint(x: self.bounds.minX + self.bounds.size.width / 4.0 * 3.0, y: self.bounds.maxY)
        path.moveToPoint(topLeft)
        path.addLineToPoint(topRight)
        path.moveToPoint(top_1_of_4)
        path.addLineToPoint(btm_1_of_4)
        path.moveToPoint(top_3_of_4)
        path.addLineToPoint(btm_3_of_4)
        path.stroke()
    }
}
