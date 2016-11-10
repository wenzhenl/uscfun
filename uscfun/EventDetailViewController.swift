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
    case imageViewTableCell(image: UIImage)
    case textViewTableCell(text: String)
    case singleButtonTableCell
    case imgKeyValueTableCell(image: UIImage, key: String, value: String)
    case imgKeyValueArrowTableCell(image: UIImage, key: String, value: String)
    case imgKeyScrollViewTableCell(image: UIImage, key: String, contentImages: [UIImage])
}

protocol EventMemberStatusDelegate {
    func userDidJoinEventWith(id: String)
    func userDidQuitEventWith(id: String)
    func userDidPostEvent()
}

class EventDetailViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var dimView: UIView!
    
    var event: Event?
    var detailSections = [[EventDetailCell]]()
    
    var delegate: EventMemberStatusDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(takeActions))
        self.view.backgroundColor = UIColor.backgroundGray
        self.tableView.backgroundColor = UIColor.backgroundGray
        self.tableView.tableFooterView = UIView()
        self.dimView.isHidden = true
        populateSections()
    }
    
    func showUpdateReminder(message: String) {
        
        self.dimView.isHidden = false
        let actionViewController = self.storyboard!.instantiateViewController(withIdentifier: USCFunConstants.storyboardIdentifierOfCustomizedAlertViewController) as! CustomizedAlertViewController
        actionViewController.delegate = self
        actionViewController.alertType = CustomAlertType.showError
        actionViewController.errorDescription = message
        actionViewController.modalPresentationStyle = .overFullScreen
        self.present(actionViewController, animated: true, completion: nil)
        
        let delay = 2 * Double(NSEC_PER_SEC)
        let time = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: time) {
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
                _ in
                self.dimView.isHidden = true
                actionViewController.dismiss(animated: true, completion: nil)
                }, completion: nil)
        }
    }

    func populateSections() {
        // Populate the cells
        detailSections.removeAll()
        if let event = event {
            let profileSection = [EventDetailCell.imageViewTableCell(image: event.type.image)]
            detailSections.append(profileSection)
            
            let nameSection = [EventDetailCell.textViewTableCell(text: event.name)]
            detailSections.append(nameSection)
            
            let seatsSection = [EventDetailCell.imgKeyValueTableCell(image: #imageLiteral(resourceName: "target"), key: "目标人数", value: "\(event.totalSeats)人"),
                                EventDetailCell.imgKeyValueTableCell(image: #imageLiteral(resourceName: "target"), key: "当前报名", value: "\(event.totalSeats - event.remainingSeats)人"),
                                EventDetailCell.imgKeyValueTableCell(image: #imageLiteral(resourceName: "target"), key: "最低成行", value: "\(event.minimumAttendingPeople)人")]
            detailSections.append(seatsSection)
            
            var memberAvatars = [UIImage]()
            for i in 0 ..< event.members.count {
                let avatar = User(user: event.members[i])?.avatar ?? #imageLiteral(resourceName: "user-4")
                memberAvatars.append(avatar)
            }
            let memberSection = [EventDetailCell.imgKeyScrollViewTableCell(image: #imageLiteral(resourceName: "users"), key: "当前成员", contentImages: memberAvatars)]
            detailSections.append(memberSection)
            
            if event.members.contains(AVUser.current()) {
                var memberShip = ""
                if event.creator == AVUser.current() {
                    memberShip = "作为发起人"
                } else {
                    memberShip = "作为参与者"
                }
                let memberStatusSection = [EventDetailCell.imgKeyValueArrowTableCell(image: #imageLiteral(resourceName: "user1"), key: memberStatusKey, value: memberShip)]
                detailSections.append(memberStatusSection)
            } else {
                let joinButtonSection = [EventDetailCell.singleButtonTableCell]
                detailSections.append(joinButtonSection)
            }
            let chatSection = [EventDetailCell.imgKeyValueArrowTableCell(image: #imageLiteral(resourceName: "chat"), key: "参与讨论", value: "")]
            detailSections.append(chatSection)
            
            // handle optional information
            var optionalSection = [EventDetailCell]()
            if let startTime = event.startTime {
                optionalSection.append(EventDetailCell.imgKeyValueTableCell(image: #imageLiteral(resourceName: "clock"), key: "开始时间", value: startTime.humanReadable))
            }
            
            if let endTime = event.endTime {
                optionalSection.append(EventDetailCell.imgKeyValueTableCell(image: #imageLiteral(resourceName: "clock"), key: "结束时间", value: endTime.humanReadable))
            }
            
            if let locationName = event.locationName {
                optionalSection.append(EventDetailCell.imgKeyValueArrowTableCell(image: #imageLiteral(resourceName: "location"), key: eventLocationKey, value: locationName))
            }
            
            if let expectedFee = event.expectedFee {
                optionalSection.append(EventDetailCell.imgKeyValueTableCell(image: #imageLiteral(resourceName: "dollar"), key: "预计费用", value: "$\(expectedFee.description)"))
            }
            
            if optionalSection.count > 0 {
                detailSections.append(optionalSection)
            }
            
            if let note = event.note {
                let noteSection = [EventDetailCell.textViewTableCell(text: note)]
                detailSections.append(noteSection)
            }
        }
    }
    
    func joinEvent(sender: UIButton) {
        SVProgressHUD.show()
        self.event?.add(newMember: AVUser.current()) {
            succeeded, error in
            SVProgressHUD.dismiss()
            if succeeded {
                self.populateSections()
                self.tableView.reloadData()
                self.delegate?.userDidJoinEventWith(id: self.event!.objectId!)
            }
            else if error != nil {
                self.showUpdateReminder(message: error!.localizedDescription)
            }
        }
    }
    
    func quitRequest() {
        
        self.dimView.isHidden = false
        let actionViewController = self.storyboard!.instantiateViewController(withIdentifier: USCFunConstants.storyboardIdentifierOfCustomizedAlertViewController) as! CustomizedAlertViewController
        actionViewController.delegate = self
        actionViewController.alertType = CustomAlertType.quitEvent
        actionViewController.modalPresentationStyle = .overFullScreen
        self.present(actionViewController, animated: true, completion: nil)
    }
    
    func takeActions() {
        
        self.dimView.isHidden = false
        let actionViewController = self.storyboard!.instantiateViewController(withIdentifier: USCFunConstants.storyboardIdentifierOfCustomizedAlertViewController) as! CustomizedAlertViewController
        actionViewController.delegate = self
        actionViewController.alertType = CustomAlertType.shareEvent
        actionViewController.modalPresentationStyle = .overFullScreen
        self.present(actionViewController, animated: true, completion: nil)
    }
    
    func back() {
        let cv = self.navigationController?.popViewController(animated: true)
        cv?.navigationController?.isNavigationBarHidden = true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
            case mapSegueIdentifier:
                let destination = segue.destination
                if let _ = destination as? MapViewController {
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
        self.dimView.isHidden = true
    }

    func withdraw() {
        self.dimView.isHidden = true
    }
    
    func shareEventToMoments() {
        print("share event to moments")
        self.dimView.isHidden = true
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
        self.dimView.isHidden = true
        self.dimView.isHidden = true
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
        print("quit event")
        self.dimView.isHidden = true
        SVProgressHUD.show()
        self.event?.remove(member: AVUser.current()) {
            succeeded, error in
            SVProgressHUD.dismiss()
            if succeeded {
                self.populateSections()
                self.tableView.reloadData()
                self.delegate?.userDidQuitEventWith(id: self.event!.objectId!)
            }
            else if error != nil {
                self.showUpdateReminder(message: error!.localizedDescription)
            }
        }
    }
}

extension EventDetailViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return detailSections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return detailSections[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch detailSections[indexPath.section][indexPath.row] {
        case .imageViewTableCell(let image):
            let cell = Bundle.main.loadNibNamed("ImageViewTableViewCell", owner: self, options: nil)?.first as! ImageViewTableViewCell
            cell.mainImageView.image = image
            cell.mainImageView.contentMode = .scaleAspectFit
            cell.selectionStyle = .none
            return cell
        case .imgKeyValueTableCell(let image, let key, let value):
            let cell = Bundle.main.loadNibNamed("ImgKeyValueTableViewCell", owner: self, options: nil)?.first as! ImgKeyValueTableViewCell
            cell.mainImageView.image = image
            cell.keyLabel.text = key
            cell.valueLabel.text = value
            cell.selectionStyle = .none
            return cell
        case .imgKeyValueArrowTableCell(let image, let key, let value):
            let cell = Bundle.main.loadNibNamed("ImgKeyValueArrowTableViewCell", owner: self, options: nil)?.first as! ImgKeyValueArrowTableViewCell
            cell.mainImageView.image = image
            cell.keyLabel.text = key
            cell.valueLabel.text = value
            return cell
        case .singleButtonTableCell:
            let cell = Bundle.main.loadNibNamed("SingleButtonTableViewCell", owner: self, options: nil)?.first as! SingleButtonTableViewCell
             cell.button.layer.cornerRadius = 25
            cell.button.setTitle("报名参加", for: .normal)
            cell.button.addTarget(self, action: #selector(joinEvent(sender:)), for: .touchUpInside)
            return cell
        case .textViewTableCell(let text):
            let cell = Bundle.main.loadNibNamed("TextViewTableViewCell", owner: self, options: nil)?.first as! TextViewTableViewCell
            cell.textView.text = text
            cell.textView.textColor = UIColor.darkText
            return cell
        case .imgKeyScrollViewTableCell(let image, let key, let contentImages):
            let cell = Bundle.main.loadNibNamed("KeyScrollViewTableViewCell", owner: self, options: nil)?.first as! KeyScrollViewTableViewCell
            cell.mainImageView.image = image
            cell.mainLabel.text = key
            for i in 0 ..< contentImages.count {
                let imageView = UIImageView()
                imageView.image = contentImages[i]
                let imageWidth = CGFloat(30.0)
                let overlapRatio = CGFloat(2.0/3.0)
                let xPosition = imageWidth * overlapRatio * CGFloat(i)
                imageView.frame = CGRect(x: xPosition, y: (44.0 - imageWidth) * 0.5, width: imageWidth, height: imageWidth)
                imageView.layer.cornerRadius = imageWidth / 2.0
                imageView.layer.masksToBounds = true
                imageView.contentMode = .scaleAspectFit
                cell.mainScrollView.contentSize.width = imageWidth * overlapRatio * CGFloat(i+1)
                cell.mainScrollView.addSubview(imageView)
            }
            cell.mainScrollView.isUserInteractionEnabled = false
            return cell
        }
    }
}

extension EventDetailViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch detailSections[indexPath.section][indexPath.row] {
        case .imageViewTableCell(_):
            return 150
        default:
            return UITableViewAutomaticDimension
        }    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        switch detailSections[indexPath.section][indexPath.row] {
        case .imageViewTableCell(_):
            return 200
        default:
            return 44
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        switch detailSections[indexPath.section][indexPath.row] {
        case .imageViewTableCell(_), .singleButtonTableCell:
            cell.backgroundColor = UIColor.clear
        default:
            cell.backgroundColor = UIColor.white
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        view.tintColor = UIColor.clear
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        if section == 0 || section == 1 || section == 2 {
            return 1
        }
        return 30
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch detailSections[indexPath.section][indexPath.row] {
        case .imgKeyValueArrowTableCell(_, let key, _):
            if key == eventLocationKey {
                performSegue(withIdentifier: mapSegueIdentifier, sender: self)
            }
            else if key == conversationKey {
                tableView.cellForRow(at: indexPath)?.isUserInteractionEnabled = false
                SVProgressHUD.show()
                
                if let event = self.event {
                    if let conversationVC = LCCKConversationViewController(conversationId: event.conversationId) {
                        conversationVC.isEnableAutoJoin = true
                        tableView.cellForRow(at: indexPath)?.isUserInteractionEnabled = true
                        SVProgressHUD.dismiss()
                        self.navigationController?.pushViewController(conversationVC, animated: true)
                    }  else {
                        tableView.cellForRow(at: indexPath)?.isUserInteractionEnabled = true
                        SVProgressHUD.dismiss()
                    }
                } else {
                    tableView.cellForRow(at: indexPath)?.isUserInteractionEnabled = true
                    SVProgressHUD.dismiss()
                }
            }
            else if key == memberStatusKey {
                self.quitRequest()
            }
        case .imgKeyScrollViewTableCell(_, _, _):
            self.performSegue(withIdentifier: memberSugueIdentifier, sender: self)
        default:
            break
        }
        
        tableView.deselectRow(at: indexPath, animated: false)
    }
}
