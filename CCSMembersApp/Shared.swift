//
//  Shared.swift
//  CCSMembersApp
//
//  Created by Jaimin Patel on 6/6/19.
//  Copyright © 2019 Jaimin Patel. All rights reserved.
//

import Foundation
import UIKit
import FirebaseDatabase
import Firebase
import SwiftyJSON
import SystemConfiguration.CaptiveNetwork
var targetName: String = ""
class Shared{
    // MARK: Client Staging
    
//    let webCall = "https://ccsnube.com/ttt/api/"
    
    // MARK: 9S Staging
   let webCall = "http://65.20.69.70/nefo-php/api/"
    
    // MARK: Live
  // let webCall = "https://ccsnubev2.com/v8/api/"
    
//    let webCall = "http://192.168.0.41/cannabisclub/api/"
//    let webCall = "http://devsj72web.websiteserverhost.com/cannabisclub/api/"
    let webCallMap = "http://devsj72web.websiteserverhost.com/nefos-web/api/"
    let device_platform : String = "iOS"
    let error : String = "Error".localized
    let title : String = "CCS Members App"
    let errorMsg : String = "Sorry, something went wrong. Please try again later.".localized;
    let wifiNoteError : String = "Note".localized
    let wifiPermissionNote : String = "You don't have permission.Please contact admin".localized
    let verifyMacAddressErrMsg : String = "Please verify your mac address.".localized
    let verifyAllreadyMacAddressErrMsg : String = "This wifi-mac address already added.".localized
    let saveMacAddressErrMsg : String = "Please save your editable mac address.";
    var cannibisAppName: String = "CCS Members App"
    
    let GOOGLE_API_KEY = "AIzaSyB37T3DT1fLza9MGhJgDYbqh8oODJTuYsk"
    
