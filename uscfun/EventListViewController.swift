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
        self.tableView.backgroundColor = UIColor.backgroundGray
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 120, 0)
        self.view.bringSubview(toFront: startEventButton)
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
        
        EventRequest.loadNewerData {
            numberOfNewUpdates in
            self.showUpdateReminder(numberOfNewUpdates: numberOfNewUpdates)
            self.tableView.reloadData()
        }
        
        self.refreshControl.endRefreshing()
    }
    
    func handleLoadMoreData() {
        EventRequest.loadOlderData {
            numberOfNewUpdates in
            self.showUpdateReminder(numberOfNewUpdates: numberOfNewUpdates)
            self.tableView.reloadData()
        }
    }
    
    func showUpdateReminder(numberOfNewUpdates: Int) {
        
        guard numberOfNewUpdates >= 0 else {
            return
        }
        AudioServicesPlaySystemSound(1002)
        if numberOfNewUpdates > 0 {
            self.newEventReminderLabel.text = "更新了\(numberOfNewUpdates)个小活动"
        } else {
            self.newEventReminderLabel.text = "没有更新的小活动"
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
                        eventDetailVC.event = EventRequest.eventsCurrentUserIsIn[(self.tableView.indexPathForSelectedRow?.row)!]
                    case is EventListTableViewCell:
                        eventDetailVC.event = EventRequest.events[(self.tableView.indexPathForSelectedRow?.section)! - 3]
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

extension EventListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath as NSIndexPath).section == 0  || (indexPath as NSIndexPath).section == 1 {
            return 44
        } else if (indexPath as NSIndexPath).section == 2 && (indexPath as NSIndexPath).row == 0 {
            return 44
        }
        return 250
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3 + EventRequest.events.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 {
            return EventRequest.eventsCurrentUserIsIn.count
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath as NSIndexPath).section == 0 {
            let cell = UITableViewCell()
            cell.textLabel?.text = "我加入的活动"
            cell.selectionStyle = .none
            return cell
        }
        
        else if (indexPath as NSIndexPath).section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AttendingEventCell") as! AttendingEventTableViewCell
            let event = EventRequest.eventsCurrentUserIsIn[indexPath.row]
            cell.selectionStyle = .none
            cell.nameTextView.text = event.name
            cell.eventImageView.image = event.type.image
            return cell
        }
            
        else if (indexPath as NSIndexPath).section == 2 {
            let cell = UITableViewCell()
            cell.textLabel?.text = "当前活动列表"
            cell.selectionStyle = .none
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "EventListCell") as! EventListTableViewCell
            cell.selectionStyle = .none
            let event = EventRequest.events[indexPath.section - 3]
            cell.mainImageView.image = event.type.image
            cell.nameTextView.text = event.name
            cell.startTimeLabel.text = event.startTime?.description
            cell.locationNameLabel.text = event.locationName
            cell.due = event.due
            cell.timerStarted()
            return cell
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
