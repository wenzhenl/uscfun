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
    var ifReadViewColor: UIColor!
    var statusViewColor: UIColor!
    
    var eventId: String?
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected {
            ifReadView.backgroundColor = ifReadViewColor
            statusView.backgroundColor = statusViewColor
        }
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        if highlighted {
            ifReadView.backgroundColor = ifReadViewColor
            statusView.backgroundColor = statusViewColor
        }
    }
}
