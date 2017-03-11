//
//  NicknameViewController.swift
//  uscfun
//
//  Created by Wenzheng Li on 8/26/16.
//  Copyright © 2016 Wenzheng Li. All rights reserved.
//

import UIKit
import SVProgressHUD

class NicknameViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var nicknameView: UIView!
    @IBOutlet weak var nicknameTextField: UITextField! {
        didSet {
            nicknameTextField.delegate = self
            nicknameTextField.addTarget(self, action: #selector(nicknameTextDidChanged), for: .editingChanged)
        }
    }
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var nextStepButtonItem: UIBarButtonItem!
    
    var nickname: String? {
        get {
            return nicknameTextField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        }
        set {
            nicknameTextField.text = newValue
            nextStepButtonItem.isEnabled = !(newValue ?? "").isWhitespaces
            UserDefaults.newNickname = newValue?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        self.title = ""
        
        errorLabel.isHidden = true
        nickname = UserDefaults.newNickname
        
        if DeviceType.IS_IPHONE_4_OR_LESS {
            containerView.transform = CGAffineTransform(translationX: 0,y: -80)
        }
        if DeviceType.IS_IPHONE_4_OR_LESS || DeviceType.IS_IPHONE_5 {
            nicknameTextField.placeholder = "你的昵称"
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        nicknameTextField.becomeFirstResponder()
    }
    
    @IBAction func goNext(_ sender: UIBarButtonItem) {
        errorLabel.isHidden = true
        nicknameTextField.resignFirstResponder()
        
        SVProgressHUD.show()
        
        LoginKit.signUp() {
            succeed, error in
            SVProgressHUD.dismiss()
            if succeed {
                print("succeed in signing up")
            } else {
                errorLabel.text = error?.localizedDescription
                errorLabel.isHidden = false
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
    
    func nicknameTextDidChanged() {
        nickname = nicknameTextField.text
        print("current nickname: \(nickname)")
    }
}
