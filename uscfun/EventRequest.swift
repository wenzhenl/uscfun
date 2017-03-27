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
    
    fileprivate static let concurrentMyOngoingEventQueue = DispatchQueue(label: "com.leeyukuang.myongoing.uscfun", attributes: .concurrent)
    fileprivate static let concurrentPublicEventQueue = DispatchQueue(label: "com.leeyukuang.public.uscfun", attributes: .concurrent)
    
    private static let timeOf1970 = Date(timeIntervalSince1970: 0)
    private static let timeOf2070 = Date(timeIntervalSince1970: 60*60*24*365*100)
    
    private static var _myOngoingEvents = OrderedDictionary<String, Event>()
    private static var newestCreatedAtOfMyOngoingEvents = timeOf1970
    private static var oldestCreatedAtOfMyOngoingEvents = timeOf2070
    
    private static var _publicEvents = OrderedDictionary<String, Event>()
    private static var newestCreatedAtOfPublicEvents = timeOf1970
    private static var oldestCreatedAtOfPublicEvents = timeOf2070
    
    static var myOngoingEvents: OrderedDictionary<String, Event> {
        var myOngoingEventsCopy: OrderedDictionary<String, Event>!
        concurrentMyOngoingEventQueue.sync {
            myOngoingEventsCopy = _myOngoingEvents
        }
        return myOngoingEventsCopy
    }
    
    static var publicEvents: OrderedDictionary<String, Event> {
        var publicEventsCopy: OrderedDictionary<String, Event>!
        concurrentPublicEventQueue.sync {
            publicEventsCopy = _publicEvents
        }
        return publicEventsCopy
    }
    
    static func removeMyOngoingEvent(with id: String, handler: (() -> Void)?) {
        concurrentMyOngoingEventQueue.async(flags: .barrier) {
            
            if _myOngoingEvents[id]?.updatedAt == newestCreatedAtOfMyOngoingEvents {
                newestCreatedAtOfMyOngoingEvents = timeOf1970
                for key in _myOngoingEvents.keys {
                    if key != id && _myOngoingEvents[key]!.updatedAt! > newestCreatedAtOfMyOngoingEvents {
                        newestCreatedAtOfMyOngoingEvents = _myOngoingEvents[key]!.updatedAt!
                    }
                }
            }
            
            if _myOngoingEvents[id]?.updatedAt == oldestCreatedAtOfMyOngoingEvents {
                oldestCreatedAtOfMyOngoingEvents = timeOf2070
                for key in _myOngoingEvents.keys {
                    if key != id && _myOngoingEvents[key]!.updatedAt! < oldestCreatedAtOfMyOngoingEvents {
                        oldestCreatedAtOfMyOngoingEvents = _myOngoingEvents[key]!.updatedAt!
                    }
                }
            }
            
            _myOngoingEvents[id] = nil
            
            DispatchQueue.main.async {
                handler?()
            }
        }
    }
    
    static func setMyOngoingEvent(event: Event, for id: String, handler: (() -> Void)?) {
        concurrentMyOngoingEventQueue.async(flags: .barrier) {
            
            if event.updatedAt! > newestCreatedAtOfMyOngoingEvents {
                newestCreatedAtOfMyOngoingEvents = event.updatedAt!
            }
            
            if event.updatedAt! < oldestCreatedAtOfMyOngoingEvents {
                oldestCreatedAtOfMyOngoingEvents = event.updatedAt!
            }
            
            _myOngoingEvents[id] = event
            
            DispatchQueue.main.async {
                handler?()
            }
        }
    }
    
    static func removeAllMyOngoingEvents(handler: (() -> Void)?) {
        concurrentMyOngoingEventQueue.async(flags: .barrier) {
            
            newestCreatedAtOfMyOngoingEvents = timeOf1970
            oldestCreatedAtOfMyOngoingEvents = timeOf2070
            _myOngoingEvents.removeAll()
            DispatchQueue.main.async {
                handler?()
            }
        }
    }
    
    static func cleanMyOngoingEventsInBackground(handler: (() -> Void)?) {
        concurrentMyOngoingEventQueue.async(flags: .barrier) {
            
            var removedUpdatedAts = [Date]()
            for id in _myOngoingEvents.keys {
                let event = _myOngoingEvents[id]!
                if event.status != .isFinalized && event.status != .isSecured && event.status != .isPending {
                    removedUpdatedAts.append(event.updatedAt!)
                    _myOngoingEvents[id] = nil
                }
            }
            
            if removedUpdatedAts.contains(newestCreatedAtOfMyOngoingEvents) {
                newestCreatedAtOfMyOngoingEvents = timeOf1970
                for key in _myOngoingEvents.keys {
                    if _myOngoingEvents[key]!.updatedAt! > newestCreatedAtOfMyOngoingEvents {
                        newestCreatedAtOfMyOngoingEvents = _myOngoingEvents[key]!.updatedAt!
                    }
                }
            }
            
            if removedUpdatedAts.contains(oldestCreatedAtOfMyOngoingEvents) {
                oldestCreatedAtOfMyOngoingEvents = timeOf2070
                for key in _myOngoingEvents.keys {
                    if _myOngoingEvents[key]!.updatedAt! < oldestCreatedAtOfMyOngoingEvents {
                        oldestCreatedAtOfMyOngoingEvents = _myOngoingEvents[key]!.updatedAt!
                    }
                }
            }
            
            DispatchQueue.main.async {
                handler?()
            }
        }
    }
    
    static func removePublicEvent(with id: String, handler: (() -> Void)?) {
        concurrentPublicEventQueue.async(flags: .barrier) {
            
            if _publicEvents[id]?.updatedAt == newestCreatedAtOfPublicEvents {
                newestCreatedAtOfPublicEvents = timeOf1970
                for key in _publicEvents.keys {
                    if key != id && _publicEvents[key]!.updatedAt! > newestCreatedAtOfPublicEvents {
                        newestCreatedAtOfPublicEvents = _publicEvents[key]!.updatedAt!
                    }
                }
            }
            
            if _publicEvents[id]?.updatedAt == oldestCreatedAtOfPublicEvents {
                oldestCreatedAtOfPublicEvents = timeOf2070
                for key in _publicEvents.keys {
                    if key != id && _publicEvents[key]!.updatedAt! < oldestCreatedAtOfPublicEvents {
                        oldestCreatedAtOfPublicEvents = _publicEvents[key]!.updatedAt!
                    }
                }
            }
            
            _publicEvents[id] = nil
            
            DispatchQueue.main.async {
                handler?()
            }
        }
    }
    
    static func setPublicEvent(event: Event, for id: String, handler: (() -> Void)?) {
        concurrentPublicEventQueue.async(flags: .barrier) {
            
            if event.updatedAt! > newestCreatedAtOfPublicEvents {
                newestCreatedAtOfPublicEvents = event.updatedAt!
            }
            
            if event.updatedAt! < oldestCreatedAtOfPublicEvents {
                oldestCreatedAtOfPublicEvents = event.updatedAt!
            }
            
            _publicEvents[id] = event
            
            DispatchQueue.main.async {
                handler?()
            }
        }
    }
    
    static func removeAllPublicEvents(handler: (() -> Void)?) {
        concurrentPublicEventQueue.async(flags: .barrier) {
            
            newestCreatedAtOfPublicEvents = timeOf1970
            oldestCreatedAtOfPublicEvents = timeOf2070
            _publicEvents.removeAll()
            DispatchQueue.main.async {
                handler?()
            }
        }
    }
    
    static func cleanPublicEventsInBackground(handler: (() -> Void)?) {
        concurrentPublicEventQueue.async(flags: .barrier) {
            
            var removedUpdatedAts = [Date]()
            for id in _publicEvents.keys {
                let event = _publicEvents[id]!
                if event.status != .isSecured && event.status != .isPending {
                    removedUpdatedAts.append(event.updatedAt!)
                    _publicEvents[id] = nil
                }
            }
            
            if removedUpdatedAts.contains(newestCreatedAtOfPublicEvents) {
                newestCreatedAtOfPublicEvents = timeOf1970
                for key in _publicEvents.keys {
                    if _publicEvents[key]!.updatedAt! > newestCreatedAtOfPublicEvents {
                        newestCreatedAtOfPublicEvents = _publicEvents[key]!.updatedAt!
                    }
                }
            }
            
            if removedUpdatedAts.contains(oldestCreatedAtOfPublicEvents) {
                oldestCreatedAtOfPublicEvents = timeOf2070
                for key in _publicEvents.keys {
                    if _publicEvents[key]!.updatedAt! < oldestCreatedAtOfPublicEvents {
                        oldestCreatedAtOfPublicEvents = _publicEvents[key]!.updatedAt!
                    }
                }
            }
            
            DispatchQueue.main.async {
                handler?()
            }
        }
    }
    
    static func preLoadData(inBackground: Bool = false) {
        EventRequest.fetchNewerMyOngoingEvents(inBackground: inBackground, currentNewestUpdatedTime: timeOf1970) {
            succeeded, error in
            UserDefaults.hasPreloadedMyOngoingEvents = true
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "finishedPreloadingMyOngoingEvents"), object: nil, userInfo: ["succeeded": succeeded])
            if error != nil {
                print("failed to preload my ongoing events: \(error!.localizedDescription)")
            }
        }
        
        EventRequest.fetchNewerPublicEvents(inBackground: inBackground, currentNewestUpdatedTime: timeOf1970) {
            succeeded, error in
            UserDefaults.hasPreloadedPublicEvents = true
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "finishedPreloadingPublicEvents"), object: nil, userInfo: ["succeeded": succeeded])
            if error != nil {
                print("failed to preload public events: \(error!.localizedDescription)")
            }
        }
    }
    
    //--MARK: functions for fetch public events
    
    static func fetchNewerPublicEvents() {
        fetchNewerPublicEvents(inBackground: false, currentNewestUpdatedTime: EventRequest.newestCreatedAtOfPublicEvents, handler: nil)
    }
    
    static func fetchNewerPublicEvents(handler: ((_ succeeded: Bool, _ error: Error?) -> Void)?) {
        fetchNewerPublicEvents(inBackground: false, currentNewestUpdatedTime: EventRequest.newestCreatedAtOfPublicEvents, handler: handler)
    }
    
    static func fetchNewerPublicEventsInBackground(handler: ((_ succeeded: Bool, _ error: Error?) -> Void)?) {
        fetchNewerPublicEvents(inBackground: true, currentNewestUpdatedTime: EventRequest.newestCreatedAtOfPublicEvents, handler: handler)
    }
    
    static func fetchNewerPublicEvents(inBackground: Bool, currentNewestUpdatedTime: Date, handler: ((_ succeeded: Bool, _ error: Error?) -> Void)?) {
        let query = AVQuery(className: EventKeyConstants.classNameOfEvent)
        query.order(byAscending: EventKeyConstants.keyOfDue)
        query.includeKey(EventKeyConstants.keyOfCreatedBy)
        query.includeKey(EventKeyConstants.keyOfMembers)
        query.whereKey(EventKeyConstants.keyOfInstitution, equalTo: AVUser.current()!.email!.institutionCode!)
        query.whereKey(EventKeyConstants.keyOfUpdatedAt, greaterThan: currentNewestUpdatedTime)
        
        /// define events must be still pending
        query.whereKey(EventKeyConstants.keyOfDue, greaterThan: Date().timeIntervalSince1970)
        query.whereKey(EventKeyConstants.keyOfRemainingSeats, greaterThan: 0)

        /// define events must be not cancelled
        query.whereKey(EventKeyConstants.keyOfIsCancelled, equalTo: false)
        
        query.cachePolicy = .networkElseCache
        query.maxCacheAge = 24*3600
        
        fetchPublicEvents(inBackground: inBackground, with: query) {
            succeeded, error in
            handler?(succeeded, error)
        }
    }
    
    static func fetchOlderPublicEvents() {
        fetchOlderPublicEvents(inBackground: false, currentOldestUpdatedTime: EventRequest.oldestCreatedAtOfPublicEvents, handler: nil)
    }
    
    static func fetchOlderPublicEvents(handler: ((_ succeeded: Bool, _ error: Error?) -> Void)?) {
        fetchOlderPublicEvents(inBackground: false, currentOldestUpdatedTime: EventRequest.oldestCreatedAtOfPublicEvents, handler: handler)
    }
    
    static func fetchOlderPublicEventsInBackground(handler: ((_ succeeded: Bool, _ error: Error?) -> Void)?) {
        fetchOlderPublicEvents(inBackground: true, currentOldestUpdatedTime: EventRequest.oldestCreatedAtOfPublicEvents, handler: handler)
    }
    
    static func fetchOlderPublicEvents(inBackground: Bool, currentOldestUpdatedTime: Date, handler: ((_ succeeded: Bool, _ error: Error?) -> Void)?) {
        let query = AVQuery(className: EventKeyConstants.classNameOfEvent)
        query.order(byAscending: EventKeyConstants.keyOfDue)
        query.includeKey(EventKeyConstants.keyOfCreatedBy)
        query.includeKey(EventKeyConstants.keyOfMembers)
        query.whereKey(EventKeyConstants.keyOfInstitution, equalTo: AVUser.current()!.email!.institutionCode!)
        query.whereKey(EventKeyConstants.keyOfUpdatedAt, lessThan: currentOldestUpdatedTime)
        
        /// define events must be still pending
        query.whereKey(EventKeyConstants.keyOfDue, greaterThan: Date().timeIntervalSince1970)
        query.whereKey(EventKeyConstants.keyOfRemainingSeats, greaterThan: 0)
        
        /// define events must be not cancelled
        query.whereKey(EventKeyConstants.keyOfIsCancelled, equalTo: false)
        
        query.cachePolicy = .networkElseCache
        query.maxCacheAge = 24*3600
        
        fetchPublicEvents(inBackground: inBackground, with: query) {
            succeeded, error in
            handler?(succeeded, error)
        }
    }
    
    //--MARK: functions for fetch my ongoing events
    
    static func fetchNewerMyOngoingEvents() {
        fetchNewerMyOngoingEvents(inBackground: false, currentNewestUpdatedTime: EventRequest.newestCreatedAtOfMyOngoingEvents, handler: nil)
    }
    
    static func fetchNewerMyOngoingEvents(handler: ((_ succeeded: Bool, _ error: Error?) -> Void)?) {
        fetchNewerMyOngoingEvents(inBackground: false, currentNewestUpdatedTime: EventRequest.newestCreatedAtOfMyOngoingEvents, handler: handler)
    }
    
    static func fetchNewerMyOngoingEventsInBackground(handler: ((_ succeeded: Bool, _ error: Error?) -> Void)?) {
        fetchNewerMyOngoingEvents(inBackground: true, currentNewestUpdatedTime: EventRequest.newestCreatedAtOfMyOngoingEvents, handler: handler)
    }
    
    static func fetchNewerMyOngoingEvents(inBackground: Bool, currentNewestUpdatedTime: Date, handler: ((_ succeeded: Bool, _ error: Error?) -> Void)?) {
        let query = AVQuery(className: EventKeyConstants.classNameOfEvent)
        query.order(byAscending: EventKeyConstants.keyOfDue)
        query.includeKey(EventKeyConstants.keyOfCreatedBy)
        query.includeKey(EventKeyConstants.keyOfMembers)
        query.whereKey(EventKeyConstants.keyOfInstitution, equalTo: AVUser.current()!.email!.institutionCode!)
        query.whereKey(EventKeyConstants.keyOfUpdatedAt, greaterThan: currentNewestUpdatedTime)
        
        /// define events must be not cancelled
        query.whereKey(EventKeyConstants.keyOfIsCancelled, equalTo: false)
        
        /// define events must be mine
        query.whereKey(EventKeyConstants.keyOfMembers, containsAllObjectsIn: [AVUser.current()!])
        
        query.cachePolicy = .networkElseCache
        query.maxCacheAge = 24*3600
        
        fetchMyOngoingEvents(inBackground: inBackground, with: query) {
            succeeded, error in
            handler?(succeeded, error)
        }
    }
    
    static func fetchOlderMyOngoingEvents() {
        fetchOlderMyOngoingEvents(inBackground: false, currentOldestUpdatedTime: EventRequest.oldestCreatedAtOfMyOngoingEvents, handler: nil)
    }
    
    static func fetchOlderMyOngoingEvents(handler: ((_ succeeded: Bool, _ error: Error?) -> Void)?) {
        fetchOlderMyOngoingEvents(inBackground: false, currentOldestUpdatedTime: EventRequest.oldestCreatedAtOfMyOngoingEvents, handler: handler)
    }
    
    static func fetchOlderMyOngoingEventsInBackground(handler: ((_ succeeded: Bool, _ error: Error?) -> Void)?) {
        fetchOlderMyOngoingEvents(inBackground: true, currentOldestUpdatedTime: EventRequest.oldestCreatedAtOfMyOngoingEvents, handler: handler)
    }
    
    static func fetchOlderMyOngoingEvents(inBackground: Bool, currentOldestUpdatedTime: Date, handler: ((_ succeeded: Bool, _ error: Error?) -> Void)?) {
        let query = AVQuery(className: EventKeyConstants.classNameOfEvent)
        query.order(byAscending: EventKeyConstants.keyOfDue)
        query.includeKey(EventKeyConstants.keyOfCreatedBy)
        query.includeKey(EventKeyConstants.keyOfMembers)
        query.whereKey(EventKeyConstants.keyOfInstitution, equalTo: AVUser.current()!.email!.institutionCode!)
        query.whereKey(EventKeyConstants.keyOfUpdatedAt, lessThan: currentOldestUpdatedTime)
        
        /// define events must be not cancelled
        query.whereKey(EventKeyConstants.keyOfIsCancelled, equalTo: false)
        
        /// define events must be mine
        query.whereKey(EventKeyConstants.keyOfMembers, containsAllObjectsIn: [AVUser.current()!])
        
        query.cachePolicy = .networkElseCache
        query.maxCacheAge = 24*3600
        
        fetchMyOngoingEvents(inBackground: inBackground, with: query) {
            succeeded, error in
            handler?(succeeded, error)
        }
    }
    
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
            
            concurrentPublicEventQueue.async(flags: .barrier) {
                for event in events {
                    if !event.members.contains(AVUser.current()!) {
                        _publicEvents[event.objectId!] = event
                        
                        if event.updatedAt! > newestCreatedAtOfPublicEvents {
                            newestCreatedAtOfPublicEvents = event.updatedAt!
                        }
                        if event.updatedAt! < oldestCreatedAtOfPublicEvents {
                            oldestCreatedAtOfPublicEvents = event.updatedAt!
                        }
                    }
                }
                DispatchQueue.main.async {
                    handler?(true, nil)
                }
            }
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
            
            concurrentMyOngoingEventQueue.async(flags: .barrier) {
                for event in events {
                    if event.status != .isFailed && !(event.completedBy ?? []).contains(AVUser.current()!) {
                        _myOngoingEvents[event.objectId!] = event
                        
                        if event.updatedAt! > newestCreatedAtOfMyOngoingEvents {
                            newestCreatedAtOfMyOngoingEvents = event.updatedAt!
                        }
                        if event.updatedAt! < oldestCreatedAtOfMyOngoingEvents {
                            oldestCreatedAtOfMyOngoingEvents = event.updatedAt!
                        }
                    }
                }
                DispatchQueue.main.async {
                    handler?(true, nil)
                }
            }
        }
    }
    
