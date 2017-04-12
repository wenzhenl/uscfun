//
//  BuildInClassExtension.swift
//  uscfun
//
//  Created by Wenzheng Li on 10/24/16.
//  Copyright © 2016 Wenzheng Li. All rights reserved.
//

import Foundation

extension UIViewController {
    var contentViewController: UIViewController {
        if let navcon = self as? UINavigationController {
            return navcon.visibleViewController!
        } else {
            return self
        }
    }
}

extension UIView {
    var screenshot: UIImage? {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, UIScreen.main.scale)
        drawHierarchy(in: self.bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
}


extension UIColor {
    class var themeYellow: UIColor {
        return UIColor(red: 1.0, green: 0.988, blue: 0.0, alpha: 1.0)
    }
    
    class func themeYellow(_ alpha: CGFloat) -> UIColor {
        return UIColor(red: 1.0, green: 0.988, blue: 0.0, alpha: alpha)
    }
    
    class var themeUSCRed: UIColor {
        return UIColor(red: 153.0/255, green: 27.0/255, blue: 30.0/255, alpha: 1.0)
    }
    
    class func themeUSCRed(_ alpha: CGFloat) -> UIColor {
        return UIColor(red: 153.0/255, green: 27.0/255, blue: 30.0/255, alpha: alpha)
    }
    
    class var backgroundGray: UIColor {
        return UIColor(red: 0.937255, green: 0.937255, blue: 0.956863, alpha: 1.0)
    }
    
    class var buttonPink: UIColor {
        return UIColor(red: 239.0/255, green: 31.0/255, blue: 85.0/255, alpha: 1.0)
    }
    
    class var buttonBlue: UIColor {
        return UIColor(red: 13.0/255, green: 179.0/255, blue: 224.0/255, alpha: 1.0)
    }
    
