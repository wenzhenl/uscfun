//
//  RateEventViewController.swift
//  uscfun
//
//  Created by Wenzheng Li on 4/13/17.
//  Copyright © 2017 Wenzheng Li. All rights reserved.
//

import UIKit
import SVProgressHUD

class RateEventViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var submitButton: UIButton!
    
    var event: Event!
    var otherMembers = [AVUser]()
    var otherMemberScore = [CGFloat]()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "评价队友"
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)

        self.tableView.scrollsToTop = true
        self.tableView.tableFooterView = UIView()
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 50, 0)
        self.tableView.separatorStyle = .none
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
        var ratings = [Rating]()
        for i in 0..<otherMemberScore.count {
            let rating = Rating(rating: Double(otherMemberScore[i]), targetEvent: event, targetMember: otherMembers[i], ratedBy: AVUser.current()!)
            ratings.append(rating)
        }
        submitButton.isEnabled = false
        Rating.submitAll(ratings: ratings) {
            succeeded, error in
            if succeeded {
                print("submit ratings successfully")
                SVProgressHUD.showSuccess(withStatus: "提交成功")
                SVProgressHUD.dismiss(withDelay: TimeInterval(1.5))
                self.presentingViewController?.dismiss(animated: true, completion: nil)
            }
            
            if error != nil {
                print("failed to submit ratings: \(error!)")
                self.submitButton.isEnabled = true
                SVProgressHUD.showInfo(withStatus: "网络错误")
                SVProgressHUD.dismiss(withDelay: TimeInterval(1.5))
            }
        }
    }
}

extension RateEventViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return otherMembers.count + 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell = Bundle.main.loadNibNamed("TextViewTableViewCell", owner: self, options: nil)?.first as! TextViewTableViewCell
            cell.textView.delegate = self
            cell.textView.isSelectable = true
            cell.textView.textColor = UIColor.darkText
            let notice = "USC小管家提醒您：\n活动结束后，互相评价可以提升信用等级。评价标准为一到五颗星，注意一颗星表明该成员是无故爽约！关于信用等级的详细内容，请参见【信用等级说明】"
            let attributedNotice = NSMutableAttributedString(string: notice)
            let rangeOfNotice = (notice as NSString).range(of: notice)
            attributedNotice.addAttributes([NSFontAttributeName: UIFont.systemFont(ofSize: 15)], range: rangeOfNotice)
            attributedNotice.addAttributes([NSForegroundColorAttributeName: UIColor.darkGray], range: rangeOfNotice)
            let oneStarAlert = "注意一颗星表明该成员是无故爽约！"
            let rangeOfOneStarAlert = (notice as NSString).range(of: oneStarAlert)
            attributedNotice.addAttributes([NSFontAttributeName: UIFont.boldSystemFont(ofSize: 15)], range: rangeOfOneStarAlert)
            let creditLink = "信用等级说明"
            let rangeOfCreditLink = (notice as NSString).range(of: creditLink)
            attributedNotice.addAttributes([NSForegroundColorAttributeName: UIColor.blue], range: rangeOfCreditLink)
            attributedNotice.addAttributes([NSLinkAttributeName: USCFunConstants.creditRecordURL], range: rangeOfCreditLink)
            cell.textView.attributedText = attributedNotice
            cell.selectionStyle = .none
            return cell

        } else {
            let cell = Bundle.main.loadNibNamed("RateMemberTableViewCell", owner: self, options: nil)?.first as! RateMemberTableViewCell
            let user = User(user: otherMembers[indexPath.section - 1])
            cell.avatarImageView.clipsToBounds = true
            cell.avatarImageView.layer.cornerRadius = cell.avatarImageView.frame.size.height / 2.0
            cell.avatarImageView.image = user?.avatar
            cell.nickNameLabel.text = user?.nickname
            cell.ratingBar.tag = indexPath.section - 1
            cell.ratingBar.delegate = self
            cell.ratingBar.ratingMin = 1.0
            cell.ratingBar.rating = otherMemberScore[indexPath.section - 1]
            cell.ratingBar.shouldAnimate = true
            cell.selectionStyle = .none
            return cell
        }
    }
}

extension RateEventViewController: RatingBarDelegate {
    func ratingDidChange(ratingBar: RatingBar, rating: CGFloat) {
        print("rating did change")
        otherMemberScore[ratingBar.tag] = rating
    }
}

extension RateEventViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        print("link clicked")
        if URL.scheme == "http" || URL.scheme == "https" {
            if let webVC = UIStoryboard(name: "Login", bundle: nil).instantiateViewController(withIdentifier: USCFunConstants.storyboardIdentifierOfWebViewController) as? WebViewController {
                webVC.url = URL
                self.navigationController?.pushViewController(webVC, animated: true)
            }
            return false
        }
        return true
    }
}
