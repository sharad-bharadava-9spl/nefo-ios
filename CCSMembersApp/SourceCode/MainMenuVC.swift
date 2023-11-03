//
//  MainMenuVC.swift
//  CCSMembersApp
//
//  Created by Jaimin Patel on 11/13/19.
//  Copyright © 2019 Jaimin Patel. All rights reserved.
//

import UIKit
import SwiftyJSON
import SlideMenuControllerSwift
import Alamofire
import NetworkExtension
import SystemConfiguration

class MainMenuVC: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var listDictArr=[[String:Any]]()
    var item1:UIBarButtonItem?
    var item2:UIBarButtonItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        self.collectionView.dataSource=self
        self.collectionView.delegate=self
        
       
       
     GetMACAddress()
        
        self.notificationBadgeCountApi()
        
        
        
        self.navigationController?.navigationBar.isHidden=false
        navigationController?.navigationBar.barTintColor = UIColor.white
        navigationController?.navigationBar.topItem?.title = "Home".localized.uppercased()
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(named: "NavigationText")!, NSAttributedString.Key.font: UIFont(name: "ProductSans-Bold", size: 17)!]
        navigationItem.leftBarButtonItem?.tintColor = UIColor(named: "NavigationText")!
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateCartCountNotification(notification:)), name: Notification.Name("updateCartCount"), object: nil)

        // Do any additional setup after loading the view.
    }
    
    
 
    
    func GetMACAddress(){
        let address = getAddress()
        let mac = GetMACAddressFromIPv6(ip: address ?? "")
        print("MAc----\(mac)")
    }

    func GetMACAddressFromIPv6(ip: String) -> String{
        let IPStruct = IPv6Address(ip)
        if(IPStruct == nil){
            return ""
        }
        let extractedMAC = [
            (IPStruct?.rawValue[8])! ^ 0b00000010,
            IPStruct?.rawValue[9],
            IPStruct?.rawValue[10],
            IPStruct?.rawValue[13],
            IPStruct?.rawValue[14],
            IPStruct?.rawValue[15]
        ]
        let str = String(format: "%02x:%02x:%02x:%02x:%02x:%02x", extractedMAC[0] ?? 00,
            extractedMAC[1] ?? 00,
            extractedMAC[2] ?? 00,
            extractedMAC[3] ?? 00,
            extractedMAC[4] ?? 00,
            extractedMAC[5] ?? 00)
        return str
    }


 
    func getAddress() -> String? {
        var address: String?

        // Get list of all interfaces on the local machine:
        var ifaddr: UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0 else { return nil }
        guard let firstAddr = ifaddr else { return nil }

        // For each interface ...
        for ifptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
            let interface = ifptr.pointee

            // Check IPv6 interface:
            let addrFamily = interface.ifa_addr.pointee.sa_family
            if addrFamily == UInt8(AF_INET6) {
                // Check interface name:
                let name = String(cString: interface.ifa_name)
                if name.contains("ipsec") {
                    // Convert interface address to a human readable string:
                    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    getnameinfo(interface.ifa_addr, socklen_t(interface.ifa_addr.pointee.sa_len),
                                &hostname, socklen_t(hostname.count),
                                nil, socklen_t(0), NI_NUMERICHOST)
                    address = String(cString: hostname)
                    let ipv6addr = IPv6Address(address ?? "::")
                    if(ipv6addr?.isLinkLocal ?? false){
                        return address
                    }
                }
            }
        }
        freeifaddrs(ifaddr)

        return address
    }

    
   
    @objc func updateCartCountNotification(notification: Notification) {
        self.setupMenu()
        if let cartCount = UserDefaults.standard.object(forKey: "Badge_cart_count") as? String{
            self.item1?.removeBadge()
            if cartCount != "0"{
                self.item1?.addBadge(number: Int(cartCount)!)
            } else{
                self.item1?.removeBadge()
            }
        } else{
            
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.setupMenu()
        
        self.setNavigationBarItem()
        self.setLeftAlignTitleView(font: UIFont(name: "ProductSans-Bold", size: 17)!, text: "Home".localized, textColor: .white)
        navigationController?.navigationBar.barTintColor = UIColor.white
        navigationController?.navigationBar.topItem?.title = "Home".localized.uppercased()
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(named: "NavigationText")!, NSAttributedString.Key.font: UIFont(name: "ProductSans-Bold", size: 17)!]
        navigationItem.leftBarButtonItem?.tintColor = UIColor(named: "NavigationText")!
        
        var imageShopingCart = Shared().imageWithImage(image: UIImage(named: "Shoping_Cart")!, scaledToSize: CGSize(width: 23, height: 23))
        imageShopingCart = imageShopingCart.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        
        var imageNotification = Shared().imageWithImage(image: UIImage(named: "Notification_icon")!, scaledToSize: CGSize(width: 23, height: 23))
        imageNotification = imageNotification.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        
        if targetName != Shared().cannibisAppName {
        let btn1 = UIButton(type: .custom)
        btn1.setImage(imageShopingCart, for: .normal)
        btn1.frame = CGRect(x: 0, y: 0, width: 28, height: 28)
        btn1.addTarget(self, action:#selector(self.cartRedirection), for: .touchUpInside)
        item1 = UIBarButtonItem(customView: btn1)
        item1?.removeBadge()
        }
        
        let btn2 = UIButton(type: .custom)
        btn2.setImage(imageNotification, for: .normal)
        btn2.addTarget(self, action: #selector(self.notificationScreenRedirection), for: .touchUpInside)
        btn2.frame = CGRect(x: 0, y: 0, width: 28, height: 28)
        item2 = UIBarButtonItem(customView: btn2)
        item2?.removeBadge()
        if targetName != Shared().cannibisAppName {
        self.navigationItem.setRightBarButtonItems([item1!,item2!], animated: true)
        } else {
            self.navigationItem.setRightBarButtonItems([item2!], animated: true)
        }
        if let cartCount = UserDefaults.standard.object(forKey: "Badge_cart_count") as? String{
            self.item1?.removeBadge()
            if cartCount != "0"{
                self.item1?.addBadge(number: Int(cartCount)!)
            } else{
                self.item1?.removeBadge()
            }
        } else{
            
        }
        
        if #available(iOS 13.0, *) {
            let statusBar = UIView(frame: (UIApplication.shared.keyWindow?.windowScene?.statusBarManager?.statusBarFrame)!)
            statusBar.backgroundColor = UIColor.clear
            UIApplication.shared.keyWindow?.addSubview(statusBar)
        }
    }
    
    
   
    @objc func notificationScreenRedirection(){
        let storyBoard=UIStoryboard(name: "Main", bundle: nil)
        let vc=storyBoard.instantiateViewController(withIdentifier: "NotificationVC") as! NotificationVC
        let navVC=UINavigationController(rootViewController: vc)
        slideMenuController()?.changeMainViewController(navVC, close: true)
    }
    
    @objc func cartRedirection(){
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "CartScreenVC") as! CartScreenVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        navigationController?.navigationBar.barTintColor = UIColor.white//Shared().hexStringToUIColor("#00A0D6")
        navigationController?.navigationBar.topItem?.title = "Home".localized.uppercased()
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(named: "NavigationText")!, NSAttributedString.Key.font: UIFont(name: "ProductSans-Bold", size: 17)!]
        navigationItem.leftBarButtonItem?.tintColor = UIColor(named: "NavigationText")!
        let when=DispatchTime.now()+0.2
        DispatchQueue.main.asyncAfter(deadline: when) {
            if let _ : AnyObject = UserDefaults.standard.object(forKey: "user_id") as AnyObject? {
                self.updateCartCounts()
            }
        }
    }
    
    func setupMenu(){
        // MARK: VIS
//        listDictArr.removeAll()
//        self.fillupMenu(id:"1",imgName: "Menu_Menu", lblName: "Menu".localized)
//       // self.fillupMenu(id:"2",imgName: "SlideCategoriesIcon", lblName: "Slide_Categories".localized)
//        if targetName != Shared().cannibisAppName {
//        self.fillupMenu(id:"3",imgName: "Donation_Menu", lblName: "Slide_Donation".localized)
//        }
//        self.fillupMenu(id:"6",imgName: "Profile_Menu", lblName: "Slide_My Profile".localized)
//        self.fillupMenu(id:"5",imgName: "Dispense_Menu", lblName: "Slide_Dispense History".localized)
//       // self.fillupMenu(id:"12",imgName: "Change_Passcode_White", lblName: "Change Passcode".localized)
//        self.fillupMenu(id:"7",imgName: "Notification_Menu", lblName: "Slide_Notifications".localized)
//
//        if let checkAdminLogin=UserDefaults.standard.object(forKey: "check_adminLogin") as? String{
//            if checkAdminLogin == "Admin"{
//                self.fillupMenu(id:"8",imgName: "Setting_Menu", lblName: "Slide_Settings".localized)
//            } else{
//            }
//        }
//        if let checkAdminLogin=UserDefaults.standard.object(forKey: "check_adminLogin") as? String{
//            if checkAdminLogin == "Customer"{
//                self.fillupMenu(id:"4",imgName: "Chat_Menu", lblName: "Slide_Chat".localized)
//            } else{
//
//            }
//        }
//        self.fillupMenu(id:"9",imgName: "Language_Menu", lblName: "Language".localized)
//        self.fillupMenu(id:"10",imgName: "Map_Menu", lblName: "Map".localized)
//        //self.fillupMenu(id:"11",imgName: "SlideLogoutIcon", lblName: "Logout".localized)
//        self.collectionView.reloadData()
        
        listDictArr.removeAll()
        
        let isMenuShow = getFromUserDefaultForKey(key_isMenuShow) as? Bool ?? true
        let isDispenseShow = getFromUserDefaultForKey(key_isDispensShow) as? Bool ?? true
        
        if UserDefaults.standard.bool(forKey: "ShowMap") == true {
            if isMenuShow == true {
                self.fillupMenu(id:"1",imgName: "Menu_home", lblName: "Menu".localized)
                if isDispenseShow{
                    self.fillupMenu(id:"5",imgName: "History_menu", lblName: "History".localized)
                }
                self.fillupMenu(id:"6",imgName: "Profile_menu", lblName: "Slide_My Profile".localized)
                self.fillupMenu(id:"10",imgName: "Map_menu", lblName: "Map".localized)
            }else{
                if isDispenseShow{
                    self.fillupMenu(id:"5",imgName: "History_menu", lblName: "History".localized)
                }
                self.fillupMenu(id:"6",imgName: "Profile_menu", lblName: "Slide_My Profile".localized)
                self.fillupMenu(id:"10",imgName: "Map_menu", lblName: "Map".localized)
            }
        } else if isMenuShow == true{
            self.fillupMenu(id:"1",imgName: "Menu_home", lblName: "Menu".localized)
            if isDispenseShow{
                self.fillupMenu(id:"5",imgName: "History_menu", lblName: "History".localized)
            }
            
            self.fillupMenu(id:"6",imgName: "Profile_menu", lblName: "Slide_My Profile".localized)
        }else {
            if isDispenseShow{
                self.fillupMenu(id:"5",imgName: "History_menu", lblName: "History".localized)
            }
            self.fillupMenu(id:"6",imgName: "Profile_menu", lblName: "Slide_My Profile".localized)
        }
        self.collectionView.reloadData()

    }
    
    override func viewDidLayoutSubviews() {
        self.collectionView.reloadData()
    }
    
    func fillupMenu(id:String,imgName:String,lblName:String){
        var menuDic = [String:String]()
        menuDic["img"] = imgName
        menuDic["txt"] = lblName
        menuDic["id"] = id
        menuDic["type"] = "1"
        self.listDictArr.append(menuDic)
    }
    
    /*func removeData(){
        Shared().firebaseProcess(visibility:"LOGOUT")
        Shared().clearData()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let initialViewController = storyboard.instantiateViewController(withIdentifier: "LoginScreenVC") as! LoginScreenVC
        let leftViewController = storyboard.instantiateViewController(withIdentifier: "SlideMenuScreenVC") as! SlideMenuScreenVC
        let nvc: UINavigationController = UINavigationController(rootViewController: initialViewController)
        
        let slideMenuController = SlideMenuController(mainViewController: nvc,  leftMenuViewController: leftViewController)
        slideMenuController.automaticallyAdjustsScrollViewInsets = true
        appDelegate?.window?.backgroundColor = UIColor(red: 236.0, green: 238.0, blue: 241.0, alpha: 1.0)
        appDelegate?.window?.rootViewController = slideMenuController
        appDelegate?.window?.makeKeyAndVisible()
        SlideMenuOptions.contentViewScale = 1
        SlideMenuOptions.hideStatusBar = true
        SlideMenuOptions.simultaneousGestureRecognizers = false
    }*/

}

