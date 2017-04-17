//
//  NewEventPreviewViewController.swift
//  uscfun
//
//  Created by Wenzheng Li on 3/1/17.
//  Copyright © 2017 Wenzheng Li. All rights reserved.
//

import UIKit
import SVProgressHUD
import ChatKit

class NewEventPreviewViewController: UIViewController {

    @IBOutlet weak var postButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    
    var previewSections = [EventDetailCell]()
    
    var errorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 10, 0)
        self.tableView.tableFooterView = UIView()
        self.populateSections()
        
        if let navigationBar = self.navigationController?.navigationBar {
            errorLabel = UILabel(frame: CGRect(x: navigationBar.frame.width/4, y: 0, width: navigationBar.frame.width/2, height: navigationBar.frame.height))
            errorLabel.textAlignment = .center
            errorLabel.textColor = UIColor.red
            errorLabel.font = UIFont.systemFont(ofSize: 13)
            errorLabel.numberOfLines = 0
            navigationBar.addSubview(errorLabel)
            errorLabel.isHidden = true
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        errorLabel.isHidden = true
    }
    
    func populateSections() {
        // Populate the cells
        previewSections.removeAll()
        previewSections.append(EventDetailCell.statusCell)
        previewSections.append(EventDetailCell.titleCell)
        previewSections.append(EventDetailCell.creatorCell)
        previewSections.append(EventDetailCell.remainingNumberCell)
        previewSections.append(EventDetailCell.numberCell)
        previewSections.append(EventDetailCell.remainingTimeCell)
        if UserDefaults.newEventStartTime > Date() {
            previewSections.append(EventDetailCell.startTimeCell)
        }
        if UserDefaults.newEventEndTime > Date() && UserDefaults.newEventEndTime > UserDefaults.newEventStartTime {
            previewSections.append(EventDetailCell.endTimeCell)
        }
        if UserDefaults.newEventLocation != nil {
            previewSections.append(EventDetailCell.locationCell)
        }
        if UserDefaults.newEventNote != nil {
            previewSections.append(EventDetailCell.noteCell)
        }
        if UserDefaults.newEventLocationLatitude != 0 || UserDefaults.newEventLocationLongitude != 0 {
            previewSections.append(EventDetailCell.mapCell)
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
        UserDefaults.newEventLocation = nil
        UserDefaults.newEventLocationLatitude = 0
        UserDefaults.newEventLocationLongitude = 0
        UserDefaults.newEventNote = nil
    }
    
    @IBAction func post(_ sender: UIBarButtonItem) {
        
        var startTime: Date?
        var endTime: Date?
        var whereCreated: AVGeoPoint?
        
        if UserDefaults.newEventStartTime > Date() {
            startTime = UserDefaults.newEventStartTime
        }
        
        if UserDefaults.newEventEndTime > Date() && UserDefaults.newEventEndTime > UserDefaults.newEventStartTime {
            endTime = UserDefaults.newEventEndTime
        }
        
        if UserDefaults.newEventLocationLatitude != 0 || UserDefaults.newEventLocationLongitude != 0 {
            whereCreated = AVGeoPoint(latitude: UserDefaults.newEventLocationLatitude, longitude: UserDefaults.newEventLocationLongitude)
        }
        
        let event = Event(name: UserDefaults.newEventName!, maximumAttendingPeople: UserDefaults.newEventMaxPeople,
                          remainingSeats: UserDefaults.newEventMaxPeople - UserDefaults.newEventNumReserved,
                          minimumAttendingPeople: UserDefaults.newEventMinPeople,
                          due: UserDefaults.newEventDue, createdBy: AVUser.current()!,
                          startTime: startTime, endTime: endTime,
                          location: UserDefaults.newEventLocation,
                          whereCreated: whereCreated,
                          note: UserDefaults.newEventNote)
        event.post() {
            succeeded, error in
            SVProgressHUD.dismiss()
            if succeeded {
                self.clearNewEventUserDefaults()
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "userDidPostNewEvent"), object: nil, userInfo: nil)
                self.presentingViewController?.dismiss(animated: true, completion: nil)
            } else if error != nil {
                print(error!)
                self.errorLabel.text = error!.customDescription
                self.errorLabel.isHidden = false
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
        if indexPath.section == 2 {
            return 50
        }
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch previewSections[indexPath.section] {
        case .statusCell:
            let cell = Bundle.main.loadNibNamed("EventStatusBarTableViewCell", owner: self, options: nil)?.first as! EventStatusBarTableViewCell
            cell.statusView.backgroundColor = UIColor.red
            cell.statusLabel.text = "火热报名中"
            cell.selectionStyle = .none
            return cell
        case .titleCell:
            let cell = UITableViewCell()
            cell.textLabel?.textColor = UIColor.darkText
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 17)
            cell.textLabel?.textAlignment = .left
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.text = UserDefaults.newEventName
            cell.selectionStyle = .none
            return cell
        case .creatorCell:
            let cell = Bundle.main.loadNibNamed("EventCreatorTableViewCell", owner: self, options: nil)?.first as! EventCreatorTableViewCell
            cell.avatorImageView.image = UserDefaults.avatar
            cell.creatorLabel.text = UserDefaults.nickname
            cell.selectionStyle = .none
            return cell
        case .remainingNumberCell:
            let cell = Bundle.main.loadNibNamed("NumberDisplayTableViewCell", owner: self, options: nil)?.first as! NumberDisplayTableViewCell
            cell.numberLabel.text = String(UserDefaults.newEventMaxPeople - UserDefaults.newEventNumReserved)
            cell.selectionStyle = .none
            return cell
        case .numberCell:
            let cell = Bundle.main.loadNibNamed("TandemLabelTableViewCell", owner: self, options: nil)?.first as! TandemLabelTableViewCell
            cell.leftLabel.text = "已经报名 " + String(UserDefaults.newEventNumReserved) + "人"
            cell.rightLabel.text = "最少成行 " + String(UserDefaults.newEventMinPeople) + "人"
            cell.selectionStyle = .none
            return cell
        case .remainingTimeCell:
            let cell = Bundle.main.loadNibNamed("TitleContentTableViewCell", owner: self, options: nil)?.first as! TitleContentTableViewCell
            cell.titleLabel.text = "离报名截止还剩："
            cell.contentLabel.text = UserDefaults.newEventDue.gapFromNow
            cell.selectionStyle = .none
            return cell
        case .startTimeCell:
            let cell = Bundle.main.loadNibNamed("TimeDisplayTableViewCell", owner: self, options: nil)?.first as! TimeDisplayTableViewCell
            cell.titleLabel.text = "活动开始时间："
            cell.dateLabel.text = UserDefaults.newEventStartTime.readableDate
            cell.timeLabel.text = UserDefaults.newEventStartTime.readableTime
            cell.selectionStyle = .none
            return cell
        case .endTimeCell:
            let cell = Bundle.main.loadNibNamed("TimeDisplayTableViewCell", owner: self, options: nil)?.first as! TimeDisplayTableViewCell
            cell.titleLabel.text = "活动结束时间："
            cell.dateLabel.text = UserDefaults.newEventEndTime.readableDate
            cell.timeLabel.text = UserDefaults.newEventEndTime.readableTime
            cell.selectionStyle = .none
            return cell
        case .locationCell:
            let cell = Bundle.main.loadNibNamed("TitleContentTableViewCell", owner: self, options: nil)?.first as! TitleContentTableViewCell
            cell.titleLabel.text = "活动地点："
            cell.contentLabel.text = UserDefaults.newEventLocation
            cell.selectionStyle = .none
            return cell
        case .mapCell:
            let cell = Bundle.main.loadNibNamed("MapViewTableViewCell", owner: self, options: nil)?.first as! MapViewTableViewCell
            let location = CLLocationCoordinate2D(latitude: UserDefaults.newEventLocationLatitude, longitude: UserDefaults.newEventLocationLongitude)
            let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            let region = MKCoordinateRegion(center: location, span: span)
            cell.mapView.setRegion(region, animated: true)
            let annotation = MKPointAnnotation()
            annotation.coordinate = location
            annotation.title = UserDefaults.newEventLocation
            cell.mapView.addAnnotation(annotation)
            cell.selectionStyle = .none
            return cell
        case .noteCell:
            let cell = Bundle.main.loadNibNamed("TitleTextViewTableViewCell", owner: self, options: nil)?.first as! TitleTextViewTableViewCell
            cell.titleLabel.text = "补充说明："
            cell.textView.text = UserDefaults.newEventNote
            cell.selectionStyle = .none
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 3 {
            return 1 / UIScreen.main.scale
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let px = 1 / UIScreen.main.scale
        let frame = CGRect(x: 0, y: 0, width: self.tableView.frame.size.width, height: px)
        let line = UIView(frame: frame)
        line.backgroundColor = self.tableView.separatorColor
        return line
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 1 {
            return 10
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        view.tintColor = UIColor.clear
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.frame.size.width, height: 10))
        footerView.backgroundColor = UIColor.backgroundGray
        return footerView
    }
}
