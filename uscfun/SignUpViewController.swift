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
            emailTextField.addTarget(self, action: #selector(emailOrCodeDidChanged(textField:)), for: .editingChanged)
        }
    }
    @IBOutlet weak var confirmationCodeTextField: UITextField! {
        didSet {
            confirmationCodeTextField.delegate = self
            confirmationCodeTextField.addTarget(self, action: #selector(emailOrCodeDidChanged(textField:)), for: .editingChanged)
        }
    }
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var noticeTextView: UITextView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var requestConfirmationCodeButton: UIButton!
    @IBOutlet weak var nextStepButtonItem: UIBarButtonItem!
    
    var emailPrefix: String? {
        get {
            return emailTextField.text
        }
        set {
            emailTextField.text = newValue
            UserDefaults.newEmail = newValue
        }
    }
    
    let suffix = "usc.edu"
    
    var email: String {
        return (emailPrefix?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "") + "@" + suffix
    }
    
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
        self.view.backgroundColor = UIColor.white
        self.navigationController?.navigationBar.isTranslucent = false
        
        /// set up notice for user agreement
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
        nextStepButtonItem.isEnabled = false
        
        if UserDefaults.newEmail != nil && UserDefaults.newEmail!.prefix != nil {
            emailPrefix = UserDefaults.newEmail!.prefix
        } else {
            emailPrefix = UserDefaults.newEmail
        }
        
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
        emailTextField.becomeFirstResponder()
        UIApplication.shared.statusBarStyle = .default
    }
    
    fileprivate let identifierToWeb = "check privacy policy"
    fileprivate let identifierToPassword = "go to password"
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
            case identifierToWeb:
                if let webVC = segue.destination.contentViewController as? WebViewController {
                    webVC.url = URL(string: USCFunConstants.urlOfPrivacy)
                    webVC.webTitle = "使用协议"
                }
            default:
                break
            }
        }
    }
    
    @IBAction func goBack(_ sender: UIBarButtonItem) {
        emailTextField.resignFirstResponder()
        confirmationCodeTextField.resignFirstResponder()
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func requestConfirmationCode(_ sender: UIButton) {
        guard email.isValid else {
            errorLabel.text = "邮箱格式不正确，请重新输入"
            errorLabel.isHidden = false
            return
        }
        do {
            try LoginKit.requestConfirmationCode(email: email)
            errorLabel.text = "验证码已经发送至邮箱，请注意查收"
            errorLabel.isHidden = false
        } catch let error {
            errorLabel.text = error.localizedDescription
            errorLabel.isHidden = false
        }
    }
    
    @IBAction func goNext(_ sender: UIBarButtonItem) {
        guard email.isValid else {
            errorLabel.text = "邮箱格式不正确，请重新输入"
            errorLabel.isHidden = false
            return
        }
        
        do {
            if try LoginKit.checkIfEmailIsTaken(email: email) {
                errorLabel.text = "此邮箱已被注册，请使用找回密码"
                errorLabel.isHidden = false
                return
            }
        } catch let error {
            errorLabel.text = error.localizedDescription
            errorLabel.isHidden = false
            return
        }
        
        guard let confirmationCode = confirmationCode, !confirmationCode.isWhitespaces else {
            errorLabel.text = "请输入验证码"
            errorLabel.isHidden = false
            return
        }
        
        do {
            if try LoginKit.checkIfConfirmationCodeMatches(email: email, code: confirmationCode) {
                UserDefaults.newEmail = email
                performSegue(withIdentifier: identifierToPassword, sender: self)
            }
        } catch let error {
            errorLabel.text = error.localizedDescription
            errorLabel.isHidden = false
        }
    }
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        self.performSegue(withIdentifier: identifierToWeb, sender: self)
        return false
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case emailTextField:
            guard email.isValid else {
                errorLabel.text = "邮箱格式不正确，请重新输入"
                errorLabel.isHidden = false
                return true
            }
            
            do {
                if try LoginKit.checkIfEmailIsTaken(email: email) {
                    errorLabel.text = "此邮箱已被注册，请使用找回密码"
                    errorLabel.isHidden = false
                    return true
                }
            } catch let error {
                errorLabel.text = error.localizedDescription
                errorLabel.isHidden = false
                return true
            }
            
            emailTextField.resignFirstResponder()
            errorLabel.isHidden = true
            confirmationCodeTextField.becomeFirstResponder()
        default:
            break
        }
        return true
    }
    
    func emailOrCodeDidChanged(textField: UITextField) {
        errorLabel.isHidden = true
        nextStepButtonItem.isEnabled = !(emailPrefix ?? "").isEmpty && !(confirmationCode ?? "").isEmpty
        switch textField {
        case emailTextField:
            if textField.markedTextRange == nil {
                emailPrefix = textField.text
            }
        default:
            break
        }
    }
}
