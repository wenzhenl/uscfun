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
    var allowsEventHistoryViewed: Bool = true
    var selfIntroduction: String?
    
    init(username: String, nickname: String) {
        self.username = username
        self.nickname = nickname
    }
    
    init?(user: AVUser?) {
        guard let user = user else {
            print("failed to create User from AVUser: data is nil")
            return nil
        }
        
        guard let username = user.username else {
            print("failed to create User from AVUser: username is nil")
            return nil
        }
        self.username = username
        
        guard let nickname = user.value(forKey: UserKeyConstants.keyOfNickname) as? String else {
            print("failed to create User from AVUser: nickname is nil")
            return nil
        }
        self.nickname = nickname
        
        if let gender = user.value(forKey: UserKeyConstants.keyOfGender) as? String {
            self.gender = Gender(rawValue: gender)
        }
        
        if let avatarUrl = user.value(forKey: UserKeyConstants.keyOfAvatarUrl) as? String {
            let avatarFile = AVFile(url: avatarUrl)
            if let avatarData = avatarFile.getData() {
                self.avatar = UIImage(data: avatarData)
            }
        }
        
        if let allowsEventHistoryViewed = user.value(forKey: UserKeyConstants.keyOfAllowsEventHistoryViewed) as? Bool {
            self.allowsEventHistoryViewed = allowsEventHistoryViewed
        }
        
        if let selfIntroduction = user.value(forKey: UserKeyConstants.keyOfSelfIntroduction) as? String {
            self.selfIntroduction = selfIntroduction
        }
    }
}
