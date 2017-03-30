//
//  FinalizedEventSnapshotTableViewCell.swift
//  uscfun
//
//  Created by Wenzheng Li on 3/13/17.
//  Copyright © 2017 Wenzheng Li. All rights reserved.
//

import UIKit

class FinalizedEventSnapshotTableViewCell: UITableViewCell {
    @IBOutlet weak var ifReadView: UIView!
    @IBOutlet weak var eventNameLabel: UILabel!
    @IBOutlet weak var latestMessageLabel: UILabel!
    @IBOutlet weak var statusView: UIView!
    var ifReadViewColor: UIColor!
    var statusViewColor: UIColor!
    
    var eventId: String?
    
    func update(notification: Notification) {
        guard let userInfo = notification.userInfo as? [String: String], let action = userInfo["action"], let conversationId = userInfo["conversationId"], let text = userInfo["text"] else {
            return
        }
        if conversationId == EventRequest.myOngoingEvents[eventId!]?.conversationId {
            self.latestMessageLabel.text = text
            if action == "receive" {
                self.ifReadView.backgroundColor = ifReadViewColor
            }
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected {
            ifReadView.backgroundColor = ifReadViewColor
            statusView.backgroundColor = statusViewColor
        }
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        if highlighted {
            ifReadView.backgroundColor = ifReadViewColor
            statusView.backgroundColor = statusViewColor
        }
    }
}
