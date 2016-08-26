//
//  USCFunConstants.swift
//  uscfun
//
//  Created by Wenzheng Li on 8/25/16.
//  Copyright © 2016 Wenzheng Li. All rights reserved.
//

import Foundation

extension UIColor {
    class func themeYellow() -> UIColor {
        return UIColor(red: 1.0, green: 0.988, blue: 0.0, alpha: 1.0)
    }
    
    class func themeYellow(alpha: CGFloat) -> UIColor {
        return UIColor(red: 1.0, green: 0.988, blue: 0.0, alpha: alpha)
    }
    
    class func themeUSCRed() -> UIColor {
        return UIColor(red: 153.0/255, green: 27.0/255, blue: 30.0/250, alpha: 1.0)
    }
    
    class func themeUSCRed(alpha: CGFloat) -> UIColor {
        return UIColor(red: 153.0/255, green: 27.0/255, blue: 30.0/250, alpha: alpha)
    }
}