//
//  EventListTableViewCell.swift
//  uscfun
//
//  Created by Wenzheng Li on 9/3/16.
//  Copyright © 2016 Wenzheng Li. All rights reserved.
//

import UIKit

class EventListTableViewCell: UITableViewCell {

    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var nameTextView: UITextView!
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var locationNameLabel: UILabel!
    @IBOutlet weak var creatorImageView: UIImageView!
    @IBOutlet weak var headCountLabel: UILabel!
    
    var due: Date?
    var timer: Timer?
    
    var eventId: String!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        containerView.layer.cornerRadius = 13
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = UIColor.lightGray.cgColor
        creatorImageView.layer.cornerRadius = 20
        creatorImageView.layer.masksToBounds = true
    }
    
    func timerStarted() {
        timer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(update), userInfo: nil, repeats: true)
    }
    
    func update() {
        if let due = due {
            self.timeLabel.text = "报名截止还有\(due.gapFromNow)"
        }
    }

}
