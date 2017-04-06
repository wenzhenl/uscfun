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
    
    /// error code for sign up
    static let kUSCFunErrorLeanEngineResultsNotExpected = 10000
    static let kUSCFunErrorInvalidEmail = 10001
    static let kUSCFunErrorInvalidPassword = 10002
    static let kUSCFunErrorInvalidNickname = 10003
    static let kUSCFunErrorCreateDefaultAvatarFailed = 10004
    static let kUSCFunErrorUploadDefaultAvatarFailed = 10005
    
    /// error code for sign in
    static let kUSCFunErrorUserNicknameMissing = 20000
    static let kUSCFunErrorUserAvatarMissing = 20001
    
    /// error code for event
    static let kUSCFunErrorEventConversationIdMissing = 30000
    static let kUSCFunErrorEventAddMemberFailed = 30001
    static let kUSCFunErrorEventInvalidMember = 30002
    static let kUSCFunErrorEventRemoveMemberFailed = 30003
    static let kUSCFunErrorEventInvalidCreatedBy = 30004
    static let kUSCFunErrorEventInvalidUpdateData = 30005
    static let kUSCFunErrorEventCancelFailedDueToExistingMember = 30006
    
    /// error code from LeanCloud
    static let kLeanCloudErrorSaveOptionError = 305
}

extension NSError {
    var customDescription: String {
        
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
        
        /// handle errors thrown by AVIM
        else if self.domain == "AVOSCloudIMErrorDomain" {
            switch self.code {
            case 5:
                return "无网络连接，请检查网络"
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
            case USCFunErrorConstants.kUSCFunErrorEventAddMemberFailed:
                return "报名已经结束"
            case USCFunErrorConstants.kUSCFunErrorEventRemoveMemberFailed:
                return "微活动已经约定成功"
            case USCFunErrorConstants.kUSCFunErrorEventInvalidMember:
                return "用户没有参加该活动"
            case USCFunErrorConstants.kUSCFunErrorEventInvalidCreatedBy:
                return "不是活动的发起人"
            case USCFunErrorConstants.kUSCFunErrorEventInvalidUpdateData:
                return "更新数据不符合要求"
            case USCFunErrorConstants.kUSCFunErrorEventCancelFailedDueToExistingMember:
                return "无法取消，已经有人参加了"
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
