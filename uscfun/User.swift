//
//  User.swift
//  uscfun
//
//  Created by Wenzheng Li on 8/25/16.
//  Copyright © 2016 Wenzheng Li. All rights reserved.
//

import Foundation
import AVOSCloud

enum Gender: String {
    case male = "男"
    case female = "女"
    case unknown = "保密"
}

class User {
    //--MARK: required information
    var username: String
    var nickname: String
    
    //--MARK: optional settings
    var gender: Gender?
    var avatar: UIImage?
    var allowsEventHistoryViewed: Bool = false
    var selfIntroduction: String?
    
    init(username: String, nickname: String) {
        self.username = username
        self.nickname = nickname
    }
    
    init?(user: AVUser?) {
        if let user = user {
            if let allkeys = user.allKeys() as? [String] {
                self.username = user.username
                
                guard allkeys.contains(UserKeyConstants.keyOfNickname), let nickname = user.value(forKey: UserKeyConstants.keyOfNickname) as? String else {
                    return nil
                }
                self.nickname = nickname
                
                if allkeys.contains(UserKeyConstants.keyOfGender) {
                    if let gender = user.value(forKey: UserKeyConstants.keyOfGender) as? String {
                        self.gender = Gender(rawValue: gender)
                    }
                }
                
                if allkeys.contains(UserKeyConstants.keyOfAvatarUrl), let avatarUrl = user.value(forKey: UserKeyConstants.keyOfAvatarUrl) as? String {
                    if let avatarFile = AVFile(url: avatarUrl) {
                        if let avtarData = avatarFile.getData() {
                            self.avatar = UIImage(data: avtarData)
                        }
                    }
                }
                
                if allkeys.contains(UserKeyConstants.keyOfAllowsEventHistoryViewed), let allowsEventHistoryViewed = user.value(forKey: UserKeyConstants.keyOfAllowsEventHistoryViewed) as? Bool {
                    self.allowsEventHistoryViewed = allowsEventHistoryViewed
                }
                
                if allkeys.contains(UserKeyConstants.keyOfSelfIntroduction), let selfIntroduction = user.value(forKey: UserKeyConstants.keyOfSelfIntroduction) as? String {
                    self.selfIntroduction = selfIntroduction
                }
                return
            }
        }
        
        print("======Cannot even see AVUser========")
        self.username = ""
        self.nickname = ""
        return nil
    }
    
    var attendedEvents: OrderedDictionary<String, Event> {
        return EventRequest.publicEvents
    }
    
    var createdEvents: OrderedDictionary<String, Event> {
        return EventRequest.myOngoingEvents
    }
}
