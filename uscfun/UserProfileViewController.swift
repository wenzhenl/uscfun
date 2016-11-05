//
//  UserProfileViewController.swift
//  uscfun
//
//  Created by Wenzheng Li on 11/4/16.
//  Copyright © 2016 Wenzheng Li. All rights reserved.
//

import UIKit

enum UserProfileCell {
    case profileTableCell(image: UIImage, text: String)
//    case labelArrowTableCell(text: String, segueId: String)
//    case labelImgArrowTableCell(text: String, isIndicated: Bool, segueId: String)
//    case labelSwitchTableCell(text: String)
//    case regularTableCell(text: String, segueId: String)
}

class UserProfileViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var other: User!
    
    var userProfileSections = [[UserProfileCell]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.backgroundColor = UIColor.backgroundGray
        self.tableView.contentInset = UIEdgeInsetsMake(30, 0, 50, 0)
        self.tableView.tableFooterView = UIView()
        self.populateSections()
    }
    
    func populateSections() {
        //--MARK: populate the cells
        userProfileSections = [[UserProfileCell]]()
        let profileSection = [UserProfileCell.profileTableCell(image: other.avatar!, text: other.nickname)]
        userProfileSections.append(profileSection)
    }
}

extension UserProfileViewController: UITableViewDataSource, UITableViewDelegate{
    func numberOfSections(in tableView: UITableView) -> Int {
        return userProfileSections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userProfileSections[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch userProfileSections[indexPath.section][indexPath.row] {
        case .profileTableCell(let image, let text):
            let cell = Bundle.main.loadNibNamed("ProfileTableViewCell", owner: self, options: nil)?.first as! ProfileTableViewCell
            cell.mainImageView.image = image
            cell.mainImageView.layer.cornerRadius = 4
            cell.mainLabel.text = text
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 20
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath as NSIndexPath).section == 0 {
            return 90
        }
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath as NSIndexPath).section == 0 {
            return 90
        }
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = UIColor.white
    }
    
    func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        view.tintColor = UIColor.clear
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
}
