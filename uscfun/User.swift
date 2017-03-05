//
//  User.swift
//  uscfun
//
//  Created by Wenzheng Li on 8/25/16.
//  Copyright © 2016 Wenzheng Li. All rights reserved.
//

import Foundation
import AVOSCloud

class User {
    //--MARK: required information
    var username: String
    var nickname: String
    
    //--MARK: optional settings
    var gender: String?
    var avatar: UIImage?
    
    var allowsEventHistoryViewed: Bool {
        return true
    }
    
    init(username: String, nickname: String) {
        self.username = username
        self.nickname = nickname
    }
    
    init?(user: AVUser?) {
        if let user = user {
            if let allkeys = user.allKeys() as? [String] {
                self.username = user.username
                
                guard allkeys.contains(UserKeyConstants.keyOfNickname), let nickname = user.value(forKey: UserKeyConstants.keyOfNickname) as? String else {
                    print("no nickname")
                    return nil
                }
                self.nickname = nickname
                
                if allkeys.contains(UserKeyConstants.keyOfGender) {
                    if let gender = user.value(forKey: UserKeyConstants.keyOfGender) as? String {
                        self.gender = gender
                    }
                }
                
                if allkeys.contains(UserKeyConstants.keyOfAvatarUrl), let avatarUrl = user.value(forKey: UserKeyConstants.keyOfAvatarUrl) as? String {
                    if let avatarFile = AVFile(url: avatarUrl) {
//                        avatarFile.getThumbnail(true, width: 100, height: 100) {
//                            image, error in
//                            if image != nil {
//                                self.avatar = image
//                            }
//                            if error != nil {
//                                print(error)
//                            }
//                        }
                        if let avtarData = avatarFile.getData() {
                            self.avatar = UIImage(data: avtarData)
                        }
                    }
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
