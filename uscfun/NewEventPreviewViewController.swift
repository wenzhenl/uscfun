//
//  NewEventPreviewViewController.swift
//  uscfun
//
//  Created by Wenzheng Li on 3/1/17.
//  Copyright © 2017 Wenzheng Li. All rights reserved.
//

import UIKit
import AVOSCloud
import SVProgressHUD

enum PreviewCell {
    case headerCell
    case startTimeCell
    case endTimeCell
    case locationCell
    case mapCell
    case noteCell
}

class NewEventPreviewViewController: UIViewController {

    @IBOutlet weak var postButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    
    var previewSections = [PreviewCell]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 100, 0)
        self.tableView.tableFooterView = UIView()
        self.populateSections()
    }

    func populateSections() {
        previewSections.append(PreviewCell.headerCell)
        if UserDefaults.newEventStartTime > Date() {
            previewSections.append(PreviewCell.startTimeCell)
        }
        if UserDefaults.newEventEndTime > Date() && UserDefaults.newEventEndTime > UserDefaults.newEventStartTime {
            previewSections.append(PreviewCell.endTimeCell)
        }
        if UserDefaults.newEventLocationName != nil {
            previewSections.append(PreviewCell.locationCell)
        }
        if UserDefaults.newEventNote != nil {
            previewSections.append(PreviewCell.noteCell)
        }
        if UserDefaults.newEventLocationLatitude != 0 || UserDefaults.newEventLocationLongitude != 0 {
            previewSections.append(PreviewCell.mapCell)
        }
    }
    
    func clearNewEventUserDefaults() {
        UserDefaults.newEventName = nil
        UserDefaults.newEventDue = Date(timeIntervalSince1970: 0)
        UserDefaults.newEventMaxPeople = 0
        UserDefaults.newEventMinPeople = 0
        UserDefaults.newEventNumReserved = 0
        UserDefaults.newEventStartTime = Date(timeIntervalSince1970: 0)
        UserDefaults.newEventEndTime = Date(timeIntervalSince1970: 0)
        UserDefaults.newEventLocationName = nil
        UserDefaults.newEventLocationLatitude = 0
        UserDefaults.newEventLocationLongitude = 0
        UserDefaults.newEventNote = nil
    }
    
    @IBAction func post(_ sender: UIBarButtonItem) {
        
        let event = Event(name: UserDefaults.newEventName!, type: EventType.foodAndDrink, totalSeats: UserDefaults.newEventMaxPeople, remainingSeats: UserDefaults.newEventMaxPeople - UserDefaults.newEventNumReserved, minimumAttendingPeople: UserDefaults.newEventMinPeople, due: UserDefaults.newEventDue, creator: AVUser.current())
        
        if UserDefaults.newEventStartTime > Date() {
            event.startTime = UserDefaults.newEventStartTime
        }
        
        if UserDefaults.newEventEndTime > Date() && UserDefaults.newEventEndTime > UserDefaults.newEventStartTime {
            event.endTime = UserDefaults.newEventEndTime
        }
        
        event.locationName = UserDefaults.newEventLocationName
        
        if UserDefaults.newEventLocationLatitude != 0 || UserDefaults.newEventLocationLongitude != 0 {
            event.location = AVGeoPoint(latitude: UserDefaults.newEventLocationLatitude, longitude: UserDefaults.newEventLocationLongitude)
        }
        
        event.note = UserDefaults.newEventNote
        
        event.post() {
            succeeded, error in
            SVProgressHUD.dismiss()
            if succeeded {
                self.clearNewEventUserDefaults()
                self.presentingViewController?.dismiss(animated: true, completion: nil)
            } else {
                self.postButton.isEnabled = true
            }
        }
        postButton.isEnabled = false
        SVProgressHUD.show()
    }
}

extension NewEventPreviewViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return previewSections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 300
        }
        return 50
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch previewSections[indexPath.section] {
        case .headerCell:
            let cell = Bundle.main.loadNibNamed("EventDetailHeaderTableViewCell", owner: self, options: nil)?.first as! EventDetailHeaderTableViewCell
            cell.avatarImageView.layer.masksToBounds = true
            cell.avatarImageView.image = UserDefaults.avatar
            cell.creatorLabel.text = "发起人：" + UserDefaults.nickname!
            cell.eventNameLabel.text = UserDefaults.newEventName
            cell.remainingNumberLabel.text = String(UserDefaults.newEventMaxPeople - UserDefaults.newEventNumReserved)
            cell.attendingNumberLabel.text = "已经" + String(UserDefaults.newEventNumReserved) + "人报名"
            cell.minPeopleLabel.text = "最少" + String(UserDefaults.newEventMinPeople) + "人成行"
            cell.remainingTimeLabel.text = UserDefaults.newEventDue.gapFromNow
            
            return cell
        case .startTimeCell:
            let cell = Bundle.main.loadNibNamed("TimeDisplayTableViewCell", owner: self, options: nil)?.first as! TimeDisplayTableViewCell
            cell.titleLabel.text = "活动开始时间："
            cell.dateLabel.text = UserDefaults.newEventStartTime.readableDate
            cell.timeLabel.text = UserDefaults.newEventStartTime.readableTime
            return cell
        case .endTimeCell:
            let cell = Bundle.main.loadNibNamed("TimeDisplayTableViewCell", owner: self, options: nil)?.first as! TimeDisplayTableViewCell
            cell.titleLabel.text = "活动结束时间："
            cell.dateLabel.text = UserDefaults.newEventEndTime.readableDate
            cell.timeLabel.text = UserDefaults.newEventEndTime.readableTime
            return cell
        case .locationCell:
            let cell = Bundle.main.loadNibNamed("TitleContentTableViewCell", owner: self, options: nil)?.first as! TitleContentTableViewCell
            cell.titleLabel.text = "活动地点："
            cell.contentLabel.text = UserDefaults.newEventLocationName
            return cell
        case .mapCell:
            let cell = Bundle.main.loadNibNamed("MapViewTableViewCell", owner: self, options: nil)?.first as! MapViewTableViewCell
            return cell
        case .noteCell:
            let cell = Bundle.main.loadNibNamed("TitleTextViewTableViewCell", owner: self, options: nil)?.first as! TitleTextViewTableViewCell
            cell.titleLabel.text = "补充说明："
            cell.textView.text = UserDefaults.newEventNote
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
}
