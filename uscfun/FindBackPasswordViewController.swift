//
//  FindBackPasswordViewController.swift
//  uscfun
//
//  Created by Wenzheng Li on 8/28/16.
//  Copyright © 2016 Wenzheng Li. All rights reserved.
//

import UIKit
import AVOSCloud

class FindBackPasswordViewController: UIViewController, UITextViewDelegate, UITextFieldDelegate {

    @IBOutlet weak var emailInputView: UIView!
    @IBOutlet weak var emailTextField: UITextField! {
        didSet {
            emailTextField.delegate = self
            emailTextField.addTarget(self, action: #selector(emailFieldDidChanged(textField:)), for: .editingChanged)
        }
    }
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var noticeTextView: UITextView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var stopButtonItem: UIBarButtonItem!
    @IBOutlet weak var sendButtonItem: UIBarButtonItem!
    
    var email: String {
        get {
            return (emailTextField.text ?? "").trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) + "@usc.edu"
        }
        set {
            emailTextField.text = newValue
            sendButtonItem.isEnabled = (newValue.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) + "@usc.edu").isValid
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = ""
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.view.backgroundColor = UIColor.white
        self.navigationController?.navigationBar.isTranslucent = false
        
        noticeTextView.textColor = UIColor.darkGray
        noticeTextView.text = ""
        
        if DeviceType.IS_IPHONE_4_OR_LESS || DeviceType.IS_IPHONE_5 {
            emailTextField.placeholder = "你的USC邮箱"
        }
        
        errorLabel.isHidden = true
        sendButtonItem.isEnabled = false
        
        if DeviceType.IS_IPHONE_4_OR_LESS {
            containerView.transform = CGAffineTransform(translationX: 0,y: -80)
        }
    }
  
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if AVUser.current() != nil {
            self.email = AVUser.current()!.email!.prefix!
        }
        emailTextField.becomeFirstResponder()
    }
    
    @IBAction func goBack(_ sender: UIBarButtonItem) {
        emailTextField.resignFirstResponder()
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func send(_ sender: UIBarButtonItem) {
        requestPasswordReset()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        requestPasswordReset()
        return true
    }
    
    func requestPasswordReset() {
        if email.isValid {
            emailTextField.resignFirstResponder()
            errorLabel.isHidden = true
            stopButtonItem.isEnabled = false
            AVUser.requestPasswordResetForEmail(inBackground: email) {
                succeeded, error in
                
                self.stopButtonItem.isEnabled = true
                
                if succeeded {
                    self.noticeTextView.text = "我们已经收到你的重置密码请求，一封邮件已经发送到 \(self.email) , 请按照邮件的指导操作"
                    self.email = ""
                }
                else if error != nil {
                    print(error!)
                    self.emailTextField.becomeFirstResponder()
                    self.errorLabel.text = error?.localizedDescription
                    self.errorLabel.isHidden = false
                }
            }
        } else {
            errorLabel.isHidden = false
        }
    }
    
    func emailFieldDidChanged(textField: UITextField) {
        if textField.markedTextRange == nil {
            email = textField.text ?? ""
        }
        errorLabel.isHidden = true
        noticeTextView.text = ""
    }
}
