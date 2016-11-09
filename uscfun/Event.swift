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

/// possible errors with event
enum EventError: Error {
    case userNotAMember(String)
    case noSeatsLeft(String)
    case eventFinalized(String)
    case cannotCreateConversation(String)
    case cannotSaveDataToServer(String)
}

/// possible types of events
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

/// possible transportation methods of events
enum TransportationMethod: String {
    case selfDriving = "selfDriving"
    case uber = "uber"
    case metro = "metro"
}

/// The 'Event' class, event much include information of name, type, maximum capacity, 
/// remaining seats, minimum number of people required, and the due.
/// At the same time, the event can include optional information such as the start time,
/// the end time, the location name, the geographic information, the expected fee, the
/// transportation method, and additional information the creator want to provide.
/// The event will also include images uploaded by the user.
/// The class also include properties set by the system.

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
    
    /// This flag indicates that the event has been executed and it will not be shown at
    /// user's my attending events section
    var isCompleted: Bool
    
    /// The event belongs this school
    var school: String
    
    //--MARK: properties added by Leancloud
    
    /// The objectId fetched from Leancloud
    var objectId: String?
    
    /// The creation time fetched from Leancloud
    var createdAt: Date?
    
    /// The update time fetched from Leancloud
    var updatedAt: Date?

    
    //--MARK: computed event status flags
    
    /// This flag indicates if this event is pending. This flag is true
    /// when the due is still in the future and there are still remaining
    /// seats
    var isPending: Bool {
        return due > Date() && remainingSeats > 0
    }
    
    /// This flag indicates if this event is satisfied. This flag is true
    /// when the due is in the future and the minimum required number
    /// of attending people is met
    var isSatisfied: Bool {
        return due > Date() && totalSeats - remainingSeats >= minimumAttendingPeople
    }
    
    /// This flag indicates if this event is finalized. This flag is true either when the
    /// maximum number of members of this event is met or the number of members meets the
    /// minimum required attending people after the due.
    var isFinalized: Bool {
        return due > Date() && remainingSeats <= 0 || due < Date() && totalSeats - remainingSeats >= minimumAttendingPeople
    }
    
    /// This flag indicates if this event is failed. This flag is true
    /// when the due is passed but minimum required people is not met
    var isFailed: Bool {
        return due < Date() && totalSeats - remainingSeats < minimumAttendingPeople
    }
    
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
        self.isCompleted = false
        self.school = USCFunConstants.nameOfSchool
    }
    
    
    /// Creates an 'Event' instance from data fetch from Leancloud
    ///
    /// - parameter data: The AVObject fetched from Leancloud
    ///
    /// - returns: The new 'Event' instance or nil if any of required argument missing
    
    init?(data: AVObject?) {
        guard let data = data, let allKeys = data.allKeys() as? [String] else {
            print("no data or no all keys")
            return nil
        }
        
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
            print("no creator")
            return nil
        }
        self.creator = creator
        print(self.creator)
        
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

        guard allKeys.contains(EventKeyConstants.keyOfMembers), let members = data.value(forKey: EventKeyConstants.keyOfMembers) as? [AVUser] else {
            print("no members")
            return nil
        }
        self.members = members

        guard allKeys.contains(EventKeyConstants.keyOfCompleted), let isCompleted = data.value(forKey: EventKeyConstants.keyOfCompleted) as? Bool else {
            print("no isCompleted")
            return nil
        }
        self.isCompleted = isCompleted

        guard allKeys.contains(EventKeyConstants.keyOfSchool), let school = data.value(forKey: EventKeyConstants.keyOfSchool) as? String else {
            print("no school")
            return nil
        }
        self.school = school
        
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
    }
    
    /// Posts an event to server, it consists of three steps: creating transient conversation, creating conversation and save data to server
    ///
    /// - parameter handler:  handle the creation depending on the operation is successful or not
    /// - parameter succeeded: indicate if the operation is successful
    /// - parameter error: optional error information if operation fails
    
    func post(handler: @escaping (_ succeeded: Bool, _ error: Error?) -> Void) {
        createConversation(isTransient: true) {
            succeeded, error in
            if succeeded {
                self.createConversation(isTransient: false) {
                    succeeded, error in
                    if succeeded {
                        self.saveDataToSever() {
                            succeeded, error in
                            if succeeded {
                                handler(true, nil)
                            } else {
                                handler(false, error)
                            }
                        }
                    } else {
                        handler(false, error)
                    }
                }
            } else {
                handler(false, error)
            }
        }
    }
    
    /// Creates conversations associated with an event
    ///
    /// - parameter isTransient: indicates whether the conversation is transient. The transient conversation is used for public discussion. The non-transient conversation is used for private discussion among formal members
    /// - parameter handler:     handle the creation depending on the operation is successful or not
    /// - parameter succeeded: indicate if the operation is successful
    /// - parameter error: optional error information if operation fails
    
    private func createConversation(isTransient: Bool, handler: @escaping (_ succeeded: Bool, _ error: Error?) -> Void) {
        guard let client = AVIMClient(clientId: AVUser.current().username) else {
            handler(false, EventError.cannotCreateConversation("cannot create AVIMClient"))
            return
        }
        client.open() {
            succeeded, error in
            if succeeded {
                if isTransient {
                    client.createConversation(withName: nil, clientIds: [], attributes: nil, options: AVIMConversationOption.transient) {
                        conversation, error in
                        if error == nil {
                            guard let conversation = conversation else {
                                handler(false, EventError.cannotCreateConversation("cannot fetch transient conversation"))
                                return
                            }
                            self.transientConversationId = conversation.conversationId
                            handler(true, nil)
                        } else {
                            handler(false, error!)
                        }
                    }
                } else {
                    client.createConversation(withName: nil, clientIds: [self.creator.username]) {
                        conversation, error in
                        if error == nil {
                            guard let conversation = conversation else {
                                handler(false, EventError.cannotCreateConversation("cannot fetch conversation"))
                                return
                            }
                            self.conversationId = conversation.conversationId
                            handler(true, nil)
                        } else {
                            handler(false, error!)
                        }
                    }
                }
            } else {
                handler(false, EventError.cannotCreateConversation("cannot open AVIMClient"))
            }
        }
    }
    
    /// Saves data to server after associated conversations are created successfully
    ///
    /// - parameter handler:  handle the creation depending on the operation is successful or not
    /// - parameter succeeded: indicate if the operation is successful
    /// - parameter error: optional error information if operation fails
    
    private func saveDataToSever(handler: @escaping (_ succeeded: Bool, _ error: Error?) -> Void) {
        guard let eventObject = AVObject(className: EventKeyConstants.classNameOfEvent) else {
            handler(false, EventError.cannotSaveDataToServer("cannot create AVObject"))
            return
        }
        
        guard transientConversationId != "" else {
            handler(false, EventError.cannotSaveDataToServer("transient conversation id is missing"))
            return
        }
        
        guard conversationId != "" else {
            handler(false, EventError.cannotSaveDataToServer("conversation id is missing"))
            return
        }
        
        eventObject.setObject(name, forKey: EventKeyConstants.keyOfName)
        eventObject.setObject(type.rawValue, forKey: EventKeyConstants.keyOfType)
        eventObject.setObject(totalSeats, forKey: EventKeyConstants.keyOfTotalSeats)
        eventObject.setObject(remainingSeats, forKey: EventKeyConstants.keyOfRemainingSeats)
        eventObject.setObject(minimumAttendingPeople, forKey: EventKeyConstants.keyOfMinimumAttendingPeople)
        eventObject.setObject(due, forKey: EventKeyConstants.keyOfDue)
        
        eventObject.setObject(creator, forKey: EventKeyConstants.keyOfCreator)
        eventObject.setObject(members, forKey: EventKeyConstants.keyOfMembers)
        eventObject.setObject(transientConversationId, forKey: EventKeyConstants.keyOfTransientConversationId)
        eventObject.setObject(conversationId, forKey: EventKeyConstants.keyOfConversationId)
        eventObject.setObject(isCompleted, forKey: EventKeyConstants.keyOfCompleted)
        eventObject.setObject(school, forKey: EventKeyConstants.keyOfSchool)
        
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
            handler(true, nil)
        } else {
            handler(false, EventError.cannotSaveDataToServer("cannot save data to server"))
        }
    }
    
    
    /// Add a new member to the event
    ///
    /// - parameter newMember:   the new member that is about to join
    /// - parameter handler:  handle the creation depending on the operation is successful or not
    /// - parameter succeeded: indicate if the operation is successful
    /// - parameter error: optional error information if operation fails
    
    func add(newMember: AVUser, handler: (_ succeeded: Bool, _ error: Error?) -> Void) {
//        if let eventObject = AVObject(className: EventKeyConstants.classNameOfEvent, objectId: self.objectId) {
//            var membersCopy = members
//            membersCopy.append(newMember)
//            eventObject.setObject(membersCopy, forKey: EventKeyConstants.keyOfMembers)
//            eventObject.incrementKey(EventKeyConstants.keyOfRemainingSeats, byAmount: -1)
//            eventObject.fetchWhenSave = true
//
//            var error: NSError?
//            if eventObject.save(&error) {
//                let latestNumberOfRemainingSeats = eventObject.value(forKey: EventKeyConstants.keyOfRemainingSeats) as! Int
//                if latestNumberOfRemainingSeats == 0 {
//                    eventObject.setObject(true, forKey: EventKeyConstants.keyOfFinalized)
//                    if eventObject.save(&error) {
//                        members.append(newMember)
//                        remainingSeats -= 1
//                        handler(true, nil)
//                    } else {
//                        handler(false, error)
//                    }
//                }
//                else if latestNumberOfRemainingSeats < 0 {
//                    handler(false, EventError.noSeatsLeft("不好意思，人已经满了。"))
//                } else {
//                    members.append(newMember)
//                    remainingSeats -= 1
//                    handler(true, nil)
//                }
//            } else {
//                handler(false, error)
//            }
//        }
    }
    
    
    /// Remove a member from the event
    ///
    /// - parameter member:   the member that is about to quit
    /// - parameter handler:  handle the creation depending on the operation is successful or not
    /// - parameter succeeded: indicate if the operation is successful
    /// - parameter error: optional error information if operation fails
    
    func remove(member: AVUser, handler: (_ succeeded: Bool, _ error: Error?) -> Void) {
        
//        guard let memberIndex = members.index(of: member) else {
//            let error = EventError.userNotAMember("这个人没有参加这个活动呀!")
//            handler(false, error)
//            return
//        }
//        
//        if let eventObject = AVObject(className: EventKeyConstants.classNameOfEvent, objectId: self.objectId) {
//            
//            if eventObject.fetch() {
//                if eventObject.value(forKey: EventKeyConstants.keyOfFinalized) as! Bool {
//                    handler(false, EventError.eventFinalized("微活动已经约定，需其他成员同意后才能退出"))
//                    return
//                }
//            }
//            
//            var membersCopy = members
//            membersCopy.remove(at: memberIndex)
//            
//            eventObject.setObject(membersCopy, forKey: EventKeyConstants.keyOfMembers)
//            eventObject.incrementKey(EventKeyConstants.keyOfRemainingSeats, byAmount: 1)
//            
//            var error: NSError?
//            if eventObject.save(&error) {
//                members.remove(at: memberIndex)
//                remainingSeats += 1
//                handler(true, nil)
//            } else {
//                handler(false, error)
//            }
//        }
    }
}
