//
//  MeViewController.swift
//  uscfun
//
//  Created by Wenzheng Li on 9/3/16.
//  Copyright © 2016 Wenzheng Li. All rights reserved.
//

import UIKit
import UIImageView_Letters

enum MeCell {
    case profileTableCell(image: UIImage, text: String, segueId: String)
    case labelArrowTableCell(text: String, segueId: String)
    case regularTableCell(text: String, segueId: String)
}

class MeViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var meSections = [[MeCell]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.buttonPink
        self.tableView.backgroundColor = UIColor.backgroundGray
        self.tableView.contentInset = UIEdgeInsetsMake(30, 0, 0, 0)
        
        //--MARK: populate the cells
        let tempImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
        tempImageView.setImageWith(UserDefaults.nickname, color: UIColor.white)
        let profileSection = [MeCell.profileTableCell(image: tempImageView.image!, text: UserDefaults.nickname!, segueId: segueIdOfUpdateProfile)]
        meSections.append(profileSection)
        
        let eventHistorySection = [MeCell.labelArrowTableCell(text: "我发起过的活动", segueId: segueIdOfCheckEventDetail), MeCell.labelArrowTableCell(text: "我参加过的活动", segueId: segueIdOfCheckEventDetail)]
        meSections.append(eventHistorySection)
        
        let appInfoSection = [MeCell.labelArrowTableCell(text: "给USC日常评分", segueId: segueIdOfRateUSCFun), MeCell.labelArrowTableCell(text: "反馈问题或建议", segueId: segueIdOfGiveComments), MeCell.labelArrowTableCell(text: "关于USC日常", segueId: segueIdOfAboutUSCFun)]
        meSections.append(appInfoSection)
        
        let signOutSection = [MeCell.regularTableCell(text: "退出登录", segueId: segueIdOfSignOut)]
        meSections.append(signOutSection)
    }
    
    let segueIdOfUpdateProfile = "go to update profile"
    let segueIdOfGiveComments = "go to feedback"
    let segueIdOfCheckEventDetail = "go to event history"
    let segueIdOfRateUSCFun = "go to rate app"
    let segueIdOfAboutUSCFun = "go to about uscfun"
    let segueIdOfSignOut = "sign out usc fun"
}

extension MeViewController: UITableViewDataSource, UITableViewDelegate{
    func numberOfSections(in tableView: UITableView) -> Int {
        return meSections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return meSections[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch meSections[indexPath.section][indexPath.row] {
        case .profileTableCell(_, let text, _):
            let cell = Bundle.main.loadNibNamed("ProfileTableViewCell", owner: self, options: nil)?.first as! ProfileTableViewCell
            if UserDefaults.avatar != nil {
                cell.mainImageView.image = UserDefaults.avatar
            } else {
                cell.mainImageView.setImageWith(text, color: USCFunConstants.avatarColorOptions[UserDefaults.avatarColor ?? "blue"])
            }
            cell.mainImageView.layer.cornerRadius = 4
            cell.mainLabel.text = text
            return cell
        case .labelArrowTableCell(let text, _):
            let cell = Bundle.main.loadNibNamed("LabelArrowTableViewCell", owner: self, options: nil)?.first as! LabelArrowTableViewCell
            cell.mainTextLabel.text = text
            cell.mainTextLabel.textColor = UIColor.darkGray
            return cell
        case .regularTableCell(let text, _):
            let cell = UITableViewCell()
            cell.textLabel?.textAlignment = .center
            cell.textLabel?.text = text
            cell.textLabel?.textColor = UIColor.darkGray
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 20
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath as NSIndexPath).section == 0 {
            return 90
        }
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath as NSIndexPath).section == 0 {
            return 90
        }
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = UIColor.white
    }
    
    func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        view.tintColor = UIColor.clear
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch meSections[indexPath.section][indexPath.row] {
        case .profileTableCell( _ , _ , let segueId):
            self.performSegue(withIdentifier: segueId, sender: self)
        case .labelArrowTableCell(_, let segueId):
            if segueId == segueIdOfRateUSCFun {
                UIApplication.shared.openURL(URL(string : "itms-apps://itunes.apple.com/app/id1073401869")!)
            } else {
                self.performSegue(withIdentifier: segueId, sender: self)
            }
        default:
            UserDefaults.hasLoggedIn = false
            let appDelegate = UIApplication.shared.delegate! as! AppDelegate
            let initialViewController = UIStoryboard(name: "Login", bundle: nil).instantiateInitialViewController()
            appDelegate.window?.rootViewController = initialViewController
            appDelegate.window?.makeKeyAndVisible()
        }
        
        tableView.deselectRow(at: indexPath, animated: false)
    }
}
