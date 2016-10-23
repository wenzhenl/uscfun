//
//  USCFunConstants.swift
//  uscfun
//
//  Created by Wenzheng Li on 8/25/16.
//  Copyright © 2016 Wenzheng Li. All rights reserved.
//

import Foundation
import UIKit

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
    
    class var avatar: UIImage? {
        get {
            let imageData = UserDefaults.standard.object(forKey: "User_Avatar_Key")
            if imageData != nil {
                return UIImage(data: imageData as! Data)
            }
            return nil
        }
        set {
            if let newImage = newValue {
                let imageData = UIImagePNGRepresentation(newImage)
                UserDefaults.standard.setValue(imageData, forKey: "User_Avatar_Key")
            }
        }
    }
    
    class var avatarColor: String? {
        get {
            return UserDefaults.standard.string(forKey: "User_AvatarColor_Key")
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "User_AvatarColor_Key")
        }
    }
    
    class var gender: String? {
        get {
            return UserDefaults.standard.string(forKey: "User_Gender_Key")
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "User_Gender_Key")
        }
    }
    
    class var isLefthanded: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "User_Lefthanded_Key")
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "User_Lefthanded_Key")
        }
    }
}

class USCFunConstants {
    
    static let minimumPasswordLength = 5
    static let nameOfUSC = "usc"
    
    static let avatarColorOptions : [String: UIColor] = [
        "blue": UIColor.avatarBlue,
        "cyan": UIColor.avatarCyan,
        "pink": UIColor.avatarPink,
        "golden": UIColor.avatarGolden,
        "orange": UIColor.avatarOrange,
        "tomato": UIColor.avatarTomato,
        "green": UIColor.avatarGreen,
    ]
    
    static var password: String?

