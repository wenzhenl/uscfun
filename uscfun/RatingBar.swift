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
    
    func createRatingView(_ image: UIImage) -> UIView {
        let view = UIView(frame: self.bounds)
        view.clipsToBounds = true
        view.backgroundColor = UIColor.clear
        for position in 0 ..< numberOfStars {
            let imageView = UIImageView(image: image)
            imageView.frame = CGRect(x: CGFloat(position) * self.bounds.size.width / CGFloat(numberOfStars), y: 0, width: self.bounds.size.width / CGFloat(numberOfStars), height: self.bounds.size.height)
            imageView.contentMode = .scaleAspectFit
            view.addSubview(imageView)
        }
        return view
    }
    
    func animateRatingChange() {
        let ratingScoreInRatio = self.rating / self.ratingMax
        self.foregroundRatingView.frame = CGRect(x: 0, y: 0, width: self.bounds.size.width * ratingScoreInRatio, height: self.bounds.size.height)
    }
    
    func rateViewTapped(sender: UITapGestureRecognizer) {
        if isIndicator { return }
        let tapPoint = sender.location(in: self)
        let offset = tapPoint.x
        let ratingScore = offset / self.bounds.size.width * ratingMax
        self.rating = self.allowsPartialStar ? ratingScore : round(ratingScore)
    }
    
    func buildView() {
        if isDrawn { return }
        isDrawn = true
        self.backgroundRatingView = self.createRatingView(darkStar)
        self.foregroundRatingView = self.createRatingView(brightStar)
        animateRatingChange()
        self.addSubview(self.backgroundRatingView)
        self.addSubview(self.foregroundRatingView)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(rateViewTapped))
        tapGesture.numberOfTapsRequired = 1
        self.addGestureRecognizer(tapGesture)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        buildView()
        let animationTimeInterval = self.shouldAnimate ? self.animationTimeInterval : 0
        UIView.animate(withDuration: animationTimeInterval, animations: {
            self.animateRatingChange()
        })
    }
}

protocol RatingBarDelegate {
    func ratingDidChange(ratingBar: RatingBar, rating: CGFloat)
}
