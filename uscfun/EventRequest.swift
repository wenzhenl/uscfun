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
    
    static func fetch(handler: @escaping (_ error: Error?, _ results: [Event]?) -> Void) {
        if let query = AVQuery(className: EventKeyConstants.classNameOfEvent) {
            query.order(byDescending: EventKeyConstants.keyOfUpdatedAt)
            query.includeKey(EventKeyConstants.keyOfCreator)
            query.includeKey(EventKeyConstants.keyOfMembers)
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
            query.order(byDescending: EventKeyConstants.keyOfUpdatedAt)
            query.includeKey(EventKeyConstants.keyOfCreator)
            query.includeKey(EventKeyConstants.keyOfMembers)
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
            query.order(byDescending: EventKeyConstants.keyOfUpdatedAt)
            query.includeKey(EventKeyConstants.keyOfCreator)
            query.includeKey(EventKeyConstants.keyOfMembers)
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
