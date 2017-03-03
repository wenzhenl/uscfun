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
    var detailSections = [EventDetailCell]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.view.backgroundColor = UIColor.backgroundGray
        self.tableView.contentInset = UIEdgeInsetsMake(10, 0, 150, 0)
        self.tableView.tableFooterView = UIView()
        self.joinButton.backgroundColor = UIColor.buttonPink
        self.chatButton.backgroundColor = UIColor.buttonBlue
        self.populateSections()
        creator = User(user: event.creator)
    }
    
    func populateSections() {
        // Populate the cells
        detailSections.removeAll()
        detailSections.append(EventDetailCell.statusCell)
        detailSections.append(EventDetailCell.titleCell)
        detailSections.append(EventDetailCell.creatorCell)
        detailSections.append(EventDetailCell.remainingNumberCell)
        detailSections.append(EventDetailCell.numberCell)
        detailSections.append(EventDetailCell.remainingTimeCell)
        if event.startTime != nil {
            detailSections.append(EventDetailCell.startTimeCell)
        }
        if event.endTime != nil {
            detailSections.append(EventDetailCell.endTimeCell)
        }
        if event.locationName != nil {
            detailSections.append(EventDetailCell.locationCell)
        }
        if event.note != nil {
            detailSections.append(EventDetailCell.noteCell)
        }
        if event.location != nil {
            detailSections.append(EventDetailCell.mapCell)
        }
    }
    
//    func joinEvent(sender: UIButton) {
//        SVProgressHUD.show()
//        self.event?.add(newMember: AVUser.current()) {
//            succeeded, error in
//            SVProgressHUD.dismiss()
//            if succeeded {
//                self.populateSections()
//                self.tableView.reloadData()
//                self.delegate?.userDidJoinEventWith(id: self.event!.objectId!)
//            }
//            else if error != nil {
//                self.showUpdateReminder(message: error!.localizedDescription)
//            }
//        }
//    }
    
//    func quitRequest() {
//        
//        let actionViewController = self.storyboard!.instantiateViewController(withIdentifier: USCFunConstants.storyboardIdentifierOfCustomizedAlertViewController) as! CustomizedAlertViewController
//        actionViewController.delegate = self
//        actionViewController.alertType = CustomAlertType.quitEvent
//        actionViewController.modalPresentationStyle = .overFullScreen
//        self.present(actionViewController, animated: true, completion: nil)
//    }
//    
//    func takeActions() {
//        
//        let actionViewController = self.storyboard!.instantiateViewController(withIdentifier: USCFunConstants.storyboardIdentifierOfCustomizedAlertViewController) as! CustomizedAlertViewController
//        actionViewController.delegate = self
//        actionViewController.alertType = CustomAlertType.shareEvent
//        actionViewController.modalPresentationStyle = .overFullScreen
//        self.present(actionViewController, animated: true, completion: nil)
//    }
    
    @IBAction func takeActions(_ sender: UIBarButtonItem) {
        let actionViewController = self.storyboard!.instantiateViewController(withIdentifier: USCFunConstants.storyboardIdentifierOfCustomizedAlertViewController) as! CustomizedAlertViewController
        actionViewController.delegate = self
        actionViewController.alertType = CustomAlertType.shareEvent
        actionViewController.modalPresentationStyle = .overFullScreen
        self.present(actionViewController, animated: true, completion: nil)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
            case mapSegueIdentifier:
                let destination = segue.destination
                if let mapVC = destination as? MapViewController {
                    mapVC.placename = event?.locationName
                    mapVC.latitude = event?.location?.latitude
                    mapVC.longitude = event?.location?.longitude
                    print("go to see map")
                }
            case memberSugueIdentifier:
                let destination = segue.destination
                if let memberDetailVC = destination as? MembersTableViewController {
                    memberDetailVC.event = self.event
                }
            default:
                break
            }
        }
    }
    
    //--MARK: global constants
    let eventLocationKey = "活动地点"
    let conversationKey = "参与讨论"
    let memberStatusKey = "已经参加"
    let mapSegueIdentifier = "SHOWMAP"
    let memberSugueIdentifier = "see member detail"
}

extension EventDetailViewController: CustomizedAlertViewDelegate {
    internal func reportEvent() {
    }

    func withdraw() {
    }
    
    func shareEventToMoments() {
        print("share event to moments")
        let message = WXMediaMessage()
        message.title = event!.name
        message.setThumbImage(event!.type.image)
        
        let ext = WXWebpageObject()
        ext.webpageUrl = "http://usrichange.com"
        message.mediaObject = ext
        
        let req = SendMessageToWXReq()
        req.bText = false
        req.message = message
        req.scene = Int32(WXSceneTimeline.rawValue)
        WXApi.send(req)
    }
    
