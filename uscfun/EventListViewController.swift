//
//  EventListViewController.swift
//  uscfun
//
//  Created by Wenzheng Li on 9/3/16.
//  Copyright © 2016 Wenzheng Li. All rights reserved.
//

import UIKit

class EventListViewController: UIViewController {

    @IBOutlet weak var buttonContainerView: UIView!
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor.themeYellow()
        self.leftButton.layer.cornerRadius = leftButton.frame.size.height / 2.0
        self.rightButton.layer.cornerRadius = rightButton.frame.size.height / 2.0
        self.leftButton.backgroundColor = UIColor.buttonPink()
        self.rightButton.backgroundColor = UIColor.buttonBlue()
        self.tableView.backgroundColor = UIColor.backgroundGray()
        self.tableView.layer.cornerRadius = 10
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
