//
//  UserProfileViewController.swift
//  uscfun
//
//  Created by Wenzheng Li on 11/4/16.
//  Copyright © 2016 Wenzheng Li. All rights reserved.
//

import UIKit

enum UserProfileCell {
    case avatarCell
    case statCell
    case introductionCell
    case segmentedCell
    case eventCell
    case noEventCell
}

class UserProfileViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var other: User!
    var showingCreatedEvents = true
    var userProfileSections = [UserProfileCell]()
    
    let numberOfPreservedSection = 4
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = other.nickname
        self.tableView.backgroundColor = UIColor.white
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 50, 0)
        self.tableView.tableFooterView = UIView()
        self.populateSections()
    }
    
    func populateSections() {
        //--MARK: populate the cells
        userProfileSections.removeAll()
        userProfileSections.append(UserProfileCell.avatarCell)
        userProfileSections.append(UserProfileCell.statCell)
        userProfileSections.append(UserProfileCell.introductionCell)
        userProfileSections.append(UserProfileCell.segmentedCell)
        
        if other.allowsEventHistoryViewed {
            if showingCreatedEvents {
                if other.createdEvents.count == 0 {
                    userProfileSections.append(UserProfileCell.noEventCell)
                } else {
                    print(userProfileSections.count)
                    userProfileSections += Array(repeating: UserProfileCell.eventCell, count: other.createdEvents.count)
                     print(userProfileSections.count)
                }
            } else {
                if other.attendedEvents.count == 0 {
                    userProfileSections.append(UserProfileCell.noEventCell)
                } else {
                    userProfileSections += Array(repeating: UserProfileCell.eventCell, count: other.attendedEvents.count)
                }
            }
        } else {
            userProfileSections.append(UserProfileCell.noEventCell)
        }
    }
    
    func handleSegmentedControl(_ sender: UISegmentedControl) {
        print(sender.selectedSegmentIndex)
        switch sender.selectedSegmentIndex {
        case 0:
            showingCreatedEvents = true
        case 1:
            showingCreatedEvents = false
        default:
            break
        }
        self.populateSections()
        self.tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
            case identifierToEventDetail:
                let destination = segue.destination
                if let edVC = destination as? EventDetailViewController {
                    edVC.event = showingCreatedEvents ? other.createdEvents[other.createdEvents.keys[(self.tableView.indexPathForSelectedRow?.section)! - numberOfPreservedSection]] : other.attendedEvents[other.attendedEvents.keys[(self.tableView.indexPathForSelectedRow?.section)! - numberOfPreservedSection]]
                }
            default:
                break
            }
        }
    }
    
    let identifierToEventDetail = "go to event detail"
}

extension UserProfileViewController: UITableViewDataSource, UITableViewDelegate{

