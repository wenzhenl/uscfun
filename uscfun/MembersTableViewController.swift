//
//  MembersTableViewController.swift
//  uscfun
//
//  Created by Wenzheng Li on 10/26/16.
//  Copyright © 2016 Wenzheng Li. All rights reserved.
//

import UIKit

class MembersTableViewController: UITableViewController {
    
    var event: Event!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.backgroundGray
        self.tableView.tableFooterView = UIView()
        self.title = "当前成员"
        self.tableView.contentInset = UIEdgeInsetsMake(10, 0, 0, 0)
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return event.members.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = Bundle.main.loadNibNamed("ImgKeyValueArrowTableViewCell", owner: self, options: nil)?.first as! ImgKeyValueArrowTableViewCell
        let member = User(user: event.members[indexPath.row])
        cell.mainImageView.image = member?.avatar
        cell.keyLabel.text = member?.nickname
        if event.creator == event.members[indexPath.row] {
            cell.valueLabel.text = "发起人"
        } else {
            cell.valueLabel.text = "参与者"
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: segueIdentifierForUserProfile, sender: self)
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    let segueIdentifierForUserProfile = "see user profile"
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            if identifier == segueIdentifierForUserProfile {
                let destination = segue.destination
                if let userProfileVC = destination as? UserProfileViewController {
                    let other = User(user: event.members[(tableView.indexPathForSelectedRow?.row)!])
                    userProfileVC.other = other
                }
            }
        }
    }
}
