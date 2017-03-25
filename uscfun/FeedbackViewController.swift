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
    @IBOutlet weak var placeholderLabel: UILabel!
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
            placeholderLabel.text = newValue.isEmpty ? "请写下usc日常存在的问题，如果你有什么建议，也欢迎提供给我们" : ""
            UserDefaults.feedback = newValue
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        feedback = UserDefaults.feedback ?? ""
        self.automaticallyAdjustsScrollViewInsets = false
        textView.delegate = self
        textView.textContainer.lineFragmentPadding = 0
        textView.becomeFirstResponder()
        
        infoLabel = UILabel(frame: CGRect(x: 0.0, y: -heightOfInfoLabel, width: view.frame.size.width, height: heightOfInfoLabel))
        infoLabel.numberOfLines = 0
        infoLabel.textAlignment = .center
        infoLabel.lineBreakMode = .byWordWrapping
        infoLabel.font = UIFont.boldSystemFont(ofSize: 16)
        infoLabel.isHidden = true
        view.addSubview(infoLabel)
        
        /// important for animation to work properly
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
            self.infoLabel.backgroundColor = UIColor.white
            self.infoLabel.textColor = UIColor.buttonPink
            self.infoLabel.text = "您的反馈已经成功发送，感谢您对USC日常的支持！"
        } else {
            self.infoLabel.backgroundColor = UIColor.white
            self.infoLabel.textColor = UIColor.buttonPink
            self.infoLabel.text = "网络错误，请稍后重试"
        }
        
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseInOut, animations: {
            _ in
            self.infoLabel.frame.origin.y = 0.0
            self.view.layoutIfNeeded()
        }) {
            completed in
            if completed {
                let delay = 1.5 * Double(NSEC_PER_SEC)
                let time = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC)
                DispatchQueue.main.asyncAfter(deadline: time) {
                    UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseInOut, animations: {
                        _ in
                        self.infoLabel.frame.origin.y = -self.heightOfInfoLabel
                        self.view.layoutIfNeeded()
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
                self.displayInfo(succeeded: true)
            } else {
                print(error?.localizedDescription ?? "unknown error while sending feedback")
                self.displayInfo(succeeded: false)
            }
        }
    }
}

extension FeedbackViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        if placeholderLabel.text != "" && !textView.text.isEmpty {
            placeholderLabel.text = ""
        }
        
        if textView.markedTextRange == nil {
            feedback = textView.text
        }
    }
}
