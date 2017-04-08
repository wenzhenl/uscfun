//
//  LoginKit.swift
//  uscfun
//
//  Created by Wenzheng Li on 10/24/16.
//  Copyright © 2016 Wenzheng Li. All rights reserved.
//

import Foundation
import ChatKit

protocol LoginDelegate {
    func userDidLoggedIn()
}

class LoginKit {
    
    static var password: String?
    
    static var delegate: LoginDelegate?
    
    static var systemNotificationClient: AVIMClient?

    static func checkIfEmailIsTaken(email: String)throws -> Bool {
        var error: NSError?
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        let result = AVCloud.callFunction(LeanEngineFunctions.nameOfCheckIfEmailIsTaken, withParameters: ["email": email], error: &error)
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        
        if error != nil {
            print(error!)
            throw error!
        }
        
        guard let isTaken = result as? Bool else {
            print("failed to check if email is taken: cannot parse return value")
            throw NSError(domain: USCFunErrorConstants.domain,
                          code: USCFunErrorConstants.kUSCFunErrorLeanEngineResultsNotExpected,
                          userInfo: [NSLocalizedDescriptionKey: "failed to check if email is taken: cannot parse return value"])
        }
        
        return isTaken
    }
    
    static func checkIfConfirmationCodeMatches(email: String, code: String)throws -> Bool {
//        var error: NSError?
//        UIApplication.shared.isNetworkActivityIndicatorVisible = true
//        let result = AVCloud.callFunction(LeanEngineFunctions.nameOfCheckIfConfirmationCodeMatches, withParameters: ["email": email, "code": code], error: &error)
//        UIApplication.shared.isNetworkActivityIndicatorVisible = false
//        
//        if error != nil {
//            print(error!)
//            throw error!
//        }
//        
//        guard let isMatched = result as? Bool else {
//            print("failed to check if confirmation code match: cannot parse return value")
//            throw NSError(domain: USCFunErrorConstants.domain,
//                          code: USCFunErrorConstants.kUSCFunErrorLeanEngineResultsNotExpected,
//                          userInfo: [NSLocalizedDescriptionKey: "failed to check if confirmation code match: cannot parse return value"])
//        }
//        
//        return isMatched
        return true
    }
    
    static func requestConfirmationCode(email: String)throws {
        var error: NSError?
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        let result = AVCloud.callFunction(LeanEngineFunctions.nameOfRequestConfirmationCode, withParameters: ["email": email], error: &error)
        UIApplication.shared.isNetworkActivityIndicatorVisible = false

        if error != nil {
            print(error!)
            throw error!
        }
        
        guard let succeeded = result as? Bool, succeeded == true else {
            print("failed to request confirmation code: cannot parse return value")
            throw NSError(domain: USCFunErrorConstants.domain,
                          code: USCFunErrorConstants.kUSCFunErrorLeanEngineResultsNotExpected,
                          userInfo: [NSLocalizedDescriptionKey: "failed to request confirmation code: cannot parse return value"])
        }
    }
    
    static func createSystemConversationIfNotExists(email: String)throws {
        var error: NSError?
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        let result = AVCloud.callFunction(LeanEngineFunctions.nameOfCreateSystemConversationIfNotExists, withParameters: ["email": email], error: &error)
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        
        if error != nil {
            print(error!)
            throw error!
        }
        
        guard let succeeded = result as? Bool, succeeded == true else {
            print("failed to create system conversation: cannot parse return value")
            throw NSError(domain: USCFunErrorConstants.domain,
                          code: USCFunErrorConstants.kUSCFunErrorLeanEngineResultsNotExpected,
                          userInfo: [NSLocalizedDescriptionKey: "failed to create system conversation: cannot parse return value"])
        }
    }
    
    static func subscribeToSystemConversation(clientId: String, institution: String)throws {
        var error: NSError?
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        let result = AVCloud.callFunction(LeanEngineFunctions.nameOfSubscribeToSystemConversation, withParameters: ["clientId": clientId, "institution": institution], error: &error)
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        
        if error != nil {
            print(error!)
            throw error!
        }
        
        guard let succeeded = result as? Bool, succeeded == true else {
            print("failed to subscribe to system conversation: cannot parse return value")
            throw NSError(domain: USCFunErrorConstants.domain,
                          code: USCFunErrorConstants.kUSCFunErrorLeanEngineResultsNotExpected,
                          userInfo: [NSLocalizedDescriptionKey: "failed to subscribe to system conversation: cannot parse return value"])
        }
    }
    
