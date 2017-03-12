//
//  LoginKit.swift
//  uscfun
//
//  Created by Wenzheng Li on 10/24/16.
//  Copyright © 2016 Wenzheng Li. All rights reserved.
//

import Foundation
import ChatKit

/// possible errors with event
enum SignUpError: Error {
    case systemError(localizedDescriotion: String, debugDescription: String)
}

extension SignUpError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .systemError(let description, _):
            return description
        }
    }
    
    public var failureReason: String? {
        switch self {
        case .systemError(_, let description):
            return description
        }
    }
    
    public var recoverySuggestion: String? {
        switch self {
        case .systemError(_, let description):
            return description
        }
    }
}

enum LoginError: Error {
    case cannotFetchKeys(reason: String)
    case cannotFindNickname(reason: String)
    case cannotFetchAvatar(reason: String)
}

protocol LoginDelegate {
    func userDidLoggedIn()
}

class LoginKit {
    static var password: String?
    
    static var delegate: LoginDelegate?
    
    static func getExistingUserEmails() -> [String] {
        var emails = [String]()
        let query = AVQuery(className: "_User")
        query.whereKeyExists("email")
        query.selectKeys(["email"])
        if let objects = query.findObjects() {
            for object in objects as! [AVUser] {
                emails.append(object.email!)
            }
        }
        return emails
    }
    
    static func requestConfirmationCode(handler: (_ succeeded: Bool, _ error: Error?) -> Void) {
        guard let email = UserDefaults.email, email.isValid else {
            handler(false, SignUpError.systemError(localizedDescriotion: "邮箱无效", debugDescription: "email is not valid"))
            return
        }
        var error: NSError?
        AVCloud.callFunction("requestConfirmationCode",
                             withParameters: ["email": UserDefaults.email!],
                             error: &error)
        if error != nil {
            handler(false, error)
        } else {
            handler(true, nil)
        }
    }
    
    static func signUp(handler: (_ succeed: Bool, _ error: Error?) -> Void) {
        
        guard let email = UserDefaults.newEmail, email.isValid else {
            handler(false, SignUpError.systemError(localizedDescriotion: "邮箱地址无效", debugDescription: "failed to sign up: email is not right"))
            return
        }
        
        guard let nickname = UserDefaults.newNickname else {
            handler(false, SignUpError.systemError(localizedDescriotion: "昵称不能为空", debugDescription: "failed to sign up: nickname is missing"))
            return
        }
        
        // save user info in server
        let user: AVUser = AVUser()
        user.username = email.replaceAtAndDotByUnderscore
        user.password = LoginKit.password
        user.email = email
        user.setObject(nickname, forKey: UserKeyConstants.keyOfNickname)
        
        // randomly generate avatar color
        let randomIndex = Int(arc4random_uniform(UInt32(USCFunConstants.avatarColorOptions.count)))
        guard let avatar = nickname.letterImage(textColor: UIColor.white,
                                                backgroundColor: USCFunConstants.avatarColorOptions[randomIndex],
                                                width: 100,
                                                height: 100) else {
            handler(false, SignUpError.systemError(localizedDescriotion: "系统故障，无法创建默认头像", debugDescription: "cannot create default avatar"))
            return
        }
        
        guard let data =  UIImagePNGRepresentation(avatar) else {
            handler(false, SignUpError.systemError(localizedDescriotion: "上传默认头像失败", debugDescription: "cannot upload default avatar"))
            return
        }
        let file = AVFile(data: data)
        
        UserDefaults.avatar = avatar
        
        var error: NSError?
        if file.save(&error) {
            user.setObject(file.url, forKey: UserKeyConstants.keyOfAvatarUrl)
            if user.signUp(&error) {
                if let current = AVUser.current() {
                    UserDefaults.email = current.email
                    UserDefaults.nickname = current.value(forKey: UserKeyConstants.keyOfNickname) as! String?
                    print("new nickname: \(UserDefaults.nickname ?? "")")
                } else {
                    print("failed to update current AVUser after signup")
                }
                
                UserDefaults.newEmail = nil
                UserDefaults.newNickname = nil
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
                        let avatarUrl = updatedUser!.value(forKey: UserKeyConstants.keyOfAvatarUrl) as? String else {
                            handler(false, LoginError.cannotFetchAvatar(reason: "cannot fetch avatar"))
                            return
                    }
                    let file = AVFile(url: avatarUrl)
                    var avatarError: NSError?
                    guard let avatarData = file.getData(&avatarError) else {
                        handler(false, avatarError)
                        return
                    }
                    
                    UserDefaults.avatar = UIImage(data: avatarData)
                }
                
                if allkeys.contains(UserKeyConstants.keyOfGender) {
                    if let gender = updatedUser!.value(forKey: UserKeyConstants.keyOfGender) as? String {
                        UserDefaults.gender = Gender(rawValue: gender) ?? Gender.unknown
                    }
                }
                
                if allkeys.contains(UserKeyConstants.keyOfAllowsEventHistoryViewed) {
                    if let allowsEventHistoryViewed = updatedUser!.value(forKey: UserKeyConstants.keyOfAllowsEventHistoryViewed) as? Bool {
                        UserDefaults.allowsEventHistoryViewed = allowsEventHistoryViewed
                    }
                } else {
                    UserDefaults.allowsEventHistoryViewed = false
                }
                
                if allkeys.contains(UserKeyConstants.keyOfSelfIntroduction) {
                    if let selfIntroduction = updatedUser!.value(forKey: UserKeyConstants.keyOfSelfIntroduction) as? String {
                        UserDefaults.selfIntroduction = selfIntroduction
                    }
                }
                
                UserDefaults.nickname = nickname
                UserDefaults.hasLoggedIn = true
                UserDefaults.email = updatedUser!.email
                
                delegate?.userDidLoggedIn()
                
                handler(true, nil)
            } else {
                handler(false, error)
            }
        }
    }
    
    static func signOut() {
        UserDefaults.hasLoggedIn = false
        EventRequest.publicEvents.removeAll()
        EventRequest.myOngoingEvents.removeAll()
        
        LCChatKit.sharedInstance().close() {
            succeed, error in
            if succeed {
                print("LCChatKit closed successfully")
            }
            else if error != nil {
                print(error!.localizedDescription)
            }
        }
        
        let appDelegate = UIApplication.shared.delegate! as! AppDelegate
        let initialViewController = UIStoryboard(name: "Login", bundle: nil).instantiateInitialViewController()
        appDelegate.window?.rootViewController = initialViewController
        appDelegate.window?.makeKeyAndVisible()
    }
}
