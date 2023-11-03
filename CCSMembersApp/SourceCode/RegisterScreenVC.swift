//
//  RegisterScreenVC.swift
//  CCSMembersApp
//
//  Created by Apple on 10/01/22.
//  Copyright © 2022 Jaimin Patel. All rights reserved.
//

import UIKit
import SlideMenuControllerSwift
import ActionSheetPicker_3_0
import NVActivityIndicatorView
import Alamofire
import SwiftyJSON
import CoreData
import Firebase


class RegisterScreenVC: UIViewController,UITextFieldDelegate,NVActivityIndicatorViewable {

    
    @IBOutlet weak var btnSpanish: UIButton!
    @IBOutlet weak var btnEnglish: UIButton!
    @IBOutlet weak var imgBackground: UIImageView!
    @IBOutlet weak var btnRegister: UIButton!
    @IBOutlet weak var txtPassword: CustomNewTextField!
    @IBOutlet weak var txtUserName: CustomNewTextField!
    @IBOutlet weak var txtEmail: CustomNewTextField!
    @IBOutlet weak var txtConfirmPassword: CustomNewTextField!
    
    var clubListing=[clubList]()
    var clubfilteredData=[clubList]()
    var callBackRegister : ((_ value : String)->())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIBarButtonItem.appearance(whenContainedInInstancesOf:[UISearchBar.self]).tintColor = UIColor(named: "statusBackgroundColour")
        UIBarButtonItem.appearance(whenContainedInInstancesOf:[UISearchBar.self]).title = "Cancel".localized
        self.navigationController?.navigationBar.isHidden=true
       // btnRegister.shadowColor(color: UIColor.black.withAlphaComponent(0.2), border: 1.0, offHeight: 3.0)
        txtEmail.textField.delegate = self
        txtUserName.textField.delegate = self
        txtPassword.textField.delegate = self
        txtConfirmPassword.textField.delegate = self
        txtPassword.textField.addTarget(self, action: #selector(RegisterScreenVC.textFieldDidChange(_:)), for: .editingChanged)
        txtPassword.errorLabel.adjustsFontSizeToFitWidth = true
        txtPassword.errorLabel.minimumScaleFactor = 0.5
        txtEmail.leftImage = UIImage(named: "ic_email")
        txtPassword.leftImage = UIImage(named: "Side_menu_Password")
        txtConfirmPassword.leftImage = UIImage(named: "Side_menu_Password")
        txtUserName.leftImage = UIImage(named: "ic_user")
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView=false
        self.view.addGestureRecognizer(tap)
        
        let flexible = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: self, action: nil)
        let toolbarDone = UIToolbar.init()
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done".localized, style: .done, target: self, action: #selector(dismissKeyboard))//UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissKeyboard))
        toolbarDone.sizeToFit()
        toolbarDone.items =  [flexible,done]
        