    static func signUp()throws {
        
        guard let email = UserDefaults.newEmail, email.isValid else {
            throw NSError(domain: USCFunErrorConstants.domain,
                          code: USCFunErrorConstants.kUSCFunErrorInvalidEmail,
                          userInfo: [NSLocalizedDescriptionKey: "failed to sign up: invalid email"])
        }
        
        guard let password = LoginKit.password, password.characters.count >= USCFunConstants.minimumPasswordLength, !password.characters.contains(" ") else {
            throw NSError(domain: USCFunErrorConstants.domain,
                          code: USCFunErrorConstants.kUSCFunErrorInvalidPassword,
                          userInfo: [NSLocalizedDescriptionKey: "failed to sign up: invalid password"])
        }
        
        guard let nickname = UserDefaults.newNickname, !nickname.isWhitespaces else {
            throw NSError(domain: USCFunErrorConstants.domain,
                          code: USCFunErrorConstants.kUSCFunErrorInvalidNickname,
                          userInfo: [NSLocalizedDescriptionKey: "failed to sign up: invalid nickname"])
        }
        
        // create institution system conversation if not exist
        do {
            try createSystemConversationIfNotExists(email: email)
        } catch let error {
            throw error
        }
        
        // subscribe to institution system conversation
        do {
            try subscribeToSystemConversation(clientId: email.systemClientId!, institution: email.institutionCode ?? "unknown")
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
            throw NSError(domain: USCFunErrorConstants.domain,
                          code: USCFunErrorConstants.kUSCFunErrorCreateDefaultAvatarFailed,
                          userInfo: [NSLocalizedDescriptionKey: "failed to sign up: create default avatar failed"])
        }
        
        guard let data =  UIImagePNGRepresentation(avatar) else {
            throw NSError(domain: USCFunErrorConstants.domain,
                          code: USCFunErrorConstants.kUSCFunErrorUploadDefaultAvatarFailed,
                          userInfo: [NSLocalizedDescriptionKey: "failed to sign up: upload default avatar failed"])
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
                throw error!
            }
        } else {
            throw NSError(domain: USCFunErrorConstants.domain,
                          code: USCFunErrorConstants.kUSCFunErrorUploadDefaultAvatarFailed,
                          userInfo: [NSLocalizedDescriptionKey: "failed to sign up: upload default avatar failed"])
        }
    }
    
    static func signIn(email: String, password: String, handler: @escaping (_ succeed: Bool, _ error: NSError?) -> Void) {
        
        AVUser.logInWithUsername(inBackground: email, password: password) {
            updatedUser, error in
            
            if updatedUser != nil {
               
                guard let nickname = updatedUser?.value(forKey: UserKeyConstants.keyOfNickname) as? String else {
                    handler(false, NSError(domain: USCFunErrorConstants.domain, code: USCFunErrorConstants.kUSCFunErrorUserNicknameMissing, userInfo: [NSLocalizedDescriptionKey: "failed to sign in: nickname is missing"]))
                    return
                }
                
                guard let avatarUrl = updatedUser!.value(forKey: UserKeyConstants.keyOfAvatarUrl) as? String else {
                    handler(false, NSError(domain: USCFunErrorConstants.domain, code: USCFunErrorConstants.kUSCFunErrorUserAvatarMissing, userInfo: [NSLocalizedDescriptionKey: "failed to sign in: avatar is missing"]))
                        return
                }
                
                let file = AVFile(url: avatarUrl)
                var avatarError: NSError?
                guard let avatarData = file.getData(&avatarError) else {
                    handler(false, NSError(domain: USCFunErrorConstants.domain, code: USCFunErrorConstants.kUSCFunErrorUserAvatarMissing, userInfo: [NSLocalizedDescriptionKey: avatarError!.localizedDescription]))
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
                handler(false, error as NSError?)
            }
        }
    }
    
    static func signOut() {
        UserDefaults.hasLoggedIn = false
        UserDefaults.hasPreloadedMyOngoingEvents = false
        UserDefaults.hasPreloadedPublicEvents = false
        EventRequest.removeAllEvents(for: .myongoing, handler: nil)
        EventRequest.removeAllEvents(for: .mypublic, handler: nil)
        
        LCChatKit.sharedInstance().close() {
            succeed, error in
            if succeed {
                print("LCChatKit closed successfully")
            }
            else if error != nil {
                print("failed to close LCChatKit \(error!)")
            }
        }
        
        LoginKit.systemNotificationClient?.close {
            succeed, error in
            if succeed {
                print("system client closed successfully")
            }
            else if error != nil {
                print("failed to close system client \(error!)")
            }
        }
        
        let appDelegate = UIApplication.shared.delegate! as! AppDelegate
        let initialViewController = UIStoryboard(name: "Login", bundle: nil).instantiateInitialViewController()
        appDelegate.window?.rootViewController = initialViewController
        appDelegate.window?.makeKeyAndVisible()
    }
}
