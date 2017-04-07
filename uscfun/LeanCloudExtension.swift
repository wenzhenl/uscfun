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
}
