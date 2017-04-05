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
    
    static let avatarColorOptions = [UIColor.avatarBlue, UIColor.avatarCyan, UIColor.avatarPink, UIColor.avatarGolden, UIColor.avatarOrange, UIColor.avatarTomato, UIColor.avatarGreen]
    
    static let indexOfMyEventList = 0
    static let indexOfEventList = 1
    static let indexOfNotification = 2
    static let indexOfMe = 3
    
    static let basicURL = "http://richang.avosapps.us/"
    static let urlOfPrivacy = basicURL + "agreement"
    static let shareEventURL = basicURL + "events/"
    static let appURL = "itms-apps://itunes.apple.com/app/id1163062860"
    
    static let QUERYLIMIT = 100
    static let MAXCACHEAGE = TimeInterval(24 * 3600)
    
    static let systemAdministratorClientId = "RICHANGXIAOGUANJIA_SYSTEMADMINISTRATOR_CLIENTID"
    
    //-MARK: storyboard identifiers
    static let storyboardIdentifierOfCustomizedAlertViewController = "Customized Alert View Controller"
    static let storyboardIdentifierOfWebViewController = "common use web vc"
    static let storyboardIdentifierOfUserProfilerViewController = "user profile view controller"
    static let storyboardIdentifierOfMapViewController = "universal map view controller"
}

struct UserKeyConstants {
    static let keyOfNickname = "nickname"
    static let keyOfAvatarUrl = "avatarUrl"
    static let keyOfSchool = "school"
    static let keyOfGender = "gender"
    static let keyOfSelfIntroduction = "selfIntroduction"
    static let keyOfAllowsEventHistoryViewed = "allowsEventHistoryViewed"
}

struct EventKeyConstants {
    static let classNameOfEvent = "Event"
    static let classNameOfConversation = "_Conversation"
    static let keyOfName = "name"
    static let keyOfMaximumAttendingPeople = "maximumAttendingPeople"
    static let keyOfRemainingSeats = "remainingSeats"
    static let keyOfMinimumAttendingPeople = "minimumAttendingPeople"
    static let keyOfDue = "due"
    
    static let keyOfCreatedBy = "createdBy"
    static let keyOfMembers = "members"
    static let keyOfIsCancelled = "isCancelled"
    static let keyOfConversation = "conversation"
    static let keyOfInstitution = "institution"
    
    static let keyOfStartTime = "startTime"
    static let keyOfEndTime = "endTime"
    static let keyOfLocation = "location"
    static let keyOfWhereCreated = "whereCreated"
    static let keyOfNote = "note"
    
    static let keyOfCreatedAt = "createdAt"
    static let keyOfObjectId = "objectId"
    
    static let keyOfCompletedBy = "completedBy"

    static let keyOfSystemNotificationOfUpdatedEvents = "updatedEventIds"
}

struct LeanEngineFunctions {
    static let nameOfCheckIfEmailIsTaken = "checkIfEmailIsTaken"
    static let nameOfRequestConfirmationCode = "requestConfirmationCode"
    static let nameOfCheckIfConfirmationCodeMatches = "checkIfConfirmationCodeMatches"
    static let nameOfCreateSystemConversationIfNotExists = "createSystemConversationIfNotExists"
    static let nameOfSubscribeToSystemConversation = "subscribeToSystemConversation"
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
