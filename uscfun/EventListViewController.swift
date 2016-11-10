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
        self.tableView.scrollsToTop = true
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

    func refreshMyOngoingEventsSilently() {
        EventRequest.fetchNewerDataForMyOngoingEvents(currentlyNewestUpdatedTime: EventRequest.newestUpdatedAtOfMyOngoingEvents) {
            error, events in
            if error != nil {
                return
            }
            
            if let events = events {
                for event in events {
                    EventRequest.indexOfMyOngoingEvents[event.objectId!] = event
                    
                    if event.updatedAt! > EventRequest.newestUpdatedAtOfMyOngoingEvents {
                        EventRequest.newestUpdatedAtOfMyOngoingEvents = event.updatedAt!
                    }
                    if event.updatedAt! < EventRequest.oldestUpdatedAtOfMyOngoingEvents {
                        EventRequest.oldestUpdatedAtOfMyOngoingEvents = event.updatedAt!
                    }
                }
                if events.count > 0 {
                    
                    EventRequest.myOngoingEvents = EventRequest.indexOfMyOngoingEvents.values.sorted {
                        if $0.isFinalized != $1.isFinalized {
                            return $0.isFinalized
                        }
                        return $0.due < $1.due
                    }
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    func handleRefresh() {
        
        self.refreshMyOngoingEventsSilently()
        
        EventRequest.fetchNewerDataForPublicEvents(currentlyNewestUpdatedTime: EventRequest.newestUpdatedAtOfPublicEvents) {
            error, events in
            if error != nil {
                self.refreshControl.endRefreshing()
                return
            }
            let numberOfPublicEventsBeforeUpdate = EventRequest.publicEvents.count
            if let events = events {
                for event in events {
                    EventRequest.indexOfPublicEvents[event.objectId!] = event
                    
                    if event.updatedAt! > EventRequest.newestUpdatedAtOfPublicEvents {
                        EventRequest.newestUpdatedAtOfPublicEvents = event.updatedAt!
                    }
                    if event.updatedAt! < EventRequest.oldestUpdatedAtOfPublicEvents {
                        EventRequest.oldestUpdatedAtOfPublicEvents = event.updatedAt!
                    }
                }
                
                if events.count > 0 {
                    
                    EventRequest.publicEvents = EventRequest.indexOfPublicEvents.values.sorted {
                        $0.due < $1.due
                    }
                    
                    let numberOfPublicEventsAfterUpdate = EventRequest.publicEvents.count
                    if numberOfPublicEventsAfterUpdate > numberOfPublicEventsBeforeUpdate {
                        self.showUpdateReminder(message: "发现了\(numberOfPublicEventsAfterUpdate - numberOfPublicEventsBeforeUpdate)个新的微活动")
                    }
                    self.tableView.reloadData()
                }
            }
            self.refreshControl.endRefreshing()
        }
    }

    func showUpdateReminder(message: String) {
 
        AudioServicesPlaySystemSound(1002)
        self.newEventReminderLabel.text = message
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
                        eventDetailVC.event = EventRequest.indexOfMyOngoingEvents[attendingCell.eventId]
                        eventDetailVC.delegate = self
                        
                    case is EventListTableViewCell:
                        let eventListCell = sender as! EventListTableViewCell
                        eventDetailVC.event = EventRequest.indexOfPublicEvents[eventListCell.eventId]
                        eventDetailVC.delegate = self
                    default:
                        break
                    }
                }
            case identifierToPostEvent:
                var destination = segue.destination
                if let nav = destination as? UINavigationController {
                    destination = nav.topViewController!
                }
                if let startEventVC = destination as? StartEventViewController {
                    startEventVC.delegate = self
                }
            default:
                break
            }
        }
    }
    
    let identifierToEventDetail = "go to event detail"
    let identifierToPostEvent = "go to post new event"
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

extension EventListViewController: EventMemberStatusDelegate {
    func userDidJoinEventWith(id: String) {
      self.handleRefresh()
    }
    
    func userDidQuitEventWith(id: String) {
        EventRequest.indexOfMyOngoingEvents.removeValue(forKey: id)
        EventRequest.myOngoingEvents = EventRequest.indexOfMyOngoingEvents.values.sorted {
            if $0.isFinalized != $1.isFinalized {
                return $0.isFinalized
            }
            return $0.due < $1.due
        }
        self.tableView.reloadData()
    }
    
    func userDidPostEvent() {
        self.refreshMyOngoingEventsSilently()
    }
}

extension EventListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if EventRequest.publicEvents.count == 0 {
            return 4
        }
        return 3 + EventRequest.publicEvents.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 {
            if EventRequest.myOngoingEvents.count == 0 {
                return 1
            } else {
                return EventRequest.myOngoingEvents.count
            }
        } else {
            return 1
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath as NSIndexPath).section == 1 && EventRequest.myOngoingEvents.count == 0 {
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
            if EventRequest.myOngoingEvents.count > 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "AttendingEventCell") as! AttendingEventTableViewCell
                let event = EventRequest.myOngoingEvents[indexPath.row]
                cell.eventId = event.objectId
                cell.selectionStyle = .default
                cell.nameTextView.text = event.name
                cell.eventImageView.image = event.type.image
                if event.isFinalized {
                    cell.indicatorView.backgroundColor = UIColor.eventFinalized
                }
                else if event.totalSeats - event.remainingSeats >= event.minimumAttendingPeople {
                    cell.indicatorView.backgroundColor = UIColor.eventMeetsMinimum
                }
                else {
                    cell.indicatorView.backgroundColor = UIColor.eventWaiting
                }
                
                return cell
            } else {
                let cell = Bundle.main.loadNibNamed("EmptySectionPlaceholderTableViewCell", owner: self, options: nil)?.first as! EmptySectionPlaceholderTableViewCell
                cell.mainTextView.text = "少年你好像还没有参加任何微活动，快去参加一波吧"
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
            if EventRequest.publicEvents.count > 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "EventListCell") as! EventListTableViewCell
                cell.selectionStyle = .blue
                let event = EventRequest.publicEvents[indexPath.section - 3]
                
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
        if !(tableView.cellForRow(at: indexPath) is EmptySectionPlaceholderTableViewCell) {
            performSegue(withIdentifier: self.identifierToEventDetail, sender: tableView.cellForRow(at: indexPath))
        }
        tableView.deselectRow(at: indexPath, animated: false)
    }
}
