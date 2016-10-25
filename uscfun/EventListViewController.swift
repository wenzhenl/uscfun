//
//  EventListViewController.swift
//  uscfun
//
//  Created by Wenzheng Li on 9/3/16.
//  Copyright © 2016 Wenzheng Li. All rights reserved.
//

import UIKit

class EventListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var startEventButton: UIButton!
    @IBOutlet weak var leftStartEventButton: UIButton!
    @IBOutlet weak var newEventReminderView: UIView!
    @IBOutlet weak var newEventReminderLabel: UILabel!
    
    @IBOutlet weak var newEventReminderViewConstraint: NSLayoutConstraint!
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: UIControlEvents.valueChanged)
        return refreshControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.backgroundGray
        self.startEventButton.layer.cornerRadius = startEventButton.frame.size.height / 2.0
        self.leftStartEventButton.layer.cornerRadius = leftStartEventButton.frame.size.height / 2.0
        self.tableView.backgroundColor = UIColor.backgroundGray
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 60, 0)
        self.view.bringSubview(toFront: startEventButton)
        self.view.bringSubview(toFront: leftStartEventButton)
        if UserDefaults.isLefthanded {
            self.startEventButton.isHidden = true
        } else {
            self.leftStartEventButton.isHidden = true
        }
        self.tableView.addSubview(self.refreshControl)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.newEventReminderView.layer.cornerRadius = newEventReminderView.frame.size.height / 2.0
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func handleRefresh() {
        
        EventRequest.fetchNewer(currentlyNewestUpdatedTime: EventRequest.newestUpdatedAt) {
            error, events in
            if error != nil {
                self.showUpdateReminder(message: error!.localizedDescription, numberOfNewUpdates: 0)
                return
            }
            
            let numberOfEventsBeforeUpdate = EventRequest.events.count + EventRequest.myEvents.count
            if let events = events {
                for event in events {
                    if event.active {
                        if let index = EventRequest.indexOfEvents[event.objectId!] {
                            EventRequest.events[index] = event
                        } else {
                            EventRequest.events.append(event)
                            EventRequest.indexOfEvents[event.objectId!] = EventRequest.events.count - 1
                        }
                    }
                    
                    if event.members.contains(AVUser.current()) {
                        if let index = EventRequest.indexOfMyEvents[event.objectId!] {
                            EventRequest.myEvents[index] = event
                        } else {
                            EventRequest.myEvents.append(event)
                            EventRequest.indexOfMyEvents[event.objectId!] = EventRequest.myEvents.count - 1
                        }
                    }

                    if event.updatedAt! > EventRequest.newestUpdatedAt {
                        EventRequest.newestUpdatedAt = event.updatedAt!
                    }
                    if event.updatedAt! < EventRequest.oldestUpdatedAt {
                        EventRequest.oldestUpdatedAt = event.updatedAt!
                    }
                }
            }
            let numberOfEventsAfterUpdate = EventRequest.events.count + EventRequest.myEvents.count
            if numberOfEventsBeforeUpdate == numberOfEventsAfterUpdate {
                self.showUpdateReminder(message: "没有发现新的微活动", numberOfNewUpdates: 0)
            }
        }
        
        self.refreshControl.endRefreshing()
    }

    func showUpdateReminder(message: String, numberOfNewUpdates: Int) {
        
        guard numberOfNewUpdates >= 0 else {
            return
        }
        
        if numberOfNewUpdates > 0 {
            AudioServicesPlaySystemSound(1002)
            self.newEventReminderLabel.text = "更新了\(numberOfNewUpdates)个微活动"
        } else {
            self.newEventReminderLabel.text = message
        }
        UIView.animate(withDuration: 1.0) {
            _ in
            self.newEventReminderViewConstraint.constant = 8
        }
        
        let delay = 1.5 * Double(NSEC_PER_SEC)
        let time = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: time) {
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
                _ in
                self.newEventReminderViewConstraint.constant = -35
                }, completion: nil)
        }

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
            case identifierToEventDetail:
                let destination = segue.destination
                if let eventDetailVC = destination as? EventDetailViewController {
                    switch sender {
                    case is AttendingEventTableViewCell:
                        let attendingCell = sender as! AttendingEventTableViewCell
                        let index = EventRequest.indexOfMyEvents[attendingCell.eventId]
                        eventDetailVC.event = EventRequest.myEvents[index!]
                        
                    case is EventListTableViewCell:
                        let eventListCell = sender as! EventListTableViewCell
                        let index = EventRequest.indexOfEvents[eventListCell.eventId]
                        eventDetailVC.event = EventRequest.events[index!]
                    default:
                        break
                    }
                }
            default:
                break
            }
        }
    }
    
    let identifierToEventDetail = "go to event detail"
}

