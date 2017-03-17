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
    case systemError(localizedDescriotion: String, debugDescription: String)
}

extension EventError: LocalizedError {
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

/// possible status of an event
enum EventStatus: CustomStringConvertible {
    
    /// This flag indicates if this event is pending. This flag is true
    /// when the due is still in the future and there are still remaining
    /// seats
    case isPending
    
    /// This flag indicates if this event has met the minimum requirement.
    /// This flag is true
    /// when the due is in the future and the minimum required number
    /// of attending people is met
    case isSecured
    
    /// This flag indicates if this event is finalized. This flag is true either when the
    /// maximum number of members of this event is met or the number of members meets the
    /// minimum required attending people after the due.
    case isFinalized
    
    /// This flag indicates if this event is failed. This flag is true
    /// when the due is passed but minimum required people is not met
    case isFailed
    
    /// This flag indicates that the event has been cancelled explicitly
    case isCancelled
    
    /// This flag indicates that the event has been executed and it will not be shown at
    /// user's my attending events section
    case isCompleted
    
    /// in case any situation not covered by the above
    case isUnKnown
    
    /// description of status
    var description: String {
        switch self {
        case .isPending:
            return "火热报名中"
        case .isSecured:
            return "达到最低人数"
        case .isFinalized:
            return "约定成功"
        case .isFailed:
            return "约定失败"
        case .isCancelled:
            return "已取消"
        case .isCompleted:
            return "已完结"
        case .isUnKnown:
            return "不晓得"
        }
    }
}

/// The 'Event' class, event must include information of name, type, maximum capacity,
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
    
    /// The maximum number of members of the event
    var maximumAttendingPeople: Int
    
    /// The remaining seats of the event, when posting the event, this number is the result
    /// of the target maximum number of members minus the number of people agreed to attend
    /// pre-hand.
    var remainingSeats: Int
    
    /// The minimumAttendingPeople is the minimum people required for this event, after the
    /// due, the event meets the minimumAttendingPeople will be considered as finalized,
    /// otherwise, the event will be cancled.
    var minimumAttendingPeople: Int
    
    /// The deadline for joining the event.
    /// After the due, no people can join the event.
    /// The event will be finalized or cancled.
    var due: Date
    
    //--MARK: optional settings
    
    /// The start time of the event
    var startTime: Date?
    
    /// The end time of the event
    var endTime: Date?
    
    /// The location name of the event
    var location: String?
    
    /// The geographical coordinate of the location
    var whereCreated: AVGeoPoint?
    
    /// The additional information that the creator wants others to know
    var note: String?
    
    /// The attached images with the event
    var imageUrl: [String]?
    
    //--MARK: system properties of event
    
    /// The creator of the event
    var createdBy: AVUser
    
    /// The chat room for general users to discuss the event to decide if they actually want
    /// to join
    var transientConversationId: String
    
    /// The chat room used after the event is finalized, it only contains the formal members
    /// of the event
    var conversationId: String
    
    /// The members of the event including creator
    var members: [AVUser]
    
    /// The flag indicates that the event has been cancelled explicitly
    var isCancelled: Bool
    
    /// The institution that the event belongs to
    var institution: String
    
    //--MARK: properties added by Leancloud
    
    /// The objectId fetched from Leancloud
    var objectId: String?
    
    /// The creation time fetched from Leancloud
    var createdAt: Date?
    
    /// The update time fetched from Leancloud
    var updatedAt: Date?

    //--MARK: indicators for individual member
    
    /// The members who indicates that he has already completed the event
    /// and no longer needs the chat room
    var completedBy: [AVUser]?
    
    /// The members who has unread message for this event
    var hasUnreadMessage: [AVUser]?
    
    var status: EventStatus {
        if isCancelled {
            return EventStatus.isCancelled
        } else if due > Date() && maximumAttendingPeople - remainingSeats >= minimumAttendingPeople && remainingSeats > 0 {
            return EventStatus.isSecured
        } else if due > Date() && remainingSeats > 0 {
            return EventStatus.isPending
        } else if due > Date() && remainingSeats <= 0 || due < Date() && maximumAttendingPeople - remainingSeats >= minimumAttendingPeople {
            return EventStatus.isFinalized
        } else if due < Date() && maximumAttendingPeople - remainingSeats < minimumAttendingPeople {
            return EventStatus.isFailed
        } else {
            return EventStatus.isUnKnown
        }
    }
    
