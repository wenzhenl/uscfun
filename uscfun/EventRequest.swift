//
//  EventRequest.swift
//  uscfun
//
//  Created by Wenzheng Li on 10/13/16.
//  Copyright © 2016 Wenzheng Li. All rights reserved.
//

import Foundation
import AVOSCloud

/// possible errors with event
enum EventRequestError: Error {
    case systemError(localizedDescriotion: String, debugDescription: String)
}

extension EventRequestError: LocalizedError {
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

class EventRequest {
    
    static var myOngoingEvents = OrderedDictionary<String, Event>()
    static var newestUpdatedAtOfMyOngoingEvents = timeOf1970
    static var oldestUpdatedAtOfMyOngoingEvents = timeOf2070

    static var publicEvents = OrderedDictionary<String, Event>()
    static var newestUpdatedAtOfPublicEvents = timeOf1970
    static var oldestUpdatedAtOfPublicEvents = timeOf2070
    
    static let timeOf1970 = Date(timeIntervalSince1970: 0)
    static let timeOf2070 = Date(timeIntervalSince1970: 60*60*24*365*100)
    
    static func preLoadData() {
        EventRequest.fetchNewerMyOngoingEvents(inBackground: false, currentNewestUpdatedTime: timeOf1970, handler: nil)
        EventRequest.fetchNewerPublicEvents(inBackground: false, currentNewestUpdatedTime: timeOf1970, handler: nil)
    }
    
    //--MARK: functions for fetch public events
    
    static func fetchNewerPublicEvents() {
        fetchNewerPublicEvents(inBackground: false, currentNewestUpdatedTime: EventRequest.newestUpdatedAtOfPublicEvents, handler: nil)
    }
    
    static func fetchNewerPublicEvents(handler: ((_ succeeded: Bool, _ error: Error?) -> Void)?) {
        fetchNewerPublicEvents(inBackground: false, currentNewestUpdatedTime: EventRequest.newestUpdatedAtOfPublicEvents, handler: handler)
    }
    
    static func fetchNewerPublicEventsInBackground(handler: ((_ succeeded: Bool, _ error: Error?) -> Void)?) {
        fetchNewerPublicEvents(inBackground: true, currentNewestUpdatedTime: EventRequest.newestUpdatedAtOfPublicEvents, handler: handler)
    }
    
    static func fetchNewerPublicEvents(inBackground: Bool, currentNewestUpdatedTime: Date, handler: ((_ succeeded: Bool, _ error: Error?) -> Void)?) {
        guard let query = AVQuery(className: EventKeyConstants.classNameOfEvent) else {
            handler?(false, EventRequestError.systemError(localizedDescriotion: "网络错误，无法加载数据", debugDescription: "cannot create query"))
            return
        }
        query.order(byAscending: EventKeyConstants.keyOfDue)
        query.includeKey(EventKeyConstants.keyOfCreator)
        query.includeKey(EventKeyConstants.keyOfMembers)
        query.whereKey(EventKeyConstants.keyOfSchool, equalTo: USCFunConstants.nameOfSchool)
        query.whereKey(EventKeyConstants.keyOfUpdatedAt, greaterThan: currentNewestUpdatedTime)
        
        /// define events must be still pending
        query.whereKey(EventKeyConstants.keyOfDue, greaterThan: Date().timeIntervalSince1970)
        query.whereKey(EventKeyConstants.keyOfRemainingSeats, greaterThan: 0)

        query.cachePolicy = .networkElseCache
        query.maxCacheAge = 24*3600
        
        fetchPublicEvents(inBackground: inBackground, with: query) {
            succeeded, error in
            handler?(succeeded, error)
        }
    }
    
    static func fetchOlderPublicEvents() {
        fetchOlderPublicEvents(inBackground: false, currentOldestUpdatedTime: EventRequest.oldestUpdatedAtOfPublicEvents, handler: nil)
    }
    
    static func fetchOlderPublicEvents(handler: ((_ succeeded: Bool, _ error: Error?) -> Void)?) {
        fetchOlderPublicEvents(inBackground: false, currentOldestUpdatedTime: EventRequest.oldestUpdatedAtOfPublicEvents, handler: handler)
    }
    
    static func fetchOlderPublicEventsInBackground(handler: ((_ succeeded: Bool, _ error: Error?) -> Void)?) {
        fetchOlderPublicEvents(inBackground: true, currentOldestUpdatedTime: EventRequest.oldestUpdatedAtOfPublicEvents, handler: handler)
    }
    
