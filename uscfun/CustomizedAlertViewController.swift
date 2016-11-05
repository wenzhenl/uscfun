//
//  CustomizedAlertViewController.swift
//  uscfun
//
//  Created by Wenzheng Li on 10/28/16.
//  Copyright © 2016 Wenzheng Li. All rights reserved.
//

import UIKit

protocol CustomizedAlertViewDelegate {
    func withdraw()
    func shareEventToWechatFriend()
    func shareEventToMoments()
    func reportEvent()
    func quitEvent()
}

enum CustomAlertType {
    case quitEvent
    case shareEvent
}

enum AlertCellType {
    case imgKeyValueCell(image: UIImage, key: String, value: String)
    case regularCell(text: String)
}

class CustomizedAlertViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var delegate: CustomizedAlertViewDelegate?
    var alertType: CustomAlertType!
    var alertSections = [AlertCellType]()
    
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = UIColor.backgroundGray
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(withdraw(sender:)))
        tapGesture.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapGesture)
        
        switch alertType! {
        case .quitEvent:
            alertSections.append(AlertCellType.imgKeyValueCell(image: #imageLiteral(resourceName: "remove"), key: keyOfQuitEvent, value: ""))
            alertSections.append(AlertCellType.imgKeyValueCell(image: #imageLiteral(resourceName: "cancel"), key: keyOfCancel, value: ""))
        case .shareEvent:
            alertSections.append(AlertCellType.imgKeyValueCell(image: #imageLiteral(resourceName: "wechat"), key: keyOfShareEventToWechatFriend, value: ""))
            alertSections.append(AlertCellType.imgKeyValueCell(image: #imageLiteral(resourceName: "moments"), key: keyOfShareEventToMoments, value: ""))
            alertSections.append(AlertCellType.imgKeyValueCell(image: #imageLiteral(resourceName: "bell"), key: keyOfReportEvent, value: ""))
            alertSections.append(AlertCellType.imgKeyValueCell(image: #imageLiteral(resourceName: "cancel"), key: keyOfCancel, value: ""))
        }
        tableView.translatesAutoresizingMaskIntoConstraints = true
        tableView.layoutIfNeeded()
        tableView.frame = CGRect(x: 0, y: self.view.frame.height - tableView.contentSize.height, width: self.view.frame.width, height: tableView.contentSize.height)
    }
    
    func withdraw(sender: UITapGestureRecognizer) {
        let tappedPoint = sender.location(in: self.view)
        if !tableView.frame.contains(tappedPoint) {
            self.delegate?.withdraw()
            self.presentingViewController?.dismiss(animated: true, completion: nil)
        }
    }
    
    let keyOfCancel = "取消"
    let keyOfQuitEvent = "退出微活动"
    let keyOfShareEventToWechatFriend = "分享给微信好友"
    let keyOfShareEventToMoments = "分享到朋友圈"
    let keyOfReportEvent = "举报该微活动"
}

extension CustomizedAlertViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 2
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch alertSections[indexPath.section] {
        case .imgKeyValueCell(_, let key, _):
            switch key {
            case keyOfCancel:
                self.delegate?.withdraw()
            case keyOfQuitEvent:
                self.delegate?.quitEvent()
            case keyOfShareEventToWechatFriend:
                self.delegate?.shareEventToWechatFriend()
            case keyOfShareEventToMoments:
                self.delegate?.shareEventToMoments()
            case keyOfReportEvent:
                self.delegate?.reportEvent()
            default:
                break
            }
        default:
            break
        }
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
}

extension CustomizedAlertViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return alertSections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch alertSections[indexPath.section] {
        case .imgKeyValueCell(let image, let key, let value):
            let cell = Bundle.main.loadNibNamed("ImgKeyValueTableViewCell", owner: self, options: nil)?.first! as! ImgKeyValueTableViewCell
            cell.mainImageView.image = image
            cell.keyLabel.text = key
            cell.valueLabel.text = value
            return cell
        case .regularCell(let text):
            let cell = UITableViewCell()
            cell.textLabel?.text = text
            return cell
        }
    }
}