    /// Creates an 'Event' instance with the required parameters
    ///
    /// - parameter name:                    The name of the event
    /// - parameter maximumAttendingPeople:  The maximum number of members that the event can include
    /// - parameter remainingSeats:          The remaining seats when the creator post the event
    /// - parameter minimumAttendingPeople:  The minimum required number of members the creator have for this event to be ready
    /// - parameter due:                     The deadline for joining the event
    /// - parameter createdBy:               The creator of this event
    ///
    /// - returns: The new 'Event' instance
    ///
    /// - warning: The transient conversation id for people to discuss the event
    ///   and the conversation id for event members to discuss the event,
    ///   neither of those conversations are created yet.
    
    init(name: String, maximumAttendingPeople: Int, remainingSeats: Int, minimumAttendingPeople: Int, due: Date, createdBy: AVUser) {
        self.name = name
        self.maximumAttendingPeople = maximumAttendingPeople
        self.remainingSeats = remainingSeats
        self.minimumAttendingPeople = minimumAttendingPeople
        self.due = due
        self.createdBy = createdBy
        self.transientConversationId = ""
        self.conversationId = ""
        self.members = [createdBy]
        self.isCancelled = false
        self.institution = USCFunConstants.nameOfSchool
    }
    
    
    /// Creates an 'Event' instance from data fetch from Leancloud
    ///
    /// - parameter data: The AVObject fetched from Leancloud
    ///
    /// - returns: The new 'Event' instance or nil if any of required argument missing
    
