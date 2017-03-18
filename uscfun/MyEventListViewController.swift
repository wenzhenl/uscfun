//
//  MyEventListViewController.swift
//  uscfun
//
//  Created by Wenzheng Li on 3/1/17.
//  Copyright © 2017 Wenzheng Li. All rights reserved.
//

import UIKit
import ChatKit

class MyEventListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    let emptyPlaceholder = "你好像还没有参加任何微活动，快去参加一波吧！"
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: UIControlEvents.valueChanged)
        return refreshControl
    }()
    
    var infoLabel: UILabel!
    let heightOfInfoLabel = CGFloat(29.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.scrollsToTop = true
        self.tableView.addSubview(self.refreshControl)
        if EventRequest.myOngoingEvents.count > 0 {
            self.tableView.backgroundColor = UIColor.backgroundGray
        } else {
            self.tableView.backgroundColor = UIColor.white
        }
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, -10, 0)
        self.tableView.tableFooterView = UIView()
        self.tableView.separatorStyle = .none
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleTab), name: NSNotification.Name(rawValue: "homeRefresh"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handlePostNewEvent), name: NSNotification.Name(rawValue: "userDidPostNewEvent"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handlePostNewEvent), name: NSNotification.Name(rawValue: "userDidJoinEvent"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleQuitEvent(notification:)), name: NSNotification.Name(rawValue: "userDidQuitEvent"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleEventExpired(notification:)), name: NSNotification.Name(rawValue: "eventDidExpired"), object: nil)
        
        infoLabel = UILabel(frame: CGRect(x: 0.0, y: -heightOfInfoLabel, width: view.frame.size.width, height: heightOfInfoLabel))
        infoLabel.numberOfLines = 0
        infoLabel.textAlignment = .center
        infoLabel.lineBreakMode = .byWordWrapping
        infoLabel.font = UIFont.boldSystemFont(ofSize: 16)
        infoLabel.isHidden = true
        view.addSubview(infoLabel)
        
        /// important for animation to work properly
        self.navigationController?.navigationBar.isTranslucent = false
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        infoLabel.isHidden = true
        infoLabel.frame.origin = CGPoint.zero
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        infoLabel.isHidden = true
        infoLabel.frame.origin = CGPoint.zero
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func handleTab() {
        self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
    }
    
    func handlePostNewEvent() {
        self.refreshControl.beginRefreshing()
        handleRefresh()
    }
    
    func handleQuitEvent(notification: Notification) {
        guard let userInfo = notification.userInfo, let eventId = userInfo["eventId"] as? String  else {
            print("cannot get user info from user did quit event notification")
            return
        }
        EventRequest.myOngoingEvents[eventId] = nil
        self.tableView.reloadData()
    }
    
    func handleEventExpired(notification: Notification) {
        guard let userInfo = notification.userInfo, let eventId = userInfo["eventId"] as? String  else {
            print("cannot get user info from event did expired notification")
            return
        }
        
        if EventRequest.myOngoingEvents.keys.contains(eventId) {
            EventRequest.fetchOneEvent(with: eventId) {
                error, event in
                if let event = event {
                    EventRequest.myOngoingEvents[eventId] = event
                }
                if let event = EventRequest.myOngoingEvents[eventId] {
                    switch event.status {
                    case .isFailed, .isCancelled, .isCompleted:
                        if let eventSection = self.sectionForEvent(eventId: eventId) {
                            EventRequest.myOngoingEvents[eventId] = nil
                            self.tableView.deleteSections(IndexSet([eventSection]), with: .fade)
                        }
                    case .isFinalized:
                        if let eventSection = self.sectionForEvent(eventId: eventId) {
                            self.tableView.reloadSections(IndexSet([eventSection]), with: .automatic)
                        }
                    default:
                        break
                    }
                }
            }
        }
    }
    
    func handleRefresh() {
        let numberOfMyOngoingEventsBeforeUpdate = EventRequest.myOngoingEvents.count
        EventRequest.fetchNewerMyOngoingEventsInBackground() {
            succeeded, error in
            if succeeded {
                if EventRequest.myOngoingEvents.count > 0 {
                    self.tableView.backgroundColor = UIColor.backgroundGray
                } else {
                    self.tableView.backgroundColor = UIColor.white
                }
                let numberOfMyOngoingEventsAfterUpdate = EventRequest.myOngoingEvents.count
                if numberOfMyOngoingEventsAfterUpdate > numberOfMyOngoingEventsBeforeUpdate {
                    self.displayInfo(info: "发现了\(numberOfMyOngoingEventsAfterUpdate - numberOfMyOngoingEventsBeforeUpdate)个新的微活动")
                } else {
                    self.displayInfo(info: "没有更新的微活动了")
                }
                self.tableView.reloadData()
            }
            else if error != nil {
                self.displayInfo(info: error!.localizedDescription)
            }
            self.refreshControl.endRefreshing()
        }
    }
    
    func displayInfo(info: String) {
        self.infoLabel.isHidden = false
        self.infoLabel.backgroundColor = UIColor.white
        self.infoLabel.textColor = UIColor.buttonPink
        self.infoLabel.text = info
        
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseInOut, animations: {
            _ in
            self.infoLabel.frame.origin.y = 0.0
            self.view.layoutIfNeeded()
        }) {
            completed in
            if completed {
                let delay = 1.5 * Double(NSEC_PER_SEC)
                let time = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC)
                DispatchQueue.main.asyncAfter(deadline: time) {
                    UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseInOut, animations: {
                        _ in
                        self.infoLabel.frame.origin.y = -self.heightOfInfoLabel
                        self.view.layoutIfNeeded()
                    }) {
                        finished in
                        if finished {
                            self.infoLabel.isHidden = true
                        }
                    }
                }
            }
        }
    }
    
    func sectionForEvent(eventId: String) -> Int? {
        guard let eventIndex = EventRequest.myOngoingEvents.keys.index(of: eventId) else { return nil }
        return eventIndex + 1
    }
    
    func eventForSection(section: Int) -> Event {
        return EventRequest.myOngoingEvents[EventRequest.myOngoingEvents.keys[section - 1]]!
    }
    
    let identifierToEventDetail = "go to event detail for my events"
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let identifier = segue.identifier else { return }
        switch identifier {
        case identifierToEventDetail:
            if let edVC = segue.destination as? EventDetailViewController {
                switch sender {
                case is EventSnapshotTableViewCell:
                    edVC.event = EventRequest.myOngoingEvents[(sender as! EventSnapshotTableViewCell).eventId!] ?? Event(name: "该微活动已经被系统回收", maximumAttendingPeople: 0, remainingSeats: 0, minimumAttendingPeople: 0, due: Date(), createdBy: AVUser.current()!)
                case is FinalizedEventSnapshotTableViewCell:
//                    EventRequest.myOngoingEvents[(sender as! FinalizedEventSnapshotTableViewCell).eventId!]?.setRead(for: AVUser.current()!) {
//                        succeed, error in
//                        if succeed {
//                         
//                        }
//                    }
//                    let rowIndex = self.tableView.indexPath(for: (sender as! FinalizedEventSnapshotTableViewCell))
//                    self.tableView.reloadRows(at: [rowIndex!], with: .automatic)
                    edVC.event = EventRequest.myOngoingEvents[(sender as! FinalizedEventSnapshotTableViewCell).eventId!]
                default:
                    break
                }
            }
        default:
            break
        }
    }
    
    func joinDiscussion(sender: UIButton) {
        guard let eventId = sender.accessibilityHint else { return }
        guard let event = EventRequest.myOngoingEvents[eventId] else { return }
        guard let conversation = LCCKConversationViewController(conversationId: event.transientConversationId) else {
            self.displayInfo(info: "网络错误，无法进入评论区")
            return
        }
        conversation.isEnableAutoJoin = true
        conversation.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(conversation, animated: true)
    }
}

