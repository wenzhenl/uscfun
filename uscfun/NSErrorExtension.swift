//
//  NSErrorExtension.swift
//  uscfun
//
//  Created by Wenzheng Li on 4/2/17.
//  Copyright © 2017 Wenzheng Li. All rights reserved.
//

import Foundation

struct USCFunErrorConstants {
    
    //--MARK: error domain
    static let domain = "USC Fun Error Domain"
    
    //--MARK: error code
    
    /// error code for sign in
    static let kUSCFunErrorUserNicknameMissing = 20000
    static let kUSCFunErrorUserAvatarMissing = 20001
}

extension NSError {
    var customDescription: String? {
        
        /// handle errors thrown by LeanCloud
        if self.domain == "AVOS Cloud Error Domain" {
            switch self.code {
            case 210:
                return "邮箱密码不匹配"
            case 211:
                return "用户名不存在"
            default:
                return "系统错误，请稍后再试"
            }
        }
        
        /// handle errors thrown by uscfun
        else if self.domain == USCFunErrorConstants.domain {
            switch self.code {
            case USCFunErrorConstants.kUSCFunErrorUserNicknameMissing:
                return "获取用户昵称失败"
            case USCFunErrorConstants.kUSCFunErrorUserAvatarMissing:
                return "获取用户头像失败"
            default:
                return "系统错误，请稍后再试"
            }
        }
        
        else {
            switch self.code {
            case -1009:
                return "无网络连接，请检查网络"
            case -1001:
                return "请求超时，请稍后再试"
            default:
                return "系统错误，请稍后再试"
            }
        }
    }
}
