//
//  EventSnapshotTableViewCell.swift
//  uscfun
//
//  Created by Wenzheng Li on 3/1/17.
//  Copyright © 2017 Wenzheng Li. All rights reserved.
//

import UIKit

class EventSnapshotTableViewCell: UITableViewCell {

    @IBOutlet weak var creatorAvatarImageView: UIImageView!
    @IBOutlet weak var creatorLabel: UILabel!
    @IBOutlet weak var eventNameLabel: UILabel!
    @IBOutlet weak var moreButton: UIButton!
    
    @IBOutlet weak var whitePaperImageView: UIImageView!
    @IBOutlet weak var needNumberLabel: UILabel!
    @IBOutlet weak var remainingTimeLabel: UILabel!
    
    @IBOutlet weak var attendingLabel: UILabel!
    @IBOutlet weak var minPeopleLabel: UILabel!
    @IBOutlet weak var chatButton: UIButton!
    @IBOutlet weak var statusView: UIView!
    
    var statusViewColor: UIColor!
    
    var eventId: String?
    var due: Date?
    var timer: Timer?
    
    func timerStarted() {
        if timer == nil {
            timer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(update), userInfo: nil, repeats: true)
        }
    }
    
    func update() {
        if let due = due {
            
            if due < Date() {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "eventDidExpired"), object: nil, userInfo: ["eventId": eventId ?? ""])
                timer?.invalidate()
                timer = nil
            }
            
            let gapFromNow = due.gapFromNow
            if gapFromNow == "" {
                remainingTimeLabel.textColor = UIColor.darkGray
                remainingTimeLabel.text = "报名已经结束"
            } else {
                remainingTimeLabel.text = gapFromNow
            }
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected {
            statusView.backgroundColor = statusViewColor
        }
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        if highlighted {
            statusView.backgroundColor = statusViewColor
        }
    }
}