extension EventListViewController: UserSettingDelegate {
    func userDidChangeLefthandMode() {
        if UserDefaults.isLefthanded {
            self.leftStartEventButton.isHidden = false
            self.startEventButton.isHidden = true
        } else {
            self.leftStartEventButton.isHidden = true
            self.startEventButton.isHidden = false
        }
    }
}

extension EventListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if EventRequest.events.count == 0 {
            return 4
        }
        return 3 + EventRequest.events.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 {
            if EventRequest.myEvents.count == 0 {
                return 1
            } else {
                return EventRequest.myEvents.count
            }
        } else {
            return 1
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath as NSIndexPath).section == 1 && EventRequest.myEvents.count == 0 {
            return 150
        }
        if (indexPath as NSIndexPath).section == 0  || (indexPath as NSIndexPath).section == 1 {
            return 44
        }
        else if (indexPath as NSIndexPath).section == 2 && (indexPath as NSIndexPath).row == 0 {
            return 44
        }
        return 270
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath as NSIndexPath).section == 0 {
            let cell = UITableViewCell()
            cell.textLabel?.text = "我加入的微活动"
            cell.selectionStyle = .none
            return cell
        }
        
        else if (indexPath as NSIndexPath).section == 1 {
            if EventRequest.myEvents.count > 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "AttendingEventCell") as! AttendingEventTableViewCell
                let event = EventRequest.myEvents[indexPath.row]
                cell.eventId = event.objectId
                cell.selectionStyle = .default
                cell.nameTextView.text = event.name
                cell.eventImageView.image = event.type.image
                return cell
            } else {
                let cell = Bundle.main.loadNibNamed("EmptySectionPlaceholderTableViewCell", owner: self, options: nil)?.first as! EmptySectionPlaceholderTableViewCell
                cell.mainTextView.text = "少年你今天好像还没有参加任何微活动，快去参加一波吧"
                cell.selectionStyle = .none
                return cell
            }
        }
            
        else if (indexPath as NSIndexPath).section == 2 {
            let cell = UITableViewCell()
            cell.textLabel?.text = "当前微活动列表"
            cell.selectionStyle = .none
            return cell
        }
        
        else {
            if EventRequest.events.count > 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "EventListCell") as! EventListTableViewCell
                cell.selectionStyle = .none
                let event = EventRequest.events[indexPath.section - 3]
                cell.eventId = event.objectId
                cell.mainImageView.image = event.type.image
                cell.creatorImageView.image = User(user: event.creator)?.avatar
                cell.nameTextView.text = event.name
                cell.startTimeLabel.text = event.startTime?.humanReadable ?? "待定"
                cell.locationNameLabel.text = event.locationName ?? "待定"
                cell.headCountLabel.text = "已参加\(event.totalSeats - event.remainingSeats)人，目标\(event.totalSeats)人"
                cell.due = event.due
                cell.timeLabel.text = "报名截止还有\(event.due.gapFromNow)"
                cell.timerStarted()
                return cell
            } else {
                let cell = Bundle.main.loadNibNamed("EmptySectionPlaceholderTableViewCell", owner: self, options: nil)?.first as! EmptySectionPlaceholderTableViewCell
                cell.mainTextView.text = "好像微活动都被参加完了，少年快去发起一波吧！"
                cell.selectionStyle = .none
                return cell
            }
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = UIColor.clear
        if ((indexPath as NSIndexPath).section == 0 && (indexPath as NSIndexPath).row == 0) || ((indexPath as NSIndexPath).section == 2 && (indexPath as NSIndexPath).row == 0) {
            cell.textLabel?.font = UIFont.systemFont(ofSize: 13)
            cell.textLabel?.textColor = UIColor.lightGray
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 0 {
            return 5
        }
        if section == 2 {
            return 5
        }
        return 15
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = UIColor.clear
        let title = UILabel()
        title.font = UIFont(name: "Futura", size: 10)!
        title.textColor = UIColor.lightGray
        
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.font=title.font
        header.textLabel?.textColor=title.textColor
        header.textLabel?.textAlignment = .left
    }
    
    func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        view.tintColor = UIColor.clear
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
}
