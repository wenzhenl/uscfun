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
//        if email == nil || !email!.isValidEmail() {
//            throw SignUpError.EmailNotValid
//        }
//        if nickname == nil || nickname!.isEmpty {
//            throw SignUpError.NicknameNotValid
//        }
//        if password == nil || password!.isEmpty {
//            throw SignUpError.PasswordNotValid
//        }
        
        let myKeychainWrapper = KeychainWrapper()
        myKeychainWrapper.mySetObject(password, forKey: kSecValueData)
        myKeychainWrapper.writeToKeychain()
    }
}