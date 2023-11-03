//
//  PreRegistrationCodeVC.swift
//  CCSMembersApp
//
//  Created by Divyesh Dabhi on 24/04/23.
//  Copyright © 2023 Jaimin Patel. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import SlideMenuControllerSwift

class PreRegistrationCodeVC: UIViewController {

    
    @IBOutlet weak var btnSubmit: UIButton!
    //@IBOutlet weak var txtCode: UITextField!
    @IBOutlet weak var lblCodeTitle: UILabel!
    @IBOutlet weak var txtCode: CustomNewTextField!
    
    var item1:UIBarButtonItem?
    var item2:UIBarButtonItem?
    var item3:UIBarButtonItem?
    var item4:UIBarButtonItem?
    var badgeLabel = UILabel()
    override func viewDidLoad() {
        super.viewDidLoad()
        appDelegateShared.preRegClubName = ""
        appDelegateShared.preRegClubCode = ""
        //self.setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //self.setupLanguageData()
        self.txtCode.textField.text = ""
        self.setupUI()
    }
    
    func setupUI(){
        self.setLeftAlignTitleView(font: UIFont(name: "ProductSans-Bold", size: 17)!, text: "Pre_Registration".localized, textColor: .white)
        navigationController?.navigationBar.barTintColor = UIColor.white
        
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(named: "NavigationText")!, NSAttributedString.Key.font: UIFont(name: "ProductSans-Bold", size: 17)!]
        navigationItem.leftBarButtonItem?.tintColor = UIColor(named: "NavigationText")!
        self.txtCode.leftImage = UIImage(named: "ic_email")
        self.txtCode.textField.autocapitalizationType = .allCharacters
        self.txtCode.textField.autocorrectionType = UITextAutocorrectionType.no
        self.setupLanguage()
        self.setNavigationBarButtonOnRight()
    }
    
    func setNavigationBarButtonOnRight(){
        self.setNavigationBarItem()
        self.navigationController?.navigationBar.isHidden = false
        navigationItem.leftBarButtonItem?.tintColor = UIColor(named: "NavigationText")
        var imageShopingCart = Shared().imageWithImage(image: UIImage(named: "Shoping_Cart")!, scaledToSize: CGSize(width: 23, height: 23))
        imageShopingCart = imageShopingCart.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        
        var imageNotification = Shared().imageWithImage(image: UIImage(named: "Notification_icon")!, scaledToSize: CGSize(width: 23, height: 23))
        imageNotification = imageNotification.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        
        /* var imageQRCode = Shared().imageWithImage(image: UIImage(named: "icon_showQRCode")!, scaledToSize: CGSize(width: 23, height: 23))
         imageQRCode = imageQRCode.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
         
         var imageChat = Shared().imageWithImage(image: UIImage(named: "icon_chat_topbar")!, scaledToSize: CGSize(width: 25, height: 25))
         imageChat = imageChat.withRenderingMode(UIImage.RenderingMode.alwaysOriginal) */
        
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
        let notification_count = UserDefaults.standard.string(forKey: "notifcount") as? String ?? "0"
        if notification_count != "0" {
            self.item2?.addBadge(number: Int(notification_count ?? "") ?? 0)
        } else{
            self.item2?.removeBadge()
        }
        
        let btn4 = UIButton(type: .custom)
        //btn4.setImage(imageChat, for: .normal)
        //btn4.addTarget(self, action: #selector(self.openFriendsChatScreen), for: .touchUpInside)
        btn4.frame = CGRect(x: 0, y: 0, width: 28, height: 28)
        btn4.addSubview(self.badgeLabel)
        item4 = UIBarButtonItem(customView: btn4)
        item4?.removeBadge()
        
        //        self.setupMessageCount()
        if targetName != Shared().cannibisAppName {
            if let _ = UserDefaults.standard.object(forKey: "club_name"){
                self.navigationItem.setRightBarButtonItems([item1!,item2!,item4!], animated: true)
            }else{
                self.navigationItem.setRightBarButtonItems([item1!,item4!], animated: true)
            }
            
        } else {
            if let _ = UserDefaults.standard.object(forKey: "club_name"){
                self.navigationItem.setRightBarButtonItems([item2!,item4!], animated: true)
            }else{
                self.navigationItem.setRightBarButtonItems([item4!], animated: true)
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
    
    func setupLanguage(){
        self.txtCode.lblTitle.textColor = .white
        self.txtCode.placeholderMessage = "Enter_Code".localized
        self.btnSubmit.setTitle("SUBMIT".localized, for: .normal)
        self.txtCode.textField.setPlaceholder(txt: "Insert_code_here".localized, color: UIColor.CommonText)
        //self.lblCodeTitle.text = "Enter_Code".localized
       
    }
    
    @objc func cartRedirection(){
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "CartScreenVC") as! CartScreenVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func notificationScreenRedirection(){
        let storyBoard=UIStoryboard(name: "Main", bundle: nil)
        let vc=storyBoard.instantiateViewController(withIdentifier: "NotificationVC") as! NotificationVC
        let navVC=UINavigationController(rootViewController: vc)
        self.slideMenuController()?.changeMainViewController(navVC, close: true)
    }
    
    @IBAction func btnSubmit(_ sender: UIButton) {
        self.view.endEditing(true)
        if self.txtCode.text ?? "" == ""{
            self.txtCode.errorMessage = "msg_enter_code".localized
            self.txtCode.errorLabel.textColor = UIColor(hexString: "#EBEDEF")
        }else{
            self.txtCode.errorMessage = ""
            self.callAPIAddCode()
            
            //let vc = storyboardName.storyBoard_PreRegistration.instantiateViewController(withIdentifier: "PreRegistrationTermsAndCondVC") as! PreRegistrationTermsAndCondVC
            //self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

//MARK: Extension for api call
extension PreRegistrationCodeVC:NVActivityIndicatorViewable{
    func callAPIAddCode() {
        startAnimating(CGSize(width: 100, height: 100), message: "", type: NVActivityIndicatorType.ballRotate, fadeInAnimation: nil)
        APIManager.callAPIRequest(Method: .post, url: "\(api_PreRegAddCode)", parameters: APIParam.PreRegAddCode(code: self.txtCode.text ?? "").getParam(), headers: nil, showAlert: false, completion: { (jsonResult, msg) in
            logD(jsonResult)
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                self.stopAnimating(nil)
                
            }
            if jsonResult["flag"].stringValue == "1"{   // ~~~9S flag = 1 ==> for check Menu option allow to show/hide
                appDelegateShared.preRegClubName = jsonResult["club_name"].stringValue
                appDelegateShared.preRegClubCode = self.txtCode.text ?? ""
                let vc = storyboardName.storyBoard_PreRegistration.instantiateViewController(withIdentifier: "PreRegistrationTermsAndCondVC") as! PreRegistrationTermsAndCondVC
                self.navigationController?.pushViewController(vc, animated: true)
            }else{
                self.showAlert(title: "Error".localized, message: jsonResult["message"].stringValue)
            }
                
        }) { (httpResponse, errorMsg) in
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                self.stopAnimating(nil)
            }
            self.showAlert(title: "", message: errorMsg)
        }
    }
}
