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
    
    var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.view.backgroundColor = UIColor.white
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 50, 0)
        self.tableView.tableFooterView = UIView()
        self.joinButton.backgroundColor = UIColor.buttonPink
        self.chatButton.backgroundColor = UIColor.buttonBlue
        
        creator = User(user: event.createdBy)
        
        setupJoinButton()
        populateSections()
        
        view.addSubview(infoLabel)
        self.navigationController?.navigationBar.isTranslucent = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if timer == nil && event.due > Date() {
            timer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(updateRemainingTime), userInfo: nil, repeats: true)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        infoLabel.isHidden = true
        infoLabel.frame.origin = CGPoint.zero
        timer?.invalidate()
        timer = nil
    }
    
    func updateRemainingTime() {
        
        if event.due < Date() {
            timer?.invalidate()
            timer = nil
        }
        
        guard let timeCellIndex = detailSections.index(of: .remainingTimeCell) else { return }
        self.tableView.reloadSections(IndexSet([timeCellIndex]), with: .automatic)
    }
    
    func setupJoinButton() {
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
        guard let conversation = LCCKConversationViewController(conversationId: event.transientConversationId) else {
            self.displayInfo(info: "网络错误，无法进入评论区")
            return
        }
        conversation.isEnableAutoJoin = true
        self.navigationController?.pushViewController(conversation, animated: true)
    }
    
    func joinEvent() {
        SVProgressHUD.show()
        self.event.add(newMember: AVUser.current()!) {
            succeeded, error in
            SVProgressHUD.dismiss()
            if succeeded {
                let joinEventGroup = DispatchGroup()
                joinEventGroup.enter()
                EventRequest.setMyOngoingEvent(event: self.event, for: self.event.objectId!, handler: nil)
                joinEventGroup.leave()
                
                joinEventGroup.enter()
                EventRequest.removePublicEvent(with: self.event.objectId!, handler: nil)
                joinEventGroup.leave()
                
                joinEventGroup.notify(queue: DispatchQueue.main) {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "userDidJoinEvent"), object: nil, userInfo: nil)
                    _ = self.navigationController?.popViewController(animated: true)
                }
            }
            else if error != nil {
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
    
    func quitRequest() {
        
        let alertViewController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let quit = UIAlertAction(title: "退出微活动", style: .destructive) {
            _ in
            SVProgressHUD.show()
            self.event.remove(member: AVUser.current()!) {
                succeeded, error in
                SVProgressHUD.dismiss()
                if succeeded {
                    let quitEventGroup = DispatchGroup()
                    quitEventGroup.enter()
                    EventRequest.setPublicEvent(event: self.event, for: self.event.objectId!, handler: nil)
                    quitEventGroup.leave()
                    
                    quitEventGroup.enter()
                    EventRequest.removeMyOngoingEvent(with: self.event.objectId!, handler: nil)
                    quitEventGroup.leave()
                    
                    quitEventGroup.notify(queue: DispatchQueue.main) {
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "userDidQuitEvent"), object: nil, userInfo: nil)
                        _ = self.navigationController?.popViewController(animated: true)
                    }
                }
                else if error != nil {
                    self.displayInfo(info: error!.localizedDescription)
                }
            }
        }
        let cancel = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        alertViewController.addAction(quit)
        alertViewController.addAction(cancel)
        self.present(alertViewController, animated: true, completion: nil)
    }
    
    @IBAction func takeActions(_ sender: UIBarButtonItem) {
        let alertViewController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let shareToFriend = UIAlertAction(title: "分享给微信好友", style: .default) {
            _ in
            let message = WXMediaMessage()
            message.title = self.event!.name
            let ext = WXWebpageObject()
            ext.webpageUrl = "http://usrichange.com"
            message.mediaObject = ext
            
            let req = SendMessageToWXReq()
            req.bText = false
            req.message = message
            req.scene = Int32(WXSceneSession.rawValue)
            WXApi.send(req)
        }
        let shareToMoment = UIAlertAction(title: "分享到朋友圈", style: .default) {
            _ in
            let message = WXMediaMessage()
            message.title = self.event!.name
            let ext = WXWebpageObject()
            ext.webpageUrl = "http://usrichange.com"
            message.mediaObject = ext
            
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
                        upVC.other = User(user: event.members[(sender as! UIButton).tag])
                    case is EventCreatorTableViewCell:
                        upVC.other = creator
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
            let cell = Bundle.main.loadNibNamed("TitleContentTableViewCell", owner: self, options: nil)?.first as! TitleContentTableViewCell
            cell.titleLabel.text = "微活动地点："
            cell.contentLabel.text = event.location
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
        self.setupJoinButton()
        self.populateSections()
        self.tableView.reloadData()
    }
}
