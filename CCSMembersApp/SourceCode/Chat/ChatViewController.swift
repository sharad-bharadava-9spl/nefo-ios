//
//  ChatViewController.swift
//  CCSMembersApp
//
//  Created by mac-18 on 28/12/22.
//  Copyright © 2022 Jaimin Patel. All rights reserved.
//

import UIKit
import SwiftyJSON

class ChatViewController: UIViewController {

    @IBOutlet weak var viewSegment: UIView!
    @IBOutlet weak var containerFriendList: UIView!
    @IBOutlet weak var containerClubList: UIView!
    @IBOutlet weak var containerUserChat: UIView!

    @IBOutlet weak var btnFriendList: UIButton!
    
    @IBOutlet weak var btnUserChatList: UIButton!
    @IBOutlet weak var btnClubList: UIButton!
    
    
    @IBOutlet weak var lblFriendList: UILabel!
    
    @IBOutlet weak var lblUserChatList: UILabel!
    @IBOutlet weak var lblClubList: UILabel!

    var item1:UIBarButtonItem?
    var item2:UIBarButtonItem?
    var item3:UIBarButtonItem?
    var item4:UIBarButtonItem?
    
    var notificationPayload = JSON("")
    
    var badgeLabel = UILabel()
    var isOpenFriendsRequestScreen : Bool = false

    
    //MARK: - ViewController life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupBadgeLabel()
        self.setLeftAlignTitleView(font: UIFont(name: "ProductSans-Bold", size: 17)!, text: "Friends".localized, textColor: .white)
        navigationController?.navigationBar.barTintColor = UIColor.white
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(named: "NavigationText")!, NSAttributedString.Key.font: UIFont(name: "ProductSans-Bold", size: 17)!]
        navigationItem.leftBarButtonItem?.tintColor = UIColor(named: "NavigationText")!
       self.setupLanguage()
        if let _ = UserDefaults.standard.object(forKey: "club_name"){
            self.CallAPINotificationsCount()
        }
        self.openChatDetailsFromNotification()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.removeObserver()
        self.addObserver()
    }
    
    override func viewWillLayoutSubviews() {
        self.setFontForButton()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.removeObserver()
    }
    deinit {
        self.removeObserver()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.setNavigationBarItem()
        
        self.navigationController?.navigationBar.isHidden = false
        navigationItem.leftBarButtonItem?.tintColor = UIColor(named: "NavigationText")
        var imageShopingCart = Shared().imageWithImage(image: UIImage(named: "Shoping_Cart")!, scaledToSize: CGSize(width: 23, height: 23))
        imageShopingCart = imageShopingCart.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        
        var imageNotification = Shared().imageWithImage(image: UIImage(named: "Notification_icon")!, scaledToSize: CGSize(width: 23, height: 23))
        imageNotification = imageNotification.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        
        var imageQRCode = Shared().imageWithImage(image: UIImage(named: "icon_showQRCode")!, scaledToSize: CGSize(width: 23, height: 23))
        imageQRCode = imageQRCode.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        
        var imageChat = Shared().imageWithImage(image: UIImage(named: "icon_chat_topbar")!, scaledToSize: CGSize(width: 25, height: 25))
        imageChat = imageChat.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)

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
        let btn3 = UIButton(type: .custom)
        btn3.setImage(imageQRCode, for: .normal)
        btn3.addTarget(self, action: #selector(self.QRCodeIMG), for: .touchUpInside)
        btn3.frame = CGRect(x: 0, y: 0, width: 28, height: 28)
        
        item3 = UIBarButtonItem(customView: btn3)
        
        let btn4 = UIButton(type: .custom)
        btn4.setImage(imageChat, for: .normal)
        btn4.addTarget(self, action: #selector(self.openFriendsChatScreen), for: .touchUpInside)
        btn4.frame = CGRect(x: 0, y: 0, width: 28, height: 28)
        btn4.addSubview(self.badgeLabel)
        item4 = UIBarButtonItem(customView: btn4)
        item4?.removeBadge()
        
//        self.setupMessageCount()
        if targetName != Shared().cannibisAppName {
            if let _ = UserDefaults.standard.object(forKey: "club_name"){
                self.navigationItem.setRightBarButtonItems([item1!,item2!,item3!,item4!], animated: true)
            }else{
                self.navigationItem.setRightBarButtonItems([item1!,item3!,item4!], animated: true)
            }
            
        } else {
            if let _ = UserDefaults.standard.object(forKey: "club_name"){
                self.navigationItem.setRightBarButtonItems([item2!,item3!,item4!], animated: true)
            }else{
                self.navigationItem.setRightBarButtonItems([item3!,item4!], animated: true)
            }
//            self.navigationItem.setRightBarButtonItems([item2!,item3!,item4!], animated: true)
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
    
    private func setupBadgeLabel() {
        self.badgeLabel = UILabel(frame: CGRect(x: 10, y: -5, width: 25, height: 15))
        self.badgeLabel.backgroundColor = UIColor(hexString: "#33FF99")
        self.badgeLabel.textColor = .black
        self.badgeLabel.textAlignment = .center
        self.badgeLabel.font = UIFont(name: "Karla-Regular_Bold".localized, size: 11)
        self.badgeLabel.textAlignment = .center
        self.badgeLabel.layer.cornerRadius = 7.5
        self.badgeLabel.layer.masksToBounds = true
        self.badgeLabel.isHidden = true
    }
    
    //Add observer
    func addObserver(){
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateCartCountNotification(notification:)), name: Notification.Name("updateCartCount"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.openChatDetailsScreen(notification:)), name: Notification.Name(NotificationName().OepnChatDetailScreen), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateMessageCount(notification:)), name: Notification.Name(NotificationName().UpdateGlobalChatCount), object: nil)
    }
    
    //Remove Observer
    func removeObserver(){
        NotificationCenter.default.removeObserver(self, name: Notification.Name(NotificationName().UpdateGlobalChatCount), object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name(NotificationName().OepnChatDetailScreen), object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name("updateCartCount"), object: nil)
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Setup views
    func setupLanguage(){
        //Chat Screen
//            self.btnFriendList.setTitle("Friends".localized, for: .normal)
//            self.btnClubList.setTitle("Club Chat".localized, for: .normal)
//            self.btnUserChatList.setTitle("Friends Chat".localized, for: .normal)
        
        
        self.lblFriendList.text = "Friends".localized
        self.lblClubList.text = "Club Chat".localized
        self.lblUserChatList.text = "Friends Chat".localized
        
        
        if self.checkIsDeviceIsASmallResolution(){
            self.lblFriendList.font = setCustomFont.KarlaBoldWith(size: 15.0)
            self.lblClubList.font = setCustomFont.KarlaBoldWith(size: 15.0)
            self.lblUserChatList.font = setCustomFont.KarlaBoldWith(size: 15.0)
        }else{
            self.lblFriendList.font = setCustomFont.KarlaBoldWith(size: 17.0)
            self.lblClubList.font = setCustomFont.KarlaBoldWith(size: 17.0)
            self.lblUserChatList.font = setCustomFont.KarlaBoldWith(size: 17.0)
        }
    }
    
    private func setFontForButton(){
//        DispatchQueue.main.async {
//            self.btnFriendList.titleLabel?.font = setCustomFont.KarlaBoldWith(size: 17.0)
//            self.btnClubList.titleLabel?.font = setCustomFont.KarlaBoldWith(size: 17.0)
//            self.btnUserChatList.titleLabel?.font = setCustomFont.KarlaBoldWith(size: 17.0)
//        }
    }
    
    // MARK: - Bar button actions
    @objc func updateCartCountNotification(notification: Notification) {
        if let cartCount = UserDefaults.standard.object(forKey: "Badge_cart_count") as? String{
            self.item1?.removeBadge()
            if cartCount != "0"{
                self.item1?.addBadge(number: Int(cartCount)!)
            } else{
                self.item1?.removeBadge()
            }
        }
    }
    
    // MARK: - Bar button actions
    @objc func openChatDetailsScreen(notification: Notification) {
        let dict = notification.object as? [String:Any]
        let vc = storyboardName.storyBoard_Chat.instantiateViewController(withIdentifier: "ChatDetailsVC") as! ChatDetailsVC
        vc.userid = dict?["userid"] as? String ?? ""
        vc.receiverName = dict?["receiverName"] as? String ?? ""
        self.navigationController?.pushViewController(vc, animated: true)
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
    @objc func QRCodeIMG(){
        let vc = storyboardName.storyBoard_Chat.instantiateViewController(withIdentifier: "MyQRcodeVC") as! MyQRcodeVC
        self.navigationController?.present(vc, animated: true)
        vc.modalPresentationStyle = .fullScreen
    }
    @objc func openFriendsChatScreen() {
        if let friendsUnreadCount = FRIENDSUNREADCOUNT, let clubUnreadCount = CLUBUNREADCOUNT {
            if friendsUnreadCount > 0 && clubUnreadCount > 0 {
                self.btnSegmentAction(self.btnClubList)
            } else if friendsUnreadCount > 0 {
                self.btnSegmentAction(self.btnUserChatList)
            } else {
                self.btnSegmentAction(self.btnClubList)
            }
        }else {
            self.btnSegmentAction(self.btnUserChatList)
        }
    }
    
    @objc func updateMessageCount(notification: Notification){
        //let dict = notification.object as? [String:Any]
        
        let count = (notification.object as? [String:Any])?["count"] as? Int ?? 0
        if count > 0{
            self.badgeLabel.isHidden = false
            if count > 99 {
                self.badgeLabel.text = "+99"
            }else{
                self.badgeLabel.text = "\(count)"
            }
        }else{
            self.badgeLabel.isHidden = true
        }
        
        /*
        Messages.getTotalUnreadCount { unreadCount in
            //self.item4?.addBadge(number: Int(unreadCount) ?? 0,andColor: UIColor(hexString: "#33FF99"),badgeTextColor: .black)
            
            if Int(unreadCount) ?? 0 > 0{
                self.badgeLabel.isHidden = false
                if Int(unreadCount) ?? 0 > 99 {
                    self.badgeLabel.text = "+99"
                }else{
                    self.badgeLabel.text = unreadCount
                }
            }else{
                self.badgeLabel.isHidden = true
            }
            
        }*/
    }
    
    //Open Friends request
    func openFriendsRequestListFromNotification(){
        appDelegateShared.isOpenFriendsRequestFromNotification = false
        NotificationCenter.default.post(name: Notification.Name(NotificationName().OpenFriendsRequest), object: nil)
    }

}
// MARK: - Button Actions
extension ChatViewController {
    @IBAction func btnSegmentAction(_ sender: UIButton) {
        self.view.endEditing(true)
        sender.backgroundColor = UIColor(named: "tab_selected")
        switch sender.tag {
        case 0:     // friend list
            NotificationCenter.default.post(name: Notification.Name(NotificationName().RefreshMyFriendList), object: nil)
            print("")
            btnClubList.backgroundColor = UIColor(named: "tab_unselected")
            btnUserChatList.backgroundColor = UIColor(named: "tab_unselected")
            UIView.animate(withDuration: 0.2, animations: {
                self.containerFriendList.alpha = 1
                self.containerClubList.alpha = 0
                self.containerUserChat.alpha = 0
            })
            self.setLeftAlignTitleView(font: UIFont(name: "ProductSans-Bold", size: 17)!, text: "Friends".localized, textColor: .white)
        case 1:     // club list
            print("")
            btnFriendList.backgroundColor = UIColor(named: "tab_unselected")
            btnUserChatList.backgroundColor = UIColor(named: "tab_unselected")
            UIView.animate(withDuration: 0.2, animations: {
                self.containerFriendList.alpha = 0
                self.containerClubList.alpha = 1
                self.containerUserChat.alpha = 0
            })
            self.setLeftAlignTitleView(font: UIFont(name: "ProductSans-Bold", size: 17)!, text: "Club Chat".localized, textColor: .white)
        case 2:     // user chat list
            print("")
            btnClubList.backgroundColor = UIColor(named: "tab_unselected")
            btnFriendList.backgroundColor = UIColor(named: "tab_unselected")
            UIView.animate(withDuration: 0.2, animations: {
                self.containerFriendList.alpha = 0
                self.containerClubList.alpha = 0
                self.containerUserChat.alpha = 1
            })
            self.setLeftAlignTitleView(font: UIFont(name: "ProductSans-Bold", size: 17)!, text: "Friends Chat".localized, textColor: .white)
        default:
            print("")
        }
        
        
    }

}
// MARK: - API CALL
extension ChatViewController {
    func CallAPINotificationsCount(){       // Get unread notifications count
        APIManager.callAPIRequest(Method: .post, url: "\(api_unreadMessageCount)", parameters: APIParam.messageNotificationsCount(club_name: UserDefaults.standard.object(forKey: "club_name") as? String ?? "", user_id: UserDefaults.standard.object(forKey: "user_id") as? String ?? "", language: "\(Language.language)", macAddress: "").getParam(), headers: nil, showAlert: false, completion: { (jsonData, msg) in
            logD(jsonData)
            if jsonData["flag"].stringValue == "1"{
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
                let message : String = JSON(jsonData["message"]).stringValue
                self.showAlert(title: Shared().error, message: message)
           }
                
        }) { (httpResponse, errorMsg) in
            //logD(httpResponse ?? "")
            //logD(errorMsg ?? "")
            self.showAlert(title: "", message: errorMsg)
        }

    }
}
    
// MARK: - API CALL
extension ChatViewController {
    func openChatDetailsFromNotification(){
        if appDelegateShared.isFromNotification{
            appDelegateShared.isFromNotification = false
            if appDelegateShared.chatRedirectionType == 1{ //User chat redirection
                self.btnSegmentAction(self.btnUserChatList)
                let vc = storyboardName.storyBoard_Chat.instantiateViewController(withIdentifier: "ChatDetailsVC") as! ChatDetailsVC
                vc.userid = notificationPayload["userId"].stringValue
                vc.receiverName = notificationPayload["userName"].stringValue
                vc.isFromClubChat = false
                self.notificationPayload = JSON("")
                self.navigationController?.pushViewController(vc, animated: false)
                
            }else if appDelegateShared.chatRedirectionType == 2{ //Club chat redirection
                self.btnSegmentAction(self.btnClubList)
                let vc = storyboardName.storyBoard_Chat.instantiateViewController(withIdentifier: "ChatDetailsVC") as! ChatDetailsVC
                vc.userid = notificationPayload["userId"].stringValue
                vc.receiverName = notificationPayload["clubName"].stringValue
                self.notificationPayload = JSON("")
                vc.isFromClubChat = true
                self.navigationController?.pushViewController(vc, animated: false)
            }
        }
    }
}
