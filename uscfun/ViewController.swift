//
//  ViewController.swift
//  uscfun
//
//  Created by Wenzheng Li on 8/6/16.
//  Copyright © 2016 Wenzheng Li. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

    @IBAction func signOut(sender: UIButton) {
        User.hasLoggedIn = false
        let appDelegate = UIApplication.sharedApplication().delegate! as! AppDelegate
        let initialViewController = UIStoryboard(name: "Login", bundle: nil).instantiateInitialViewController()
        appDelegate.window?.rootViewController = initialViewController
        appDelegate.window?.makeKeyAndVisible()
    }

}

