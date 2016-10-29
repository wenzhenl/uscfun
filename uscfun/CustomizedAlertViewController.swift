//
//  CustomizedAlertViewController.swift
//  uscfun
//
//  Created by Wenzheng Li on 10/28/16.
//  Copyright © 2016 Wenzheng Li. All rights reserved.
//

import UIKit

protocol CustomizedAlertViewDelegate {
    func withdraw()
}

class CustomizedAlertViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var delegate: CustomizedAlertViewDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = UIColor.backgroundGray
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(withdraw(sender:)))
        tapGesture.delegate = self
        self.view.addGestureRecognizer(tapGesture)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        self.tableView.frame = CGRect(x: tableView.frame.origin.x, y: self.view.frame.height - tableView.contentSize.height, width: tableView.frame.width, height: tableView.contentSize.height)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.tableView.frame = CGRect(x: tableView.frame.origin.x, y: self.view.frame.height - tableView.contentSize.height, width: tableView.frame.width, height: tableView.contentSize.height)
        self.tableView.reloadData()
    }
    
    func withdraw(sender: UITapGestureRecognizer) {
        let tappedPoint = sender.location(in: self.view)
        if !tableView.frame.contains(tappedPoint) {
            self.delegate?.withdraw()
            self.presentingViewController?.dismiss(animated: true, completion: nil)
        }
    }
}

extension CustomizedAlertViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if (gestureRecognizer.view!.isDescendant(of: self.tableView)) {
            return true
        } else {
            return false
        }
    }
}

extension CustomizedAlertViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("selected")
        if indexPath.section == 2 {
            self.delegate?.withdraw()
            self.presentingViewController?.dismiss(animated: true, completion: nil)
        }
    }
}

extension CustomizedAlertViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 2 {
            let cell = UITableViewCell()
            cell.textLabel?.text = "取消"
            cell.textLabel?.textAlignment = .center
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "button share cell") as! ButtonShareTableViewCell
        return cell
    }
}
