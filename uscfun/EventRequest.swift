//
//  EventRequest.swift
//  uscfun
//
//  Created by Wenzheng Li on 10/13/16.
//  Copyright © 2016 Wenzheng Li. All rights reserved.
//

import Foundation
import AVOSCloud

class EventRequest {
    
    static var myEvents = [Event]()
    static var events = [Event]()
    static var indexOfMyEvents = [String: Int]()
    static var indexOfEvents = [String: Int]()
    static var newestUpdatedAt = Date(timeIntervalSince1970: 0)
    static var oldestUpdatedAt = Date(timeIntervalSinceNow: 60*60*24*365*100)
    
    static func handleLoadedData(error: Error?, events: [Event]?) {
        if error != nil {
            print(error)
            return
        }
        if let events = events {
            for event in events {
                if event.active {
                    if let index = EventRequest.indexOfEvents[event.objectId!] {
                        EventRequest.events[index] = event
                    } else {
                        EventRequest.events.append(event)
                        EventRequest.indexOfEvents[event.objectId!] = EventRequest.events.count - 1
                    }
                }
                
                if event.members.contains(AVUser.current()) {
                    if let index = EventRequest.indexOfMyEvents[event.objectId!] {
                        EventRequest.myEvents[index] = event
                    } else {
                        EventRequest.myEvents.append(event)
                        EventRequest.indexOfMyEvents[event.objectId!] = EventRequest.myEvents.count - 1
                    }
                }
                if event.updatedAt! > EventRequest.newestUpdatedAt {
                    EventRequest.newestUpdatedAt = event.updatedAt!
                }
                if event.updatedAt! < EventRequest.oldestUpdatedAt {
                    EventRequest.oldestUpdatedAt = event.updatedAt!
                }
            }
        }
    }
    
    static func preLoadData() {
        EventRequest.fetch(handler: EventRequest.handleLoadedData)
    }
    
    static func fetch(handler: @escaping (_ error: Error?, _ results: [Event]?) -> Void) {
        if let query = AVQuery(className: EventKeyConstants.classNameOfEvent) {
            query.order(byDescending: EventKeyConstants.keyOfDue)
            query.includeKey(EventKeyConstants.keyOfCreator)
            query.includeKey(EventKeyConstants.keyOfMembers)
            query.whereKey(EventKeyConstants.keyOfSchool, equalTo: USCFunConstants.nameOfUSC)
            query.whereKey(EventKeyConstants.keyOfFinished, equalTo: false)
            query.cachePolicy = .networkElseCache
            query.maxCacheAge = 24*3600
            if let objects = query.findObjects() {
                var newerEvents = [Event]()
                for object in objects as! [AVObject] {
                    if let event = Event(data: object) {
                        newerEvents.append(event)
                    }
                }
                handler(nil, newerEvents)
            }
        }
    }
    
    static func fetchInBackground(handler: @escaping (_ error: Error?, _ results: [Event]?) -> Void) {
        if let query = AVQuery(className: EventKeyConstants.classNameOfEvent) {
            query.order(byDescending: EventKeyConstants.keyOfDue)
            query.includeKey(EventKeyConstants.keyOfCreator)
            query.includeKey(EventKeyConstants.keyOfMembers)
            query.whereKey(EventKeyConstants.keyOfSchool, equalTo: USCFunConstants.nameOfUSC)
            query.whereKey(EventKeyConstants.keyOfFinished, equalTo: false)
            query.cachePolicy = .networkElseCache
            query.maxCacheAge = 24*3600
            query.findObjectsInBackground() {
                objects, error in
                if error != nil {
                    print(error!.localizedDescription)
                    handler(error!, nil)
                    return
                }
                if objects != nil {
                    var newerEvents = [Event]()
                    for object in objects as! [AVObject] {
                        if let event = Event(data: object) {
                            newerEvents.append(event)
                        }
                    }
                    handler(nil, newerEvents)
                }
            }
        }
    }
    
    static func fetchNewer(currentlyNewestUpdatedTime: Date, handler: @escaping (_ error: Error?, _ results: [Event]?) -> Void) {
        if let query = AVQuery(className: EventKeyConstants.classNameOfEvent) {
            query.order(byDescending: EventKeyConstants.keyOfDue)
            query.includeKey(EventKeyConstants.keyOfCreator)
            query.includeKey(EventKeyConstants.keyOfMembers)
            query.whereKey(EventKeyConstants.keyOfSchool, equalTo: USCFunConstants.nameOfUSC)
            query.whereKey(EventKeyConstants.keyOfFinished, equalTo: false)
            query.cachePolicy = .networkElseCache
            query.maxCacheAge = 24*3600
            query.whereKey(EventKeyConstants.keyOfUpdatedAt, greaterThan: currentlyNewestUpdatedTime)
            query.findObjectsInBackground() {
                objects, error in
                if error != nil {
                    print(error!.localizedDescription)
                    handler(error!, nil)
                    return
                }
                if objects != nil {
                    var newerEvents = [Event]()
                    for object in objects as! [AVObject] {
                        if let event = Event(data: object) {
                            newerEvents.append(event)
                        }
                    }
                    handler(nil, newerEvents)
                }
            }
        }
    }
    
    static func fetchOlder(currentlyOldestUpdatedTime: Date, handler: @escaping (_ error: Error?, _ results: [Event]?) -> Void) {
        if let query = AVQuery(className: EventKeyConstants.classNameOfEvent) {
            query.order(byDescending: EventKeyConstants.keyOfDue)
            query.includeKey(EventKeyConstants.keyOfCreator)
            query.includeKey(EventKeyConstants.keyOfMembers)
            query.whereKey(EventKeyConstants.keyOfSchool, equalTo: USCFunConstants.nameOfUSC)
            query.whereKey(EventKeyConstants.keyOfFinished, equalTo: false)
            query.cachePolicy = .networkElseCache
            query.maxCacheAge = 24*3600
            query.whereKey(EventKeyConstants.keyOfUpdatedAt, lessThan: currentlyOldestUpdatedTime)
            query.findObjectsInBackground() {
                objects, error in
                if error != nil {
                    print(error!.localizedDescription)
                    handler(error!, nil)
                    return
                }
                if objects != nil {
                    var newerEvents = [Event]()
                    for object in objects as! [AVObject] {
                        if let event = Event(data: object) {
                            newerEvents.append(event)
                        }
                    }
                    handler(nil, newerEvents)
                }
            }
        }
    }
}
