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

enum EventError: Error {
    case userNotAMember(String)
    case noSeatsLeft(String)
    case eventFinalized(String)
}

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
            return #imageLiteral(resourceName: "birthday")
        case .travel:
            return #imageLiteral(resourceName: "travel")
        case .study:
            return #imageLiteral(resourceName: "birthday")
        case .other:
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

/// description of Event class
class Event {
    //--MARK: required information
    
    /// The name of the event
    var name: String
    
    /// The type of the event
    var type: EventType
    
    /// The total seats of the event which means the maximum number of members of the event
    var totalSeats: Int
    
    /// The remaining seats of the event, when posting the event, this number is the result
    /// of the target maximum number of members minus the number of people agreed to attend
    /// pre-hand.
    var remainingSeats: Int
    
    /// The minimumAttendingPeople is the minimum people required for this event, after the
    /// due, the event meets the minimumAttendingPeople will be considered as finalized,
    /// otherwise, the event will be cancled.
    var minimumAttendingPeople: Int
    
    /// After the due, no people can join the event. The event will be finalized or cancled.
    var due: Date
    
    //--MARK: optional settings
    
    /// The start time of the event
    var startTime: Date?
    
    /// The end time of the event
    var endTime: Date?
    
    /// The location name of the event
    var locationName: String?
    
    /// The longitude and latitude of the location
    var location: AVGeoPoint?
    
    /// The expected fee of the event
    var expectedFee: Double?
    
    /// The transportantion method of the event
    var transportationMethod: TransportationMethod?
    
    /// Additional information that the creator wants other to know
    var note: String?
    
    /// The attached images with the event
    var imageUrl: [String]?
    
    //--MARK: system properties of event
    
    /// The creator of the event
    var creator: AVUser
    
    /// The chat room for general users to discuss the event to decide if they actually want
    /// to join
    var transientConversationId: String
    
    /// The chat room used after the event is finalized, it only contains the formal members
    /// of the event
    var conversationId: String
    
    /// The members of the event
    var members: [AVUser]
    
    /// This flag indicates if this event is finalized. This flag is true either when the
    /// maximum number of members of this event is met or the number of members meets the
    /// minimum required attending people after the due.
    var finalized: Bool
    
    /// This flag indicates that the event has been executed and it will not be shown at
    /// user's my attending events section
    var finished: Bool
    
    /// The event belongs this school
    var school: String
    
    //--MARK: properties added by Leancloud
    
    /// The objectId fetched from Leancloud
    var objectId: String?
    
    /// The creation time fetched from Leancloud
    var createdAt: Date?
    
    /// The update time fetched from Leancloud
    var updatedAt: Date?
    
    // MARK: delegate for handling posting process
    
    /// The delegate of the event
    var delegate: EventDelegate?
    
    
    /// Creates an 'Event' instance with the required parameters
    ///
    /// - parameter name:                    The name of the event
    /// - parameter type:                    The type of the event, predefined in enum EventType
    /// - parameter totalSeats:              The maximum number of members that the event can include
    /// - parameter remainingSeats:          The remaining seats when the creator post the event
    /// - parameter minimumAttendingPeople:  The minimum required number of members the creator have for this event to be ready
    /// - parameter due:                     The last moment that people can join this event
    /// - parameter creator:                 The creator of this event
    ///
    /// - returns: The new 'Event' instance
    ///
    /// - warning: The transient conversation id for people to discuss the event and the conversation id for event members to discuss the event, neither of those conversations are created yet.
    
    init(name: String, type: EventType, totalSeats: Int, remainingSeats: Int, minimumAttendingPeople: Int, due: Date, creator: AVUser) {
        self.name = name
        self.type = type
        self.totalSeats = totalSeats
        self.remainingSeats = remainingSeats
        self.minimumAttendingPeople = minimumAttendingPeople
        self.due = due
        self.creator = creator
        self.transientConversationId = ""
        self.conversationId = ""
        self.members = [creator]
        self.finalized = false
        self.finished = false
        self.school = USCFunConstants.nameOfSchool
    }
    
    
    /// Creates an 'Event' instance from data fetch from Leancloud
    ///
    /// - parameter data: The AVObject fetched from Leancloud
    ///
    /// - returns: The new 'Event' instance or nil if any of required argument missing
    
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

                guard allKeys.contains(EventKeyConstants.keyOfMinimumAttendingPeople), let minimumAttendingPeople = data.value(forKey: EventKeyConstants.keyOfMinimumAttendingPeople) as? Int else {
                    print("no minimum seats")
                    return nil
                }
                self.minimumAttendingPeople = minimumAttendingPeople

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

                guard allKeys.contains(EventKeyConstants.keyOfFinalized), let finalized = data.value(forKey: EventKeyConstants.keyOfFinalized) as? Bool else {
                    print("no finalized")
                    return nil
                }
                self.finalized = finalized

                guard allKeys.contains(EventKeyConstants.keyOfFinished), let finished = data.value(forKey: EventKeyConstants.keyOfFinished) as? Bool else {
                    print("no finished")
                    return nil
                }
                self.finished = finished

