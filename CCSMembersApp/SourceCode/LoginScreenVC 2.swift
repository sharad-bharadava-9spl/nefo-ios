//
//  LoginScreenVC.swift
//  Cannabis
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

    @IBOutlet weak var constraintsSearchBarTop: NSLayoutConstraint!
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var clubFullView: UIView!
    @IBOutlet weak var clubView: UIView!
    @IBOutlet weak var btnLoginWidth: NSLayoutConstraint!
    @IBOutlet weak var btnLoginHeight: NSLayoutConstraint!
    @IBOutlet weak var stackViewWidthMemberCode: NSLayoutConstraint!
    @IBOutlet weak var stackViewMemberHeight: NSLayoutConstraint!
    @IBOutlet weak var stackViewEnterPasscodeHeight: NSLayoutConstraint!
    @IBOutlet weak var stackViewWidthEnterPasscode: NSLayoutConstraint!
    @IBOutlet weak var dropdownHeight: NSLayoutConstraint!
    @IBOutlet weak var languageStackViewHeight: NSLayoutConstraint!
    @IBOutlet weak var languageViewWidth: NSLayoutConstraint!
    @IBOutlet weak var languageViewHeight: NSLayoutConstraint!
    @IBOutlet weak var logoHeight: NSLayoutConstraint!
    @IBOutlet weak var btnEngish: UIButton!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var btnSpanish: UIButton!
    @IBOutlet weak var constraintsSelectClubBottom: NSLayoutConstraint!
    @IBOutlet weak var constraintEnterPasscodeHeight: NSLayoutConstraint!
    @IBOutlet weak var constraintMemberCode: NSLayoutConstraint!
    @IBOutlet weak var constraintEnterPasscodeCenterY: NSLayoutConstraint!
    @IBOutlet weak var lblMemberCode: UILabel!
    @IBOutlet weak var lblEnterPasscode: UILabel!
  //  @IBOutlet weak var lblSelectClub: UILabel!
    @IBOutlet weak var logotopConstraints: NSLayoutConstraint!
    @IBOutlet weak var btnSelectClubOutlet: UIButton!
    @IBOutlet weak var imgBackground: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var btnLoginOutlet: UIButton!
    @IBOutlet weak var txtSix: UITextField!
    @IBOutlet weak var txtFive: UITextField!
    @IBOutlet weak var txtFour: UITextField!
    @IBOutlet weak var txtThree: UITextField!
    @IBOutlet weak var txtTwo: UITextField!
    @IBOutlet weak var txtOne: UITextField!
    @IBOutlet weak var txtMtwo: UITextField!
    @IBOutlet weak var txtMThree: UITextField!
    
    @IBOutlet weak var txtMFour: UITextField!
    @IBOutlet weak var txtMOne: UITextField!
    
    var clubSelection:[String] = []
    var clubListing=[clubList]()
    var clubfilteredData=[clubList]()
    var backBtn:String=""
    override func viewDidLoad() {
        super.viewDidLoad()
        self.searchBar.delegate=self
        self.searchBar.showsCancelButton=true
        UIBarButtonItem.appearance(whenContainedInInstancesOf:[UISearchBar.self]).tintColor = UIColor(named: "statusBackgroundColour")
        UIBarButtonItem.appearance(whenContainedInInstancesOf:[UISearchBar.self]).title = "Cancel".localized
        self.navigationController?.navigationBar.isHidden=true
        txtOne.delegate=self
        txtTwo.delegate=self
        txtThree.delegate=self
        txtFour.delegate=self
        txtFive.delegate=self
        txtSix.delegate=self
        
        txtMOne.delegate=self
        txtMtwo.delegate=self
        txtMThree.delegate=self
        txtMFour.delegate=self
        
        tableView.dataSource=self
        tableView.delegate=self
        
        btnLoginOutlet.shadowColor(color: UIColor.black.withAlphaComponent(0.2), border: 1.0, offHeight: 3.0)
        
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
        
        self.txtMThree.inputAccessoryView = toolbarDone
        self.clubView.isHidden=true
        self.clubFullView.isHidden=true
        
        self.tableViewHeight.constant=0
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func txtMtwoAction(_ sender: UITextField) {
        if self.txtMtwo.text == ""{
            self.txtMtwo.keyboardType = .asciiCapable
            self.txtMtwo.reloadInputViews()
        } else{
            self.txtMtwo.keyboardType = .numberPad
            self.txtMtwo.reloadInputViews()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.removeNavigationBarItem()
        self.clubSelection=["demo"]
        self.imgBackground.image = UIImage(named : Shared().getImgName())
        self.btnSelectClubOutlet.layer.borderWidth=1.0
        self.btnSelectClubOutlet.layer.borderColor=UIColor.black.cgColor
        setupLanguage()
        
        if let _ : AnyObject = UserDefaults.standard.object(forKey: "user_id") as AnyObject? {
            self.btnBack.isHidden=false
        } else{
            self.btnBack.isHidden=true
        }
        
        if #available(iOS 13.0, *) {
            let statusBar = UIView(frame: (UIApplication.shared.keyWindow?.windowScene?.statusBarManager?.statusBarFrame)!)
            statusBar.backgroundColor = UIColor(named: "statusBackgroundColour")!
            UIApplication.shared.keyWindow?.addSubview(statusBar)
        }
        
        self.fetchClubList()
    }

    @IBAction func btnBack(_ sender: UIButton) {
        if let _ : AnyObject = UserDefaults.standard.object(forKey: "user_id") as AnyObject? {
            self.goHomeScreen()
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
    
    @IBAction func btnActionEngish(_ sender: UIButton) {
        self.btnEngish.backgroundColor = UIColor(named: "backgroundViewColor")
        self.btnEngish.setTitleColor(UIColor.white, for: .normal)
        
        self.btnSpanish.backgroundColor = UIColor.clear
        self.btnSpanish.setTitleColor(UIColor(named: "backgroundViewColor"), for: .normal)
        
        Language.language = Language.en
        setupLanguage()
    }
    
    @IBAction func btnEspanolAction(_ sender: UIButton) {
        self.btnSpanish.backgroundColor = UIColor(named: "backgroundViewColor")
        self.btnSpanish.setTitleColor(UIColor.white, for: .normal)
        
        self.btnEngish.backgroundColor = UIColor.clear
        self.btnEngish.setTitleColor(UIColor(named: "backgroundViewColor"), for: .normal)
        
        Language.language = Language.es
        setupLanguage()
    }
    
    func setupLanguage(){
        self.btnEngish.setTitle("English".localized, for: .normal)
        self.btnSpanish.setTitle("Spanish".localized, for: .normal)
        self.btnSelectClubOutlet.setTitle("Select Your Club".localized, for: .normal)
        self.lblEnterPasscode.text="Enter Passcode".localized
        self.lblMemberCode.text="Enter Member No.".localized
        self.btnLoginOutlet.setTitle("LOGIN".localized, for: .normal)
        
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
        self.view.resignFirstResponder()
    }
    
    override func viewDidLayoutSubviews() {
        self.languageViewHeight.constant=75
        self.logoHeight.constant=85
        self.dropdownHeight.constant=30
        self.languageStackViewHeight.constant=30
        self.stackViewMemberHeight.constant=32
        self.stackViewEnterPasscodeHeight.constant=32
        self.stackViewWidthMemberCode.constant=190
        self.stackViewWidthEnterPasscode.constant=280
        self.btnLoginHeight.constant=50
        self.btnLoginWidth.constant=280
        self.languageViewWidth.constant=220
        if Shared().getScreenHeight() == 667{
           
            self.logotopConstraints.constant=30
            self.constraintEnterPasscodeCenterY.constant=50
            
            self.constraintMemberCode.constant=100
            self.constraintEnterPasscodeHeight.constant=100
            self.constraintsSelectClubBottom.constant=37
            self.languageViewHeight.constant=110
            self.logoHeight.constant=100
            self.dropdownHeight.constant=40
            self.languageStackViewHeight.constant=40
            self.stackViewMemberHeight.constant=40
            self.stackViewEnterPasscodeHeight.constant=40
            self.stackViewWidthMemberCode.constant=225
            self.stackViewWidthEnterPasscode.constant=330
            self.btnLoginHeight.constant=60
            self.btnLoginWidth.constant=300
            self.languageViewWidth.constant=250
        } else if Shared().getScreenHeight() > 667{
            print("Shared().getScreenWidth()",Shared().getScreenWidth())
            print("Shared().getScreenHeight()",Shared().getScreenHeight())
            if Shared().getScreenWidth() > 375{
                if Shared().getScreenHeight() == 736{
                    self.logotopConstraints.constant=40
                } else{
                    self.logotopConstraints.constant=70
                }
            } else{
                self.logotopConstraints.constant=40
            }
            
            self.constraintEnterPasscodeCenterY.constant=50
            
            self.constraintMemberCode.constant=100
            self.constraintEnterPasscodeHeight.constant=100
            self.constraintsSelectClubBottom.constant=37
            self.languageViewHeight.constant=110
            self.logoHeight.constant=120
            self.dropdownHeight.constant=40
            self.languageStackViewHeight.constant=40
            self.stackViewMemberHeight.constant=40
            self.stackViewEnterPasscodeHeight.constant=40
            self.stackViewWidthMemberCode.constant=225
            self.stackViewWidthEnterPasscode.constant=330
            self.btnLoginHeight.constant=60
            self.btnLoginWidth.constant=300
            self.languageViewWidth.constant=250
        } else{
            self.logotopConstraints.constant=20
            self.constraintEnterPasscodeCenterY.constant=30
            self.constraintMemberCode.constant=90
            self.constraintEnterPasscodeHeight.constant=90
            self.constraintsSelectClubBottom.constant=37
        }
        
        if "\(Language.language)" == "en"{
            self.btnEngish.backgroundColor = UIColor(named: "backgroundViewColor")
            self.btnEngish.setTitleColor(UIColor.white, for: .normal)
            
            self.btnSpanish.backgroundColor = UIColor.clear
            self.btnSpanish.setTitleColor(UIColor(named: "backgroundViewColor"), for: .normal)
        } else{
            self.btnSpanish.backgroundColor = UIColor(named: "backgroundViewColor")
            self.btnSpanish.setTitleColor(UIColor.white, for: .normal)
            
            self.btnEngish.backgroundColor = UIColor.clear
            self.btnEngish.setTitleColor(UIColor(named: "backgroundViewColor"), for: .normal)
        }
    }
    
    @IBAction func btnSelectClub(_ sender: UIButton) {
        self.clubView.isHidden=false
        self.clubFullView.isHidden=false
        self.tableView.reloadData()
        self.tableViewHeight.constant=self.tableView.contentSize.height
        if self.view.frame.size.height >= 812{
            self.constraintsSearchBarTop.constant=44
        } else{
            
        }
//        let paragraph = NSMutableParagraphStyle()
//        paragraph.alignment = .center
//
//        let clubOptionPicker = ActionSheetStringPicker(title: "Select Your Club".localized, rows: self.clubSelection, initialSelection: 0, doneBlock: { (pickerSheet, selectedIndex, selectedValue) in
//            print("Selected language option index",selectedIndex)
//            self.btnSelectClubOutlet.setTitle(selectedValue as! String, for: .normal)
//
//        }, cancel: {pickerSheet in return }, origin: (sender as AnyObject).superview!)
//
//        clubOptionPicker?.pickerTextAttributes = [NSAttributedString.Key.font: UIFont(name: "ProductSans-Medium", size: 15)!, NSAttributedString.Key.paragraphStyle: paragraph]
//        clubOptionPicker?.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "ProductSans-Medium", size: 17)!]
//
//        let btnDone = UIBarButtonItem(title: "Done".localized, style: .plain, target: self, action: nil)
//        btnDone.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "ProductSans-Medium", size: 16)!], for: .normal)
//        clubOptionPicker?.setDoneButton(btnDone)
//
//        let btnCancel = UIBarButtonItem(title: "Cancel".localized, style: .plain, target: self, action: nil)
//        btnCancel.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "ProductSans-Medium", size: 16)!], for: .normal)
//        clubOptionPicker?.setCancelButton(btnCancel)
//        clubOptionPicker?.show();
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        self.scrollView.isScrollEnabled = true
        let userInfo: NSDictionary = notification.userInfo! as NSDictionary
        let keyboardInfo = userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue
        let keyboardSize = keyboardInfo.cgRectValue.size
        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height+20, right: 0)
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
    }
    @objc func keyboardWillHide(notification: NSNotification) {
        scrollView.contentInset = .zero
        scrollView.scrollIndicatorInsets = .zero
    }
    
    @IBAction func btnLogin(_ sender: UIButton) {
        //loginAPI()
        let token = InstanceID.instanceID().token()
        print(token)
        print("self.txtMThree.text!",self.txtMThree.text!)
        print("self.txtMtwo.text!",self.txtMtwo.text!)
        print("self.txtMOne.text!",self.txtMOne.text!)
        let enterPIN = "\(txtOne.text! as String)\(txtTwo.text! as String)\(txtThree.text! as String)\(txtFour.text! as String)\(txtFive.text! as String)\(txtSix.text! as String)"
        let memberPIN = "\(txtMOne.text! as String)\(txtMtwo.text! as String)\(txtMThree.text! as String)\(txtMFour.text! as String)"
        if "Select Your Club".localized == self.btnSelectClubOutlet.titleLabel!.text{
            Shared().showAlert(uIViewController: self, title: Shared().error, message: "Please select your club.".localized)
        } else if (enterPIN.count < 4) {
            Shared().showAlert(uIViewController: self, title: Shared().error, message: "Please enter your passcode.".localized)
        } else if self.txtMOne.text! == "" || self.txtMtwo.text! == "" || self.txtMThree.text! == "" {
            Shared().showAlert(uIViewController: self, title: Shared().error, message: "Please enter your member no.".localized)
        } else if (token == nil) {
            Shared().showAlert(uIViewController: self, title: Shared().error, message: Shared().errorMsg)
        } else {
            print("Enter Pin ::",enterPIN)
            print("memberPIN Pin ::",memberPIN)
            self.dismissKeyboard()
            
            loginAPI(enterPIN:enterPIN,memberPIN:memberPIN,fcm_key:token!,macAddress:Shared().getWifi())
        }
    }
    
    func setupLoginData(cart_count:String,domain:String,email:String,first_name:String,memberno:String,userGroup:String,user_id:String,workStation:String,image:String,user_type:String){
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
                UserDefaults.standard.set(self.btnSelectClubOutlet.titleLabel!.text!, forKey: "club_name")
                UserDefaults.standard.set(self.btnSelectClubOutlet.titleLabel!.text!, forKey: "first_name")//For club_name
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
            UserDefaults.standard.set(self.btnSelectClubOutlet.titleLabel!.text!, forKey: "club_name")
            UserDefaults.standard.set(self.btnSelectClubOutlet.titleLabel!.text!, forKey: "first_name")
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

extension LoginScreenVC:UITableViewDataSource,UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.clubListing.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell=tableView.dequeueReusableCell(withIdentifier: "clubCell") as! clubCell
        let clubData=self.clubListing[indexPath.row]
        cell.lblClubName.text=clubData.club_name
        cell.selectionStyle = .default
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let clubData=self.clubListing[indexPath.row]
        self.btnSelectClubOutlet.setTitle(clubData.club_name, for: .normal)
        self.clubFullView.isHidden=true
        self.clubView.isHidden=true
        self.view.endEditing(true)
    }
}

extension LoginScreenVC:UITextFieldDelegate{
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        self.txtMtwo.keyboardType = .numberPad
        self.txtMtwo.reloadInputViews()
        if textField == txtOne{
            if (txtOne.text?.count)! > 0 && string.count > 0 {
                txtTwo.text = ""
                txtTwo.becomeFirstResponder()
                txtTwo.text = string
                return false
            } else if ((textField.text?.count)! >= 1  && string.count == 0){
                textField.text = "";
                doneButtonAction()
                return false;
            }
        } else if textField == txtTwo{
            if (txtTwo.text?.count)! > 0 && string.count > 0 {
                txtThree.text = ""
                txtThree.becomeFirstResponder()
                txtThree.text = string
                return false
            } else if ((textField.text?.count)! >= 1  && string.count == 0) {
                textField.text = "";
                txtOne.becomeFirstResponder();
                return false;
            }
        } else if textField == txtThree{
            if (txtThree.text?.count)! > 0 && string.count > 0 {
                txtFour.text = ""
                txtFour.becomeFirstResponder()
                txtFour.text = string
                return false
            } else if ((textField.text?.count)! >= 1  && string.count == 0){
                textField.text = "";
                txtTwo.becomeFirstResponder();
                return false;
            }
        } else if textField == txtFour{
            if (txtFour.text?.count)! > 0 && string.count > 0 {
                txtFive.text = ""
                txtFive.becomeFirstResponder()
                txtFive.text = string
                return false
            } else if ((textField.text?.count)! >= 1  && string.count == 0){
                textField.text = "";
                txtThree.becomeFirstResponder();
                return false;
            }
        } else if textField == txtFive{
            if (txtFive.text?.count)! > 0 && string.count > 0 {
                txtSix.text = ""
                txtSix.becomeFirstResponder()
                txtSix.text = string
                self.view.endEditing(true)
                return false
            } else if ((textField.text?.count)! >= 1  && string.count == 0) {
                textField.text = "";
                txtFour.becomeFirstResponder();
                return false;
            }
        } else if textField == txtSix{
            if (txtSix.text?.count)! > 0 && string.count > 0 {
                doneButtonAction()
                return false
            } else if ((textField.text?.count)! >= 1  && string.count == 0){
                textField.text = "";
                txtFive.becomeFirstResponder();
                return false;
            }
        } else if textField == txtMOne{
            if (txtMOne.text?.count)! > 0 && string.count > 0 {
                txtMtwo.text = ""
                txtMtwo.becomeFirstResponder()
                txtMtwo.text = string
                return false
            } else if ((textField.text?.count)! >= 1  && string.count == 0){
                textField.text = "";
                doneButtonAction()
                return false;
            }
        } else if textField == txtMtwo{
            if (txtMtwo.text?.count)! > 0 && string.count > 0 {
                txtMThree.text = ""
                txtMThree.becomeFirstResponder()
                txtMThree.text = string
                return false
            } else if ((textField.text?.count)! >= 1  && string.count == 0) {
                textField.text = "";
                txtMOne.becomeFirstResponder();
                return false;
            }
        } else if textField == txtMThree{
            if (txtMThree.text?.count)! > 0 && string.count > 0 {
                txtMFour.text = ""
                txtMFour.becomeFirstResponder()
                txtMFour.text = string
                self.view.endEditing(true)
                return false
            } else if ((textField.text?.count)! >= 1  && string.count == 0){
                textField.text = "";
                txtMtwo.becomeFirstResponder();
                return false;
            }
        } else if textField == txtMFour{
            if (txtMFour.text?.count)! > 0 && string.count > 0 {
                doneButtonAction()
                return false
            } else if ((textField.text?.count)! >= 1  && string.count == 0){
                textField.text = "";
                txtMThree.becomeFirstResponder();
                return false;
            }
        }
        return true;
    }
    
    func doneButtonAction() {
        if (txtOne.text?.count)! == 0 {
            txtOne.text = ""
            txtOne.becomeFirstResponder()
        } else if (txtTwo.text?.count)! == 0 {
            txtTwo.text = ""
            txtTwo.becomeFirstResponder()
        } else if (txtThree.text?.count)! == 0 {
            txtThree.text = ""
            txtThree.becomeFirstResponder()
        } else if (txtFour.text?.count)! == 0 {
            txtFour.text = ""
            txtFour.becomeFirstResponder()
        } else if (txtFive.text?.count)! == 0 {
            txtFive.text = ""
            txtFive.becomeFirstResponder()
        } else if (txtSix.text?.count)! == 0 {
            txtSix.text = ""
            txtSix.becomeFirstResponder()
        } else if (txtMOne.text?.count)! == 0 {
            txtMOne.text = ""
            txtMOne.becomeFirstResponder()
        } else if (txtMtwo.text?.count)! == 0 {
            txtMtwo.text = ""
            txtMtwo.becomeFirstResponder()
        } else if (txtMThree.text?.count)! == 0 {
            txtMThree.text = ""
            txtMThree.becomeFirstResponder()
        } else if (txtMFour.text?.count)! == 0 {
            txtMFour.text = ""
            txtMFour.becomeFirstResponder()
        } else {
            self.view.endEditing(true)
        }
    }
    
}
//http://192.168.1.124/cannabisclub/api/login
//login_code : XPE6BJ,club_name = demo ,member_no = AH3 ,device_id ,platform
extension LoginScreenVC{
    func loginAPI(enterPIN:String,memberPIN:String,fcm_key:String,macAddress:String){
        startAnimating(CGSize(width: 100, height: 100), message: "", type: NVActivityIndicatorType.ballRotate, fadeInAnimation: nil)
        let parameters: Parameters = [
            "language" : "\(Language.language)",
            "club_name" : self.btnSelectClubOutlet.titleLabel!.text!,
            "login_code" : enterPIN,
            "member_no" : memberPIN,
            "platform" : Shared().device_platform,
            "device_id" : UIDevice.current.identifierForVendor!.uuidString,
            "fcm_key" : fcm_key,
            "macAddress" : macAddress,
        ]
        print("\(Shared().webCall)login?language=\(Language.language)&club_name=\(self.btnSelectClubOutlet.titleLabel!.text!)&login_code=\(enterPIN)&platform=\(Shared().device_platform)&device_id=\(UIDevice.current.identifierForVendor!.uuidString)&member_no=\(memberPIN)&fcm_key=\(fcm_key)&macAddress=\(macAddress)")
        Alamofire.request("\(Shared().webCall)login", method: .post, parameters: parameters)
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
                                self.setupLoginData(cart_count: JSON(jsonData["cart_count"]!).stringValue, domain:JSON(jsonDict["domain"]!).stringValue,email:JSON(jsonDict["email"]!).stringValue,first_name:JSON(jsonDict["first_name"]!).stringValue,memberno:JSON(jsonDict["memberno"]!).stringValue,userGroup:JSON(jsonDict["userGroup"]!).stringValue,user_id:JSON(jsonDict["user_id"]!).stringValue,workStation:JSON(jsonDict["workStation"]!).stringValue,image:JSON(jsonDict["image"]!).stringValue,user_type:JSON(jsonDict["user_type"]!).stringValue)
                            }
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
    //http://devsj72web.websiteserverhost.com/cannabisclub/api/clubList
    func fetchClubList(){
        startAnimating(CGSize(width: 100, height: 100), message: "", type: NVActivityIndicatorType.ballRotate, fadeInAnimation: nil)
        let parameters: Parameters = [
            "language" : "\(Language.language)",
        ]
        print("\(Shared().webCall)clubList?language=\(Language.language)")
        Alamofire.request("\(Shared().webCall)clubList", method: .post, parameters: parameters)
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
                            if let jsonClub=jsonData["data"] as? [[String:Any]]{
                                let jsonVal=JSON(jsonClub)
                                self.clubfilteredData.removeAll()
                                self.clubListing.removeAll()
                                for item in 0..<jsonVal.count{
                                    let arrObj=clubList(json:jsonVal[item])
                                    self.clubListing.append(arrObj)
                                self.clubfilteredData.append(arrObj)
                                }
                            }
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

extension LoginScreenVC:UISearchBarDelegate{
    
func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
     if(searchBar.text != "") {
     //self.searchBar.isHidden=true
     self.searchBar.resignFirstResponder()
     self.searchBar.text=""
     self.view.endEditing(true)
     self.searchBar.text=nil
     } else{
     //self.searchBar.isHidden=true
     self.searchBar.resignFirstResponder()
     self.searchBar.text=""
     self.view.endEditing(true)
     self.searchBar.text=nil
     self.clubListing.removeAll()
    for item in 0..<self.clubfilteredData.count{
      self.clubListing.append(self.clubfilteredData[item])
     }
     self.tableView.reloadData()
     self.tableViewHeight.constant=self.tableView.contentSize.height
     }
}
    
func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
     //self.searchBar.isHidden=true
     self.searchBar.resignFirstResponder()
     self.searchBar.text=""
     self.view.endEditing(true)
     self.searchBar.text=nil
     self.clubListing.removeAll()
     for item in 0..<self.clubfilteredData.count{
       self.clubListing.append(self.clubfilteredData[item])
      }
      self.tableView.reloadData()
      self.tableViewHeight.constant=self.tableView.contentSize.height
    self.clubFullView.isHidden=true
    self.clubView.isHidden=true
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
     self.tableView.reloadData()
     self.tableViewHeight.constant=self.tableView.contentSize.height
     }
 }
}
