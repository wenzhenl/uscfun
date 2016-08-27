//
//  USCFunConstants.swift
//  uscfun
//
//  Created by Wenzheng Li on 8/25/16.
//  Copyright © 2016 Wenzheng Li. All rights reserved.
//

import Foundation

class USCFunConstants {
    static let minimumPasswordLength = 5
}

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
    
    class func backgroundGray() -> UIColor {
        let grayLevel = CGFloat(240.0)
        return UIColor(red: grayLevel/255, green: grayLevel/255, blue: grayLevel/250, alpha: 1.0)
    }
}

extension String {
    func isValidEmail() -> Bool {
        
        let emailRegEx = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluateWithObject(self)
    }
    
    func isEmpty() -> Bool {
        let patternForEmptyString = "^\\s*$"
        if self.rangeOfString(patternForEmptyString, options: .RegularExpressionSearch) != nil {
            return true
        }
        return false
    }
    
    func emailPrefix() -> String? {
        let delimiter = "@"
        let token = self.componentsSeparatedByString(delimiter)
        if token.count > 1 {
            return token[0]
        } else {
            return nil
        }
    }
}