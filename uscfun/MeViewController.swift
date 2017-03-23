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
    case labelSwitchTableCell(text: String)
    case regularTableCell(text: String, segueId: String)
}

class MeViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var meSections = [[MeCell]]()
    var selectedIndex: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.view.backgroundColor = UIColor.white
        self.tableView.backgroundColor = UIColor.backgroundGray
        self.tableView.tableFooterView = UIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.populateSections()
        self.tableView.reloadData()
    }
    
    
    func populateSections() {
        //--MARK: populate the cells
        meSections.removeAll()
        let profileSection = [MeCell.profileTableCell(image: UserDefaults.avatar!, text: UserDefaults.nickname!, segueId: segueIdOfUpdateProfile)]
        meSections.append(profileSection)
        
        let eventHistorySection = [MeCell.labelArrowTableCell(text: textOfCreatedHistory, segueId: segueIdOfCheckEventHistory),
                                   MeCell.labelArrowTableCell(text: textOfAttendedHistory, segueId: segueIdOfCheckEventHistory)]
        meSections.append(eventHistorySection)
        
        let privacySection = [MeCell.labelSwitchTableCell(text: textOfAllowEventHistroyViewed)]
        meSections.append(privacySection)
        
        let appInfoSection = [MeCell.labelArrowTableCell(text: textOfFeedback, segueId: segueIdOfFeedback),
                              MeCell.labelArrowTableCell(text: "给USC日常评分", segueId: segueIdOfRateUSCFun),
                              MeCell.labelArrowTableCell(text: "关于USC日常", segueId: segueIdOfAboutUSCFun)]
        meSections.append(appInfoSection)
        
        let signOutSection = [MeCell.regularTableCell(text: "退出登录", segueId: segueIdOfSignOut)]
        meSections.append(signOutSection)
    }
    
    func switchAllowEventHistoryViewedMode(switchElement: UISwitch) {
        print(switchElement.isOn)
        UserDefaults.allowsEventHistoryViewed = switchElement.isOn
        UserDefaults.updateAllowsEventHistoryViewed()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
            case segueIdOfCheckEventHistory:
                let destination = segue.destination
                if let ehVC = destination as? EventHistoryViewController {
                    switch meSections[(selectedIndex?.section)!][(selectedIndex?.row)!] {
                    case .labelArrowTableCell(let text, _):
                        if text == textOfCreatedHistory {
                            ehVC.eventHistorySource = .created
                        } else {
                            ehVC.eventHistorySource = .attended
                        }
                    default: break
                    }
                }
            default:
                break
            }
        }
    }
    
    let textOfAllowEventHistroyViewed = "公开活动历史"
    let textOfCreatedHistory = "我发起过的活动"
    let textOfAttendedHistory = "我参加过的活动"
    let textOfFeedback = "反馈问题与建议"
    
    let segueIdOfUpdateProfile = "go to update profile"
    let segueIdOfCheckEventHistory = "go to event history"
    let segueIdOfRateUSCFun = "go to rate app"
    let segueIdOfAboutUSCFun = "go to about uscfun"
    let segueIdOfFeedback = "go to feedback"
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
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == meSections.count - 2 {
            return 40
        }
        return 15
    }
    
    func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        view.tintColor = UIColor.clear
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        selectedIndex = indexPath
        switch meSections[indexPath.section][indexPath.row] {
        case .profileTableCell( _ , _ , let segueId):
            self.performSegue(withIdentifier: segueId, sender: self)
        case .labelArrowTableCell(_, let segueId):
            print(segueId)
            if segueId == segueIdOfRateUSCFun {
                UIApplication.shared.openURL(URL(string : "itms-apps://itunes.apple.com/app/id1073401869")!)
            }
            else {
                self.performSegue(withIdentifier: segueId, sender: self)
            }
        case .regularTableCell(_, let segueId):
            if segueId == segueIdOfSignOut {
                LoginKit.signOut()
            }
        default: break
        }
        tableView.deselectRow(at: indexPath, animated: false)
    }
}
