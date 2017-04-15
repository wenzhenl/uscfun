//
//  EventListViewController.swift
//  uscfun
//
//  Created by Wenzheng Li on 9/3/16.
//  Copyright © 2016 Wenzheng Li. All rights reserved.
//

import UIKit
import SVProgressHUD
import ChatKit
import SCLAlertView

class EventListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var preloadDataSucceeded = true

    var numberOfSection: Int {
        if UserDefaults.hasPreloadedPublicEvents {
            return EventRequest.publicEvents.count + 1
        } else {
            return 1
        }
    }
    
    var emptyPlaceholder: String {
        if UserDefaults.hasPreloadedPublicEvents {
            if !preloadDataSucceeded {
                return "加载失败，请重新加载"
            }
            else if EventRequest.publicEvents.count == 0 {
                return "好像微活动都被参加完了，少年快去发起一波吧！"
            } else {
                return ""
            }
        } else {
            return "正在加载数据，请稍后..."
        }
    }
    
    var numberOfNewEvents: Int = 0 {
        didSet {
            self.tabBarController?.tabBar.items![USCFunConstants.indexOfEventList].badgeValue = numberOfNewEvents > 0 ? "\(numberOfNewEvents)" : nil
        }
    }
    
    var isRefreshAnimating = false
    var customRefreshView: UIView = UIView()
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = UIColor.clear
        refreshControl.backgroundColor = UIColor.clear
        self.customRefreshView = (Bundle.main.loadNibNamed("RefreshView", owner: self, options: nil)?.first as? UIView)!
        self.customRefreshView.frame = refreshControl.bounds
        self.customRefreshView.backgroundColor = UIColor.clear
        let customImageView = self.customRefreshView.viewWithTag(1) as! UIImageView
        
        self.isRefreshAnimating = false
        
        refreshControl.addSubview(self.customRefreshView)
        return refreshControl
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
        
        print("EventList view did load")

        self.navigationController?.view.backgroundColor = UIColor.white
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        self.tableView.scrollsToTop = true
        self.tableView.addSubview(self.refreshControl)
     
        self.tableView.tableFooterView = UIView()
        self.tableView.backgroundColor = UIColor.backgroundGray
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleApplicationDidBecomesActive), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handlePreload(notification:)), name: NSNotification.Name(rawValue: "finishedPreloadingPublicEvents"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleTab), name: NSNotification.Name(rawValue: "tabBarItemSelected"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleTabRefresh), name: NSNotification.Name(rawValue: "findRefresh"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleJoinEvent), name: NSNotification.Name(rawValue: "userDidJoinEvent"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleQuitEvent), name: NSNotification.Name(rawValue: "userDidQuitEvent"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleEventExpired(notification:)), name: NSNotification.Name(rawValue: "eventDidExpired"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleNewEventAvailable(notification:)), name: NSNotification.Name(rawValue: "newEventAvailable"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleUpdatedEventAvailable(notification:)), name: NSNotification.Name(rawValue: "updatedEventAvailable"), object: nil)

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
        
        if UserDefaults.shouldRemindUpdateNewVersion {
            UserDefaults.lastUpdateNewVersionRemindedAt = Date()
            let appearance = SCLAlertView.SCLAppearance(showCloseButton: false)
            let alertView = SCLAlertView(appearance: appearance)
            alertView.addButton("立即更新") {
                UIApplication.shared.openURL(URL(string : USCFunConstants.appURL)!)
            }
            alertView.addButton("暂时不要") {
                print("remind update new app version ignored")
            }
            alertView.showInfo("有新版本啦！", subTitle: UserDefaults.newVersionDescription ?? "")
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func handleApplicationDidBecomesActive() {
        print("handle application did becomes active")
        self.tableView.reloadData()
    }
    
    func handlePreload(notification: Notification) {
        guard let info = notification.userInfo as? [String: Bool], let succeeded = info["succeeded"] else {
            print("cannot parse preload public events notification")
            return
        }
        print("public preload notification received:\(succeeded)")
        preloadDataSucceeded = succeeded
        self.tableView.reloadData()
        preloadDataSucceeded = true
    }
    
    func handleTab() {
        print("event list tabbed")
    }
    
    func handleTabRefresh() {
        self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
    }
    
    func handleJoinEvent() {
        self.tableView.reloadData()
    }
    
    func handleQuitEvent() {
        self.tableView.reloadData()
    }
    
    func handleEventExpired(notification: Notification) {
        self.tableView.reloadData()
    }
    
    func handleNewEventAvailable(notification: Notification) {
        guard let info = notification.userInfo as? [String: String], let eventId = info["eventId"] else {
            print("cannot parse UpdatedEventAvailable notification")
            return
        }
        EventRequest.fetchEvent(with: eventId) {
            error, event in
            if let event = event {
                if event.createdBy != AVUser.current()! {
                    self.numberOfNewEvents += 1
                }
            }
        }
    }
    
    func handleUpdatedEventAvailable(notification: Notification) {
        guard let info = notification.userInfo as? [String: String], let eventId = info["eventId"] else {
            print("cannot parse UpdatedEventAvailable notification")
            return
        }
        if EventRequest.publicEvents.keys.contains(eventId) {
            EventRequest.fetchEvent(with: eventId) {
                error, event in
                if let event = event {
                    EventRequest.setEvent(event: event, with: event.objectId!, for: .mypublic) {
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }
    
    func handleRefresh() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        EventRequest.fetchNewerPublicEventsInBackground() {
            succeeded, numberOfNewEvents, error in
            if succeeded {
                print("successfully fetched \(numberOfNewEvents) new events")
                if numberOfNewEvents > 0 {
                    self.displayInfo(info: "\(numberOfNewEvents) 个新的微活动")
                }
                self.refreshControl.endRefreshing()
                self.tableView.reloadData()
                self.numberOfNewEvents = 0
            }
            else if error != nil {
                self.refreshControl.endRefreshing()
                self.displayInfo(info: error!.localizedDescription)
            }
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
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
        guard let eventIndex = EventRequest.publicEvents.keys.index(of: eventId) else { return nil }
        return eventIndex + 1
    }
    
    func eventForSection(section: Int) -> Event {
        return EventRequest.publicEvents[EventRequest.publicEvents.keys[section - 1]]!
    }
    
    let identifierToEventDetail = "go to event detail"
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
            case identifierToEventDetail:
                let destination = segue.destination.contentViewController
                if let edVC = destination as? EventDetailViewController {
                    switch sender {
                    case is EventSnapshotTableViewCell:
                        edVC.event = EventRequest.publicEvents[(sender as! EventSnapshotTableViewCell).eventId!]
                    default:
                        break
                    }
                }
            default:
                break
            }
        }
    }
    
    func joinDiscussion(sender: UIButton) {
        guard let eventId = sender.accessibilityHint else { return }
        guard let event = EventRequest.publicEvents[eventId] else { return }
        guard let conversationViewController = LCCKConversationViewController(conversationId: event.conversationId) else {
            self.displayInfo(info: "网络错误，无法进入评论区")
            return
        }
        
        if !event.members.contains(AVUser.current()!) {
            LeanEngine.joinConversation(clientId: AVUser.current()!.username!, conversationId: event.conversationId) {
                succeeded, error in
                if succeeded {
                    print("join conversation before enter successfully")
                }
                if error != nil {
                    print("failed to join conversation before enter \(error!)")
                }
            }
        }
        
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

            if !event.members.contains(AVUser.current()!) {
                LeanEngine.quitConversation(clientId: AVUser.current()!.username!, conversationId: event.conversationId) {
                    succeeded, error in
                    if succeeded {
                        print("quit conversation after exit successfully")
                    }
                    if error != nil {
                        print("failed to quit conversation after exit \(error!)")
                    }
                }
            }
        }
        
        self.navigationController?.pushViewController(conversationViewController, animated: true)
    }
    
    func deleteEvent(sender: UIButton) {
        guard let eventId = sender.accessibilityHint else {
            print("sender doesn't provide event id")
            return
        }
        guard let section = sectionForEvent(eventId: eventId) else {
            print("cannot locate event id section")
            return
        }
        
        print("delete public event cell starts")
        EventRequest.removeEvent(with: eventId, for: .mypublic) {
            print("about to delete invalid public event")
            if EventRequest.publicEvents.count == 0 {
                self.tableView.reloadData()
            } else {
                self.tableView.deleteSections(IndexSet([section]), with: .fade)
            }
            print("delete public event cell ends")
        }
    }
}

