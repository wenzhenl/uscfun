//
//  BuildInClassExtension.swift
//  uscfun
//
//  Created by Wenzheng Li on 10/24/16.
//  Copyright © 2016 Wenzheng Li. All rights reserved.
//

import Foundation

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
        let grayLevel = CGFloat(240.0)
        return UIColor(red: grayLevel/255, green: grayLevel/255, blue: grayLevel/255, alpha: 1.0)
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
    
    //--MARK: Color for highlighting my ongoing events
    class var eventHighlighted: UIColor {
        return themeYellow
    }
    
    class var eventFinalized: UIColor {
        return UIColor.green
    }
    
    class var eventSecured: UIColor {
        return UIColor.themeYellow
    }
    
    class var eventPending: UIColor {
        return UIColor.red
    }
    
    class var lightGreen: UIColor {
        return UIColor(red: 1.0/255, green: 153.0/255, blue: 51/255, alpha: 0.3)
    }
}

extension String {
    
    var isConsistedOnlyWithSpace: Bool {
        let patternForEmptyString = "^\\s*$"
        if self.range(of: patternForEmptyString, options: .regularExpression) != nil {
            return true
        }
        return false
    }
    
    func isValidEmail() -> Bool {
        
        let emailRegEx = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: self)
    }
    
    func isEmpty() -> Bool {
        let patternForEmptyString = "^\\s*$"
        if self.range(of: patternForEmptyString, options: .regularExpression) != nil {
            return true
        }
        return false
    }
    
    func emailPrefix() -> String? {
        let delimiter = "@"
        let token = self.components(separatedBy: delimiter)
        if token.count > 1 {
            return token[0]
        } else {
            return nil
        }
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
