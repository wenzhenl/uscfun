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
    var detailSections = [EventDetailCell]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.view.backgroundColor = UIColor.white
        self.tableView.contentInset = UIEdgeInsetsMake(10, 0, 50, 0)
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
//        if event.members.count > 1 {
            detailSections.append(EventDetailCell.memberCell)
//        }
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
                }
            case userProfileSugueIdentifier:
                let destination = segue.destination
                if let upVC = destination as? UserProfileViewController {
                    upVC.other = creator
                }
            default:
                break
            }
        }
    }
    
    //--MARK: global constants
    let mapSegueIdentifier = "SHOWMAP"
    let userProfileSugueIdentifier = "see user profile"
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if detailSections[indexPath.section] == .mapCell {
            performSegue(withIdentifier: mapSegueIdentifier, sender: self)
        }
        
        if detailSections[indexPath.section] == .creatorCell {
            performSegue(withIdentifier: userProfileSugueIdentifier, sender: self)
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
            cell.statusLabel.text = event.statusDescription
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
            cell.selectionStyle = .none
            return cell
        case .numberCell:
            let cell = Bundle.main.loadNibNamed("TandemLabelTableViewCell", owner: self, options: nil)?.first as! TandemLabelTableViewCell
            cell.leftLabel.text = "已经报名 " + String(event.totalSeats - event.remainingSeats) + "人"
            cell.rightLabel.text = "最少成行 " + String(event.minimumAttendingPeople) + "人"
            cell.selectionStyle = .none
            return cell
        case .remainingTimeCell:
            let cell = Bundle.main.loadNibNamed("TitleContentTableViewCell", owner: self, options: nil)?.first as! TitleContentTableViewCell
            cell.titleLabel.text = "离报名截止还剩："
            cell.contentLabel.text = event.due.gapFromNow
            cell.selectionStyle = .none
            return cell
        case .startTimeCell:
            let cell = Bundle.main.loadNibNamed("TimeDisplayTableViewCell", owner: self, options: nil)?.first as! TimeDisplayTableViewCell
            cell.titleLabel.text = "活动开始时间："
            cell.dateLabel.text = event.startTime!.readableDate
            cell.timeLabel.text = event.startTime!.readableTime
            cell.selectionStyle = .none
            return cell
        case .endTimeCell:
            let cell = Bundle.main.loadNibNamed("TimeDisplayTableViewCell", owner: self, options: nil)?.first as! TimeDisplayTableViewCell
            cell.titleLabel.text = "活动结束时间："
            cell.dateLabel.text = event.endTime!.readableDate
            cell.timeLabel.text = event.endTime!.readableTime
            cell.selectionStyle = .none
            return cell
        case .locationCell:
            let cell = Bundle.main.loadNibNamed("TitleContentTableViewCell", owner: self, options: nil)?.first as! TitleContentTableViewCell
            cell.titleLabel.text = "活动地点："
            cell.contentLabel.text = event.locationName
            cell.selectionStyle = .none
            return cell
        case .mapCell:
            let cell = Bundle.main.loadNibNamed("MapViewTableViewCell", owner: self, options: nil)?.first as! MapViewTableViewCell
            let location = CLLocationCoordinate2D(latitude: (event.location?.latitude)!, longitude: (event.location?.longitude)!)
            let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            let region = MKCoordinateRegion(center: location, span: span)
            cell.mapView.setRegion(region, animated: true)
            let annotation = MKPointAnnotation()
            annotation.coordinate = location
            annotation.title = event.locationName
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
            let cell = Bundle.main.loadNibNamed("CollectionViewTableViewCell", owner: self, options: nil)?.first as! CollectionViewTableViewCell
            cell.collectionView.delegate = self
            cell.collectionView.dataSource = self
            let layout = UICollectionViewFlowLayout()
            layout.itemSize = CGSize(width: 100, height: 100)
            layout.scrollDirection = .vertical
            cell.collectionView.collectionViewLayout = layout
            cell.collectionView.contentInset = UIEdgeInsetsMake(100, 0, 50, 0)
            cell.collectionView.reloadData()
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

extension EventDetailViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("haha, iam here1")
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = Bundle.main.loadNibNamed("ImageViewCollectionViewCell", owner: self, options: nil)?.first as! ImageViewCollectionViewCell
        (cell.viewWithTag(1) as! UIImageView).image = creator.avatar
        print("haha, iam here--------")
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        print("haha, iam here2")
        let width = collectionView.frame.size.width / 3.0 - 1
        return CGSize(width: width , height: width )
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
}
