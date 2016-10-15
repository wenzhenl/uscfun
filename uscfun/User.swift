//
//  User.swift
//  uscfun
//
//  Created by Wenzheng Li on 8/25/16.
//  Copyright © 2016 Wenzheng Li. All rights reserved.
//

import Foundation
import AVOSCloud

class User {
    static var hasLoggedIn: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "User_HasLoggIn_Key")
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "User_HasLoggIn_Key")
        }
    }
    
    static var email: String? {
        get {
            return UserDefaults.standard.string(forKey: "User_Email_Key")
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "User_Email_Key")
        }
    }
    
    static var nickname: String? {
        get {
            return UserDefaults.standard.string(forKey: "User_Nickname_Key")
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "User_Nickname_Key")
        }
    }
    
    static var password: String?
    
    static func signUp(handler: (_ succeed: Bool, _ error: NSError?) -> Void){
        
        // save user info in server
        let user: AVUser = AVUser()
        user.username = email
        user.password = password
        user.email = email
        user.setObject(nickname, forKey: keyOfNickname)
        user.setObject("usc", forKey: keyOfSchool)
        var error: NSError?
        if user.signUp(&error) {
            handler(true, nil)
        } else {
            handler(false, error)
        }
    }
    
    static func signIn(email: String, password: String, handler: @escaping (_ succeed: Bool, _ error: Error?) -> Void){
        
        AVUser.logInWithUsername(inBackground: email, password: password) {
            updatedUser, error in
            if updatedUser != nil {
                self.hasLoggedIn = true
                if let allkeys = updatedUser!.allKeys() as? [String] {
                    if allkeys.contains(keyOfNickname) {
                        if let nickname = updatedUser?.value(forKey: keyOfNickname) as? String {
                            self.nickname = nickname
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
