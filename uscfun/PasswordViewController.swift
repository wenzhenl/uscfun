//
//  PasswordViewController.swift
//  uscfun
//
//  Created by Wenzheng Li on 8/27/16.
//  Copyright © 2016 Wenzheng Li. All rights reserved.
//

import UIKit

class PasswordViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var passwordView: UIView!
    @IBOutlet weak var passwordTextField: UITextField! {
        didSet {
            passwordTextField.delegate = self
            passwordTextField.addTarget(self, action: #selector(passwordDidChanged), for: .editingChanged)
        }
    }
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var nextStepButtonItem: UIBarButtonItem!
    
    var password: String? {
        get {
            return passwordTextField.text
        }
        set {
            passwordTextField.text = newValue
            nextStepButtonItem.isEnabled = (newValue ?? "").characters.count >= USCFunConstants.minimumPasswordLength
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        self.title = ""
        
        errorLabel.isHidden = true
        nextStepButtonItem.isEnabled = false
        
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
    
    @IBAction func goNext(_ sender: UIBarButtonItem) {
        checkPassword()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        checkPassword()
        return true
    }
    
    func checkPassword() {
        guard let password = password else {
            errorLabel.text = "😂说好了至少要5个字符的呀"
            errorLabel.isHidden = false
            return
        }
        
        if password.characters.count >= USCFunConstants.minimumPasswordLength && !password.characters.contains(" ") {
            LoginKit.password = password
            performSegue(withIdentifier: "go to nickname", sender: self)
        }
        else if password.characters.count < USCFunConstants.minimumPasswordLength {
            errorLabel.text = "😂说好了至少要5个字符的呀"
            errorLabel.isHidden = false
        }
        else {
            errorLabel.text = "😂说好了不要空格的呀"
            errorLabel.isHidden = false
        }
    }
    
    func passwordDidChanged() {
        password = passwordTextField.text
        errorLabel.isHidden = true
        print("current password: \(String(describing: password))")
    }
}
