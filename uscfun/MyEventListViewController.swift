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
    
    let emptyPlaceholder = "你好像还没有参加任何微活动，快去参加一波吧！"
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: UIControlEvents.valueChanged)
        return refreshControl
    }()
    
    var infoLabel: UILabel!
    let heightOfInfoLabel = CGFloat(46.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.scrollsToTop = true
        self.tableView.addSubview(self.refreshControl)
        if EventRequest.myOngoingEvents.count > 0 {
            self.tableView.backgroundColor = UIColor.backgroundGray
        } else {
            self.tableView.backgroundColor = UIColor.white
        }
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, -10, 0)
        self.tableView.tableFooterView = UIView()
        self.tableView.separatorStyle = .none
        NotificationCenter.default.addObserver(self, selector: #selector(handleTab), name: NSNotification.Name(rawValue: "homeRefresh"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handlePostNewEvent), name: NSNotification.Name(rawValue: "userDidPostNewEvent"), object: nil)
        
        infoLabel = UILabel(frame: CGRect(x: 0.0, y: -heightOfInfoLabel, width: view.frame.size.width, height: heightOfInfoLabel))
        infoLabel.numberOfLines = 0
        infoLabel.textAlignment = .center
        infoLabel.lineBreakMode = .byWordWrapping
        infoLabel.font = UIFont.boldSystemFont(ofSize: 16)
        infoLabel.isHidden = true
        view.addSubview(infoLabel)
        
        /// important for animation to work properly
        self.navigationController?.navigationBar.isTranslucent = false
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        infoLabel.isHidden = true
        infoLabel.frame.origin = CGPoint.zero
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func handleTab() {
        self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
    }
    
    func handlePostNewEvent() {
        self.refreshControl.beginRefreshing()
        handleRefresh()
    }
    
    func handleRefresh() {
        let numberOfMyOngoingEventsBeforeUpdate = EventRequest.myOngoingEvents.count
        EventRequest.fetchNewerMyOngoingEventsInBackground() {
            succeeded, error in
            if succeeded {
                if EventRequest.myOngoingEvents.count > 0 {
                    self.tableView.backgroundColor = UIColor.backgroundGray
                } else {
                    self.tableView.backgroundColor = UIColor.white
                }
                let numberOfMyOngoingEventsAfterUpdate = EventRequest.myOngoingEvents.count
                if numberOfMyOngoingEventsAfterUpdate > numberOfMyOngoingEventsBeforeUpdate {
                    self.displayInfo(info: "发现了\(numberOfMyOngoingEventsAfterUpdate - numberOfMyOngoingEventsBeforeUpdate)个新的微活动")
                } else {
                    self.displayInfo(info: "没有更新的微活动了")
                }
                self.tableView.reloadData()
            }
            else if error != nil {
                self.displayInfo(info: error!.localizedDescription)
            }
            self.refreshControl.endRefreshing()
        }
    }
    
    func displayInfo(info: String) {
        self.infoLabel.isHidden = false
        self.infoLabel.backgroundColor = UIColor.white
        self.infoLabel.textColor = UIColor.buttonPink
        self.infoLabel.text = info
        
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseInOut, animations: {
            _ in
            self.infoLabel.frame.origin.y = 0.0
            self.view.layoutIfNeeded()
        }) {
            completed in
            if completed {
                let delay = 1.5 * Double(NSEC_PER_SEC)
                let time = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC)
                DispatchQueue.main.asyncAfter(deadline: time) {
                    UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseInOut, animations: {
                        _ in
                        self.infoLabel.frame.origin.y = -self.heightOfInfoLabel
                        self.view.layoutIfNeeded()
                    }) {
                        finished in
                        if finished {
                            self.infoLabel.isHidden = true
                        }
                    }
                }
            }
        }
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
            cell.mainTextView.text = emptyPlaceholder
            cell.backgroundColor = UIColor.clear
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
            cell.selectionStyle = .none
            return cell
        }
        else {
            let event = EventRequest.myOngoingEvents[EventRequest.myOngoingEvents.keys[indexPath.section - 1]]!
            let cell = Bundle.main.loadNibNamed("EventSnapshotTableViewCell", owner: self, options: nil)?.first as! EventSnapshotTableViewCell
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
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if EventRequest.myOngoingEvents.count == 0 {
            return 0
        }
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
        if EventRequest.myOngoingEvents.count == 0 {
            return 0
        }
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
            return UIColor.darkGray
        }
    }
    
    var whitePaper: UIImage {
        let possibleWhitePapers = [#imageLiteral(resourceName: "clip4"), #imageLiteral(resourceName: "clip1"), #imageLiteral(resourceName: "clip2"), #imageLiteral(resourceName: "clip3")]
        if let index = self.objectId?.hash {
            return possibleWhitePapers[abs(index) % possibleWhitePapers.count]
        }
        return possibleWhitePapers[0]
    }
}