    static func signUp(handler: (_ succeed: Bool, _ error: NSError?) -> Void) {
        
        // save user info in server
        let user: AVUser = AVUser()
        user.username = UserDefaults.email
        user.password = USCFunConstants.password
        user.email = UserDefaults.email
        user.setObject(UserDefaults.nickname, forKey: UserKeyConstants.keyOfNickname)
        user.setObject(USCFunConstants.nameOfUSC, forKey: UserKeyConstants.keyOfSchool)
        
        // randomly generate avatar color
        let randomIndex = Int(arc4random_uniform(UInt32(USCFunConstants.avatarColorOptions.count)))
        let randomAvatarColorName = Array(USCFunConstants.avatarColorOptions.keys)[randomIndex]
        UserDefaults.avatarColor = randomAvatarColorName
        user.setObject(randomAvatarColorName, forKey: UserKeyConstants.keyOfAvatarColor)
        
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
                UserDefaults.email = updatedUser!.email
                if let allkeys = updatedUser!.allKeys() as? [String] {
                    if allkeys.contains(UserKeyConstants.keyOfNickname) {
                        if let nickname = updatedUser?.value(forKey: UserKeyConstants.keyOfNickname) as? String {
                            UserDefaults.nickname = nickname
                        }
                    }
                    
                    if allkeys.contains(UserKeyConstants.keyOfGender) {
                        if let gender = updatedUser!.value(forKey: UserKeyConstants.keyOfGender) as? String {
                            UserDefaults.gender = gender
                        }
                    }
                    
                    if allkeys.contains(UserKeyConstants.keyOfAvatarColor) {
                        if let avatarColor = updatedUser!.value(forKey: UserKeyConstants.keyOfAvatarColor) as? String {
                            UserDefaults.avatarColor = avatarColor
                        }
                    }
                    
                    if allkeys.contains(UserKeyConstants.keyOfLeftHanded) {
                        if let isLefthanded = updatedUser!.value(forKey: UserKeyConstants.keyOfLeftHanded) as? Bool {
                            UserDefaults.isLefthanded = isLefthanded
                        }
                    } else {
                        UserDefaults.isLefthanded = false
                    }
                    
                    if UserDefaults.avatar == nil {
                        if allkeys.contains(UserKeyConstants.keyOfAvatarUrl) {
                            if let avatarUrl = updatedUser!.value(forKey: UserKeyConstants.keyOfAvatarUrl) as? String {
                                if let file = AVFile(url: avatarUrl) {
                                    file.getDataInBackground() {
                                        data, error in
                                        if data != nil {
                                            UserDefaults.avatar = UIImage(data: data!)
                                        } else {
                                            print(error)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                handler(true, nil)
            } else {
                handler(false, error)
            }
        }
    }
    
    static func signOut() {
        UserDefaults.hasLoggedIn = false
        EventRequest.events.removeAll()
        EventRequest.eventsCurrentUserIsIn.removeAll()
        
        let appDelegate = UIApplication.shared.delegate! as! AppDelegate
        let initialViewController = UIStoryboard(name: "Login", bundle: nil).instantiateInitialViewController()
        appDelegate.window?.rootViewController = initialViewController
        appDelegate.window?.makeKeyAndVisible()
    }
    
    static func updateIsLefthanded(isLefthanded: Bool) {
        UserDefaults.isLefthanded = isLefthanded
        AVUser.current().setObject(UserDefaults.isLefthanded, forKey: UserKeyConstants.keyOfLeftHanded)
        AVUser.current().saveInBackground()
    }
}

struct UserKeyConstants {
    static let keyOfNickname = "nickname"
    static let keyOfAvatarUrl = "avatarUrl"
    static let keyOfAvatarColor = "avatarColor"
    static let keyOfSchool = "school"
    static let keyOfGender = "gender"
    static let keyOfLeftHanded = "leftHanded"
}

struct EventKeyConstants {
    static let classNameOfEvent = "Event"
    static let keyOfName = "name"
    static let keyOfType = "type"
    static let keyOfTotalSeats = "totalSeats"
    static let keyOfRemainingSeats = "remainingSeats"
    static let keyOfMinimumMoreAttendingPeople = "minimumMoreAttendingPeople"
    static let keyOfDue = "due"
    
    static let keyOfCreator = "creator"
    static let keyOfMembers = "members"
    static let keyOfActive = "active"
    static let keyOfFinished = "finished"
    static let keyOfConversationId = "conversationId"
    static let keyOfSchool = "school"
    
    static let keyOfStartTime = "startTime"
    static let keyOfEndTime = "endTime"
    static let keyOfLocationName = "locationName"
    static let keyOfLocation = "location"
    static let keyOfExpectedFee = "expectedFee"
    static let keyOfTransportationMethod = "transportationMethod"
    static let keyOfNote = "note"
    
    static let keyOfUpdatedAt = "updatedAt"
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
        return UIColor(red: 153.0/255, green: 27.0/255, blue: 30.0/255, alpha: 1.0)
    }
    
    class func themeUSCRed(_ alpha: CGFloat) -> UIColor {
        return UIColor(red: 153.0/255, green: 27.0/255, blue: 30.0/255, alpha: alpha)
    }
    
    class var backgroundGray: UIColor {
        let grayLevel = CGFloat(240.0)
        return UIColor(red: grayLevel/255, green: grayLevel/255, blue: grayLevel/255, alpha: 1.0)
    }
    
    class var buttonPink: UIColor {
        return UIColor(red: 239.0/255, green: 31.0/255, blue: 85.0/255, alpha: 1.0)
    }
    
    class var buttonBlue: UIColor {
        return UIColor(red: 13.0/255, green: 179.0/255, blue: 224.0/255, alpha: 1.0)
    }
    
    //--MARK: Avatar background colors
    class var avatarGolden: UIColor {
        return UIColor(red: 255.0/255, green: 153.0/255, blue: 51/255, alpha: 1.0)
    }
    class var avatarBlue: UIColor {
        return UIColor(red: 0, green: 102.0/255, blue: 153.0/255, alpha: 1.0)
    }
    class var avatarCyan: UIColor {
        return UIColor(red: 2.0/255, green: 132.0/255, blue: 128.0/255, alpha: 1.0)

    }
    class var avatarOrange: UIColor {
        return UIColor(red: 255.0/255, green: 102.0/255, blue: 0, alpha: 1.0)
    }
    class var avatarPink: UIColor {
        return UIColor(red: 239.0/255, green: 31.0/255, blue: 85.0/255, alpha: 1.0)
    }
    class var avatarGreen: UIColor {
        return UIColor(red: 1.0/255, green: 153.0/255, blue: 51/255, alpha: 1.0)
    }
    class var avatarTomato: UIColor {
        return UIColor(red: 255.0/255, green: 99.0/255, blue: 71.0/255, alpha: 1.0)
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
