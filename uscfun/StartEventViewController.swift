//
//  StartEventViewController.swift
//  uscfun
//
//  Created by Wenzheng Li on 9/4/16.
//  Copyright © 2016 Wenzheng Li. All rights reserved.
//

import UIKit
import AVOSCloud
import SVProgressHUD
//import Eureka

class StartEventViewController: UIViewController {
    @IBOutlet weak var cancleButton: UIBarButtonItem!
    @IBOutlet weak var postButton: UIBarButtonItem!
    
    var delegate: EventMemberStatusDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isTranslucent = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        UIApplication.shared.statusBarStyle = .default
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    @IBAction func close() {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func postEvent() {
        
        let events = [("去滑雪有人有兴趣么", EventType.entertainment),
                          ("准备去大华shopping，有兴趣的走起", EventType.shopping),
                          ("暑假有人回国的么，想要组队", EventType.other),
                          ("八月份阿黛尔演唱会有人有兴趣么，有兴趣大家组织一下吧，准备好了好一起买票", EventType.entertainment),
                          ("有人还没有去过黄石的么， 这个春假有人要一起么", EventType.travel),
                          ("打牌三缺一，有兴趣的速来", EventType.entertainment),
                          ("过年了打个麻将有人会么", EventType.entertainment),
                          ("新上映的电影《从你的全世界路过》，听过很不错，有人要一起去看吗", EventType.entertainment),
                          ("中午有人有兴趣carpool一起去韩国城吃个饭么", EventType.foodAndDrink),
                          ("新开的这家店石器时代很不错，有兴趣一起组个队去吃么，团购有优惠",EventType.foodAndDrink)]
        
        let randIndex = Int(arc4random_uniform(UInt32(events.count)))
        let event = Event(name: events[randIndex].0, type: events[randIndex].1, totalSeats: 4, remainingSeats: 1, minimumAttendingPeople: 4, due: Date(timeIntervalSinceNow: 12345), creator: AVUser.current())
        event.startTime = Date(timeIntervalSinceNow: 45678)
        event.endTime = Date(timeIntervalSinceNow: 55890)
        let yesorno = Int(arc4random_uniform(2))
        if yesorno == 1 {
        event.note = "需要3-4人，准备Airbnb，希望大家多穿些衣服注意保暖。另外我们还可以一起打打牌什么的，会玩牌的更加好了。重要的事情说三遍：需要3-4人，准备Airbnb，希望大家多穿些衣服注意保暖。另外我们还可以一起打打牌什么的，会玩牌的更加好了。需要3-4人，准备Airbnb，希望大家多穿些衣服注意保暖。另外我们还可以一起打打牌什么的，会玩牌的更加好了"
        }
        event.expectedFee = 12.34
        event.transportationMethod = .uber
        event.locationName = "Ellendale Pl"
        event.location = AVGeoPoint(latitude: 34.0090, longitude: -118.4974)
        event.post() {
            succeeded, error in
            SVProgressHUD.dismiss()
            if succeeded {
                self.delegate?.userDidPostEvent()
                self.presentingViewController?.dismiss(animated: true, completion: nil)
            } else {
                self.cancleButton.isEnabled = true
                self.postButton.isEnabled = true
            }
        }
        cancleButton.isEnabled = false
        postButton.isEnabled = false
        SVProgressHUD.show()
    }
}

//class StartEventViewController: FormViewController {
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        form +++ Section("*活动名称")
//            <<< TextAreaRow("eventTitle") {
//                $0.placeholder = "例如: 中午去中国城吃饭有人去么"
//            }
//            
//            +++ Section()
//
//            <<< AlertRow<String> ("eventType") {
//                $0.title = "*活动类型"
//                $0.selectorTitle = "活动类型"
//                $0.options = ["吃饭","购物","娱乐","学习","其他"]
//                $0.value = "其他"
//            }
//            +++ Section("*活动人数")
//            <<< IntRow("totalSeats") {
//                $0.title = "全部席位(包括自己)"
//                $0.placeholder = "0"
//            }
//            <<< IntRow("remainingSeats") {
//                $0.title = "剩余席位"
//                $0.placeholder = "0"
//            }
//            <<< IntRow("minimumMoreAttendingPeople") {
//                $0.title = "至少还需要报名人数"
//                $0.placeholder = "0"
//            }
//            +++ Section(header: "", footer: "报名截止后没有达到最少报名人数的活动会自动解散")
//            <<< DateTimeRow("due"){
//                $0.title = "*报名截止时间"
//                $0.value = NSDate()
//            }
//            +++ Section("高级设置(选填)")
//            <<< DateTimeRow("eventStartTime"){
//                $0.title = "活动开始时间"
//                $0.value = NSDate()
//            }
//            <<< DateTimeRow("eventEndTime"){
//                $0.title = "活动结束时间"
//                $0.value = NSDate()
//            }
//            <<< TextRow("eventLocation") {
//                $0.title = "活动地点"
//                $0.placeholder = "待定"
//            }
//            <<< DecimalRow("expectedFee") {
//                $0.title = "预计费用"
//                $0.placeholder = "0.0"
//            }
//            
//            <<< AlertRow<String> ("transportationMethod") {
//                $0.title = "出行方式"
//                $0.selectorTitle = "出行方式"
//                $0.options = ["自驾","Uber","待定"]
//                $0.value = "待定"
//            }
//            
//            +++ Section("其他需要说明的情况(选填)")
//            <<< TextAreaRow("note"){ row in
//                row.placeholder = "比如需不需要带现金，户外活动需要什么样的装备等等"
//            }
//    }
//    
//    override func viewWillAppear(animated: Bool) {
//        super.viewWillAppear(true)
//        UIApplication.sharedApplication().statusBarStyle = .Default
//    }
//    
//    override func viewWillDisappear(animated: Bool) {
//        super.viewWillDisappear(true)
//        UIApplication.sharedApplication().statusBarStyle = .LightContent
//        self.view.endEditing(true)
//    }
//    
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//        // Dispose of any resources that can be recreated.
//    }
//    
//    @IBAction func close() {
//        
//        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
//    }
//
//    @IBAction func postEvent(sender: UIBarButtonItem) {
//        print("\(eventTitle)")
//        print("\(eventType)")
//        print("\(totalSeats)")
//        print("\(remainingSeats)")
//        print("\(minimumMoreAttendingPeople)")
//        print("\(due)")
//        print("\(eventStartTime)")
//        print("\(eventEndTime)")
//        print("\(eventLocation)")
//        print("\(expectedFee)")
//        print("\(transportationMethod)")
//        print("\(note)")
//        
//        let event = AVObject(className: "Event")
//        event.setObject(eventTitle, forKey: "title")
//        event.setObject(due, forKey: "due")
//        event.saveInBackgroundWithBlock() {
//            succceeded, error in
//                if succceeded {
//                    print("successful")
//                } else {
//                    print(error)
//                }
//        }
//    }
//    //MARK: - values for all rows
//    var eventTitle: String? {
//        get {
//            return (form.rowByTag("eventTitle") as! TextAreaRow).value
//        }
//        set {
//            (form.rowByTag("eventTitle") as! TextAreaRow).value = newValue
//        }
//    }
//    
//    var eventType: String? {
//        get {
//            return (form.rowByTag("eventType") as! AlertRow).value
//        }
//        set {
//            (form.rowByTag("eventType") as! AlertRow).value = newValue
//        }
//    }
//    
//    var totalSeats: Int? {
//        get {
//            return (form.rowByTag("totalSeats") as! IntRow).value
//        }
//        set {
//            (form.rowByTag("totalSeats") as! IntRow).value = newValue
//        }
//    }
//    
//    var remainingSeats: Int? {
//        get {
//            return (form.rowByTag("remainingSeats") as! IntRow).value
//        }
//        set {
//            (form.rowByTag("remainingSeats") as! IntRow).value = newValue
//        }
//    }
//    
//    var minimumMoreAttendingPeople: Int? {
//        get {
//            return (form.rowByTag("minimumMoreAttendingPeople") as! IntRow).value
//        }
//        set {
//            (form.rowByTag("minimumMoreAttendingPeople") as! IntRow).value = newValue
//        }
//    }
//    
//    var due: NSDate? {
//        get {
//            return (form.rowByTag("due") as! DateTimeRow).value
//        }
//        set {
//            (form.rowByTag("due") as! DateTimeRow).value = newValue
//        }
//    }
//    
//    var eventStartTime: NSDate? {
//        get {
//            return (form.rowByTag("eventStartTime") as! DateTimeRow).value
//        }
//        set {
//            (form.rowByTag("eventStartTime") as! DateTimeRow).value = newValue
//        }
//    }
//    
//    var eventEndTime: NSDate? {
//        get {
//            return (form.rowByTag("eventEndTime") as! DateTimeRow).value
//        }
//        set {
//            (form.rowByTag("eventEndTime") as! DateTimeRow).value = newValue
//        }
//    }
//    
//    var eventLocation: String? {
//        get {
//            return (form.rowByTag("eventLocation") as! TextRow).value
//        }
//        set {
//            (form.rowByTag("eventLocation") as! TextRow).value = newValue
//        }
//    }
//    
//    var expectedFee: Double? {
//        get {
//            return (form.rowByTag("expectedFee") as! DecimalRow).value
//        }
//        set {
//            (form.rowByTag("expectedFee") as! DecimalRow).value = newValue
//        }
//    }
//    
//    var transportationMethod: String? {
//        get {
//            return (form.rowByTag("transportationMethod") as! AlertRow).value
//        }
//        set {
//            (form.rowByTag("transportationMethod") as! AlertRow).value = newValue
//        }
//    }
//    
//    var note: String? {
//        get {
//            return (form.rowByTag("note") as! TextAreaRow).value
//        }
//        set {
//            (form.rowByTag("note") as! TextAreaRow).value = newValue
//        }
//    }
//}
