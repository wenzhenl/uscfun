//
//  USCFunConstants.swift
//  uscfun
//
//  Created by Wenzheng Li on 8/25/16.
//  Copyright © 2016 Wenzheng Li. All rights reserved.
//

import Foundation
import UIKit

class USCFunConstants {
    static let minimumPasswordLength = 5
    
    static var password: String?

    static func signUp(handler: (_ succeed: Bool, _ error: NSError?) -> Void) {
        
        // save user info in server
        let user: AVUser = AVUser()
        user.username = UserDefaults.email
        user.password = USCFunConstants.password
        user.email = UserDefaults.email
        user.setObject(UserDefaults.nickname, forKey: keyOfNickname)
        user.setObject("usc", forKey: keyOfSchool)
        var error: NSError?
        if user.signUp(&error) {
            handler(true, nil)
        } else {
            handler(false, error)
        }
    }
    
    static func signIn(email: String, password: String, handler: @escaping (_ succeed: Bool, _ error: Error?) -> Void) {
        
        AVUser.logInWithUsername(inBackground: email, password: password) {
            updatedUser, error in
            if updatedUser != nil {
                UserDefaults.hasLoggedIn = true
                if let allkeys = updatedUser!.allKeys() as? [String] {
                    if allkeys.contains(keyOfNickname) {
                        if let nickname = updatedUser?.value(forKey: keyOfNickname) as? String {
                            UserDefaults.nickname = nickname
                        }
                    }
                }
                handler(true, nil)
            } else {
                handler(false, error)
            }
        }
    }
    
    static let keyOfNickname = "nickname"
    static let keyOfSchool = "school"
}

enum UIUserInterfaceIdiom : Int {
    case unspecified
    case phone
    case pad
}

struct ScreenSize {
    static let SCREEN_WIDTH         = UIScreen.main.bounds.size.width
    static let SCREEN_HEIGHT        = UIScreen.main.bounds.size.height
    static let SCREEN_MAX_LENGTH    = max(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
    static let SCREEN_MIN_LENGTH    = min(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
}

struct DeviceType {
    static let IS_IPHONE_4_OR_LESS  = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH < 568.0
    static let IS_IPHONE_5          = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 568.0
    static let IS_IPHONE_6          = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 667.0
    static let IS_IPHONE_6P         = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 736.0
    static let IS_IPAD              = UIDevice.current.userInterfaceIdiom == .pad && ScreenSize.SCREEN_MAX_LENGTH == 1024.0
}

extension UIColor {
    class var themeYellow: UIColor {
        return UIColor(red: 1.0, green: 0.988, blue: 0.0, alpha: 1.0)
    }
    
    class func themeYellow(_ alpha: CGFloat) -> UIColor {
        return UIColor(red: 1.0, green: 0.988, blue: 0.0, alpha: alpha)
    }
    
    class var themeUSCRed: UIColor {
        return UIColor(red: 153.0/255, green: 27.0/255, blue: 30.0/250, alpha: 1.0)
    }
    
    class func themeUSCRed(_ alpha: CGFloat) -> UIColor {
        return UIColor(red: 153.0/255, green: 27.0/255, blue: 30.0/250, alpha: alpha)
    }
    
    class var backgroundGray: UIColor {
        let grayLevel = CGFloat(240.0)
        return UIColor(red: grayLevel/255, green: grayLevel/255, blue: grayLevel/250, alpha: 1.0)
    }
    
    class var buttonPink: UIColor {
        return UIColor(red: 239.0/255, green: 31.0/255, blue: 85.0/250, alpha: 1.0)
    }
    
    class var buttonBlue: UIColor {
        return UIColor(red: 13.0/255, green: 179.0/255, blue: 224.0/250, alpha: 1.0)
    }
}

extension String {
    func isValidEmail() -> Bool {
        
        let emailRegEx = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: self)
    }
    
    func isEmpty() -> Bool {
        let patternForEmptyString = "^\\s*$"
        if self.range(of: patternForEmptyString, options: .regularExpression) != nil {
            return true
        }
        return false
    }
    
    func emailPrefix() -> String? {
        let delimiter = "@"
        let token = self.components(separatedBy: delimiter)
        if token.count > 1 {
            return token[0]
        } else {
            return nil
        }
    }
}

extension UIImage {
    func scaleTo(width: CGFloat, height: CGFloat) -> UIImage {
        let newSize = CGSize(width: width, height: height)
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        self.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
}

extension UserDefaults {
    class var hasLoggedIn: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "User_HasLoggIn_Key")
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "User_HasLoggIn_Key")
        }
    }
    
    class var email: String? {
        get {
            return UserDefaults.standard.string(forKey: "User_Email_Key")
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "User_Email_Key")
        }
    }
    
    class var nickname: String? {
        get {
            return UserDefaults.standard.string(forKey: "User_Nickname_Key")
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "User_Nickname_Key")
        }
    }
}
