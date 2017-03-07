//
//  UpdateProfileViewController.swift
//  uscfun
//
//  Created by Wenzheng Li on 10/14/16.
//  Copyright © 2016 Wenzheng Li. All rights reserved.
//

import UIKit
import Eureka

class UpdateProfileViewController: FormViewController {
    
    var nickname: String? {
        get {
            return (form.rowBy(tag: "nickname") as! TextRow).value
        }
        set {
            (form.rowBy(tag: "nickname") as! TextRow).value = newValue
            UserDefaults.nickname = newValue
        }
    }
    
    var gender: String? {
        get {
            return (form.rowBy(tag: "gender") as! AlertRow).value
        }
        set {
            (form.rowBy(tag: "gender") as! AlertRow).value = newValue
            if newValue != nil {
                UserDefaults.gender = Gender(rawValue: newValue!) ?? Gender.unknown
            }
        }
    }
    
    var selfIntroduction: String? {
        get {
            return (form.rowBy(tag: "selfIntro") as! TextAreaRow).value
        }
        set {
            (form.rowBy(tag: "selfIntro") as! TextAreaRow).value = newValue
            UserDefaults.selfIntroduction = newValue
        }
    }
    
    var avatarIsChanged = false
    var oldNickName: String?
    var oldGender: Gender!
    var oldSelfIntroduction: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.view.backgroundColor = UIColor.white

        self.title = "更新个人信息"
        form +++ Section()
            <<< ImageRow("avatar") {
                $0.title = "头像"
                $0.value = UserDefaults.avatar
                }.onChange { row in
                    print("changed")
                    UserDefaults.avatar = row.value
                    self.avatarIsChanged = true
                }
            <<< TextRow("nickname") {
                $0.title = "昵称"
                }.cellUpdate { cell, row in
                    cell.textField.textColor = UIColor.darkGray
                }
                .onChange { row in
                    self.nickname = row.value
                }
            <<< AlertRow<String>("gender") {
                $0.title = "性别"
                $0.selectorTitle = "性别"
                $0.options = ["男","女", "保密"]
                }.cellUpdate { cell, row in
                    cell.detailTextLabel?.textColor = UIColor.darkGray
                }
                .onChange { row in
                    self.gender = row.value
                }
             +++ Section("个人简介")
             <<< TextAreaRow("selfIntro"){ row in
                    row.placeholder = "简单描述下自己"
                }.onChange { row in
                    self.selfIntroduction = row.value
                }
        nickname = UserDefaults.nickname
        gender = UserDefaults.gender.rawValue
        selfIntroduction = UserDefaults.selfIntroduction
        oldNickName = UserDefaults.nickname
        oldGender = UserDefaults.gender
        oldSelfIntroduction = UserDefaults.selfIntroduction
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        if avatarIsChanged {
            UserDefaults.updateUserAvatar()
        }
        let withNickName = oldNickName != UserDefaults.nickname
        let withGender = oldGender != UserDefaults.gender
        let withSelfIntroduction = oldSelfIntroduction != UserDefaults.selfIntroduction
        UserDefaults.updateUserProfile(withNickName: withNickName, withGender: withGender, withSelfIntroduction: withSelfIntroduction)
    }
}
