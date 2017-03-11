//
//  NicknameViewController.swift
//  uscfun
//
//  Created by Wenzheng Li on 8/26/16.
//  Copyright © 2016 Wenzheng Li. All rights reserved.
//

import UIKit

class NicknameViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var nicknameView: UIView!
    @IBOutlet weak var nicknameTextField: UITextField! {
        didSet {
            nicknameTextField.delegate = self
            nicknameTextField.addTarget(self, action: #selector(nicknameTextDidChanged), for: .editingChanged)
        }
    }
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var nextStepButtonItem: UIBarButtonItem!
    
    var nickname: String? {
        get {
            return nicknameTextField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        }
        set {
            nicknameTextField.text = newValue
            nextStepButtonItem.isEnabled = !(newValue ?? "").isWhitespaces
            UserDefaults.nickname = newValue?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        self.title = ""
        
        errorLabel.isHidden = true
        nickname = UserDefaults.nickname
        
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
        performSegue(withIdentifier: "go to password", sender: self)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        guard let nickname = nickname, !nickname.isWhitespaces else {
            errorLabel.isHidden = false
            return true
        }
      
        errorLabel.isHidden = true
        nicknameTextField.resignFirstResponder()
        performSegue(withIdentifier: "go to password", sender: self)
  
        return true
    }
    
    func nicknameTextDidChanged() {
        nickname = nicknameTextField.text
        print("current nickname: \(nickname)")
    }
}
