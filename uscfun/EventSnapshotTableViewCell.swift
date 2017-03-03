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
}