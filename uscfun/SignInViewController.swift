//
//  SignInViewController.swift
//  uscfun
//
//  Created by Wenzheng Li on 8/26/16.
//  Copyright © 2016 Wenzheng Li. All rights reserved.
//

import UIKit

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

        // Do any additional setup after loading the view.
        // self.navigationController!.navigationBar.barTintColor = UIColor.themeYellow()
        self.navigationController!.navigationBar.tintColor = UIColor.darkGrayColor()
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.darkGrayColor(), NSFontAttributeName: UIFont.systemFontOfSize(17)]
        self.view.backgroundColor = UIColor.backgroundGray()
        
        // inputView.layer.cornerRadius = 8
        errorLabel.hidden = true
        emailTextField.becomeFirstResponder()
        signInButton.layer.cornerRadius = 25
        
        if DeviceType.IS_IPHONE_4_OR_LESS || DeviceType.IS_IPHONE_5 {
            emailTextField.placeholder = "你的USC邮箱"
        }
        
        if DeviceType.IS_IPHONE_4_OR_LESS {
            containerView.transform = CGAffineTransformMakeTranslation(0,-80)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func goBack(sender: UIBarButtonItem) {
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        switch textField {
        case emailTextField:
            if email.isValidEmail() {
                emailTextField.resignFirstResponder()
                errorLabel.hidden = true
                passwordTextField.becomeFirstResponder()
            } else {
                errorLabel.text = "邮箱格式貌似不太对劲"
                errorLabel.hidden = false
            }
        case passwordTextField:
            if password.characters.count < USCFunConstants.minimumPasswordLength  {
                errorLabel.text = "密码不足5位"
                errorLabel.hidden = false
            }
            else if password.characters.contains(" ") {
                errorLabel.text = "密码不应含有空格"
                errorLabel.hidden = false
            }
            else {
                passwordTextField.resignFirstResponder()
                errorLabel.hidden = true
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
            errorLabel.hidden = false
        }
        else if password.characters.count < USCFunConstants.minimumPasswordLength  {
            errorLabel.text = "密码不足5位"
            errorLabel.hidden = false
        }
        else if password.characters.contains(" ") {
            errorLabel.text = "密码不应含有空格"
            errorLabel.hidden = false
        } else {
            AVUser.logInWithUsernameInBackground(email, password: password) {
                updatedUser, error in
                if updatedUser != nil {
                    // TODO: preload contents before going to the homepage
                    print(updatedUser.email)
                    let appDelegate = UIApplication.sharedApplication().delegate! as! AppDelegate
                    let initialViewController = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()
                    appDelegate.window?.rootViewController = initialViewController
                    appDelegate.window?.makeKeyAndVisible()
                }
                
                if error != nil {
                    print(error.localizedDescription)
                    self.errorLabel.text = error.localizedDescription
                    self.errorLabel.hidden = false
                }
            }
        }
    }
}