    func numberOfSections(in tableView: UITableView) -> Int {
        return userProfileSections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch userProfileSections[indexPath.section] {
        case .avatarCell:
            let cell = Bundle.main.loadNibNamed("UserProfileHeaderTableViewCell", owner: self, options: nil)?.first as! UserProfileHeaderTableViewCell
            cell.avatarImageView.image = other.avatar
            cell.avatarImageView.layer.masksToBounds = true
            cell.avatarImageView.layer.cornerRadius = cell.avatarImageView.frame.size.width / 2.0
            cell.selectionStyle = .none
            return cell
        case .statCell:
            let cell = Bundle.main.loadNibNamed("TandemLabelTableViewCell", owner: self, options: nil)?.first as! TandemLabelTableViewCell
            cell.leftLabel.textColor = UIColor.darkGray
            cell.leftLabel.text = "发起活动：20"
            cell.rightLabel.textColor = UIColor.darkGray
            cell.rightLabel.text = "参加活动：10"
            cell.selectionStyle = .none
            return cell
        case .introductionCell:
             let cell = Bundle.main.loadNibNamed("TitleTextViewTableViewCell", owner: self, options: nil)?.first as! TitleTextViewTableViewCell
            cell.titleLabel.text = "个人简介"
            cell.textView.text = "这个人什么都没有留下"
            cell.selectionStyle = .none
            return cell
        case .segmentedCell:
            let cell = Bundle.main.loadNibNamed("SegmentedTableViewCell", owner: self, options: nil)?.first as! SegmentedTableViewCell
            cell.segmentedControl.setTitle("发起过活动", forSegmentAt: 0)
            cell.segmentedControl.setTitle("参加过活动", forSegmentAt: 1)
            cell.segmentedControl.selectedSegmentIndex = showingCreatedEvents ? 0 : 1
            cell.segmentedControl.addTarget(self, action: #selector(handleSegmentedControl(_:)), for: .valueChanged)
            cell.selectionStyle = .none
            return cell
        case .eventCell:
            let cell = Bundle.main.loadNibNamed("EventSnapshotTableViewCell", owner: self, options: nil)?.first as! EventSnapshotTableViewCell
            var event: Event!
            event = showingCreatedEvents ? other.createdEvents[other.createdEvents.keys[indexPath.section - numberOfPreservedSection]] : other.attendedEvents[other.attendedEvents.keys[indexPath.section - numberOfPreservedSection]]
            let creator = User(user: event.creator)!
            cell.eventNameLabel.text = event.name
            cell.creatorLabel.text = "发起人：" + creator.nickname
            cell.creatorAvatarImageView.layer.masksToBounds = true
            cell.creatorAvatarImageView.layer.cornerRadius = cell.creatorAvatarImageView.frame.size.width / 2.0
            cell.creatorAvatarImageView.image = creator.avatar
            
            let possibleWhitePapers = [#imageLiteral(resourceName: "clip4"), #imageLiteral(resourceName: "clip1"), #imageLiteral(resourceName: "clip2"), #imageLiteral(resourceName: "clip3")]
            let randomIndex = Int(arc4random_uniform(UInt32(possibleWhitePapers.count)))
            cell.whitePaperImageView.image = possibleWhitePapers[randomIndex]
            
            cell.needNumberLabel.text = String(event.remainingSeats)
            cell.remainingTimeLabel.text = event.due.gapFromNow
            
            cell.attendingLabel.text = "已经报名 " + String(event.totalSeats - event.remainingSeats)
            cell.minPeopleLabel.text = "最少成行 " + String(event.minimumAttendingPeople)
            
            cell.statusView.backgroundColor = event.statusColor
            cell.statusView.layer.masksToBounds = true
            cell.statusView.layer.cornerRadius = cell.statusView.frame.size.width / 2
            return cell
        case .noEventCell:
            let cell = Bundle.main.loadNibNamed("EmptySectionPlaceholderTableViewCell", owner: self, options: nil)?.first as! EmptySectionPlaceholderTableViewCell
            if !other.allowsEventHistoryViewed {
                cell.mainTextView.text = "用户没有公开活动历史"
            } else if other.createdEvents.count == 0 {
                cell.mainTextView.text = "用户还没有发起过任何活动"
            } else {
                cell.mainTextView.text = "用户还没有参加过任何活动"
            }
            cell.selectionStyle = .none
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if userProfileSections[indexPath.section] == .avatarCell {
            return 90
        }
        
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if userProfileSections[indexPath.section] == .avatarCell {
            return 90
        }
        return 300
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = UIColor.white
    }
    
    func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        view.tintColor = UIColor.clear
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if userProfileSections[indexPath.section] == .eventCell {
            performSegue(withIdentifier: identifierToEventDetail, sender: self)
        }
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if userProfileSections[section] == .introductionCell {
            return 1 / UIScreen.main.scale
        }
        if userProfileSections[section] == .eventCell {
            return 1 / UIScreen.main.scale
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let px = 1 / UIScreen.main.scale
        let frame = CGRect(x: 8, y: 0, width: self.tableView.frame.size.width, height: px)
        let line = UIView(frame: frame)
        line.backgroundColor = self.tableView.separatorColor
        return line
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if userProfileSections[section] == .avatarCell {
            return 15
        }
        if userProfileSections[section] == .introductionCell {
            return 10
        }
        if userProfileSections[section] == .eventCell {
            return 10
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.frame.size.width, height: 10))
        if userProfileSections[section] == .introductionCell {
            footerView.backgroundColor = UIColor.backgroundGray
        }
        if userProfileSections[section] == .eventCell {
            let px = 1 / UIScreen.main.scale
            let footerView = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.frame.size.width, height: 10 + px))
            let frame = CGRect(x: 0, y: 0, width: self.tableView.frame.size.width, height: px)
            let line = UIView(frame: frame)
            line.backgroundColor = self.tableView.separatorColor
            footerView.addSubview(line)
            return footerView
        }
        return footerView
    }
}
