//
//  CardViewController.swift
//  uscfun
//
//  Created by Wenzheng Li on 4/11/17.
//  Copyright © 2017 Wenzheng Li. All rights reserved.
//

import UIKit

class CardViewController: UIViewController {

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var button: UIButton!
    
    var pageIndex: Int?
    var welcomeCard: WelcomeCard?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.themeYellow
        label.isHidden = true
        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .extraLight))
        blurView.frame = view.bounds
        view.addSubview(blurView)
        imageView.image = welcomeCard?.image
        view.bringSubview(toFront: imageView)
        view.bringSubview(toFront: button)
    }
}
