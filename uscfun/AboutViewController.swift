//
//  AboutViewController.swift
//  uscfun
//
//  Created by Wenzheng Li on 10/14/16.
//  Copyright © 2016 Wenzheng Li. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController {

    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var copyrightLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.view.backgroundColor = UIColor.white
        self.view.backgroundColor = UIColor.white
        self.title = "关于"
        versionLabel.text = "USC日常 2.0.7"
        copyrightLabel.text = "Copyright © 2016-2017 留学日常联盟"
    }
    @IBAction func goOpenSource(_ sender: UIButton) {
    }
}
