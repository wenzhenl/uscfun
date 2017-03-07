//
//  SignInViewController.swift
//  uscfun
//
//  Created by Wenzheng Li on 8/26/16.
//  Copyright © 2016 Wenzheng Li. All rights reserved.
//

import UIKit
import AVOSCloud
import SVProgressHUD

class SignInViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var emailTextField: UITextField! {
        didSet {
            emailTextField.delegate = self
        }
    }
    
    @IBOutlet weak var passwordTextField: UITextField! {
        didSet {
            passwordTextField.delegate = self
        }
    }
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var signInButton: UIButton!
    
    var email: String {
        get {
            return (emailTextField.text ?? "") + "@usc.edu"
        }
        set {
            emailTextField.text = newValue
        }
    }
    
    var password: String {
        get {
            return passwordTextField.text ?? ""
        }
        set {
            passwordTextField.text = newValue
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController!.navigationBar.tintColor = UIColor.darkGray
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.darkGray]
        self.view.backgroundColor = UIColor.backgroundGray
        
        errorLabel.isHidden = true
        emailTextField.becomeFirstResponder()
        signInButton.layer.cornerRadius = 25
        
        if DeviceType.IS_IPHONE_4_OR_LESS || DeviceType.IS_IPHONE_5 {
            emailTextField.placeholder = "你的USC邮箱"
        }
        
        if DeviceType.IS_IPHONE_4_OR_LESS {
            containerView.transform = CGAffineTransform(translationX: 0, y: -80)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if AVUser.current() != nil {
            email = AVUser.current()!.email!.emailPrefix()!
        }
        UIApplication.shared.statusBarStyle = .default
    }
    
    @IBAction func goBack(_ sender: UIBarButtonItem) {
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case emailTextField:
            if email.isValidEmail() {
                emailTextField.resignFirstResponder()
                errorLabel.isHidden = true
                passwordTextField.becomeFirstResponder()
            } else {
                errorLabel.text = "邮箱格式貌似不太对劲"
                errorLabel.isHidden = false
            }
        case passwordTextField:
            if password.characters.count < USCFunConstants.minimumPasswordLength  {
                errorLabel.text = "密码不足5位"
                errorLabel.isHidden = false
            }
            else if password.characters.contains(" ") {
                errorLabel.text = "密码不应含有空格"
                errorLabel.isHidden = false
            }
            else {
                passwordTextField.resignFirstResponder()
                errorLabel.isHidden = true
                signIn()
            }
        default:
            break
        }
        return true
    }
    
    @IBAction func signIn() {
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        if !email.isValidEmail() {
            errorLabel.text = "邮箱格式貌似不太对劲"
            errorLabel.isHidden = false
        }
        else if password.characters.count < USCFunConstants.minimumPasswordLength  {
            errorLabel.text = "密码不足5位"
            errorLabel.isHidden = false
        }
        else if password.characters.contains(" ") {
            errorLabel.text = "密码不应含有空格"
            errorLabel.isHidden = false
        } else {
            SVProgressHUD.show()
            
            LoginKit.signIn(email: email, password: password) {
                succeed, error in
                
                SVProgressHUD.dismiss()
                
                if succeed {
                    // TODO: preload contents before going to the homepage
                    EventRequest.preLoadData()
                    let appDelegate = UIApplication.shared.delegate! as! AppDelegate
                    let initialViewController = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()
                    appDelegate.window?.rootViewController = initialViewController
                    appDelegate.window?.makeKeyAndVisible()
                }
                
                if error != nil {
                    print(error!.localizedDescription)
                    self.errorLabel.text = error!.localizedDescription
                    self.errorLabel.isHidden = false
                }
            }
        }
    }
}
