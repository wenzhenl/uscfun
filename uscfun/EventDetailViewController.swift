//
//  EventDetailViewController.swift
//  uscfun
//
//  Created by Wenzheng Li on 9/3/16.
//  Copyright © 2016 Wenzheng Li. All rights reserved.
//

import UIKit
import ChatKit

enum EventDetailCell {
    case imageViewTableCell(image: UIImage)
    case textViewTableCell(text: String)
    case singleButtonTableCell
    case imgKeyValueTableCell(image: UIImage, key: String, value: String)
    case imgKeyValueArrowTableCell(image: UIImage, key: String, value: String)
}

class EventDetailViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var event: Event?
    var detailSections = [[EventDetailCell]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(takeActions))
        self.view.backgroundColor = UIColor.backgroundGray
        self.tableView.backgroundColor = UIColor.backgroundGray
        self.tableView.tableFooterView = UIView()
        
        populateSections()
    }

    func populateSections() {
        // Populate the cells
        detailSections.removeAll()
        if let event = event {
            let profileSection = [EventDetailCell.imageViewTableCell(image: event.type.image)]
            detailSections.append(profileSection)
            
            let nameSection = [EventDetailCell.textViewTableCell(text: event.name)]
            detailSections.append(nameSection)
            
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
        sender.isEnabled = false
        self.event?.add(newMember: AVUser.current()) {
            succeed, error in
            if succeed {
                populateSections()
                self.tableView.reloadData()
            }
        }
    }
    
    func quitEvent() {
        let alertController = UIAlertController(title: "退出小活动", message: "你是否想退出此活动?", preferredStyle: .actionSheet)
        let quit = UIAlertAction(title: "决定退出", style: .default) {
            _ in
            self.event?.remove(member: AVUser.current()) {
                succeed, error in
                if succeed {
                    self.populateSections()
                    self.tableView.reloadData()
                }
            }
        }
        let cancel = UIAlertAction(title: "原谅我的手滑", style: .cancel, handler: nil)
        alertController.addAction(quit)
        alertController.addAction(cancel)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func takeActions() {
        
    }
    
    func shareEvent() {
        let image = #imageLiteral(resourceName: "albums")
        let ext = WXImageObject()
        ext.imageData = UIImagePNGRepresentation(image)
        
        let message = WXMediaMessage()
        message.title = "I am title"
        message.description = "I am description"
        message.mediaObject = ext
        message.mediaTagName = "MyPic"
        
        UIGraphicsBeginImageContext(CGSize(width: 100, height: 100))
        image.draw(in: CGRect(x: 0, y: 0, width: 100, height: 100))
        let thumbImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        message.thumbData = UIImagePNGRepresentation(thumbImage!)
        
        let req = SendMessageToWXReq()
        req.text = "I am text for req"
        req.message = message
        req.bText = false
        req.scene = 1
        WXApi.send(req)
    }
    
    func back() {
        let cv = self.navigationController?.popViewController(animated: true)
        cv?.navigationController?.isNavigationBarHidden = true
    }
    
    
    //--MARK: global constants
    let eventLocationKey = "活动地点"
    let memberStatusKey = "已经参加"
    let mapSegueIdentifier = "SHOWMAP"
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
            cell.mainImageView.contentMode = .scaleToFill
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
        
        if section == 0 {
            return 0
        }
        return 30
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 3 {
            if let event = self.event {
                LCChatKit.sharedInstance().open(withClientId: AVUser.current().username, force: true) {
                    succeed, error in
                    if let conversationVC = LCCKConversationViewController(conversationId: event.conversationId) {
                        conversationVC.isEnableAutoJoin = true
                        
                        conversationVC.setFetchConversationHandler() {
                            conversation, error in
                            if conversation == nil {
                                print("Serious error happened")
                            } else {
                                print("successfully fetched conversation")
                            }
                        }
                        self.navigationController?.pushViewController(conversationVC, animated: true)
                    }
                }
            }
        }
        else {
            switch detailSections[indexPath.section][indexPath.row] {
            case .imgKeyValueArrowTableCell(_, let key, _):
                if key == eventLocationKey {
                    performSegue(withIdentifier: mapSegueIdentifier, sender: self)
                }
                else if key == memberStatusKey {
                    self.quitEvent()
                }
            default:
                print("don't go to map")
                break
            }
        }
        tableView.deselectRow(at: indexPath, animated: false)
    }
}