    //--MARK: Avatar background colors
    class var avatarGolden: UIColor {
        return UIColor(red: 255.0/255, green: 153.0/255, blue: 51/255, alpha: 1.0)
    }
    class var avatarBlue: UIColor {
        return UIColor(red: 0, green: 102.0/255, blue: 153.0/255, alpha: 1.0)
    }
    class var avatarCyan: UIColor {
        return UIColor(red: 2.0/255, green: 132.0/255, blue: 128.0/255, alpha: 1.0)
        
    }
    class var avatarOrange: UIColor {
        return UIColor(red: 255.0/255, green: 102.0/255, blue: 0, alpha: 1.0)
    }
    class var avatarPink: UIColor {
        return UIColor(red: 239.0/255, green: 31.0/255, blue: 85.0/255, alpha: 1.0)
    }
    class var avatarGreen: UIColor {
        return UIColor(red: 1.0/255, green: 153.0/255, blue: 51/255, alpha: 1.0)
    }
    class var avatarTomato: UIColor {
        return UIColor(red: 255.0/255, green: 99.0/255, blue: 71.0/255, alpha: 1.0)
    }
    class var avatarYellow: UIColor {
        return UIColor(red: 255.0/255, green: 218.0/255, blue: 68.0/255, alpha: 1.0)
    }
    /// additional 50 colors
    class var avatar1: UIColor {
        return UIColor(red: 105/255.0, green: 210/255.0, blue: 231/255.0, alpha: 1.0)
    }
    class var avatar2: UIColor {
        return UIColor(red: 167/255.0, green: 219/255.0, blue: 219/255.0, alpha: 1.0)
    }
    class var avatar3: UIColor {
        return UIColor(red: 237/255.0, green: 228/255.0, blue: 204/255.0, alpha: 1.0)
    }
    class var avatar4: UIColor {
        return UIColor(red: 243/255.0, green: 134/255.0, blue: 48/255.0, alpha: 1.0)
    }
    class var avatar5: UIColor {
        return UIColor(red: 250/255.0, green: 105/255.0, blue: 0/255.0, alpha: 1.0)
    }
    class var avatar6: UIColor {
        return UIColor(red: 233/255.0, green: 76/255.0, blue: 111/255.0, alpha: 1.0)
    }
    class var avatar7: UIColor {
        return UIColor(red: 84/255.0, green: 39/255.0, blue: 51/255.0, alpha: 1.0)
    }
    class var avatar8: UIColor {
        return UIColor(red: 90/255.0, green: 106/255.0, blue: 98/255.0, alpha: 1.0)
    }
    class var avatar9: UIColor {
        return UIColor(red: 198/255.0, green: 213/255.0, blue: 205/255.0, alpha: 1.0)
    }
    class var avatar10: UIColor {
        return UIColor(red: 253/255.0, green: 242/255.0, blue: 0/255.0, alpha: 1.0)
    }
    class var avatar11: UIColor {
        return UIColor(red: 219/255.0, green: 51/255.0, blue: 64/255.0, alpha: 1.0)
    }
    class var avatar12: UIColor {
        return UIColor(red: 232/255.0, green: 183/255.0, blue: 26/255.0, alpha: 1.0)
    }
    class var avatar13: UIColor {
        return UIColor(red: 247/255.0, green: 234/255.0, blue: 200/255.0, alpha: 1.0)
    }
    class var avatar14: UIColor {
        return UIColor(red: 31/255.0, green: 218/255.0, blue: 154/255.0, alpha: 1.0)
    }
    class var avatar15: UIColor {
        return UIColor(red: 40/255.0, green: 171/255.0, blue: 227/255.0, alpha: 1.0)
    }
    class var avatar16: UIColor {
        return UIColor(red: 88/255.0, green: 140/255.0, blue: 115/255.0, alpha: 1.0)
    }
    class var avatar17: UIColor {
        return UIColor(red: 242/255.0, green: 227/255.0, blue: 148/255.0, alpha: 1.0)
    }
    class var avatar18: UIColor {
        return UIColor(red: 242/255.0, green: 174/255.0, blue: 114/255.0, alpha: 1.0)
    }
    class var avatar19: UIColor {
        return UIColor(red: 217/255.0, green: 100/255.0, blue: 89/255.0, alpha: 1.0)
    }
    class var avatar20: UIColor {
        return UIColor(red: 220/255.0, green: 64/255.0, blue: 56/255.0, alpha: 1.0)
    }
    class var avatar21: UIColor {
        return UIColor(red: /255.0, green: /255.0, blue: /255.0, alpha: 1.0)
    }
    class var avatar22: UIColor {
        return UIColor(red: /255.0, green: /255.0, blue: /255.0, alpha: 1.0)
    }
    class var avatar23: UIColor {
        return UIColor(red: /255.0, green: /255.0, blue: /255.0, alpha: 1.0)
    }
    class var avatar24: UIColor {
        return UIColor(red: /255.0, green: /255.0, blue: /255.0, alpha: 1.0)
    }
    class var avatar25: UIColor {
        return UIColor(red: /255.0, green: /255.0, blue: /255.0, alpha: 1.0)
    }
    class var avatar26: UIColor {
        return UIColor(red: /255.0, green: /255.0, blue: /255.0, alpha: 1.0)
    }
    class var avatar27: UIColor {
        return UIColor(red: /255.0, green: /255.0, blue: /255.0, alpha: 1.0)
    }
    class var avatar28: UIColor {
        return UIColor(red: /255.0, green: /255.0, blue: /255.0, alpha: 1.0)
    }
    class var avatar29: UIColor {
        return UIColor(red: /255.0, green: /255.0, blue: /255.0, alpha: 1.0)
    }
    class var avatar30: UIColor {
        return UIColor(red: /255.0, green: /255.0, blue: /255.0, alpha: 1.0)
    }
    class var avatar31: UIColor {
        return UIColor(red: /255.0, green: /255.0, blue: /255.0, alpha: 1.0)
    }
    class var avatar32: UIColor {
        return UIColor(red: /255.0, green: /255.0, blue: /255.0, alpha: 1.0)
    }
    class var avatar33: UIColor {
        return UIColor(red: /255.0, green: /255.0, blue: /255.0, alpha: 1.0)
    }
    class var avatar34: UIColor {
        return UIColor(red: /255.0, green: /255.0, blue: /255.0, alpha: 1.0)
    }
    class var avatar35: UIColor {
        return UIColor(red: /255.0, green: /255.0, blue: /255.0, alpha: 1.0)
    }
    class var avatar36: UIColor {
        return UIColor(red: /255.0, green: /255.0, blue: /255.0, alpha: 1.0)
    }
    class var avatar37: UIColor {
        return UIColor(red: /255.0, green: /255.0, blue: /255.0, alpha: 1.0)
    }
    class var avatar38: UIColor {
        return UIColor(red: /255.0, green: /255.0, blue: /255.0, alpha: 1.0)
    }
    class var avatar39: UIColor {
        return UIColor(red: /255.0, green: /255.0, blue: /255.0, alpha: 1.0)
    }
    class var avatar40: UIColor {
        return UIColor(red: /255.0, green: /255.0, blue: /255.0, alpha: 1.0)
    }
    class var avatar41: UIColor {
        return UIColor(red: /255.0, green: /255.0, blue: /255.0, alpha: 1.0)
    }
    class var avatar42: UIColor {
        return UIColor(red: /255.0, green: /255.0, blue: /255.0, alpha: 1.0)
    }
    class var avatar43: UIColor {
        return UIColor(red: /255.0, green: /255.0, blue: /255.0, alpha: 1.0)
    }
    class var avatar44: UIColor {
        return UIColor(red: /255.0, green: /255.0, blue: /255.0, alpha: 1.0)
    }
    class var avatar45: UIColor {
        return UIColor(red: /255.0, green: /255.0, blue: /255.0, alpha: 1.0)
    }
    class var avatar46: UIColor {
        return UIColor(red: /255.0, green: /255.0, blue: /255.0, alpha: 1.0)
    }
    class var avatar47: UIColor {
        return UIColor(red: /255.0, green: /255.0, blue: /255.0, alpha: 1.0)
    }
    class var avatar48: UIColor {
        return UIColor(red: /255.0, green: /255.0, blue: /255.0, alpha: 1.0)
    }
    class var avatar49: UIColor {
        return UIColor(red: /255.0, green: /255.0, blue: /255.0, alpha: 1.0)
    }
    class var avatar50: UIColor {
        return UIColor(red: /255.0, green: /255.0, blue: /255.0, alpha: 1.0)
    }

