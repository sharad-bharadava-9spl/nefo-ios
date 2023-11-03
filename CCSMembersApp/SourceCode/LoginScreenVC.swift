//
//  LoginScreenVC.swift
//  CCSMembersApp
//
//  Created by Jaimin Patel on 6/7/19.
//  Copyright © 2019 Jaimin Patel. All rights reserved.
//

import UIKit
import SlideMenuControllerSwift
import ActionSheetPicker_3_0
import NVActivityIndicatorView
import Alamofire
import SwiftyJSON
import CoreData
import Firebase

class LoginScreenVC: UIViewController,NVActivityIndicatorViewable {
    
    @IBOutlet weak var btnRegister: UIButton!
  
    @IBOutlet weak var languageStackViewHeight: NSLayoutConstraint!
    @IBOutlet weak var languageViewWidth: NSLayoutConstraint!
    @IBOutlet weak var languageViewHeight: NSLayoutConstraint!
    @IBOutlet weak var logoHeight: NSLayoutConstraint!
    @IBOutlet weak var btnEngish: UIButton!
   
    @IBOutlet weak var btnSpanish: UIButton!
    @IBOutlet weak var imgBackground: UIImageView!
   
    @IBOutlet weak var btnLoginOutlet: UIButton!
    @IBOutlet weak var txtUserName: CustomNewTextField!
    @IBOutlet weak var txtPassword: CustomNewTextField!
    @IBOutlet weak var lblNotMember: UILabel!
    @IBOutlet weak var lblRemember: UILabel!
    @IBOutlet weak var btnForgot: UIButton!
    @IBOutlet var viewAlert: UIView!
    @IBOutlet weak var lblRegisterSucess: UILabel!
    @IBOutlet weak var viewCheck: UIView!
    @IBOutlet weak var imgCheck: UIImageView!
    
    var clubListing=[clubList]()
    var clubfilteredData=[clubList]()
    var backBtn:String=""

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIBarButtonItem.appearance(whenContainedInInstancesOf:[UISearchBar.self]).tintColor = UIColor(named: "statusBackgroundColour")
        UIBarButtonItem.appearance(whenContainedInInstancesOf:[UISearchBar.self]).title = "Cancel".localized
        self.navigationController?.navigationBar.isHidden=true
       
       // btnLoginOutlet.shadowColor(color: UIColor.black.withAlphaComponent(0.2), border: 1.0, offHeight: 3.0)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView=false
        self.view.addGestureRecognizer(tap)
        
        let flexible = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: self, action: nil)
        let toolbarDone = UIToolbar.init()
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done".localized, style: .done, target: self, action: #selector(dismissKeyboard))//UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissKeyboard))
        toolbarDone.sizeToFit()
        toolbarDone.items =  [flexible,done]
        
        let gesture = UITapGestureRecognizer(target: self, action:  #selector(self.checkAction))
        self.viewCheck.addGestureRecognizer(gesture)
        imgCheck.isHidden = true


    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.removeNavigationBarItem()
        self.navigationController?.navigationBar.isHidden=true
        //self.imgBackground.image = UIImage(named : Shared().getImgName())
        txtUserName.leftImage = UIImage(named: "ic_email")
        txtPassword.leftImage = UIImage(named: "Side_menu_Password")
        txtUserName.textField.keyboardType = .emailAddress
        txtUserName.errorMessage = ""
        txtPassword.errorMessage = ""
        
        setupLanguage()
        
//        if let _ : AnyObject = UserDefaults.standard.object(forKey: "user_id") as AnyObject? {
//            self.btnBack.isHidden=false
//        } else{
//            self.btnBack.isHidden=true
//        } icon-check
        
//        if appDelegateShared.isFromLogout{
            print("appDelegateShared.isFromLogout")
            print(appDelegateShared.isFromLogout)
            print("appDelegateShared.isRemember")
            print(appDelegateShared.isRemember)
            appDelegateShared.isFromLogout = false
            if getFromUserDefaultForKey(key_isRememberMe)?.boolValue == true{
                imgCheck.isHidden = false
                txtPassword.textField.text = getFromUserDefaultForKey(key_Password)?.stringValue
                txtUserName.textField.text = getFromUserDefaultForKey(key_MyEmail)?.stringValue
            }else{
                imgCheck.isHidden = true
            }
//        }
        
        
        if #available(iOS 13.0, *) {
            let statusBar = UIView(frame: (UIApplication.shared.keyWindow?.windowScene?.statusBarManager?.statusBarFrame)!)
            statusBar.backgroundColor = UIColor.ThemDarkGreen
            UIApplication.shared.keyWindow?.addSubview(statusBar)
        }
    }
    