extension MyEventListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if EventRequest.myOngoingEvents.count == 0 {
            return 1
        }
        
        return EventRequest.myOngoingEvents.count + 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if EventRequest.myOngoingEvents.count > 0 && indexPath.section == 0 {
            return 30
        }
        
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if EventRequest.myOngoingEvents.count == 0 {
            return 150
        }
        
        if indexPath.section == 0 {
            return 44
        }
        
        return 270
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if EventRequest.myOngoingEvents.count == 0 {
            let cell = Bundle.main.loadNibNamed("EmptySectionPlaceholderTableViewCell", owner: self, options: nil)?.first as! EmptySectionPlaceholderTableViewCell
            cell.mainTextView.text = emptyPlaceholder
            cell.backgroundColor = UIColor.clear
            cell.selectionStyle = .none
            return cell
        }
        else if indexPath.section == 0 {
            let cell = Bundle.main.loadNibNamed("EventStatusTableViewCell", owner: self, options: nil)?.first as! EventStatusTableViewCell
            cell.pendingView.layer.cornerRadius = cell.pendingView.frame.size.width / 2.0
            cell.pendingView.layer.backgroundColor = UIColor.eventPending.cgColor
            cell.securedView.layer.cornerRadius = cell.securedView.frame.size.width / 2.0
            cell.securedView.layer.backgroundColor = UIColor.eventSecured.cgColor
            cell.finalizedView.layer.cornerRadius = cell.finalizedView.frame.size.width / 2.0
            cell.finalizedView.layer.backgroundColor = UIColor.eventFinalized.cgColor
            cell.selectionStyle = .none
            return cell
        }
        else {
            let event = EventRequest.myOngoingEvents[EventRequest.myOngoingEvents.keys[indexPath.section - 1]]!
            let creator = User(user: event.createdBy)!

            if event.status == .isFinalized {
                let cell = Bundle.main.loadNibNamed("FinalizedEventSnapshotTableViewCell", owner: self, options: nil)?.first as! FinalizedEventSnapshotTableViewCell
                if event.hasUnread {
                    cell.ifReadView.layer.cornerRadius = 4
                    cell.ifReadView.backgroundColor = event.finalizedColor
                } else {
                    cell.ifReadView.layer.cornerRadius = 4
                    cell.ifReadView.layer.borderWidth = 2
                    cell.ifReadView.layer.borderColor = event.finalizedColor.cgColor
                    cell.ifReadView.backgroundColor = UIColor.clear
                }
                cell.eventNameLabel.text = event.name
                cell.eventNameLabel.numberOfLines = 0
                cell.latestMessageLabel.text = "tap to read"
                cell.statusView.backgroundColor = event.statusColor
                cell.statusView.layer.masksToBounds = true
                cell.statusView.layer.cornerRadius = cell.statusView.frame.size.width / 2
                cell.eventId = event.objectId
                return cell

            } else {
                let cell = Bundle.main.loadNibNamed("EventSnapshotTableViewCell", owner: self, options: nil)?.first as! EventSnapshotTableViewCell
                cell.eventNameLabel.text = event.name
                cell.creatorLabel.text = "发起人：" + creator.nickname
                cell.creatorAvatarImageView.layer.masksToBounds = true
                cell.creatorAvatarImageView.layer.cornerRadius = cell.creatorAvatarImageView.frame.size.width / 2.0
                cell.creatorAvatarImageView.image = creator.avatar
                
                cell.whitePaperImageView.image = event.whitePaper
                
                cell.needNumberLabel.text = String(event.remainingSeats)
                let gapFromNow = event.due.gapFromNow
                if gapFromNow == "" {
                    cell.remainingTimeLabel.textColor = UIColor.darkGray
                    cell.remainingTimeLabel.text = "报名已经结束"
                } else {
                    cell.remainingTimeLabel.text = gapFromNow
                }
                cell.attendingLabel.text = "已经报名 " + String(event.maximumAttendingPeople - event.remainingSeats)
                cell.minPeopleLabel.text = "最少成行 " + String(event.minimumAttendingPeople)
                
                cell.statusView.backgroundColor = event.statusColor
                cell.statusView.layer.masksToBounds = true
                cell.statusView.layer.cornerRadius = cell.statusView.frame.size.width / 2
                
                cell.chatButton.accessibilityHint = event.objectId
                cell.chatButton.addTarget(self, action: #selector(joinDiscussion(sender:)), for: .touchUpInside)
                
                cell.eventId = event.objectId
                
                cell.due = event.due
                cell.timerStarted()
                
                return cell
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if EventRequest.myOngoingEvents.count == 0 {
            return 0
        }
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
        if section == 0 {
            return 0
        }
        
        if section > 0 {
            let event = eventForSection(section: section)
            if event.status == .isFinalized {
                if section < EventRequest.myOngoingEvents.count {
                    let nextEvent = eventForSection(section: section + 1)
                    if nextEvent.status == .isFinalized {
                        return 0
                    } else {
                        return 12
                    }
                } else {
                    return 10
                }
            }
        }
        
        return 10
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
        if EventRequest.myOngoingEvents.count > 0 && indexPath.section > 0 {
            let event = self.eventForSection(section: indexPath.section)
            if event.status == .isFinalized {
                guard let conversation = LCCKConversationViewController(conversationId: event.conversationId) else {
                    self.displayInfo(info: "网络错误，无法进入评论区")
                    tableView.deselectRow(at: indexPath, animated: true)
                    return
                }
                conversation.isEnableAutoJoin = true
                conversation.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(conversation, animated: true)
            } else {
                performSegue(withIdentifier: identifierToEventDetail, sender: tableView.cellForRow(at: indexPath))
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        guard EventRequest.myOngoingEvents.count > 0, indexPath.section > 0 else { return nil }
        let event = self.eventForSection(section: indexPath.section)
        if event.status == .isFinalized {
            let more = UITableViewRowAction(style: .normal, title: "详情") {
                action, index in
                self.performSegue(withIdentifier: self.identifierToEventDetail, sender: tableView.cellForRow(at: index))
            }
            let delete = UITableViewRowAction(style: .default, title: "完结") {
                action, index in
                if let finalizedCell = tableView.cellForRow(at: indexPath) as? FinalizedEventSnapshotTableViewCell {
                    if UserDefaults.hasSeenCompleteEventTip {
                        EventRequest.myOngoingEvents[finalizedCell.eventId!]?.setComplete(for: AVUser.current()!) {
                            succeeded, error in
                            if succeeded {
                                EventRequest.myOngoingEvents[finalizedCell.eventId!] = nil
                                tableView.deleteSections(IndexSet([indexPath.section]), with: .fade)
                            }
                            
                            if error != nil {
                                self.displayInfo(info: error!.localizedDescription)
                            }
                        }
                    } else {
                        let alertViewController = UIAlertController(title: nil, message: "请确认你已经不需要跟其他队友继续讨论该微活动。完结后该微活动将会出现在 我->我发起(参加)过的活动中", preferredStyle: .alert)
                        let okay = UIAlertAction(title: "确认", style: .default) {
                            _ in
                            EventRequest.myOngoingEvents[finalizedCell.eventId!]?.setComplete(for: AVUser.current()!) {
                                succeeded, error in
                                if succeeded {
                                    EventRequest.myOngoingEvents[finalizedCell.eventId!] = nil
                                    tableView.deleteSections(IndexSet([indexPath.section]), with: .fade)
                                    UserDefaults.hasSeenCompleteEventTip = true
                                }
                                
                                if error != nil {
                                    self.displayInfo(info: error!.localizedDescription)
                                }
                            }
                        }
                        let cancel = UIAlertAction(title: "取消", style: .cancel, handler: nil)
                        alertViewController.addAction(cancel)
                        alertViewController.addAction(okay)
                        self.present(alertViewController, animated: true, completion: nil)
                    }
                }
            }
            return [delete, more]
        } else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        guard EventRequest.myOngoingEvents.count > 0, indexPath.section > 0 else { return false }
        let event = self.eventForSection(section: indexPath.section)
        if event.status == .isFinalized {
            return true
        }
        return false
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    }
}

extension Event {
    enum RelationWithMe {
        case createdByMe
        case joinedByMe
        case noneOfMyBusiness
    }
    
    var statusColor: UIColor {
        switch self.status {
        case .isPending:
            return UIColor.eventPending
        case .isSecured:
            return UIColor.eventSecured
        case .isFinalized:
            return UIColor.eventFinalized
        default:
            return UIColor.darkGray
        }
    }
    
    var finalizedColor: UIColor {
        if let index = self.objectId?.hash {
            return USCFunConstants.avatarColorOptions[abs(index) % USCFunConstants.avatarColorOptions.count]
        }
        return USCFunConstants.avatarColorOptions[0]
    }
    
    var whitePaper: UIImage {
        let possibleWhitePapers = [#imageLiteral(resourceName: "clip4"), #imageLiteral(resourceName: "clip1"), #imageLiteral(resourceName: "clip2"), #imageLiteral(resourceName: "clip3")]
        if let index = self.objectId?.hash {
            return possibleWhitePapers[abs(index) % possibleWhitePapers.count]
        }
        return possibleWhitePapers[0]
    }
    
    var relationWithMe: RelationWithMe {
        if self.createdBy == AVUser.current()! {
            return .createdByMe
        }
        if self.members.contains(AVUser.current()!) {
            return .joinedByMe
        }
        return .noneOfMyBusiness
    }
    
    var hasUnread: Bool {
        if (self.hasUnreadMessage ?? []).contains(AVUser.current()!) {
            return true
        }
        return false
    }
}
