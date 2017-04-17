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
    
    var numberOfNewMessages: Int = 0 {
        didSet {
            self.tabBarController?.tabBar.items![USCFunConstants.indexOfMyEventList].badgeValue = numberOfNewMessages > 0 ? "\(numberOfNewMessages)" : nil
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
        NotificationCenter.default.addObserver(self, selector: #selector(handlerNewMessage(notification:)), name: NSNotification.Name(rawValue: LCCKNotificationMessageReceived), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handlerReadNewMessage), name: NSNotification.Name(rawValue: "userReadMessage"), object: nil)

        view.addSubview(infoLabel)
        self.navigationController?.navigationBar.isTranslucent = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.tableView.reloadData()
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
        print("tabbed")
    }
    
    func handleTabRefresh() {
        self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
    }
    
    func handlePostNewEvent() {
        self.tabBarController?.selectedIndex = USCFunConstants.indexOfMyEventList
        EventRequest.fetchNewerMyOngoingEventsInBackground {
            succeeded, numberOfNewEvents, error in
            if succeeded {
                print("successfully fetched \(numberOfNewEvents) new events")
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
    
    func handlerReadNewMessage() {
        self.numberOfNewMessages -= 1
        self.tableView.reloadData()
    }
    
    func handlerNewMessage(notification: Notification) {
        guard let object = notification.object as? [String: Any], let conversation = object["conversation"] as? AVIMConversation else {
            print("failed to parse message received notification")
            return
        }
        if let eventId = eventIdForConversationId(conversationId: conversation.conversationId!) {
            EventRequest.setEvent(event: EventRequest.myOngoingEvents[eventId]!, with: eventId, for: .myongoing) {
                self.tableView.reloadData()
            }
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
                    
                    EventRequest.setEvent(event: event, with: event.objectId!, for: .myongoing) {
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }
    
    func handleRefresh() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        EventRequest.fetchNewerMyOngoingEventsInBackground() {
            succeeded, numberOfNewEvents, error in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            if succeeded {
                print("successfully fetch \(numberOfNewEvents) new my ongoing events")
                if numberOfNewEvents > 0 {
                    self.displayInfo(info: "\(numberOfNewEvents) 个新微活动")
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
    
    func eventIdForConversationId(conversationId: String) -> String? {
        for eventId in EventRequest.myOngoingEvents.keys {
            let event = EventRequest.myOngoingEvents[eventId]!
            if event.conversationId == conversationId {
                return eventId
            }
        }
        return nil
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
        }
        
        conversationViewController.configureBarButtonItemStyle(.more) {
            viewController, buttonItem, uievent in
            let conversationMoreVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: USCFunConstants.storyboardIndetifierOfConversationMoreViewController) as! ConversationMoreViewController
            conversationMoreVC.event = event
            viewController?.navigationController?.pushViewController(conversationMoreVC, animated: true)
        }
        
        self.navigationController?.pushViewController(conversationViewController, animated: true)
    }
    
    func deleteEvent(sender: UIButton) {
        deleteEvent(eventId: sender.accessibilityHint!)
    }
    
    func deleteEventDecided(eventId: String) {
        print("delete event cell starts")
        guard let event = EventRequest.myOngoingEvents[eventId] else {
            print("failed to delete event cell: cannot find event")
            return
        }
        guard let section = sectionForEvent(eventId: eventId) else {
            print("failed to delete event cell: cannot find section")
            return
        }
        EventRequest.myOngoingEvents[eventId]?.close(for: AVUser.current()!) {
            succeeded, error in
            if succeeded {
                EventRequest.removeEvent(with: eventId, for: .myongoing) {
                    if EventRequest.myOngoingEvents.count == 0 {
                        self.tableView.reloadData()
                    } else {
                        self.tableView.deleteSections(IndexSet([section]), with: .fade)
                    }
                    
                    /// quit user from conversation
                    LCChatKit.sharedInstance().conversationService.fetchConversation(withConversationId: event.conversationId) {
                        conversation, error in
                        guard let conversation = conversation else {
                            if error != nil {
                                print("failed to fetch conversation \(error!)")
                            }
                            return
                        }
                        conversation.quit {
                            succeeded, error in
                            if succeeded {
                                print("quit conversation successfully after close event")
                            }
                            if error != nil {
                                print("failed to quit conversation after close event \(error!)")
                            }
                        }
                    }

                    /// let user rate event for finalized event
                    if event.status == .isFinalized {
                        guard let rateEventNavVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: USCFunConstants.storyboardIdentiferOfRateEventNavigationViewController) as? UINavigationController, let rateVC = rateEventNavVC.contentViewController as? RateEventViewController else {
                            return
                        }
                        rateVC.event = event
                        self.present(rateEventNavVC, animated: true, completion: nil)
                    }
                }
            }
            
            if error != nil {
                self.displayInfo(info: error!.customDescription)
            }
        }
        print("delete event cell ends")
    }
    
    func deleteEvent(eventId: String) {
        guard let event = EventRequest.myOngoingEvents[eventId] else { return }
        
        if !UserDefaults.hasWarnedAboutDeletingFinalizedEvent && event.status == .isFinalized {
            UserDefaults.hasWarnedAboutDeletingFinalizedEvent = true
            let alertVC = UIAlertController(title: "请确认微活动已经完结，不再需要继续讨论。完结活动可以在活动历史中查看。",
                                            message: nil,
                                            preferredStyle: .actionSheet)
            let okay = UIAlertAction(title: "确认删除", style: .destructive) {
                _ in
                self.deleteEventDecided(eventId: eventId)
            }
            
            let cancel = UIAlertAction(title: "取消", style: .cancel, handler: nil)
            alertVC.addAction(okay)
            alertVC.addAction(cancel)
            self.present(alertVC, animated: true, completion: nil)
        } else {
            deleteEventDecided(eventId: eventId)
        }
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
        if indexPath.section == self.numberOfSection - 1 && EventRequest.thereIsUnfetchedOldMyOngoingEvents && UserDefaults.hasPreloadedMyOngoingEvents {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            EventRequest.fetchOlderMyOngoingEventsInBackground {
                succeeded, numberOfNewEvents, error in
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                if succeeded {
                    print("successfully fetch \(numberOfNewEvents) old events")
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
                
                let isUnread = false
                let latestMessage = "点击查看"
                
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
                cell.eventNameLabel.numberOfLines = 1
                cell.latestMessageLabel.text = latestMessage
                cell.statusView.backgroundColor = event.statusColor
                cell.statusView.layer.masksToBounds = true
                cell.statusView.layer.cornerRadius = cell.statusView.frame.size.width / 2
                cell.statusViewColor = event.statusColor
                
                cell.eventId = event.objectId
                return cell

            } else {
                let cell = Bundle.main.loadNibNamed("MyEventSnapshotTableViewCell", owner: self, options: nil)?.first as! MyEventSnapshotTableViewCell
                cell.eventNameLabel.numberOfLines = 2
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
                
                let isUnread = false
                let latestMessage = "点击查看"
                
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
                
                switch event.status {
                case .isCancelled:
                    cell.sealImageView.image = #imageLiteral(resourceName: "cancelledSeal")
                case .isFailed:
                    cell.sealImageView.image = #imageLiteral(resourceName: "failedSeal")
                default:
                    cell.sealImageView.isHidden = true
                }
                
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
        if section == self.numberOfSection - 1 {
            return 20
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
        if section == self.numberOfSection - 1 {
            
            var status = ""
            if EventRequest.thereIsUnfetchedOldMyOngoingEvents {
                status = "正在加载···"
            } else {
                status = "已经是最后一个微活动"
            }
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: self.tableView.frame.size.width, height: 20))
            label.text = status
            label.textAlignment = .center
            label.textColor = UIColor.lightGray
            label.font = UIFont.systemFont(ofSize: 13)
            return label
        } else {
            let px = 1 / UIScreen.main.scale
            let footerView = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.frame.size.width, height: 10 + px))
            let frame = CGRect(x: 0, y: 0, width: self.tableView.frame.size.width, height: px)
            let line = UIView(frame: frame)
            line.backgroundColor = self.tableView.separatorColor
            footerView.addSubview(line)
            return footerView
        }
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
            
            let delete = UITableViewRowAction(style: .default, title: "删除") {
                action, index in
                if let finalizedCell = tableView.cellForRow(at: indexPath) as? FinalizedEventSnapshotTableViewCell {
                    self.deleteEvent(eventId: finalizedCell.eventId!)
                }
            }
            return [delete]
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
            return USCFunConstants.conversationColorOptions[abs(index) % USCFunConstants.conversationColorOptions.count]
        }
        return USCFunConstants.conversationColorOptions[0]
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
}

extension MyEventListViewController: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if self.refreshController.isRefreshing {
            self.handleRefresh()
        }
    }
}

extension AVIMMessage {
    var shortDescription: String {
        guard let message = self as? AVIMTypedMessage else {
            return ""
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
        return text
    }
}
