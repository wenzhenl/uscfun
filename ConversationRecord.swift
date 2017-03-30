//
//  ConversationRecord.swift
//  uscfun
//
//  Created by Wenzheng Li on 3/30/17.
//  Copyright © 2017 Wenzheng Li. All rights reserved.
//

import Foundation

struct ConversationRecord {
    var conversationId: String
    var eventId: String
    var latestMessage: String?
    var isUnread: Bool
}

struct ConversationList {
    fileprivate static func parseConversationRecords() -> [String: ConversationRecord] {
        let filePath = Bundle.main.path(forResource: "ConversationRecord", ofType: "plist")!
        let dictionary = NSDictionary(contentsOfFile: filePath)!
        let conversationData = dictionary["Conversations"] as! [[String: Any]]
        
        var results = [String: ConversationRecord]()
        for record in conversationData {
            let conversationId = record["conversationId"] as! String
            let eventId = record["eventId"] as! String
            let latestMessage = record["latestMessage"] as! String?
            let isUnread = record["isUnread"] as! Bool
            
            results[conversationId] = ConversationRecord(conversationId: conversationId, eventId: eventId, latestMessage: latestMessage, isUnread: isUnread)
        }
        return results
    }
}
