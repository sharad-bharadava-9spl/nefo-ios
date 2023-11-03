//
//  ChangePasscodeVC.swift
//  CCSMembersApp
//
//  Created by Jaimin Patel on 3/19/20.
//  Copyright © 2020 Jaimin Patel. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import NVActivityIndicatorView
import SlideMenuControllerSwift

class ChangePasscodeVC: UIViewController,NVActivityIndicatorViewable {

   
    @IBOutlet weak var btnSubmitOutlet: UIButton!
    @IBOutlet weak var newPasswordTextField: CustomNewTextField!
    @IBOutlet weak var confirmPasswordTextField: CustomNewTextField!
    @IBOutlet weak var oldPasswordTextField: CustomNewTextField!
    @IBOutlet weak var titleText: UILabel!

  
    var item1:UIBarButtonItem?
    var item2:UIBarButtonItem?
    var item3:UIBarButtonItem?
    var item4:UIBarButtonItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.barTintColor = UIColor.white//UIColor(named: "backgroundViewColor")
       // navigationController?.navigationBar.topItem?.title = "Reset Password".localized.uppercased()
//        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(named: "NavigationText"), NSAttributedString.Key.font: UIFont(name: "ProductSans-Bold", size: 17)!]
        navigationItem.leftBarButtonItem?.tintColor = UIColor(hexString: "#33FF99")
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
        self.view.resignFirstResponder()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupMultilanguage()
        newPasswordTextField.textField.isSecureTextEntry = true
        oldPasswordTextField.textField.isSecureTextEntry = true
        confirmPasswordTextField.textField.isSecureTextEntry = true
       // self.setNavigationBarItem()
        newPasswordTextField.placeholderMessage = "Enter your new password".localized
        newPasswordTextField.lblTitle.textColor = UIColor.white
        newPasswordTextField.leftImage = UIImage(named: "Side_menu_Password")
        newPasswordTextField.textField.setPlaceholder(txt: "Enter your new password".localized, color: UIColor.CommonText)
        
        confirmPasswordTextField.placeholderMessage = "Repeat password".localized
        confirmPasswordTextField.lblTitle.textColor = UIColor.white
        confirmPasswordTextField.leftImage = UIImage(named: "Side_menu_Password")
        confirmPasswordTextField.textField.setPlaceholder(txt: "Repeat password".localized, color: UIColor.CommonText)

