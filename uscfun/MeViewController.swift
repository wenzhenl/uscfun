//
//  MeViewController.swift
//  uscfun
//
//  Created by Wenzheng Li on 9/3/16.
//  Copyright © 2016 Wenzheng Li. All rights reserved.
//

import UIKit

class MeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    let numberOfRowInSection = [1,2,3,2,1]
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationController!.navigationBar.barTintColor = UIColor.buttonPink()
        self.navigationController!.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: UIFont.systemFontOfSize(20)]
//        self.navigationController!.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
//        self.navigationController!.navigationBar.shadowImage = UIImage()
        self.view.backgroundColor = UIColor.backgroundGray()
        self.tableView.layer.borderWidth = 1
        self.tableView.layer.borderColor = UIColor.whiteColor().CGColor
        self.tableView.layer.cornerRadius = 13
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return numberOfRowInSection.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfRowInSection[section]
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("UserProfileCell") as! UserProfileTableViewCell
            return cell
        }
        else if indexPath.section == numberOfRowInSection.count - 1 {
            let cell = UITableViewCell()
            cell.textLabel?.textAlignment = .Center
            cell.textLabel?.text = "退出登录"
            cell.textLabel?.textColor = UIColor.darkGrayColor()
            return cell
        }
        else if indexPath.section == 2 || indexPath.section == 3 {
            let cell = tableView.dequeueReusableCellWithIdentifier("AttendedEventCell") as! AttendedTableViewCell
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCellWithIdentifier("SettingCell") as! SettingTableViewCell
            if indexPath.row == 0 {
                cell.textLabel?.text = "给USC日常评分"
            } else {
                cell.textLabel?.text = "反馈问题或建议"
            }
            return cell
        }
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 20
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return UITableViewAutomaticDimension
        }
        else if indexPath.section == 2 || indexPath.section == 3 {
            return UITableViewAutomaticDimension
        }
        else {
            return 50
        }
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return UITableViewAutomaticDimension
        }
        else if indexPath.section == 2 || indexPath.section == 3 {
            return UITableViewAutomaticDimension
        }
        else {
            return 50
        }
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.backgroundColor = UIColor.whiteColor()
    }
    
    func tableView(tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        view.tintColor = UIColor.clearColor()
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if indexPath.section == numberOfRowInSection.count - 1 {
            User.hasLoggedIn = false
            let appDelegate = UIApplication.sharedApplication().delegate! as! AppDelegate
            let initialViewController = UIStoryboard(name: "Login", bundle: nil).instantiateInitialViewController()
            appDelegate.window?.rootViewController = initialViewController
            appDelegate.window?.makeKeyAndVisible()
        }
        
        else if indexPath.section == 1 && indexPath.row == 0 {
            UIApplication.sharedApplication().openURL(NSURL(string : "itms-apps://itunes.apple.com/app/id1073401869")!)
        }
        
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 2 {
            return "我发起过的活动"
        }
        else if section == 3 {
            return "我参加过的活动"
        }
        return ""
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 2 || section == 3 {
            return 15
        }
        return 0
    }
    
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
    
    @IBAction func close() {
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
}