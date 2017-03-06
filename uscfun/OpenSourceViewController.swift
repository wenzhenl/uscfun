//
//  OpenSourceViewController.swift
//  uscfun
//
//  Created by Wenzheng Li on 3/6/17.
//  Copyright © 2017 Wenzheng Li. All rights reserved.
//

import UIKit

class OpenSourceViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        textView.contentInset = UIEdgeInsetsMake(10, 0, 0, 0)
    }
}