        oldPasswordTextField.placeholderMessage = "Enter your old password".localized
        oldPasswordTextField.lblTitle.textColor = UIColor.white
        oldPasswordTextField.leftImage = UIImage(named: "Side_menu_Password")
        oldPasswordTextField.textField.setPlaceholder(txt: "Enter your old password".localized, color: UIColor.CommonText)


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
        btn2.frame = CGRect(x: 0, y: 0, width: 35, height: 35)
        btn2.addTarget(self, action: #selector(self.notificationScreenRedirection), for: .touchUpInside)
        item2 = UIBarButtonItem(customView: btn2)
        let notification_count = UserDefaults.standard.string(forKey: "notifcount") as? String ?? "0"
        if notification_count != "0" {
            self.item2?.addBadge(number: Int(notification_count ?? "") ?? 0)
        } else{
            self.item2?.removeBadge()
        }
        
        if targetName != Shared().cannibisAppName {
            if let _ = UserDefaults.standard.object(forKey: "club_name"){
                self.navigationItem.setRightBarButtonItems([item1!,item2!], animated: true)
            }else{
                self.navigationItem.setRightBarButtonItems([item1!], animated: true)
            }
            
        } else {
            if let _ = UserDefaults.standard.object(forKey: "club_name"){
                self.navigationItem.setRightBarButtonItems([item2!], animated: true)
            }
        }
        if targetName != Shared().cannibisAppName {
            if let _ = UserDefaults.standard.object(forKey: "club_name"){
                self.navigationItem.setRightBarButtonItems([item1!,item2!], animated: true)
            }else{
                self.navigationItem.setRightBarButtonItems([item1!], animated: true)
            }
        } else {
            if let _ = UserDefaults.standard.object(forKey: "club_name"){
                self.navigationItem.setRightBarButtonItems([item2!], animated: true)
            }
        }
        var menu = Shared().imageWithImage(image: UIImage(named: "Menu_icon-green")!, scaledToSize: CGSize(width: 30, height: 23))
        menu = menu.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        let btn1 = UIButton(type: .custom)
        btn1.setImage(menu, for: .normal)
        btn1.frame = CGRect(x: 0, y: 0, width: 28, height: 28)
        btn1.addTarget(self, action:#selector(self.toggleLeft), for: .touchUpInside)
        item3 = UIBarButtonItem(customView: btn1)
        item3?.removeBadge()
        let label = UILabel()
        label.font = UIFont(name: "Montserrat-Bold", size: 16)
        label.frame = CGRect(x: 10, y: 0, width: 100, height: 28)
        label.textColor =  Shared().hexStringToUIColor("#FFFFFF")
        label.text = "Change password".localized.capitalized
        item4 = UIBarButtonItem(customView: label)
        item4?.removeBadge()
        self.navigationItem.setLeftBarButtonItems([item3!,item4!], animated: true)
//        navigationController?.navigationBar.barTintColor = UIColor.white//UIColor(named: "backgroundViewColor")
//        navigationController?.navigationBar.topItem?.title = "Change Passcode".localized.uppercased()
//        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(named: "NavigationText")!, NSAttributedString.Key.font: UIFont(name: "ProductSans-Bold", size: 17)!]
//        navigationItem.leftBarButtonItem?.tintColor = UIColor(named: "NavigationText")!
    }
    
    @objc func notificationScreenRedirection(){
        let storyBoard=UIStoryboard(name: "Main", bundle: nil)
        let vc=storyBoard.instantiateViewController(withIdentifier: "NotificationVC") as! NotificationVC
        let navVC=UINavigationController(rootViewController: vc)
        self.slideMenuController()?.changeMainViewController(navVC, close: true)
    }
    
    @objc func cartRedirection(){
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "CartScreenVC") as! CartScreenVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
//        navigationController?.navigationBar.barTintColor = UIColor.white//UIColor(named: "backgroundViewColor")
//        navigationController?.navigationBar.topItem?.title = "Change Passcode".localized.uppercased()
//        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(named: "NavigationText"), NSAttributedString.Key.font: UIFont(name: "ProductSans-Bold", size: 17)!]
//        navigationItem.leftBarButtonItem?.tintColor = UIColor(named: "NavigationText")
    }
    
    func setupMultilanguage(){
       
        self.btnSubmitOutlet.setTitle("Change password".localized, for: .normal)
        self.titleText.text = "your_new_password_must_be_".localized
    }
    
    @IBAction func btnSubmit(_ sender: UIButton) {
        let oldPasscode = oldPasswordTextField.textField.text

        let newPasscode = newPasswordTextField.textField.text
        
        let confirmPasscode = confirmPasswordTextField.textField.text
        
        let isUserPasswordValid = appDelegateShared.regexPassword.evaluate(with: newPasscode)
        
        if oldPasscode == ""{
            oldPasswordTextField.errorMessage = "Please enter old password".localized
            oldPasswordTextField.errorLabel.textColor = UIColor(hexString: "#33FF99")
        }
        else if newPasswordTextField.textField.text == "" {
            oldPasswordTextField.errorMessage = ""
            newPasswordTextField.errorMessage = "Please enter valid new passcode.".localized
            newPasswordTextField.errorLabel.textColor = UIColor(hexString: "#33FF99")
        } else if !isUserPasswordValid {
            newPasswordTextField.errorMessage = "password_validation".localized
            newPasswordTextField.errorLabel.textColor = UIColor(hexString: "#33FF99")
        } else if newPasscode != confirmPasscode {
            newPasswordTextField.errorMessage = ""
           confirmPasswordTextField.errorMessage = "Passwords do not match".localized
            confirmPasswordTextField.errorLabel.textColor = UIColor(hexString: "#33FF99")
        } else {
            oldPasswordTextField.errorMessage = ""
            newPasswordTextField.errorMessage = ""
           confirmPasswordTextField.errorMessage = ""
            print("newPasscode Pin ::",newPasscode)
            print("confirmPasscode Pin ::",confirmPasscode)
            print("Sucess")
            self.dismissKeyboard()
            
            self.changePasscode(newpasscode:newPasscode ?? "")
        }
    }
}

