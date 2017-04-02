//
//  UserDefaultsExtension.swift
//  uscfun
//
//  Created by Wenzheng Li on 10/24/16.
//  Copyright © 2016 Wenzheng Li. All rights reserved.
//

import Foundation

extension UserDefaults {
    
    /// user sign up variables
    class var newEmail: String? {
        get {
            return UserDefaults.standard.string(forKey: "User_New_Email_Key")
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "User_New_Email_Key")
        }
    }
    
    class var newNickname: String? {
        get {
            return UserDefaults.standard.string(forKey: "User_New_Nickname_Key")
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "User_New_Nickname_Key")
        }
    }

    /// user sign in variables
    class var hasLoggedIn: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "User_HasLoggIn_Key")
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "User_HasLoggIn_Key")
        }
    }
    
    class var hasPreloadedMyOngoingEvents: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "User_hasPreloadedMyOngoingEvents_Key")
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "User_hasPreloadedMyOngoingEvents_Key")
        }
    }
    
    class var hasPreloadedPublicEvents: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "User_hasPreloadedPublicEvents_Key")
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "User_hasPreloadedPublicEvents_Key")
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
    
    class var gender: Gender {
        get {
            guard let genderText = UserDefaults.standard.string(forKey: "User_Gender_Key") else { return Gender.unknown }
            return Gender(rawValue: genderText) ?? Gender.unknown
        }
        set {
            UserDefaults.standard.setValue(newValue.rawValue, forKey: "User_Gender_Key")
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
    
    class var selfIntroduction: String? {
        get {
            return UserDefaults.standard.string(forKey: "User_Self_Introduction_Key")
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "User_Self_Introduction_Key")
        }
    }
    
    static func updateAllowsEventHistoryViewed() {
        AVUser.current()!.setObject(UserDefaults.allowsEventHistoryViewed, forKey: UserKeyConstants.keyOfAllowsEventHistoryViewed)
        AVUser.current()!.saveEventually()
    }
    
    class var needToSaveAvatarEventually: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "User_needToSaveAvatarEventually_Key")
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "User_needToSaveAvatarEventually_Key")
        }
    }
    
    static func updateUserAvatar() {
        print("user is updating avatar")
        guard let data = UIImagePNGRepresentation(UserDefaults.avatar!) else {
            print("update avatar failed: cannot get image png representation")
            needToSaveAvatarEventually = true
            return
        }
        let file = AVFile(data: data)
        
        file.saveInBackground({
            succeeded, error in
            if succeeded {
                AVUser.current()!.setObject(file.url, forKey: UserKeyConstants.keyOfAvatarUrl)
                AVUser.current()!.saveInBackground {
                    succeeded, error in
                    if succeeded {
                        needToSaveAvatarEventually = false
                    }
                    if error != nil {
                        print("update avatar failed:\(error!.localizedDescription)")
                        needToSaveAvatarEventually = true
                    }
                    
                }
            }
            if error != nil {
                print("update avatar failed:\(error!.localizedDescription)")
                needToSaveAvatarEventually = true
            }
        })
    }
    
    static func updateUserProfile(withNickName: Bool, withGender: Bool, withSelfIntroduction: Bool) {
        
        if !withNickName && !withGender && !withSelfIntroduction {
            return
        }

        print("user is updating other information")

        if withNickName {
            AVUser.current()!.setObject(UserDefaults.nickname, forKey: UserKeyConstants.keyOfNickname)
        }
        
        if withGender {
            AVUser.current()!.setObject(UserDefaults.gender.rawValue, forKey: UserKeyConstants.keyOfGender)
        }
        
        if withSelfIntroduction {
            AVUser.current()!.setObject(UserDefaults.selfIntroduction, forKey: UserKeyConstants.keyOfSelfIntroduction)
        }
        
        AVUser.current()!.saveEventually()
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
    
    class var newEventLocation: String? {
        get {
            return UserDefaults.standard.string(forKey: "New_Event_Location_Name")
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "New_Event_Location_Name")
        }
    }
    
    class var newEventLocationLongitude: Double {
        get {
            return UserDefaults.standard.double(forKey: "New_Event_Location_Longitude")
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "New_Event_Location_Longitude")
        }
    }
    
    class var newEventLocationLatitude: Double {
        get {
            return UserDefaults.standard.double(forKey: "New_Event_Location_Latitude")
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "New_Event_Location_Latitude")
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
    
    //--MARK: indicate this application becomes active immediately after launch
    class var isfirstActiveFollowingLaunching: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "isfirstActiveFollowingLaunching_Key")
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "isfirstActiveFollowingLaunching_Key")
        }
    }
}