    init?(data: AVObject?) {
        guard let data = data else {
            print("failed to create Event from AVObject: data is nil")
            return nil
        }
        
        guard let name = data.value(forKey: EventKeyConstants.keyOfName) as? String else {
            print("failed to create Event from AVObject: no name")
            return nil
        }
        self.name = name

        guard let maximumAttendingPeople = data.value(forKey: EventKeyConstants.keyOfMaximumAttendingPeople) as? Int else {
            print("failed to create Event from AVObject: no maximum attending people")
            return nil
        }
        self.maximumAttendingPeople = maximumAttendingPeople

        guard let remainingSeats = data.value(forKey: EventKeyConstants.keyOfRemainingSeats) as? Int else {
            print("failed to create Event from AVObject: no remaining seats")
            return nil
        }
        self.remainingSeats = remainingSeats

        guard let minimumAttendingPeople = data.value(forKey: EventKeyConstants.keyOfMinimumAttendingPeople) as? Int else {
            print("failed to create Event from AVObject: no minimum attending people")
            return nil
        }
        self.minimumAttendingPeople = minimumAttendingPeople

        guard let due = data.value(forKey: EventKeyConstants.keyOfDue) as? Double else {
            print("failed to create Event from AVObject: no due")
            return nil
        }
        self.due = Date(timeIntervalSince1970: due)

        guard let createdBy = data.object(forKey: EventKeyConstants.keyOfCreatedBy) as? AVUser else {
            print("failed to create Event from AVObject: no createdBy")
            return nil
        }
        self.createdBy = createdBy
        
        guard let transientConversationId = data.value(forKey: EventKeyConstants.keyOfTransientConversationId) as? String else {
            print("failed to create Event from AVObject: no transient conversation")
            return nil
        }
        self.transientConversationId = transientConversationId
        
        guard let conversationId = data.value(forKey: EventKeyConstants.keyOfConversationId) as? String else {
            print("failed to create Event from AVObject: no conversation")
            return nil
        }
        self.conversationId = conversationId

        guard let members = data.value(forKey: EventKeyConstants.keyOfMembers) as? [AVUser] else {
            print("failed to create Event from AVObject: no members")
            return nil
        }
        self.members = members

        guard let isCancelled = data.value(forKey: EventKeyConstants.keyOfIsCancelled) as? Bool else {
            print("failed to create Event from AVObject: no isCancelled")
            return nil
        }
        self.isCancelled = isCancelled
        
        guard let institution = data.value(forKey: EventKeyConstants.keyOfInstitution) as? String else {
            print("failed to create Event from AVObject: no institution")
            return nil
        }
        self.institution = institution
        
        
        /// check other optional attributes
        if let startTime = data.value(forKey: EventKeyConstants.keyOfStartTime) as? Double {
            self.startTime = Date(timeIntervalSince1970: startTime)
        }
        
        if let endTime = data.value(forKey: EventKeyConstants.keyOfEndTime) as? Double {
            self.endTime = Date(timeIntervalSince1970: endTime)
        }
        
        if let location = data.value(forKey: EventKeyConstants.keyOfLocation) as? String {
            self.location = location
        }
        
        if let whereCreated = data.value(forKey: EventKeyConstants.keyOfWhereCreated) as? AVGeoPoint {
            self.whereCreated = whereCreated
        }
        
        if let note = data.value(forKey: EventKeyConstants.keyOfNote) as? String {
            self.note = note
        }
        
        /// check attributes added by Leancloud
        self.objectId = data.objectId
        self.createdAt = data.createdAt
        self.updatedAt = data.updatedAt
        
        /// check property for individual member
        if let completedBy = data.value(forKey: EventKeyConstants.keyOfCompletedBy) as? [AVUser] {
           self.completedBy = completedBy
        }
        
        if let hasUnreadMessage = data.value(forKey: EventKeyConstants.keyOfHasUnreadMessage) as? [AVUser] {
            self.hasUnreadMessage = hasUnreadMessage
        }
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
        let client = AVIMClient(clientId: AVUser.current()!.username!)
        client.open() {
            succeeded, error in
            if succeeded {
                if isTransient {
                    client.createConversation(withName: "讨论区:" + self.name, clientIds: [], attributes: nil, options: AVIMConversationOption.transient) {
                        conversation, error in
                        if error == nil {
                            guard let conversation = conversation else {
                                handler(false, EventError.systemError(localizedDescriotion: "网络错误，请稍后再试", debugDescription: "cannot fetch transient conversation"))
                                return
                            }
                            self.transientConversationId = conversation.conversationId!
                            handler(true, nil)
                        } else {
                            handler(false, error!)
                        }
                    }
                } else {
                    client.createConversation(withName: self.name, clientIds: []) {
                        conversation, error in
                        if error == nil {
                            guard let conversation = conversation else {
                                handler(false, EventError.systemError(localizedDescriotion: "网络错误，请稍后再试", debugDescription: "cannot fetch conversation"))
                                return
                            }
                            self.conversationId = conversation.conversationId!
                            handler(true, nil)
                        } else {
                            handler(false, error!)
                        }
                    }
                }
            } else {
                handler(false, EventError.systemError(localizedDescriotion: "网络错误，请稍后再试", debugDescription: "cannot open AVIMClient"))
            }
        }
    }
    
    /// Saves data to server after associated conversations are created successfully
    ///
    /// - parameter handler:  handle the creation depending on the operation is successful or not
    /// - parameter succeeded: indicate if the operation is successful
    /// - parameter error: optional error information if operation fails
    
