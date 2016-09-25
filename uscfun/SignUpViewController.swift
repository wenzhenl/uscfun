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
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var noticeTextView: UITextView!
    @IBOutlet weak var containerView: UIView!
    
    var email: String {
        get {
            return (emailTextField.text ?? "").trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) + "@usc.edu"
        }
        set {
            emailTextField.text = newValue
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
//        self.navigationController!.navigationBar.barTintColor = UIColor.themeYellow()
        self.navigationController!.navigationBar.tintColor = UIColor.darkGray
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.darkGray, NSFontAttributeName: UIFont.systemFont(ofSize: 17)]
        self.view.backgroundColor = UIColor.backgroundGray()
        
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
        
        emailTextField.delegate = self
        if DeviceType.IS_IPHONE_4_OR_LESS || DeviceType.IS_IPHONE_5 {
            emailTextField.placeholder = "你的USC邮箱"
        }
        
        errorLabel.isHidden = true
        
        if DeviceType.IS_IPHONE_4_OR_LESS {
            containerView.transform = CGAffineTransform(translationX: 0,y: -80)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        UIApplication.shared.statusBarStyle = .default
        emailTextField.becomeFirstResponder()
    }
    
    @IBAction func goBack(_ sender: UIBarButtonItem) {
        emailTextField.resignFirstResponder()
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        UIApplication.shared.openURL(URL)
        return false
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if email.isValidEmail() {
            User.email = email
            textField.resignFirstResponder()
            errorLabel.isHidden = true
            performSegue(withIdentifier: "go to nickname", sender: self)
        } else {
            errorLabel.isHidden = false
        }
        return true
    }
}
