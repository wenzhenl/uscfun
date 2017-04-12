//
//  LeanCloudExtension.swift
//  uscfun
//
//  Created by Wenzheng Li on 3/30/17.
//  Copyright © 2017 Wenzheng Li. All rights reserved.
//

import Foundation
import AVOSCloud

enum MessageMediaType: Int {
    case plain = -1
    case image = -2
    case audio = -3
    case video = -4
    case geolocation = -5
    case file = -6
}

enum SystemNotificationType: Int {
    case urgentMessage = 0
    case eventCreated = 1
    case eventUpdated = 2
    case newVersionReleased = 3
}

struct LeanEngineFunctions {
    static let nameOfCheckIfEmailIsTaken = "checkIfEmailIsTaken"
    static let nameOfRequestConfirmationCode = "requestConfirmationCode"
    static let nameOfCheckIfConfirmationCodeMatches = "checkIfConfirmationCodeMatches"
    static let nameOfCreateSystemConversationIfNotExists = "createSystemConversationIfNotExists"
    static let nameOfSubscribeToSystemConversation = "subscribeToSystemConversation"
    static let nameOfJoinConversation = "joinConversation"
    static let nameOfQuitConversation = "quitConversation"
    static let nameOfMuteConversation = "muteConversation"
    static let nameOfUnmuteConversation = "unmuteConversation"
    static let nameOfCheckIfMutedInConversation = "isMutedInConversation"
}

class LeanEngine {
    static func joinConversation(clientId: String, conversationId: String, handler: ((_ succeeded: Bool, _ error: NSError?) -> Void)?) {
        AVCloud.callFunction(inBackground: LeanEngineFunctions.nameOfJoinConversation, withParameters: ["clientId": clientId, "conversationId": conversationId]) {
            result, error in
            if let succeeded = result as? Bool, succeeded == true {
                handler?(true, nil)
                return
            }
            if error != nil {
                handler?(false, error as NSError?)
            }
        }
    }
    
    static func quitConversation(clientId: String, conversationId: String, handler: ((_ succeeded: Bool, _ error: NSError?) -> Void)?) {
        AVCloud.callFunction(inBackground: LeanEngineFunctions.nameOfQuitConversation, withParameters: ["clientId": clientId, "conversationId": conversationId]) {
            result, error in
            if let succeeded = result as? Bool, succeeded == true {
                handler?(true, nil)
                return
            }
            if error != nil {
                handler?(false, error as NSError?)
            }
        }
    }
    
    static func muteConversation(clientId: String, conversationId: String, handler: ((_ succeeded: Bool, _ error: NSError?) -> Void)?) {
        AVCloud.callFunction(inBackground: LeanEngineFunctions.nameOfMuteConversation, withParameters: ["clientId": clientId, "conversationId": conversationId]) {
            result, error in
            if let succeeded = result as? Bool, succeeded == true {
                handler?(true, nil)
                return
            }
            if error != nil {
                handler?(false, error as NSError?)
            }
        }
    }
    
    static func unmuteConversation(clientId: String, conversationId: String, handler: ((_ succeeded: Bool, _ error: NSError?) -> Void)?) {
        AVCloud.callFunction(inBackground: LeanEngineFunctions.nameOfUnmuteConversation, withParameters: ["clientId": clientId, "conversationId": conversationId]) {
            result, error in
            if let succeeded = result as? Bool, succeeded == true {
                handler?(true, nil)
                return
            }
            if error != nil {
                handler?(false, error as NSError?)
            }
        }
    }
    
    static func isMutedInConversation(clientId: String, conversationId: String)throws -> Bool {
        var error: NSError?
        let result = AVCloud.callFunction(LeanEngineFunctions.nameOfCheckIfMutedInConversation, withParameters: ["clientId": clientId, "conversationId": conversationId], error: &error)
        if error != nil {
            throw error!
        }
        
        guard let isMuted = result as? Bool else {
            print("cannot parse check if muted in conversation return value")
            throw NSError(domain: USCFunErrorConstants.domain, code: USCFunErrorConstants.kUSCFunErrorCannotParseLeanEnginResult, userInfo: nil)
        }
        
        return isMuted
    }
}
