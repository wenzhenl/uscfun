//
//  AboutViewController.swift
//  uscfun
//
//  Created by Wenzheng Li on 10/14/16.
//  Copyright © 2016 Wenzheng Li. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var copyrightLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.view.backgroundColor = UIColor.white
        self.view.backgroundColor = UIColor.white
        self.title = "关于"
        tableView.contentInset = UIEdgeInsetsMake(20, 0, 0, 0)
        tableView.separatorStyle = .none
        copyrightLabel.text = "Copyright © 2016-2017 留学日常联盟"
    }
    @IBAction func goOpenSource(_ sender: UIButton) {
    }
}

extension AboutViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 270
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "versioncell")
        let imageView = cell?.viewWithTag(1) as! UIImageView
        imageView.image = #imageLiteral(resourceName: "blackfish")
        let versionLabel = cell?.viewWithTag(2) as! UILabel
        versionLabel.text = "USC日常 2.0.7"
        versionLabel.textColor = UIColor.buttonPink
        versionLabel.textAlignment = .center
        return cell!
    }
}

