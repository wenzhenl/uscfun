//
//  USCFunConstants.swift
//  uscfun
//
//  Created by Wenzheng Li on 8/25/16.
//  Copyright © 2016 Wenzheng Li. All rights reserved.
//

import Foundation
import UIKit

class USCFunConstants {
    
    static let minimumPasswordLength = 5
    static let storyboardIdentifierOfCustomizedAlertViewController = "Customized Alert View Controller"
    static let nameOfSchool = "usc"
    
    static let avatarColorOptions = [UIColor.avatarBlue, UIColor.avatarCyan, UIColor.avatarPink, UIColor.avatarGolden, UIColor.avatarOrange, UIColor.avatarTomato, UIColor.avatarGreen]
}

struct UserKeyConstants {
    static let keyOfNickname = "nickname"
    static let keyOfAvatarUrl = "avatarUrl"
    static let keyOfSchool = "school"
    static let keyOfGender = "gender"
    static let keyOfLeftHanded = "leftHanded"
    static let keyOfAllowsEventHistoryViewed = "allowsEventHistoryViewed"
}

struct EventKeyConstants {
    static let classNameOfEvent = "Event"
    static let keyOfName = "name"
    static let keyOfType = "type"
    static let keyOfTotalSeats = "totalSeats"
    static let keyOfRemainingSeats = "remainingSeats"
    static let keyOfMinimumAttendingPeople = "minimumAttendingPeople"
    static let keyOfDue = "due"
    
    static let keyOfCreator = "creator"
    static let keyOfMembers = "members"
    static let keyOfCompleted = "completed"
    static let keyOfTransientConversationId = "transientConversationId"
    static let keyOfConversationId = "conversationId"
    static let keyOfSchool = "school"
    
    static let keyOfStartTime = "startTime"
    static let keyOfEndTime = "endTime"
    static let keyOfLocationName = "locationName"
    static let keyOfLocation = "location"
    static let keyOfExpectedFee = "expectedFee"
    static let keyOfTransportationMethod = "transportationMethod"
    static let keyOfNote = "note"
    
    static let keyOfUpdatedAt = "updatedAt"
}

enum UIUserInterfaceIdiom : Int {
    case unspecified
    case phone
    case pad
}

struct ScreenSize {
    static let SCREEN_WIDTH         = UIScreen.main.bounds.size.width
    static let SCREEN_HEIGHT        = UIScreen.main.bounds.size.height
    static let SCREEN_MAX_LENGTH    = max(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
    static let SCREEN_MIN_LENGTH    = min(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
}

struct DeviceType {
    static let IS_IPHONE_4_OR_LESS  = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH < 568.0
    static let IS_IPHONE_5          = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 568.0
    static let IS_IPHONE_6          = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 667.0
    static let IS_IPHONE_6P         = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 736.0
    static let IS_IPAD              = UIDevice.current.userInterfaceIdiom == .pad && ScreenSize.SCREEN_MAX_LENGTH == 1024.0
}
