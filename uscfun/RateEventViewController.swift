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
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var submitButton: UIButton!
    
    var event: Event!
    var otherMembers = [AVUser]()
    var otherMemberScore = [CGFloat]()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.scrollsToTop = true
        self.tableView.tableFooterView = UIView()
        self.tableView.separatorStyle = .none
        self.toolBar.barTintColor = UIColor.white
        self.submitButton.layer.cornerRadius = self.submitButton.frame.size.height / 2.0
        self.submitButton.backgroundColor = UIColor.buttonBlue
        
        for member in event.members {
            if member != AVUser.current()! {
                otherMembers.append(member)
                otherMemberScore.append(5.0)
            }
        }
    }
    
    @IBAction func submitRatings(_ sender: UIButton) {
    }
    
    @IBAction func stopRating(_ sender: UIBarButtonItem) {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
}

extension RateEventViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return otherMembers.count
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
        cell.avatarImageView.clipsToBounds = true
        cell.avatarImageView.layer.cornerRadius = cell.avatarImageView.frame.size.height / 2.0
        cell.avatarImageView.image = user?.avatar
        cell.nickNameLabel.text = user?.nickname
        cell.ratingBar.tag = indexPath.row
        cell.ratingBar.delegate = self
        cell.ratingBar.ratingMin = 1.0
        cell.ratingBar.rating = otherMemberScore[indexPath.row]
        cell.ratingBar.shouldAnimate = true
        cell.selectionStyle = .none
        return cell
    }
}

extension RateEventViewController: RatingBarDelegate {
    func ratingDidChange(ratingBar: RatingBar, rating: CGFloat) {
        print("rating did change")
        otherMemberScore[ratingBar.tag] = rating
    }
}
