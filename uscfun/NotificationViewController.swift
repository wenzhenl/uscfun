//
//  NotificationViewController.swift
//  uscfun
//
//  Created by Wenzheng Li on 3/6/17.
//  Copyright © 2017 Wenzheng Li. All rights reserved.
//

import UIKit

struct NotificationUscFun {
    var title: String
    var content: String
    var eventId: String
    var isRead: Bool
}

class NotificationViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var notifications = [NotificationUscFun]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.view.backgroundColor = UIColor.white
        self.tableView.tableFooterView = UIView()
        self.tableView.separatorStyle = .none

//        notifications = [Notification(title: "完成活动",content: "下雨天出去滑个雪好不好",eventId: "1", isRead: false), Notification(title: "取消活动",content: "副教授积分的设计费束带结发世纪东方健康是福京东方快递费绝对是蒋介石",eventId: "2", isRead: false), Notification(title: "完成活动",content: "下雨天出去滑个雪好不好",eventId: "1", isRead: false)]
    }
}

extension NotificationViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if notifications.count == 0 {
            return 1
        }
        
        return notifications.count    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if notifications.count == 0 {
            let cell = Bundle.main.loadNibNamed("EmptySectionPlaceholderTableViewCell", owner: self, options: nil)?.first as! EmptySectionPlaceholderTableViewCell
            cell.mainTextView.text = "你好像还没有收到任何通知"
            cell.selectionStyle = .none
            return cell
        }
        else {
            let cell = Bundle.main.loadNibNamed("TitleContentTableViewCell", owner: self, options: nil)?.first as! TitleContentTableViewCell
            cell.clipsToBounds = true
            cell.titleLabel.text = notifications[indexPath.row].title
            cell.contentLabel.textAlignment = .left
            cell.contentLabel.text = notifications[indexPath.row].content
            cell.contentLabel.textColor = UIColor.darkText
            cell.backgroundColor = notifications[indexPath.row].isRead ? UIColor.clear : UIColor.lightGreen
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if notifications.count == 0 {
            return 0
        }
        return 1 / UIScreen.main.scale
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
            let px = 1 / UIScreen.main.scale
            let frame = CGRect(x: 0, y: 0, width: self.tableView.frame.size.width, height: px)
            let line = UIView(frame: frame)
            line.backgroundColor = self.tableView.separatorColor
            return line
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if notifications.count > 0 {
            notifications[indexPath.row].isRead = true
            tableView.cellForRow(at: indexPath)?.backgroundColor = UIColor.clear
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