    func shareEventToWechatFriend() {
        print("share event to friend")
        let message = WXMediaMessage()
        message.title = event!.name
        message.setThumbImage(event!.type.image)
        
        let ext = WXWebpageObject()
        ext.webpageUrl = "http://usrichange.com"
        message.mediaObject = ext
        
        let req = SendMessageToWXReq()
        req.bText = false
        req.message = message
        req.scene = Int32(WXSceneSession.rawValue)
        WXApi.send(req)
    }
    
    func quitEvent() {
    }
//    
//    func quitEvent() {
//        print("quit event")
//        SVProgressHUD.show()
//        self.event?.remove(member: AVUser.current()) {
//            succeeded, error in
//            SVProgressHUD.dismiss()
//            if succeeded {
//                self.populateSections()
//                self.tableView.reloadData()
//                self.delegate?.userDidQuitEventWith(id: self.event!.objectId!)
//            }
//            else if error != nil {
//                self.showUpdateReminder(message: error!.localizedDescription)
//            }
//        }
//    }
}

extension EventDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return detailSections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 300
        }
        return 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch detailSections[indexPath.section] {
        case .statusCell:
            let cell = Bundle.main.loadNibNamed("EventStatusBarTableViewCell", owner: self, options: nil)?.first as! EventStatusBarTableViewCell
            cell.statusView.backgroundColor = event.statusColor
            cell.statusLabel.text = event.statusDescription
            return cell
        case .titleCell:
            let cell = Bundle.main.loadNibNamed("EventTitleTableViewCell", owner: self, options: nil)?.first as! EventTitleTableViewCell
            cell.titleLabel.text = event.name
            return cell
        case .creatorCell:
            let cell = Bundle.main.loadNibNamed("EventCreatorTableViewCell", owner: self, options: nil)?.first as! EventCreatorTableViewCell
            cell.avatorImageView.layer.masksToBounds = true
            cell.avatorImageView.layer.cornerRadius = cell.avatorImageView.frame.size.width / 2.0
            cell.avatorImageView.image = creator.avatar
            cell.creatorLabel.text = creator.nickname
            return cell
        case .remainingNumberCell:
            let cell = Bundle.main.loadNibNamed("NumberDisplayTableViewCell", owner: self, options: nil)?.first as! NumberDisplayTableViewCell
            cell.numberLabel.text = String(event.remainingSeats)
            return cell
        case .numberCell:
            let cell = Bundle.main.loadNibNamed("TandemLabelTableViewCell", owner: self, options: nil)?.first as! TandemLabelTableViewCell
            cell.leftLabel.text = "已经报名 " + String(event.totalSeats - event.remainingSeats) + "人"
            cell.rightLabel.text = "最少成行 " + String(event.minimumAttendingPeople) + "人"
            return cell
        case .remainingTimeCell:
            let cell = Bundle.main.loadNibNamed("TitleContentTableViewCell", owner: self, options: nil)?.first as! TitleContentTableViewCell
            cell.titleLabel.text = "离报名截止还剩："
            cell.contentLabel.text = event.due.gapFromNow
            return cell
        case .startTimeCell:
            let cell = Bundle.main.loadNibNamed("TimeDisplayTableViewCell", owner: self, options: nil)?.first as! TimeDisplayTableViewCell
            cell.titleLabel.text = "活动开始时间："
            cell.dateLabel.text = event.startTime!.readableDate
            cell.timeLabel.text = event.startTime!.readableTime
            return cell
        case .endTimeCell:
            let cell = Bundle.main.loadNibNamed("TimeDisplayTableViewCell", owner: self, options: nil)?.first as! TimeDisplayTableViewCell
            cell.titleLabel.text = "活动结束时间："
            cell.dateLabel.text = event.endTime!.readableDate
            cell.timeLabel.text = event.endTime!.readableTime
            return cell
        case .locationCell:
            let cell = Bundle.main.loadNibNamed("TitleContentTableViewCell", owner: self, options: nil)?.first as! TitleContentTableViewCell
            cell.titleLabel.text = "活动地点："
            cell.contentLabel.text = event.locationName
            return cell
        case .mapCell:
            let cell = Bundle.main.loadNibNamed("MapViewTableViewCell", owner: self, options: nil)?.first as! MapViewTableViewCell
            return cell
        case .noteCell:
            let cell = Bundle.main.loadNibNamed("TitleTextViewTableViewCell", owner: self, options: nil)?.first as! TitleTextViewTableViewCell
            cell.titleLabel.text = "补充说明："
            cell.textView.text = event.note
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 2 || section == 3 {
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
        if section == 1 {
            return 10
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        return view
    }
    
    func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        view.tintColor = UIColor.clear
    }
}
