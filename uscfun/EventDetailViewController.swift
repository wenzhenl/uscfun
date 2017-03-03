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
    case headerCell
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
    var detailSections = [EventDetailCell]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 150, 0)
        self.tableView.tableFooterView = UIView()
        self.joinButton.backgroundColor = UIColor.buttonPink
        self.chatButton.backgroundColor = UIColor.buttonBlue
        self.populateSections()
    }

    func populateSections() {
        // Populate the cells
        detailSections.removeAll()
        detailSections.append(EventDetailCell.headerCell)
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
        case .headerCell:
            let cell = Bundle.main.loadNibNamed("EventDetailHeaderTableViewCell", owner: self, options: nil)?.first as! EventDetailHeaderTableViewCell
            
            let creator = User(user: event.creator)!
            cell.avatarImageView.layer.masksToBounds = true
            cell.avatarImageView.image = creator.avatar
            cell.creatorLabel.text = "发起人：" + creator.nickname
            cell.eventNameLabel.text = event.name
            cell.remainingNumberLabel.text = String(event.remainingSeats)
            cell.attendingNumberLabel.text = "已经" + String(event.totalSeats - event.remainingSeats) + "人报名"
            cell.minPeopleLabel.text = "最少" + String(event.minimumAttendingPeople) + "人成行"
            cell.remainingTimeLabel.text = event.due.gapFromNow
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
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
}
