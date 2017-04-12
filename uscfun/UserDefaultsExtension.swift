//
//  UserDefaultsExtension.swift
//  uscfun
//
//  Created by Wenzheng Li on 10/24/16.
//  Copyright © 2016 Wenzheng Li. All rights reserved.
//

import Foundation

extension UserDefaults {
    
    //--MARK: user sign up variables
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

    //--MARK: user sign in variables
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
    
    class var shouldSkipUnreadAfterLaunch: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "shouldSkipUnreadAfterLaunch")
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "shouldSkipUnreadAfterLaunch")
        }
    }
    
    //--MARK: current user information
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
    
    //--MARK: new event info
    
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
    
    //--MARK: tutorial related
    
    /// current app version
    class var currentVersion: String? {
        get {
            return UserDefaults.standard.string(forKey: "currentVersion")
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "currentVersion")
        }
    }
    
    /// latest app version
    class var latestVersion: String? {
        get {
            return UserDefaults.standard.string(forKey: "latestVersion")
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "latestVersion")
        }
    }
    
    /// remind user to update new version every 7 days
    class var shouldRemindUpdateNewVersion: Bool {
        if currentVersion == latestVersion {
            return false
        }
        else if Date().timeIntervalSince(lastUpdateNewVersionRemindedAt) > TimeInterval(7*24*3600) {
            return true
        }
        return false
    }
    
    class var lastUpdateNewVersionRemindedAt: Date {
        get {
            let interval = UserDefaults.standard.double(forKey: "lastUpdateNewVersionRemindedAt")
            return Date(timeIntervalSince1970: interval)
        }
        set {
            UserDefaults.standard.setValue(newValue.timeIntervalSince1970, forKey: "lastUpdateNewVersionRemindedAt")
        }
    }
    
    /// latest app version description
    class var newVersionDescription: String? {
        get {
            return UserDefaults.standard.string(forKey: "newVersionDescription")
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "newVersionDescription")
        }
    }
    
    /// remind user to open remote notification every 10 days
    class var shouldRemindOpenRemoteNotification: Bool {
        if hasOpenedRemoteNotification {
            return false
        }
        else if Date().timeIntervalSince(lastOpenRemoteNotificationRemindedAt) > TimeInterval(10*24*3600) {
            return true
        }
        return false
    }
    
    class var lastOpenRemoteNotificationRemindedAt: Date {
        get {
            let interval = UserDefaults.standard.double(forKey: "lastOpenRemoteNotificationRemindedAt")
            return Date(timeIntervalSince1970: interval)
        }
        set {
            UserDefaults.standard.setValue(newValue.timeIntervalSince1970, forKey: "lastOpenRemoteNotificationRemindedAt")
        }
    }
    
    class var hasOpenedRemoteNotification: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "hasOpenedRemoteNotification")
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "hasOpenedRemoteNotification")
        }
    }
    
    /// remind user to rate app in app store every 30 days
    class var shouldRemindRateApp: Bool {
        if hasRatedApp {
            return false
        }
        else if Date().timeIntervalSince(lastRateAppRemindedAt) > TimeInterval(30*24*3600) {
            return true
        }
        return false
    }
    
    class var lastRateAppRemindedAt: Date {
        get {
            let interval = UserDefaults.standard.double(forKey: "lastRateAppRemindedAt")
            return Date(timeIntervalSince1970: interval)
        }
        set {
            UserDefaults.standard.setValue(newValue.timeIntervalSince1970, forKey: "lastRateAppRemindedAt")
        }
    }
    
    class var hasRatedApp: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "hasRatedApp")
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "hasRatedApp")
        }
    }
    
    /// clean public events regularly every 10 minutes
    class var shouldCleanPublicEvents: Bool {
        if Date().timeIntervalSince(lastPublicEventsCleanedAt) > TimeInterval(10*60) {
            return true
        }
        return false
    }
    
    class var lastPublicEventsCleanedAt: Date {
        get {
            let interval = UserDefaults.standard.double(forKey: "lastPublicEventsCleanedAt")
            return Date(timeIntervalSince1970: interval)
        }
        set {
            UserDefaults.standard.setValue(newValue.timeIntervalSince1970, forKey: "lastPublicEventsCleanedAt")
        }
    }
    
    /// remind user to be serious first time join an event
    class var hasRemindedUserBeSeriousAboutJoining: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "hasRemindedUserBeSeriousAboutJoining")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "hasRemindedUserBeSeriousAboutJoining")
        }
    }
    
    /// display welcome pages for new user
    class var hasShownWelcomePages: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "hasShownWelcomePages")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "hasShownWelcomePages")
        }
    }
}
