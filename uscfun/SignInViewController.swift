//
//  SignInViewController.swift
//  uscfun
//
//  Created by Wenzheng Li on 8/26/16.
//  Copyright © 2016 Wenzheng Li. All rights reserved.
//

import UIKit
import SVProgressHUD

class SignInViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var emailTextField: UITextField! {
        didSet {
            emailTextField.delegate = self
            emailTextField.addTarget(self, action: #selector(textDidChanged(textField:)), for: .editingChanged)
        }
    }
    
    @IBOutlet weak var passwordTextField: UITextField! {
        didSet {
            passwordTextField.delegate = self
            passwordTextField.addTarget(self, action: #selector(textDidChanged(textField:)), for: .editingChanged)
        }
    }
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var stopButtonItem: UIBarButtonItem!
    
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
        self.title = ""
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.view.backgroundColor = UIColor.white
        self.navigationController?.navigationBar.isTranslucent = false
        
        errorLabel.isHidden = true
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
            email = AVUser.current()!.email!.prefix!
        }
        emailTextField.becomeFirstResponder()
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
            if email.isValid {
                emailTextField.resignFirstResponder()
                errorLabel.isHidden = true
                passwordTextField.becomeFirstResponder()
            } else {
                errorLabel.text = "邮箱格式不正确"
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
        if !email.isValid {
            emailTextField.becomeFirstResponder()
            errorLabel.text = "邮箱格式不正确"
            errorLabel.isHidden = false
        }
        else if password.characters.count < USCFunConstants.minimumPasswordLength  {
            passwordTextField.becomeFirstResponder()
            errorLabel.text = "密码不足5位"
            errorLabel.isHidden = false
        }
        else if password.characters.contains(" ") {
            passwordTextField.becomeFirstResponder()
            errorLabel.text = "密码不应含有空格"
            errorLabel.isHidden = false
        } else {
            SVProgressHUD.show()
            stopButtonItem.isEnabled = false
            
            LoginKit.signIn(email: email, password: password) {
                succeed, error in
                
                SVProgressHUD.dismiss()
                self.stopButtonItem.isEnabled = true
                
                if succeed {
                    print("login successfully")
                    EventRequest.preLoadDataInBackground()
                    let appDelegate = UIApplication.shared.delegate! as! AppDelegate
                    let initialViewController = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()
                    appDelegate.window?.rootViewController = initialViewController
                    appDelegate.window?.makeKeyAndVisible()
                }
                
                if error != nil {
                    print(error!.localizedDescription)
                    self.emailTextField.becomeFirstResponder()
                    self.errorLabel.text = error!.localizedDescription
                    self.errorLabel.isHidden = false
                }
            }
        }
    }
    
    func textDidChanged(textField: UITextField) {
        errorLabel.isHidden = true
    }
}
