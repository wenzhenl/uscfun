//
//  UserProfileHeaderTableViewCell.swift
//  uscfun
//
//  Created by Wenzheng Li on 3/5/17.
//  Copyright © 2017 Wenzheng Li. All rights reserved.
//

import UIKit

class UserProfileHeaderTableViewCell: UITableViewCell {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var initEventLabel: UILabel!
    @IBOutlet weak var joinEventLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
