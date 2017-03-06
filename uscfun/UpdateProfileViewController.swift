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

    var avatar: UIImage? {
        get {
            return (form.rowBy(tag: "avatar") as! ImageRow).value
        }
        set {
            (form.rowBy(tag: "avatar") as! ImageRow).value = newValue
            UserDefaults.avatar = newValue
        }
    }
    
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
                UserDefaults.gender = Gender(rawValue: newValue!)
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.view.backgroundColor = UIColor.white

        self.title = "更新个人信息"
        form +++ Section()
            <<< ImageRow("avatar") {
                $0.title = "头像"
            }
                .cellUpdate {
                    cell, row in
                    self.avatar = row.value
            }
            <<< TextRow("nickname") {
                $0.title = "昵称"
            }
            <<< AlertRow<String>("gender") {
                $0.title = "性别"
                $0.selectorTitle = "性别"
                $0.options = ["男","女", "保密"]
                }.onChange { row in
                    self.gender = row.value
                }
             +++ Section("个人简介")
            <<< TextAreaRow("selfIntro"){ row in
                    row.placeholder = "简单描述下自己"
                }
                    .cellUpdate {
                        cell, row in
                        self.selfIntroduction = row.value
            }
        avatar = UserDefaults.avatar
        nickname = UserDefaults.nickname
        gender = UserDefaults.gender?.rawValue
        selfIntroduction = UserDefaults.selfIntroduction
    }
}
