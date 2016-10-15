//
//  EventHistoryViewController.swift
//  uscfun
//
//  Created by Wenzheng Li on 10/14/16.
//  Copyright © 2016 Wenzheng Li. All rights reserved.
//

import UIKit

class EventHistoryViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "历史信息"
        self.navigationController!.navigationBar.barTintColor = UIColor.buttonPink
        self.navigationController!.navigationBar.tintColor = UIColor.white
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
    }
}
