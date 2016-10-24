//
//  LoginKit.swift
//  uscfun
//
//  Created by Wenzheng Li on 10/24/16.
//  Copyright © 2016 Wenzheng Li. All rights reserved.
//

import Foundation

enum SignUpError: Error, CustomNSError {
    case cannotCreateAvatar(reason: String)
    case cannotUploadAvatar(reason: String)
    
    static var errorDomain: String {
        return "SignUpError"
    }
    
    var errorCode: Int {
        switch self {
        case .cannotCreateAvatar(_):
            return 1
        case .cannotUploadAvatar(_):
            return 2
        }
    }
    
    var errorUserInfo: [String : Any] {
        switch self {
        case .cannotCreateAvatar(let reason):
            return ["avatar": reason]
        case .cannotUploadAvatar(let reason):
            return ["avatar": reason]
        }
    }
}

class LoginKit {
    static var password: String?
    
    static func signUp(handler: (_ succeed: Bool, _ error: NSError?) -> Void) {
        
        // save user info in server
        let user: AVUser = AVUser()
        user.username = UserDefaults.email
        user.password = LoginKit.password
        user.email = UserDefaults.email
        user.setObject(UserDefaults.nickname, forKey: UserKeyConstants.keyOfNickname)
        user.setObject(USCFunConstants.nameOfUSC, forKey: UserKeyConstants.keyOfSchool)
        
        // randomly generate avatar color
        let randomIndex = Int(arc4random_uniform(UInt32(USCFunConstants.avatarColorOptions.count)))
        guard let avatar = UserDefaults.nickname!.letterImage(textColor: UIColor.white,
                                                              backgroundColor: USCFunConstants.avatarColorOptions[randomIndex],
                                                              width: 100,
                                                              height: 100) else {
            handler(false, SignUpError.cannotCreateAvatar(reason: "cannot create default avatar") as NSError?)
            return
        }
        
        guard let file = AVFile(data: UIImagePNGRepresentation(avatar)) else {
            handler(false, SignUpError.cannotUploadAvatar(reason: "cannot upload avatar") as NSError?)
            return
        }
        
        UserDefaults.avatar = avatar
        
        var error: NSError?
        if file.save(&error) {
            user.setObject(file.url, forKey: UserKeyConstants.keyOfAvatarUrl)
            if user.signUp(&error) {
                handler(true, nil)
            } else {
                handler(false, error)
            }
        } else {
            handler(false, error)
        }
    }
    
    static func signIn(email: String, password: String, handler: @escaping (_ succeed: Bool, _ error: Error?) -> Void) {
        
        AVUser.logInWithUsername(inBackground: email, password: password) {
            updatedUser, error in
            if updatedUser != nil {
                print("updatedUser:\(updatedUser!.username)")
                print("currentUser:\(AVUser.current().username)")
                if let allkeys = updatedUser!.allKeys() as? [String] {
                    if allkeys.contains(UserKeyConstants.keyOfNickname) {
                        if let nickname = updatedUser?.value(forKey: UserKeyConstants.keyOfNickname) as? String {
                            UserDefaults.nickname = nickname
                        }
                    }
                    
                    if allkeys.contains(UserKeyConstants.keyOfGender) {
                        if let gender = updatedUser!.value(forKey: UserKeyConstants.keyOfGender) as? String {
                            UserDefaults.gender = gender
                        }
                    }
                    
                    if allkeys.contains(UserKeyConstants.keyOfLeftHanded) {
                        if let isLefthanded = updatedUser!.value(forKey: UserKeyConstants.keyOfLeftHanded) as? Bool {
                            UserDefaults.isLefthanded = isLefthanded
                        }
                    } else {
                        UserDefaults.isLefthanded = false
                    }
                    
                    if AVUser.current() == nil || updatedUser!.email != UserDefaults.email {
                        if allkeys.contains(UserKeyConstants.keyOfAvatarUrl) {
                            if let avatarUrl = updatedUser!.value(forKey: UserKeyConstants.keyOfAvatarUrl) as? String {
                                if let file = AVFile(url: avatarUrl) {
                                    var avatarError: NSError?
                                    if let avatarData = file.getData(&avatarError) {
                                        UserDefaults.avatar = UIImage(data: avatarData)
                                    } else {
                                        handler(false, error)
                                        return
                                    }
                                }
                            }
                        }
                    }
                    
                    UserDefaults.hasLoggedIn = true
                    UserDefaults.email = updatedUser!.email
                }
                handler(true, nil)
            } else {
                handler(false, error)
            }
        }
    }
    
    static func signOut() {
        UserDefaults.hasLoggedIn = false
        EventRequest.events.removeAll()
        EventRequest.eventsCurrentUserIsIn.removeAll()
        
        let appDelegate = UIApplication.shared.delegate! as! AppDelegate
        let initialViewController = UIStoryboard(name: "Login", bundle: nil).instantiateInitialViewController()
        appDelegate.window?.rootViewController = initialViewController
        appDelegate.window?.makeKeyAndVisible()
    }
}
