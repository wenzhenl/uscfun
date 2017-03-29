//
//  MyEventListViewController.swift
//  uscfun
//
//  Created by Wenzheng Li on 3/1/17.
//  Copyright © 2017 Wenzheng Li. All rights reserved.
//

import UIKit
import ChatKit
import SVProgressHUD

class MyEventListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var preloadDataSucceeded = true
    
    var numberOfSection: Int {
        if UserDefaults.hasPreloadedMyOngoingEvents {
            return EventRequest.myOngoingEvents.count + 1
        } else {
            return 1
        }
    }
    
    var emptyPlaceholder: String {
        if UserDefaults.hasPreloadedMyOngoingEvents {
            if !preloadDataSucceeded {
                return "预加载失败，请手动加载"
            }
            else if EventRequest.myOngoingEvents.count == 0 {
                return "你好像还没有参加任何微活动，快去参加一波吧！"
            }
            else {
                return ""
            }
        } else {
            return "正在加载数据，请稍后..."
        }
    }
    
    var numberOfNewEvents: Int = 0 {
        didSet {
            self.tabBarController?.tabBar.items![USCFunConstants.indexOfMyEventList].badgeValue = numberOfNewEvents > 0 ? "\(numberOfNewEvents)" : nil
        }
    }
    
    lazy var refreshController: UIRefreshControl = {
        let refreshController = UIRefreshControl()
        return refreshController
    }()
    
    lazy var infoLabel: UILabel = {
        let heightOfInfoLabel = CGFloat(29.0)
        let infoLabel = UILabel(frame: CGRect(x: 0.0, y: -heightOfInfoLabel, width: self.view.frame.size.width, height: heightOfInfoLabel))
        infoLabel.numberOfLines = 0
        infoLabel.textAlignment = .center
        infoLabel.lineBreakMode = .byWordWrapping
        infoLabel.font = UIFont.boldSystemFont(ofSize: 16)
        infoLabel.backgroundColor = UIColor.white
        infoLabel.textColor = UIColor.buttonPink
        infoLabel.isHidden = true
        return infoLabel
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("MyEventList view did load")
        
        self.navigationController?.view.backgroundColor = UIColor.white
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.darkGray]

        self.tableView.scrollsToTop = true
        self.tableView.tableFooterView = UIView()
        self.tableView.backgroundColor = UIColor.backgroundGray
        self.tableView.separatorStyle = .none
        
        self.tableView.addSubview(self.refreshController)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handlePreload(notification:)), name: NSNotification.Name(rawValue: "finishedPreloadingMyOngoingEvents"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleTab), name: NSNotification.Name(rawValue: "tabBarItemSelected"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleTabRefresh), name: NSNotification.Name(rawValue: "homeRefresh"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handlePostNewEvent), name: NSNotification.Name(rawValue: "userDidPostNewEvent"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleJoinEvent), name: NSNotification.Name(rawValue: "userDidJoinEvent"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleQuitEvent), name: NSNotification.Name(rawValue: "userDidQuitEvent"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleEventExpired(notification:)), name: NSNotification.Name(rawValue: "eventDidExpired"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleUpdateEvent(notification:)), name: NSNotification.Name(rawValue: "userDidUpdateEvent"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleCancelEvent(notification:)), name: NSNotification.Name(rawValue: "userDidCancelEvent"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleUpdatedEventAvailable(notification:)), name: NSNotification.Name(rawValue: "updatedEventAvailable"), object: nil)

        view.addSubview(infoLabel)
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
    
    func handlePreload(notification: Notification) {
        guard let info = notification.userInfo as? [String: Bool], let succeeded = info["succeeded"] else {
            print("cannot parse preload my ongoing events notification")
            return
            
        }
        print("my ongoing preload notification received:\(succeeded)")
        preloadDataSucceeded = succeeded
        self.tableView.reloadData()
        preloadDataSucceeded = true
    }
    
    func handleTab() {
        self.numberOfNewEvents = 0
    }
    
    func handleTabRefresh() {
        self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
    }
    
    func handlePostNewEvent() {
        numberOfNewEvents += 1
        self.tabBarController?.selectedIndex = USCFunConstants.indexOfMyEventList
        EventRequest.fetchNewerMyOngoingEventsInBackground {
            succeeded, error in
            if succeeded {
                self.tableView.reloadData()
            }
            
            if error != nil {
                self.displayInfo(info: error!.localizedDescription)
            }
        }
    }
    
    func handleJoinEvent() {
        self.numberOfNewEvents += 1
        self.tableView.reloadData()
    }
    
    func handleQuitEvent() {
        self.tableView.reloadData()
    }
    
    func handleEventExpired(notification: Notification) {
        self.tableView.reloadData()
    }
    
    func handleUpdateEvent(notification: Notification) {
        self.tableView.reloadData()
    }
    
    func handleCancelEvent(notification: Notification) {
        self.tableView.reloadData()
    }
    
    func handleUpdatedEventAvailable(notification: Notification) {
        guard let info = notification.userInfo as? [String: String], let eventId = info["eventId"] else {
            print("cannot parse UpdatedEventAvailable notification")
            return
        }
        if EventRequest.myOngoingEvents.keys.contains(eventId) {
            EventRequest.fetchEvent(with: eventId) {
                error, event in
                
                // TODO: if there's error, the update might be lost forever
                if let event = event {
                    
                    if event.isCancelled {
                        print("my ongoing events should not get cancelled")
                        if let section = self.sectionForEvent(eventId: event.objectId!) {
                            
                            EventRequest.removeEvent(with: event.objectId!, for: .myongoing) {
                                self.tableView.deleteSections(IndexSet([section]), with: .automatic)
                            }
                        }
                    } else {
                        EventRequest.setEvent(event: event, with: event.objectId!, for: .myongoing) {
                            self.tableView.reloadData()
                        }
                    }
                }
            }
        }
    }
    
    func handleRefresh() {
        let numberOfMyOngoingEventsBeforeUpdate = EventRequest.myOngoingEvents.count
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        EventRequest.fetchNewerMyOngoingEventsInBackground() {
            succeeded, error in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            if succeeded {
                let numberOfMyOngoingEventsAfterUpdate = EventRequest.myOngoingEvents.count
                if numberOfMyOngoingEventsAfterUpdate > numberOfMyOngoingEventsBeforeUpdate {
                    print("\(numberOfMyOngoingEventsAfterUpdate - numberOfMyOngoingEventsBeforeUpdate)个新的微活动")
                }
                self.refreshController.endRefreshing()
                self.tableView.reloadData()
            }
            else if error != nil {
                self.refreshController.endRefreshing()
                self.displayInfo(info: error!.localizedDescription)
            }
        }
    }
    
    func displayInfo(info: String) {
        self.infoLabel.isHidden = false
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
                        self.infoLabel.frame.origin.y = -self.infoLabel.frame.height
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
                    edVC.event = EventRequest.myOngoingEvents[(sender as! EventSnapshotTableViewCell).eventId!]
                case is FinalizedEventSnapshotTableViewCell:
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
        conversation.isDisableTitleAutoConfig = true
        conversation.disablesAutomaticKeyboardDismissal = false
        conversation.viewDidLoadBlock = {
            viewController in
            viewController?.navigationItem.title = event.name
            viewController?.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        }
        conversation.viewDidDisappearBlock = {
            viewController in
            SVProgressHUD.dismiss()
        }
        self.navigationController?.pushViewController(conversation, animated: true)
    }
}

