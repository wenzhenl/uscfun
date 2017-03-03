//
//  MyEventListViewController.swift
//  uscfun
//
//  Created by Wenzheng Li on 3/1/17.
//  Copyright © 2017 Wenzheng Li. All rights reserved.
//

import UIKit

class MyEventListViewController: UIViewController {

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
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, -10, 0)
        self.tableView.tableFooterView = UIView()
    }

    func handleRefresh() {
        EventRequest.fetchNewerMyOngoingEventsInBackground() {
            succeeded, error in
            if succeeded {
                self.tableView.reloadData()
            }
        }
        let numberOfPublicEventsBeforeUpdate = EventRequest.myOngoingEvents.count
        EventRequest.fetchNewerPublicEventsInBackground() {
            succeeded, error in
            if error != nil {
                self.showUpdateReminder(message: error!.localizedDescription)
            }
            else if succeeded {
                let numberOfPublicEventsAfterUpdate = EventRequest.myOngoingEvents.count
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
    
    let identifierToEventDetail = "go to event detail for my events"
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
            case identifierToEventDetail:
                let destination = segue.destination
                if let edVC = destination as? EventDetailViewController {
                    edVC.event = EventRequest.myOngoingEvents[EventRequest.myOngoingEvents.keys[((tableView.indexPathForSelectedRow?.section)! - 1)]]
                }
            default:
                break
            }
        }
    }
}

extension MyEventListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if EventRequest.myOngoingEvents.count == 0 {
            return 1
        }
        
        return EventRequest.myOngoingEvents.count + 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if EventRequest.myOngoingEvents.count == 0 {
            return 150
        }
        
        if indexPath.section == 0 {
            return 44
        }
        
        return 270
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if EventRequest.myOngoingEvents.count == 0 {
            let cell = Bundle.main.loadNibNamed("EmptySectionPlaceholderTableViewCell", owner: self, options: nil)?.first as! EmptySectionPlaceholderTableViewCell
            cell.mainTextView.text = "你好像还没有参加任何微活动，快去参加一波吧！"
            cell.selectionStyle = .none
            return cell
        }
        else if indexPath.section == 0 {
            let cell = Bundle.main.loadNibNamed("EventStatusTableViewCell", owner: self, options: nil)?.first as! EventStatusTableViewCell
            cell.pendingView.layer.masksToBounds = true
            cell.pendingView.layer.cornerRadius = cell.pendingView.frame.size.width / 2.0
            cell.securedView.layer.masksToBounds = true
            cell.securedView.layer.cornerRadius = cell.securedView.frame.size.width / 2.0
            cell.finalizedView.layer.masksToBounds = true
            cell.finalizedView.layer.cornerRadius = cell.finalizedView.frame.size.width / 2.0
            return cell
        }
        else {
            let event = EventRequest.myOngoingEvents[EventRequest.myOngoingEvents.keys[indexPath.section - 1]]!
            let cell = Bundle.main.loadNibNamed("EventSnapshotTableViewCell", owner: self, options: nil)?.first as! EventSnapshotTableViewCell
            let creator = User(user: event.creator)!
            cell.eventNameLabel.text = event.name
            cell.creatorLabel.text = "发起人：" + creator.nickname
            cell.creatorAvatarImageView.layer.masksToBounds = true
            cell.creatorAvatarImageView.layer.cornerRadius = cell.creatorAvatarImageView.frame.size.width / 2.0
            cell.creatorAvatarImageView.image = creator.avatar
            
            let possibleWhitePapers = [#imageLiteral(resourceName: "clip4"), #imageLiteral(resourceName: "clip1"), #imageLiteral(resourceName: "clip2"), #imageLiteral(resourceName: "clip3")]
            let randomIndex = Int(arc4random_uniform(UInt32(possibleWhitePapers.count)))
            cell.whitePaperImageView.image = possibleWhitePapers[randomIndex]
            
            cell.needNumberLabel.text = String(event.remainingSeats)
            cell.remainingTimeLabel.text = event.due.gapFromNow
            
            cell.attendingLabel.text = "已经报名 " + String(event.totalSeats - event.remainingSeats)
            cell.minPeopleLabel.text = "最少成行 " + String(event.minimumAttendingPeople)
            
            cell.statusView.backgroundColor = event.statusColor
            cell.statusView.layer.masksToBounds = true
            cell.statusView.layer.cornerRadius = cell.statusView.frame.size.width / 2
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
        return 10
    }
    
    func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        view.tintColor = UIColor.clear
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if EventRequest.myOngoingEvents.count > 0 && indexPath.section > 0 {
            performSegue(withIdentifier: identifierToEventDetail, sender: self)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension Event {
    var statusColor: UIColor {
        switch self.status {
        case .isPending:
            return UIColor.eventPending
        case .isSecured:
            return UIColor.eventSecured
        case .isFinalized:
            return UIColor.eventFinalized
        default:
            return UIColor.lightGray
        }
    }
}
