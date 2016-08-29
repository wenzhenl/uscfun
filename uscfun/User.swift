//
//  User.swift
//  uscfun
//
//  Created by Wenzheng Li on 8/25/16.
//  Copyright © 2016 Wenzheng Li. All rights reserved.
//

import Foundation

class User {
    static var hasLoggedIn: Bool {
        get {
            return NSUserDefaults.standardUserDefaults().boolForKey("User_HasLoggIn_Key")
        }
        set {
            NSUserDefaults.standardUserDefaults().setValue(newValue, forKey: "User_HasLoggIn_Key")
        }
    }
    
    static var email: String? {
        get {
            return NSUserDefaults.standardUserDefaults().stringForKey("User_Email_Key")
        }
        set {
            NSUserDefaults.standardUserDefaults().setValue(newValue, forKey: "User_Email_Key")
        }
    }
    
    static var nickname: String? {
        get {
            return NSUserDefaults.standardUserDefaults().stringForKey("User_Nickname_Key")
        }
        set {
            NSUserDefaults.standardUserDefaults().setValue(newValue, forKey: "User_Nickname_Key")
        }
    }
    
    static var password: String?
    
    static func signUp() throws -> Bool {
        
        // save account and password in keychain
        let myKeychainWrapper = KeychainWrapper()
        myKeychainWrapper.mySetObject(password, forKey: kSecValueData)
        myKeychainWrapper.mySetObject(email, forKey: kSecAttrAccount)
        myKeychainWrapper.writeToKeychain()
        
        // save user info in server
        let user: AVUser = AVUser()
        user.username = email
        user.password = password
        user.email = email
        user.setObject(nickname, forKey: "nickname")
        user.setObject("usc", forKey: "school")
        var error: NSError?
        if user.signUp(&error) {
            return true
        } else {
            throw error!
        }
    }
}