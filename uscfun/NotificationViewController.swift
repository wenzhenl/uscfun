//
//  NotificationViewController.swift
//  uscfun
//
//  Created by Wenzheng Li on 3/6/17.
//  Copyright © 2017 Wenzheng Li. All rights reserved.
//

import UIKit
import ChatKit
import SVProgressHUD

struct NotificationUscFun {
    var title: String
    var content: String
    var eventId: String
    var isRead: Bool
}

class NotificationViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var notifications = [NotificationUscFun]()
    
    var conversation: AVIMConversation?
    
    var numberOfNewNotifications: Int = 0 {
        didSet {
            self.tabBarController?.tabBar.items![USCFunConstants.indexOfNotification].badgeValue = numberOfNewNotifications > 0 ? "\(numberOfNewNotifications)" : nil
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("Notification View Controller did load")
        
        self.navigationController?.view.backgroundColor = UIColor.white
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.tableView.tableFooterView = UIView()
        self.tableView.backgroundColor = UIColor.backgroundGray
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleNewMessageReceived(notification:)), name: NSNotification.Name(rawValue: LCCKNotificationMessageReceived), object: nil)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if conversation == nil {
            LCChatKit.sharedInstance().conversationService.fetchConversation(withPeerId: USCFunConstants.systemAdministratorClientId) {
                conversation, error in
                
                guard let conversation = conversation else {
                    if error != nil {
                        print("failed to fetch admin conversation \(error!)")
                    }
                    return
                }
                self.conversation = conversation
            }
        }
        self.tableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
    }
    
    func handleNewMessageReceived(notification: Notification) {
        
        print("new message received")
        
        
        guard let object = notification.object as? [String: Any], let conversation = object["conversation"] as? AVIMConversation else {
            print("failed to parse message received notification")
            return
        }
        
        if conversation.conversationId == self.conversation?.conversationId {
            self.numberOfNewNotifications = 1
        }
    }
    
    func checkNotification() {
        guard let conversationViewController = LCCKConversationViewController(peerId: USCFunConstants.systemAdministratorClientId) else {
            SVProgressHUD.showError(withStatus: "无法连接网络")
            return
        }
        conversationViewController.isEnableAutoJoin = true
        conversationViewController.hidesBottomBarWhenPushed = true
        conversationViewController.isDisableTitleAutoConfig = true
        conversationViewController.disablesAutomaticKeyboardDismissal = false
        conversationViewController.viewDidLoadBlock = {
            viewController in
            viewController?.navigationItem.title = "日常小管家"
            viewController?.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        }
        conversationViewController.viewDidAppearBlock = {
            (viewController, animated) in
            print("conversation controller view did appear")
            viewController?.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        }
        
        conversationViewController.viewWillDisappearBlock = {
            [unowned self](viewController, animated) in
            print("conversation controller view will disappear")
            viewController?.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
            SVProgressHUD.dismiss()
            self.numberOfNewNotifications = 0
        }
        
        self.navigationController?.pushViewController(conversationViewController, animated: true)
    }
}

extension NotificationViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if conversation?.lastMessage == nil {
            return self.tableView.frame.height - 44.0
        }
        
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 1 / UIScreen.main.scale
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if conversation?.lastMessage == nil {
            let cell = Bundle.main.loadNibNamed("EmptySectionPlaceholderTableViewCell", owner: self, options: nil)?.first as! EmptySectionPlaceholderTableViewCell
            cell.mainTextView.text = "你好像还没有收到任何通知"
            cell.selectionStyle = .none
            return cell
        }
        else {
            let cell = Bundle.main.loadNibNamed("ImageLabelTableViewCell", owner: self, options: nil)?.first as! ImageLabelTableViewCell
            cell.avatarImageView.image = #imageLiteral(resourceName: "officialAvatar")
            cell.nameLabel.text = "日常小管家"
            cell.messageLabel.text = conversation?.lastMessage?.shortDescription
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if conversation?.lastMessage != nil {
            checkNotification()
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
