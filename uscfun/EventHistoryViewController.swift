//
//  EventHistoryViewController.swift
//  uscfun
//
//  Created by Wenzheng Li on 10/14/16.
//  Copyright © 2016 Wenzheng Li. All rights reserved.
//

import UIKit

enum EventHistorySource {
    case created
    case attended
}

class EventHistoryViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var eventHistorySource: EventHistorySource!
    var previousEvents = OrderedDictionary<String, Event>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.view.backgroundColor = UIColor.white
        self.tableView.backgroundColor = UIColor.backgroundGray
        tableView.tableFooterView = UIView()
        
        if eventHistorySource == .created {
            self.title = "我发起过的活动"
        } else {
            self.title = "我参加过的活动"
        }
        
        switch eventHistorySource! {
        case .created:
            EventRequest.fetchEventsCreated(by: AVUser.current()!) {
                error, events in
                if let events = events {
                    for event in events {
                        self.previousEvents[event.objectId!] = event
                    }
                }
                self.tableView.reloadData()
            }
        case .attended:
            EventRequest.fetchEventsAttended(by: AVUser.current()!) {
                error, events in
                if let events = events {
                    for event in events {
                        self.previousEvents[event.objectId!] = event
                    }
                }
                self.tableView.reloadData()
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
            case identifierToEventDetail:
                let destination = segue.destination
                if let edVC = destination as? EventDetailViewController {
                    edVC.event = previousEvents[previousEvents.keys[((tableView.indexPathForSelectedRow?.section)!)]]
                }
            default:
                break
            }
        }
    }
    
    let identifierToEventDetail = "go to event detail"
}

extension EventHistoryViewController: UITableViewDataSource, UITableViewDelegate{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if previousEvents.count == 0 {
            return 1
        }
        return previousEvents.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if previousEvents.count == 0 {
            let cell = Bundle.main.loadNibNamed("EmptySectionPlaceholderTableViewCell", owner: self, options: nil)?.first as! EmptySectionPlaceholderTableViewCell
            if eventHistorySource == .attended {
                cell.mainTextView.text = "用户还没有参加过任何活动"
            } else {
                cell.mainTextView.text = "用户还没有发起过任何活动"
            }
            cell.backgroundColor = UIColor.clear
            cell.selectionStyle = .none
            return cell
        } else {
            let cell = Bundle.main.loadNibNamed("EventSnapshotTableViewCell", owner: self, options: nil)?.first as! EventSnapshotTableViewCell
            var event: Event!
            event = previousEvents[previousEvents.keys[indexPath.section]]
            let creator = User(user: event.createdBy)!
            cell.eventNameLabel.text = event.name
            cell.creatorLabel.text = "发起人：" + creator.nickname
            cell.creatorAvatarImageView.layer.masksToBounds = true
            cell.creatorAvatarImageView.layer.cornerRadius = cell.creatorAvatarImageView.frame.size.width / 2.0
            cell.creatorAvatarImageView.image = creator.avatar
            
            cell.whitePaperImageView.image = event.whitePaper
            
            cell.needNumberLabel.text = String(event.remainingSeats)
            let gapFromNow = event.due.gapFromNow
            if gapFromNow == "" {
                cell.remainingTimeLabel.textColor = UIColor.darkGray
                cell.remainingTimeLabel.text = "报名已经结束"
            } else {
                cell.remainingTimeLabel.text = gapFromNow
            }
            cell.attendingLabel.text = "已经报名 " + String(event.maximumAttendingPeople - event.remainingSeats)
            cell.minPeopleLabel.text = "最少成行 " + String(event.minimumAttendingPeople)
            
            cell.statusView.backgroundColor = event.statusColor
            cell.statusView.layer.masksToBounds = true
            cell.statusView.layer.cornerRadius = cell.statusView.frame.size.width / 2
            cell.statusViewColor = event.statusColor
            
            cell.moreButton.isHidden = true
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if previousEvents.count == 0 {
            return self.tableView.frame.height
        }
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 300
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = UIColor.white
    }
    
    func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        view.tintColor = UIColor.clear
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if previousEvents.count > 0 {
            performSegue(withIdentifier: identifierToEventDetail, sender: self)
        }
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if previousEvents.count == 0 {
            return CGFloat.leastNormalMagnitude
        }
        return 1 / UIScreen.main.scale
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if previousEvents.count == 0 {
            return CGFloat.leastNormalMagnitude
        }
        return 10
    }
}
