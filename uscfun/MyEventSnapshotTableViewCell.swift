//
//  MyEventSnapshotTableViewCell.swift
//  uscfun
//
//  Created by Wenzheng Li on 4/7/17.
//  Copyright © 2017 Wenzheng Li. All rights reserved.
//

import UIKit

class MyEventSnapshotTableViewCell: UITableViewCell {

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
    
    @IBOutlet weak var ifReadView: UIView!
    @IBOutlet weak var latestMessageButton: UIButton!
    
    var statusViewColor: UIColor!
    var ifReadViewColor: UIColor!
    
    var eventId: String?
    var due: Date?
    
    func update() {
        print("received need to update notification")
        if let due = due {
            if due < Date() {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "eventDidExpired"), object: nil, userInfo: nil)
                NotificationCenter.default.removeObserver(self)
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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        NotificationCenter.default.addObserver(self, selector: #selector(update), name: NSNotification.Name(rawValue: "needToUpdateRemainingTime"), object: nil)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected {
            statusView.backgroundColor = statusViewColor
            ifReadView.backgroundColor = ifReadViewColor
        }
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        if highlighted {
            statusView.backgroundColor = statusViewColor
            ifReadView.backgroundColor = ifReadViewColor
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