    static func fetchOlderPublicEvents(inBackground: Bool, currentOldestUpdatedTime: Date, handler: ((_ succeeded: Bool, _ error: Error?) -> Void)?) {
        guard let query = AVQuery(className: EventKeyConstants.classNameOfEvent) else {
            handler?(false, EventRequestError.systemError(localizedDescriotion: "网络错误，无法加载数据", debugDescription: "cannot create query"))
            return
        }
        query.order(byAscending: EventKeyConstants.keyOfDue)
        query.includeKey(EventKeyConstants.keyOfCreator)
        query.includeKey(EventKeyConstants.keyOfMembers)
        query.whereKey(EventKeyConstants.keyOfSchool, equalTo: USCFunConstants.nameOfSchool)
        query.whereKey(EventKeyConstants.keyOfUpdatedAt, lessThan: currentOldestUpdatedTime)
        
        /// define events must be still pending
        query.whereKey(EventKeyConstants.keyOfDue, greaterThan: Date().timeIntervalSince1970)
        query.whereKey(EventKeyConstants.keyOfRemainingSeats, greaterThan: 0)
        
        query.cachePolicy = .networkElseCache
        query.maxCacheAge = 24*3600
        
        fetchPublicEvents(inBackground: inBackground, with: query) {
            succeeded, error in
            handler?(succeeded, error)
        }
    }
    
    //--MARK: functions for fetch my ongoing events
    
    static func fetchNewerMyOngoingEvents() {
        fetchNewerMyOngoingEvents(inBackground: false, currentNewestUpdatedTime: EventRequest.newestUpdatedAtOfMyOngoingEvents, handler: nil)
    }
    
    static func fetchNewerMyOngoingEvents(handler: ((_ succeeded: Bool, _ error: Error?) -> Void)?) {
        fetchNewerMyOngoingEvents(inBackground: false, currentNewestUpdatedTime: EventRequest.newestUpdatedAtOfMyOngoingEvents, handler: handler)
    }
    
    static func fetchNewerMyOngoingEventsInBackground(handler: ((_ succeeded: Bool, _ error: Error?) -> Void)?) {
        fetchNewerMyOngoingEvents(inBackground: true, currentNewestUpdatedTime: EventRequest.newestUpdatedAtOfMyOngoingEvents, handler: handler)
    }
    
    static func fetchNewerMyOngoingEvents(inBackground: Bool, currentNewestUpdatedTime: Date, handler: ((_ succeeded: Bool, _ error: Error?) -> Void)?) {
        guard let query = AVQuery(className: EventKeyConstants.classNameOfEvent) else {
            handler?(false, EventRequestError.systemError(localizedDescriotion: "网络错误，无法加载数据", debugDescription: "cannot create query"))
            return
        }
        query.order(byAscending: EventKeyConstants.keyOfDue)
        query.includeKey(EventKeyConstants.keyOfCreator)
        query.includeKey(EventKeyConstants.keyOfMembers)
        query.whereKey(EventKeyConstants.keyOfSchool, equalTo: USCFunConstants.nameOfSchool)
        query.whereKey(EventKeyConstants.keyOfUpdatedAt, greaterThan: currentNewestUpdatedTime)
        
        /// define events must be not completed or cancelled
        query.whereKey(EventKeyConstants.keyOfCompleted, equalTo: false)
        query.whereKey(EventKeyConstants.keyOfCancelled, equalTo: false)
        
        /// define events must be mine
        query.whereKey(EventKeyConstants.keyOfMembers, containsAllObjectsIn: [AVUser.current()])
        
        query.cachePolicy = .networkElseCache
        query.maxCacheAge = 24*3600
        
        fetchMyOngoingEvents(inBackground: inBackground, with: query) {
            succeeded, error in
            handler?(succeeded, error)
        }
    }
    
    static func fetchOlderMyOngoingEvents() {
        fetchOlderMyOngoingEvents(inBackground: false, currentOldestUpdatedTime: EventRequest.oldestUpdatedAtOfMyOngoingEvents, handler: nil)
    }
    
    static func fetchOlderMyOngoingEvents(handler: ((_ succeeded: Bool, _ error: Error?) -> Void)?) {
        fetchOlderMyOngoingEvents(inBackground: false, currentOldestUpdatedTime: EventRequest.oldestUpdatedAtOfMyOngoingEvents, handler: handler)
    }
    
    static func fetchOlderMyOngoingEventsInBackground(handler: ((_ succeeded: Bool, _ error: Error?) -> Void)?) {
        fetchOlderMyOngoingEvents(inBackground: true, currentOldestUpdatedTime: EventRequest.oldestUpdatedAtOfMyOngoingEvents, handler: handler)
    }
    
