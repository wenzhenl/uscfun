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
import ChatKit

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
    
    /// in case any situation not covered by the above
    case isUnknown
    
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
        case .isUnknown:
            return "未知状态"
        }
    }
}

/// The 'Event' class, event must include information of name, type, maximum capacity,
/// remaining seats, minimum number of people required, and the due.
/// At the same time, the event can include optional information such as the start time,
/// the end time, the location name, the geographic information,
/// and additional information the creator want to provide.
/// The event will also include images uploaded by the user.
/// The class also include properties set by the system.

class Event {
    //--MARK: required information
    
    /// The name of the event
    private var _name: String
    
    var name: String {
        return _name
    }
    
    /// The maximum number of members of the event
    private var _maximumAttendingPeople: Int
    
    var maximumAttendingPeople: Int {
        return _maximumAttendingPeople
    }
    
    /// The remaining seats of the event, when posting the event, this number is the result
    /// of the target maximum number of members minus the number of people agreed to attend
    /// pre-hand.
    private var _remainingSeats: Int
    
    var remainingSeats: Int {
        return _remainingSeats
    }
    
    /// The minimumAttendingPeople is the minimum people required for this event, after the
    /// due, the event meets the minimumAttendingPeople will be considered as finalized,
    /// otherwise, the event will be cancled.
    private var _minimumAttendingPeople: Int
    
    var minimumAttendingPeople: Int {
        return _minimumAttendingPeople
    }
    
    /// The deadline for joining the event.
    /// After the due, no people can join the event.
    /// The event will be finalized or cancled.
    private var _due: Date
    
    var due: Date {
        return _due
    }
    
    //--MARK: optional settings
    
    /// The start time of the event
    private var _startTime: Date?
    
    var startTime: Date? {
        return _startTime
    }
    
    /// The end time of the event
    private var _endTime: Date?
    
    var endTime: Date? {
        return _endTime
    }
    
    /// The location name of the event
    private var _location: String?
    
    var location: String? {
        return _location
    }
    
    /// The geographical coordinate of the location
    private var _whereCreated: AVGeoPoint?
    
    var whereCreated: AVGeoPoint? {
        return _whereCreated
    }
    
    /// The additional information that the creator wants others to know
    private var _note: String?
    
    var note: String? {
        return _note
    }
    
    //--MARK: system properties of event
    
    /// The creator of the event
    private var _createdBy: AVUser
    
    var createdBy: AVUser {
        return _createdBy
    }
    
    /// The id of the associated conversation of the event
    private var _conversationId: String
    
    var conversationId: String {
        return _conversationId
    }
    
    /// The members of the event including creator
    private var _members: [AVUser]
    
    var members: [AVUser] {
        return _members
    }
    
    /// The members who still need the event
    private var _neededBy: [AVUser]
    
    var neededBy: [AVUser] {
        return _neededBy
    }
    
    /// The flag indicates that the event has been cancelled explicitly
    private var _isCancelled: Bool
    
    var isCancelled: Bool {
        return _isCancelled
    }
    
    /// The institution that the event belongs to
    private var _institution: String
    
    var institution: String {
        return _institution
    }
    
    //--MARK: properties added by Leancloud
    
    /// The objectId fetched from Leancloud
    private var _objectId: String?
    
    var objectId: String? {
        return _objectId
    }
    
    /// The creation time fetched from Leancloud
    private var _createdAt: Date?
    
    var createdAt: Date? {
        return _createdAt
    }
    
    /// The update time fetched from Leancloud
    private var _updatedAt: Date?
    
    var updatedAt: Date? {
        return _updatedAt
    }
    
