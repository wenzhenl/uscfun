//
//  UserProfileTableViewCell.swift
//  uscfun
//
//  Created by Wenzheng Li on 9/4/16.
//  Copyright © 2016 Wenzheng Li. All rights reserved.
//

import UIKit

class UserProfileTableViewCell: UITableViewCell {

    @IBOutlet weak var avatarButton: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        avatarButton.layer.cornerRadius = avatarButton.frame.size.height / 2.0
        avatarButton.backgroundColor = UIColor.buttonPink()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