extension MyEventListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.numberOfSection
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if EventRequest.myOngoingEvents.count == 0 {
            return self.tableView.frame.height - 44.0
        }
        
        if EventRequest.myOngoingEvents.count > 0 && indexPath.section == 0 {
            return 30
        }
        
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if EventRequest.myOngoingEvents.count == 0 {
            return 600
        }
        
        if indexPath.section == 0 {
            return 44
        }
        
        return 270
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = UIColor.white
        if indexPath.section == EventRequest.myOngoingEvents.count && EventRequest.thereIsUnfetchedOldMyOngoingEvents {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            EventRequest.fetchOlderMyOngoingEventsInBackground {
                succeeded, error in
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                if succeeded {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if EventRequest.myOngoingEvents.count == 0 {
            let cell = Bundle.main.loadNibNamed("EmptySectionPlaceholderTableViewCell", owner: self, options: nil)?.first as! EmptySectionPlaceholderTableViewCell
            cell.mainTextView.text = emptyPlaceholder
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
            let event = eventForSection(section: indexPath.section)
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
                cell.ifReadViewColor = event.finalizedColor
                
                cell.eventNameLabel.text = event.name
                cell.eventNameLabel.numberOfLines = 0
                cell.latestMessageLabel.text = "点击查看"
                cell.statusView.backgroundColor = event.statusColor
                cell.statusView.layer.masksToBounds = true
                cell.statusView.layer.cornerRadius = cell.statusView.frame.size.width / 2
                cell.statusViewColor = event.statusColor
                
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
                cell.statusViewColor = event.statusColor
                
                cell.chatButton.accessibilityHint = event.objectId
                cell.chatButton.addTarget(self, action: #selector(joinDiscussion(sender:)), for: .touchUpInside)
                
                cell.moreButton.isHidden = true
                
                cell.eventId = event.objectId
                
                cell.due = event.due
                
                return cell
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if EventRequest.myOngoingEvents.count == 0 {
            return CGFloat.leastNormalMagnitude
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
        if EventRequest.myOngoingEvents.count == 0 {
            return CGFloat.leastNormalMagnitude
        }
                
        if section > 0 {
            let event = eventForSection(section: section)
            if event.status == .isFinalized {
                if section < EventRequest.myOngoingEvents.count {
                    let nextEvent = eventForSection(section: section + 1)
                    if nextEvent.status == .isFinalized {
                        return CGFloat.leastNormalMagnitude
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
                conversation.isDisableTitleAutoConfig = true
                conversation.disablesAutomaticKeyboardDismissal = false
                conversation.viewDidLoadBlock = {
                    viewController in
                    viewController?.navigationItem.title = event.name + "(" + String(event.members.count) + ")"
                    viewController?.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
                }
                conversation.viewDidDisappearBlock = {
                    viewController in
                    SVProgressHUD.dismiss()
                }
                conversation.configureBarButtonItemStyle(.groupProfile) {
                    action in
                    print("group prifle here")
                }
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
            let delete = UITableViewRowAction(style: .default, title: "删除") {
                action, index in
                if let finalizedCell = tableView.cellForRow(at: indexPath) as? FinalizedEventSnapshotTableViewCell {
                    let alertVC = UIAlertController(title: "请确认微活动已经完结，不再需要继续讨论。完结活动可以在活动历史中查看。", message: nil, preferredStyle: .actionSheet)
                    let okay = UIAlertAction(title: "确认删除", style: .destructive) {
                        _ in
                        EventRequest.myOngoingEvents[finalizedCell.eventId!]?.setComplete(for: AVUser.current()!) {
                            succeeded, error in
                            if succeeded {
                                EventRequest.removeEvent(with: finalizedCell.eventId!, for: .myongoing) {
                                    print("about to delete finalized event")
                                    if EventRequest.myOngoingEvents.count == 0 {
                                        self.tableView.reloadData()
                                    } else {
                                        self.tableView.deleteSections(IndexSet([indexPath.section]), with: .fade)
                                    }
                                }
                            }

                            if error != nil {
                                self.displayInfo(info: error!.localizedDescription)
                            }
                        }
                    }
                    
                    let cancel = UIAlertAction(title: "取消", style: .cancel, handler: nil)
                    alertVC.addAction(okay)
                    alertVC.addAction(cancel)
                    self.present(alertVC, animated: true, completion: nil)
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
        return false
    }
}

extension MyEventListViewController: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if self.refreshController.isRefreshing {
            self.handleRefresh()
        }
    }
}
