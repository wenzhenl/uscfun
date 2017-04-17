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
    static let nameOfCheckIfMutedInConversation = "isMutedInConversation"
    
    static let nameOfFetchOverallRating = "fetchOverallRating"
}

class LeanEngine {
    
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
    
    static func fetchOverallRating(of userId: String)throws -> Double {
        var error: NSError?
        let result = AVCloud.callFunction(LeanEngineFunctions.nameOfFetchOverallRating, withParameters: ["userId": userId], error: &error)
        if error != nil {
            print("failed to fetch overall rating: \(error!)")
            throw error!
        }
        
        guard let overallRating = result as? Double else {
            print("cannot parse fetch overall rating return value")
            throw NSError(domain: USCFunErrorConstants.domain, code: USCFunErrorConstants.kUSCFunErrorCannotParseLeanEnginResult, userInfo: nil)
        }
        return overallRating
    }
}
