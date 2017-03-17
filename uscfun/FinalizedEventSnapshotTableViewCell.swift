//
//  FinalizedEventSnapshotTableViewCell.swift
//  uscfun
//
//  Created by Wenzheng Li on 3/13/17.
//  Copyright © 2017 Wenzheng Li. All rights reserved.
//

import UIKit

class FinalizedEventSnapshotTableViewCell: UITableViewCell {
    @IBOutlet weak var ifReadView: UIView!
    @IBOutlet weak var eventNameLabel: UILabel!
    @IBOutlet weak var latestMessageLabel: UILabel!
    @IBOutlet weak var statusView: UIView!
    var eventId: String?
}
