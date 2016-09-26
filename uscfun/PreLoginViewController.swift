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
        self.view.layoutIfNeeded()
        signupView.layer.cornerRadius = signupView.bounds.size.height / 2.0
        loginView.layer.cornerRadius = loginView.bounds.size.height / 2.0
        signupView.backgroundColor = UIColor.buttonPink()
        loginView.backgroundColor = UIColor.buttonBlue()
        print("view did load")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        UIView.animate(withDuration: 1.0, animations: {
            self.signupConstraint.constant = -170.0
            self.loginContraint.constant = -170.0
            self.blackfishConstraint.constant = 0
            self.view.layoutIfNeeded()
        })
        print("view did layout subviews")
    }
    
//    override func viewDidAppear(animated: Bool) {
//        super.viewDidAppear(true)
//        UIView.animateWithDuration(1.0, animations: {
//            self.signupConstraint.constant = -170.0
//            self.loginContraint.constant = -170.0
//            self.blackfishConstraint.constant = 0
//            self.view.layoutIfNeeded()
//        })
//        print("view did appear")
//    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        UIApplication.shared.isStatusBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        UIApplication.shared.isStatusBarHidden = false
    }
}
