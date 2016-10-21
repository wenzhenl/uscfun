//
//  PasswordViewController.swift
//  uscfun
//
//  Created by Wenzheng Li on 8/27/16.
//  Copyright © 2016 Wenzheng Li. All rights reserved.
//

import UIKit
import SVProgressHUD

class PasswordViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var passwordView: UIView!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    
    var password: String {
        get {
            return (passwordTextField.text ?? "").trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        }
        set {
            passwordTextField.text = newValue
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor.backgroundGray

        passwordTextField.delegate = self
        errorLabel.isHidden = true
        
        if DeviceType.IS_IPHONE_4_OR_LESS {
            containerView.transform = CGAffineTransform(translationX: 0,y: -80)
        }
        if DeviceType.IS_IPHONE_4_OR_LESS || DeviceType.IS_IPHONE_5 {
            passwordTextField.placeholder = "设置密码"
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        passwordTextField.becomeFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if password.characters.count >= USCFunConstants.minimumPasswordLength && !password.characters.contains(" ") {
            USCFunConstants.password = password
            passwordTextField.resignFirstResponder()
            errorLabel.isHidden = true
            SVProgressHUD.show()

            USCFunConstants.signUp() {
                succeed, error in
                SVProgressHUD.dismiss()
                if succeed {
                    self.performSegue(withIdentifier: "go to confirm email", sender: self)
                } else {
                    errorLabel.text = error?.localizedDescription
                    errorLabel.isHidden = false
                }
            }
        }
        else if password.characters.count < USCFunConstants.minimumPasswordLength {
            errorLabel.text = "😂说好了至少要5个字符的呀"
            errorLabel.isHidden = false
        }
        else {
            errorLabel.text = "😂说好了不要空格的呀"
            errorLabel.isHidden = false
        }
        return true
    }
}