    //--MARK: Color for highlighting my ongoing events
    class var eventHighlighted: UIColor {
        return themeYellow
    }
    
    class var eventFinalized: UIColor {
        return UIColor.green
    }
    
    class var eventSecured: UIColor {
        return UIColor.yellow
    }
    
    class var eventPending: UIColor {
        return UIColor.red
    }
    
    class var lightGreen: UIColor {
        return UIColor(red: 1.0/255, green: 153.0/255, blue: 51/255, alpha: 0.3)
    }
}

typealias Email = String

extension Email {
    
    var isValid: Bool {
        let emailRegEx = "^[a-zA-Z0-9._-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"

        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: self)
    }
    
    var prefix: String? {
        guard self.isValid else { return nil }
        let delimiter = "@"
        let token = self.components(separatedBy: delimiter)
        guard token.count == 2 else { return nil }
        return token[0]
    }
    
    var suffix: String? {
        guard self.isValid else { return nil }
        let delimiter = "@"
        let token = self.components(separatedBy: delimiter)
        guard token.count == 2 else { return nil }
        return token[1]
    }
    
    /// The assumed email format is as "wenzhenl@cs.usc.edu"
    /// The instituion code should be immediate prefix of .edu
    var institutionCode: String? {
        guard self.isValid else { return nil }
        let delimiter = "@"
        let token = self.components(separatedBy: delimiter)
        guard token.count == 2 else { return nil }
        let dot = "."
        let dotToken = token[1].components(separatedBy: dot)
        guard dotToken.count >= 2 else { return nil }
        return dotToken[dotToken.count - 2]
    }
    
