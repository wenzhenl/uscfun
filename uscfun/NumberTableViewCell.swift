//
//  NumberTableViewCell.swift
//  uscfun
//
//  Created by Wenzheng Li on 9/9/16.
//  Copyright © 2016 Wenzheng Li. All rights reserved.
//

import UIKit

class NumberTableViewCell: UITableViewCell {

    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var footnoteLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
