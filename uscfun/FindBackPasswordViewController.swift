//
//  FindBackPasswordViewController.swift
//  uscfun
//
//  Created by Wenzheng Li on 8/28/16.
//  Copyright © 2016 Wenzheng Li. All rights reserved.
//

import UIKit

class FindBackPasswordViewController: UIViewController, UITextViewDelegate, UITextFieldDelegate {

    @IBOutlet weak var emailInputView: UIView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var noticeTextView: UITextView!
    @IBOutlet weak var containerView: UIView!
    
    var email: String {
        get {
            return (emailTextField.text ?? "").stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()) + "@usc.edu"
        }
        set {
            emailTextField.text = newValue
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        //        self.navigationController!.navigationBar.barTintColor = UIColor.themeYellow()
        self.navigationController!.navigationBar.tintColor = UIColor.darkGrayColor()
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.darkGrayColor(), NSFontAttributeName: UIFont.systemFontOfSize(17)]
        self.view.backgroundColor = UIColor.backgroundGray()
        
        noticeTextView.tintColor = UIColor.darkGrayColor()
        noticeTextView.textAlignment = .Center
        noticeTextView.text = ""
        
        emailTextField.delegate = self
        if DeviceType.IS_IPHONE_4_OR_LESS || DeviceType.IS_IPHONE_5 {
            emailTextField.placeholder = "你的USC邮箱"
        }
        
        errorLabel.hidden = true
        
        if DeviceType.IS_IPHONE_4_OR_LESS {
            containerView.transform = CGAffineTransformMakeTranslation(0,-80)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        if AVUser.currentUser() != nil {
            self.email = AVUser.currentUser().email.emailPrefix()!
        }
        emailTextField.becomeFirstResponder()
    }
    
    @IBAction func goBack(sender: UIBarButtonItem) {
        emailTextField.resignFirstResponder()
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if email.isValidEmail() {
            User.email = email
            textField.resignFirstResponder()
            errorLabel.hidden = true
            AVUser.requestPasswordResetForEmailInBackground(email) {
                succeeded, error in
                if succeeded {
                    self.noticeTextView.text = "我们已经收到你的重置密码请求，一封邮件已经发送到\(self.email), 请按照邮件的指导操作"
                } else {
                    print(error)
                    self.errorLabel.text = error.localizedDescription
                    self.errorLabel.hidden = false
                }
            }
        } else {
            errorLabel.hidden = false
        }
        return true
    }
}
