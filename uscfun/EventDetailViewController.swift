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
    var detailCells = [[EventDetailCell]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationController!.navigationBar.barTintColor = UIColor.buttonBlue
        self.navigationController!.navigationBar.tintColor = UIColor.white
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareEvent))
        self.view.backgroundColor = UIColor.backgroundGray
        self.tableView.backgroundColor = UIColor.backgroundGray
        self.tableView.tableFooterView = UIView()
        self.tableView.contentInset = UIEdgeInsetsMake(10, 0, 0, 0)
        
        // Populate the cells
        if let event = event {
            let profileSection = [EventDetailCell.imageViewTableCell(image: #imageLiteral(resourceName: "launchscreen")), .textViewTableCell(text: event.name)]
            let joinButtonSection = [EventDetailCell.singleButtonTableCell]
            let chatSection = [EventDetailCell.imgKeyValueArrowTableCell(image: #imageLiteral(resourceName: "location"), key: "参与讨论", value: "")]
            detailCells.append(profileSection)
            detailCells.append(joinButtonSection)
            detailCells.append(chatSection)
            
            // handle optional information
            var optionalSection = [EventDetailCell]()
            if let startTime = event.startTime {
                optionalSection.append(EventDetailCell.imgKeyValueTableCell(image: #imageLiteral(resourceName: "alarm-clock"), key: "活动开始时间", value: startTime.description))
            }
            
            if let endTime = event.endTime {
                optionalSection.append(EventDetailCell.imgKeyValueTableCell(image: #imageLiteral(resourceName: "alarm-clock"), key: "活动结束时间", value: endTime.description))
            }
            
            if let locationName = event.locationName {
                 optionalSection.append(EventDetailCell.imgKeyValueArrowTableCell(image: #imageLiteral(resourceName: "location"), key: eventLocationKey, value: locationName))
            }
            
            if let expectedFee = event.expectedFee {
                optionalSection.append(EventDetailCell.imgKeyValueTableCell(image: #imageLiteral(resourceName: "location"), key: "预计费用", value: expectedFee.description))
            }
            
            if optionalSection.count > 0 {
                detailCells.append(optionalSection)
            }
            
            if let note = event.note {
                let noteSection = [EventDetailCell.textViewTableCell(text: note)]
                detailCells.append(noteSection)
            }
        }
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
    let mapSegueIdentifier = "SHOWMAP"
}

extension EventDetailViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return detailCells.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return detailCells[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch detailCells[indexPath.section][indexPath.row] {
        case .imageViewTableCell(let image):
            let cell = Bundle.main.loadNibNamed("ImageViewTableViewCell", owner: self, options: nil)?.first as! ImageViewTableViewCell
            cell.mainImageView.image = image
            return cell
        case .imgKeyValueTableCell(let image, let key, let value):
            let cell = Bundle.main.loadNibNamed("ImgKeyValueTableViewCell", owner: self, options: nil)?.first as! ImgKeyValueTableViewCell
            cell.mainImageView.image = image
            cell.keyLabel.text = key
            cell.valueLabel.text = value
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
            return cell
        case .textViewTableCell(let text):
            let cell = Bundle.main.loadNibNamed("TextViewTableViewCell", owner: self, options: nil)?.first as! TextViewTableViewCell
            cell.textView.text = text
            return cell
        }
    }
}

extension EventDetailViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch detailCells[indexPath.section][indexPath.row] {
        case .imageViewTableCell(_):
            return 200
        default:
            return UITableViewAutomaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        switch detailCells[indexPath.section][indexPath.row] {
        case .imageViewTableCell(_):
            return 200
        default:
            return UITableViewAutomaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        switch detailCells[indexPath.section][indexPath.row] {
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
        return 30
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 2 {
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
            switch detailCells[indexPath.section][indexPath.row] {
            case .imgKeyValueArrowTableCell(_, let key, _):
                print("go to map")
                if key == eventLocationKey {
                    performSegue(withIdentifier: mapSegueIdentifier, sender: self)
                }
            default:
                print("don't go to map")
                break
            }
        }
        tableView.deselectRow(at: indexPath, animated: false)
    }
}