    var status: EventStatus {
        let now = Date()
        if isCancelled {
            return EventStatus.isCancelled
        } else if due > now && maximumAttendingPeople - remainingSeats >= minimumAttendingPeople && remainingSeats > 0 {
            return EventStatus.isSecured
        } else if due > now && remainingSeats > 0 {
            return EventStatus.isPending
        } else if due > now && remainingSeats <= 0 || due <= now && maximumAttendingPeople - remainingSeats >= minimumAttendingPeople {
            return EventStatus.isFinalized
        } else if due <= now && maximumAttendingPeople - remainingSeats < minimumAttendingPeople {
            return EventStatus.isFailed
        } else {
            return EventStatus.isUnknown
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
    /// - warning: the conversation id for discussing the event
    ///   is not created yet.
    
    init(name: String, maximumAttendingPeople: Int, remainingSeats: Int, minimumAttendingPeople: Int, due: Date, createdBy: AVUser) {
        self._name = name
        self._maximumAttendingPeople = maximumAttendingPeople
        self._remainingSeats = remainingSeats
        self._minimumAttendingPeople = minimumAttendingPeople
        self._due = due
        self._createdBy = createdBy
        self._conversationId = ""
        self._members = [createdBy]
        self._neededBy = [createdBy]
        self._isCancelled = false
        self._institution = createdBy.email!.institutionCode!
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
        self._name = name

        guard let maximumAttendingPeople = data.value(forKey: EventKeyConstants.keyOfMaximumAttendingPeople) as? Int else {
            print("failed to create Event from AVObject: no maximum attending people")
            return nil
        }
        self._maximumAttendingPeople = maximumAttendingPeople

        guard let remainingSeats = data.value(forKey: EventKeyConstants.keyOfRemainingSeats) as? Int else {
            print("failed to create Event from AVObject: no remaining seats")
            return nil
        }
        self._remainingSeats = remainingSeats

        guard let minimumAttendingPeople = data.value(forKey: EventKeyConstants.keyOfMinimumAttendingPeople) as? Int else {
            print("failed to create Event from AVObject: no minimum attending people")
            return nil
        }
        self._minimumAttendingPeople = minimumAttendingPeople

        guard let due = data.value(forKey: EventKeyConstants.keyOfDue) as? Double else {
            print("failed to create Event from AVObject: no due")
            return nil
        }
        self._due = Date(timeIntervalSince1970: due)

        guard let createdBy = data.object(forKey: EventKeyConstants.keyOfCreatedBy) as? AVUser else {
            print("failed to create Event from AVObject: no createdBy")
            return nil
        }
        self._createdBy = createdBy
        
        guard let conversation = data.value(forKey: EventKeyConstants.keyOfConversation) as? AVObject, let conversationId = conversation.objectId else {
            print("failed to create Event from AVObject: no conversation")
            return nil
        }
        self._conversationId = conversationId

        guard let members = data.value(forKey: EventKeyConstants.keyOfMembers) as? [AVUser] else {
            print("failed to create Event from AVObject: no members")
            return nil
        }
        self._members = members

        guard let neededBy = data.value(forKey: EventKeyConstants.keyOfNeededBy) as? [AVUser] else {
            print("failed to create Event from AVObject: no neededBy")
            return nil
        }
        self._neededBy = neededBy
        
        guard let isCancelled = data.value(forKey: EventKeyConstants.keyOfIsCancelled) as? Bool else {
            print("failed to create Event from AVObject: no isCancelled")
            return nil
        }
        self._isCancelled = isCancelled
        
        guard let institution = data.value(forKey: EventKeyConstants.keyOfInstitution) as? String else {
            print("failed to create Event from AVObject: no institution")
            return nil
        }
        self._institution = institution
        
        
        /// check other optional attributes
        if let startTime = data.value(forKey: EventKeyConstants.keyOfStartTime) as? Double {
            self._startTime = Date(timeIntervalSince1970: startTime)
        }
        
        if let endTime = data.value(forKey: EventKeyConstants.keyOfEndTime) as? Double {
            self._endTime = Date(timeIntervalSince1970: endTime)
        }
        
        if let location = data.value(forKey: EventKeyConstants.keyOfLocation) as? String {
            self._location = location
        }
        
        if let whereCreated = data.value(forKey: EventKeyConstants.keyOfWhereCreated) as? AVGeoPoint {
            self._whereCreated = whereCreated
        }
        
        if let note = data.value(forKey: EventKeyConstants.keyOfNote) as? String {
            self._note = note
        }
        
        /// check attributes added by Leancloud
        self._objectId = data.objectId
        self._createdAt = data.createdAt
        self._updatedAt = data.updatedAt
    }
    
    /// Posts an event to server, it consists of three steps: creating transient conversation, creating conversation and save data to server
    ///
    /// - parameter handler:  handle the creation depending on the operation is successful or not
    /// - parameter succeeded: indicate if the operation is successful
    /// - parameter error: optional error information if operation fails
    
    func post(handler: @escaping (_ succeeded: Bool, _ error: NSError?) -> Void) {
        
        LCChatKit.sharedInstance().conversationService.createConversation(withMembers: [], type: LCCKConversationType.group, unique: false) {
            conversation, error in
            guard let conversationId = conversation?.conversationId else {
                handler(false, error as NSError?)
                return
            }
            print("successfully created conversation with id \(conversationId)")
            self._conversationId = conversationId
            self.saveDataToSever {
                succeeded, error in
                if succeeded {
                    print("successfully created event \(self.name)")
                }
                handler(succeeded, error)
            }
        }
    }
    
    /// Saves data to server after associated conversations are created successfully
    ///
    /// - parameter handler:  handle the creation depending on the operation is successful or not
    /// - parameter succeeded: indicate if the operation is successful
    /// - parameter error: optional error information if operation fails
    
    private func saveDataToSever(handler: @escaping (_ succeeded: Bool, _ error: NSError?) -> Void) {
        
        guard conversationId != "" else {
            print("failed to save event data: conversationId is missing")
            handler(false, NSError(domain: USCFunErrorConstants.domain,
                                   code: USCFunErrorConstants.kUSCFunErrorEventConversationIdMissing,
                                   userInfo: [NSLocalizedDescriptionKey: "failed to save event data: conversationId is missing"]))
            return
        }
        
        let eventObject = AVObject(className: EventKeyConstants.classNameOfEvent)
        
        eventObject.setObject(name, forKey: EventKeyConstants.keyOfName)
        eventObject.setObject(maximumAttendingPeople, forKey: EventKeyConstants.keyOfMaximumAttendingPeople)
        eventObject.setObject(remainingSeats, forKey: EventKeyConstants.keyOfRemainingSeats)
        eventObject.setObject(minimumAttendingPeople, forKey: EventKeyConstants.keyOfMinimumAttendingPeople)
        eventObject.setObject(due.timeIntervalSince1970, forKey: EventKeyConstants.keyOfDue)
        
        eventObject.setObject(createdBy, forKey: EventKeyConstants.keyOfCreatedBy)
        eventObject.setObject(members, forKey: EventKeyConstants.keyOfMembers)
        eventObject.setObject(neededBy, forKey: EventKeyConstants.keyOfNeededBy)
        
        let conversation = AVObject(className: EventKeyConstants.classNameOfConversation, objectId: conversationId)
        eventObject.setObject(conversation, forKey: EventKeyConstants.keyOfConversation)
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
            handler(false, error)
        }
    }
    
    /// Add a new member to the event
    ///
    /// - parameter newMember:   the new member that is about to join
    /// - parameter handler:     handle the creation depending on the operation is successful or not
    /// - parameter succeeded: indicate if the operation is successful
    /// - parameter error:       optional error information if operation fails
    
    func add(newMember: AVUser, handler: (_ succeeded: Bool, _ error: NSError?) -> Void) {
        
        let eventObject = AVObject(className: EventKeyConstants.classNameOfEvent, objectId: self.objectId!)
        let query = AVQuery()
        query.whereKey(EventKeyConstants.keyOfDue, greaterThan: Date().timeIntervalSince1970)
        query.whereKey(EventKeyConstants.keyOfRemainingSeats, greaterThanOrEqualTo: 1)
        query.whereKey(EventKeyConstants.keyOfIsCancelled, equalTo: false)
        
        let option = AVSaveOption()
        option.query = query
        eventObject.incrementKey(EventKeyConstants.keyOfRemainingSeats, byAmount: -1)
        eventObject.addUniqueObject(newMember, forKey: EventKeyConstants.keyOfMembers)
        eventObject.addUniqueObject(newMember, forKey: EventKeyConstants.keyOfNeededBy)
        do {
            try eventObject.save(with: option)
            self._remainingSeats -= 1
            self._members.append(newMember)
            self._neededBy.append(newMember)
            handler(true, nil)
        } catch let error {
            print("cannot add member \(error)")
            if (error as NSError).code == USCFunErrorConstants.kLeanCloudErrorSaveOptionError {
                handler(false, NSError(domain: USCFunErrorConstants.domain,
                                       code: USCFunErrorConstants.kUSCFunErrorEventAddMemberFailed,
                                       userInfo: [NSLocalizedDescriptionKey: "failed to add member: passed joining time"]))
            } else {
                handler(false, error as NSError?)
            }
        }
    }
    
    
    /// Remove a member from the event
    ///
    /// - parameter member:   the member that is about to quit
    /// - parameter handler:  handle the creation depending on the operation is successful or not
    /// - parameter succeeded: indicate if the operation is successful
    /// - parameter error: optional error information if operation fails
    
    func remove(member: AVUser, handler: (_ succeeded: Bool, _ error: NSError?) -> Void) {
        
        guard let memberIndex = members.index(of: member), let neededIndex = neededBy.index(of: member) else {
            handler(false, NSError(domain: USCFunErrorConstants.domain,
                                   code: USCFunErrorConstants.kUSCFunErrorEventInvalidMember,
                                   userInfo: [NSLocalizedDescriptionKey: "failed to remove member: not a member"]))
            return
        }
        
        let eventObject = AVObject(className: EventKeyConstants.classNameOfEvent, objectId: self.objectId!)
        let query = AVQuery()
        query.whereKey(EventKeyConstants.keyOfDue, greaterThan: Date().timeIntervalSince1970)
        query.whereKey(EventKeyConstants.keyOfRemainingSeats, greaterThan: 0)
        query.whereKey(EventKeyConstants.keyOfIsCancelled, equalTo: false)

        let option = AVSaveOption()
        option.query = query
        
        eventObject.incrementKey(EventKeyConstants.keyOfRemainingSeats, byAmount: 1)
        eventObject.remove(member, forKey: EventKeyConstants.keyOfMembers)
        eventObject.remove(member, forKey: EventKeyConstants.keyOfNeededBy)
        do {
            try eventObject.save(with: option)
            self._remainingSeats += 1
            self._members.remove(at: memberIndex)
            self._neededBy.remove(at: neededIndex)
            handler(true, nil)
        } catch let error {
            print("cannot remove member \(error)")
            if (error as NSError).code == USCFunErrorConstants.kLeanCloudErrorSaveOptionError {
                handler(false, NSError(domain: USCFunErrorConstants.domain,
                                       code: USCFunErrorConstants.kUSCFunErrorEventRemoveMemberFailed,
                                       userInfo: [NSLocalizedDescriptionKey: "failed to remove member: passed removing time"]))
            } else {
                handler(false, error as NSError?)
            }
        }
    }
    
    /// Update an event
    ///
    /// - parameter newDue:                     the new deadline for joining
    /// - parameter newMaximumAttendingPeople:  the new maximum number of members that the event can include
    /// - parameter newStartTime:               the new start time of the event
    /// - parameter newEndTime:                 the new end time of the event
    /// - parameter newLocation:                the new location of the event
    /// - parameter newWhereCreated:            the new geographical coordinate of the location
    /// - parameter newNote:                    the new additional information that the creator wants others to know
    /// - parameter handler:                    handle the creation depending on the operation is successful or not
    /// - parameter succeeded: indicate if the operation is successful
    /// - parameter error:                      optional error information if operation fails
    
    func update(newDue: Date, newMaximumAttendingPeople: Int, newMinimumAttendingPeople: Int, newStartTime: Date?, newEndTime: Date?, newLocation: String?, newWhereCreated: AVGeoPoint?, newNote: String?, handler: (_ succeeded: Bool, _ error: NSError?) -> Void) {
        
        guard createdBy == AVUser.current()! else {
            handler(false, NSError(domain: USCFunErrorConstants.domain,
                                   code: USCFunErrorConstants.kUSCFunErrorEventInvalidCreatedBy,
                                   userInfo: [NSLocalizedDescriptionKey: "failed to update event: not creator"]))
            return
        }
        
        guard newDue >= due && newMaximumAttendingPeople >= maximumAttendingPeople && newMinimumAttendingPeople <= minimumAttendingPeople && newMinimumAttendingPeople >= 2 else {
            handler(false, NSError(domain: USCFunErrorConstants.domain,
                                   code: USCFunErrorConstants.kUSCFunErrorEventInvalidUpdateData,
                                   userInfo: [NSLocalizedDescriptionKey: "failed to update event: unexpected due or maximum attending people"]))
            return
        }
        
        let eventObject = AVObject(className: EventKeyConstants.classNameOfEvent, objectId: self.objectId!)
        let query = AVQuery()
        let option = AVSaveOption()
        option.query = query
        option.fetchWhenSave = true
        
        if newDue > due {
            eventObject.setObject(newDue.timeIntervalSince1970, forKey: EventKeyConstants.keyOfDue)
        }
        if newMaximumAttendingPeople > maximumAttendingPeople {
            eventObject.setObject(newMaximumAttendingPeople, forKey: EventKeyConstants.keyOfMaximumAttendingPeople)
            eventObject.incrementKey(EventKeyConstants.keyOfRemainingSeats, byAmount: NSNumber(integerLiteral: newMaximumAttendingPeople - maximumAttendingPeople))
        }
        if newMinimumAttendingPeople < minimumAttendingPeople {
            eventObject.setObject(newMinimumAttendingPeople, forKey: EventKeyConstants.keyOfMinimumAttendingPeople)
        }
        eventObject.setObject(newStartTime?.timeIntervalSince1970, forKey: EventKeyConstants.keyOfStartTime)
        eventObject.setObject(newEndTime?.timeIntervalSince1970, forKey: EventKeyConstants.keyOfEndTime)
        eventObject.setObject(newLocation, forKey: EventKeyConstants.keyOfLocation)
        eventObject.setObject(newWhereCreated, forKey: EventKeyConstants.keyOfWhereCreated)
        eventObject.setObject(newNote, forKey: EventKeyConstants.keyOfNote)
        do {
            try eventObject.save(with: option)
            if let updatedDue = eventObject.value(forKey: EventKeyConstants.keyOfDue) as? Double {
                self._due = Date(timeIntervalSince1970: updatedDue)
            }
            if let updatedMaximumAttendingPeople = eventObject.value(forKey: EventKeyConstants.keyOfMaximumAttendingPeople) as? Int {
                self._maximumAttendingPeople = updatedMaximumAttendingPeople
            }
            if let updatedRemainingSeats = eventObject.value(forKey: EventKeyConstants.keyOfRemainingSeats) as? Int {
                self._remainingSeats = updatedRemainingSeats
            }
            if let updatedMinimumAttendingPeople = eventObject.value(forKey: EventKeyConstants.keyOfMinimumAttendingPeople) as? Int {
                self._minimumAttendingPeople = updatedMinimumAttendingPeople
            }
            if let updatedStartTime = eventObject.value(forKey: EventKeyConstants.keyOfStartTime) as? Double {
                self._startTime = Date(timeIntervalSince1970: updatedStartTime)
            }
            if let updatedEndTime = eventObject.value(forKey: EventKeyConstants.keyOfEndTime) as? Double {
                self._endTime = Date(timeIntervalSince1970: updatedEndTime)
            }
            if let updatedLocation = eventObject.value(forKey: EventKeyConstants.keyOfLocation) as? String {
                self._location = updatedLocation
            }
            if let updatedWhereCreated = eventObject.value(forKey: EventKeyConstants.keyOfWhereCreated) as? AVGeoPoint {
                self._whereCreated = updatedWhereCreated
            }
            if let updatedNote = eventObject.value(forKey: EventKeyConstants.keyOfNote) as? String {
                self._note = updatedNote
            }
            
            handler(true, nil)
        } catch let error {
            print("cannot update event \(error)")
            handler(false, error as NSError?)
        }
    }
    
    /// Cancel the event
    ///
    /// - parameter handler:  handle the creation depending on the operation is successful or not
    /// - parameter succeeded: indicate if the operation is successful
    /// - parameter error: optional error information if operation fails
    
    func cancel(handler: (_ succeeded: Bool, _ error: NSError?) -> Void) {
        
        guard createdBy == AVUser.current()! else {
            handler(false, NSError(domain: USCFunErrorConstants.domain,
                                   code: USCFunErrorConstants.kUSCFunErrorEventInvalidCreatedBy,
                                   userInfo: [NSLocalizedDescriptionKey: "failed to cancel event: not creator"]))
            return
        }
        
        guard members.count == 1 else {
            handler(false, NSError(domain: USCFunErrorConstants.domain,
                                   code: USCFunErrorConstants.kUSCFunErrorEventCancelFailedDueToExistingMember,
                                   userInfo: [NSLocalizedDescriptionKey: "failed to cancel event: already attended by people"]))
            return
        }
        
        let eventObject = AVObject(className: EventKeyConstants.classNameOfEvent, objectId: self.objectId!)
        let query = AVQuery()
        query.whereKey(EventKeyConstants.keyOfMembers, equalTo: [AVUser.current()!])
        
        let option = AVSaveOption()
        option.query = query
        
        eventObject.setObject(true, forKey: EventKeyConstants.keyOfIsCancelled)
        do {
            try eventObject.save(with: option)
            self._isCancelled = true
            handler(true, nil)
        } catch let error {
            print("cannot cancel event \(error)")
            handler(false, error as NSError?)
        }
    }

    /// indicate that member doesn't need the event
    ///
    /// - parameter member:            the member that is about to close the event
    /// - parameter handler:           handle the creation depending on the operation is successful or not
    /// - parameter succeeded:         indicate if the operation is successful
    /// - parameter error:             optional error information if operation fails
    
    func close(for member: AVUser, handler: (_ succeeded: Bool, _ error: NSError?) -> Void) {
        
        guard let _ = members.index(of: member), let neededIndex = neededBy.index(of: member) else {
            handler(false, NSError(domain: USCFunErrorConstants.domain,
                                   code: USCFunErrorConstants.kUSCFunErrorEventInvalidMember,
                                   userInfo: [NSLocalizedDescriptionKey: "failed to close event: not a member"]))
            return
        }
        
        let eventObject = AVObject(className: EventKeyConstants.classNameOfEvent, objectId: self.objectId!)
        let query = AVQuery()
        let option = AVSaveOption()
        option.query = query
        option.fetchWhenSave = true
        eventObject.remove(member, forKey: EventKeyConstants.keyOfNeededBy)
        do {
            try eventObject.save(with: option)
            self._neededBy.remove(at: neededIndex)
            handler(true, nil)
        } catch let error {
            print("cannot close event for member \(error)")
            handler(false, error as NSError?)
        }
    }
}

/// conforms to Comparable protocol so that Event can be used in OrderedDictionary
extension Event: Comparable {
    
