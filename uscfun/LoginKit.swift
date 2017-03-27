//
//  LoginKit.swift
//  uscfun
//
//  Created by Wenzheng Li on 10/24/16.
//  Copyright © 2016 Wenzheng Li. All rights reserved.
//

import Foundation
import ChatKit

/// possible errors with sign up
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

/// possible errors with sign in
enum SignInError: Error {
    case systemError(localizedDescriotion: String, debugDescription: String)
}

extension SignInError: LocalizedError {
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

protocol LoginDelegate {
    func userDidLoggedIn()
}

class LoginKit {
    static var password: String?
    
    static var delegate: LoginDelegate?
    
    static func checkIfEmailIsTaken(email: String)throws -> Bool {
        return false
//        var error: NSError?
//        if let result = AVCloud.callFunction(LeanEngineFunctions.nameOfCheckIfEmailIsTaken, withParameters: ["email": email], error: &error) as? Bool {
//            return result
//        } else if error != nil {
//            throw SignUpError.systemError(localizedDescriotion: "网络故障：无法连接服务器", debugDescription: error!.localizedDescription)
//        } else {
//            throw SignUpError.systemError(localizedDescriotion: "网络故障：无法连接服务器", debugDescription: "cannot check confirmation code")
//        }
    }
    
    static func checkIfConfirmationCodeMatches(email: String, code: String)throws -> Bool {
//        var error: NSError?
//        
//        AVCloud.callFunction(inBackground: "checkIfConfirmationCodeMatches", withParameters: ["email": email]) {
//            object, error in
//            if let matched = object as? [String: Bool] {
//                print("if matched: \(matched["succeeded"])")
//            }
//            if error != nil {
//                print(error!.localizedDescription)
//            }
//        }
        return true
//        var error: NSError?
//        if let result = AVCloud.callFunction(LeanEngineFunctions.nameOfCheckIfConfirmationCodeMatches, withParameters: ["email": email, "code": code], error: &error) as? Bool {
//            return result
//        } else if error != nil {
//            throw SignUpError.systemError(localizedDescriotion: "系统故障：无法验证验证码", debugDescription: error!.localizedDescription)
//        } else {
//            throw SignUpError.systemError(localizedDescriotion: "系统故障：无法验证验证码", debugDescription: "cannot check confirmation code")
//        }
    }
    
    static func requestConfirmationCode(email: String)throws {
//        var error: NSError?
//        AVCloud.callFunction("requestConfirmationCode",
//                             withParameters: ["email": email],
//                             error: &error)
//        if error != nil {
//            throw SignUpError.systemError(localizedDescriotion: "系统故障：无法发送验证码", debugDescription: error!.localizedDescription)
//        }
    }
    
    static func createSystemConversationIfNotExists(email: String)throws {
        var error: NSError?
        AVCloud.callFunction(LeanEngineFunctions.nameOfCreateSystemConversationIfNotExists, withParameters: ["email": email], error: &error)
        if error != nil {
            print(error!)
            print(error!.localizedDescription)
            throw SignUpError.systemError(localizedDescriotion: "无法创建系统对话", debugDescription: error!.localizedDescription)
        }
    }
    
