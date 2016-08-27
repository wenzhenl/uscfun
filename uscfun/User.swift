//
//  Me.swift
//  uscfun
//
//  Created by Wenzheng Li on 8/25/16.
//  Copyright © 2016 Wenzheng Li. All rights reserved.
//

import Foundation

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
}