    static func < (lhs: Event, rhs: Event) -> Bool {
        
        /// public events
        if !lhs.members.contains(AVUser.current()!) && !rhs.members.contains(AVUser.current()!) {
            return lhs.createdAt! > rhs.createdAt!
        }
        
        /// my ongoing events
        if lhs.members.contains(AVUser.current()!) && rhs.members.contains(AVUser.current()!) {
            if lhs.status == .isFinalized && rhs.status != .isFinalized { return true }
            if lhs.status != .isFinalized && rhs.status == .isFinalized { return false }
            return lhs.updatedAt! > rhs.updatedAt!
        }
        
        /// order is: finalized < secured < pending < failed < cancelled
        if lhs.status == .isFinalized && rhs.status != .isFinalized { return true }
        if lhs.status != .isFinalized && rhs.status == .isFinalized { return false }
        if lhs.status == .isSecured && rhs.status != .isSecured { return true }
        if lhs.status != .isSecured && rhs.status == .isSecured { return false }
        if lhs.status == .isCancelled && rhs.status != .isCancelled { return false }
        if lhs.status != .isCancelled && rhs.status == .isCancelled { return true }
        if lhs.status == .isFailed && rhs.status != .isFailed { return false }
        if lhs.status != .isFailed && rhs.status == .isFailed { return true }
        
        return lhs.due < rhs.due
    }
    
    static func == (lhs: Event, rhs: Event) -> Bool {
        return lhs.objectId == rhs.objectId
    }
}