    private func saveDataToSever(handler: @escaping (_ succeeded: Bool, _ error: Error?) -> Void) {
        let eventObject = AVObject(className: EventKeyConstants.classNameOfEvent)
        
        guard transientConversationId != "" else {
            handler(false, EventError.systemError(localizedDescriotion: "网络错误，请稍后再试", debugDescription: "transient conversation id is missing"))
            return
        }
        
        guard conversationId != "" else {
            handler(false, EventError.systemError(localizedDescriotion: "网络错误，请稍后再试", debugDescription: "conversation id is missing"))
            return
        }
        
        eventObject.setObject(name, forKey: EventKeyConstants.keyOfName)
        eventObject.setObject(maximumAttendingPeople, forKey: EventKeyConstants.keyOfMaximumAttendingPeople)
        eventObject.setObject(remainingSeats, forKey: EventKeyConstants.keyOfRemainingSeats)
        eventObject.setObject(minimumAttendingPeople, forKey: EventKeyConstants.keyOfMinimumAttendingPeople)
        eventObject.setObject(due.timeIntervalSince1970, forKey: EventKeyConstants.keyOfDue)
        
        eventObject.setObject(createdBy, forKey: EventKeyConstants.keyOfCreatedBy)
        eventObject.setObject(members, forKey: EventKeyConstants.keyOfMembers)
        eventObject.setObject(transientConversationId, forKey: EventKeyConstants.keyOfTransientConversationId)
        eventObject.setObject(conversationId, forKey: EventKeyConstants.keyOfConversationId)
        eventObject.setObject(isCancelled, forKey: EventKeyConstants.keyOfIsCancelled)
        eventObject.setObject(institution, forKey: EventKeyConstants.keyOfInstitution)
        
        if startTime != nil {
            eventObject.setObject(startTime!.timeIntervalSince1970, forKey: EventKeyConstants.keyOfStartTime)
        }
        
        if endTime != nil {
            eventObject.setObject(endTime!.timeIntervalSince1970, forKey: EventKeyConstants.keyOfEndTime)
        }
        
        if location != nil {
            eventObject.setObject(location!, forKey: EventKeyConstants.keyOfLocation)
        }
        
        if whereCreated != nil {
            eventObject.setObject(whereCreated!, forKey: EventKeyConstants.keyOfWhereCreated)
        }
        
        if note != nil {
            eventObject.setObject(note!, forKey: EventKeyConstants.keyOfNote)
        }
        
        var error: NSError?
        if eventObject.save(&error) {
            handler(true, nil)
        } else {
            handler(false,  EventError.systemError(localizedDescriotion: "网络错误，请稍后再试", debugDescription: error.debugDescription))
        }
    }
    
    /// Add a new member to the event
    ///
    /// - parameter newMember:   the new member that is about to join
    /// - parameter handler:     handle the creation depending on the operation is successful or not
    /// - parameter succeeded:   indicate if the operation is successful
    /// - parameter error:       optional error information if operation fails
    
    func add(newMember: AVUser, handler: (_ succeeded: Bool, _ error: Error?) -> Void) {
        
        let eventObject = AVObject(className: EventKeyConstants.classNameOfEvent, objectId: self.objectId!)
        let query = AVQuery()
        query.whereKey(EventKeyConstants.keyOfDue, greaterThan: Date().timeIntervalSince1970)
        query.whereKey(EventKeyConstants.keyOfRemainingSeats, greaterThanOrEqualTo: 1)
        
        let option = AVSaveOption()
        option.query = query
        option.fetchWhenSave = true
        eventObject.incrementKey(EventKeyConstants.keyOfRemainingSeats, byAmount: -1)
        eventObject.addUniqueObject(newMember, forKey: EventKeyConstants.keyOfMembers)
        do {
            try eventObject.save(with: option)
            self.remainingSeats -= 1
            self.members.append(newMember)
            handler(true, nil)
        } catch let error {
            print("cannot add member \(error.localizedDescription)")
            handler(false, EventError.systemError(localizedDescriotion: "不好意思，已经没有位置了。", debugDescription: error.localizedDescription))
        }
    }
    
    
    /// Remove a member from the event
    ///
    /// - parameter member:   the member that is about to quit
    /// - parameter handler:  handle the creation depending on the operation is successful or not
    /// - parameter succeeded: indicate if the operation is successful
    /// - parameter error: optional error information if operation fails
    