    static func fetchOlderMyOngoingEvents(inBackground: Bool, currentOldestUpdatedTime: Date, handler: ((_ succeeded: Bool, _ error: Error?) -> Void)?) {
        guard let query = AVQuery(className: EventKeyConstants.classNameOfEvent) else {
            handler?(false, EventRequestError.systemError(localizedDescriotion: "网络错误，无法加载数据", debugDescription: "cannot create query"))
            return
        }
        query.order(byAscending: EventKeyConstants.keyOfDue)
        query.includeKey(EventKeyConstants.keyOfCreator)
        query.includeKey(EventKeyConstants.keyOfMembers)
        query.whereKey(EventKeyConstants.keyOfSchool, equalTo: USCFunConstants.nameOfSchool)
        query.whereKey(EventKeyConstants.keyOfUpdatedAt, lessThan: currentOldestUpdatedTime)
        
        /// define events must be not completed or cancelled
        query.whereKey(EventKeyConstants.keyOfCompleted, equalTo: false)
        query.whereKey(EventKeyConstants.keyOfCancelled, equalTo: false)
        
        /// define events must be mine
        query.whereKey(EventKeyConstants.keyOfMembers, containsAllObjectsIn: [AVUser.current()])
        
        query.cachePolicy = .networkElseCache
        query.maxCacheAge = 24*3600
        
        fetchMyOngoingEvents(inBackground: inBackground, with: query) {
            succeeded, error in
            handler?(succeeded, error)
        }
    }
    
    private static func fetchMyOngoingEvents(inBackground: Bool, with query: AVQuery, handler: ((_ succeeded: Bool, _ error: Error?) -> Void)?) {
        print("fetch my ongoing events")
        fetchData(inBackground: inBackground, with: query) {
            error, events in
            if error != nil {
                print(error!)
                handler?(false, EventRequestError.systemError(localizedDescriotion: "网络错误，无法加载数据", debugDescription: error!.localizedDescription))
                return
            }
            guard let events = events else {
                handler?(false, EventRequestError.systemError(localizedDescriotion: "网络错误，无法加载数据", debugDescription: "cannot get events"))
                return
            }
            for event in events {
                EventRequest.myOngoingEvents[event.objectId!] = event
                
                if event.updatedAt! > EventRequest.newestUpdatedAtOfMyOngoingEvents {
                    EventRequest.newestUpdatedAtOfMyOngoingEvents = event.updatedAt!
                }
                if event.updatedAt! < EventRequest.oldestUpdatedAtOfMyOngoingEvents {
                    EventRequest.oldestUpdatedAtOfMyOngoingEvents = event.updatedAt!
                }
            }
            handler?(true, nil)
        }
    }
    
    //--MARK: common private function for fetching data from server
    
    private static func fetchPublicEvents(inBackground: Bool, with query: AVQuery, handler: ((_ succeeded: Bool, _ error: Error?) -> Void)?) {
        print("fetch my public events")
        fetchData(inBackground: inBackground, with: query) {
            error, events in
            if error != nil {
                print(error!)
                handler?(false, EventRequestError.systemError(localizedDescriotion: "网络错误，无法加载数据", debugDescription: error!.localizedDescription))
                return
            }
            guard let events = events else {
                handler?(false, EventRequestError.systemError(localizedDescriotion: "网络错误，无法加载数据", debugDescription: "cannot get events"))
                return
            }
            for event in events {
                if !event.members.contains(AVUser.current()) {
                    EventRequest.publicEvents[event.objectId!] = event
                    
                    if event.updatedAt! > EventRequest.newestUpdatedAtOfPublicEvents {
                        EventRequest.newestUpdatedAtOfPublicEvents = event.updatedAt!
                    }
                    if event.updatedAt! < EventRequest.oldestUpdatedAtOfPublicEvents {
                        EventRequest.oldestUpdatedAtOfPublicEvents = event.updatedAt!
                    }
                }
            }
            handler?(true, nil)
        }
    }
    
    private static func fetchData(inBackground: Bool, with query: AVQuery, handler: @escaping (_ error: Error?, _ results: [Event]?) -> Void) {
        
        if inBackground {
            query.findObjectsInBackground() {
                objects, error in
                if error != nil {
                    print(error!.localizedDescription)
                    handler(EventRequestError.systemError(localizedDescriotion: "网络错误，无法加载数据", debugDescription: error!.localizedDescription), nil)
                    return
                }
                if objects != nil {
                    var events = [Event]()
                    for object in objects as! [AVObject] {
                        if let event = Event(data: object) {
                            events.append(event)
                        }
                    }
                    handler(nil, events)
                }
            }
        } else {
            guard let objects = query.findObjects() else {
                handler(EventRequestError.systemError(localizedDescriotion: "网络错误，无法加载数据", debugDescription: "cannot fetch objects"), nil)
                return
            }
            var events = [Event]()
            for object in objects as! [AVObject] {
                if let event = Event(data: object) {
                    events.append(event)
                }
            }
            handler(nil, events)
        }
    }
}