    func statusBarSetup(view:UIView){
        let app = UIApplication.shared
        let statusBarHeight: CGFloat = app.statusBarFrame.size.height
        
        let statusbarView = UIView()
        statusbarView.backgroundColor = UIColor(named: "statusBackgroundColour")!
        view.addSubview(statusbarView)
        
        statusbarView.translatesAutoresizingMaskIntoConstraints = false
        statusbarView.heightAnchor
            .constraint(equalToConstant: statusBarHeight).isActive = true
        statusbarView.widthAnchor
            .constraint(equalTo: view.widthAnchor, multiplier: 1.0).isActive = true
        statusbarView.topAnchor
            .constraint(equalTo: view.topAnchor).isActive = true
        statusbarView.centerXAnchor
            .constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    func applyShadow(view : UIView) {
        view.layer.borderWidth = 1.0
        view.layer.borderColor = UIColor.white.cgColor
        view.layer.shadowColor = UIColor.lightGray.cgColor
        view.layer.shadowOffset = CGSize(width: 3, height: 3)
        view.layer.shadowOpacity = 1.0
        view.layer.shadowRadius = 4.0
    }
    
    func setGradientBackground(gradientView:UIView) {
        let colorTop = UIColor(red: 19 / 255.0, green: 154 / 255.0, blue: 131 / 255.0, alpha: 1.0).cgColor
        let colorBottom = UIColor(red: 115 / 255.0, green: 186 / 255.0, blue: 104 / 255.0, alpha: 1.0).cgColor
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [colorTop, colorBottom]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        gradientLayer.frame = gradientView.bounds
        
        gradientView.layer.insertSublayer(gradientLayer, at:0)
    }
    
    func hexStringToUIColor (_ hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString = cString.substring(from: cString.index(cString.startIndex, offsetBy: 1))
        }
        
        if ((cString.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    func getImgName()->String{
        var imgName:String?
        let device : String = UIDevice.current.screenType.rawValue
        if (device == "iPhone 5, iPhone 5s, iPhone 5c or iPhone SE") {
            imgName="home_iPhone_5s"
        } else if (device == "iPhone 6, iPhone 6S, iPhone 7 or iPhone 8") {
            imgName="home_iPhone_8"
        } else if (device == "iPhone 6 Plus, iPhone 6S Plus, iPhone 7 Plus or iPhone 8 Plus") {
            imgName="home_iPhone_8+"
        } else if (device == "iPhone X or iPhone XS" || device == "iPhone XR" || device == "iPhone XS Max") {
            imgName="home_iPhone_X"
        } else{
            imgName="home_iPhone_5s"
        }
        return imgName!
    }
    
    func getWifiInfo() -> Array<WifiInfo> {
        guard let interfaceNames = CNCopySupportedInterfaces() as? [String] else {
            return []
        }
        let wifiInfo:[WifiInfo] = interfaceNames.compactMap{ name in
            guard let info = CNCopyCurrentNetworkInfo(name as CFString) as? [String:AnyObject] else {
                return nil
            }
            guard let ssid = info[kCNNetworkInfoKeySSID as String] as? String else {
                return nil
            }
            guard let bssid = info[kCNNetworkInfoKeyBSSID as String] as? String else {
                return nil
            }
            return WifiInfo(name, ssid,bssid)
        }
        return wifiInfo
    }
    
    func clearData() {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "Name")
        defaults.removeObject(forKey: "addMemberAccount")
        defaults.removeObject(forKey: "domain")
        defaults.removeObject(forKey: "first_name")
        defaults.removeObject(forKey: "memberno")
        defaults.removeObject(forKey: "userGroup")
        defaults.removeObject(forKey: "user_id")
        defaults.removeObject(forKey: "workStation")
        defaults.removeObject(forKey: "image")
        defaults.removeObject(forKey: "club_name")
        defaults.removeObject(forKey: "check_adminLogin")
        defaults.removeObject(forKey: "Badge_cart_count")
        defaults.removeObject(forKey: key_isLogin)
        defaults.synchronize()
//        removeFromUserDefaultForKey(key_isMenuShow)
//        removeFromUserDefaultForKey(key_isMenuPriceShow)
    }
    
    func componentSepareted(fullValue:String,separatedBy:String)->String{
        var fullValue1:String=""
        for item in fullValue{
            if item == ","{
               
            } else{
               fullValue1.append(item)
            }
        }
        let fileName = fullValue1
        let fileArray = fileName.components(separatedBy: separatedBy)
        let fileTypeis = fileArray.first!
        return fileTypeis
    }
    
    func componentSeparetedGuardians(fullValue:String,separatedBy:String)->(String,String){
        let fileName = fullValue
        let fileArray = fileName.components(separatedBy: separatedBy)
        let fileTypeis = fileArray.first!
        let second = fileArray.last!
        return (fileTypeis,second)
    }
    
    func getWIFIInformation() -> [String:String]{
        var informationDictionary = [String:String]()
        let informationArray:NSArray? = CNCopySupportedInterfaces()
        if let information = informationArray {
            let dict:NSDictionary? = CNCopyCurrentNetworkInfo(information[0] as! CFString)
            if let temp = dict {
//                informationDictionary["SSID"] = String(temp["SSID"]!)
//                informationDictionary["BSSID"] = String(temp["BSSID"]!)
                return informationDictionary
            }
        }

        return informationDictionary
    }
    
    
    
    
    
    
    
    
    func getWifi()->String{
        let macAddress=getWifiInfo()
        var macAddressStr=""
        
        if macAddress.count != 0{
            print("macAddress[0].bssid===============>>>>>>>>>>>>>>>>>>>>======",macAddress[0].bssid)
            macAddressStr=macAddress[0].ssid
        } else{
            print("macAddress[0].bssid===============>>>>>>>>>>>>>>>>>>>>======",macAddress)
            macAddressStr=""
        }
        return macAddressStr
    }
    
    func isValid(text:String) -> Bool {
        let macRegex = "([0-9A-Fa-f]{2}[:]){5}([0-9A-Fa-f]{2})"
        if let macTest = NSPredicate(format: "SELF MATCHES %@", macRegex) as NSPredicate? {
            return macTest.evaluate(with: text)//.evaluateWithObject(self.text)
        }
        return false
    }
    
    func imageRotatedByDegrees(oldImage: UIImage, deg degrees: CGFloat) -> UIImage {
        //Calculate the size of the rotated view's containing box for our drawing space
        let rotatedViewBox: UIView = UIView(frame: CGRect(x: 0, y: 0, width: oldImage.size.width, height: oldImage.size.height))
        let t: CGAffineTransform = CGAffineTransform(rotationAngle: degrees * CGFloat(M_PI / 180))
        rotatedViewBox.transform = t
        let rotatedSize: CGSize = rotatedViewBox.frame.size
        //Create the bitmap context
        UIGraphicsBeginImageContext(rotatedSize)
        let bitmap: CGContext = UIGraphicsGetCurrentContext()!
        //Move the origin to the middle of the image so we will rotate and scale around the center.
        bitmap.translateBy(x: rotatedSize.width / 2, y: rotatedSize.height / 2)
        //Rotate the image context
        bitmap.rotate(by: (degrees * CGFloat(M_PI / 180)))
        //Now, draw the rotated/scaled image into the context
        bitmap.scaleBy(x: 1.0, y: -1.0)
        bitmap.draw(oldImage.cgImage!, in: CGRect(x: -oldImage.size.width / 2, y: -oldImage.size.height / 2, width: oldImage.size.width, height: oldImage.size.height))
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
    
    func showAlert(uIViewController:UIViewController){
        let uiAlert = UIAlertController(title: error, message: errorMsg , preferredStyle:.alert)
        uIViewController.present(uiAlert, animated: true, completion: nil)
        uiAlert.addAction(UIAlertAction(title: "Ok".localized, style: .default, handler: { action in
            uiAlert.dismiss(animated: true, completion: nil)
        }))
    }
    
    //implemented all over //Fitdata: For converting dynamic date format
    func convertDateTimeformat(format:String,intoFormat : String,text :String) -> String
    {
        let dateString = text
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        let dateObj = dateFormatter.date(from: dateString)
//        dateFormatter.dateFormat = intoFormat
//        dateFormatter.locale = Locale(identifier: "en_US")
        let result = dateFormatter.string(from: dateObj!)
        return result
    }
    
    func showAlert(uIViewController:UIViewController, title : String, message :String){
        let uiAlert = UIAlertController(title: title, message: message , preferredStyle:.alert)
        uIViewController.present(uiAlert, animated: true, completion: nil)
        uiAlert.addAction(UIAlertAction(title: "Ok".localized, style: .default, handler: { action in }))
    }
    
    func imageWithImage(image:UIImage, scaledToSize newSize:CGSize) -> UIImage{
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0);
        image.draw(in: CGRect(origin: CGPoint.zero, size: CGSize(width: newSize.width, height: newSize.height)))
        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
    
    func getScreenHeight()->CGFloat{
        return UIScreen.main.bounds.height
    }
    
    func getScreenWidth()->CGFloat{
        return UIScreen.main.bounds.width
    }
    
    func convertStringToDate(strDate:String)->Date{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.locale = Locale.current
        return dateFormatter.date(from: strDate)! // replace Date String
    }
    
    //User ::
    func firebaseProcess(visibility:String){
        var ref1: DatabaseReference!
        ref1 = Database.database().reference()
        if visibility == "LOGIN"{
            //When Login user first time
            //ref1.child("Users").child(JSON(UserDefaults.standard.object(forKey: "user_id")!).stringValue).setValue(["email":JSON(UserDefaults.standard.object(forKey: "email")!).stringValue,"name":JSON(UserDefaults.standard.object(forKey: "Name")!).stringValue,"status":"LOGIN","token":deviceTokenString])
        } else if visibility == "ONLINE"{
            
            
            //ref1.child("Users").child(JSON(UserDefaults.standard.object(forKey: "user_id") ?? "").stringValue).updateChildValues(["email":JSON(UserDefaults.standard.object(forKey: "email")!).stringValue,"name":JSON(UserDefaults.standard.object(forKey: "Name")!).stringValue,"status":"ONLINE","token":deviceTokenString])
        } else if visibility == "LOGOUT"{
            //ref1.child("Users").child(JSON(UserDefaults.standard.object(forKey: "user_id")).stringValue).removeValue()
        } else{
            //Offline
            //ref1.child("Users").child(JSON(UserDefaults.standard.object(forKey: "user_id") ?? "").stringValue).updateChildValues(["email":JSON(UserDefaults.standard.object(forKey: "email")!).stringValue,"name":JSON(UserDefaults.standard.object(forKey: "Name")!).stringValue,"status":ServerValue.timestamp(),"token":deviceTokenString])
        }
    }
    
    //Chat ::
    func firebaseChatProcess(text:String){
            var ref1: DatabaseReference!
            ref1 = Database.database().reference()
                //When Login user first time
            ref1.child("Chat").child(JSON(UserDefaults.standard.object(forKey: "user_id")!).stringValue).childByAutoId().setValue(["createdAt":ServerValue.timestamp(),"id":JSON(UserDefaults.standard.object(forKey: "user_id")!).stringValue,"text":text,"user":["id":JSON(UserDefaults.standard.object(forKey: "user_id")!).stringValue,"name":JSON(UserDefaults.standard.object(forKey: "Name")!).stringValue]])
    }
    
    func uploadMedia(image:UIImage,completion: @escaping (_ url: String?) -> Void) {
        
    }
        
    func firebaseChatProcessImage(image:UIImage){
        let storageRef = Storage.storage().reference().child("uploads").child(JSON(ServerValue.timestamp).stringValue)//FIRStorage.storage().reference().child("myImage.png")
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpeg"
        print("Image is",image)
        if let uploadData = image.jpegData(compressionQuality: 0.10) {
            storageRef.putData(uploadData, metadata: metaData) { (metadata, error) in
                if error != nil {
                    print("error")
                } else {
                    storageRef.downloadURL(completion: { (url, error1) in
                        if error1 != nil {
                            print("error",error1.debugDescription)
                        } else{
                            print("url is",url)
                            var ref1: DatabaseReference!
                            ref1 = Database.database().reference()
                            ref1.child("Chat").child(JSON(UserDefaults.standard.object(forKey: "user_id")!).stringValue).childByAutoId().setValue(["createdAt":ServerValue.timestamp(),"id":JSON(UserDefaults.standard.object(forKey: "user_id")!).stringValue,"image":"\(url!)","text":"","user":["id":JSON(UserDefaults.standard.object(forKey: "user_id")!).stringValue,"name":JSON(UserDefaults.standard.object(forKey: "Name")!).stringValue]])
                        }
                    })
                    //completion((metadata?.downloadURL()?.absoluteString)!)
                    
                    // your uploaded photo url.
                }
            }
        }
    }
}
//        if let uploadData = image.pngData() {
//            storageRef.put(uploadData, metadata: nil) { (metadata, error) in
//                if error != nil {
//                    print("error")
//                    completion(nil)
//                } else {
//                    completion((metadata?.downloadURL()?.absoluteString)!))
//                    // your uploaded photo url.
//                }
//            }

class UISwitchCustom: UISwitch {
    @IBInspectable var OffTint: UIColor? {
        didSet {
            self.tintColor = OffTint
            self.layer.cornerRadius = 16
            self.backgroundColor = OffTint
        }
    }
}

extension UIImageView {
    func setImageColor(color: UIColor) {
        let templateImage = self.image?.withRenderingMode(.alwaysTemplate)
        self.image = templateImage
        self.tintColor = color
    }
}

extension String {
    func strikeThrough() -> NSAttributedString {
        let attributeString =  NSMutableAttributedString(string: self)
        attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: NSUnderlineStyle.single.rawValue, range: NSMakeRange(0,attributeString.length))
        return attributeString
    }
}

extension String {
    func grouping(every groupSize: String.IndexDistance, with separator: Character) -> String {
        let cleanedUpCopy = replacingOccurrences(of: String(separator), with: "")
        return String(cleanedUpCopy.enumerated().map() {
            $0.offset % groupSize == 0 ? [separator, $0.element] : [$0.element]
            }.joined().dropFirst())
    }
}

extension Date {
    func offsetFrom(date : Date) -> String {
        let dayHourMinuteSecond: Set<Calendar.Component> = [.year,.month,.day, .hour, .minute, .second]
        let difference = NSCalendar.current.dateComponents(dayHourMinuteSecond, from: date, to: self);
        
        var seconds = "\(difference.second ?? 0)"// + " seconds ago."
        if Int(seconds)! > 1{
            seconds="\(difference.second ?? 0)" + " seconds ago.".localized
        } else{
            seconds="second ago.".localized
        }
        var minutes = "\(difference.minute ?? 0)"// + " minutes ago."//+ " " + seconds
        if Int(minutes)! > 1{
            minutes="\(difference.minute ?? 0)" + " minutes ago.".localized
        } else{
            minutes="minute ago.".localized
        }
        var hours = "\(difference.hour ?? 0)" //+ " hours ago."//+ " " + minutes
        if Int(hours)! > 1{
            hours="\(difference.hour ?? 0)" + " hours ago.".localized
        } else{
            hours="hour ago.".localized
        }
        var days = "\(difference.day ?? 0)"//+ " " + hours
        if Int(days)! > 1{
            days="\(difference.day ?? 0)" + " days ago.".localized
        } else{
            days="Yesterday.".localized
        }
        var months = "\(difference.month ?? 0)"// + " months ago."// + " " + days
        if Int(months)! > 1{
            months="\(difference.month ?? 0)" + " months ago.".localized
        } else{
            months="month ago.".localized
        }
        var years = "\(difference.year ?? 0)" //+ " years ago."// + " " + months
        if Int(years)! > 1{
            years="\(difference.year ?? 0)" + " years ago.".localized
        } else{
            years="year ago.".localized
        }
        if let year = difference.year, year       > 0 { return  years}
        if let month = difference.month, month    > 0 { return months }
        if let day = difference.day, day          > 0 { return days }
        if let hour = difference.hour, hour       > 0 { return hours }
        if let minute = difference.minute, minute > 0 { return minutes }
        if let second = difference.second, second > 0 { return seconds }
        return ""
    }
}

extension Double {
    func getDateStringFromUTC() -> String {
        let date = Date(timeIntervalSince1970: self)
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.dateStyle = .medium
        
        return dateFormatter.string(from: date)
    }
}

extension UIApplication {
    var statusBarView: UIView? {
        return value(forKey: "statusBar") as? UIView
    }
}

extension CAShapeLayer {
    func drawCircleAtLocation(location: CGPoint, withRadius radius: CGFloat, andColor color: UIColor, filled: Bool) {
        fillColor = filled ? color.cgColor : UIColor.white.cgColor
        strokeColor = color.cgColor
        let origin = CGPoint(x: location.x - radius, y: location.y - radius)
        path = UIBezierPath(ovalIn: CGRect(origin: origin, size: CGSize(width: radius * 2, height: radius * 2))).cgPath
    }
}

private var handle: UInt8 = 0;

extension UIBarButtonItem {
    
    static func menuButton(_ target: Any?, action: Selector, imageName: String) -> UIBarButtonItem {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: imageName), for: .normal)
        button.addTarget(target, action: action, for: .touchUpInside)
        
        let menuBarItem = UIBarButtonItem(customView: button)
        menuBarItem.customView?.translatesAutoresizingMaskIntoConstraints = false
        menuBarItem.customView?.heightAnchor.constraint(equalToConstant: 24).isActive = true
        menuBarItem.customView?.widthAnchor.constraint(equalToConstant: 24).isActive = true
        
        return menuBarItem
    }
    
