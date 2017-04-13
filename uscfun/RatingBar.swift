//
//  RatingBar.swift
//  uscfun
//
//  Created by Wenzheng Li on 4/13/17.
//  Copyright © 2017 Wenzheng Li. All rights reserved.
//

import UIKit

class RatingBar: UIView {
    @IBInspectable var rating: CGFloat = 0 {
        didSet {
            rating = max(rating, 0)
            rating = min(rating, ratingMax)
            delegate?.ratingDidChange(ratingBar: self, rating: rating)
            self.setNeedsLayout()
        }
    }
    @IBInspectable var ratingMax: CGFloat = 5.0
    @IBInspectable var numberOfStars: Int = 5
    @IBInspectable var shouldAnimate: Bool = false
    @IBInspectable var animationTimeInterval: TimeInterval = 0.2
    @IBInspectable var allowsPartialStar: Bool = false
    @IBInspectable var isIndicator: Bool = false
    
    @IBInspectable var brightStar: UIImage = #imageLiteral(resourceName: "bright-star")
    @IBInspectable var darkStar: UIImage = #imageLiteral(resourceName: "dark-star")
    
    var foregroundRatingView: UIView!
    var backgroundRatingView: UIView!
    
    var delegate: RatingBarDelegate?
    var isDrawn = false
    
    
}

protocol RatingBarDelegate {
    func ratingDidChange(ratingBar: RatingBar, rating: CGFloat)
}
