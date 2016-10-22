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
    case travel = "travel"
    case study = "study"
    case other = "other"
    
    var image: UIImage {
        switch self {
        case .foodAndDrink:
            return #imageLiteral(resourceName: "foodAndDrink")
        case .shopping:
            return #imageLiteral(resourceName: "shopping")
        case .entertainment:
            return #imageLiteral(resourceName: "recreation")
        case .travel:
            return #imageLiteral(resourceName: "travel")
        case .study:
            return #imageLiteral(resourceName: "seasons")
        default:
            return #imageLiteral(resourceName: "party")
        }
    }
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
        if let data = data {
            if let allKeys = data.allKeys() as? [String] {
                guard allKeys.contains(EventKeyConstants.keyOfName), let name = data.value(forKey: EventKeyConstants.keyOfName) as? String else {
                    print("no name")
                    return nil
                }
                self.name = name

                guard allKeys.contains(EventKeyConstants.keyOfType), let type = data.value(forKey: EventKeyConstants.keyOfType) as? String else {
                    print("no type")
                    return nil
                }
                self.type = EventType(rawValue: type)!

                guard allKeys.contains(EventKeyConstants.keyOfTotalSeats), let totalSeats = data.value(forKey: EventKeyConstants.keyOfTotalSeats) as? Int else {
                    print("no total seats")
                    return nil
                }
                self.totalSeats = totalSeats

                guard allKeys.contains(EventKeyConstants.keyOfRemainingSeats), let remainingSeats = data.value(forKey: EventKeyConstants.keyOfRemainingSeats) as? Int else {
                    print("no remaining seats")
                    return nil
                }
                self.remainingSeats = remainingSeats

                guard allKeys.contains(EventKeyConstants.keyOfMinimumMoreAttendingPeople), let minimumMoreAttendingPeople = data.value(forKey: EventKeyConstants.keyOfMinimumMoreAttendingPeople) as? Int else {
                    print("no minimum more")
                    return nil
                }
                self.minimumMoreAttendingPeople = minimumMoreAttendingPeople

                guard allKeys.contains(EventKeyConstants.keyOfDue), let due = data.value(forKey: EventKeyConstants.keyOfDue) as? Date else {
                    print("no due")
                    return nil
                }
                self.due = due

                guard allKeys.contains(EventKeyConstants.keyOfCreator), let creator = data.object(forKey: EventKeyConstants.keyOfCreator) as? AVUser else {
                    print("no user")
                    return nil
                }
                self.creator = creator
                print(self.creator)
                
                guard allKeys.contains(EventKeyConstants.keyOfMembers), let members = data.value(forKey: EventKeyConstants.keyOfMembers) as? [AVUser] else {
                    print("no members")
                    return nil
                }
                self.members = members

                guard allKeys.contains(EventKeyConstants.keyOfActive), let active = data.value(forKey: EventKeyConstants.keyOfActive) as? Bool else {
                    print("no active")
                    return nil
                }
                self.active = active

                guard allKeys.contains(EventKeyConstants.keyOfFinished), let finished = data.value(forKey: EventKeyConstants.keyOfFinished) as? Bool else {
                    print("no finished")
                    return nil
                }
                self.finished = finished

                guard allKeys.contains(EventKeyConstants.keyOfConversationId), let conversationId = data.value(forKey: EventKeyConstants.keyOfConversationId) as? String else {
                    return nil
                }
                self.conversationId = conversationId

                if allKeys.contains(EventKeyConstants.keyOfStartTime) {
                    if let startTime = data.value(forKey: EventKeyConstants.keyOfStartTime) as? Date {
                        self.startTime = startTime
                    }
                }
                if allKeys.contains(EventKeyConstants.keyOfEndTime) {
                    if let endTime = data.value(forKey: EventKeyConstants.keyOfEndTime) as? Date {
                        self.endTime = endTime
                    }
                }
                if allKeys.contains(EventKeyConstants.keyOfLocationName) {
                    if let locationName = data.value(forKey: EventKeyConstants.keyOfLocationName) as? String {
                        self.locationName = locationName
                    }
                }
                if allKeys.contains(EventKeyConstants.keyOfLocation) {
                    if let location = data.value(forKey: EventKeyConstants.keyOfLocation) as? AVGeoPoint {
                        self.location = location
                    }
                }
                if allKeys.contains(EventKeyConstants.keyOfExpectedFee) {
                    if let expectedFee = data.value(forKey: EventKeyConstants.keyOfExpectedFee) as? Double {
                        self.expectedFee = expectedFee
                    }
                }
                if allKeys.contains(EventKeyConstants.keyOfTransportationMethod) {
                    if let transportationMethod = data.value(forKey: EventKeyConstants.keyOfTransportationMethod) as? String {
                        self.transportationMethod = TransportationMethod(rawValue: transportationMethod)
                    }
                }
                if allKeys.contains(EventKeyConstants.keyOfNote) {
                    if let note = data.value(forKey: EventKeyConstants.keyOfNote) as? String {
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
        if let eventObject = AVObject(className: EventKeyConstants.classNameOfEvent) {
            eventObject.setObject(name, forKey: EventKeyConstants.keyOfName)
            eventObject.setObject(type.rawValue, forKey: EventKeyConstants.keyOfType)
            eventObject.setObject(totalSeats, forKey: EventKeyConstants.keyOfTotalSeats)
            eventObject.setObject(remainingSeats, forKey: EventKeyConstants.keyOfRemainingSeats)
            eventObject.setObject(minimumMoreAttendingPeople, forKey: EventKeyConstants.keyOfMinimumMoreAttendingPeople)
            eventObject.setObject(due, forKey: EventKeyConstants.keyOfDue)
            
            eventObject.setObject(creator, forKey: EventKeyConstants.keyOfCreator)
            eventObject.setObject(members, forKey: EventKeyConstants.keyOfMembers)
            eventObject.setObject(active, forKey: EventKeyConstants.keyOfActive)
            eventObject.setObject(finished, forKey: EventKeyConstants.keyOfFinished)
            
            if conversationId != nil {
                eventObject.setObject(conversationId!, forKey: EventKeyConstants.keyOfConversationId)
            } else {
                self.delegate?.eventDidPost(succeed: false, errorReason: "cannot create conversation")
                return
            }
            
            if startTime != nil {
                eventObject.setObject(startTime!, forKey: EventKeyConstants.keyOfStartTime)
            }
            
            if endTime != nil {
                eventObject.setObject(endTime!, forKey: EventKeyConstants.keyOfEndTime)
            }
            
            if locationName != nil {
                eventObject.setObject(locationName!, forKey: EventKeyConstants.keyOfLocationName)
            }
            
            if location != nil {
                eventObject.setObject(location!, forKey: EventKeyConstants.keyOfLocation)
            }
            
            if expectedFee != nil {
                eventObject.setObject(expectedFee!, forKey: EventKeyConstants.keyOfExpectedFee)
            }
            
            if transportationMethod != nil {
                eventObject.setObject(transportationMethod!.rawValue, forKey: EventKeyConstants.keyOfTransportationMethod)
            }
            
            if note != nil {
                eventObject.setObject(note!, forKey: EventKeyConstants.keyOfNote)
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
        if let eventObject = AVObject(className: EventKeyConstants.classNameOfEvent) {
            eventObject.setObject(members, forKey: "members")
            eventObject.fetchWhenSave = true
            eventObject.incrementKey("remainingSeats")
        }
    }
}
