//
//  MessageListViewController.swift
//  uscfun
//
//  Created by Wenzheng Li on 9/5/16.
//  Copyright © 2016 Wenzheng Li. All rights reserved.
//

import UIKit

class MessageListViewController: UIViewController {

    var delegate: MainViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func goEvent(_ sender: UIButton) {
        delegate?.goToEvent(from: self)
    }
}
