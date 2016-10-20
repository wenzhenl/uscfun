//
//  EventListViewController.swift
//  uscfun
//
//  Created by Wenzheng Li on 9/3/16.
//  Copyright © 2016 Wenzheng Li. All rights reserved.
//

import UIKit

class EventListViewController: UIViewController {

    @IBOutlet weak var buttonContainerView: UIView!
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var startEventButton: UIButton!
    @IBOutlet weak var newEventReminderView: UIView!
    @IBOutlet weak var newEventReminderLabel: UILabel!
    
    var delegate: MainViewControllerDelegate?
    
    var events = [Event]()
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: UIControlEvents.valueChanged)
        return refreshControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("EVENT LIST VIEW DID LOAD")
        
        self.view.backgroundColor = UIColor.backgroundGray
        self.startEventButton.layer.cornerRadius = startEventButton.frame.size.height / 2.0
        self.tableView.backgroundColor = UIColor.backgroundGray
//        self.tableView.contentInset = UIEdgeInsetsMake(10, 0, 0, 0)

        self.view.bringSubview(toFront: startEventButton)
        self.tableView.addSubview(self.refreshControl)
        self.newEventReminderView.isHidden = true
        
//        EventRequest.fetch() {
//            error, results in
//            if error != nil {
//                print(error)
//                return
//            }
//            if let events = results {
//                for event in events {
//                    self.events.append(event)
//                }
//                self.events.sort {
//                    $0.updatedAt! > $1.updatedAt!
//                }
//                self.tableView.reloadData()
//            }
//        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.leftButton.layer.cornerRadius = leftButton.frame.size.height / 2.0
        self.rightButton.layer.cornerRadius = rightButton.frame.size.height / 2.0
        self.leftButton.backgroundColor = UIColor.buttonBlue
        self.rightButton.backgroundColor = UIColor.buttonPink
        self.newEventReminderView.layer.cornerRadius = newEventReminderView.frame.size.height / 2.0
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func goToMessage(_ sender: UIButton) {
        delegate?.goToMessage()
    }
    
    @IBAction func goToMe(_ sender: UIButton) {
        delegate?.goToMe()
    }
    
    func handleRefresh() {
        if events.count == 0 {
            EventRequest.fetch() {
                error, results in
                if error != nil {
                    print(error)
                    return
                }
                if let events = results {
                    for event in events {
                        self.events.append(event)
                    }
                    self.events.sort {
                        $0.updatedAt! > $1.updatedAt!
                    }
                    AudioServicesPlaySystemSound(1002)
                    self.newEventReminderLabel.text = "更新了\(results!.count)个小活动"
                    UIView.animate(withDuration: 1.0) {
                        _ in
                        self.newEventReminderView.isHidden = false
//                        self.newEventReminderView.isHidden = true
                    }

                    self.tableView.reloadData()
                }
            }
        } else {
            EventRequest.fetchNewer(currentlyNewestUpdatedTime: self.events.last!.updatedAt!) {
                error, results in
                if error != nil {
                    print(error)
                    return
                }
                if let events = results {
                    for event in events {
                        self.events.append(event)
                    }
                    self.events.sort {
                        $0.updatedAt! > $1.updatedAt!
                    }
                    self.tableView.reloadData()
                }
            }
        }
        self.refreshControl.endRefreshing()
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
            case identifierToEventDetail:
                let destination = segue.destination
                if let eventDetailVC = destination as? EventDetailViewController {
                    switch sender {
                    case is AttendingEventTableViewCell:
                        eventDetailVC.event = self.events[(self.tableView.indexPathForSelectedRow?.row)! - 1]
                    case is EventListTableViewCell:
                        eventDetailVC.event = self.events[(self.tableView.indexPathForSelectedRow?.section)! - 2]
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
        if (indexPath as NSIndexPath).section == 0 {
            return UITableViewAutomaticDimension
        } else if (indexPath as NSIndexPath).section == 1 && (indexPath as NSIndexPath).row == 0 {
            return UITableViewAutomaticDimension
        }
        return 250
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath as NSIndexPath).section == 0 {
            return UITableViewAutomaticDimension
        } else if (indexPath as NSIndexPath).section == 1 && (indexPath as NSIndexPath).row == 0 {
            return UITableViewAutomaticDimension
        }
        return 250
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2 + events.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 5
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath as NSIndexPath).section == 0 {
            if (indexPath as NSIndexPath).row == 0 {
                let cell = UITableViewCell()
                cell.textLabel?.text = "我加入的活动"
                cell.selectionStyle = .none
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "AttendingEventCell") as! AttendingEventTableViewCell
                cell.selectionStyle = .none
                return cell
            }
        } else if (indexPath as NSIndexPath).section == 1 {
            let cell = UITableViewCell()
            cell.textLabel?.text = "当前活动列表"
            cell.selectionStyle = .none
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "EventListCell") as! EventListTableViewCell
            cell.selectionStyle = .none
            let event = events[indexPath.section - 2]
            cell.nameLabel.text = event.name
            cell.startTimeLabel.text = event.startTime?.description
            cell.locationNameLabel.text = event.locationName
            cell.due = event.due
            cell.timerStarted()
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = UIColor.clear
        if ((indexPath as NSIndexPath).section == 0 && (indexPath as NSIndexPath).row == 0) || ((indexPath as NSIndexPath).section == 1 && (indexPath as NSIndexPath).row == 0) {
            cell.textLabel?.font = UIFont.systemFont(ofSize: 13)
            cell.textLabel?.textColor = UIColor.lightGray
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 15
    }
    
    //    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    //        if section == 0 {
    //            return 15
    //        }
    //        else if section == 1 {
    //            return 15
    //        } else {
    //            return 0
    //        }
    //    }
    
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
    
    //    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    //        if section == 0 {
    //            return "我加入的活动"
    //        }
    //        else if section == 1 {
    //            return "当前活动列表"
    //        } else {
    //            return nil
    //        }
    //    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
}
