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
        var error: NSError?
        let result = AVCloud.callFunction(LeanEngineFunctions.nameOfCheckIfEmailIsTaken, withParameters: ["email": email], error: &error)
        if error != nil {
            print(error!)
            throw SignUpError.systemError(localizedDescriotion: "无法验证邮箱是否被占用", debugDescription: error!.localizedDescription)
        }
        
        guard let isTaken = result as? Bool else {
            print("failed to check if email is taken: cannot parse return value")
            throw SignUpError.systemError(localizedDescriotion: "无法验证邮箱是否被占用", debugDescription: "cannot check if email is taken")
        }
        
        return isTaken
    }
    
    static func checkIfConfirmationCodeMatches(email: String, code: String)throws -> Bool {
        var error: NSError?
        let result = AVCloud.callFunction(LeanEngineFunctions.nameOfCheckIfConfirmationCodeMatches, withParameters: ["email": email, "code": code], error: &error)
        if error != nil {
            print(error!)
            throw SignUpError.systemError(localizedDescriotion: "无法验证验证码", debugDescription: error!.localizedDescription)
        }
        
        guard let matched = result as? Bool else {
            print("failed to check if confirmation code match: cannot parse return value")
            throw SignUpError.systemError(localizedDescriotion: "无法验证验证码", debugDescription: "cannot check if confirmation code matches")
        }
        
        return matched
    }
    
    static func requestConfirmationCode(email: String)throws {
        var error: NSError?
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        let result = AVCloud.callFunction(LeanEngineFunctions.nameOfRequestConfirmationCode, withParameters: ["email": email], error: &error)
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        if error != nil {
            print(error!)
            throw SignUpError.systemError(localizedDescriotion: "无法发送验证码", debugDescription: error!.localizedDescription)
        }
        
        guard let succeeded = result as? Bool, succeeded == true else {
            print("failed to request confirmation code: cannot parse return value")
            throw SignUpError.systemError(localizedDescriotion: "无法验证验证码", debugDescription: "cannot send confirmation code")
        }
    }
    
    static func createSystemConversationIfNotExists(email: String)throws {
        var error: NSError?
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        let result = AVCloud.callFunction(LeanEngineFunctions.nameOfCreateSystemConversationIfNotExists, withParameters: ["email": email], error: &error)
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        
        guard let succeeded = result as? Bool, succeeded == true else {
            print("failed to create system conversation: cannot parse return value")
            throw SignUpError.systemError(localizedDescriotion: "无法创建系统对话", debugDescription: "cannot create system conversation")
        }
        
        if error != nil {
            print(error!)
            throw SignUpError.systemError(localizedDescriotion: "无法创建系统对话", debugDescription: error!.localizedDescription)
        }
    }
    
    static func subscribeToSystemConversation(clientId: String, institution: String)throws {
        var error: NSError?
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        let result = AVCloud.callFunction(LeanEngineFunctions.nameOfSubscribeToSystemConversation, withParameters: ["clientId": clientId, "institution": institution], error: &error)
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        if error != nil {
            print(error!)
            throw SignUpError.systemError(localizedDescriotion: "无法订阅系统对话", debugDescription: error!.localizedDescription)
        }
        
        guard let succeeded = result as? Bool, succeeded == true else {
            print("failed to subscribe to system conversation: cannot parse return value")
            throw SignUpError.systemError(localizedDescriotion: "无法订阅系统对话", debugDescription: "cannot subscribe system conversation")
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
        
        // subscribe to institution system conversation
        do {
            try subscribeToSystemConversation(clientId: email.systemClientId ?? "unknown", institution: email.institutionCode ?? "unknown")
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
