//
//  Event.swift
//  uscfun
//
//  Created by Wenzheng Li on 9/3/16.
//  Copyright © 2016 Wenzheng Li. All rights reserved.
//

import Foundation
import AVOSCloud

struct Location {
    var placename: String
    var latitude: Double
    var longitude: Double
}

enum EventType: String {
    case foodAndDrink = "foodAndDrink"
    case shopping = "shopping"
    case entertainment = "entertainment"
    case study = "study"
    case other = "other"
}

enum TransportationMethod: String {
    case selfDriving = "selfDriving"
    case uber = "uber"
    case metro = "metro"
}

class Event {
    //--MARK: required information
    var name: String
    var type: EventType
    var totalSeats: Int
    var remainingSeats: Int
    var minimumMoreAttendingPeople: Int
    var due: Date
    
    //--MARK: optional settings
    var startTime: Date?
    var endTime: Date?
    var location: Location?
    var expectedFee: Double?
    var transportationMethod: TransportationMethod?
    var note: String?
    
    //--MARK: system properties of event
    var creator: AVUser
    var conversationId: String
    var members: [AVUser]
    
    init(name: String, type: EventType, totalSeats: Int, remainingSeats: Int, minimumMoreAttendingPeople: Int, due: Date, creator: AVUser, conversationId: String) {
        self.name = name
        self.type = type
        self.totalSeats = totalSeats
        self.remainingSeats = remainingSeats
        self.minimumMoreAttendingPeople = minimumMoreAttendingPeople
        self.due = due
        self.creator = creator
        self.conversationId = conversationId
        self.members = [AVUser]()
        members.append(creator)
    }
    
    func post() {
        if let eventObject = AVObject(className: classNameOfEvent) {
            eventObject.setObject(name, forKey: "name")
            eventObject.setObject(type.rawValue, forKey: "type")
            eventObject.setObject(totalSeats, forKey: "totalSeats")
            eventObject.setObject(remainingSeats, forKey: "remainingSeats")
            eventObject.setObject(minimumMoreAttendingPeople, forKey: "minimumMoreAttendingPeople")
            eventObject.setObject(due, forKey: "due")
            
            eventObject.setObject(creator, forKey: "creator")
            eventObject.setObject(conversationId, forKey: "conversationId")
            eventObject.setObject(members, forKey: "members")
            
            if startTime != nil {
                eventObject.setObject(startTime!, forKey: "startTime")
            }
            if endTime != nil {
                eventObject.setObject(endTime!, forKey: "endTime")
            }
            if location != nil {
                eventObject.setObject(location!, forKey: "location")
            }
            if expectedFee != nil {
                eventObject.setObject(expectedFee!, forKey: "expectedFee")
            }
            if transportationMethod != nil {
                eventObject.setObject(transportationMethod!.rawValue, forKey: "transportationMethod")
            }
            if note != nil {
                eventObject.setObject(note!, forKey: "note")
            }
            
            eventObject.save()
        }
        
    }
    
    func join(newMember: AVUser) {
        members.append(newMember)
        if let eventObject = AVObject(className: classNameOfEvent) {
            eventObject.setObject(members, forKey: "members")
            eventObject.fetchWhenSave = true
            eventObject.incrementKey("remainingSeats")
        }
    }
    
    //--MARK: constants
    private let classNameOfEvent = "Event"
}