extension MainMenuVC:UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.listDictArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell=collectionView.dequeueReusableCell(withReuseIdentifier: "MainMenuCell", for: indexPath) as! MainMenuCell
        let cellData=self.listDictArr[indexPath.row]
        cell.lblMenuName.text=cellData["txt"] as? String
        cell.imgMenu.image=UIImage(named: cellData["img"] as! String)
        cellSetup(cell: cell)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectadIs=listDictArr[indexPath.row]
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if JSON(selectadIs["type"]!).stringValue == "1"{
            switch JSON(selectadIs["id"]!).stringValue {
            case "2":
                var vc: UIViewController!
                let vcCon = storyboard.instantiateViewController(withIdentifier: "CategoryScreevVC") as! CategoryScreevVC
                vc = UINavigationController(rootViewController: vcCon)
                self.slideMenuController()?.changeMainViewController(vc, close: true)
                
            case "3":
                var vc: UIViewController!
                let vcCon = storyboard.instantiateViewController(withIdentifier: "DonationVC") as! DonationVC
                vc = UINavigationController(rootViewController: vcCon)
                self.slideMenuController()?.changeMainViewController(vc, close: true)
                
            case "4":
                var vc: UIViewController!
                let vcCon = storyboard.instantiateViewController(withIdentifier: "ChatListVC") as! ChatListVC
                vc = UINavigationController(rootViewController: vcCon)
                self.slideMenuController()?.changeMainViewController(vc, close: true)
                
            case "12":
                var vc: UIViewController!
                let vcCon = storyboard.instantiateViewController(withIdentifier: "ChangePasscodeVC") as! ChangePasscodeVC
                vc = UINavigationController(rootViewController: vcCon)
                self.slideMenuController()?.changeMainViewController(vc, close: true)
                
            case "5":
                appDelegateShared.selectedIndexMenu = 3
                var vc: UIViewController!
                let vcCon = storyboard.instantiateViewController(withIdentifier: "HistoryVC") as! HistoryVC
                vc = UINavigationController(rootViewController: vcCon)
                self.slideMenuController()?.changeMainViewController(vc, close: true)
                
            case "6":
                appDelegateShared.selectedIndexMenu = 2
                var vc: UIViewController!
                let vcCon = storyboard.instantiateViewController(withIdentifier: "NewProfileVC") as! NewProfileVC
                vc = UINavigationController(rootViewController: vcCon)
                self.slideMenuController()?.changeMainViewController(vc, close: true)
                
            case "7":
                var vc: UIViewController!
                let vcCon = storyboard.instantiateViewController(withIdentifier: "NotificationVC") as! NotificationVC
                vc = UINavigationController(rootViewController: vcCon)
                self.slideMenuController()?.changeMainViewController(vc, close: true)
                
            case "8":
                var vc: UIViewController!
                let vcCon = storyboard.instantiateViewController(withIdentifier: "SettingScreenVC") as! SettingScreenVC
                vc = UINavigationController(rootViewController: vcCon)
                self.slideMenuController()?.changeMainViewController(vc, close: true)
                
            case "9":
                var vc: UIViewController!
                let vcCon = storyboard.instantiateViewController(withIdentifier: "LanguageVC") as! LanguageVC
                vc = UINavigationController(rootViewController: vcCon)
                self.slideMenuController()?.changeMainViewController(vc, close: true)
                
            case "10":
                appDelegateShared.selectedIndexMenu = 4
                var vc: UIViewController!
                let vcCon = storyboard.instantiateViewController(withIdentifier: "MapScreenVC") as! MapScreenVC
                vc = UINavigationController(rootViewController: vcCon)
                self.slideMenuController()?.changeMainViewController(vc, close: true)
                
            case "11":
                let uiAlert = UIAlertController(title: Shared().title, message: "LogoutMsg".localized, preferredStyle:.alert)
                uiAlert.addAction(UIAlertAction(title: "No".localized, style: .default, handler: { action in }))
                uiAlert.addAction(UIAlertAction(title: "Yes".localized, style: .destructive, handler: { action in
                    self.removeData()
                    
                }))
                self.present(uiAlert, animated: true, completion: nil)
            default:
                print("Default Case selected")
                appDelegateShared.selectedIndexMenu = 1
                var vc: UIViewController!
                let vcCon = storyboard.instantiateViewController(withIdentifier: "HomeScreenVC") as! HomeScreenVC
                vc = UINavigationController(rootViewController: vcCon)
                self.slideMenuController()?.changeMainViewController(vc, close: true)
            }
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateMenuSelection"), object: nil)
        }
    }
    
    func cellSetup(cell:MainMenuCell){
        if self.view.frame.width == 375{
            cell.mainViewHeight.constant=125
        } else if self.view.frame.width == 414{
            cell.mainViewHeight.constant=140
        } else{
            cell.mainViewHeight.constant=100
        }
    }
    
    @objc func updateCartCount(notification: NSNotification){
        let data=notification.userInfo!["update_cart"] as! String
        //do stuff using the userInfo property of the notification object
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemSize = (collectionView.frame.width - (collectionView.contentInset.left + collectionView.contentInset.right + 10)) / 2
        if self.view.frame.width == 375{
            return CGSize(width: itemSize, height: 165)
        } else if self.view.frame.width == 414{
            return CGSize(width: itemSize, height: 180)
        } else{
            return CGSize(width: itemSize, height: 140)
        }
    }
}

