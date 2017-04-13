//
//  RateEventViewController.swift
//  uscfun
//
//  Created by Wenzheng Li on 4/13/17.
//  Copyright © 2017 Wenzheng Li. All rights reserved.
//

import UIKit

class RateEventViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var event: Event!
    var otherMembers = [AVUser]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.scrollsToTop = true
        self.tableView.tableFooterView = UIView()
        self.tableView.separatorStyle = .none
        self.title = "评价队友"
        for member in event.members {
            if member != AVUser.current()! {
                otherMembers.append(member)
            }
        }
    }
}

extension RateEventViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return event.members.count - 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = Bundle.main.loadNibNamed("RateMemberTableViewCell", owner: self, options: nil)?.first as! RateMemberTableViewCell
        let user = User(user: otherMembers[indexPath.row])
        cell.avatarImageView.image = user?.avatar
        cell.ratingBar.delegate = self
        cell.selectionStyle = .none
        return cell
    }
}

extension RateEventViewController: RatingBarDelegate {
    func ratingDidChange(ratingBar: RatingBar, rating: CGFloat) {
        print("rating did change")
    }
}
