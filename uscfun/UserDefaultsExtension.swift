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
    
    class var confirmationCode: String? {
        get {
            return UserDefaults.standard.string(forKey: "User_confirmationCode_Key")
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "User_confirmationCode_Key")
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
    
    static func updateUserAvatar() {
        print("update avatar")
        guard let data = UIImagePNGRepresentation(UserDefaults.avatar!) else {
            return
        }
        let file = AVFile(data: data)
        
        file.saveInBackground({
            succeeded, error in
            if succeeded {
                AVUser.current()!.setObject(file.url, forKey: UserKeyConstants.keyOfAvatarUrl)
                AVUser.current()!.saveInBackground()
            }
        })
    }
    
    static func updateUserProfile(withNickName: Bool, withGender: Bool, withSelfIntroduction: Bool) {
        
        if !withNickName && !withGender && !withSelfIntroduction {
            return
        }

        print("update other info")

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
    
    //-MARK: feedback
    class var feedback: String? {
        get {
            return UserDefaults.standard.string(forKey: "user_feedback")
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "user_feedback")
        }
    }
    
    static func sendFeedback(handler: ((_ succeeded: Bool, _ error: Error?) -> Void)?) {
        guard let feedback = UserDefaults.feedback, !feedback.isEmpty else { return }
        var error: NSError?
        AVCloud.callFunction("receiveFeedback", withParameters: ["feedback": UserDefaults.feedback!, "email": AVUser.current()!.email!], error: &error)
        if error != nil {
            handler?(false, error)
        } else {
            handler?(true, nil)
        }
    }
}