extension ChangePasscodeVC:UITextFieldDelegate{
   
}

extension ChangePasscodeVC{
    /*
     user_id
      newpassport
      language
     club_name
     */
    func changePasscode(newpasscode:String){
        startAnimating(CGSize(width: 100, height: 100), message: "", type: NVActivityIndicatorType.ballRotate, fadeInAnimation: nil)
        let parameters: Parameters = [
            "language" : "\(Language.language)",
            "email" : "\(UserDefaults.standard.object(forKey: "MyEmail") ?? "")",
            "old_password" : self.oldPasswordTextField.text ?? "",
            "new_password" : newpasscode,
            "platform" : Shared().device_platform,
            "device_id" : UIDevice.current.identifierForVendor!.uuidString,
            "fcm_key" : deviceTokenString,
            "macAddress" : Shared().getWifi(),
        ]
//        print("\(Shared().webCall)changePassword?language=\(Language.language)&club_name=\(UserDefaults.standard.object(forKey: "club_name") as! String)&newpassport=\(newpasscode)&platform=\(Shared().device_platform)&device_id=\(UIDevice.current.identifierForVendor!.uuidString)&user_id=\(UserDefaults.standard.string(forKey: "user_id") ?? "")")
        Alamofire.request("\(Shared().webCall)changeMemberPassword.php", method: .post, parameters: parameters)
            .responseJSON { response in
                let when = DispatchTime.now()
                DispatchQueue.main.asyncAfter(deadline: when) {
                    self.stopAnimating(nil)
                }
                
                switch response.result {
                case .success:
                    print("JSON::",response.result.value!)
                    // alert.dismiss(animated: true, completion: {
                    if let jsonData = response.result.value as? [String:Any] {
                        let flag = JSON(jsonData["flag"]!).stringValue
                        if flag == "1"{
                            let uiAlert = UIAlertController(title: Shared().title, message: JSON(jsonData["message"]!).stringValue, preferredStyle:.alert)
                            uiAlert.addAction(UIAlertAction(title: "Ok".localized, style: .default, handler: { action in
                                self.logOut()
                                /*appDelegateShared.selectedIndexMenu = 0
                                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                let appDelegate = UIApplication.shared.delegate as? AppDelegate
                                let initialViewController = storyboard.instantiateViewController(withIdentifier: "MainMenuVC") as! MainMenuVC
                                let leftViewController = storyboard.instantiateViewController(withIdentifier: "SlideMenuScreenVC") as! SlideMenuScreenVC
                                let nvc: UINavigationController = UINavigationController(rootViewController: initialViewController)
                                let slideMenuController = SlideMenuController(mainViewController: nvc,  leftMenuViewController: leftViewController)
                                slideMenuController.automaticallyAdjustsScrollViewInsets = true
                                appDelegate?.window?.backgroundColor = UIColor(red: 236.0, green: 238.0, blue: 241.0, alpha: 1.0)
                                appDelegate?.window?.rootViewController = slideMenuController
                                appDelegate?.window?.makeKeyAndVisible()
                                SlideMenuOptions.contentViewScale = 1
                                SlideMenuOptions.hideStatusBar = false
                                SlideMenuOptions.simultaneousGestureRecognizers = false*/
                                
                            }))
                            self.present(uiAlert, animated: true, completion: nil)
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
    
}

