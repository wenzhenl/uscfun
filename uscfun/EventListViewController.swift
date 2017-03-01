//
//  EventListViewController.swift
//  uscfun
//
//  Created by Wenzheng Li on 9/3/16.
//  Copyright © 2016 Wenzheng Li. All rights reserved.
//

import UIKit
import ChatKit
import SVProgressHUD

protocol SystemNotificationDelegate {
    func systemDidUpdateExistingEvents(ids: [String])
    func systemDidUpdateNewEvents()
}

class EventListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: UIControlEvents.valueChanged)
        return refreshControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.scrollsToTop = true
        self.tableView.addSubview(self.refreshControl)
        self.tableView.backgroundColor = UIColor.backgroundGray
        self.tableView.tableFooterView = UIView()
        AppDelegate.systemNotificationDelegate = self
    }

    func handleRefresh() {
        EventRequest.fetchNewerMyOngoingEventsInBackground() {
            succeeded, error in
            if succeeded {
                self.tableView.reloadData()
            }
        }
        let numberOfPublicEventsBeforeUpdate = EventRequest.publicEvents.count
        EventRequest.fetchNewerPublicEventsInBackground() {
            succeeded, error in
            if error != nil {
                self.showUpdateReminder(message: error!.localizedDescription)
            }
            else if succeeded {
                let numberOfPublicEventsAfterUpdate = EventRequest.publicEvents.count
                if numberOfPublicEventsAfterUpdate > numberOfPublicEventsBeforeUpdate {
                    self.showUpdateReminder(message: "发现了\(numberOfPublicEventsAfterUpdate - numberOfPublicEventsBeforeUpdate)个新的微活动")
                }
                self.tableView.reloadData()
            }
            self.refreshControl.endRefreshing()
        }
    }
    
    func showUpdateReminder(message: String) {
    }
    let identifierToEventDetail = "go to event detail"
    let identifierToPostEvent = "go to post new event"
}

extension EventListViewController: UserSettingDelegate {
    func userDidChangeLefthandMode() {
    }
}

extension EventListViewController: EventMemberStatusDelegate {
    func userDidJoinEventWith(id: String) {
        EventRequest.myOngoingEvents[id] = EventRequest.publicEvents[id]
        EventRequest.publicEvents[id] = nil
        self.tableView.reloadData()
    }
    
    func userDidQuitEventWith(id: String) {
        EventRequest.publicEvents[id] = EventRequest.myOngoingEvents[id]
        EventRequest.myOngoingEvents[id] = nil
        self.tableView.reloadData()
    }
    
    func userDidPostEvent() {
        EventRequest.fetchNewerMyOngoingEventsInBackground() {
            _ in
            self.tableView.reloadData()
        }
    }
}

extension EventListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if EventRequest.publicEvents.count == 0 {
            return 1
        }
        
        return EventRequest.publicEvents.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
 
        if EventRequest.publicEvents.count == 0 {
            return 150
        }
        return 270
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if EventRequest.publicEvents.count == 0 {
            let cell = Bundle.main.loadNibNamed("EmptySectionPlaceholderTableViewCell", owner: self, options: nil)?.first as! EmptySectionPlaceholderTableViewCell
            cell.mainTextView.text = "好像微活动都被参加完了，少年快去发起一波吧！"
            cell.selectionStyle = .none
            return cell
        } else {
            let event = EventRequest.publicEvents[EventRequest.publicEvents.keys[indexPath.section]]!
            let cell = Bundle.main.loadNibNamed("EventSnapshotTableViewCell", owner: self, options: nil)?.first as! EventSnapshotTableViewCell
            let creator = User(user: event.creator)!
            cell.eventNameLabel.text = event.name
            cell.creatorLabel.text = "发起人：" + creator.nickname
            cell.creatorAvatarImageView.layer.masksToBounds = true
            cell.creatorAvatarImageView.layer.cornerRadius = cell.creatorAvatarImageView.frame.size.width / 2.0
            cell.creatorAvatarImageView.image = creator.avatar
            cell.selectionStyle = .none
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 1 / UIScreen.main.scale
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let px = 1 / UIScreen.main.scale
        let frame = CGRect(x: 0, y: 0, width: self.tableView.frame.size.width, height: px)
        let line = UIView(frame: frame)
        line.backgroundColor = self.tableView.separatorColor
        return line
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == EventRequest.publicEvents.count - 1 {
            return 0
        }
        return 10
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let px = 1 / UIScreen.main.scale
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.frame.size.width, height: 10 + px))
        let frame = CGRect(x: 0, y: 0, width: self.tableView.frame.size.width, height: px)
        let line = UIView(frame: frame)
        line.backgroundColor = self.tableView.separatorColor
        footerView.addSubview(line)
        return footerView
    }
}

extension EventListViewController: SystemNotificationDelegate {
    func systemDidUpdateExistingEvents(ids: [String]) {
        print("updating existing events")
        EventRequest.fetchEvents(inBackground: true, with: ids) {
            succeeded, error in
            if succeeded {
                self.tableView.reloadData()
            } else if error != nil {
                print(error!.localizedDescription)
            }
        }
    }
    
    func systemDidUpdateNewEvents() {
        print("new events coming")
    }
}
