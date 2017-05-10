//
//  EventDetailViewController.swift
//  uscfun
//
//  Created by Wenzheng Li on 9/3/16.
//  Copyright © 2016 Wenzheng Li. All rights reserved.
//

import UIKit
import ChatKit
import SVProgressHUD
import SCLAlertView

enum EventDetailCell {
    case statusCell
    case titleCell
    case creatorCell
    case remainingNumberCell
    case numberCell
    case memberCell
    case remainingTimeCell
    case startTimeCell
    case endTimeCell
    case locationCell
    case mapCell
    case noteCell
}

enum ExitAfter: String {
    case none = "none"
    case join = "join"
    case quit = "quit"
}

class EventDetailViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var joinButton: UIButton!
    @IBOutlet weak var chatButton: UIButton!
    
    var event: Event!
    var creator: User!
    var memberAvatars = [UIImage]()
    
    var detailSections = [EventDetailCell]()
    
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
    
    var exitAfter = ExitAfter.none
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.view.backgroundColor = UIColor.white
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 50, 0)
        self.tableView.tableFooterView = UIView()
        self.joinButton.backgroundColor = UIColor.buttonPink
        self.chatButton.backgroundColor = UIColor.buttonBlue
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateRemainingTime), name: NSNotification.Name(rawValue: "needToUpdateRemainingTime"), object: nil)
        
        creator = User(user: event.createdBy)
        
        setupButtons()
        populateSections()
        
        view.addSubview(infoLabel)
        self.navigationController?.navigationBar.isTranslucent = false
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        infoLabel.isHidden = true
        infoLabel.frame.origin = CGPoint.zero
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "eventDetailViewControllerDidDisappear"), object: nil, userInfo: ["exitAfter": self.exitAfter])
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func updateRemainingTime() {
        guard let timeCellIndex = detailSections.index(of: .remainingTimeCell) else { return }
        self.tableView.reloadSections(IndexSet([timeCellIndex]), with: .automatic)
    }
    
    func setupButtons() {
        switch event.relationWithMe {
        case .createdByMe:
            joinButton.setTitle("修改微活动", for: .normal)
            joinButton.backgroundColor = UIColor.avatarTomato
            joinButton.setTitleColor(UIColor.white, for: .normal)
        case .joinedByMe:
            joinButton.setTitle("已经参加", for: .normal)
            joinButton.backgroundColor = UIColor.lightGray
            joinButton.setTitleColor(UIColor.darkGray, for: .normal)
        case .noneOfMyBusiness:
            joinButton.setTitle("报名参加", for: .normal)
            joinButton.backgroundColor = UIColor.buttonPink
            joinButton.setTitleColor(UIColor.white, for: .normal)
        }
        
        if event.relationWithMe == .noneOfMyBusiness {
            switch event.status {
            case .isSecured, .isPending:
                joinButton.isHidden = false
                chatButton.isHidden = false
            default:
                joinButton.isHidden = true
                chatButton.isHidden = true
            }
        }
    }
    
    func populateSections() {
        memberAvatars.removeAll()
        memberAvatars.append(creator.avatar ?? #imageLiteral(resourceName: "user-4"))
        for memberData in event.members {
            if memberData != event.createdBy {
                if let member = User(user: memberData) {
                    memberAvatars.append(member.avatar ?? #imageLiteral(resourceName: "user-4"))
                }
            }
        }
        detailSections.removeAll()
        detailSections.append(EventDetailCell.statusCell)
        detailSections.append(EventDetailCell.titleCell)
        detailSections.append(EventDetailCell.creatorCell)
        detailSections.append(EventDetailCell.remainingNumberCell)
        detailSections.append(EventDetailCell.numberCell)
        if event.members.count > 1 {
            detailSections.append(EventDetailCell.memberCell)
        }
        detailSections.append(EventDetailCell.remainingTimeCell)
        if event.startTime != nil {
            detailSections.append(EventDetailCell.startTimeCell)
        }
        if event.endTime != nil {
            detailSections.append(EventDetailCell.endTimeCell)
        }
        if event.location != nil {
            detailSections.append(EventDetailCell.locationCell)
        }
        if event.note != nil {
            detailSections.append(EventDetailCell.noteCell)
        }
        if event.whereCreated != nil {
            detailSections.append(EventDetailCell.mapCell)
        }
    }
    
    @IBAction func updateEvent(_ sender: UIButton) {
        switch event.relationWithMe {
        case .createdByMe:
            performSegue(withIdentifier: editEventSegueIdentifier, sender: self)
        case .joinedByMe:
            quitRequest()
        case .noneOfMyBusiness:
            joinEvent()
        }
    }
    
    @IBAction func joinDiscussion(_ sender: UIButton) {
        guard let conversationViewController = LCCKConversationViewController(conversationId: event.conversationId) else {
            self.displayInfo(info: "网络错误，无法进入评论区")
            return
        }
        
        conversationViewController.isEnableAutoJoin = true
        conversationViewController.hidesBottomBarWhenPushed = true
        conversationViewController.isDisableTitleAutoConfig = true
        conversationViewController.viewDidLoadBlock = {
            viewController in
            viewController?.navigationItem.title = self.event.name
            viewController?.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        }
        
        conversationViewController.viewDidAppearBlock = {
            (viewController, animated) in
            print("conversation controller view did appear")
            viewController?.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        }
        
        conversationViewController.viewWillDisappearBlock = {
            [unowned self](viewController, animated) in
            print("conversation controller view will disappear")
            viewController?.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
            SVProgressHUD.dismiss()
            if !self.event.members.contains(AVUser.current()!) {
                LCChatKit.sharedInstance().conversationService.fetchConversation(withConversationId: self.event.conversationId) {
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
                            print("quit conversation successfully after exit")
                        }
                        if error != nil {
                            print("failed to quit conversation \(error!)")
                        }
                    }
                }
            } else {
                /// notify my event list to update if needed
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "userReturnedFromConversation"), object: nil, userInfo: ["conversationId": self.event.conversationId])
            }
        }
        
        if event.members.contains(AVUser.current()!) {
            conversationViewController.configureBarButtonItemStyle(.more) {
                viewController, buttonItem, uievent in
                let conversationMoreVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: USCFunConstants.storyboardIndetifierOfConversationMoreViewController) as! ConversationMoreViewController
                conversationMoreVC.event = self.event
                viewController?.navigationController?.pushViewController(conversationMoreVC, animated: true)
            }
        }
        
        self.navigationController?.pushViewController(conversationViewController, animated: true)
    }
    
    func joinEventDecided() {
        
        SVProgressHUD.show()
        self.event.add(newMember: AVUser.current()!) {
            succeeded, error in
            SVProgressHUD.dismiss()
            if succeeded {
                /// subscribe event push notification
                let current = AVInstallation.current()
                current.addUniqueObject(self.event.objectId!, forKey: InstallationKeyConstants.keyOfChannels)
                current.saveInBackground()
                let push = AVPush()
                push.setChannel(self.event.objectId!)
                push.setMessage(UserDefaults.nickname! + "加入了你的微活动:" + self.event.name)
                push.sendInBackground()
                
                /// join event conversation
                LCChatKit.sharedInstance().conversationService.fetchConversation(withConversationId: self.event.conversationId) {
                    conversation, error in
                    guard let conversation = conversation else {
                        if error != nil {
                            print("failed to fetch conversation \(error!)")
                        }
                        return
                    }
                    conversation.join {
                        succeeded, error in
                        if succeeded {
                            print("join conversation successfully after join event")
                        }
                        if error != nil {
                            print("failed to join conversation after join event \(error!)")
                        }
                    }
                }
                
                let joinEventGroup = DispatchGroup()
                joinEventGroup.enter()
                EventRequest.setEvent(event: self.event, with: self.event.objectId!, for: .myongoing, handler: nil)
                joinEventGroup.leave()
                
                joinEventGroup.enter()
                EventRequest.removeEvent(with: self.event.objectId!, for: .mypublic, handler: nil)
                joinEventGroup.leave()
                
                joinEventGroup.notify(queue: DispatchQueue.main) {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "userDidJoinEvent"), object: nil, userInfo: ["eventId": self.event.objectId!])
                    self.exitAfter = .join
                    self.navigationController?.tabBarController?.selectedIndex = USCFunConstants.indexOfMyEventList
                    _ = self.navigationController?.popViewController(animated: true)
                }
            }
            else if error != nil {
                self.displayInfo(info: error!.customDescription)
            }
        }
    }
    
    func joinEvent() {
        
        guard event.remainingSeats > 0 else {
            self.displayInfo(info: "已经没有位子了")
            return
        }
        
        if !UserDefaults.hasRemindedUserBeSeriousAboutJoining {
            let appearance = SCLAlertView.SCLAppearance(showCloseButton: false)
            let alertView = SCLAlertView(appearance: appearance)
            alertView.addButton("确定参加") {
                UserDefaults.hasRemindedUserBeSeriousAboutJoining = true
                self.joinEventDecided()
            }
            alertView.addButton("手滑了") {
                print("user decide not to join after reminder")
            }
            alertView.showWarning("参与须知", subTitle: "欢迎参加微活动！请确定你的确有时间完成该活动，活动约定成功前你可以选择退出。约定成功后如果有事无法参加，请及时与队友沟通，无故爽约将会影响到你的信誉等级！")
        } else {
            joinEventDecided()
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
    
    func quitRequest() {
        
        let alertViewController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let quit = UIAlertAction(title: "退出微活动", style: .destructive) {
            _ in
            SVProgressHUD.show()
            self.event.remove(member: AVUser.current()!) {
                succeeded, error in
                SVProgressHUD.dismiss()
                if succeeded {
                    
                    /// unsubscribe event push notification
                    let current = AVInstallation.current()
                    current.remove(self.event.objectId!, forKey: InstallationKeyConstants.keyOfChannels)
                    current.saveInBackground()
                    let push = AVPush()
                    push.setChannel(self.event.objectId!)
                    push.setMessage(UserDefaults.nickname! + "退出了你的微活动:" + self.event.name)
                    push.sendInBackground()
                    
                    /// quit event conversation
                    LCChatKit.sharedInstance().conversationService.fetchConversation(withConversationId: self.event.conversationId) {
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
                                print("quit conversation successfully after quit event")
                            }
                            if error != nil {
                                print("failed to quit conversation after quit event \(error!)")
                            }
                        }
                    }
                    
                    let quitEventGroup = DispatchGroup()
                    quitEventGroup.enter()
                    EventRequest.setEvent(event: self.event, with: self.event.objectId!, for: .mypublic) {
                        quitEventGroup.leave()
                    }
                    
                    quitEventGroup.enter()
                    EventRequest.removeEvent(with: self.event.objectId!, for: .myongoing) {
                        quitEventGroup.leave()
                    }
                    
                    quitEventGroup.notify(queue: DispatchQueue.main) {
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "userDidQuitEvent"), object: nil, userInfo: nil)
                        self.exitAfter = .quit
                        _ = self.navigationController?.popViewController(animated: true)
                    }
                }
                else if error != nil {
                    self.displayInfo(info: error!.customDescription)
                }
            }
        }
        let cancel = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        alertViewController.addAction(quit)
        alertViewController.addAction(cancel)
        self.present(alertViewController, animated: true, completion: nil)
    }
    
    var snapshot: UIImage? {
        self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        return self.tableView.screenshot
    }
    
    @IBAction func takeActions(_ sender: UIBarButtonItem) {
        let alertViewController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let shareToFriend = UIAlertAction(title: "分享给微信好友", style: .default) {
            _ in
            let message = WXMediaMessage()
            switch self.event!.relationWithMe {
            case .createdByMe:
                message.title = "我正在usc日常上发起微活动：" + self.event!.name
            case .joinedByMe:
                message.title = "我正在usc日常上参加微活动：" + self.event!.name
            case .noneOfMyBusiness:
                message.title = "我推荐usc日常上微活动：" + self.event!.name
            }
            
            let ext = WXWebpageObject()
            ext.webpageUrl = USCFunConstants.shareEventURL + self.event!.objectId!
            message.mediaObject = ext
            message.description = "剩余席位:" + String(self.event.remainingSeats) + " 已经参加:" + String(self.event.maximumAttendingPeople - self.event.remainingSeats)
            message.setThumbImage(#imageLiteral(resourceName: "uscfun").scaleTo(width: 100, height: 100))
            
            let req = SendMessageToWXReq()
            req.bText = false
            req.message = message
            req.scene = Int32(WXSceneSession.rawValue)
            WXApi.send(req)
        }
        let shareToMoment = UIAlertAction(title: "分享到朋友圈", style: .default) {
            _ in
            let message = WXMediaMessage()
            switch self.event!.relationWithMe {
            case .createdByMe:
                message.title = "我正在usc日常上发起微活动：" + self.event!.name
            case .joinedByMe:
                message.title = "我正在usc日常上参加微活动：" + self.event!.name
            case .noneOfMyBusiness:
                message.title = "我推荐usc日常上微活动：" + self.event!.name
            }
            
            let ext = WXWebpageObject()
            ext.webpageUrl = USCFunConstants.shareEventURL + self.event!.objectId!
            message.mediaObject = ext
            message.description = "剩余席位:" + String(self.event.remainingSeats) + " 已经参加:" + String(self.event.maximumAttendingPeople - self.event.remainingSeats)
            message.setThumbImage(#imageLiteral(resourceName: "uscfun").scaleTo(width: 100, height: 100))

            let req = SendMessageToWXReq()
            req.bText = false
            req.message = message
            req.scene = Int32(WXSceneTimeline.rawValue)
            WXApi.send(req)
        }
        let cancel = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        alertViewController.addAction(shareToFriend)
        alertViewController.addAction(shareToMoment)
        alertViewController.addAction(cancel)
        self.present(alertViewController, animated: true, completion: nil)
    }
    
    func checkProfile(sender: UIButton) {
        performSegue(withIdentifier: userProfileSugueIdentifier, sender: sender)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let destination = segue.destination.contentViewController
        
        if let identifier = segue.identifier {
            switch identifier {
            case mapSegueIdentifier:
                if let mapVC = destination as? MapViewController {
                    mapVC.placename = event.location
                    mapVC.latitude = event.whereCreated?.latitude
                    mapVC.longitude = event.whereCreated?.longitude
                }
            case userProfileSugueIdentifier:
                if let upVC = destination as? UserProfileViewController {
                    switch sender {
                    case is UIButton:
                        upVC.user = event.members[(sender as! UIButton).tag]
                    case is EventCreatorTableViewCell:
                        upVC.user = event.createdBy
                    default:
                        break
                    }
                }
            case editEventSegueIdentifier:
                if let eeVC = destination as? EditEventViewController {
                    eeVC.event = event
                    eeVC.delegate = self
                }
            default:
                break
            }
        }
    }
    
    //--MARK: global constants
    let mapSegueIdentifier = "SHOWMAP"
    let userProfileSugueIdentifier = "see user profile"
    let editEventSegueIdentifier = "go to edit event"
}

extension EventDetailViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if detailSections[indexPath.section] == .mapCell {
            performSegue(withIdentifier: mapSegueIdentifier, sender: self)
        }
        
        if detailSections[indexPath.section] == .creatorCell {
            performSegue(withIdentifier: userProfileSugueIdentifier, sender: tableView.cellForRow(at: indexPath))
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return detailSections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if detailSections[indexPath.section] == .creatorCell {
            return 50
        }
        
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch detailSections[indexPath.section] {
        case .statusCell:
            let cell = Bundle.main.loadNibNamed("EventStatusBarTableViewCell", owner: self, options: nil)?.first as! EventStatusBarTableViewCell
            cell.statusView.backgroundColor = event.statusColor
            cell.statusLabel.text = event.status.description
            cell.selectionStyle = .none
            return cell
        case .titleCell:
            let cell = UITableViewCell()
            cell.textLabel?.textColor = UIColor.darkText
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 17)
            cell.textLabel?.textAlignment = .left
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.text = event.name
            cell.selectionStyle = .none
            return cell
        case .creatorCell:
            let cell = Bundle.main.loadNibNamed("EventCreatorTableViewCell", owner: self, options: nil)?.first as! EventCreatorTableViewCell
            cell.avatorImageView.image = creator.avatar
            cell.creatorLabel.text = creator.nickname
            cell.selectionStyle = .none
            return cell
        case .remainingNumberCell:
            let cell = Bundle.main.loadNibNamed("NumberDisplayTableViewCell", owner: self, options: nil)?.first as! NumberDisplayTableViewCell
            cell.numberLabel.text = String(event.remainingSeats)
            cell.whitePaperImageView.image = event.whitePaper
            cell.selectionStyle = .none
            return cell
        case .numberCell:
            let cell = Bundle.main.loadNibNamed("TandemLabelTableViewCell", owner: self, options: nil)?.first as! TandemLabelTableViewCell
            cell.leftLabel.text = "已经报名 " + String(event.maximumAttendingPeople - event.remainingSeats) + "人"
            cell.rightLabel.text = "最少成行 " + String(event.minimumAttendingPeople) + "人"
            cell.selectionStyle = .none
            return cell
        case .remainingTimeCell:
            let cell = Bundle.main.loadNibNamed("TitleContentTableViewCell", owner: self, options: nil)?.first as! TitleContentTableViewCell
            cell.titleLabel.text = "离报名截止还剩："
            let gapFromNow = event.due.gapFromNow
            if gapFromNow == "" {
                cell.contentLabel.textColor = UIColor.darkGray
                cell.contentLabel.text = "报名已经结束"
            } else {
                cell.contentLabel.text = gapFromNow
            }
            cell.selectionStyle = .none
            return cell
        case .startTimeCell:
            let cell = Bundle.main.loadNibNamed("TimeDisplayTableViewCell", owner: self, options: nil)?.first as! TimeDisplayTableViewCell
            cell.titleLabel.text = "微活动开始时间："
            cell.dateLabel.text = event.startTime!.readableDate
            cell.timeLabel.text = event.startTime!.readableTime
            cell.selectionStyle = .none
            return cell
        case .endTimeCell:
            let cell = Bundle.main.loadNibNamed("TimeDisplayTableViewCell", owner: self, options: nil)?.first as! TimeDisplayTableViewCell
            cell.titleLabel.text = "微活动结束时间："
            cell.dateLabel.text = event.endTime!.readableDate
            cell.timeLabel.text = event.endTime!.readableTime
            cell.selectionStyle = .none
            return cell
        case .locationCell:
            let cell = Bundle.main.loadNibNamed("TitleTextViewTableViewCell", owner: self, options: nil)?.first as! TitleTextViewTableViewCell
            cell.titleLabel.text = "微活动地点："
            cell.textView.text = event.location
            cell.textView.isEditable = false
            cell.textView.textColor = UIColor.darkText
            cell.textView.font = UIFont.boldSystemFont(ofSize: 17)
            cell.textView.textAlignment = .center
            cell.textView.dataDetectorTypes = [.address]
            cell.selectionStyle = .none
            return cell
        case .mapCell:
            let cell = Bundle.main.loadNibNamed("MapViewTableViewCell", owner: self, options: nil)?.first as! MapViewTableViewCell
            let location = CLLocationCoordinate2D(latitude: (event.whereCreated?.latitude)!, longitude: (event.whereCreated?.longitude)!)
            let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            let region = MKCoordinateRegion(center: location, span: span)
            cell.mapView.setRegion(region, animated: true)
            let annotation = MKPointAnnotation()
            annotation.coordinate = location
            annotation.title = event.location
            cell.mapView.addAnnotation(annotation)
            cell.mapView.isUserInteractionEnabled = false
            cell.selectionStyle = .none
            return cell
        case .noteCell:
            let cell = Bundle.main.loadNibNamed("TitleTextViewTableViewCell", owner: self, options: nil)?.first as! TitleTextViewTableViewCell
            cell.titleLabel.text = "补充说明："
            cell.textView.text = event.note
            cell.textView.delegate = self
            cell.selectionStyle = .none
            return cell
        case .memberCell:
            let cell = Bundle.main.loadNibNamed("KeyScrollViewTableViewCell", owner: self, options: nil)?.first as! KeyScrollViewTableViewCell
            let numberOfMysteriousMembers = event.maximumAttendingPeople - event.remainingSeats - memberAvatars.count
            var possibleLabelWidth = CGFloat(0)
            
            for i in 0..<memberAvatars.count {
                let buttonWidth = CGFloat(35.0)
                let margin = CGFloat(2.0)
                let xPosition = buttonWidth * CGFloat(i) + margin * CGFloat(i) + possibleLabelWidth
                let button = UIButton(frame: CGRect(x: xPosition, y: (70.0 - buttonWidth) * 0.5, width: buttonWidth, height: buttonWidth))
                button.setBackgroundImage(memberAvatars[i], for: .normal)
                button.layer.cornerRadius = buttonWidth / 2.0
                button.layer.masksToBounds = true
                button.contentMode = .scaleAspectFit
                button.tag = i
                button.addTarget(self, action: #selector(checkProfile(sender:)), for: .touchUpInside)
                cell.mainScrollView.contentSize.width = (buttonWidth + margin) * CGFloat(i+1) + possibleLabelWidth
                cell.mainScrollView.addSubview(button)
                
                if i == 0 && numberOfMysteriousMembers > 0 {
                    print("number of unseen members: \(numberOfMysteriousMembers)")
                    possibleLabelWidth = CGFloat(20.0)
                    let label = UILabel(frame: CGRect(x: xPosition + buttonWidth, y: (70.0 - buttonWidth) * 0.5, width: buttonWidth, height: buttonWidth))
                    label.textAlignment = .left
                    label.text = "+\(numberOfMysteriousMembers)"
                    label.textColor = UIColor.buttonPink
                    label.font = UIFont.boldSystemFont(ofSize: 13)
                    cell.mainScrollView.contentSize.width += possibleLabelWidth
                    cell.mainScrollView.addSubview(label)
                }
            }
            cell.selectionStyle = .none
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if detailSections[section] == .remainingNumberCell {
            return 1 / UIScreen.main.scale
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let px = 1 / UIScreen.main.scale
        let frame = CGRect(x: 0, y: 0, width: self.tableView.frame.size.width, height: px)
        let line = UIView(frame: frame)
        line.backgroundColor = self.tableView.separatorColor
        return line
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if detailSections[section] == .titleCell {
            return 10
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        view.tintColor = UIColor.clear
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.frame.size.width, height: 10))
        footerView.backgroundColor = UIColor.backgroundGray
        return footerView
    }
}

extension EventDetailViewController: EditEventViewControllerDelegate {
    func userDidUpdatedEvent(event: Event) {
        self.event = event
        self.setupButtons()
        self.populateSections()
        self.tableView.reloadData()
    }
}

extension EventDetailViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        if URL.scheme == "http" || URL.scheme == "https" {
            if let webVC = UIStoryboard(name: "Login", bundle: nil).instantiateViewController(withIdentifier: USCFunConstants.storyboardIdentifierOfWebViewController) as? WebViewController {
                webVC.url = URL
                self.navigationController?.pushViewController(webVC, animated: true)
            }
            return false
        }
        return true
    }
}