    var replaceAtAndDotByUnderscore: String? {
        guard self.isValid else { return nil }
        let delimiter = "@"
        let token = self.components(separatedBy: delimiter)
        guard token.count == 2 else { return nil }
        let dot = "."
        let dotToken = token[1].components(separatedBy: dot)
        guard dotToken.count >= 2 else { return nil }
        return token[0] + "_" + dotToken.joined(separator: "_")
    }
    
    var systemClientId: String? {
        if replaceAtAndDotByUnderscore != nil {
            return replaceAtAndDotByUnderscore! + "_sys"
        }
        return nil
    }
}

extension String {
    
    var isWhitespaces: Bool {
        let patternForEmptyString = "^\\s*$"
        if self.range(of: patternForEmptyString, options: .regularExpression) != nil {
            return true
        }
        return false
    }
    
    func letterImage(textColor: UIColor, backgroundColor: UIColor, width: CGFloat, height: CGFloat) -> UIImage? {
        let capitalizedText = self.uppercased()
        let trimmedText = capitalizedText.trimmingCharacters(in: .whitespaces)
        guard !trimmedText.isEmpty else {   return nil }
        var image = UIImage()
        let label = UILabel()
        label.frame.size = CGSize(width: width, height: height)
        label.textColor = textColor
        label.backgroundColor = backgroundColor
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: width / 2.0)
        
        let fullNameArray = trimmedText.components(separatedBy: " ")
        guard fullNameArray.count > 0 else {
            return nil
        }
        if fullNameArray.count == 1 {
            label.text = String(trimmedText.characters.first!)
        } else {
            let firstName = fullNameArray.first
            let lastName = fullNameArray.last
            label.text = String(describing: firstName!.characters.first!) + String(describing: lastName!.characters.first!)
        }
        UIGraphicsBeginImageContextWithOptions(label.frame.size, true, 0.0)
        label.layer.render(in: UIGraphicsGetCurrentContext()!)
        image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
}

extension UIImage {
    func scaleTo(width: CGFloat, height: CGFloat) -> UIImage {
        let newSize = CGSize(width: width, height: height)
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        self.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
}

extension Date {
    var humanReadable: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: self)
    }
    
    var fullStyle: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .short
        return formatter.string(from: self)
    }
    
    var readableDate: String {
        let fullTime = self.fullStyle
        if NSLocale.preferredLanguages.first == "zh-Hans-US" {
            let dateAndTime = fullTime.components(separatedBy: " ")
            return dateAndTime[0] + " " + dateAndTime[1]
        }
        else if NSLocale.preferredLanguages.first == "en-US" {
            let dateAndTime = fullTime.components(separatedBy: " at ")
            let date = dateAndTime.first!
            let deleteYear = date.components(separatedBy: ", ")
            return deleteYear.first! + ", " + deleteYear[1]
        } else {
            return ""
        }
    }
    
    var readableTime: String {
        let fullTime = self.fullStyle
        if NSLocale.preferredLanguages.first == "zh-Hans-US" {
            let dateAndTime = fullTime.components(separatedBy: " ")
            return dateAndTime[2]
        }
        else if NSLocale.preferredLanguages.first == "en-US" {
            let dateAndTime = fullTime.components(separatedBy: " at ")
            let time = dateAndTime.last
            return time ?? ""
        } else {
            return ""
        }
    }
    
    var gapFromNow: String {
        let currentDate = Date()
         let diffDateComponents = Calendar.current.dateComponents([Calendar.Component.day,.hour,.minute], from: currentDate, to: self)
        var days = "", hours = "", minutes = ""
        if let day = diffDateComponents.day {
            if day > 0 {
                if day < 10 {
                    days = "0\(day)天"
                } else {
                    days = "\(day)天"
                }
            }
        }
        
        if let hour = diffDateComponents.hour {
            if hour > 0 {
                if hour < 10 {
                    hours = "0\(hour)小时"
                } else {
                    hours = "\(hour)小时"
                }
            }
        }
        
        if let minute = diffDateComponents.minute {
            if minute > 0 {
                if minute < 10 {
                    minutes = "0\(minute)分钟"
                } else {
                    minutes = "\(minute)分钟"
                }
            }
        }
        
        return days + hours + minutes
    }
}
