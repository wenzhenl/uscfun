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
    var locationName: String?
    var location: AVGeoPoint?
    var expectedFee: Double?
    var transportationMethod: TransportationMethod?
    var note: String?
    var imageUrl: String?
    
    //--MARK: system properties of event
    var creator: AVUser
    var conversationId: String?
    var members: [AVUser]
    var active: Bool
    var finished: Bool
    
    
    //--MARK: properties added by Leancloud
    var objectId: String?
    var createdAt: Date?
    var updatedAt: Date?
    
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
        self.active = true
        self.finished = false
    }
    
    init?(data: AVObject?) {
        print("called")
        if let data = data {
            if let allKeys = data.allKeys() as? [String] {
                guard allKeys.contains(keyOfName), let name = data.value(forKey: keyOfName) as? String else {
                    print("no name")
                    return nil
                }
                self.name = name

                guard allKeys.contains(keyOfType), let type = data.value(forKey: keyOfType) as? String else {
                    print("no type")
                    return nil
                }
                self.type = EventType(rawValue: type)!

                guard allKeys.contains(keyOfTotalSeats), let totalSeats = data.value(forKey: keyOfTotalSeats) as? Int else {
                    print("no total seats")
                    return nil
                }
                self.totalSeats = totalSeats

                guard allKeys.contains(keyOfRemainingSeats), let remainingSeats = data.value(forKey: keyOfRemainingSeats) as? Int else {
                    print("no remaining seats")
                    return nil
                }
                self.remainingSeats = remainingSeats

                guard allKeys.contains(keyOfMinimumMoreAttendingPeople), let minimumMoreAttendingPeople = data.value(forKey: keyOfMinimumMoreAttendingPeople) as? Int else {
                    print("no minimum more")
                    return nil
                }
                self.minimumMoreAttendingPeople = minimumMoreAttendingPeople

                guard allKeys.contains(keyOfDue), let due = data.value(forKey: keyOfDue) as? Date else {
                    print("no due")
                    return nil
                }
                self.due = due

                guard allKeys.contains(keyOfCreator), let creator = data.value(forKey: keyOfCreator) as? AVUser else {
                    print("no user")
                    return nil
                }
                self.creator = creator
                guard allKeys.contains(keyOfMembers), let members = data.value(forKey: keyOfMembers) as? [AVUser] else {
                    print("no members")
                    return nil
                }
                self.members = members

                guard allKeys.contains(keyOfActive), let active = data.value(forKey: keyOfActive) as? Bool else {
                    print("no active")
                    return nil
                }
                self.active = active

                guard allKeys.contains(keyOfFinished), let finished = data.value(forKey: keyOfFinished) as? Bool else {
                    print("no finished")
                    return nil
                }
                self.finished = finished

                guard allKeys.contains(keyOfConversationId), let conversationId = data.value(forKey: keyOfConversationId) as? String else {
                    return nil
                }
                self.conversationId = conversationId

                if allKeys.contains(keyOfStartTime) {
                    if let startTime = data.value(forKey: keyOfStartTime) as? Date {
                        self.startTime = startTime
                    }
                }
                if allKeys.contains(keyOfEndTime) {
                    if let endTime = data.value(forKey: keyOfEndTime) as? Date {
                        self.endTime = endTime
                    }
                }
                if allKeys.contains(keyOfLocationName) {
                    if let locationName = data.value(forKey: keyOfLocationName) as? String {
                        self.locationName = locationName
                    }
                }
                if allKeys.contains(keyOfLocation) {
                    if let location = data.value(forKey: keyOfLocation) as? AVGeoPoint {
                        self.location = location
                    }
                }
                if allKeys.contains(keyOfExpectedFee) {
                    if let expectedFee = data.value(forKey: keyOfExpectedFee) as? Double {
                        self.expectedFee = expectedFee
                    }
                }
                if allKeys.contains(keyOfTransportationMethod) {
                    if let transportationMethod = data.value(forKey: keyOfTransportationMethod) as? String {
                        self.transportationMethod = TransportationMethod(rawValue: transportationMethod)
                    }
                }
                if allKeys.contains(keyOfNote) {
                    if let note = data.value(forKey: keyOfNote) as? String {
                        self.note = note
                    }
                }
                self.objectId = data.objectId
                self.createdAt = data.createdAt
                self.updatedAt = data.updatedAt

                return
            }
            print("no keys")
        }
        
        print("no data")
        self.name = ""
        self.type = EventType.entertainment
        self.totalSeats = 0
        self.remainingSeats = 0
        self.minimumMoreAttendingPeople = 0
        self.due = Date()
        return nil
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
        if let eventObject = AVObject(className: Event.classNameOfEvent) {
            eventObject.setObject(name, forKey: keyOfName)
            eventObject.setObject(type.rawValue, forKey: keyOfType)
            eventObject.setObject(totalSeats, forKey: keyOfTotalSeats)
            eventObject.setObject(remainingSeats, forKey: keyOfRemainingSeats)
            eventObject.setObject(minimumMoreAttendingPeople, forKey: keyOfMinimumMoreAttendingPeople)
            eventObject.setObject(due, forKey: keyOfDue)
            
            eventObject.setObject(creator, forKey: keyOfCreator)
            eventObject.setObject(members, forKey: keyOfMembers)
            eventObject.setObject(active, forKey: keyOfActive)
            eventObject.setObject(finished, forKey: keyOfFinished)
            
            if conversationId != nil {
                eventObject.setObject(conversationId!, forKey: keyOfConversationId)
            } else {
                self.delegate?.eventDidPost(succeed: false, errorReason: "cannot create conversation")
                return
            }
            
            if startTime != nil {
                eventObject.setObject(startTime!, forKey: keyOfStartTime)
            }
            
            if endTime != nil {
                eventObject.setObject(endTime!, forKey: keyOfEndTime)
            }
            
            if locationName != nil {
                eventObject.setObject(locationName!, forKey: keyOfLocationName)
            }
            
            if location != nil {
                eventObject.setObject(location!, forKey: keyOfLocation)
            }
            
            if expectedFee != nil {
                eventObject.setObject(expectedFee!, forKey: keyOfExpectedFee)
            }
            
            if transportationMethod != nil {
                eventObject.setObject(transportationMethod!.rawValue, forKey: keyOfTransportationMethod)
            }
            
            if note != nil {
                eventObject.setObject(note!, forKey: keyOfNote)
            }
            
            if eventObject.save() {
                self.delegate?.eventDidPost(succeed: true, errorReason: nil)
            } else {
                self.delegate?.eventDidPost(succeed: false, errorReason: "cannot save data")
            }
        }
        print("===================END POSTING EVENT===============================")
    }
    
    func join(newMember: AVUser) {
        members.append(newMember)
        if let eventObject = AVObject(className: Event.classNameOfEvent) {
            eventObject.setObject(members, forKey: "members")
            eventObject.fetchWhenSave = true
            eventObject.incrementKey("remainingSeats")
        }
    }
    
    //--MARK: constants
    public static let classNameOfEvent = "Event"
    private let keyOfName = "name"
    private let keyOfType = "type"
    private let keyOfTotalSeats = "totalSeats"
    private let keyOfRemainingSeats = "remainingSeats"
    private let keyOfMinimumMoreAttendingPeople = "minimumMoreAttendingPeople"
    private let keyOfDue = "due"
    
    private let keyOfCreator = "creator"
    private let keyOfMembers = "members"
    private let keyOfActive = "active"
    private let keyOfFinished = "finished"
    private let keyOfConversationId = "conversationId"
    
    private let keyOfStartTime = "startTime"
    private let keyOfEndTime = "endTime"
    private let keyOfLocationName = "locationName"
    private let keyOfLocation = "location"
    private let keyOfExpectedFee = "expectedFee"
    private let keyOfTransportationMethod = "transportationMethod"
    private let keyOfNote = "note"
}
