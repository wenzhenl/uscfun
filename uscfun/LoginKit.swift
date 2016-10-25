//
//  LoginKit.swift
//  uscfun
//
//  Created by Wenzheng Li on 10/24/16.
//  Copyright © 2016 Wenzheng Li. All rights reserved.
//

import Foundation

enum SignUpError: Error {
    case cannotCreateAvatar(reason: String)
    case cannotUploadAvatar(reason: String)
}

enum LoginError: Error {
    case cannotFetchKeys(reason: String)
    case cannotFindNickname(reason: String)
    case cannotFetchAvatar(reason: String)
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
                
                guard let allkeys = updatedUser!.allKeys() as? [String] else {
                    handler(false, LoginError.cannotFetchKeys(reason: "cannot fetch keys"))
                    return
                }
                
                guard allkeys.contains(UserKeyConstants.keyOfNickname),
                    let nickname = updatedUser?.value(forKey: UserKeyConstants.keyOfNickname) as? String else {
                    handler(false, LoginError.cannotFindNickname(reason: "cannot find nickname"))
                    return
                }
                
                if AVUser.current() == nil || updatedUser!.email != UserDefaults.email {
                    guard allkeys.contains(UserKeyConstants.keyOfAvatarUrl),
                        let avatarUrl = updatedUser!.value(forKey: UserKeyConstants.keyOfAvatarUrl) as? String,
                        let file = AVFile(url: avatarUrl) else {
                            handler(false, LoginError.cannotFetchAvatar(reason: "cannot fetch avatar"))
                            return
                    }
                    
                    var avatarError: NSError?
                    guard let avatarData = file.getData(&avatarError) else {
                        handler(false, avatarError)
                        return
                    }
                    
                    UserDefaults.avatar = UIImage(data: avatarData)
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
                
                UserDefaults.nickname = nickname
                UserDefaults.hasLoggedIn = true
                UserDefaults.email = updatedUser!.email
                handler(true, nil)
            } else {
                handler(false, error)
            }
        }
    }
    
    static func signOut() {
        UserDefaults.hasLoggedIn = false
        EventRequest.events.removeAll()
        EventRequest.myEvents.removeAll()
        EventRequest.indexOfMyEvents.removeAll()
        EventRequest.indexOfEvents.removeAll()
        
        let appDelegate = UIApplication.shared.delegate! as! AppDelegate
        let initialViewController = UIStoryboard(name: "Login", bundle: nil).instantiateInitialViewController()
        appDelegate.window?.rootViewController = initialViewController
        appDelegate.window?.makeKeyAndVisible()
    }
}
