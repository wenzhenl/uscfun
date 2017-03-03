//
//  EventStatusBarTableViewCell.swift
//  uscfun
//
//  Created by Wenzheng Li on 3/4/17.
//  Copyright © 2017 Wenzheng Li. All rights reserved.
//

import UIKit

class EventStatusBarTableViewCell: UITableViewCell {

    @IBOutlet weak var statusView: UIView!
    @IBOutlet weak var statusLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        statusView.layer.cornerRadius = statusView.frame.size.height / 2.0
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
