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
    
    static var myOngoingEvents = [Event]()
    static var indexOfMyOngoingEvents = [String: Event]()
    static var newestUpdatedAtOfMyOngoingEvents = Date(timeIntervalSince1970: 0)
    static var oldestUpdatedAtOfMyOngoingEvents = Date(timeIntervalSinceNow: 60*60*24*365*100)

    static var publicEvents = [Event]()
    static var indexOfPublicEvents = [String: Event]()
    static var newestUpdatedAtOfPublicEvents = Date(timeIntervalSince1970: 0)
    static var oldestUpdatedAtOfPublicEvents = Date(timeIntervalSinceNow: 60*60*24*365*100)
    
    static func preLoadData() {
        EventRequest.fetchDataForMyOngoingEvents(handler: EventRequest.handleLoadedDataOfMyOngoingEvents)
        EventRequest.fetchDataForPublicEvents(handler: EventRequest.handleLoadedDataOfPublicEvents)
    }
    
    static func handleLoadedDataOfMyOngoingEvents(error: Error?, events: [Event]?) {
        print("fetch my ongoing events")
        if error != nil {
            print(error!)
            return
        }
        if let events = events {
            for event in events {
                EventRequest.indexOfMyOngoingEvents[event.objectId!] = event
                
                if event.updatedAt! > EventRequest.newestUpdatedAtOfMyOngoingEvents {
                    EventRequest.newestUpdatedAtOfMyOngoingEvents = event.updatedAt!
                }
                if event.updatedAt! < EventRequest.oldestUpdatedAtOfMyOngoingEvents {
                    EventRequest.oldestUpdatedAtOfMyOngoingEvents = event.updatedAt!
                }
            }
            if events.count > 0 {
                EventRequest.myOngoingEvents = EventRequest.indexOfMyOngoingEvents.values.sorted {
                    if $0.finalized != $1.finalized {
                        return $0.finalized
                    }
                    return $0.due < $1.due
                }
            }
        }
    }
    
    static func handleLoadedDataOfPublicEvents(error: Error?, events: [Event]?) {
        print("fetch public events")
        if error != nil {
            print(error!)
            return
        }
        if let events = events {
            for event in events {
                EventRequest.indexOfPublicEvents[event.objectId!] = event
                EventRequest.publicEvents.append(event)
                
                if event.updatedAt! > EventRequest.newestUpdatedAtOfPublicEvents {
                    EventRequest.newestUpdatedAtOfPublicEvents = event.updatedAt!
                }
                if event.updatedAt! < EventRequest.oldestUpdatedAtOfPublicEvents {
                    EventRequest.oldestUpdatedAtOfPublicEvents = event.updatedAt!
                }
            }
        }
    }
    
    static func fetchDataForMyOngoingEvents(handler: @escaping (_ error: Error?, _ results: [Event]?) -> Void) {
        if let query = AVQuery(className: EventKeyConstants.classNameOfEvent) {
            query.order(byDescending: EventKeyConstants.keyOfFinalized)
            query.order(byAscending: EventKeyConstants.keyOfDue)
            query.includeKey(EventKeyConstants.keyOfCreator)
            query.includeKey(EventKeyConstants.keyOfMembers)
            query.whereKey(EventKeyConstants.keyOfMembers, containsAllObjectsIn: [AVUser.current()])
            query.whereKey(EventKeyConstants.keyOfSchool, equalTo: USCFunConstants.nameOfSchool)
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
    
    static func fetchNewerDataForMyOngoingEvents(currentlyNewestUpdatedTime: Date, handler: @escaping (_ error: Error?, _ results: [Event]?) -> Void) {
        if let query = AVQuery(className: EventKeyConstants.classNameOfEvent) {
            query.order(byDescending: EventKeyConstants.keyOfFinalized)
            query.order(byAscending: EventKeyConstants.keyOfDue)
            query.includeKey(EventKeyConstants.keyOfCreator)
            query.includeKey(EventKeyConstants.keyOfMembers)
            query.whereKey(EventKeyConstants.keyOfMembers, containsAllObjectsIn: [AVUser.current()])
            query.whereKey(EventKeyConstants.keyOfSchool, equalTo: USCFunConstants.nameOfSchool)
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
    
    static func fetchOlderDataForMyOngoingEvents(currentlyOldestUpdatedTime: Date, handler: @escaping (_ error: Error?, _ results: [Event]?) -> Void) {
        if let query = AVQuery(className: EventKeyConstants.classNameOfEvent) {
            query.order(byDescending: EventKeyConstants.keyOfFinalized)
            query.order(byAscending: EventKeyConstants.keyOfDue)
            query.includeKey(EventKeyConstants.keyOfCreator)
            query.includeKey(EventKeyConstants.keyOfMembers)
            query.whereKey(EventKeyConstants.keyOfMembers, containsAllObjectsIn: [AVUser.current()])
            query.whereKey(EventKeyConstants.keyOfSchool, equalTo: USCFunConstants.nameOfSchool)
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
    
    static func fetchDataForPublicEvents(handler: @escaping (_ error: Error?, _ results: [Event]?) -> Void) {
        if let query = AVQuery(className: EventKeyConstants.classNameOfEvent) {
            query.order(byAscending: EventKeyConstants.keyOfDue)
            query.includeKey(EventKeyConstants.keyOfCreator)
            query.includeKey(EventKeyConstants.keyOfMembers)
            query.whereKey(EventKeyConstants.keyOfSchool, equalTo: USCFunConstants.nameOfSchool)
            query.whereKey(EventKeyConstants.keyOfFinalized, equalTo: false)
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
    
    static func fetchNewerDataForPublicEvents(currentlyNewestUpdatedTime: Date, handler: @escaping (_ error: Error?, _ results: [Event]?) -> Void) {
        if let query = AVQuery(className: EventKeyConstants.classNameOfEvent) {
            query.order(byAscending: EventKeyConstants.keyOfDue)
            query.includeKey(EventKeyConstants.keyOfCreator)
            query.includeKey(EventKeyConstants.keyOfMembers)
            query.whereKey(EventKeyConstants.keyOfSchool, equalTo: USCFunConstants.nameOfSchool)
            query.whereKey(EventKeyConstants.keyOfFinalized, equalTo: false)
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
    
    static func fetchOlderDataForPublicEvents(currentlyOldestUpdatedTime: Date, handler: @escaping (_ error: Error?, _ results: [Event]?) -> Void) {
        if let query = AVQuery(className: EventKeyConstants.classNameOfEvent) {
            query.order(byAscending: EventKeyConstants.keyOfDue)
            query.includeKey(EventKeyConstants.keyOfCreator)
            query.includeKey(EventKeyConstants.keyOfMembers)
            query.whereKey(EventKeyConstants.keyOfSchool, equalTo: USCFunConstants.nameOfSchool)
            query.whereKey(EventKeyConstants.keyOfFinalized, equalTo: false)
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
