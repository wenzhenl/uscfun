//
//  EventListTableViewCell.swift
//  uscfun
//
//  Created by Wenzheng Li on 9/3/16.
//  Copyright © 2016 Wenzheng Li. All rights reserved.
//

import UIKit

class EventListTableViewCell: UITableViewCell {

    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    var due: Date?
    var timer: Timer?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        containerView.layer.cornerRadius = 13
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = UIColor.lightGray.cgColor
//        let blueColor = CGFloat(Int(arc4random() % 255)) / 255.0
//        let greenColor = CGFloat(Int(arc4random() % 255)) / 255.0
//        let redColor = CGFloat(Int(arc4random() % 255)) / 255.0
//        bannerView.backgroundColor = UIColor(red: redColor, green: greenColor, blue: blueColor, alpha: 1.0)
//        bannerView.backgroundColor = UIColor.clearColor()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func timerStarted() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(update), userInfo: nil, repeats: true)
    }
    
    func update() {
        if let due = due {
            let currentDate = Date()
            let diffDateComponents = Calendar.current.dateComponents([Calendar.Component.day,.hour,.minute,.second], from: currentDate, to: due)
            self.timeLabel.text = "还剩\(diffDateComponents.day!)天\(diffDateComponents.hour!)时\(diffDateComponents.minute!)分\(diffDateComponents.second!)秒"
        }
    }

}
