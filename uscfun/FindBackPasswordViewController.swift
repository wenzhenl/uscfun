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
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.darkGray]
        self.view.backgroundColor = UIColor.backgroundGray
        
        noticeTextView.tintColor = UIColor.darkGray
        noticeTextView.textAlignment = .center
        noticeTextView.text = ""
        
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
        if AVUser.current() != nil {
            self.email = AVUser.current().email.emailPrefix()!
        }
        emailTextField.becomeFirstResponder()
    }
    
    @IBAction func goBack(_ sender: UIBarButtonItem) {
        emailTextField.resignFirstResponder()
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if email.isValidEmail() {
            User.email = email
            textField.resignFirstResponder()
            errorLabel.isHidden = true
            AVUser.requestPasswordResetForEmail(inBackground: email) {
                succeeded, error in
                if succeeded {
                    self.noticeTextView.text = "我们已经收到你的重置密码请求，一封邮件已经发送到\(self.email), 请按照邮件的指导操作"
                } else {
                    print(error)
                    self.errorLabel.text = error?.localizedDescription
                    self.errorLabel.isHidden = false
                }
            }
        } else {
            errorLabel.isHidden = false
        }
        return true
    }
}
