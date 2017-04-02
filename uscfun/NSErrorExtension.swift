//
//  NSErrorExtension.swift
//  uscfun
//
//  Created by Wenzheng Li on 4/2/17.
//  Copyright © 2017 Wenzheng Li. All rights reserved.
//

import Foundation

struct USCFunErrorConstants {
    static let domain = "USC Fun Error Domain"
    static let kUSCFunErrorUserNicknameMissing = 10001
    static let kUSCFunErrorUserAvatarMissing = 10002
}

extension NSError {
    var customDescription: String? {
        
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
        
        else if self.domain == USCFunErrorConstants.domain {
            switch self.code {
            case USCFunErrorConstants.kUSCFunErrorUserNicknameMissing:
                return ""
            default:
                return ""
            }
        }
        
        else {
            switch self.code {
            case -1009:
                return "无网络连接，请检查网络"
            default:
                return ""
            }
        }
    }
}
