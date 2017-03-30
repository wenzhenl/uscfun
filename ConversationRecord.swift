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
    static func parseConversationRecords() -> [String: ConversationRecord]? {
        
        guard let plist = Plist(name: "ConversationRecord") else { return nil }
        guard let conversationData = plist.getValuesInPlistFile() as? [[String: Any]] else { return nil }
        var results = [String: ConversationRecord]()
        for record in conversationData {
            let conversationId = record[keyOfConversationId] as! String
            let eventId = record[keyOfEventId] as! String
            let latestMessage = record[keyOfLatestMessage] as! String?
            let isUnread = record[keyOfIsUnread] as! Bool
            
            results[conversationId] = ConversationRecord(conversationId: conversationId, eventId: eventId, latestMessage: latestMessage, isUnread: isUnread)
        }
        return results
    }
    
    static func addRecord(conversationId: String, eventId: String, latestMessage: String?, isUnread: Bool = false)throws {
        guard let plist = Plist(name: "ConversationRecord") else {
            print("cannot get plist file")
            return
        }
        guard let records = plist.getMutablePlistFile() else {
            print("cannot get mutable plist file")
            return
        }
        var record = [String: Any]()
        record[keyOfConversationId] = conversationId
        record[keyOfEventId] = eventId
        record[keyOfLatestMessage] = latestMessage
        record[keyOfIsUnread] = isUnread
        
        records.add(NSDictionary(dictionary: record))
        
        do {
            try plist.addValuesToPlistFile(array: records)
        } catch let error {
            throw error
        }
    }
    
    static let keyOfConversationId = "conversationId"
    static let keyOfEventId = "eventId"
    static let keyOfLatestMessage = "latestMessage"
    static let keyOfIsUnread = "isUnread"
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
    
    func getValuesInPlistFile() -> NSArray? {
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: destPath!) {
            guard let arr = NSArray(contentsOfFile: destPath!) else { return nil }
            return arr
        } else {
            return nil
        }
    }
    
    func getMutablePlistFile() -> NSMutableArray? {
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: destPath!) {
            guard let arr = NSMutableArray(contentsOfFile: destPath!) else { return nil }
            return arr
        } else {
            return nil
        }
    }
    
    func addValuesToPlistFile(array:NSArray)throws {
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: destPath!) {
            if !array.write(toFile: destPath!, atomically: false) {
                print("File not written successfully")
                throw PlistError.FileNotWritten
            }
        } else {
            throw PlistError.FileDoesNotExist
        }
    }
}