//    static func fetchEvents(inBackground: Bool, with eventIds: [String], handler: ((_ succeeded: Bool, _ error: Error?) -> Void)?) {
//        let query = AVQuery(className: EventKeyConstants.classNameOfEvent)
//        query.includeKey(EventKeyConstants.keyOfCreatedBy)
//        query.includeKey(EventKeyConstants.keyOfMembers)
//        query.whereKey(EventKeyConstants.keyOfObjectId, containedIn: eventIds)
//        query.cachePolicy = .networkElseCache
//        query.maxCacheAge = 24*3600
//        
//        fetchData(inBackground: inBackground, with: query) {
//            error, events in
//            if error != nil {
//                print(error!)
//                handler?(false, EventRequestError.systemError(localizedDescriotion: "网络错误，无法加载数据", debugDescription: error!.localizedDescription))
//                return
//            }
//            guard let events = events else {
//                handler?(false, EventRequestError.systemError(localizedDescriotion: "网络错误，无法加载数据", debugDescription: "cannot get events"))
//                return
//            }
//            
//            for event in events {
//                if event.members.contains(AVUser.current()!) {
//                    EventRequest._myOngoingEvents[event.objectId!] = event
//                    if event.updatedAt! > EventRequest.newestCreatedAtOfMyOngoingEvents {
//                        EventRequest.newestCreatedAtOfMyOngoingEvents = event.updatedAt!
//                    }
//                    if event.updatedAt! < EventRequest.oldestCreatedAtOfMyOngoingEvents {
//                        EventRequest.oldestCreatedAtOfMyOngoingEvents = event.updatedAt!
//                    }
//                } else {
//                    EventRequest._publicEvents[event.objectId!] = event
//                    if event.updatedAt! > EventRequest.newestCreatedAtOfPublicEvents {
//                        EventRequest.newestCreatedAtOfPublicEvents = event.updatedAt!
//                    }
//                    if event.updatedAt! < EventRequest.oldestCreatedAtOfPublicEvents {
//                        EventRequest.oldestCreatedAtOfPublicEvents = event.updatedAt!
//                    }
//                }
//            }
//            handler?(true, nil)
//        }
//    }
    //--MARK: common private function for fetching data from server

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
    
    //--MARK: fetch one event with its object id
    static func fetchOneEvent(with objectId: String, handler: @escaping (_ error: Error?, _ result: Event?) -> Void) {
        let query = AVQuery(className: EventKeyConstants.classNameOfEvent)
        query.includeKey(EventKeyConstants.keyOfCreatedBy)
        query.includeKey(EventKeyConstants.keyOfMembers)
        query.includeKey(EventKeyConstants.keyOfCompletedBy)
        query.getObjectInBackground(withId: objectId) {
            object, error in
            if error != nil {
                print(error!.localizedDescription)
                handler(EventRequestError.systemError(localizedDescriotion: "网络错误，无法获取数据", debugDescription: error!.localizedDescription), nil)
            }
            if object != nil {
                if let event = Event(data: object) {
                    handler(nil, event)
                } else {
                    handler(EventRequestError.systemError(localizedDescriotion: "无法解析活动数据", debugDescription: error!.localizedDescription), nil)
                }
            }
            
        }
    }
}
