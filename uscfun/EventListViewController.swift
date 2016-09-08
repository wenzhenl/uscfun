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
    
    var delegate: MainViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
//        self.navigationController!.navigationBarHidden = true
        
        self.view.backgroundColor = UIColor.buttonBlue()
//        UIApplication.sharedApplication().statusBarStyle = .LightContent
        self.backgroundView.backgroundColor = UIColor.backgroundGray()
        self.leftButton.layer.cornerRadius = leftButton.frame.size.height / 2.0
        self.rightButton.layer.cornerRadius = rightButton.frame.size.height / 2.0
        self.leftButton.backgroundColor = UIColor.buttonBlue()
        self.rightButton.backgroundColor = UIColor.buttonPink()
        self.startEventButton.layer.cornerRadius = startEventButton.frame.size.height / 2.0
        self.tableView.backgroundColor = UIColor.backgroundGray()
        self.tableView.contentInset = UIEdgeInsetsMake(80, 0, 0, 0)
//        self.backgroundView.layer.cornerRadius = 15
//        self.backgroundView.layer.borderWidth = 1
//        self.backgroundView.layer.borderColor = UIColor.lightGrayColor().CGColor
//        self.leftButton.layer.borderWidth = 5
//        self.leftButton.layer.borderColor = UIColor.buttonPink().CGColor
//        self.rightButton.layer.borderWidth = 5
//        self.rightButton.layer.borderColor = UIColor.buttonPink().CGColor
//        self.startEventButton.layer.borderWidth = 1
//        self.startEventButton.layer.borderColor = UIColor.buttonBlue().CGColor
        self.view.bringSubviewToFront(buttonContainerView)
        self.view.bringSubviewToFront(startEventButton)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func goToMessage(sender: UIButton) {
        delegate?.goToMessage()
    }
    
    @IBAction func goToMe(sender: UIButton) {
        delegate?.goToMe()
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return UITableViewAutomaticDimension
        } else if indexPath.section == 1 && indexPath.row == 0 {
            return UITableViewAutomaticDimension
        }
        return 200
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return UITableViewAutomaticDimension
        } else if indexPath.section == 1 && indexPath.row == 0 {
            return UITableViewAutomaticDimension
        }
        return 200
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 10
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 5
        } else if section == 1 {
            return 2
        } else {
            return 1
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                let cell = UITableViewCell()
                cell.textLabel?.text = "我加入的活动"
                cell.selectionStyle = .None
                return cell
            } else {
                let cell = tableView.dequeueReusableCellWithIdentifier("AttendingEventCell") as! AttendingEventTableViewCell
                cell.selectionStyle = .Default
                return cell
            }
        } else if indexPath.section == 1 && indexPath.row == 0 {
            let cell = UITableViewCell()
            cell.textLabel?.text = "当前活动列表"
            cell.selectionStyle = .None
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("EventListCell") as! EventListTableViewCell
            cell.selectionStyle = .Default
            return cell
        }
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.backgroundColor = UIColor.clearColor()
        if (indexPath.section == 0 && indexPath.row == 0) || (indexPath.section == 1 && indexPath.row == 0) {
            cell.textLabel?.font = UIFont.systemFontOfSize(13)
            cell.textLabel?.textColor = UIColor.lightGrayColor()
        }
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 15
    }
    
//    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        if section == 0 {
//            return 15
//        }
//        else if section == 1 {
//            return 15
//        } else {
//            return 0
//        }
//    }
    
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = UIColor.clearColor()
        let title = UILabel()
        title.font = UIFont(name: "Futura", size: 10)!
        title.textColor = UIColor.lightGrayColor()
        
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.font=title.font
        header.textLabel?.textColor=title.textColor
        header.textLabel?.textAlignment = .Left
    }
    
    func tableView(tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        view.tintColor = UIColor.clearColor()
    }
    
//    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        if section == 0 {
//            return "我加入的活动"
//        }
//        else if section == 1 {
//            return "当前活动列表"
//        } else {
//            return nil
//        }
//    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }
}