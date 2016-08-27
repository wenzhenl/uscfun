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
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationController!.navigationBar.barTintColor = UIColor.themeYellow()
        self.navigationController!.navigationBar.tintColor = UIColor.darkGrayColor()
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.darkGrayColor(), NSFontAttributeName: UIFont.systemFontOfSize(20)]
        self.view.backgroundColor = UIColor.backgroundGray()
        
        nicknameView.layer.borderWidth = 3
        nicknameView.layer.borderColor = UIColor.whiteColor().CGColor
        nicknameTextField.becomeFirstResponder()
        nicknameTextField.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        nicknameTextField.resignFirstResponder()
        performSegueWithIdentifier("go to password", sender: self)
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
