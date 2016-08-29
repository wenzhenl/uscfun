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

enum UIUserInterfaceIdiom : Int {
    case Unspecified
    case Phone
    case Pad
}

struct ScreenSize {
    static let SCREEN_WIDTH         = UIScreen.mainScreen().bounds.size.width
    static let SCREEN_HEIGHT        = UIScreen.mainScreen().bounds.size.height
    static let SCREEN_MAX_LENGTH    = max(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
    static let SCREEN_MIN_LENGTH    = min(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
}

struct DeviceType {
    static let IS_IPHONE_4_OR_LESS  = UIDevice.currentDevice().userInterfaceIdiom == .Phone && ScreenSize.SCREEN_MAX_LENGTH < 568.0
    static let IS_IPHONE_5          = UIDevice.currentDevice().userInterfaceIdiom == .Phone && ScreenSize.SCREEN_MAX_LENGTH == 568.0
    static let IS_IPHONE_6          = UIDevice.currentDevice().userInterfaceIdiom == .Phone && ScreenSize.SCREEN_MAX_LENGTH == 667.0
    static let IS_IPHONE_6P         = UIDevice.currentDevice().userInterfaceIdiom == .Phone && ScreenSize.SCREEN_MAX_LENGTH == 736.0
    static let IS_IPAD              = UIDevice.currentDevice().userInterfaceIdiom == .Pad && ScreenSize.SCREEN_MAX_LENGTH == 1024.0
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
    
    class func buttonPink() -> UIColor {
        return UIColor(red: 239.0/255, green: 31.0/255, blue: 85.0/250, alpha: 1.0)
    }
    
    class func buttonBlue() -> UIColor {
        return UIColor(red: 13.0/255, green: 179.0/255, blue: 224.0/250, alpha: 1.0)
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