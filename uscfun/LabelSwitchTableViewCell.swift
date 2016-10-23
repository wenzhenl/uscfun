//
//  LabelSwitchTableViewCell.swift
//  uscfun
//
//  Created by Wenzheng Li on 10/23/16.
//  Copyright © 2016 Wenzheng Li. All rights reserved.
//

import UIKit

class LabelSwitchTableViewCell: UITableViewCell {

    @IBOutlet weak var mainLabel: UILabel!
    @IBOutlet weak var mainSwitch: UISwitch!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
