//
//  FeedbackViewController.swift
//  uscfun
//
//  Created by Wenzheng Li on 3/10/17.
//  Copyright © 2017 Wenzheng Li. All rights reserved.
//

import UIKit

class FeedbackViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var sendButton: UIBarButtonItem!
    
    var infoLabel: UILabel!
    let heightOfInfoLabel = CGFloat(50.0)
    
    var feedback: String {
        get {
            return (textView.text ?? "").trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        }
        set {
            print("feedback is set")
            textView.text = newValue
            sendButton.isEnabled = !newValue.isEmpty
            UserDefaults.feedback = newValue
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        feedback = UserDefaults.feedback ?? ""
        textView.delegate = self
        textView.becomeFirstResponder()
        
        if let navigationBar = self.navigationController?.navigationBar {
            infoLabel = UILabel(frame: CGRect(x: 0.0, y: 0.0, width: navigationBar.frame.width, height: heightOfInfoLabel))
            infoLabel.backgroundColor = UIColor.themeYellow
            infoLabel.numberOfLines = 0
            infoLabel.textColor = UIColor.white
            infoLabel.alpha = 0.7
            infoLabel.textAlignment = .center
            navigationBar.addSubview(infoLabel)
            infoLabel.translatesAutoresizingMaskIntoConstraints = false
            infoLabel.isHidden = true
        }
        
        self.navigationController?.navigationBar.isTranslucent = false
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        infoLabel.isHidden = true
        infoLabel.frame.origin = CGPoint.zero
    }
    
    func displayInfo(succeeded: Bool) {
        self.infoLabel.isHidden = false
        if succeeded {
            self.infoLabel.backgroundColor = UIColor.green
            self.infoLabel.textColor = UIColor.themeYellow
            self.infoLabel.text = "您的反馈已经成功发送，感谢您对USC日常的支持！"
        } else {
            self.infoLabel.backgroundColor = UIColor.red
            self.infoLabel.textColor = UIColor.white
            self.infoLabel.text = "网络错误，请稍后重试"
        }
        
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseInOut, animations: {
            _ in
            if let navigationBar = self.navigationController?.navigationBar {
                self.infoLabel.frame.origin = CGPoint(x: 0.0, y: navigationBar.frame.height)
            }
        }) {
            completed in
            if completed {
                let delay = 1.5 * Double(NSEC_PER_SEC)
                let time = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC)
                DispatchQueue.main.asyncAfter(deadline: time) {
                    UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseInOut, animations: {
                        _ in
                        self.infoLabel.frame.origin = CGPoint.zero
                    }) {
                        finished in
                        if finished {
                            self.infoLabel.isHidden = true
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func sendFeedback(_ sender: UIBarButtonItem) {
        UserDefaults.sendFeedback {
            succeeded, error in
            if succeeded {
                self.feedback = ""
            } else {
                print(error?.localizedDescription ?? "unknown error while sending feedback")
                self.displayInfo(succeeded: false)
            }
        }
    }
}

extension FeedbackViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        if textView.markedTextRange == nil {
            feedback = textView.text
        }
    }
}
