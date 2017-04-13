//
//  UserProfileViewController.swift
//  uscfun
//
//  Created by Wenzheng Li on 11/4/16.
//  Copyright © 2016 Wenzheng Li. All rights reserved.
//

import UIKit
import ChatKit
import SVProgressHUD

enum UserProfileCell {
    case avatarCell
    case statCell
    case creditRecordCell
    case introductionCell
    case segmentedCell
    case eventCell
    case noEventCell
}

class UserProfileViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var user: AVUser!
    var other: User!
    var showingCreatedEvents = true
    var userProfileSections = [UserProfileCell]()
    
    let numberOfPreservedSection = 5
   
    var genderTitle: String!
 
    var attendedEvents = OrderedDictionary<String, Event>()
    var createdEvents = OrderedDictionary<String, Event>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.tableView.backgroundColor = UIColor.backgroundGray
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, -10, 0)
        self.tableView.tableFooterView = UIView()
        
        other = User(user: user)
        self.title = other.nickname
//        if user != AVUser.current()! {
//            let messageImage = #imageLiteral(resourceName: "send").scaleTo(width: 22, height: 22)
//            self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: messageImage, style: .plain, target: self, action: #selector(sendMessage))
//        }
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)

        let fetchGroup = DispatchGroup()
        fetchGroup.enter()
        EventRequest.fetchEventsCreated(by: user) {
            error, events in
            if let events = events {
                for event in events {
                    if event.status == .isFinalized {
                        self.createdEvents[event.objectId!] = event
                    }
                }
            }
            fetchGroup.leave()
        }
        fetchGroup.enter()
        EventRequest.fetchEventsAttended(by: self.user) {
            error, events in
            if let events = events {
                for event in events {
                    if event.status == .isFinalized {
                        self.attendedEvents[event.objectId!] = event
                    }
                }
            }
            fetchGroup.leave()
        }
        fetchGroup.notify(queue: DispatchQueue.main) {
            self.populateSections()
            self.tableView.reloadData()
        }
        self.populateSections()
    }
    
    func populateSections() {
        //--MARK: populate the cells
        if other.gender == .female {
            genderTitle = "她"
        }
        else if other.gender == .male {
            genderTitle = "他"
        }
        else {
            genderTitle = "TA"
        }

        userProfileSections.removeAll()
        userProfileSections.append(UserProfileCell.avatarCell)
        userProfileSections.append(UserProfileCell.statCell)
        userProfileSections.append(UserProfileCell.creditRecordCell)
        userProfileSections.append(UserProfileCell.introductionCell)
        userProfileSections.append(UserProfileCell.segmentedCell)
        
        if other.allowsEventHistoryViewed {
            if showingCreatedEvents {
                if createdEvents.count == 0 {
                    userProfileSections.append(UserProfileCell.noEventCell)
                } else {
                    userProfileSections += Array(repeating: UserProfileCell.eventCell, count: createdEvents.count)
                }
            } else {
                if attendedEvents.count == 0 {
                    userProfileSections.append(UserProfileCell.noEventCell)
                } else {
                    userProfileSections += Array(repeating: UserProfileCell.eventCell, count: attendedEvents.count)
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
    
    func avatarTapped() {
        performSegue(withIdentifier: identifierToBigAvatar, sender: self)
    }
    
    func sendMessage() {
        guard let conversation = LCCKConversationViewController(peerId: other.username) else {
            SVProgressHUD.showError(withStatus: "无法连接网络")
            return
        }
        conversation.isEnableAutoJoin = true
        conversation.hidesBottomBarWhenPushed = true
        conversation.isDisableTitleAutoConfig = true
        conversation.disablesAutomaticKeyboardDismissal = false
        conversation.viewDidLoadBlock = {
            viewController in
            viewController?.navigationItem.title = self.other.nickname
            viewController?.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        }
        conversation.viewDidAppearBlock = {
            (viewController, animated) in
            print("conversation controller view did appear")
            viewController?.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        }
        
        conversation.viewWillDisappearBlock = {
            (viewController, animated) in
            print("conversation controller view will disappear")
            viewController?.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
            SVProgressHUD.dismiss()
        }
        
        conversation.configureBarButtonItemStyle(.singleProfile) {
            action in
            print("single prifle here")
        }
        self.navigationController?.pushViewController(conversation, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
            case identifierToBigAvatar:
                let destination = segue.destination.contentViewController
                if let bpVC = destination as? BigPictureViewController {
                    bpVC.image = other.avatar
                }
            default:
                break
            }
        }
    }
    
    let identifierToBigAvatar = "go to see big picture"
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

            if other.username != USCFunConstants.systemAdministratorClientId {
                cell.officialBadgeButton.isHidden = true
            }
            cell.avatarButton.setBackgroundImage(other.avatar, for: .normal)
            cell.avatarButton.layer.masksToBounds = true
            cell.avatarButton.layer.cornerRadius = 35
            cell.avatarButton.contentMode = .scaleAspectFit
            cell.avatarButton.addTarget(self, action: #selector(avatarTapped), for: .touchUpInside)
            if other.gender != nil && other.gender != Gender.unknown {
                cell.genderLabel.text = other.gender!.rawValue
            } else {
                cell.genderLabel.text = ""
            }
            cell.selectionStyle = .none
            return cell
        case .creditRecordCell:
            let cell = Bundle.main.loadNibNamed("CreditRecordTableViewCell", owner: self, options: nil)?.first as! CreditRecordTableViewCell
            cell.titleLabel.text = "信用等级："
            cell.ratingBar.isUserInteractionEnabled = false
            cell.ratingBar.rating = 2.5
            cell.ratingBar.ratingMin = 1.0
            cell.ratingBar.allowsPartialStar = true
            cell.ratingBar.isIndicator = true

            return cell
        case .statCell:
            let cell = Bundle.main.loadNibNamed("TandemLabelTableViewCell", owner: self, options: nil)?.first as! TandemLabelTableViewCell
            cell.leftLabel.textColor = UIColor.darkGray
            cell.leftLabel.text = "发起微活动：" + String(createdEvents.count)
            cell.rightLabel.textColor = UIColor.darkGray
            cell.rightLabel.text = "参加微活动：" + String(attendedEvents.count)
            cell.selectionStyle = .none
            return cell
        case .introductionCell:
             let cell = Bundle.main.loadNibNamed("TitleTextViewTableViewCell", owner: self, options: nil)?.first as! TitleTextViewTableViewCell
            cell.titleLabel.text = "个人简介"
            cell.textView.text = other.selfIntroduction ?? genderTitle + "什么都没有留下"
            cell.selectionStyle = .none
            return cell
        case .segmentedCell:
            let cell = Bundle.main.loadNibNamed("SegmentedTableViewCell", owner: self, options: nil)?.first as! SegmentedTableViewCell
          
            cell.segmentedControl.setTitle(genderTitle + "发起过的微活动", forSegmentAt: 0)
            cell.segmentedControl.setTitle(genderTitle + "参加过的微活动", forSegmentAt: 1)
            cell.segmentedControl.selectedSegmentIndex = showingCreatedEvents ? 0 : 1
            cell.segmentedControl.addTarget(self, action: #selector(handleSegmentedControl(_:)), for: .valueChanged)
            cell.selectionStyle = .none
            return cell
        case .eventCell:
            let cell = Bundle.main.loadNibNamed("CompletedEventSnapshotTableViewCell", owner: self, options: nil)?.first as! CompletedEventSnapshotTableViewCell
            var event: Event!
            event = showingCreatedEvents ? createdEvents[createdEvents.keys[indexPath.section - numberOfPreservedSection]] : attendedEvents[attendedEvents.keys[indexPath.section - numberOfPreservedSection]]
            let creator = User(user: event.createdBy)!
            cell.eventNameLabel.text = event.name
            cell.creatorLabel.text = "发起人：" + creator.nickname
            cell.creatorAvatarImageView.layer.masksToBounds = true
            cell.creatorAvatarImageView.layer.cornerRadius = cell.creatorAvatarImageView.frame.size.width / 2.0
            cell.creatorAvatarImageView.image = creator.avatar
            cell.createdAtDateLabel.text = event.createdAt!.readableDate
            cell.createdAtTimeLabel.text = event.createdAt!.readableTime
            cell.attendingPeopleLabel.text = String(event.maximumAttendingPeople - event.remainingSeats)
            
            cell.selectionStyle = .none
            return cell
        case .noEventCell:
            let cell = Bundle.main.loadNibNamed("EmptySectionPlaceholderTableViewCell", owner: self, options: nil)?.first as! EmptySectionPlaceholderTableViewCell
            if !other.allowsEventHistoryViewed {
                cell.mainTextView.text = "用户没有公开活动历史"
            } else if createdEvents.count == 0 {
                cell.mainTextView.text = "用户还没有发起过任何活动"
            } else {
                cell.mainTextView.text = "用户还没有参加过任何活动"
            }
            cell.selectionStyle = .none
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
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
      if userProfileSections[indexPath.section] == .creditRecordCell {
            if let webVC = UIStoryboard(name: "Login", bundle: nil).instantiateViewController(withIdentifier: USCFunConstants.storyboardIdentifierOfWebViewController) as? WebViewController {
                webVC.url = URL(string: USCFunConstants.creditRecordURL)
                self.navigationController?.pushViewController(webVC, animated: true)
            }
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
            return 0
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
        if userProfileSections[section] == .avatarCell {
            footerView.backgroundColor = UIColor.white
        }
        
        if userProfileSections[section] == .introductionCell {
            footerView.backgroundColor = UIColor.backgroundGray
        }
        if userProfileSections[section] == .eventCell {
            let px = 1 / UIScreen.main.scale
            let footerView = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.frame.size.width, height: 10 + px))
            footerView.backgroundColor = UIColor.backgroundGray
            let frame = CGRect(x: 0, y: 0, width: self.tableView.frame.size.width, height: px)
            let line = UIView(frame: frame)
            line.backgroundColor = self.tableView.separatorColor
            footerView.addSubview(line)
            return footerView
        }
        return footerView
    }
}
