//
//  ConversationMoreViewController.swift
//  uscfun
//
//  Created by Wenzheng Li on 4/11/17.
//  Copyright © 2017 Wenzheng Li. All rights reserved.
//

import UIKit

enum ConversationDetailCell {
    case labelSwitchCell
    case statusCell
    case titleCell
    case creatorCell
    case remainingNumberCell
    case numberCell
    case memberCell
    case remainingTimeCell
    case startTimeCell
    case endTimeCell
    case locationCell
    case mapCell
    case noteCell
}

class ConversationMoreViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var event: Event!
    var creator: User!
    var memberAvatars = [UIImage]()
    var detailSections = [ConversationDetailCell]()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.tableView.scrollsToTop = true
        self.tableView.tableFooterView = UIView()
        self.tableView.separatorStyle = .none
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 50, 0)
        self.title = "聊天详情"
        creator = User(user: event.createdBy)
        if event.status == .isFinalized {
            self.tableView.backgroundColor = UIColor.white
        } else {
            self.tableView.backgroundColor = UIColor.backgroundGray
        }

        populateSections()
    }
    
    func populateSections() {
        
     
        if event.status == .isFinalized {
            memberAvatars.removeAll()
            memberAvatars.append(creator.avatar ?? #imageLiteral(resourceName: "user-4"))
            for memberData in event.members {
                if memberData != event.createdBy {
                    if let member = User(user: memberData) {
                        memberAvatars.append(member.avatar ?? #imageLiteral(resourceName: "user-4"))
                    }
                }
            }
            detailSections.removeAll()
            detailSections.append(.titleCell)
            detailSections.append(.labelSwitchCell)
            detailSections.append(.creatorCell)
            detailSections.append(.remainingNumberCell)
            detailSections.append(.numberCell)
            if event.members.count > 1 {
                detailSections.append(.memberCell)
            }
            detailSections.append(.remainingTimeCell)
            if event.startTime != nil {
                detailSections.append(.startTimeCell)
            }
            if event.endTime != nil {
                detailSections.append(.endTimeCell)
            }
            if event.location != nil {
                detailSections.append(.locationCell)
            }
            if event.note != nil {
                detailSections.append(.noteCell)
            }
            if event.whereCreated != nil {
                detailSections.append(.mapCell)
            }
        } else {
            detailSections.removeAll()
            detailSections.append(.labelSwitchCell)
        }
    }
    
    func checkProfile(sender: UIButton) {
        performSegue(withIdentifier: userProfileSugueIdentifier, sender: sender)
    }
    
    func switchMuteMode(switchElement: UISwitch) {
        print("current mute state: \(switchElement.isOn)")
        if switchElement.isOn {
            LeanEngine.muteConversation(clientId: AVUser.current()!.username!, conversationId: event.conversationId) {
                succeeded, error in
                if succeeded {
                    print("mute conversation successfully")
                }
                if error != nil {
                    print(error!)
                }
            }
        } else {
            LeanEngine.unmuteConversation(clientId: AVUser.current()!.username!, conversationId: event.conversationId) {
                succeeded, error in
                if succeeded {
                    print("unmute conversation successfully")
                }
                if error != nil {
                    print(error!)
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let destination = segue.destination.contentViewController
        
        if let identifier = segue.identifier {
            switch identifier {
            case mapSegueIdentifier:
                if let mapVC = destination as? MapViewController {
                    mapVC.placename = event.location
                    mapVC.latitude = event.whereCreated?.latitude
                    mapVC.longitude = event.whereCreated?.longitude
                }
            case userProfileSugueIdentifier:
                if let upVC = destination as? UserProfileViewController {
                    switch sender {
                    case is UIButton:
                        upVC.user = event.members[(sender as! UIButton).tag]
                    case is EventCreatorTableViewCell:
                        upVC.user = event.createdBy
                    default:
                        break
                    }
                }
            default:
                break
            }
        }
    }
    
    let mapSegueIdentifier = "go to see map"
    let userProfileSugueIdentifier = "go to see user profile"
}

extension ConversationMoreViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if detailSections[indexPath.section] == .mapCell {
            performSegue(withIdentifier: mapSegueIdentifier, sender: self)
        }
        
        if detailSections[indexPath.section] == .creatorCell {
            performSegue(withIdentifier: userProfileSugueIdentifier, sender: tableView.cellForRow(at: indexPath))
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return detailSections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if detailSections[indexPath.section] == .creatorCell {
            return 50
        }
        
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch detailSections[indexPath.section] {
        case .labelSwitchCell:
            let cell = Bundle.main.loadNibNamed("LabelSwitchTableViewCell", owner: self, options: nil)?.first as! LabelSwitchTableViewCell
            cell.mainLabel.text = "消息免打扰"
            cell.mainLabel.textColor = UIColor.darkText
            do {
                let isMuted = try LeanEngine.isMutedInConversation(clientId: AVUser.current()!.username!, conversationId: event.conversationId)
                cell.mainSwitch.isOn = isMuted
                cell.mainSwitch.addTarget(self, action: #selector(switchMuteMode(switchElement:)), for: .valueChanged)
            } catch let error {
                print("failed to fetch if is muted \(error)")
            }
            cell.selectionStyle = .none
            return cell
        case .statusCell:
            let cell = Bundle.main.loadNibNamed("EventStatusBarTableViewCell", owner: self, options: nil)?.first as! EventStatusBarTableViewCell
            cell.statusView.backgroundColor = event.statusColor
            cell.statusLabel.text = event.status.description
            cell.selectionStyle = .none
            return cell
        case .titleCell:
            let cell = UITableViewCell()
            cell.textLabel?.textColor = UIColor.darkText
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 17)
            cell.textLabel?.textAlignment = .left
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.text = event.name
            cell.selectionStyle = .none
            return cell
        case .creatorCell:
            let cell = Bundle.main.loadNibNamed("EventCreatorTableViewCell", owner: self, options: nil)?.first as! EventCreatorTableViewCell
            cell.avatorImageView.image = creator.avatar
            cell.creatorLabel.text = creator.nickname
            cell.selectionStyle = .none
            return cell
        case .remainingNumberCell:
            let cell = Bundle.main.loadNibNamed("NumberDisplayTableViewCell", owner: self, options: nil)?.first as! NumberDisplayTableViewCell
            cell.numberLabel.text = String(event.remainingSeats)
            cell.whitePaperImageView.image = event.whitePaper
            cell.selectionStyle = .none
            return cell
        case .numberCell:
            let cell = Bundle.main.loadNibNamed("TandemLabelTableViewCell", owner: self, options: nil)?.first as! TandemLabelTableViewCell
            cell.leftLabel.text = "已经报名 " + String(event.maximumAttendingPeople - event.remainingSeats) + "人"
            cell.rightLabel.text = "最少成行 " + String(event.minimumAttendingPeople) + "人"
            cell.selectionStyle = .none
            return cell
        case .remainingTimeCell:
            let cell = Bundle.main.loadNibNamed("TitleContentTableViewCell", owner: self, options: nil)?.first as! TitleContentTableViewCell
            cell.titleLabel.text = "离报名截止还剩："
            let gapFromNow = event.due.gapFromNow
            if gapFromNow == "" {
                cell.contentLabel.textColor = UIColor.darkGray
                cell.contentLabel.text = "报名已经结束"
            } else {
                cell.contentLabel.text = gapFromNow
            }
            cell.selectionStyle = .none
            return cell
        case .startTimeCell:
            let cell = Bundle.main.loadNibNamed("TimeDisplayTableViewCell", owner: self, options: nil)?.first as! TimeDisplayTableViewCell
            cell.titleLabel.text = "微活动开始时间："
            cell.dateLabel.text = event.startTime!.readableDate
            cell.timeLabel.text = event.startTime!.readableTime
            cell.selectionStyle = .none
            return cell
        case .endTimeCell:
            let cell = Bundle.main.loadNibNamed("TimeDisplayTableViewCell", owner: self, options: nil)?.first as! TimeDisplayTableViewCell
            cell.titleLabel.text = "微活动结束时间："
            cell.dateLabel.text = event.endTime!.readableDate
            cell.timeLabel.text = event.endTime!.readableTime
            cell.selectionStyle = .none
            return cell
        case .locationCell:
            let cell = Bundle.main.loadNibNamed("TitleTextViewTableViewCell", owner: self, options: nil)?.first as! TitleTextViewTableViewCell
            cell.titleLabel.text = "微活动地点："
            cell.textView.text = event.location
            cell.textView.isEditable = false
            cell.textView.textColor = UIColor.darkText
            cell.textView.font = UIFont.boldSystemFont(ofSize: 17)
            cell.textView.textAlignment = .center
            cell.textView.dataDetectorTypes = [.address]
            cell.selectionStyle = .none
            return cell
        case .mapCell:
            let cell = Bundle.main.loadNibNamed("MapViewTableViewCell", owner: self, options: nil)?.first as! MapViewTableViewCell
            let location = CLLocationCoordinate2D(latitude: (event.whereCreated?.latitude)!, longitude: (event.whereCreated?.longitude)!)
            let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            let region = MKCoordinateRegion(center: location, span: span)
            cell.mapView.setRegion(region, animated: true)
            let annotation = MKPointAnnotation()
            annotation.coordinate = location
            annotation.title = event.location
            cell.mapView.addAnnotation(annotation)
            cell.mapView.isUserInteractionEnabled = false
            cell.selectionStyle = .none
            return cell
        case .noteCell:
            let cell = Bundle.main.loadNibNamed("TitleTextViewTableViewCell", owner: self, options: nil)?.first as! TitleTextViewTableViewCell
            cell.titleLabel.text = "补充说明："
            cell.textView.text = event.note
            cell.textView.delegate = self
            cell.selectionStyle = .none
            return cell
        case .memberCell:
            let cell = Bundle.main.loadNibNamed("KeyScrollViewTableViewCell", owner: self, options: nil)?.first as! KeyScrollViewTableViewCell
            let numberOfMysteriousMembers = event.maximumAttendingPeople - event.remainingSeats - memberAvatars.count
            var possibleLabelWidth = CGFloat(0)
            
            for i in 0..<memberAvatars.count {
                let buttonWidth = CGFloat(35.0)
                let margin = CGFloat(2.0)
                let xPosition = buttonWidth * CGFloat(i) + margin * CGFloat(i) + possibleLabelWidth
                let button = UIButton(frame: CGRect(x: xPosition, y: (70.0 - buttonWidth) * 0.5, width: buttonWidth, height: buttonWidth))
                button.setBackgroundImage(memberAvatars[i], for: .normal)
                button.layer.cornerRadius = buttonWidth / 2.0
                button.layer.masksToBounds = true
                button.contentMode = .scaleAspectFit
                button.tag = i
                button.addTarget(self, action: #selector(checkProfile(sender:)), for: .touchUpInside)
                cell.mainScrollView.contentSize.width = (buttonWidth + margin) * CGFloat(i+1) + possibleLabelWidth
                cell.mainScrollView.addSubview(button)
                
                if i == 0 && numberOfMysteriousMembers > 0 {
                    print("number of unseen members: \(numberOfMysteriousMembers)")
                    possibleLabelWidth = CGFloat(20.0)
                    let label = UILabel(frame: CGRect(x: xPosition + buttonWidth, y: (70.0 - buttonWidth) * 0.5, width: buttonWidth, height: buttonWidth))
                    label.textAlignment = .left
                    label.text = "+\(numberOfMysteriousMembers)"
                    label.textColor = UIColor.buttonPink
                    label.font = UIFont.boldSystemFont(ofSize: 13)
                    cell.mainScrollView.contentSize.width += possibleLabelWidth
                    cell.mainScrollView.addSubview(label)
                }
            }
            cell.selectionStyle = .none
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if detailSections[section] == .remainingNumberCell {
            return 1 / UIScreen.main.scale
        }
        if event.status == .isFinalized {
            if detailSections[section] == .labelSwitchCell {
                return 1 / UIScreen.main.scale
            }
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
        if detailSections[section] == .labelSwitchCell {
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

extension ConversationMoreViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        if URL.scheme == "http" || URL.scheme == "https" {
            if let webVC = UIStoryboard(name: "Login", bundle: nil).instantiateViewController(withIdentifier: USCFunConstants.storyboardIdentifierOfWebViewController) as? WebViewController {
                webVC.url = URL
                self.navigationController?.pushViewController(webVC, animated: true)
            }
            return false
        }
        return true
    }
}
