//
//  EmptySectionPlaceholderTableViewCell.swift
//  uscfun
//
//  Created by Wenzheng Li on 10/23/16.
//  Copyright © 2016 Wenzheng Li. All rights reserved.
//

import UIKit

class EmptySectionPlaceholderTableViewCell: UITableViewCell {

    @IBOutlet weak var blackfishImageView: UIImageView!
    @IBOutlet weak var mainTextView: UITextView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
