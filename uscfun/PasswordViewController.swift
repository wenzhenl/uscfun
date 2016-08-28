//
//  PasswordViewController.swift
//  uscfun
//
//  Created by Wenzheng Li on 8/27/16.
//  Copyright © 2016 Wenzheng Li. All rights reserved.
//

import UIKit

class PasswordViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var passwordView: UIView!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    
    var password: String {
        get {
            return (passwordTextField.text ?? "").stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        }
        set {
            passwordTextField.text = newValue
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor.backgroundGray()

        passwordTextField.delegate = self
        errorLabel.hidden = true
        
        if DeviceType.IS_IPHONE_4_OR_LESS {
            containerView.transform = CGAffineTransformMakeTranslation(0,-80)
        }
        if DeviceType.IS_IPHONE_4_OR_LESS || DeviceType.IS_IPHONE_5 {
            passwordTextField.placeholder = "设置密码"
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        passwordTextField.becomeFirstResponder()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if password.characters.count >= USCFunConstants.minimumPasswordLength && !password.characters.contains(" ") {
            User.password = password
            passwordTextField.resignFirstResponder()
            errorLabel.hidden = true
            
            let appDelegate = UIApplication.sharedApplication().delegate! as! AppDelegate
            let initialViewController = self.storyboard?.instantiateViewControllerWithIdentifier("Confirm email")
            appDelegate.window?.rootViewController = initialViewController
            appDelegate.window?.makeKeyAndVisible()
        }
        else if password.characters.count < USCFunConstants.minimumPasswordLength {
            errorLabel.text = "😂说好了至少要5个字符的呀"
            errorLabel.hidden = false
        }
        else {
            errorLabel.text = "😂说好了不要空格的呀"
            errorLabel.hidden = false
        }
        return true
    }
}
