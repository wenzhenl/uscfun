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
    
    //--MARK: common fetch type
    enum FetchType {
        case newer
        case older
    }
    
    enum EventSource {
        case myongoing
        case mypublic
    }
    
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
    
    //--MARK: fetch event with its object id
    
    static func fetchEvent(with objectId: String, handler: @escaping (_ error: Error?, _ result: Event?) -> Void) {
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
    
    //--MARK: common function for preloading data
    
    static func preLoadData() {
        fetchNewerMyOngoingEvents()
        fetchNewerPublicEvents()
    }
    
    static func preLoadDataInBackground() {
        EventRequest.fetchNewerMyOngoingEventsInBackground {
            succeeded, error in
            UserDefaults.hasPreloadedMyOngoingEvents = true
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "finishedPreloadingMyOngoingEvents"), object: nil, userInfo: ["succeeded": succeeded])
            if error != nil {
                print("failed to preload my ongoing events: \(error!.localizedDescription)")
            }
        }
        
        EventRequest.fetchNewerPublicEventsInBackground {
            succeeded, error in
            UserDefaults.hasPreloadedPublicEvents = true
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "finishedPreloadingPublicEvents"), object: nil, userInfo: ["succeeded": succeeded])
            if error != nil {
                print("failed to preload public events: \(error!.localizedDescription)")
            }
        }
    }
    
    //--MARK: common private time constant
    
    private static let timeOf1970 = Date(timeIntervalSince1970: 0)
    private static let timeOf2070 = Date(timeIntervalSince1970: 60*60*24*365*100)
    
    //--MARK: interface for my ongoing events
    
    fileprivate static let concurrentMyOngoingEventQueue = DispatchQueue(label: "com.leeyukuang.myongoing.uscfun", attributes: .concurrent)
    
    private static var _myOngoingEvents = OrderedDictionary<String, Event>()
    private static var newestCreatedAtOfMyOngoingEvents = timeOf1970
    private static var oldestCreatedAtOfMyOngoingEvents = timeOf2070
    
    static var myOngoingEvents: OrderedDictionary<String, Event> {
        var myOngoingEventsCopy: OrderedDictionary<String, Event>!
        concurrentMyOngoingEventQueue.sync {
            myOngoingEventsCopy = _myOngoingEvents
        }
        return myOngoingEventsCopy
    }
    
    //--MARK: interface of public events
    
    fileprivate static let concurrentPublicEventQueue = DispatchQueue(label: "com.leeyukuang.public.uscfun", attributes: .concurrent)

    private static var _publicEvents = OrderedDictionary<String, Event>()
    private static var newestCreatedAtOfPublicEvents = timeOf1970
    private static var oldestCreatedAtOfPublicEvents = timeOf2070
    
    static var publicEvents: OrderedDictionary<String, Event> {
        var publicEventsCopy: OrderedDictionary<String, Event>!
        concurrentPublicEventQueue.sync {
            publicEventsCopy = _publicEvents
        }
        return publicEventsCopy
    }
    
    //--MARK: {get, set} of events
    static func removeEvent(with id: String, for source: EventSource, handler: (() -> Void)?) {
        
        var concurrentQueue: DispatchQueue!
     
        /// choose concurent queue
        switch source {
        case .myongoing:
            concurrentQueue = concurrentMyOngoingEventQueue
        case .mypublic:
            concurrentQueue = concurrentPublicEventQueue
        }
        
        concurrentQueue.async(flags: .barrier) {
            var eventsCopy: OrderedDictionary<String, Event>!
            var newestCreatedAt: Date!
            var oldestCreatedAt: Date!
            switch source {
            case .myongoing:
                eventsCopy = _myOngoingEvents
                newestCreatedAt = newestCreatedAtOfMyOngoingEvents
                oldestCreatedAt = oldestCreatedAtOfMyOngoingEvents
            case .mypublic:
                eventsCopy = _publicEvents
                newestCreatedAt = newestCreatedAtOfPublicEvents
                oldestCreatedAt = oldestCreatedAtOfPublicEvents
            }
            
            if eventsCopy[id]?.createdAt == newestCreatedAt {
                newestCreatedAt = timeOf1970
                for key in eventsCopy.keys {
                    if key != id && eventsCopy[key]!.createdAt! > newestCreatedAt {
                        newestCreatedAt = eventsCopy[key]!.createdAt!
                    }
                }
            }
            
            if eventsCopy[id]?.createdAt == oldestCreatedAt {
                oldestCreatedAt = timeOf2070
                for key in eventsCopy.keys {
                    if key != id && eventsCopy[key]!.createdAt! < oldestCreatedAt {
                        oldestCreatedAt = eventsCopy[key]!.createdAt!
                    }
                }
            }
            
            eventsCopy[id] = nil
            
            /// restore data
            switch source {
            case .myongoing:
                _myOngoingEvents = eventsCopy
                newestCreatedAtOfMyOngoingEvents = newestCreatedAt
                oldestCreatedAtOfMyOngoingEvents = oldestCreatedAt
            case .mypublic:
                _publicEvents = eventsCopy
                newestCreatedAtOfPublicEvents = newestCreatedAt
                oldestCreatedAtOfPublicEvents = oldestCreatedAt
            }
            
            DispatchQueue.main.async {
                handler?()
            }
        }
    }
    
    static func setEvent(event: Event, with id: String, for source: EventSource, handler: (() -> Void)?) {
        var concurrentQueue: DispatchQueue!
        
        /// choose concurent queue
        switch source {
        case .myongoing:
            concurrentQueue = concurrentMyOngoingEventQueue
        case .mypublic:
            concurrentQueue = concurrentPublicEventQueue
        }
        
        concurrentQueue.async(flags: .barrier) {
            var eventsCopy: OrderedDictionary<String, Event>!
            switch source {
            case .myongoing:
                eventsCopy = _myOngoingEvents
            case .mypublic:
                eventsCopy = _publicEvents
            }
            
            eventsCopy[id] = event
            
            /// restore data
            switch source {
            case .myongoing:
                _myOngoingEvents = eventsCopy
            case .mypublic:
                _publicEvents = eventsCopy
            }
            
            DispatchQueue.main.async {
                handler?()
            }
        }
    }
    
    static func removeAllEvents(for source: EventSource, handler: (() -> Void)?) {
        var concurrentQueue: DispatchQueue!
        
        /// choose concurent queue
        switch source {
        case .myongoing:
            concurrentQueue = concurrentMyOngoingEventQueue
        case .mypublic:
            concurrentQueue = concurrentPublicEventQueue
        }
        
        concurrentQueue.async(flags: .barrier) {
            switch source {
            case .myongoing:
                newestCreatedAtOfMyOngoingEvents = timeOf1970
                oldestCreatedAtOfMyOngoingEvents = timeOf2070
                _myOngoingEvents.removeAll()
            case .mypublic:
                newestCreatedAtOfPublicEvents = timeOf1970
                oldestCreatedAtOfPublicEvents = timeOf2070
                _publicEvents.removeAll()
            }
            
            DispatchQueue.main.async {
                handler?()
            }
        }
    }
    
    static func cleanEventsInBackground(for source: EventSource, handler: (() -> Void)?) {
        var concurrentQueue: DispatchQueue!
        
        /// choose concurent queue
        switch source {
        case .myongoing:
            concurrentQueue = concurrentMyOngoingEventQueue
        case .mypublic:
            concurrentQueue = concurrentPublicEventQueue
        }

        concurrentQueue.async(flags: .barrier) {
            
            var eventsCopy: OrderedDictionary<String, Event>!
            var newestCreatedAt: Date!
            var oldestCreatedAt: Date!
            switch source {
            case .myongoing:
                eventsCopy = _myOngoingEvents
                newestCreatedAt = newestCreatedAtOfMyOngoingEvents
                oldestCreatedAt = oldestCreatedAtOfMyOngoingEvents
            case .mypublic:
                eventsCopy = _publicEvents
                newestCreatedAt = newestCreatedAtOfPublicEvents
                oldestCreatedAt = oldestCreatedAtOfPublicEvents
            }
            
            var removedUpdatedAts = [Date]()
            for id in eventsCopy.keys {
                let event = eventsCopy[id]!
                switch source {
                case .myongoing:
                    if event.status != .isFinalized && event.status != .isSecured && event.status != .isPending {
                        removedUpdatedAts.append(event.createdAt!)
                        eventsCopy[id] = nil
                    }
                case .mypublic:
                    if event.status != .isSecured && event.status != .isPending {
                        removedUpdatedAts.append(event.createdAt!)
                        eventsCopy[id] = nil
                    }
                }
            }
            
            if removedUpdatedAts.contains(newestCreatedAt) {
                newestCreatedAt = timeOf1970
                for key in eventsCopy.keys {
                    if eventsCopy[key]!.createdAt! > newestCreatedAt {
                        newestCreatedAt = eventsCopy[key]!.createdAt!
                    }
                }
            }
            
            if removedUpdatedAts.contains(oldestCreatedAt) {
                oldestCreatedAt = timeOf2070
                for key in eventsCopy.keys {
                    if eventsCopy[key]!.createdAt! < oldestCreatedAt {
                        oldestCreatedAt = eventsCopy[key]!.createdAt!
                    }
                }
            }
            
            /// restore data
            switch source {
            case .myongoing:
                _myOngoingEvents = eventsCopy
                newestCreatedAtOfMyOngoingEvents = newestCreatedAt
                oldestCreatedAtOfMyOngoingEvents = oldestCreatedAt
            case .mypublic:
                _publicEvents = eventsCopy
                newestCreatedAtOfPublicEvents = newestCreatedAt
                oldestCreatedAtOfPublicEvents = oldestCreatedAt
            }
            
            DispatchQueue.main.async {
                handler?()
            }
        }
    }
    
    //--MARK: function for refresh events
    
    static func refreshMyOngoingEvents() {
        refreshEvents(for: .myongoing, handler: nil)
    }
    
    static func refreshPublicEvents() {
        refreshEvents(for: .mypublic, handler: nil)
    }
    
    static func refreshEvents(for source: EventSource, handler: ((_ succeeded: Bool, _ error: Error?) -> Void)?) {
        let query = AVQuery(className: EventKeyConstants.classNameOfEvent)
        switch source {
        case .myongoing:
            query.whereKey(EventKeyConstants.keyOfObjectId, containedIn: myOngoingEvents.keys)
        case .mypublic:
            query.whereKey(EventKeyConstants.keyOfObjectId, containedIn: publicEvents.keys)
        }
        
        /// include AVUser
        query.includeKey(EventKeyConstants.keyOfCreatedBy)
        query.includeKey(EventKeyConstants.keyOfMembers)
        query.includeKey(EventKeyConstants.keyOfCompletedBy)

        query.cachePolicy = .networkElseCache
        query.maxCacheAge = USCFunConstants.MAXCACHEAGE
        query.limit = USCFunConstants.QUERYLIMIT
        
        var concurrentQueue: DispatchQueue!
        
        /// choose concurent queue
        switch source {
        case .myongoing:
            concurrentQueue = concurrentMyOngoingEventQueue
        case .mypublic:
            concurrentQueue = concurrentPublicEventQueue
        }
        
        fetchData(inBackground: false, with: query) {
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
            
            print("updated events number: \(events.count)")
            
            concurrentQueue.async(flags: .barrier) {
                for event in events {
                    switch source {
                    case .myongoing:
                        _myOngoingEvents[event.objectId!] = event
                    case .mypublic:
                        _publicEvents[event.objectId!] = event
                    }
                }
                
                DispatchQueue.main.async {
                    handler?(true, nil)
                }
            }
        }
    }

    //--MARK: functions for fetch newer my ongoing events
    
    static func fetchNewerMyOngoingEvents() {
        fetchEvents(for: .myongoing, by: .newer, inBackground: false, currentCreatedTime: newestCreatedAtOfMyOngoingEvents, handler: nil)
    }
    
    static func fetchNewerMyOngoingEventsInBackground(handler: ((_ succeeded: Bool, _ error: Error?) -> Void)?) {
        fetchEvents(for: .myongoing, by: .newer, inBackground: true, currentCreatedTime: newestCreatedAtOfMyOngoingEvents, handler: handler)
    }
    
    //--MARK: functions for fetch older my ongoing events

    static func fetchOlderMyOngoingEventsInBackground(handler: ((_ succeeded: Bool, _ error: Error?) -> Void)?) {
        fetchEvents(for: .myongoing, by: .older, inBackground: true, currentCreatedTime: oldestCreatedAtOfMyOngoingEvents, handler: handler)
    }
    
    //--MARK: functions for fetch newer public events

    static func fetchNewerPublicEvents() {
        fetchEvents(for: .mypublic, by: .newer, inBackground: false, currentCreatedTime: newestCreatedAtOfPublicEvents, handler: nil)
    }

    static func fetchNewerPublicEventsInBackground(handler: ((_ succeeded: Bool, _ error: Error?) -> Void)?) {
        fetchEvents(for: .mypublic, by: .newer, inBackground: true, currentCreatedTime: newestCreatedAtOfPublicEvents, handler: handler)
    }
    
    //--MARK: functions for fetch older my ongoing events

    static func fetchOlderPublicEventsInBackground(handler: ((_ succeeded: Bool, _ error: Error?) -> Void)?) {
        fetchEvents(for: .mypublic, by: .older, inBackground: true, currentCreatedTime: oldestCreatedAtOfPublicEvents, handler: handler)
    }
    
    static func fetchEvents(for source: EventSource, by type: FetchType, inBackground: Bool, currentCreatedTime: Date, handler: ((_ succeeded: Bool, _ error: Error?) -> Void)?) {
        let query = AVQuery(className: EventKeyConstants.classNameOfEvent)
        
        /// sort events by createdAt, always fetch the newest created events
        query.order(byDescending: EventKeyConstants.keyOfCreatedAt)
        
        /// include AVUser
        query.includeKey(EventKeyConstants.keyOfCreatedBy)
        query.includeKey(EventKeyConstants.keyOfMembers)
        query.includeKey(EventKeyConstants.keyOfCompletedBy)
        
        /// events must belong to user's institution
        query.whereKey(EventKeyConstants.keyOfInstitution, equalTo: AVUser.current()!.email!.institutionCode!)
        
        /// events must newer or older than current
        switch type {
        case .newer:
            query.whereKey(EventKeyConstants.keyOfCreatedAt, greaterThan: currentCreatedTime)
        case .older:
            query.whereKey(EventKeyConstants.keyOfCreatedAt, lessThan: currentCreatedTime)
        }
        
        switch source {
        case .myongoing:
            /// define events must be mine
            query.whereKey(EventKeyConstants.keyOfMembers, containsAllObjectsIn: [AVUser.current()!])
        case .mypublic:
            /// define events must be still pending
            query.whereKey(EventKeyConstants.keyOfDue, greaterThan: Date().timeIntervalSince1970)
            query.whereKey(EventKeyConstants.keyOfRemainingSeats, greaterThan: 0)
        }
     
        /// define events must be not cancelled
        query.whereKey(EventKeyConstants.keyOfIsCancelled, equalTo: false)
        
        query.cachePolicy = .networkElseCache
        query.maxCacheAge = USCFunConstants.MAXCACHEAGE
        query.limit = USCFunConstants.QUERYLIMIT
        
        fetchEvents(for: source, by: type, inBackground: inBackground, with: query) {
            succeeded, error in
            handler?(succeeded, error)
        }
    }
    
    //--MARK: private function for handling fetched events

    private static func fetchEvents(for source: EventSource, by type: FetchType, inBackground: Bool, with query: AVQuery, handler: ((_ succeeded: Bool, _ error: Error?) -> Void)?) {
        
        var concurrentQueue: DispatchQueue!
        
        /// choose concurent queue
        switch source {
        case .myongoing:
            concurrentQueue = concurrentMyOngoingEventQueue
        case .mypublic:
            concurrentQueue = concurrentPublicEventQueue
        }
        
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
            
            concurrentQueue.async(flags: .barrier) {
                var eventsCopy: OrderedDictionary<String, Event>!
                var newestCreatedAt: Date!
                var oldestCreatedAt: Date!
                switch source {
                case .myongoing:
                    eventsCopy = _myOngoingEvents
                    newestCreatedAt = newestCreatedAtOfMyOngoingEvents
                    oldestCreatedAt = oldestCreatedAtOfMyOngoingEvents
                case .mypublic:
                    eventsCopy = _publicEvents
                    newestCreatedAt = newestCreatedAtOfPublicEvents
                    oldestCreatedAt = oldestCreatedAtOfPublicEvents
                }
                
                if type == .newer && events.count >= USCFunConstants.QUERYLIMIT {
                    eventsCopy.removeAll()
                    newestCreatedAt = timeOf1970
                    oldestCreatedAt = timeOf2070
                }
                
                for event in events {
                    switch source {
                    case .myongoing:
                        if event.status != .isFailed && !(event.completedBy ?? []).contains(AVUser.current()!) {
                            eventsCopy[event.objectId!] = event
                            
                            if event.createdAt! > newestCreatedAt {
                                newestCreatedAt = event.createdAt!
                            }
                            if event.createdAt! < oldestCreatedAt {
                                oldestCreatedAt = event.createdAt!
                            }
                        }
                    case .mypublic:
                        if !event.members.contains(AVUser.current()!) {
                            eventsCopy[event.objectId!] = event
                            
                            if event.createdAt! > newestCreatedAt {
                                newestCreatedAt = event.createdAt!
                            }
                            if event.createdAt! < oldestCreatedAt {
                                oldestCreatedAt = event.createdAt!
                            }
                        }
                    }
                }
                
                /// restore data
                switch source {
                case .myongoing:
                    _myOngoingEvents = eventsCopy
                    newestCreatedAtOfMyOngoingEvents = newestCreatedAt
                    oldestCreatedAtOfMyOngoingEvents = oldestCreatedAt
                case .mypublic:
                    _publicEvents = eventsCopy
                    newestCreatedAtOfPublicEvents = newestCreatedAt
                    oldestCreatedAtOfPublicEvents = oldestCreatedAt
                }
                
                DispatchQueue.main.async {
                    handler?(true, nil)
                }
            }
        }
    }
    
    static func fetchEventsCreated(by user: AVUser, handler: @escaping (_ error: Error?, _ results: [Event]?) -> Void) {
        let query = AVQuery(className: EventKeyConstants.classNameOfEvent)
        query.includeKey(EventKeyConstants.keyOfCreatedBy)
        query.includeKey(EventKeyConstants.keyOfMembers)
        query.includeKey(EventKeyConstants.keyOfCompletedBy)
        query.whereKey(EventKeyConstants.keyOfCreatedBy, equalTo: user)
        query.whereKey(EventKeyConstants.keyOfCompletedBy, containsAllObjectsIn: [user])
        fetchData(inBackground: true, with: query, handler: handler)
    }
    
    static func fetchEventsAttended(by user: AVUser, handler: @escaping (_ error: Error?, _ results: [Event]?) -> Void) {
        let query = AVQuery(className: EventKeyConstants.classNameOfEvent)
        query.includeKey(EventKeyConstants.keyOfCreatedBy)
        query.includeKey(EventKeyConstants.keyOfMembers)
        query.includeKey(EventKeyConstants.keyOfCompletedBy)
        query.whereKey(EventKeyConstants.keyOfCreatedBy, notEqualTo: user)
        query.whereKey(EventKeyConstants.keyOfMembers, containsAllObjectsIn: [user])
        query.whereKey(EventKeyConstants.keyOfCompletedBy, containsAllObjectsIn: [user])
        fetchData(inBackground: true, with: query, handler: handler)
    }
}
