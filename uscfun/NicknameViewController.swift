//
//  NicknameViewController.swift
//  uscfun
//
//  Created by Wenzheng Li on 8/26/16.
//  Copyright © 2016 Wenzheng Li. All rights reserved.
//

import UIKit
import SVProgressHUD

class NicknameViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var nicknameView: UIView!
    @IBOutlet weak var nicknameTextField: UITextField! {
        didSet {
            nicknameTextField.delegate = self
            nicknameTextField.addTarget(self, action: #selector(nicknameTextDidChanged(textField:)), for: .editingChanged)
        }
    }
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var nextStepButtonItem: UIBarButtonItem!
    
    var nickname: String? {
        get {
            return nicknameTextField.text
        }
        set {
            nicknameTextField.text = newValue
            UserDefaults.newNickname = newValue
            nextStepButtonItem.isEnabled = !(newValue ?? "").isWhitespaces
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        self.title = ""
        
        errorLabel.isHidden = true
        nickname = UserDefaults.newNickname
        
        if DeviceType.IS_IPHONE_4_OR_LESS {
            containerView.transform = CGAffineTransform(translationX: 0,y: -80)
        }
        if DeviceType.IS_IPHONE_4_OR_LESS || DeviceType.IS_IPHONE_5 {
            nicknameTextField.placeholder = "你的昵称"
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        nicknameTextField.becomeFirstResponder()
    }
    
    @IBAction func goNext(_ sender: UIBarButtonItem) {
        join()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let nickname = nickname, !nickname.isWhitespaces else {
            errorLabel.isHidden = false
            return true
        }
        join()
        return true
    }
    
    func join() {
        errorLabel.isHidden = true
        
        nicknameTextField.resignFirstResponder()
        SVProgressHUD.show()
        
        do {
            try LoginKit.signUp()
            SVProgressHUD.dismiss()
            print("sign up successfully")
            EventRequest.preLoadData(inBackground: true)
            let appDelegate = UIApplication.shared.delegate! as! AppDelegate
            let initialViewController = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()
            appDelegate.window?.rootViewController = initialViewController
            appDelegate.window?.makeKeyAndVisible()
        } catch let error {
            SVProgressHUD.dismiss()
            nicknameTextField.becomeFirstResponder()
            errorLabel.text = error.localizedDescription
            errorLabel.isHidden = false
        }
    }
    
    func nicknameTextDidChanged(textField: UITextField) {
        
        if textField.markedTextRange == nil {
            nickname = nicknameTextField.text
            print("current nickname: \(nickname)")
        }
        
        errorLabel.isHidden = true
    }
}
