//
//  MeViewController.swift
//  uscfun
//
//  Created by Wenzheng Li on 9/3/16.
//  Copyright © 2016 Wenzheng Li. All rights reserved.
//

import UIKit

enum MeCell {
    case profileTableCell(image: UIImage, text: String, segueId: String)
    case labelArrowTableCell(text: String, segueId: String)
    case labelImgArrowTableCell(text: String, isIndicated: Bool, segueId: String)
    case labelSwitchTableCell(text: String)
    case regularTableCell(text: String, segueId: String)
}

protocol UserSettingDelegate {
    func userDidChangeLefthandMode()
//    func userDidChangeAllowEventHistoryViewedMode()
}

class MeViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var meSections = [[MeCell]]()
    var delegate: UserSettingDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.buttonPink
        self.tableView.backgroundColor = UIColor.backgroundGray
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 50, 0)
        self.tableView.tableFooterView = UIView()
        self.populateSections()
    }
    
    func populateSections() {
        //--MARK: populate the cells
        meSections = [[MeCell]]()
        let profileSection = [MeCell.profileTableCell(image: UserDefaults.avatar!, text: UserDefaults.nickname!, segueId: segueIdOfUpdateProfile)]
        meSections.append(profileSection)
        
        let eventHistorySection = [MeCell.labelArrowTableCell(text: "我发起过的活动", segueId: segueIdOfCheckEventDetail), MeCell.labelArrowTableCell(text: "我参加过的活动", segueId: segueIdOfCheckEventDetail)]
        meSections.append(eventHistorySection)
        
        let privacySection = [MeCell.labelSwitchTableCell(text: textOfAllowEventHistroyViewed)]
        meSections.append(privacySection)
        
        let appInfoSection = [MeCell.labelArrowTableCell(text: "给USC日常评分", segueId: segueIdOfRateUSCFun),
                              MeCell.labelArrowTableCell(text: "关于USC日常", segueId: segueIdOfAboutUSCFun)]
        meSections.append(appInfoSection)
        
        let signOutSection = [MeCell.regularTableCell(text: "退出登录", segueId: segueIdOfSignOut)]
        meSections.append(signOutSection)
    }
    
    func switchAllowEventHistoryViewedMode(switchElement: UISwitch) {
        print(switchElement.isOn)
        UserDefaults.updateAllowsEventHistoryViewed(allowsEventHistoryViewed: switchElement.isOn)
    }
    
    let textOfAllowEventHistroyViewed = "公开活动历史"
    
    let segueIdOfUpdateProfile = "go to update profile"
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
        case .profileTableCell(let image, let text, _):
            let cell = Bundle.main.loadNibNamed("ProfileTableViewCell", owner: self, options: nil)?.first as! ProfileTableViewCell
            cell.mainImageView.layer.masksToBounds = true
            cell.mainImageView.image = image
            cell.mainImageView.layer.cornerRadius = 4
            cell.mainLabel.text = text
            return cell
        case .labelArrowTableCell(let text, _):
            let cell = Bundle.main.loadNibNamed("LabelArrowTableViewCell", owner: self, options: nil)?.first as! LabelArrowTableViewCell
            cell.mainTextLabel.text = text
            cell.mainTextLabel.textColor = UIColor.darkGray
            return cell
        case .labelImgArrowTableCell(let text, let isIndicated, _):
            let cell = Bundle.main.loadNibNamed("LabelImgArrowTableViewCell", owner: self, options: nil)?.first as! LabelImgArrowTableViewCell
            cell.mainLabel.text = text
            cell.mainLabel.textColor = UIColor.darkGray
            if isIndicated {
                cell.indicatorView.backgroundColor = UIColor.red
            } else {
                cell.indicatorView.backgroundColor = UIColor.clear
            }
            cell.indicatorView.layer.cornerRadius = 5
            cell.indicatorView.layer.masksToBounds = true
            return cell
        case .labelSwitchTableCell(let text):
            let cell = Bundle.main.loadNibNamed("LabelSwitchTableViewCell", owner: self, options: nil)?.first as! LabelSwitchTableViewCell
            cell.mainLabel.text = text
            cell.mainLabel.textColor = UIColor.darkGray
            if text == textOfAllowEventHistroyViewed {
                cell.mainSwitch.isOn = UserDefaults.allowsEventHistoryViewed
                cell.mainSwitch.addTarget(self, action: #selector(switchAllowEventHistoryViewedMode(switchElement:)), for: UIControlEvents.valueChanged)
            }
            cell.selectionStyle = .none
            return cell
        case .regularTableCell(let text, _):
            let cell = UITableViewCell()
            cell.textLabel?.textAlignment = .center
            cell.textLabel?.text = text
            cell.textLabel?.textColor = UIColor.darkGray
            return cell
        }
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
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 1 / UIScreen.main.scale
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let px = 1 / UIScreen.main.scale
        let frame = CGRect(x: 0, y: 0, width: self.tableView.frame.size.width, height: px)
        let line = UIView(frame: frame)
        line.backgroundColor = self.tableView.separatorColor
        return line
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 15
    }
    
    func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        view.tintColor = UIColor.clear
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        let px = 1 / UIScreen.main.scale
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.frame.size.width, height: 10 + px))
        let frame = CGRect(x: 0, y: 0, width: self.tableView.frame.size.width, height: px)
        let line = UIView(frame: frame)
        line.backgroundColor = self.tableView.separatorColor
        footerView.addSubview(line)
        return footerView
    }

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch meSections[indexPath.section][indexPath.row] {
        case .profileTableCell( _ , _ , let segueId):
            self.performSegue(withIdentifier: segueId, sender: self)
        case .labelArrowTableCell(_, let segueId):
            if segueId == segueIdOfRateUSCFun {
                UIApplication.shared.openURL(URL(string : "itms-apps://itunes.apple.com/app/id1073401869")!)
            }
            else {
                self.performSegue(withIdentifier: segueId, sender: self)
            }
        case .labelImgArrowTableCell(_, _, let segueId):
            break
        case .labelSwitchTableCell(_):
            break
        case .regularTableCell(_, let segueId):
            if segueId == segueIdOfSignOut {
                LoginKit.signOut()
            }
        }
        
        tableView.deselectRow(at: indexPath, animated: false)
    }
}
