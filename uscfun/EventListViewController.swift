//
//  EventListViewController.swift
//  uscfun
//
//  Created by Wenzheng Li on 9/3/16.
//  Copyright © 2016 Wenzheng Li. All rights reserved.
//

import UIKit

class EventListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var buttonContainerView: UIView!
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var startEventButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor.themeYellow()
        self.backgroundView.backgroundColor = UIColor.backgroundGray()
        self.leftButton.layer.cornerRadius = leftButton.frame.size.height / 2.0
        self.rightButton.layer.cornerRadius = rightButton.frame.size.height / 2.0
        self.leftButton.backgroundColor = UIColor.buttonPink()
        self.rightButton.backgroundColor = UIColor.buttonBlue()
        self.startEventButton.layer.cornerRadius = startEventButton.frame.size.height / 2.0
        self.tableView.backgroundColor = UIColor.backgroundGray()
//        self.backgroundView.layer.cornerRadius = 15
        self.backgroundView.layer.borderWidth = 1
        self.backgroundView.layer.borderColor = UIColor.lightGrayColor().CGColor
        self.leftButton.layer.borderWidth = 1
        self.leftButton.layer.borderColor = UIColor.lightGrayColor().CGColor
        self.rightButton.layer.borderWidth = 1
        self.rightButton.layer.borderColor = UIColor.lightGrayColor().CGColor
        self.startEventButton.layer.borderWidth = 1
        self.startEventButton.layer.borderColor = UIColor.buttonBlue().CGColor
        self.view.bringSubviewToFront(buttonContainerView)
        self.view.bringSubviewToFront(startEventButton)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 300
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 300
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 10
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("EventListCell") as! EventListTableViewCell
        cell.selectionStyle = .None
        return cell
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.backgroundColor = UIColor.clearColor()
    }
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 13
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 50
        } else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRectMake(0, 0, tableView.bounds.size.width, 30))
        headerView.backgroundColor = UIColor.clearColor()
        return headerView
    }
    
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView(frame: CGRectMake(0, 0, tableView.bounds.size.width, 30))
        footerView.backgroundColor = UIColor.clearColor()
        return footerView
    }
}