//
//  Rating.swift
//  uscfun
//
//  Created by Wenzheng Li on 4/14/17.
//  Copyright © 2017 Wenzheng Li. All rights reserved.
//

import Foundation

class Rating {
    var rating: Double
    var targetEvent: Event
    var targetMember: AVUser
    var ratedBy: AVUser
    
    init(rating: Double, targetEvent: Event, targetMember: AVUser, ratedBy: AVUser) {
        self.rating = rating
        self.targetEvent = targetEvent
        self.targetMember = targetMember
        self.ratedBy = ratedBy
    }
    
    func submit(handler: @escaping (_ succeeded: Bool, _ error: NSError?) -> Void) {
        guard rating >= 0 else {
            print("failed to submit rating: rating cannot be negative")
            handler(false, NSError(domain: USCFunErrorConstants.domain, code: USCFunErrorConstants.kUSCFunErrorInvalidRating, userInfo: nil))
            return
        }
        
        let ratingObject = AVObject(className: RatingKeyConstants.classNameOfRating)
        ratingObject.setObject(rating, forKey: RatingKeyConstants.keyOfRating)
        let eventObject = AVObject(className: EventKeyConstants.classNameOfEvent, objectId: targetEvent.objectId!)
        ratingObject.setObject(eventObject, forKey: RatingKeyConstants.keyOfTargetEvent)
        ratingObject.setObject(targetMember, forKey: RatingKeyConstants.keyOfTargetMember)
        ratingObject.setObject(ratedBy, forKey: RatingKeyConstants.keyOfRatedBy)
        
        let query = AVQuery(className: RatingKeyConstants.classNameOfRating)
        query.whereKey(RatingKeyConstants.keyOfTargetEvent, equalTo: eventObject)
        query.whereKey(RatingKeyConstants.keyOfTargetMember, equalTo: targetMember)
        query.whereKey(RatingKeyConstants.keyOfRatedBy, equalTo: ratedBy)
        
        var error: NSError?
        let results = query.findObjects(&error)
        if error != nil {
            handler(false, error!)
            return
        }
        
        if results != nil && results!.count > 0 {
            handler(false, NSError(domain: USCFunErrorConstants.domain, code: USCFunErrorConstants.kUSCFunErrorDuplicateRating, userInfo: nil))
            return
        }
        
        if ratingObject.save(&error) {
            handler(true, nil)
        } else {
            handler(false, error)
        }
    }
}
