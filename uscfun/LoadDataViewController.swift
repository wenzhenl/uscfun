//
//  LoadDataViewController.swift
//  uscfun
//
//  Created by Wenzheng Li on 3/19/17.
//  Copyright © 2017 Wenzheng Li. All rights reserved.
//

import UIKit

class LoadDataViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        EventRequest.preLoadData()
        let appDelegate = UIApplication.shared.delegate! as! AppDelegate
        let initialViewController = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()
        appDelegate.window?.rootViewController = initialViewController
        appDelegate.window?.makeKeyAndVisible()
    }
}
