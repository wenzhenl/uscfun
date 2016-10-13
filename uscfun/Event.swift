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

enum CreatingEventError: Error {
    case cannotCreateConversation(reason: String)
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
    
    
    private func createChatRoom() throws {
        var eventConversationId: String?
        var errorReason: String?
        
        if let client = AVIMClient(clientId: AVUser.current().username) {
            client.open() {
                succeeded, error in
                if succeeded {
                    client.createConversation(withName: self.name, clientIds: [], attributes: nil, options: AVIMConversationOption.transient) {
                        conversation, error in
                        if(error == nil) {
                            print("create conversation successfully")
                            if let conversation = conversation {
                                print("---------------create conversation-------------")
                                print("----conversation id \(conversation.conversationId)----------")
                                print("----conversation name \(conversation.name)")
                                eventConversationId = conversation.conversationId
                            } else {
                                errorReason = "莫名其妙的原因"
                            }
                        } else {
                            errorReason = error!.localizedDescription
                        }
                    }
                } else {
                    errorReason = error?.localizedDescription
                }
            }
        } else {
            errorReason = "cannot open AVIMClient"
        }
        
        if errorReason == nil && eventConversationId != nil {
            self.conversationId = eventConversationId!
        } else if errorReason != nil {
            throw CreatingEventError.cannotCreateConversation(reason: errorReason!)
        } else {
            throw CreatingEventError.cannotCreateConversation(reason: "莫名其妙的原因")
        }
    }
    
    func post() throws {
        if let client = AVIMClient(clientId: AVUser.current().username) {
            client.open() {
                succeeded, error in
                if succeeded {
                    client.createConversation(withName: self.name, clientIds: [], attributes: nil, options: AVIMConversationOption.transient) {
                        conversation, error in
                        if(error == nil) {
                            print("create conversation successfully")
                            if let conversation = conversation {
                                print("---------------create conversation-------------")
                                print("----conversation id \(conversation.conversationId)----------")
                                print("----conversation name \(conversation.name)")
                                self.conversationId = conversation.conversationId
                                self.saveDataToSever()
                            } else {
                                print("莫名其妙的原因")
                            }
                        } else {
                            print(error?.localizedDescription)
                        }
                    }
                } else {
                    print(error?.localizedDescription)
                }
            }
        } else {
            print("cannot open AVIMClient")
        }
        
        
        
        
    }
    
    private func saveDataToSever() {
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
            }
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
