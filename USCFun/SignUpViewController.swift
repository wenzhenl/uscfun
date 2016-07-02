//
//  ViewController.swift
//  USCFun
//
//  Created by Wenzheng Li on 7/1/16.
//  Copyright © 2016 Wenzheng Li. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController, UITextFieldDelegate {

    var blurView: UIView!

    @IBOutlet weak var nicknameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    
//    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    var nickname: String? {
        get {
            return nicknameTextField.text
        }
        set {
            nicknameTextField.text = newValue
        }
    }
    
    var email: String? {
        get {
            return emailTextField.text
        }
        set {
            emailTextField.text = newValue
        }
    }
    
    var password: String? {
        get {
            return passwordTextField.text
        }
        set {
            passwordTextField.text = newValue
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        nicknameTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        
        let blurEffect = UIBlurEffect(style: .Light)
        blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = view.bounds
        view.insertSubview(blurView, aboveSubview: imageView)
//        
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SignUpViewController.keyboardWillShow(_:)), name:UIKeyboardWillShowNotification, object: nil);
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SignUpViewController.keyboardWillHide(_:)), name:UIKeyboardWillHideNotification, object: nil);
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setTextFieldBorder(nicknameTextField)
        setTextFieldBorder(emailTextField)
        setTextFieldBorder(passwordTextField)
    }
    
//    deinit {
//        NSNotificationCenter.defaultCenter().removeObserver(self)
//    }
    
//    func keyboardWillShow(notification: NSNotification) {
//        var info = notification.userInfo!
//        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
//        
//        UIView.animateWithDuration(0.1, animations: { () -> Void in
//            self.bottomConstraint.constant = -keyboardFrame.size.height
//        })
//    }
//    
//    func keyboardWillHide(notification: NSNotification) {
//        UIView.animateWithDuration(0.1, animations: { () -> Void in
//            self.bottomConstraint.constant = 0
//        })
//    }

    func setTextFieldBorder(textField: UITextField) {
        let border = CALayer()
        let width = CGFloat(1.0)
        border.borderColor = UIColor.whiteColor().CGColor
        border.frame = CGRect(x: 0, y: textField.frame.size.height - width, width: textField.frame.size.width, height:width)
        
        border.borderWidth = width
        textField.layer.addSublayer(border)
        textField.layer.masksToBounds = true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return true
    }
}