                guard allKeys.contains(EventKeyConstants.keyOfTransientConversationId), let transientConversationId = data.value(forKey: EventKeyConstants.keyOfTransientConversationId) as? String else {
                    print("no transient conversation")
                    return nil
                }
                self.transientConversationId = transientConversationId

                guard allKeys.contains(EventKeyConstants.keyOfConversationId), let conversationId = data.value(forKey: EventKeyConstants.keyOfConversationId) as? String else {
                    print("no conversation")
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
                self.school = USCFunConstants.nameOfSchool
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
        self.minimumAttendingPeople = 0
        self.due = Date()
        return nil
    }
    
    func post() {
        print("=================== POSTING EVENT ==================================")
        if let client = AVIMClient(clientId: AVUser.current().username) {
            client.open() {
                succeeded, error in
                if succeeded {
                    client.createConversation(withName: nil, clientIds: [], attributes: nil, options: AVIMConversationOption.transient) {
                        conversation, error in
                        if error == nil {
                            print("create transient conversation successfully")
                            if let conversation = conversation {
                                print("CREATED CONVERSATION")
                                print("transient_conversation_id: \(conversation.conversationId)----------")
                                print("transient_conversation_name: \(conversation.name)")
                                self.transientConversationId = conversation.conversationId
                                
                                client.createConversation(withName: nil, clientIds: [AVUser.current().username]) {
                                    conversation, error in
                                    if error == nil {
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
            eventObject.setObject(minimumAttendingPeople, forKey: EventKeyConstants.keyOfMinimumAttendingPeople)
            eventObject.setObject(due, forKey: EventKeyConstants.keyOfDue)
            
            eventObject.setObject(creator, forKey: EventKeyConstants.keyOfCreator)
            eventObject.setObject(members, forKey: EventKeyConstants.keyOfMembers)
            eventObject.setObject(finalized, forKey: EventKeyConstants.keyOfFinalized)
            eventObject.setObject(finished, forKey: EventKeyConstants.keyOfFinished)
            eventObject.setObject(school, forKey: EventKeyConstants.keyOfSchool)

            if transientConversationId != nil {
                eventObject.setObject(transientConversationId!, forKey: EventKeyConstants.keyOfTransientConversationId)
            } else {
                self.delegate?.eventDidPost(succeed: false, errorReason: "cannot create transient conversation")
                return
            }
            
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
    
    func add(newMember: AVUser, handler: (_ succeed: Bool, _ error: Error?) -> Void) {
        if let eventObject = AVObject(className: EventKeyConstants.classNameOfEvent, objectId: self.objectId) {
            var membersCopy = members
            membersCopy.append(newMember)
            eventObject.setObject(membersCopy, forKey: EventKeyConstants.keyOfMembers)
            eventObject.incrementKey(EventKeyConstants.keyOfRemainingSeats, byAmount: -1)
            eventObject.fetchWhenSave = true

            var error: NSError?
            if eventObject.save(&error) {
                let latestNumberOfRemainingSeats = eventObject.value(forKey: EventKeyConstants.keyOfRemainingSeats) as! Int
                if latestNumberOfRemainingSeats == 0 {
                    eventObject.setObject(true, forKey: EventKeyConstants.keyOfFinalized)
                    if eventObject.save(&error) {
                        members.append(newMember)
                        remainingSeats -= 1
                        handler(true, nil)
                    } else {
                        handler(false, error)
                    }
                }
                else if latestNumberOfRemainingSeats < 0 {
                    handler(false, EventError.noSeatsLeft("不好意思，人已经满了。"))
                } else {
                    members.append(newMember)
                    remainingSeats -= 1
                    handler(true, nil)
                }
            } else {
                handler(false, error)
            }
        }
    }
    
    func remove(member: AVUser, handler: (_ succeed: Bool, _ error: Error?) -> Void) {
        
        guard let memberIndex = members.index(of: member) else {
            let error = EventError.userNotAMember("这个人没有参加这个活动呀!")
            handler(false, error)
            return
        }
        
        if let eventObject = AVObject(className: EventKeyConstants.classNameOfEvent, objectId: self.objectId) {
            
            if eventObject.fetch() {
                if eventObject.value(forKey: EventKeyConstants.keyOfFinalized) as! Bool {
                    handler(false, EventError.eventFinalized("微活动已经约定，需其他成员同意后才能退出"))
                    return
                }
            }
            
            var membersCopy = members
            membersCopy.remove(at: memberIndex)
            
            eventObject.setObject(membersCopy, forKey: EventKeyConstants.keyOfMembers)
            eventObject.incrementKey(EventKeyConstants.keyOfRemainingSeats, byAmount: 1)
            
            var error: NSError?
            if eventObject.save(&error) {
                members.remove(at: memberIndex)
                remainingSeats += 1
                handler(true, nil)
            } else {
                handler(false, error)
            }
        }
    }
}
