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
    
    init(username: String, nickname: String) {
        self.username = username
        self.nickname = nickname
    }
}
