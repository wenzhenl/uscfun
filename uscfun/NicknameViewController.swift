//
//  NicknameViewController.swift
//  uscfun
//
//  Created by Wenzheng Li on 8/26/16.
//  Copyright © 2016 Wenzheng Li. All rights reserved.
//

import UIKit

class NicknameViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var nicknameView: UIView!
    @IBOutlet weak var nicknameTextField: UITextField!
    
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    var nickname: String? {
        get {
            return (nicknameTextField.text ?? "").stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        }
        set {
            nicknameTextField.text = newValue
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationController!.navigationBar.barTintColor = UIColor.themeYellow()
        self.navigationController!.navigationBar.tintColor = UIColor.darkGrayColor()
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.darkGrayColor(), NSFontAttributeName: UIFont.systemFontOfSize(20)]
        self.view.backgroundColor = UIColor.backgroundGray()
        
        nicknameView.layer.borderWidth = 3
        nicknameView.layer.borderColor = UIColor.whiteColor().CGColor
        nicknameTextField.delegate = self
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
        nickname = User.nickname
        nicknameTextField.becomeFirstResponder()
    }
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        if !(nickname ?? "").isEmpty() {
            User.nickname = nickname
            errorLabel.hidden = true
            nicknameTextField.resignFirstResponder()
            performSegueWithIdentifier("go to password", sender: self)
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