extension EventListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.numberOfSection
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if EventRequest.publicEvents.count == 0 {
            return self.tableView.frame.height - 44.0
        }
        
        if EventRequest.publicEvents.count > 0 && indexPath.section == 0 {
            return 30
        }
        
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if EventRequest.publicEvents.count == 0 {
            return 600
        }
        
        if indexPath.section == 0 {
            return 44
        }
        
        return 270
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if EventRequest.publicEvents.count == 0 {
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
            let cell = Bundle.main.loadNibNamed("EventSnapshotTableViewCell", owner: self, options: nil)?.first as! EventSnapshotTableViewCell
            let creator = User(user: event.createdBy)!
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
            
            switch event.status {
            case .isPending, .isSecured:
                cell.moreButton.isHidden = true
            default:
                cell.moreButton.isHidden = false
            }
            cell.moreButton.accessibilityHint = event.objectId!
            cell.moreButton.addTarget(self, action: #selector(deleteEvent(sender:)), for: .touchUpInside)
            
            cell.eventId = event.objectId
            
            cell.due = event.due
            
            switch event.status {
            case .isCancelled:
                cell.sealImageView.image = #imageLiteral(resourceName: "cancelledSeal")
            case .isFailed:
                cell.sealImageView.image = #imageLiteral(resourceName: "failedSeal")
            case .isFinalized:
                cell.sealImageView.image = #imageLiteral(resourceName: "finalizedSeal")
            default:
                cell.sealImageView.isHidden = true
            }
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if EventRequest.publicEvents.count == 0 {
            return CGFloat.leastNormalMagnitude
        }
        return 1 / UIScreen.main.scale
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if EventRequest.publicEvents.count == 0 {
            return CGFloat.leastNormalMagnitude
        }
        if section == self.numberOfSection - 1 {
            return 20
        }
        return 10
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = UIColor.white
        if indexPath.section == self.numberOfSection - 1 && EventRequest.thereIsUnfetchedPublicEvents && UserDefaults.hasPreloadedPublicEvents {
            print("about to fetch older data")
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            EventRequest.fetchOlderPublicEventsInBackground {
                succeeded, numberOfNewEvents, error in
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                if succeeded {
                    print("successfully fetch \(numberOfNewEvents) old events")
                    self.tableView.reloadData()
                }
                if error != nil {
                    print("failed to fetch older data: \(error!)")
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        view.tintColor = UIColor.clear
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == self.numberOfSection - 1 {
            
            var status = ""
            if EventRequest.thereIsUnfetchedPublicEvents {
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
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if EventRequest.publicEvents.count > 0 && indexPath.section > 0 {
            performSegue(withIdentifier: identifierToEventDetail, sender: tableView.cellForRow(at: indexPath))
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension EventListViewController: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if self.refreshControl.isRefreshing {
            (self.customRefreshView.viewWithTag(2) as! UILabel).text = "正在拼命加载中..."
            self.handleRefresh()
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if self.refreshControl.isRefreshing && !self.isRefreshAnimating {
            animateRefreshView()
        }
    }
    
    func animateRefreshView() {
        if !self.isRefreshAnimating {
            (self.customRefreshView.viewWithTag(2) as! UILabel).text = "可以松手了"
        }
        self.isRefreshAnimating = true
        UIView.animateKeyframes(withDuration: 0.8, delay: 0.0, options: .calculationModeCubic, animations: {
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 1/4, animations: {
                self.customRefreshView.viewWithTag(1)?.transform = (self.customRefreshView.viewWithTag(1)?.transform.rotated(by: CGFloat(M_PI_4)))!
                self.customRefreshView.backgroundColor = UIColor.buttonPink
            })
            UIView.addKeyframe(withRelativeStartTime: 1/4, relativeDuration: 1/4, animations: {
                self.customRefreshView.viewWithTag(1)?.transform = (self.customRefreshView.viewWithTag(1)?.transform.rotated(by: -CGFloat(M_PI_4)))!
                self.customRefreshView.backgroundColor = UIColor.buttonBlue
            })
            UIView.addKeyframe(withRelativeStartTime: 2/4, relativeDuration: 1/4, animations: {
                self.customRefreshView.viewWithTag(1)?.transform = (self.customRefreshView.viewWithTag(1)?.transform.rotated(by: -CGFloat(M_PI_4)))!
                self.customRefreshView.backgroundColor = UIColor.buttonPink
            })
            UIView.addKeyframe(withRelativeStartTime: 3/4, relativeDuration: 1/4, animations: {
                self.customRefreshView.viewWithTag(1)?.transform = (self.customRefreshView.viewWithTag(1)?.transform.rotated(by: CGFloat(M_PI_4)))!
                self.customRefreshView.backgroundColor = UIColor.buttonBlue
            })
        }, completion: {
            finished in
            if self.refreshControl.isRefreshing {
                self.animateRefreshView()
            } else {
                self.resetAnimation()
            }
        })
    }
    
    func resetAnimation() {
        (self.customRefreshView.viewWithTag(2) as! UILabel).text = "看见浮夸后松手"
        self.customRefreshView.backgroundColor = UIColor.clear
        self.customRefreshView.viewWithTag(1)?.transform = .identity
        self.isRefreshAnimating = false
    }
}