//    @IBAction func btnBack(_ sender: UIButton) {
//        if let _ : AnyObject = UserDefaults.standard.object(forKey: "user_id") as AnyObject? {
//            self.goHomeScreen()
//        }
//    }
    @objc func checkAction(sender : UITapGestureRecognizer) {
        if imgCheck.isHidden{
            imgCheck.isHidden = false
            appDelegateShared.isRemember = true
            setToUserDefaultForKey(true as AnyObject, key: key_isRememberMe)
        }else{
            imgCheck.isHidden = true
            appDelegateShared.isRemember = false
            setToUserDefaultForKey(false as AnyObject, key: key_isRememberMe)
        }
    }
    func goHomeScreen(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        var initialViewController=UIViewController()
        if let _ : AnyObject = UserDefaults.standard.object(forKey: "user_id") as AnyObject? {
            if let _ : AnyObject = UserDefaults.standard.object(forKey: "addMemberAccount") as AnyObject?{
                if JSON(UserDefaults.standard.object(forKey: "addMemberAccount")!).stringValue == "falseSetting"{
                    initialViewController = storyboard.instantiateViewController(withIdentifier: "SettingScreenVC") as! SettingScreenVC
                } else{
                    initialViewController = storyboard.instantiateViewController(withIdentifier: "HomeScreenVC") as! HomeScreenVC
                }
            } else{
                initialViewController = storyboard.instantiateViewController(withIdentifier: "MainMenuVC") as! MainMenuVC
            }
        } else{
            initialViewController = storyboard.instantiateViewController(withIdentifier: "MainMenuVC") as! MainMenuVC
        }
        
        UserDefaults.standard.set("true", forKey: "addMemberAccount")
        let leftViewController = storyboard.instantiateViewController(withIdentifier: "SlideMenuScreenVC") as! SlideMenuScreenVC
        let nvc: UINavigationController = UINavigationController(rootViewController: initialViewController)
        let slideMenuController = SlideMenuController(mainViewController: nvc,  leftMenuViewController: leftViewController)
        slideMenuController.automaticallyAdjustsScrollViewInsets = true
        appDelegate?.window?.backgroundColor = UIColor(red: 236.0, green: 238.0, blue: 241.0, alpha: 1.0)
        appDelegate?.window?.rootViewController = slideMenuController
        appDelegate?.window?.makeKeyAndVisible()
        SlideMenuOptions.contentViewScale = 1
        SlideMenuOptions.hideStatusBar = false
        SlideMenuOptions.simultaneousGestureRecognizers = false
    }
    
    func addRegisterAlert(){
        viewAlert.frame = self.view.frame
        self.view.addSubview(viewAlert)
    }
    
    func removeRegisterAlert(){
        viewAlert.removeFromSuperview()
    }
    
    @IBAction func btnRegisterAction(_ sender: UIButton) {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "RegisterScreenVC") as! RegisterScreenVC
        vc.callBackRegister = { msg in
            self.addRegisterAlert()
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnForgotAction(_ sender: UIButton) {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "ForgotPasswordScreenVC") as! ForgotPasswordScreenVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnActionEngish(_ sender: UIButton) {
        self.btnEngish.backgroundColor = UIColor.black
        self.btnEngish.setTitleColor(UIColor.white, for: .normal)
        
        self.btnSpanish.backgroundColor = UIColor.white
        self.btnSpanish.setTitleColor(UIColor.black, for: .normal)
        
        Language.language = Language.en
        setupLanguage()
    }
    
    @IBAction func btnEspanolAction(_ sender: UIButton) {
        self.btnSpanish.backgroundColor = .black
        self.btnSpanish.setTitleColor(UIColor.white, for: .normal)
        
        self.btnEngish.backgroundColor = .white
        self.btnEngish.setTitleColor(.black, for: .normal)
        
        Language.language = Language.es
        setupLanguage()
    }
    
    func setupLanguage(){
        self.btnEngish.setTitle("English".localized, for: .normal)
        self.btnSpanish.setTitle("Spanish".localized, for: .normal)
        self.txtUserName.placeholderMessage="Email".localized
        self.txtPassword.placeholderMessage="Password".localized
        self.txtUserName.lblTitle.textColor = .white
        self.txtPassword.lblTitle.textColor = .white
        
        
        self.btnLoginOutlet.setTitle("LOGIN".localized, for: .normal)
        self.btnRegister.setTitle("Register_here".localized, for: .normal)
        lblRemember.text = "Remember_me".localized
        lblNotMember.text = "Not_a_member_yet".localized
        btnForgot.setTitle("FORGOT_PASSWORD".localized, for: .normal)
        
        txtUserName.textField.setPlaceholder(txt: "dummy_Email".localized, color: UIColor.CommonText)
        txtPassword.textField.setPlaceholder(txt: "Password".localized, color: UIColor.CommonText)
        txtPassword.textField.isSecureTextEntry = true
        
        lblRegisterSucess.text = "User_Registered_Successfully".localized
        
        let gesture = UITapGestureRecognizer(target: self, action:  #selector(self.tapViewAlert))
        self.viewAlert.addGestureRecognizer(gesture)
        lblRegisterSucess.font = UIFont(name: "Roboto-Regular", size: 16.0)
    }
    
    
    @objc func tapViewAlert(sender : UITapGestureRecognizer) {
       removeRegisterAlert()
    }

    
    @objc func dismissKeyboard() {
        view.endEditing(true)
        self.view.resignFirstResponder()
    }
    
    override func viewDidLayoutSubviews() {
//        self.languageViewHeight.constant=75
//        self.logoHeight.constant=85
//        self.languageStackViewHeight.constant=30
//
//
//        self.languageViewWidth.constant=220
//        if Shared().getScreenHeight() == 667{
//
//
//            self.languageViewHeight.constant=110
//            self.logoHeight.constant=100
//            self.languageStackViewHeight.constant=40
//
//
//            self.languageViewWidth.constant=250
//        } else if Shared().getScreenHeight() > 667{
//            print("Shared().getScreenWidth()",Shared().getScreenWidth())
//            print("Shared().getScreenHeight()",Shared().getScreenHeight())
//
//            self.languageViewHeight.constant=110
//            self.logoHeight.constant=120
//            self.languageStackViewHeight.constant=40
//
//
//            self.languageViewWidth.constant=250
//        } else{
//
//        }
//
        if "\(Language.language)" == "en"{
            self.btnEngish.backgroundColor = UIColor(hexString: "#0EFF86")
            self.btnEngish.setTitleColor(UIColor.black, for: .normal)
            
            self.btnSpanish.backgroundColor = UIColor(hexString: "#EBEDEF")
            self.btnSpanish.setTitleColor(.black, for: .normal)
        } else{
            self.btnSpanish.backgroundColor = UIColor(hexString: "#0EFF86")
            self.btnSpanish.setTitleColor(UIColor.black, for: .normal)
            
            self.btnEngish.backgroundColor = UIColor(hexString: "#EBEDEF")
            self.btnEngish.setTitleColor(.black, for: .normal)
        }
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
       
        let userInfo: NSDictionary = notification.userInfo! as NSDictionary
        let keyboardInfo = userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue
        let keyboardSize = keyboardInfo.cgRectValue.size
        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height+20, right: 0)
      
    }
    @objc func keyboardWillHide(notification: NSNotification) {
       
    }
    
   
    func validateEmail(_ email: String? = nil) -> Bool {
        guard let userEmail = email, userEmail.isEmpty == false else { return false }
        let isEmailValid = NSPredicate(format: "SELF MATCHES %@", "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,10}").evaluate(with: email)
        guard isEmailValid else { return false  }
        return true
    }
    @IBAction func btnLogin(_ sender: UIButton) {
        //loginAPI()
       // txtUserName.textField.text  = //"mark1@yopmail.com"//"tahirh@yopmail.com"//"shubh@yopmail.com"
       // txtPassword.textField.text = "Test@1234"//"aaaaaaA1@"
        
        print("self.txtPassword.text!",self.txtPassword.text!)
        let userName = "\((txtUserName.textField.text ?? "") as String)"
        let password = "\((txtPassword.textField.text ?? "") as String)"
        
        if(!validateEmail(userName)) {
            
            txtUserName.errorMessage = "Please enter a valid email address".localized
            txtPassword.errorMessage = ""
            self.txtUserName.errorLabel.textColor = UIColor(hexString: "#EBEDEF")
       }
//        else if(isValidEmail(userName)) {
//            Shared().showAlert(uIViewController: self, title: Shared().error, message: "Please enter username.".localized)
//        }
        else if password.count == 0 {
            
            txtPassword.errorMessage = "Please enter password.".localized
            txtUserName.errorMessage = ""
            self.txtPassword.errorLabel.textColor = UIColor(hexString: "#EBEDEF")
        } else if (deviceTokenString == nil) {
            Shared().showAlert(uIViewController: self, title: Shared().error, message: Shared().errorMsg)
        } else {
            print("Enter Pin ::",userName)
            print("memberPIN Pin ::",password)
            self.dismissKeyboard()
            txtUserName.errorMessage = ""
            txtPassword.errorMessage = ""
            setToUserDefaultForKey(userName as AnyObject, key: key_MyEmail)
            setToUserDefaultForKey(password as AnyObject, key: key_Password)
            //loginAPI(userName: userName, password: password, fcm_key: deviceTokenString, macAddress: Shared().getWifi())
            let memberId = getFromUserDefaultForKey(key_oldUserMemberID)?.stringValue ?? ""
            if memberId != "" {
                startAnimating(CGSize(width: 100, height: 100), message: "", type: NVActivityIndicatorType.ballRotate, fadeInAnimation: nil)
                appDelegateShared.callAPIRemoveFCMToken {
                    self.loginAPI(userName: userName, password: password, fcm_key: deviceTokenString, macAddress: Shared().getWifi())
                }
            }else{
                startAnimating(CGSize(width: 100, height: 100), message: "", type: NVActivityIndicatorType.ballRotate, fadeInAnimation: nil)
                self.loginAPI(userName: userName, password: password, fcm_key: deviceTokenString, macAddress: Shared().getWifi())
            }

        }
    }
    
    func setupLoginData(cart_count:String,domain:String,email:String,first_name:String,memberno:String,userGroup:String,user_id:String,workStation:String,image:String,user_type:String, clubName: String,member_id:String){
        print("first_name",first_name)
        if let _ : AnyObject = UserDefaults.standard.object(forKey: "user_id") as AnyObject? {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
            }
            let id=user_id
            let allreadyExist = isExist(id:Int(user_id)!)
            if allreadyExist == false{
                Shared().clearData()
                UserDefaults.standard.set(member_id, forKey: "member_id")
                UserDefaults.standard.set(cart_count, forKey: "Badge_cart_count")
                UserDefaults.standard.set(user_type, forKey: "check_adminLogin")
                UserDefaults.standard.set(domain, forKey: "domain")
                UserDefaults.standard.set(email, forKey: "email")
                UserDefaults.standard.set(first_name, forKey: "Name")
                UserDefaults.standard.set(memberno, forKey: "memberno")
                UserDefaults.standard.set(userGroup, forKey: "userGroup")
                UserDefaults.standard.set(user_id, forKey: "user_id")
                UserDefaults.standard.set(workStation, forKey: "workStation")
                UserDefaults.standard.set(image, forKey: "image")
                UserDefaults.standard.set(clubName, forKey: "club_name")
                UserDefaults.standard.set(clubName, forKey: "first_name")//For club_name

                Shared().firebaseProcess(visibility:"LOGIN")
                self.goHomeScreen()
            } else{
                self.view.endEditing(true)
                Shared().showAlert(uIViewController: self, title: Shared().error, message: "Account already added".localized)
            }
        } else{
            Shared().clearData()
            UserDefaults.standard.set(cart_count, forKey: "Badge_cart_count")
            UserDefaults.standard.set(user_type, forKey: "check_adminLogin")
            UserDefaults.standard.set(domain, forKey: "domain")
            UserDefaults.standard.set(email, forKey: "email")
            UserDefaults.standard.set(first_name, forKey: "Name")
            UserDefaults.standard.set(memberno, forKey: "memberno")
            UserDefaults.standard.set(userGroup, forKey: "userGroup")
            UserDefaults.standard.set(user_id, forKey: "user_id")
            UserDefaults.standard.set(workStation, forKey: "workStation")
            UserDefaults.standard.set(image, forKey: "image")
            UserDefaults.standard.set(clubName, forKey: "club_name")
            UserDefaults.standard.set(clubName, forKey: "first_name")//For club_name

            Shared().firebaseProcess(visibility:"LOGIN")
            self.goHomeScreen()
        }
        
    }
    
    func isExist(id: Int) -> Bool {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let managedContext = appDelegate!.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "FileStore")
        fetchRequest.predicate = NSPredicate(format: "user_id = %d", id)
        
        let res = try! managedContext.fetch(fetchRequest)
        return res.count > 0 ? true : false
    }
}

