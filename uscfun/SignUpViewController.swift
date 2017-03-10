//
//  SignUpViewController.swift
//  uscfun
//
//  Created by Wenzheng Li on 8/26/16.
//  Copyright © 2016 Wenzheng Li. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController, UITextViewDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var emailInputView: UIView!
    @IBOutlet weak var emailTextField: UITextField! {
        didSet {
            emailTextField.delegate = self
        }
    }
    @IBOutlet weak var confirmationCodeTextField: UITextField! {
        didSet {
            confirmationCodeTextField.delegate = self
        }
    }
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var noticeTextView: UITextView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var requestConfirmationCodeButton: UIButton!
    @IBOutlet weak var nextStepButtonItem: UIBarButtonItem!
    
    var emailPrefix: String? {
        get {
            return emailTextField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        }
        set {
            emailTextField.text = newValue
            if newValue != nil {
                UserDefaults.email = newValue!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) + "@" + suffix
            } else {
                UserDefaults.email = nil
            }
        }
    }
    
    let suffix = "usc.edu"
    
    var confirmationCode: String? {
        get {
            return confirmationCodeTextField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        }
        set {
            confirmationCodeTextField.text = newValue
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = ""
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.view.backgroundColor = UIColor.backgroundGray
        noticeTextView.delegate = self
        let notice = NSMutableAttributedString(string: "继续注册流程代表你已阅读并同意用户使用协议")
        notice.addAttribute(NSLinkAttributeName, value: "http://www.google.com", range: NSRange(location: 15, length: 6))
        notice.addAttribute(NSUnderlineStyleAttributeName, value: NSUnderlineStyle.styleSingle.rawValue, range: NSRange(location: 15, length: 6))
        if DeviceType.IS_IPHONE_4_OR_LESS || DeviceType.IS_IPHONE_5 {
            notice.addAttribute(NSFontAttributeName, value: UIFont.systemFont(ofSize: 14), range: NSRange(location: 0, length: 21))
        } else {
            notice.addAttribute(NSFontAttributeName, value: UIFont.systemFont(ofSize: 15), range: NSRange(location: 0, length: 21))
        }
        notice.addAttribute(NSForegroundColorAttributeName, value: UIColor.darkGray, range: NSRange(location: 0, length: 21))
        noticeTextView.tintColor = UIColor.darkGray
        noticeTextView.attributedText = notice
        noticeTextView.textAlignment = .center
        
        errorLabel.isHidden = true
        emailPrefix = UserDefaults.email?.prefix
        emailTextField.becomeFirstResponder()
        
        /// additonal setup for iPhone4 and iPhone5
        if DeviceType.IS_IPHONE_4_OR_LESS || DeviceType.IS_IPHONE_5 {
            emailTextField.placeholder = "你的USC邮箱"
        }
        if DeviceType.IS_IPHONE_4_OR_LESS {
            containerView.transform = CGAffineTransform(translationX: 0,y: -80)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        UIApplication.shared.statusBarStyle = .default
    }
    
    @IBAction func goBack(_ sender: UIBarButtonItem) {
        emailTextField.resignFirstResponder()
        confirmationCodeTextField.resignFirstResponder()
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func requestConfirmationCode(_ sender: UIButton) {
    }
    
    @IBAction func goNext(_ sender: UIBarButtonItem) {
    }
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        self.performSegue(withIdentifier: "check privacy policy", sender: self)
        return false
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case emailTextField:
            let email = (emailPrefix ?? "") + "@" + suffix
            if email.isValid {
                emailTextField.resignFirstResponder()
                errorLabel.isHidden = true
                confirmationCodeTextField.becomeFirstResponder()
            } else {
                print(email)
                errorLabel.text = "邮箱格式貌似不太对劲"
                errorLabel.isHidden = false
            }
        case confirmationCodeTextField:
            if UserDefaults.confirmationCode == nil {
                errorLabel.text = "你还没有请求验证码"
                errorLabel.isHidden = false
            }
            else if confirmationCode != UserDefaults.confirmationCode {
                errorLabel.text = "验证码错误"
                errorLabel.isHidden = false
            } else {
                confirmationCodeTextField.resignFirstResponder()
                errorLabel.isHidden = true
                performSegue(withIdentifier: "go to nickname", sender: self)
            }
        default:
            break
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        print("text field did end editing")
        
        switch textField {
        case emailTextField:
            emailPrefix = textField.text
        case confirmationCodeTextField:
            confirmationCode = textField.text
        default:
            break
        }
    }
}