    func remove(member: AVUser, handler: (_ succeeded: Bool, _ error: Error?) -> Void) {
        
        guard let memberIndex = members.index(of: member) else {
            handler(false, EventError.systemError(localizedDescriotion: "用户没有参与此微活动", debugDescription: "user is not a member"))
            return
        }
        
        let eventObject = AVObject(className: EventKeyConstants.classNameOfEvent, objectId: self.objectId!)
        let query = AVQuery()
        query.whereKey(EventKeyConstants.keyOfDue, greaterThan: Date().timeIntervalSince1970)
        query.whereKey(EventKeyConstants.keyOfRemainingSeats, greaterThan: 0)
        
        let option = AVSaveOption()
        option.query = query
        
        eventObject.incrementKey(EventKeyConstants.keyOfRemainingSeats, byAmount: 1)
        eventObject.remove(member, forKey: EventKeyConstants.keyOfMembers)
        
        do {
            try eventObject.save(with: option)
            members.remove(at: memberIndex)
            remainingSeats += 1
            handler(true, nil)
        } catch let error {
            print("cannot remove member \(error.localizedDescription)")
            handler(false, EventError.systemError(localizedDescriotion: "活动已经约定成功或者已经过期了", debugDescription: error.localizedDescription))
        }
    }
    
    /// indicate that member has completed the event
    ///
    /// - parameter member:            the member that is about to complete the event
    /// - parameter handler:           handle the creation depending on the operation is successful or not
    /// - parameter succeeded:         indicate if the operation is successful
    /// - parameter error:             optional error information if operation fails
    
    func setComplete(for member: AVUser, handler: (_ succeeded: Bool, _ error: Error?) -> Void) {
        
        guard let _ = members.index(of: member) else {
            handler(false, EventError.systemError(localizedDescriotion: "用户没有参与此微活动", debugDescription: "user is not a member"))
            return
        }
        
        let eventObject = AVObject(className: EventKeyConstants.classNameOfEvent, objectId: self.objectId!)
        let query = AVQuery()
        let option = AVSaveOption()
        option.query = query
        option.fetchWhenSave = true
        eventObject.addUniqueObject(member, forKey: EventKeyConstants.keyOfCompletedBy)
        do {
            try eventObject.save(with: option)
            self.completedBy?.append(member)
            handler(true, nil)
        } catch let error {
            print("cannot complete event for member \(error.localizedDescription)")
            handler(false, EventError.systemError(localizedDescriotion: "无法完结活动，请检查网络", debugDescription: error.localizedDescription))
        }
    }
    
    /// indicate that member has read the message
    ///
    /// - parameter member:   the member that read the message
    /// - parameter handler:  handle the creation depending on the operation is successful or not
    /// - parameter succeeded: indicate if the operation is successful
    /// - parameter error: optional error information if operation fails
    
    func setRead(for member: AVUser, handler: (_ succeeded: Bool, _ error: Error?) -> Void) {
        
        guard let _ = members.index(of: member) else {
            handler(false, EventError.systemError(localizedDescriotion: "用户没有参与此微活动", debugDescription: "user is not a member"))
            return
        }
        
        guard let memberIndex = hasUnreadMessage?.index(of: member) else {
            handler(false, EventError.systemError(localizedDescriotion: "用户没有未读信息", debugDescription: "user has no unread message"))
            return
        }
        
        let eventObject = AVObject(className: EventKeyConstants.classNameOfEvent, objectId: self.objectId!)
        let query = AVQuery()
        let option = AVSaveOption()
        option.query = query
        
        eventObject.remove(member, forKey: EventKeyConstants.keyOfHasUnreadMessage)
        
        do {
            try eventObject.save(with: option)
            hasUnreadMessage?.remove(at: memberIndex)
            handler(true, nil)
        } catch let error {
            print("cannot remove member \(error.localizedDescription)")
            handler(false, EventError.systemError(localizedDescriotion: "无法设定已读，请检查网络", debugDescription: error.localizedDescription))
        }
    }
}

/// conforms to Comparable protocol so that Event can be used in OrderedDictionary
extension Event: Comparable {
    
    static func < (lhs: Event, rhs: Event) -> Bool {
        
        if lhs.status == .isFinalized && rhs.status != .isFinalized { return true }
        if lhs.status != .isFinalized && rhs.status == .isFinalized { return false }
        if lhs.status == .isSecured && rhs.status != .isSecured { return true }
        if lhs.status != .isSecured && rhs.status == .isSecured { return false }
        
        return lhs.due < rhs.due
    }
    
    static func == (lhs: Event, rhs: Event) -> Bool {
        return lhs.objectId == rhs.objectId
    }
}
