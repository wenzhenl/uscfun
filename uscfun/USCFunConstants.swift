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
    
    static let avatarColorOptions = [UIColor.avatarBlue, UIColor.avatarCyan, UIColor.avatarPink, 
                                     UIColor.avatarGolden, UIColor.avatarOrange, UIColor.avatarTomato,
                                     UIColor.avatarGreen, UIColor.avatar1, UIColor.avatar2, 
                                     UIColor.avatar3, UIColor.avatar4, UIColor.avatar5, UIColor.avatar6,
                                     UIColor.avatar7, UIColor.avatar8, UIColor.avatar9, UIColor.avatar10,
                                     UIColor.avatar11, UIColor.avatar12, UIColor.avatar13, UIColor.avatar14,
                                     UIColor.avatar15, UIColor.avatar16, UIColor.avatar17, UIColor.avatar18,
                                     UIColor.avatar19, UIColor.avatar20, UIColor.avatar21, UIColor.avatar22,
                                     UIColor.avatar23, UIColor.avatar24, UIColor.avatar25, UIColor.avatar26,
                                     UIColor.avatar27, UIColor.avatar28, UIColor.avatar29, UIColor.avatar30,
                                     UIColor.avatar31, UIColor.avatar32, UIColor.avatar33, UIColor.avatar34,
                                     UIColor.avatar35, UIColor.avatar36, UIColor.avatar37, UIColor.avatar38,
                                     UIColor.avatar39, UIColor.avatar40, UIColor.avatar41, UIColor.avatar42,
                                     UIColor.avatar43, UIColor.avatar44, UIColor.avatar45, UIColor.avatar46,
                                     UIColor.avatar47, UIColor.avatar48, UIColor.avatar49, UIColor.avatar50]
    
    static let conversationColorOptions = [UIColor.avatarBlue, UIColor.avatarCyan, UIColor.avatarPink,
                                           UIColor.avatarGolden, UIColor.avatarOrange, UIColor.avatarTomato,
                                           UIColor.avatarGreen]
    
    
    static let indexOfMyEventList = 0
    static let indexOfEventList = 1
    static let indexOfNotification = 2
    static let indexOfMe = 3
    
    static let basicURL = "https://www.richang.life/"
    static let urlOfPrivacy = basicURL + "agreement"
    static let shareEventURL = basicURL + "events/"
    static let appURL = "itms-apps://itunes.apple.com/app/id1163062860"
    static let creditRecordURL = basicURL + "rating"
    
    static let QUERYLIMIT = 100
    static let MAXCACHEAGE = TimeInterval(24 * 3600)
    
    static let systemAdministratorClientId = "wenzhenl_usc_edu"
        
    //--MARK: storyboard identifiers
    static let storyboardIdentifierOfCustomizedAlertViewController = "Customized Alert View Controller"
    static let storyboardIdentifierOfWebViewController = "common use web vc"
    static let storyboardIdentifierOfUserProfilerViewController = "user profile view controller"
    static let storyboardIdentifierOfMapViewController = "universal map view controller"
    static let storyboardIdentifierOfLoadDataViewController = "load data view controller"
    static let storyboardIndetifierOfConversationMoreViewController = "conversation more view controller"
    static let storyboardIdentiferOfRateEventViewController = "rating event view controller"
    static let storyboardIdentiferOfRateEventNavigationViewController = "rate event navigation view controller"
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
    
    static let keyOfNeededBy = "neededBy"

    static let keyOfSystemNotificationOfUpdatedEvents = "updatedEventIds"
}

struct RatingKeyConstants {
    static let classNameOfRating = "Rating"
    static let keyOfRating = "rating"
    static let keyOfTargetEvent = "targetEvent"
    static let keyOfTargetMember = "targetMember"
    static let keyOfRatedBy = "ratedBy"
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
