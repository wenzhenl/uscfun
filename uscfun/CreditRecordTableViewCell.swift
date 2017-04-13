//
//  CreditRecordTableViewCell.swift
//  uscfun
//
//  Created by Wenzheng Li on 4/13/17.
//  Copyright © 2017 Wenzheng Li. All rights reserved.
//

import UIKit

class CreditRecordTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var ratingBar: RatingBar!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
