//
//  PreLoginViewController.swift
//  uscfun
//
//  Created by Wenzheng Li on 8/25/16.
//  Copyright © 2016 Wenzheng Li. All rights reserved.
//

import UIKit

class PreLoginViewController: UIViewController {

    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var signupView: UIView!
    @IBOutlet weak var loginView: UIView!
    
    @IBOutlet weak var signupConstraint: NSLayoutConstraint!
    @IBOutlet weak var loginContraint: NSLayoutConstraint!
    @IBOutlet weak var blackfishConstraint: NSLayoutConstraint!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor.themeYellow()
        signupView.layer.cornerRadius = signupView.bounds.size.height / 2.0
        loginView.layer.cornerRadius = loginView.bounds.size.height / 2.0
        signupView.backgroundColor = UIColor.buttonPink()
        loginView.backgroundColor = UIColor.buttonBlue()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        UIView.animateWithDuration(1.5, animations: {
            self.signupConstraint.constant = -170.0
            self.loginContraint.constant = -170.0
            self.blackfishConstraint.constant = 0
            self.view.layoutIfNeeded()
        })
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        UIApplication.sharedApplication().statusBarHidden = true
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(true)
        UIApplication.sharedApplication().statusBarHidden = false
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
