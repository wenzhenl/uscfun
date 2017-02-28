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
    
    class var allowsEventHistoryViewed: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "User_AllowHistoryViewed_Key")
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "User_AllowHistoryViewed_Key")
        }
    }
    
    static func updateIsLefthanded(isLefthanded: Bool) {
        UserDefaults.isLefthanded = isLefthanded
        AVUser.current().setObject(UserDefaults.isLefthanded, forKey: UserKeyConstants.keyOfLeftHanded)
        AVUser.current().saveInBackground()
    }
    
    static func updateAllowsEventHistoryViewed(allowsEventHistoryViewed: Bool) {
        UserDefaults.allowsEventHistoryViewed = allowsEventHistoryViewed
        AVUser.current().setObject(UserDefaults.allowsEventHistoryViewed, forKey: UserKeyConstants.keyOfAllowsEventHistoryViewed)
        AVUser.current().saveInBackground()
    }
    
    //-MARK: new event info
    
    class var newEventName: String? {
        get {
            return UserDefaults.standard.string(forKey: "New_Event_Name")
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "New_Event_Name")
        }
    }
    
    class var newEventDue: Date {
        get {
            let interval = UserDefaults.standard.double(forKey: "New_Event_Due")
            return Date(timeIntervalSince1970: interval)
        }
        set {
            UserDefaults.standard.setValue(newValue.timeIntervalSince1970, forKey: "New_Event_Due")
        }
    }
    
    class var newEventMaxPeople: Int {
        get {
            return UserDefaults.standard.integer(forKey: "New_Event_Max_People")
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "New_Event_Max_People")
        }
    }
    
    class var newEventMinPeople: Int {
        get {
            return UserDefaults.standard.integer(forKey: "New_Event_Min_People")
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "New_Event_Min_People")
        }
    }
    
    class var newEventNumReserved: Int {
        get {
            return UserDefaults.standard.integer(forKey: "New_Event_Num_Reserved")
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "New_Event_Num_Reserved")
        }
    }
    
    class var newEventStartTime: Date {
        get {
            let interval = UserDefaults.standard.double(forKey: "New_Event_Start")
            return Date(timeIntervalSince1970: interval)
        }
        set {
            UserDefaults.standard.setValue(newValue.timeIntervalSince1970, forKey: "New_Event_Start")
        }
    }
    
    class var newEventEndTime: Date {
        get {
            let interval = UserDefaults.standard.double(forKey: "New_Event_End")
            return Date(timeIntervalSince1970: interval)
        }
        set {
            UserDefaults.standard.setValue(newValue.timeIntervalSince1970, forKey: "New_Event_End")
        }
    }
    
    class var newEventNote: String? {
        get {
            return UserDefaults.standard.string(forKey: "New_Event_Note")
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "New_Event_Note")
        }
    }
}