extension LoginScreenVC:UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == txtUserName.textField {
            txtPassword.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField.text?.count == 0 && string == " " {
            return false
        }
        
        return true
    }
}
//login_code : XPE6BJ,club_name = demo ,member_no = AH3 ,device_id ,platform
extension LoginScreenVC{
    func loginAPI(userName:String,password:String,fcm_key:String,macAddress:String) {
        
        let parameters: Parameters = [
            "language" : "\(Language.language)",
            "email" : userName.lowercased(),
            "password" : password,
            "platform" : Shared().device_platform,
            "device_id" : UIDevice.current.identifierForVendor!.uuidString,
            "fcm_key" : fcm_key,
            "macAddress" : macAddress,
        ]
        
        Alamofire.request("\(Shared().webCall)memberLogin.php", method: .post, parameters: parameters)
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
                            if let jsonDict = jsonData["data"] as? [String:Any]{
                                
                                if let name = jsonDict["username"] as? String {
                                    appDelegateShared.nameU = name
                                }
                                if let qrcode = jsonDict["qrcode"] as? String {
                                    setToUserDefaultForKey(qrcode as AnyObject, key: key_myQrCode)
                                }
//                                self.setupLoginData(cart_count: JSON(jsonData["cart_count"]).stringValue, domain:JSON(jsonDict["domain"]).stringValue,email:JSON(jsonDict["email"]).stringValue,first_name:JSON(jsonDict["first_name"]).stringValue,memberno:JSON(jsonDict["memberno"]).stringValue,userGroup:JSON(jsonDict["userGroup"]).stringValue,user_id:JSON(jsonDict["user_id"]).stringValue,workStation:JSON(jsonDict["workStation"]).stringValue,image:JSON(jsonDict["image"]).stringValue,user_type:JSON(jsonDict["user_type"]).stringValue, clubName: JSON(jsonDict["domain"]).stringValue,member_id: JSON(jsonDict["member_id"]).stringValue)
                                
                                
                            }

                            appDelegateShared.Email = userName
                            appDelegateShared.Password = password
                            
                            setToUserDefaultForKey(true as AnyObject, key: key_isLogin)
                            if let memberId = jsonData["member_id"] as? String{
                                UserDefaults.standard.set(memberId, forKey: "member_id")
                                MEMBER_ID = getFromUserDefaultForKey("member_id") as? String ?? ""
                                setToUserDefaultForKey(MEMBER_ID as AnyObject, key: key_oldUserMemberID)
                                setToUserDefaultForKey(fcm_key as AnyObject, key: key_oldUserFcmToken)
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    Messaging.messaging().subscribe(toTopic: getFromUserDefaultForKey("member_id") as? String ?? "")
                                }
                            }
                            let dict = ["email":JSON(jsonData["data"]!)["email"].stringValue,"name":JSON(jsonData["data"]!)["username"].stringValue,"token":fcm_key,"status":"LOGIN","isOnline":true]
                            FirebaseManager.sharedInstance.setUsersLoginData(userId: MEMBER_ID, dict: dict)
                            
//                            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
//                            let vc = storyBoard.instantiateViewController(withIdentifier: "AddNewClubVC") as! AddNewClubVC
//
//                            vc.clubfilteredData = self.clubfilteredData
//                            vc.clubListing = self.clubListing
//
//                            self.navigationController?.pushViewController(vc, animated: true)
                            appDelegateShared.selectedIndexMenu = 2
                            let storyboard = UIStoryboard(name: "Main", bundle: nil)
                            let appDelegate = UIApplication.shared.delegate as? AppDelegate
                            let initialViewController = storyboard.instantiateViewController(withIdentifier: "AddNewClubVC") as! AddNewClubVC
                            let leftViewController = storyboard.instantiateViewController(withIdentifier: "SlideMenuScreenVC") as! SlideMenuScreenVC
                            let nvc: UINavigationController = UINavigationController(rootViewController: initialViewController)
                            initialViewController.clubfilteredData = self.clubfilteredData
                            initialViewController.clubListing = self.clubListing
                            let slideMenuController = SlideMenuController(mainViewController: nvc,  leftMenuViewController: leftViewController)
                            slideMenuController.automaticallyAdjustsScrollViewInsets = true
                            appDelegate?.window?.backgroundColor = UIColor(red: 236.0, green: 238.0, blue: 241.0, alpha: 1.0)
                            appDelegate?.window?.rootViewController = slideMenuController
                            appDelegate?.window?.makeKeyAndVisible()
                            SlideMenuOptions.contentViewScale = 1
                            SlideMenuOptions.hideStatusBar = false
                            SlideMenuOptions.simultaneousGestureRecognizers = false
                            
                            
                            
                        }
                        else if flag == "2"{
                            if let dataAry = jsonData["club_data"] as? [[String:Any]] {
                                
                                let jsonVal=JSON(dataAry)
                                setToUserDefaultForKey(true as AnyObject, key: key_isLogin)
                                self.clubfilteredData.removeAll()
                                self.clubListing.removeAll()
                                
                                for item in 0..<jsonVal.count {
                                    let arrObj=clubList(json:jsonVal[item])
                                    self.clubListing.append(arrObj)
                                    self.clubfilteredData.append(arrObj)
                                }
                                print(self.clubListing)
                               
                                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                let appDelegate = UIApplication.shared.delegate as? AppDelegate
                                let initialViewController = storyboard.instantiateViewController(withIdentifier: "AddNewClubVC") as! AddNewClubVC
                                let leftViewController = storyboard.instantiateViewController(withIdentifier: "SlideMenuScreenVC") as! SlideMenuScreenVC
                                let nvc: UINavigationController = UINavigationController(rootViewController: initialViewController)
                                initialViewController.clubfilteredData = self.clubfilteredData
                                initialViewController.clubListing = self.clubListing
                                let slideMenuController = SlideMenuController(mainViewController: nvc,  leftMenuViewController: leftViewController)
                                slideMenuController.automaticallyAdjustsScrollViewInsets = true
                                appDelegate?.window?.backgroundColor = UIColor(red: 236.0, green: 238.0, blue: 241.0, alpha: 1.0)
                                appDelegate?.window?.rootViewController = slideMenuController
                                appDelegate?.window?.makeKeyAndVisible()
                                SlideMenuOptions.contentViewScale = 1
                                SlideMenuOptions.hideStatusBar = false
                                SlideMenuOptions.simultaneousGestureRecognizers = false
                            }
                        }
                        else{
                            let message : String = JSON(jsonData["message"]!).stringValue
                            Shared().showAlert(uIViewController: self, title: "", message: message)
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
    }
}

extension LoginScreenVC:UISearchBarDelegate{
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if(searchBar.text != "") {
            self.view.endEditing(true)
        }
        else {
            self.view.endEditing(true)
            self.clubListing.removeAll()
            for item in 0..<self.clubfilteredData.count{
                self.clubListing.append(self.clubfilteredData[item])
            }
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        self.view.endEditing(true)
        
        for item in 0..<self.clubfilteredData.count{
            self.clubListing.append(self.clubfilteredData[item])
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.clubListing.removeAll()
        if(self.clubfilteredData.count > 0) {
            for i in 0...self.clubfilteredData.count-1 {
                let brandName = self.clubfilteredData[i].club_name.lowercased()
                if(brandName.range(of: searchText.lowercased()) != nil) {
                    self.clubListing.append(self.clubfilteredData[i])
                }
            }
            if(searchText == "") {
                self.clubListing = self.clubfilteredData
            }
        }
    }
}