extension MainMenuVC{
    
    func updateCartCounts(){
        //startAnimating(CGSize(width: 100, height: 100), message: "", type: NVActivityIndicatorType.ballRotate, fadeInAnimation: nil)
        let parameters: Parameters = [
            "language" : "\(Language.language)",
            "club_name" : UserDefaults.standard.object(forKey: "club_name") as! String,
            "user_id" : UserDefaults.standard.object(forKey: "user_id") as! String,
        ]
        
        print("\(Shared().webCall)userLoginSwitch?language=\(Language.language)&club_name=\(UserDefaults.standard.object(forKey: "club_name") as! String)&user_id=\(UserDefaults.standard.object(forKey: "user_id") as! String)")
        Alamofire.request("\(Shared().webCall)userLoginSwitch.php", method: .post, parameters: parameters)
            .responseJSON { response in
             //   let when = DispatchTime.now() + 0.1
//                DispatchQueue.main.asyncAfter(deadline: when) {
//                    self.stopAnimating(nil)
//                }
                
                switch response.result {
                case .success:
                    print("JSON::",response.result.value!)
                    // alert.dismiss(animated: true, completion: {
                    
                    if let jsonData = response.result.value as? [String:Any] {
                        let flag = JSON(jsonData["flag"]!).stringValue
                        if flag == "1"{
                           // print("=======user_type=====",user_type)
                            let cartCount = JSON(jsonData["cart_count"]!).stringValue
                            if cartCount != "0"{
                                self.item1?.addBadge(number: Int(cartCount)!)
                            } else{
                                self.item1?.removeBadge()
                            }
                            
//                            let notification_count = JSON(jsonData["notification_count"]!).stringValue
//                            UIApplication.shared.applicationIconBadgeNumber=JSON(notification_count).intValue
//                            if notification_count != "0" {
//                                 self.item2?.addBadge(number: Int(notification_count)!)
//                            } else{
//                                self.item2?.removeBadge()
//                            }

                        } else{
                            let message : String = JSON(jsonData["message"]!).stringValue
                            Shared().showAlert(uIViewController: self, title: Shared().error, message: message)
                        }
                    }
                    // })
                    break
                    
                case .failure(let error):
                    //alert.dismiss(animated: true, completion: {
                    let errorCode = error._code
                    if(errorCode == -1001 || errorCode == -1005 || errorCode == -1009) {
                        Shared().showAlert(uIViewController: self, title: Shared().error, message: error.localizedDescription)
                    } else {
                        Shared().showAlert(uIViewController: self)
                    }
                    // })
                    print("Server:",error.localizedDescription)
                    break
                }
        }
        //})
    }
    
    
    
    
    func notificationBadgeCountApi() {
        
        
        let parameters: Parameters = [
            "language" : "\(Language.language)",
            "club_name" : UserDefaults.standard.object(forKey: "club_name") as! String,
            "member_id" : UserDefaults.standard.string(forKey: "member_id") ?? "",
            "user_id" : UserDefaults.standard.object(forKey: "user_id") as! String,
            "macAddress" : "",
        ]
        
        let url = "\(Shared().webCall)unreadNotifications.php"
        
        Alamofire.request(url, method: .post, parameters: parameters).responseJSON { response in
            
            print("url-\(url)")
            switch response.result {
                
            case .success :
                print("notif--\(response.result.value)")
                
                if let jsonData = response.result.value as? [String:Any] {
                    
                    let flag = JSON(jsonData["flag"]).stringValue
                    if flag == "1" {
                        let notifcount = JSON(jsonData["unread_count"]).stringValue
                        UIApplication.shared.applicationIconBadgeNumber=JSON(notifcount).intValue
                        UserDefaults.standard.set(notifcount, forKey: "notifcount")
                        if notifcount != "0"{
                             self.item2?.addBadge(number: Int(notifcount)!)
                        } else{
                            self.item2?.removeBadge()
                        }
                        print("notifcount---\(notifcount)")
                    }else{
                       let message : String = JSON(jsonData["message"]!).stringValue
                       Shared().showAlert(uIViewController: self, title: Shared().error, message: message)
                   }
                }
                
                break
                
            case .failure (let error) :
                let errorCode = error._code
                if(errorCode == -1001 || errorCode == -1005 || errorCode == -1009) {
                    Shared().showAlert(uIViewController: self, title: Shared().error, message: error.localizedDescription)
                } else {
                    Shared().showAlert(uIViewController: self)
                }
                // })
                print("Server:",error.localizedDescription)
                break
            }
        }
        
    }
    
    
}