    private var badgeLayer: CAShapeLayer? {
        if let b: Any = objc_getAssociatedObject(self, &handle) {
            return b as? CAShapeLayer
        } else {
            return nil
        }
    }
    
    func addBadge(number: Int, withOffset offset: CGPoint = CGPoint.zero, andColor color: UIColor = UIColor.red, andFilled filled: Bool = true,badgeTextColor: UIColor = UIColor.white) {
        guard let view = self.value(forKey: "view") as? UIView else { return }
        
        badgeLayer?.removeFromSuperlayer()
        
        // Initialize Badge
        let badge = CAShapeLayer()
        let radius = CGFloat(7)
        let location = CGPoint(x: view.frame.width - (radius + offset.x), y: (radius + offset.y))
        badge.drawCircleAtLocation(location: location, withRadius: radius, andColor: color, filled: filled)
        view.layer.addSublayer(badge)
        
        // Initialiaze Badge's label
        let label = CATextLayer()
        label.string = "\(number)"
        label.alignmentMode = CATextLayerAlignmentMode.center
        label.fontSize = 9
        label.font = CGFont(UIFont(name: "Karla-Regular_Bold".localized, size: 9)!.fontName as CFString) // Set the desired font
        
        label.frame = CGRect(origin: CGPoint(x: location.x - 8, y: offset.y+1), size: CGSize(width: 16, height: 16))
        
        label.foregroundColor = badgeTextColor.cgColor //filled ? UIColor.white.cgColor : color.cgColor
        label.backgroundColor = UIColor.clear.cgColor
        label.contentsScale = UIScreen.main.scale
        badge.addSublayer(label)
        
        // Save Badge as UIBarButtonItem property
        objc_setAssociatedObject(self, &handle, badge, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    func updateBadge(number: Int) {
        if let text = badgeLayer?.sublayers?.filter({ $0 is CATextLayer }).first as? CATextLayer {
            text.string = "\(number)"
        }
    }
    
    func removeBadge() {
        badgeLayer?.removeFromSuperlayer()
    }
    
}

extension UIView{
    func shadowColor(color:UIColor,border:CGFloat!,offHeight:CGFloat)
    {
        self.layer.borderWidth = border
        self.layer.borderColor = color.cgColor
        self.layer.shadowRadius = 1.0
        self.layer.shadowColor = color.cgColor
        self.layer.shadowOffset = CGSize(width: 0.0, height: offHeight)
        self.layer.shadowOpacity = 1.0
        self.layer.cornerRadius=0.0
        self.layer.masksToBounds = false
        
    }
}

extension Double {
    /// Rounds the double to decimal places value
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

extension UITextView{
    func heightForView(text:String, font:UIFont, width:CGFloat) -> CGFloat{
        let label:UILabel = UILabel(frame:CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = font
        label.text = text
        
        label.sizeToFit()
        return label.frame.height
    }
}


extension UIViewController {
    
    func setNavigationBarItem() {
        self.addLeftBarButtonWithImage(UIImage(named: "Menu_icon-green")!)
        self.slideMenuController()?.removeLeftGestures()
        self.slideMenuController()?.removeRightGestures()
        self.slideMenuController()?.addLeftGestures()
        self.slideMenuController()?.addRightGestures()
    }
    
    func removeNavigationBarItem() {
        self.navigationItem.leftBarButtonItem = nil
        self.navigationItem.rightBarButtonItem = nil
        self.slideMenuController()?.removeLeftGestures()
        self.slideMenuController()?.removeRightGestures()
    }
    
    func setLeftAlignTitleView(font: UIFont, text: String, textColor: UIColor) {
        guard let navFrame = navigationController?.navigationBar.frame else{
            return
        }
        
        let parentView = UIView(frame: CGRect(x: 0, y: 0, width: navFrame.width*3, height: navFrame.height))
        self.navigationItem.titleView = parentView
        
        let label = UILabel(frame: .init(x: parentView.frame.minX, y: parentView.frame.minY, width: parentView.frame.width, height: parentView.frame.height))
        label.backgroundColor = .clear
        label.numberOfLines = 2
        label.font = font
        label.textAlignment = .left
        label.textColor = textColor
        label.text = text
        
        parentView.addSubview(label)
    }
    
    
}

extension UIDevice {
    var iPhoneX: Bool {
        return UIScreen.main.nativeBounds.height == 2436
    }
    var iPhone: Bool {
        return UIDevice.current.userInterfaceIdiom == .phone
    }
    enum ScreenType: String {
        case iPhones_4_4S = "iPhone 4 or iPhone 4S"
        case iPhones_5_5s_5c_SE = "iPhone 5, iPhone 5s, iPhone 5c or iPhone SE"
        case iPhones_6_6s_7_8 = "iPhone 6, iPhone 6S, iPhone 7 or iPhone 8"
        case iPhones_6Plus_6sPlus_7Plus_8Plus = "iPhone 6 Plus, iPhone 6S Plus, iPhone 7 Plus or iPhone 8 Plus"
        case iPhones_X_XS = "iPhone X or iPhone XS"
        case iPhone_XR = "iPhone XR"
        case iPhone_XSMax = "iPhone XS Max"
        case unknown
    }
    var screenType: ScreenType {
        switch UIScreen.main.nativeBounds.height {
        case 960:
            return .iPhones_4_4S
        case 1136:
            return .iPhones_5_5s_5c_SE
        case 1334:
            return .iPhones_6_6s_7_8
        case 1792:
            return .iPhone_XR
        case 1920, 2208:
            return .iPhones_6Plus_6sPlus_7Plus_8Plus
        case 2436:
            return .iPhones_X_XS
        case 2688:
            return .iPhone_XSMax
        default:
            return .unknown
        }
    }
}

@IBDesignable extension UIButton {
    
    @IBInspectable var borderWidth: CGFloat {
        set {
            layer.borderWidth = newValue
        }
        get {
            return layer.borderWidth
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat {
        set {
            layer.cornerRadius = newValue
        }
        get {
            return layer.cornerRadius
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        set {
            guard let uiColor = newValue else { return }
            layer.borderColor = uiColor.cgColor
        }
        get {
            guard let color = layer.borderColor else { return nil }
            return UIColor(cgColor: color)
        }
    }
}

@IBDesignable extension UIView {
    
    @IBInspectable var borderWidths: CGFloat {
        set {
            layer.borderWidth = newValue
        }
        get {
            return layer.borderWidth
        }
    }
    
    @IBInspectable var cornerRadiuss: CGFloat {
        set {
            layer.cornerRadius = newValue
        }
        get {
            return layer.cornerRadius
        }
    }
    
    @IBInspectable var borderColors: UIColor? {
        set {
            guard let uiColor = newValue else { return }
            layer.borderColor = uiColor.cgColor
        }
        get {
            guard let color = layer.borderColor else { return nil }
            return UIColor(cgColor: color)
        }
    }
}

extension UISegmentedControl {
    
    func defaultConfiguration(font: UIFont = UIFont.systemFont(ofSize: 12), color: UIColor = UIColor.gray) {
        let defaultAttributes = [
            NSAttributedString.Key.font: font,
            NSAttributedString.Key.foregroundColor: color
        ]
        setTitleTextAttributes(defaultAttributes, for: .normal)
    }
    
    func selectedConfiguration(font: UIFont = UIFont.boldSystemFont(ofSize: 12), color: UIColor = UIColor.red) {
        let selectedAttributes = [
            NSAttributedString.Key.font: font,
            NSAttributedString.Key.foregroundColor: color
        ]
        setTitleTextAttributes(selectedAttributes, for: .selected)
    }
}

struct WifiInfo {
    public let interface:String
    public let ssid:String
    public let bssid:String
    init(_ interface:String, _ ssid:String,_ bssid:String) {
        self.interface = interface
        self.ssid = ssid
        self.bssid = bssid
    }
}

class CustomTextField: UITextField {
    
    private func getKeyboardLanguage() -> String? {
        return "en" // here you can choose keyboard any way you need
    }
    
    override var textInputMode: UITextInputMode? {
        if let language = getKeyboardLanguage() {
            for tim in UITextInputMode.activeInputModes {
                if tim.primaryLanguage!.contains(language) {
                    return tim
                }
            }
        }
        return super.textInputMode
    }
    
}

extension UIApplication {
    //var statusBarUIView: UIView? {
    var statusBarUIView: UIView? {
        if #available(iOS 13.0, *) {
            let tag = 38482
            let keyWindow = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
            
            if let statusBar = keyWindow?.viewWithTag(tag) {
                return statusBar
            } else {
                guard let statusBarFrame = keyWindow?.windowScene?.statusBarManager?.statusBarFrame else { return nil }
                let statusBarView = UIView(frame: statusBarFrame)
                statusBarView.tag = tag
                keyWindow?.addSubview(statusBarView)
                return statusBarView
            }
        } else if responds(to: Selector(("statusBar"))) {
            return value(forKey: "statusBar") as? UIView
        } else {
            return nil
        }
    }
}



