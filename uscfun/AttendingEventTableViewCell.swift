//
//  AttendingEventTableViewCell.swift
//  uscfun
//
//  Created by Wenzheng Li on 9/4/16.
//  Copyright © 2016 Wenzheng Li. All rights reserved.
//

import UIKit

class AttendingEventTableViewCell: UITableViewCell {
    @IBOutlet weak var nameTextView: UITextView!
    @IBOutlet weak var eventImageView: UIImageView!
    @IBOutlet weak var indicatorView: UIView!
    var eventId: String!
    
    override func awakeFromNib() {
        indicatorView.layer.cornerRadius = 5
    }
}
