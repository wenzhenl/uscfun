//
//  EventDetailViewController.swift
//  uscfun
//
//  Created by Wenzheng Li on 9/3/16.
//  Copyright © 2016 Wenzheng Li. All rights reserved.
//

import UIKit

class EventDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationController!.navigationBar.barTintColor = UIColor.buttonBlue()
        self.navigationController!.navigationBar.tintColor = UIColor.white
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white, NSFontAttributeName: UIFont.systemFont(ofSize: 20)]
        
        let negtivespacer = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: self, action: nil)
        negtivespacer.width = -16
        let backButton = UIBarButtonItem(image: #imageLiteral(resourceName: "back"), style: .plain, target: self, action: #selector(back))
        self.navigationItem.setLeftBarButtonItems([negtivespacer, backButton], animated: true)

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareEvent))
        self.view.backgroundColor = UIColor.backgroundGray()
        self.tableView.backgroundColor = UIColor.backgroundGray()
        self.tableView.tableFooterView = UIView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController!.isNavigationBarHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        self.navigationController!.isNavigationBarHidden = true
    }
    
    func shareEvent() {
        
    }
    
    func back() {
        let cv = self.navigationController?.popViewController(animated: true)
        cv?.navigationController?.navigationBar.barTintColor = UIColor.clear
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 200
        }
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 200
        }

        return UITableViewAutomaticDimension
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = Bundle.main.loadNibNamed("ImageViewTableViewCell", owner: self, options: nil)?.first as! ImageViewTableViewCell
            cell.mainImageView.image = #imageLiteral(resourceName: "calendar-6")
            return cell
        }
        else if indexPath.row >= 1 {
            let cell = Bundle.main.loadNibNamed("TextViewTableViewCell", owner: self, options: nil)?.first as! TextViewTableViewCell
            cell.textView.text = "周末去大华活动及附加按附件是打发；就；收到了非计算机打发时间爱上的解决类似的方式"
            return cell
        }
        else {
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = UIColor.white
    }
    
//    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
//        return 15
//    }
    
    //    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    //        if section == 0 {
    //            return 15
    //        }
    //        else if section == 1 {
    //            return 15
    //        } else {
    //            return 0
    //        }
    //    }
    
//    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
//        view.tintColor = UIColor.clear
//        let title = UILabel()
//        title.font = UIFont(name: "Futura", size: 10)!
//        title.textColor = UIColor.lightGray
//        
//        let header = view as! UITableViewHeaderFooterView
//        header.textLabel?.font=title.font
//        header.textLabel?.textColor=title.textColor
//        header.textLabel?.textAlignment = .left
//    }
//    
    func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        view.tintColor = UIColor.clear
    }
    
    //    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    //        if section == 0 {
    //            return "我加入的活动"
    //        }
    //        else if section == 1 {
    //            return "当前活动列表"
    //        } else {
    //            return nil
    //        }
    //    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
}