    static func signUp()throws {
        
        guard let email = UserDefaults.newEmail, email.isValid else {
            throw SignUpError.systemError(localizedDescriotion: "邮箱格式不正确，请重新输入", debugDescription: "failed to sign up: email is not right")
        }
        
        guard let password = LoginKit.password, password.characters.count >= USCFunConstants.minimumPasswordLength, !password.characters.contains(" ") else {
            throw SignUpError.systemError(localizedDescriotion: "密码不符合要求", debugDescription: "failed to sign up: password format is not right")
        }
        
        guard let nickname = UserDefaults.newNickname, !nickname.isWhitespaces else {
            throw SignUpError.systemError(localizedDescriotion: "昵称不能为空", debugDescription: "failed to sign up: nickname is missing")
        }
        
        // create institution system conversation if not exist
        do {
            try createSystemConversationIfNotExists(email: email)
        } catch let error {
            throw error
        }
        
        // save user info in server
        let user: AVUser = AVUser()
        user.username = email.replaceAtAndDotByUnderscore
        user.password = password
        user.email = email
        user.setObject(nickname, forKey: UserKeyConstants.keyOfNickname)
        
        // randomly generate avatar color
        let randomIndex = Int(arc4random_uniform(UInt32(USCFunConstants.avatarColorOptions.count)))
        guard let avatar = nickname.letterImage(textColor: UIColor.white,
                                                backgroundColor: USCFunConstants.avatarColorOptions[randomIndex],
                                                width: 100,
                                                height: 100) else {
            throw SignUpError.systemError(localizedDescriotion: "系统故障，无法创建默认头像", debugDescription: "failed to sign up: cannot create default avatar")
        }
        
        guard let data =  UIImagePNGRepresentation(avatar) else {
            throw SignUpError.systemError(localizedDescriotion: "上传默认头像失败", debugDescription: "failed to sign up: cannot upload default avatar")
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
                    UserDefaults.gender = .unknown
                    UserDefaults.selfIntroduction = nil
                    UserDefaults.allowsEventHistoryViewed = true
                    UserDefaults.hasLoggedIn = true
                    delegate?.userDidLoggedIn()
                    print("new nickname: \(UserDefaults.nickname ?? "")")
                } else {
                    print("failed to update current AVUser after signup")
                }
                
                UserDefaults.newEmail = nil
                UserDefaults.newNickname = nil
            } else {
                throw SignUpError.systemError(localizedDescriotion: "系统故障：注册失败", debugDescription: error.debugDescription)
            }
        } else {
            throw SignUpError.systemError(localizedDescriotion: "上传默认头像失败", debugDescription: error.debugDescription)
        }
    }
    
    static func signIn(email: String, password: String, handler: @escaping (_ succeed: Bool, _ error: Error?) -> Void) {
        
        AVUser.logInWithUsername(inBackground: email, password: password) {
            updatedUser, error in
            if updatedUser != nil {
                
                guard let nickname = updatedUser?.value(forKey: UserKeyConstants.keyOfNickname) as? String else {
                    handler(false, SignInError.systemError(localizedDescriotion: "登录失败：无法找到昵称", debugDescription: "failed to sign in: nickname is missing"))
                    return
                }
                
                guard let avatarUrl = updatedUser!.value(forKey: UserKeyConstants.keyOfAvatarUrl) as? String else {
                        handler(false, SignInError.systemError(localizedDescriotion: "登录失败：无法找到用户头像", debugDescription: "failed to sign in: avatar is missing"))
                        return
                }
                
                let file = AVFile(url: avatarUrl)
                var avatarError: NSError?
                guard let avatarData = file.getData(&avatarError) else {
                    handler(false, SignInError.systemError(localizedDescriotion: "登录失败：无法加载用户头像", debugDescription: "failed to sign in: cannot download avatar"))
                    return
                }
                
                UserDefaults.avatar = UIImage(data: avatarData)
                
                if let gender = updatedUser!.value(forKey: UserKeyConstants.keyOfGender) as? String {
                    UserDefaults.gender = Gender(rawValue: gender) ?? Gender.unknown
                } else {
                    UserDefaults.gender = .unknown
                }
                
                if let allowsEventHistoryViewed = updatedUser!.value(forKey: UserKeyConstants.keyOfAllowsEventHistoryViewed) as? Bool {
                    UserDefaults.allowsEventHistoryViewed = allowsEventHistoryViewed
                } else {
                    UserDefaults.allowsEventHistoryViewed = true
                }
            
                if let selfIntroduction = updatedUser!.value(forKey: UserKeyConstants.keyOfSelfIntroduction) as? String {
                    UserDefaults.selfIntroduction = selfIntroduction
                } else {
                    UserDefaults.selfIntroduction = ""
                }
                
                UserDefaults.email = updatedUser!.email
                UserDefaults.nickname = nickname
                UserDefaults.hasLoggedIn = true
                
                delegate?.userDidLoggedIn()
                
                handler(true, nil)
            } else {
                handler(false, error)
            }
        }
    }
    
    static func signOut() {
        UserDefaults.hasLoggedIn = false
        UserDefaults.hasPreloadedMyOngoingEvents = false
        UserDefaults.hasPreloadedPublicEvents = false
        EventRequest.removeAllPublicEvents(handler: nil)
        EventRequest.removeAllMyOngoingEvents(handler: nil)
        
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
