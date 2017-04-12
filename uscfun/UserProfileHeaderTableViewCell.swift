//
//  UserProfileHeaderTableViewCell.swift
//  uscfun
//
//  Created by Wenzheng Li on 3/5/17.
//  Copyright © 2017 Wenzheng Li. All rights reserved.
//

import UIKit

class UserProfileHeaderTableViewCell: UITableViewCell {
    @IBOutlet weak var avatarButton: UIButton!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var officialBadgeButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        officialBadgeButton.backgroundColor = UIColor.avatarTomato
        officialBadgeButton.setTitleColor(UIColor.white, for: .normal)
        officialBadgeButton.layer.cornerRadius = 4
    }
}
