//
//  textViewTableViewCell.swift
//  uscfun
//
//  Created by Wenzheng Li on 9/25/16.
//  Copyright © 2016 Wenzheng Li. All rights reserved.
//

import UIKit

class TextViewTableViewCell: UITableViewCell {

    @IBOutlet weak var textView: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
