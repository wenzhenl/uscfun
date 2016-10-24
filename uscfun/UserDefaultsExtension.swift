//
//  UserDefaultsExtension.swift
//  uscfun
//
//  Created by Wenzheng Li on 10/24/16.
//  Copyright © 2016 Wenzheng Li. All rights reserved.
//

import Foundation

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
    
    static func updateIsLefthanded(isLefthanded: Bool) {
        UserDefaults.isLefthanded = isLefthanded
        AVUser.current().setObject(UserDefaults.isLefthanded, forKey: UserKeyConstants.keyOfLeftHanded)
        AVUser.current().saveInBackground()
    }
}
