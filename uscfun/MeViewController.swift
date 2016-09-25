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
    
    var delegate: MainViewControllerDelegate?
    
//    let numberOfRowInSection = [1,2,3,2,1]
    let numberOfRowInSection = [1,2]
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.buttonPink()
        self.tableView.backgroundColor = UIColor.backgroundGray()
//        self.tableView.layer.borderWidth = 1
//        self.tableView.layer.borderColor = UIColor.whiteColor().CGColor
//        self.tableView.layer.cornerRadius = 13
        
        self.tableView.contentInset = UIEdgeInsetsMake(30, 0, 0, 0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
//        self.navigationController!.navigationBarHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
//        self.navigationController!.navigationBarHidden = true
    }
    
    @IBAction func goEvent(_ sender: UIButton) {
        delegate?.goToEvent(from: self)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return numberOfRowInSection.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfRowInSection[section]
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if (indexPath as NSIndexPath).section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "UserProfileCell") as! UserProfileTableViewCell
            return cell
        }
        else if (indexPath as NSIndexPath).section == numberOfRowInSection.count - 1 {
            let cell = UITableViewCell()
            cell.textLabel?.textAlignment = .center
            cell.textLabel?.text = "退出登录"
            cell.textLabel?.textColor = UIColor.darkGray
            return cell
        }
        else if (indexPath as NSIndexPath).section == 2 || (indexPath as NSIndexPath).section == 3 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AttendedEventCell") as! AttendedTableViewCell
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SettingCell") as! SettingTableViewCell
            if (indexPath as NSIndexPath).row == 0 {
                cell.textLabel?.text = "给USC日常评分"
            } else {
                cell.textLabel?.text = "反馈问题或建议"
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 20
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath as NSIndexPath).section == 0 {
            return 80
        }
        else if (indexPath as NSIndexPath).section == 2 || (indexPath as NSIndexPath).section == 3 {
            return UITableViewAutomaticDimension
        }
        else {
            return 50
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath as NSIndexPath).section == 0 {
            return UITableViewAutomaticDimension
        }
        else if (indexPath as NSIndexPath).section == 2 || (indexPath as NSIndexPath).section == 3 {
            return UITableViewAutomaticDimension
        }
        else {
            return 50
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = UIColor.white
    }
    
    func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        view.tintColor = UIColor.clear
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if (indexPath as NSIndexPath).section == numberOfRowInSection.count - 1 {
            User.hasLoggedIn = false
            let appDelegate = UIApplication.shared.delegate! as! AppDelegate
            let initialViewController = UIStoryboard(name: "Login", bundle: nil).instantiateInitialViewController()
            appDelegate.window?.rootViewController = initialViewController
            appDelegate.window?.makeKeyAndVisible()
        }
        
        else if (indexPath as NSIndexPath).section == 1 && (indexPath as NSIndexPath).row == 0 {
            UIApplication.shared.openURL(URL(string : "itms-apps://itunes.apple.com/app/id1073401869")!)
        }
        
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 2 {
            return "我发起过的活动"
        }
        else if section == 3 {
            return "我参加过的活动"
        }
        return ""
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 2 || section == 3 {
            return 15
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = UIColor.clear
        let title = UILabel()
        title.font = UIFont(name: "Futura", size: 10)!
        title.textColor = UIColor.lightGray
        
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.font=title.font
        header.textLabel?.textColor=title.textColor
        header.textLabel?.textAlignment = .left
    }
    
//    @IBAction func close() {
//        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
//    }
}
