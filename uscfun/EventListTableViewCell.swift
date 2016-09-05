//
//  EventListTableViewCell.swift
//  uscfun
//
//  Created by Wenzheng Li on 9/3/16.
//  Copyright © 2016 Wenzheng Li. All rights reserved.
//

import UIKit

class EventListTableViewCell: UITableViewCell {

    @IBOutlet weak var containerView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        containerView.layer.cornerRadius = 13
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = UIColor.lightGrayColor().CGColor
//        let blueColor = CGFloat(Int(arc4random() % 255)) / 255.0
//        let greenColor = CGFloat(Int(arc4random() % 255)) / 255.0
//        let redColor = CGFloat(Int(arc4random() % 255)) / 255.0
//        bannerView.backgroundColor = UIColor(red: redColor, green: greenColor, blue: blueColor, alpha: 1.0)
//        bannerView.backgroundColor = UIColor.clearColor()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
