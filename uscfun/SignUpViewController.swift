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
    
    var email: String? {
        get {
            return emailTextField.text == nil ? "" : emailTextField.text! + "@usc.edu"
        }
        set {
            emailTextField.text = newValue
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationController!.navigationBar.barTintColor = UIColor.themeYellow()
        self.navigationController!.navigationBar.tintColor = UIColor.darkGrayColor()
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.darkGrayColor(), NSFontAttributeName: UIFont.systemFontOfSize(20)]
        self.view.backgroundColor = UIColor.backgroundGray()
//        emailTextField.becomeFirstResponder()
        emailInputView.layer.borderWidth = 3
        emailInputView.layer.borderColor = UIColor.whiteColor().CGColor
        
        noticeTextView.delegate = self
        let notice = NSMutableAttributedString(string: "继续注册流程代表你已阅读并同意用户使用协议")
        notice.addAttribute(NSLinkAttributeName, value: "http://www.google.com", range: NSRange(location: 15, length: 6))
        notice.addAttribute(NSUnderlineStyleAttributeName, value: NSUnderlineStyle.StyleSingle.rawValue, range: NSRange(location: 15, length: 6))
        notice.addAttribute(NSFontAttributeName, value: UIFont.systemFontOfSize(15), range: NSRange(location: 0, length: 21))
        notice.addAttribute(NSForegroundColorAttributeName, value: UIColor.darkGrayColor(), range: NSRange(location: 0, length: 21))
        noticeTextView.tintColor = UIColor.darkGrayColor()
        noticeTextView.attributedText = notice
        noticeTextView.textAlignment = .Center
        emailTextField.delegate = self
//        emailTextField.attributedPlaceholder = NSAttributedString(string: "在这里输入你的USC邮箱", attributes: [NSFontAttributeName: UIFont.systemFontOfSize(10)])
        errorLabel.hidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        email = User.email
        emailTextField.becomeFirstResponder()
    }
    @IBAction func goBack(sender: UIBarButtonItem) {
        emailTextField.resignFirstResponder()
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func textView(textView: UITextView, shouldInteractWithURL URL: NSURL, inRange characterRange: NSRange) -> Bool {
        UIApplication.sharedApplication().openURL(URL)
        return false
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if email != nil && email!.isValidEmail() {
            User.email = email!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
            textField.resignFirstResponder()
            errorLabel.hidden = true
            performSegueWithIdentifier("go to nickname", sender: self)
        } else {
            errorLabel.hidden = false
        }
        return true
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
