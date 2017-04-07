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
import SCLAlertView

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
        NotificationCenter.default.addObserver(self, selector: #selector(handlerNewMessage(notification:)), name: NSNotification.Name(rawValue: "newMessageForMyEvents"), object: nil)

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
        
        if UserDefaults.shouldRemindRateApp {
            UserDefaults.lastRateAppRemindedAt = Date()
            let appearance = SCLAlertView.SCLAppearance(showCloseButton: false)
            let alertView = SCLAlertView(appearance: appearance)
            alertView.addButton("去评分") {
                UserDefaults.hasRatedApp = true
                UIApplication.shared.openURL(URL(string : USCFunConstants.appURL)!)
            }
            alertView.addButton("暂时不要") {
                print("remind opening rate app ignored")
            }
            alertView.showInfo("给USC日常评分", subTitle: "如果觉得USC日常还不错的话，请去 app store 给我们一点鼓励吧！")
        }
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
        
        if UserDefaults.shouldRemindOpenRemoteNotification {
            UserDefaults.lastOpenRemoteNotificationRemindedAt = Date()
            let appearance = SCLAlertView.SCLAppearance(showCloseButton: false)
            let alertView = SCLAlertView(appearance: appearance)
            alertView.addButton("请通知我") {
                UserDefaults.hasOpenedRemoteNotification = true
                let notificationSettings = UIUserNotificationSettings(types: [UIUserNotificationType.badge, .sound, .alert], categories: nil)
                UIApplication.shared.registerUserNotificationSettings(notificationSettings)
            }
            alertView.addButton("暂时不要") {
                print("remind opening remote notification ignored")
            }
            
            alertView.showSuccess("打开通知", subTitle:     "恭喜你成功发起了第一个微活动，请打开通知，防止错过小伙伴们对于你发起的微活动的询问。")
        }
    }
    
    func handleJoinEvent() {
        self.numberOfNewEvents += 1
        self.tableView.reloadData()
        
        if UserDefaults.shouldRemindOpenRemoteNotification {
            UserDefaults.lastOpenRemoteNotificationRemindedAt = Date()
            let appearance = SCLAlertView.SCLAppearance(showCloseButton: false)
            let alertView = SCLAlertView(appearance: appearance)
            alertView.addButton("请通知我") {
                UserDefaults.hasOpenedRemoteNotification = true
                let notificationSettings = UIUserNotificationSettings(types: [UIUserNotificationType.badge, .sound, .alert], categories: nil)
                UIApplication.shared.registerUserNotificationSettings(notificationSettings)
            }
            alertView.addButton("暂时不要") {
                print("remind opening remote notification ignored")
            }
            
            alertView.showSuccess("打开通知", subTitle: "恭喜你成功参加了第一个微活动，请打开通知，防止错过小伙伴们对于活动的讨论。")
        }
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
    
    
    func handlerNewMessage(notification: Notification) {
        guard let userInfo = notification.userInfo as? [String: Any], let action = userInfo["action"] as? String, let conversationId = userInfo["conversationId"] as? String, let message = userInfo["message"] as? AVIMTypedMessage else {
            print("failed to parse new message notification")
            return
        }
        
        var text = ""
        let mediaType = MessageMediaType(rawValue: Int(message.mediaType))!
        switch mediaType {
        case .plain:
            text = message.text ?? ""
        case .image:
            text = "[图片]"
        case .audio:
            text = "[语音信息]"
        case .video:
            text = "[视频信息]"
        case .geolocation:
            text = "[位置]"
        case .file:
            text = "[文件]"
        }
        
        guard let conversationRecords = ConversationList.parseConversationRecords(), let conversationRecord = conversationRecords[conversationId] else {
            /// if the conversation is not in record yet
            print("conversation is not in record yet")
            for id in EventRequest.myOngoingEvents.keys {
                let event = EventRequest.myOngoingEvents[id]!
                if event.conversationId == conversationId {
                    var newRecord: ConversationRecord? = nil
                    if action == "send" {
                        newRecord = ConversationRecord(eventId: event.objectId!, latestMessage: text, isUnread: false, lastUpdatedAt: Int64(Date().timeIntervalSince1970))
                    }
                    else if action == "receive" {
                        if message.clientId == AVUser.current()!.username {
                            newRecord = ConversationRecord(eventId: event.objectId!, latestMessage: text, isUnread: false, lastUpdatedAt: message.sendTimestamp)
                        } else {
                            newRecord = ConversationRecord(eventId: event.objectId!, latestMessage: text, isUnread: true, lastUpdatedAt: message.sendTimestamp)
                        }
                    }
                    if newRecord != nil {
                        do {
                            try ConversationList.addRecord(conversationId: conversationId, record: newRecord!)
                        } catch let error {
                            print("save conversation record failed: \(error)")
                        }
                    }
                    EventRequest.setEvent(event: event, with: event.objectId!, for: .myongoing) {
                        self.tableView.reloadData()
                        return
                    }
                    return
                }
            }
            return
        }
        
        /// if the conversation is already in record
        
        guard let event = EventRequest.myOngoingEvents[conversationRecord.eventId] else {
            print("receive new message for events not mine")
            return
        }
        
        var newRecord: ConversationRecord?
        if action == "send" {
            newRecord = ConversationRecord(eventId: conversationRecord.eventId, latestMessage: text, isUnread: false, lastUpdatedAt: Int64(Date().timeIntervalSince1970))
        }
        else if action == "receive" {
            if message.clientId == AVUser.current()!.username {
                newRecord = ConversationRecord(eventId: conversationRecord.eventId, latestMessage: text, isUnread: false, lastUpdatedAt: message.sendTimestamp)
            } else {
                newRecord = ConversationRecord(eventId: conversationRecord.eventId, latestMessage: text, isUnread: true, lastUpdatedAt: message.sendTimestamp)
            }
        }
        if newRecord != nil {
            do {
                try ConversationList.addRecord(conversationId: conversationId, record: newRecord!)
            } catch let error {
                print("save conversation record failed: \(error)")
            }
        }
        
        EventRequest.setEvent(event: event, with: event.objectId!, for: .myongoing) {
            self.tableView.reloadData()
        }
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
                        
                        if event.createdBy == AVUser.current()! && event.status == .isFinalized {
                            LCChatKit.sharedInstance().sendWelcomeMessage(toConversationId: event.conversationId, text: USCFunConstants.finalizedMessage) {
                                succeeded, error in
                                if succeeded {
                                    print("send finalized message successfully")
                                }
                                if error != nil {
                                    print(error!)
                                }
                            }
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
                case is MyEventSnapshotTableViewCell:
                    edVC.event = EventRequest.myOngoingEvents[(sender as! MyEventSnapshotTableViewCell).eventId!]
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
        joinDiscussion(eventId: eventId)
    }
    
    func joinDiscussion(eventId: String) {
        guard let event = EventRequest.myOngoingEvents[eventId] else { return }
        guard let conversationViewController = LCCKConversationViewController(conversationId: event.conversationId) else {
            self.displayInfo(info: "网络错误，无法进入评论区")
            return
        }
        conversationViewController.isEnableAutoJoin = true
        conversationViewController.hidesBottomBarWhenPushed = true
        conversationViewController.isDisableTitleAutoConfig = true
        conversationViewController.disablesAutomaticKeyboardDismissal = false
        conversationViewController.viewDidLoadBlock = {
            viewController in
            viewController?.navigationItem.title = event.name
            viewController?.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        }
        
        conversationViewController.viewDidAppearBlock = {
            (viewController, animated) in
            print("conversation controller view did appear")
            viewController?.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        }
        
        conversationViewController.viewWillDisappearBlock = {
            (viewController, animated) in
            print("conversation controller view will disappear")
            viewController?.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
            SVProgressHUD.dismiss()

            guard let conversation = conversationViewController.getConversationIfExists() else {
                print("cannot get conversation from conversation view controller")
                return
            }
            
            if !event.members.contains(AVUser.current()!) {
                conversation.quit {
                    succeeded, error in
                    if succeeded {
                        print("quit conversation successfully")
                    }
                    if error != nil {
                        print(error!)
                    }
                }
            }
            
            guard let conversationRecords = ConversationList.parseConversationRecords(), var conversationRecord = conversationRecords[conversation.conversationId!] else {
                print("unable to set conversation to read")
                return
            }
            conversationRecord.isUnread = false
            do {
                try ConversationList.addRecord(conversationId: conversation.conversationId!, record: conversationRecord)
            } catch let error {
                print("reset conversation to read failed: \(error)")
            }
        }
        
        self.navigationController?.pushViewController(conversationViewController, animated: true)
    }
    
    func deleteEvent(sender: UIButton) {
        deleteEvent(eventId: sender.accessibilityHint!)
    }
    
    func deleteEvent(eventId: String) {
        print("delete event cell starts")
        guard let section = sectionForEvent(eventId: eventId) else { return }
        let alertVC = UIAlertController(title: "请确认微活动已经完结，不再需要继续讨论。完结活动可以在活动历史中查看。", message: nil, preferredStyle: .actionSheet)
        let okay = UIAlertAction(title: "确认删除", style: .destructive) {
            _ in
            EventRequest.myOngoingEvents[eventId]?.close(for: AVUser.current()!) {
                succeeded, error in
                if succeeded {
                    EventRequest.removeEvent(with: eventId, for: .myongoing) {
                        print("about to delete finalized event")
                        if EventRequest.myOngoingEvents.count == 0 {
                            self.tableView.reloadData()
                        } else {
                            self.tableView.deleteSections(IndexSet([section]), with: .fade)
                        }
                    }
                }
                
                if error != nil {
                    self.displayInfo(info: error!.customDescription)
                }
            }
        }
        
        let cancel = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        alertVC.addAction(okay)
        alertVC.addAction(cancel)
        self.present(alertVC, animated: true, completion: nil)
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
                
                var isUnread = false
                var latestMessage = "点击查看"
                if let record = event.conversationRecord {
                    isUnread = record.isUnread
                    if record.latestMessage != nil {
                        latestMessage = record.latestMessage!
                    }
                }
                
                if isUnread {
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
                cell.latestMessageLabel.text = latestMessage
                cell.statusView.backgroundColor = event.statusColor
                cell.statusView.layer.masksToBounds = true
                cell.statusView.layer.cornerRadius = cell.statusView.frame.size.width / 2
                cell.statusViewColor = event.statusColor
                
                cell.eventId = event.objectId
                return cell

            } else {
                let cell = Bundle.main.loadNibNamed("MyEventSnapshotTableViewCell", owner: self, options: nil)?.first as! MyEventSnapshotTableViewCell
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
                
                var isUnread = false
                var latestMessage = "有一条新消息"
                if let record = event.conversationRecord {
                    isUnread = record.isUnread
                    if record.latestMessage != nil {
                        latestMessage = record.latestMessage!
                    }
                }
                if isUnread {
                    cell.ifReadView.layer.cornerRadius = 4
                    cell.ifReadView.backgroundColor = event.finalizedColor
                } else {
                    cell.ifReadView.layer.cornerRadius = 4
                    cell.ifReadView.layer.borderWidth = 2
                    cell.ifReadView.layer.borderColor = event.finalizedColor.cgColor
                    cell.ifReadView.backgroundColor = UIColor.clear
                }
                cell.ifReadViewColor = event.finalizedColor
                cell.latestMessageButton.setTitle(latestMessage, for: .normal)
                cell.latestMessageButton.accessibilityHint = event.objectId
                cell.latestMessageButton.addTarget(self, action: #selector(joinDiscussion(sender:)), for: .touchUpInside)
                
                switch event.status {
                case .isPending, .isSecured:
                    cell.moreButton.isHidden = true
                default:
                    cell.moreButton.isHidden = false
                }
                
                cell.moreButton.accessibilityHint = event.objectId
                cell.moreButton.addTarget(self, action: #selector(deleteEvent(sender:)), for: .touchUpInside)
                
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
                joinDiscussion(eventId: event.objectId!)
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
                    self.deleteEvent(eventId: finalizedCell.eventId!)
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
    
    var conversationRecord: ConversationRecord? {
        if let records = ConversationList.parseConversationRecords() {
            if let record = records[self.conversationId] {
                return record
            }
        }
        return nil
    }
}

extension MyEventListViewController: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if self.refreshController.isRefreshing {
            self.handleRefresh()
        }
    }
}
