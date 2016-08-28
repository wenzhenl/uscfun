//
//  User.swift
//  uscfun
//
//  Created by Wenzheng Li on 8/25/16.
//  Copyright © 2016 Wenzheng Li. All rights reserved.
//

import Foundation

enum SignUpError: ErrorType {
    case EmailNotValid
    case NicknameNotValid
    case PasswordNotValid
    case ServerError
}

class User {
    static var hasLoggedIn = false
    
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
    
    static func signUp(){
        let myKeychainWrapper = KeychainWrapper()
        myKeychainWrapper.mySetObject(password, forKey: kSecValueData)
        myKeychainWrapper.writeToKeychain()
        
        let user: AVUser = AVUser()
        user.username = email
        user.password = password
        user.email = email
        user.signUpInBackgroundWithBlock() {
            succeeded, error in
            if succeeded {
                print("yes")
            }
            else {
                print(error)
            }
        }
    }
}