        txtPassword.textField.isSecureTextEntry = true
        txtConfirmPassword.textField.isSecureTextEntry = true
        // Do any additional setup after loading the view.
    }
    
  
    func validateEmail(_ email: String? = nil) -> Bool {
        guard let userEmail = email, userEmail.isEmpty == false else { return false }
        let isEmailValid = NSPredicate(format: "SELF MATCHES %@", "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,10}").evaluate(with: email)
        guard isEmailValid else { return false  }
        return true
    }
    @objc func dismissKeyboard() {
        view.endEditing(true)
        self.view.resignFirstResponder()
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden=true

        self.removeNavigationBarItem()
        txtEmail.errorMessage = ""
        txtUserName.errorMessage = ""
        txtPassword.errorMessage = ""
        txtConfirmPassword.errorMessage = ""
      //  self.imgBackground.image = UIImage(named : Shared().getImgName())
        
        setupLanguage()
        
//        if let _ : AnyObject = UserDefaults.standard.object(forKey: "user_id") as AnyObject? {
//            self.btnBack.isHidden=false
//        } else{
//            self.btnBack.isHidden=true
//        }
        
        if #available(iOS 13.0, *) {
//            let statusBar = UIView(frame: (UIApplication.shared.keyWindow?.windowScene?.statusBarManager?.statusBarFrame)!)
//            statusBar.backgroundColor = UIColor(named: "statusBackgroundColour")!
//            UIApplication.shared.keyWindow?.addSubview(statusBar)
        }
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        guard let text = textField.text, !text.isEmpty else { return }
        let isUserPasswordValid = appDelegateShared.regexPassword.evaluate(with: text)
        if !isUserPasswordValid {
            txtPassword.errorMessage = "password_validation".localized
            txtPassword.errorLabel.textColor = UIColor(hexString: "#EBEDEF")
            txtPassword.txtView.borderWidths = 1
            txtPassword.txtView.borderColors = .red
        }else{
            txtPassword.errorMessage = ""
            txtPassword.txtView.borderColors = .clear
        }
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if self.view.frame.origin.y >= 0{
            self.viewMoveUp(moveUp: true)
        }
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        if self.view.frame.origin.y < 0{
            self.viewMoveUp(moveUp: false)
        }
    }
    func viewMoveUp(moveUp: Bool) {
        if moveUp {
            UIView.animate(withDuration: 0.25, delay: 0.25, options: .curveEaseInOut, animations: {
                self.view.frame = CGRect(x: 0, y: (self.view.frame.origin.y - 60), width: self.view.bounds.width, height: self.view.bounds.height)
            }, completion: nil)
        }else{
            UIView.animate(withDuration: 0.25, delay: 0.25, options: .curveEaseInOut, animations: {
                self.view.frame = CGRect(x: 0, y: (self.view.frame.origin.y + 60), width: self.view.bounds.width, height: self.view.bounds.height)
            }, completion: nil)
        }
            
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == txtEmail {
            txtUserName.becomeFirstResponder()
        }  else if textField == txtUserName {
            txtPassword.becomeFirstResponder()
        }  else if textField == txtPassword {
            txtConfirmPassword.becomeFirstResponder()
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
    func setupLanguage(){
        self.btnEnglish.setTitle("English".localized, for: .normal)
        self.btnSpanish.setTitle("Spanish".localized, for: .normal)
        txtEmail.placeholderMessage = "Email".localized
        txtUserName.placeholderMessage = "Username".localized
        txtPassword.placeholderMessage = "Set your password".localized
        txtConfirmPassword.placeholderMessage = "Repeat password".localized
        self.btnRegister.setTitle("REGISTER".localized, for: .normal)
        txtEmail.lblTitle.textColor = .white
        txtUserName.lblTitle.textColor = .white
        txtPassword.lblTitle.textColor = .white
        txtConfirmPassword.lblTitle.textColor = .white
        txtEmail.textField.setPlaceholder(txt: "dummy_Email".localized, color: UIColor.CommonText)
        txtUserName.textField.setPlaceholder(txt: "Username".localized, color: UIColor.CommonText)
        txtPassword.textField.setPlaceholder(txt: "Set your password".localized, color: UIColor.CommonText)
        txtConfirmPassword.textField.setPlaceholder(txt: "Repeat password".localized, color: UIColor.CommonText)


    }
    func isExist(id: Int) -> Bool {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let managedContext = appDelegate!.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "FileStore")
        fetchRequest.predicate = NSPredicate(format: "user_id = %d", id)
        
        let res = try! managedContext.fetch(fetchRequest)
        return res.count > 0 ? true : false
    }
    func setupRegisterData(cart_count:String,domain:String,email:String,first_name:String,memberno:String,userGroup:String,user_id:String,workStation:String,image:String,user_type:String, clubName: String){
        print("first_name",first_name)
        if let _ : AnyObject = UserDefaults.standard.object(forKey: "user_id") as AnyObject? {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
            }
            let id=user_id
            let allreadyExist = isExist(id:Int(user_id)!)
            if allreadyExist == false{
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
    func registerAPI(email:String,userName:String,password:String,fcm_key:String,macAddress:String) {
        startAnimating(CGSize(width: 100, height: 100), message: "", type: NVActivityIndicatorType.ballRotate, fadeInAnimation: nil)
        let parameters: Parameters = [
            "language" : "\(Language.language)",
            "username" : userName,
            "email" : email,
            "password" : password,
            "platform" : Shared().device_platform,
            "device_id" : UIDevice.current.identifierForVendor!.uuidString,
            "fcm_key" : fcm_key,
            "macAddress" : macAddress,
        ]
       
        
        Alamofire.request("\(Shared().webCall)memberRegister.php", method: .post, parameters: parameters)
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
                                self.setupRegisterData(cart_count: JSON(jsonData["cart_count"]!).stringValue, domain:JSON(jsonDict["domain"]!).stringValue,email:JSON(jsonDict["email"]!).stringValue,first_name:JSON(jsonDict["first_name"]!).stringValue,memberno:JSON(jsonDict["memberno"]!).stringValue,userGroup:JSON(jsonDict["userGroup"]!).stringValue,user_id:JSON(jsonDict["user_id"]!).stringValue,workStation:JSON(jsonDict["workStation"]!).stringValue,image:JSON(jsonDict["image"]!).stringValue,user_type:JSON(jsonDict["user_type"]!).stringValue, clubName: JSON(jsonDict["domain"]!).stringValue)
                            }
                            let message : String = JSON(jsonData["message"]!).stringValue
                            //Shared().showAlert(uIViewController: self, title: Shared().error, message: message)
                            self.navigationController?.popViewController(animated: true)
                            self.callBackRegister?("true")
                        
                        }
                        else if flag == "2"{
                            if let dataAry = jsonData["club_data"] as? [[String:Any]] {
                                
                                let jsonVal=JSON(dataAry)
                                
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
    }
    
    
   
    @IBAction func backViewClicked(_ sender: UIControl) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func backBtnAction(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func englishBtnAction(_ sender: UIButton) {
        self.btnEnglish.backgroundColor = UIColor(named: "backgroundViewColor")
        self.btnEnglish.setTitleColor(UIColor.white, for: .normal)
        
        self.btnSpanish.backgroundColor = UIColor.clear
        self.btnSpanish.setTitleColor(UIColor(named: "backgroundViewColor"), for: .normal)
        
        Language.language = Language.en
        setupLanguage()
    }
    
    
    @IBAction func spanishBtnAction(_ sender: UIButton) {
        self.btnSpanish.backgroundColor = UIColor(named: "backgroundViewColor")
        self.btnSpanish.setTitleColor(UIColor.white, for: .normal)
        
        self.btnEnglish.backgroundColor = UIColor.clear
        self.btnEnglish.setTitleColor(UIColor(named: "backgroundViewColor"), for: .normal)
        
        Language.language = Language.es
        setupLanguage()
    }
    @IBAction func registerBtnAction(_ sender: UIButton) {
      
        print("self.txtPassword.text!",self.txtPassword.text!)
        let userName = "\(txtUserName.text! as String)"
        let password = "\(txtPassword.text! as String)"
        let email = "\(txtEmail.text! as String)"
        let confirmPassword = "\(txtConfirmPassword.text! as String)"
//        let isUserPasswordValid = NSPredicate(format: "SELF MATCHES %@", "^(?=(.*[a-zA-Z])+)(?=(.*[0-9])+).{8,}$").evaluate(with: password)
        let isUserPasswordValid = appDelegateShared.regexPassword.evaluate(with: password)
        
        if(!validateEmail(email)) {
            txtEmail.errorMessage = "Please enter a valid email address".localized
            txtEmail.errorLabel.textColor = UIColor(hexString: "#EBEDEF")
        }else{
            txtEmail.errorMessage = ""
        }
        if (userName.count == 0) {
           txtUserName.errorMessage = "Please enter username.".localized
           txtUserName.errorLabel.textColor = UIColor(hexString: "#EBEDEF")
        }else{
            txtUserName.errorMessage = ""
        }
        if password.count == 0 {
            txtPassword.errorMessage = "Please enter password.".localized
            txtPassword.errorLabel.textColor = UIColor(hexString: "#EBEDEF")
        }  else if !isUserPasswordValid {
            txtPassword.errorMessage = "password_validation".localized
            txtPassword.errorLabel.textColor = UIColor(hexString: "#EBEDEF")
            txtPassword.txtView.borderWidths = 1
            txtPassword.txtView.borderColors = .red
        }else{
            txtPassword.errorMessage = ""
        }
        if (confirmPassword.count == 0) {
            txtConfirmPassword.errorMessage = "Please enter Confirm Password.".localized
            txtConfirmPassword.errorLabel.textColor = UIColor(hexString: "#EBEDEF")
            txtPassword.txtView.borderColors = .clear
            return
        }  else if (password != confirmPassword) {
            txtConfirmPassword.errorMessage = "Passwords do not match".localized
            txtConfirmPassword.errorLabel.textColor = UIColor(hexString: "#EBEDEF")
            txtPassword.txtView.borderColors = .clear
        }else{
            txtConfirmPassword.errorMessage = ""
        }
        if !txtEmail.errorMessage!.isEmpty || !txtUserName.errorMessage!.isEmpty || !txtPassword.errorMessage!.isEmpty || !txtConfirmPassword.errorMessage!.isEmpty{
            return
        }
        if (deviceTokenString == nil) {
            Shared().showAlert(uIViewController: self, title: Shared().error, message: Shared().errorMsg)
        } else {
            print("Enter Pin ::",userName)
            print("memberPIN Pin ::",password)
            self.dismissKeyboard()
            registerAPI(email: email, userName: userName, password: password, fcm_key: deviceTokenString, macAddress: Shared().getWifi())
          //  loginAPI(userName: userName, password: password, fcm_key: deviceTokenString, macAddress: Shared().getWifi())
        }
    }
    
}

