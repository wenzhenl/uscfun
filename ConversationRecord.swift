//
//  ConversationRecord.swift
//  uscfun
//
//  Created by Wenzheng Li on 3/30/17.
//  Copyright © 2017 Wenzheng Li. All rights reserved.
//

import Foundation

struct ConversationRecord {
    var eventId: String
    var latestMessage: String?
    var isUnread: Bool
    var lastUpdatedAt: Int64?
}

struct ConversationList {
    static func parseConversationRecords() -> [String: ConversationRecord]? {
        
        guard let plist = Plist(name: "ConversationRecord") else { return nil }
        guard let conversationList = plist.getValuesInPlistFile() as? [String: [String: Any]] else { return nil }
        
        var results = [String: ConversationRecord]()
        
        for (conversationId, conversation) in conversationList {
            let eventId = conversation[keyOfEventId] as! String
            let latestMessage = conversation[keyOfLatestMessage] as! String?
            let isUnread = conversation[keyOfIsUnread] as! Bool
            let lastUpdatedAt = conversation[keyOfLastUpdatedAt] as! Int64?
            results[conversationId] = ConversationRecord(eventId: eventId, latestMessage: latestMessage, isUnread: isUnread, lastUpdatedAt: lastUpdatedAt)
        }
        
        return results
    }
    
    static func addRecord(conversationId: String, record: ConversationRecord)throws {
        guard let plist = Plist(name: "ConversationRecord") else {
            print("cannot get plist file")
            return
        }
        guard let records = plist.getMutablePlistFile() else {
            print("cannot get mutable plist file")
            return
        }
        var recordValue = [String: Any]()
        recordValue[keyOfEventId] = record.eventId
        recordValue[keyOfLatestMessage] = record.latestMessage
        recordValue[keyOfIsUnread] = record.isUnread
        recordValue[keyOfLastUpdatedAt] = record.lastUpdatedAt
        records[conversationId] = recordValue
        
        do {
            try plist.addValuesToPlistFile(dictionary: records)
        } catch let error {
            throw error
        }
    }
    
    static let keyOfConversationId = "conversationId"
    static let keyOfEventId = "eventId"
    static let keyOfLatestMessage = "latestMessage"
    static let keyOfIsUnread = "isUnread"
    static let keyOfLastUpdatedAt = "lastUpdatedAt"
}

struct Plist {
    enum PlistError: Error {
        case FileNotWritten
        case FileDoesNotExist
    }
    
    let name:String
    
    var sourcePath: String? {
        guard let path = Bundle.main.path(forResource: name, ofType: "plist") else { return nil}
        return path
    }
    
    var destPath:String? {
        guard sourcePath != nil else { return nil }
        let dir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        return (dir as NSString).appendingPathComponent("\(name).plist")
    }
    
    init?(name:String) {
        self.name = name
        
        let fileManager = FileManager.default
        
        guard let source = sourcePath else { return nil }
        guard let destination = destPath else { return nil }
        guard fileManager.fileExists(atPath: source) else { return nil }
        
        if !fileManager.fileExists(atPath: destination) {
            do {
                try fileManager.copyItem(atPath: source, toPath: destination)
            } catch let error as NSError {
                print("Unable to copy file. ERROR: \(error.localizedDescription)")
                return nil
            }
        }
    }
    
    func getValuesInPlistFile() -> NSDictionary? {
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: destPath!) {
            guard let dictionary = NSDictionary(contentsOfFile: destPath!) else { return nil }
            return dictionary
        } else {
            return nil
        }
    }
    
    func getMutablePlistFile() -> NSMutableDictionary? {
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: destPath!) {
            guard let dictionary = NSMutableDictionary(contentsOfFile: destPath!) else { return nil }
            return dictionary
        } else {
            return nil
        }
    }
    
    func addValuesToPlistFile(dictionary: NSDictionary)throws {
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: destPath!) {
            if !dictionary.write(toFile: destPath!, atomically: false) {
                print("File not written successfully")
                throw PlistError.FileNotWritten
            }
        } else {
            throw PlistError.FileDoesNotExist
        }
    }
}
