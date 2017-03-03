//
//  EventCreatorTableViewCell.swift
//  uscfun
//
//  Created by Wenzheng Li on 3/4/17.
//  Copyright © 2017 Wenzheng Li. All rights reserved.
//

import UIKit

class EventCreatorTableViewCell: UITableViewCell {

    @IBOutlet weak var avatorImageView: UIImageView!
    @IBOutlet weak var creatorLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        avatorImageView.layer.masksToBounds = true
        avatorImageView.layer.cornerRadius = avatorImageView.frame.size.width / 2.0
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
