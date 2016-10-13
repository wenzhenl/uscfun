//
//  Event.swift
//  uscfun
//
//  Created by Wenzheng Li on 9/3/16.
//  Copyright © 2016 Wenzheng Li. All rights reserved.
//

import Foundation
import AVOSCloud
import AVOSCloudIM

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

protocol EventDelegate {
    func eventDidPost(succeed: Bool, errorReason: String?)
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
    var conversationId: String?
    var members: [AVUser]
    
    //--MARK: delegate for handling posting process
    var delegate: EventDelegate?
    
    init(name: String, type: EventType, totalSeats: Int, remainingSeats: Int, minimumMoreAttendingPeople: Int, due: Date, creator: AVUser) {
        self.name = name
        self.type = type
        self.totalSeats = totalSeats
        self.remainingSeats = remainingSeats
        self.minimumMoreAttendingPeople = minimumMoreAttendingPeople
        self.due = due
        self.creator = creator
        self.members = [AVUser]()
        members.append(creator)
    }
    
    func post() {
        print("=================== POSTING EVENT ==================================")
        if let client = AVIMClient(clientId: AVUser.current().username) {
            client.open() {
                succeeded, error in
                if succeeded {
                    client.createConversation(withName: self.name, clientIds: [], attributes: nil, options: AVIMConversationOption.transient) {
                        conversation, error in
                        if(error == nil) {
                            print("create conversation successfully")
                            if let conversation = conversation {
                                print("CREATED CONVERSATION")
                                print("conversation_id: \(conversation.conversationId)----------")
                                print("conversation_name: \(conversation.name)")
                                self.conversationId = conversation.conversationId
                                self.saveDataToSever()
                            } else {
                                self.delegate?.eventDidPost(succeed: false, errorReason: "莫名其妙的原因")
                            }
                        } else {
                            self.delegate?.eventDidPost(succeed: false, errorReason: error?.localizedDescription)
                        }
                    }
                } else {
                    self.delegate?.eventDidPost(succeed: false, errorReason: error?.localizedDescription)
                }
            }
        } else {
            self.delegate?.eventDidPost(succeed: false, errorReason: "cannot open AVIMClient")
        }
    }
    
    private func saveDataToSever() {
        print("SAVING DATA TO SERVER")
        if let eventObject = AVObject(className: classNameOfEvent) {
            eventObject.setObject(name, forKey: "name")
            eventObject.setObject(type.rawValue, forKey: "type")
            eventObject.setObject(totalSeats, forKey: "totalSeats")
            eventObject.setObject(remainingSeats, forKey: "remainingSeats")
            eventObject.setObject(minimumMoreAttendingPeople, forKey: "minimumMoreAttendingPeople")
            eventObject.setObject(due, forKey: "due")
            
            eventObject.setObject(creator, forKey: "creator")
            eventObject.setObject(members, forKey: "members")
            
            if conversationId != nil {
                eventObject.setObject(conversationId!, forKey: "conversationId")
            } else {
                self.delegate?.eventDidPost(succeed: false, errorReason: "cannot create conversation")
                return
            }
            
            if startTime != nil {
                eventObject.setObject(startTime!, forKey: "startTime")
            }
            
            if endTime != nil {
                eventObject.setObject(endTime!, forKey: "endTime")
            }
            
            if location != nil {
                eventObject.setObject(location!.placename, forKey: "locationName")
                let geoPoint = AVGeoPoint(latitude: location!.latitude, longitude: location!.longitude)
                eventObject.setObject(geoPoint, forKey: "location")
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
            self.delegate?.eventDidPost(succeed: true, errorReason: nil)
        }
        print("===================END POSTING EVENT===============================")
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
