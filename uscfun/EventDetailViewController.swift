//
//  EventDetailViewController.swift
//  uscfun
//
//  Created by Wenzheng Li on 9/3/16.
//  Copyright © 2016 Wenzheng Li. All rights reserved.
//

import UIKit

enum EventDetailCell {
    case imageViewTableCell(image: UIImage)
    case textViewTableCell(text: String)
    case singleButtonTableCell
    case imgKeyValueTableCell(image: UIImage, key: String, value: String)
}

class EventDetailViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var detailCells = [[EventDetailCell]]()
    
    let eventLocationKey = "活动地点"
    let mapSegueIdentifier = "SHOWMAP"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationController!.navigationBar.barTintColor = UIColor.buttonBlue
        self.navigationController!.navigationBar.tintColor = UIColor.themeYellow
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.themeYellow, NSFontAttributeName: UIFont.systemFont(ofSize: 20)]
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareEvent))
        self.view.backgroundColor = UIColor.backgroundGray
        self.tableView.backgroundColor = UIColor.backgroundGray
        self.tableView.tableFooterView = UIView()
        self.tableView.contentInset = UIEdgeInsetsMake(10, 0, 0, 0)
        
        // Populate the cells
        let firstSection = [EventDetailCell.imageViewTableCell(image: #imageLiteral(resourceName: "add-3")), .textViewTableCell(text: "Happy birthday to Jing Li")]
        let secondSection = [EventDetailCell.singleButtonTableCell]
        let thirdSection = [EventDetailCell.imgKeyValueTableCell(image: #imageLiteral(resourceName: "location"), key: "参与讨论", value: ">")]
        let forthSection = [EventDetailCell.imgKeyValueTableCell(image: #imageLiteral(resourceName: "alarm-clock"), key: "活动时间", value: "星期天上午"), .imgKeyValueTableCell(image: #imageLiteral(resourceName: "paper-plane-1"), key: eventLocationKey, value: "中国城大华超市")]
        detailCells.append(firstSection)
        detailCells.append(secondSection)
        detailCells.append(thirdSection)
        detailCells.append(forthSection)
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
        cv?.navigationController?.isNavigationBarHidden = true
    }
}

extension EventDetailViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return detailCells.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return detailCells[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch detailCells[indexPath.section][indexPath.row] {
        case .imageViewTableCell(let image):
            let cell = Bundle.main.loadNibNamed("ImageViewTableViewCell", owner: self, options: nil)?.first as! ImageViewTableViewCell
            cell.mainImageView.image = image
            return cell
        case .imgKeyValueTableCell(let image, let key, let value):
            let cell = Bundle.main.loadNibNamed("ImgKeyValueTableViewCell", owner: self, options: nil)?.first as! ImgKeyValueTableViewCell
            cell.mainImageView.image = image
            cell.keyLabel.text = key
            cell.valueLabel.text = value
            return cell
        case .singleButtonTableCell:
            let cell = Bundle.main.loadNibNamed("SingleButtonTableViewCell", owner: self, options: nil)?.first as! SingleButtonTableViewCell
            cell.button.layer.cornerRadius = 13
            cell.button.setTitle("报名参加", for: .normal)
            return cell
        case .textViewTableCell(let text):
            let cell = Bundle.main.loadNibNamed("TextViewTableViewCell", owner: self, options: nil)?.first as! TextViewTableViewCell
            cell.textView.text = text
            return cell
        }
    }
}

extension EventDetailViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch detailCells[indexPath.section][indexPath.row] {
        case .imageViewTableCell(_):
            return 200
        default:
            return UITableViewAutomaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        switch detailCells[indexPath.section][indexPath.row] {
        case .imageViewTableCell(_):
            return 200
        default:
            return UITableViewAutomaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        switch detailCells[indexPath.section][indexPath.row] {
        case .imageViewTableCell(_), .singleButtonTableCell:
            cell.backgroundColor = UIColor.clear
        default:
            cell.backgroundColor = UIColor.white
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        view.tintColor = UIColor.clear
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch detailCells[indexPath.section][indexPath.row] {
        case .imgKeyValueTableCell(_, let key, _):
            if key == eventLocationKey {
                performSegue(withIdentifier: mapSegueIdentifier, sender: self)
            }
        default:
            break
        }
        
        tableView.deselectRow(at: indexPath, animated: false)
    }
}
