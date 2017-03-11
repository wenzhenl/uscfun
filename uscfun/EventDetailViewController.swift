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
    
    var infoLabel: UILabel!
    let heightOfInfoLabel = CGFloat(46.0)
    
    lazy var blurView: UIView = {
        let blurView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
        blurView.backgroundColor = UIColor.lightGray
        blurView.alpha = 0.2
        return blurView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.view.backgroundColor = UIColor.white
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 50, 0)
        self.tableView.tableFooterView = UIView()
        self.joinButton.backgroundColor = UIColor.buttonPink
        self.chatButton.backgroundColor = UIColor.buttonBlue
        self.populateSections()
        creator = User(user: event.createdBy)
        
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
    
    func setupJoinButton() {
        switch event.relationWithMe {
        case .createdByMe:
            joinButton.setTitle("修改微活动", for: .normal)
        case .joinedByMe:
            joinButton.setTitle("已经参加", for: .normal)
        case .noneOfMyBusiness:
            joinButton.setTitle("报名参加", for: .normal)
        }
        
        switch event.status {
        case .isCancelled, .isFailed, .isCompleted:
            joinButton.isEnabled = false
        case .isFinalized:
            if event.relationWithMe != .createdByMe {
                joinButton.isEnabled = false
            }
        default:
            break
        }
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
            performSegue(withIdentifier: "go to edit event", sender: self)
        case .joinedByMe:
            quitRequest()
        case .noneOfMyBusiness:
            joinEvent()
        }
    }
    
    @IBAction func joinDiscussion(_ sender: UIButton) {
  
    }
    
    func joinEvent() {
        SVProgressHUD.show()
        self.event.add(newMember: AVUser.current()!) {
            succeeded, error in
            SVProgressHUD.dismiss()
            if succeeded {
                self.populateSections()
                self.tableView.reloadData()
                self.setupJoinButton()
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "userDidJoinEvent"), object: nil, userInfo: ["eventId": event.objectId!])
            }
            else if error != nil {
                self.displayInfo(info: error!.localizedDescription)
            }
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
    
    func quitRequest() {
        
        let actionViewController = self.storyboard!.instantiateViewController(withIdentifier: USCFunConstants.storyboardIdentifierOfCustomizedAlertViewController) as! CustomizedAlertViewController
        actionViewController.delegate = self
        actionViewController.alertType = CustomAlertType.quitEvent
        actionViewController.modalPresentationStyle = .overFullScreen
        if !self.view.subviews.contains(blurView) {
            self.view.addSubview(blurView)
        }
        self.present(actionViewController, animated: true, completion: nil)
    }
    
    @IBAction func takeActions(_ sender: UIBarButtonItem) {
        let actionViewController = self.storyboard!.instantiateViewController(withIdentifier: USCFunConstants.storyboardIdentifierOfCustomizedAlertViewController) as! CustomizedAlertViewController
        actionViewController.delegate = self
        actionViewController.alertType = CustomAlertType.shareEvent
        actionViewController.modalPresentationStyle = .overFullScreen
        if !self.view.subviews.contains(blurView) {
            self.view.addSubview(blurView)
        }
        self.present(actionViewController, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
            case mapSegueIdentifier:
                let destination = segue.destination
                if let mapVC = destination as? MapViewController {
                    mapVC.placename = event?.location
                    mapVC.latitude = event?.whereCreated?.latitude
                    mapVC.longitude = event?.whereCreated?.longitude
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
    let editEventSegueIdentifier = "go to edit event"
}

extension EventDetailViewController: CustomizedAlertViewDelegate {
    internal func reportEvent() {
        self.blurView.removeFromSuperview()
    }

    func withdraw() {
        self.blurView.removeFromSuperview()
    }
    
    func shareEventToMoments() {
        
        self.blurView.removeFromSuperview()
        
        print("share event to moments")
        let message = WXMediaMessage()
        message.title = event!.name
//        message.setThumbImage(event!.type.image)
        
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
        
        self.blurView.removeFromSuperview()

        print("share event to friend")
        let message = WXMediaMessage()
        message.title = event!.name
//        message.setThumbImage(event!.type.image)
        
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
        
        self.blurView.removeFromSuperview()

        print("quit event")
        SVProgressHUD.show()
        self.event.remove(member: AVUser.current()!) {
            succeeded, error in
            SVProgressHUD.dismiss()
            if succeeded {
                self.populateSections()
                self.tableView.reloadData()
                self.setupJoinButton()
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "userDidQuitEvent"), object: nil, userInfo: ["eventId": event.objectId!])
            }
            else if error != nil {
                self.displayInfo(info: error!.localizedDescription)
            }
        }
    }
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
            let cell = Bundle.main.loadNibNamed("CollectionViewTableViewCell", owner: self, options: nil)?.first as! CollectionViewTableViewCell
            cell.collectionView.delegate = self
            cell.collectionView.dataSource = self
            let layout = UICollectionViewFlowLayout()
            layout.itemSize = CGSize(width: 100, height: 100)
            layout.scrollDirection = .vertical
            cell.collectionView.collectionViewLayout = layout
            cell.collectionView.contentInset = UIEdgeInsetsMake(100, 0, 50, 0)
            cell.collectionView.reloadData()
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
