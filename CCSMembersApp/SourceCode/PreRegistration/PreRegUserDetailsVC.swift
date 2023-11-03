//
//  PreRegUserDetailsVC.swift
//  CCSMembersApp
//
//  Created by Divyesh Dabhi on 08/05/23.
//  Copyright © 2023 Jaimin Patel. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import SlideMenuControllerSwift

class PreRegUserDetailsVC: UIViewController {

    
    //Personal Details
    @IBOutlet weak var btnMale: UIButton!
    @IBOutlet weak var btnFemale: UIButton!
    @IBOutlet weak var btnOther: UIButton!
    @IBOutlet weak var btnRecreational: UIButton!
    @IBOutlet weak var btnMedicinal: UIButton!
    
    @IBOutlet weak var lblPersonalDetail: UILabel!
    @IBOutlet weak var lblGender: UILabel!
    @IBOutlet weak var lblMale: UILabel!
    @IBOutlet weak var lblFemale: UILabel!
    @IBOutlet weak var lblOther: UILabel!
    @IBOutlet weak var lblUsage: UILabel!
    @IBOutlet weak var lblRecreational: UILabel!
    @IBOutlet weak var lblMedicinal: UILabel!
    
    @IBOutlet weak var txtFirstName: CustomNewTextField!
    @IBOutlet weak var txtLastName: CustomNewTextField!
    @IBOutlet weak var txtNationality: CustomNewTextField!
    @IBOutlet weak var txtDNIPassport: CustomNewTextField!
    
    //Contact Details
    @IBOutlet weak var lblContactDetail: UILabel!
    @IBOutlet weak var txtEmail: CustomNewTextField!
    @IBOutlet weak var txtTelephone: CustomNewTextField!
    @IBOutlet weak var txtStreetName: CustomNewTextField!
    @IBOutlet weak var txtPostCode: CustomNewTextField!
    @IBOutlet weak var txtCity: CustomNewTextField!
    @IBOutlet weak var txtCountry: CustomNewTextField!
    
    @IBOutlet weak var btnConfirm: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!

    var item1:UIBarButtonItem?
    var activeTextField : UITextField? = nil

    var selectedTextFieldYPosition : CGFloat = 0.0
    var keyboardHeight : CGFloat = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.setupUI()
        //self.btnMale.isSelected = true
        //self.btnRecreational.isSelected = true
        self.registerForKeyboardNotifications()
        self.txtEmail.textField.text = appDelegateShared.Email
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //self.setupLanguageData()
        self.setupUI()
    }
    
    func setupUI(){
        
        //NotificationCenter.default.addObserver(self, selector: Selector(("keyboardWillShow:")), name: UIResponder.keyboardWillShowNotification, object: nil)
        //NotificationCenter.default.addObserver(self, selector: Selector(("keyboardWillHide:")), name: UIResponder.keyboardWillShowNotification, object: nil)
        self.setupLanguage()
        self.setupNavigationItem()
        
        /*
        self.txtFirstName.textField.autocapitalizationType = .sentences
        self.txtLastName.textField.autocapitalizationType = .sentences
        self.txtNationality.textField.autocapitalizationType = .sentences
        //self.txtDNIPassport.textField.autocapitalizationType = .sentences
        self.txtStreetName.textField.autocapitalizationType = .sentences
        self.txtCity.textField.autocapitalizationType = .sentences
        self.txtCountry.textField.autocapitalizationType = .sentences
        */
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboardThrougOutSideClick))
        tap.cancelsTouchesInView=false
        self.view.addGestureRecognizer(tap)
        
        
        self.txtFirstName.textField.delegate = self
        self.txtLastName.textField.delegate = self
        self.txtEmail.textField.delegate = self
        self.txtNationality.textField.delegate = self
        self.txtDNIPassport.textField.delegate = self
        self.txtStreetName.textField.delegate = self
        self.txtCity.textField.delegate = self
        self.txtCountry.textField.delegate = self
        
        
        self.txtFirstName.textField.autocapitalizationType = .sentences
        self.txtLastName.textField.autocapitalizationType = .sentences
        self.txtNationality.textField.autocapitalizationType = .sentences
        self.txtDNIPassport.textField.autocapitalizationType = .sentences
        self.txtEmail.textField.autocapitalizationType = .sentences
        self.txtTelephone.textField.autocapitalizationType = .sentences
        self.txtStreetName.textField.autocapitalizationType = .sentences
        self.txtPostCode.textField.autocapitalizationType = .sentences
        self.txtCity.textField.autocapitalizationType = .sentences
        self.txtCountry.textField.autocapitalizationType = .sentences
        
    }
    
    func setupNavigationItem(){
        self.title = "Pre_Registration".localized.uppercased()
        self.removeNavigationBarItem()
        self.navigationController?.navigationBar.tintColor = .white
       // self.setNavigationBarItem()
        self.setLeftAlignTitleView(font: UIFont(name: "ProductSans-Bold", size: 17)!, text: "Pre_Registration".localized, textColor: .white)
        
        
    }
    
    //Set Language wise Data
    func setupLanguage(){
        
        self.txtFirstName.leftImage = UIImage(named: "ic_user")
        self.txtLastName.leftImage = UIImage(named: "ic_user")
        self.txtNationality.leftImage = UIImage(named: "ic_user")
        self.txtDNIPassport.leftImage = UIImage(named: "ic_user")
        self.txtEmail.leftImage = UIImage(named: "ic_email")
        self.txtTelephone.leftImage = UIImage(named: "ic_user")
        self.txtStreetName.leftImage = UIImage(named: "ic_user")
        self.txtPostCode.leftImage = UIImage(named: "ic_user")
        self.txtCity.leftImage = UIImage(named: "ic_user")
        self.txtCountry.leftImage = UIImage(named: "ic_user")
        
        
        
        self.txtTelephone.textField.keyboardType = .phonePad
        self.txtPostCode.textField.keyboardType = .numberPad
        self.txtEmail.textField.keyboardType = .emailAddress
        
        // ===================== Personal Details =====================
        self.lblPersonalDetail.text = "Personal details".localized
        self.lblMale.text = "Male".localized
        self.lblOther.text = "Other".localized
        self.lblFemale.text = "Female".localized
        self.lblGender.text = "Gender".localized
        self.lblUsage.text = "Usage".localized
        self.lblRecreational.text = "Recreational".localized
        self.lblMedicinal.text = "Medicinal".localized
        
        self.txtFirstName.lblTitle.textColor = .white
        self.txtLastName.lblTitle.textColor = .white
        self.txtNationality.lblTitle.textColor = .white
        self.txtDNIPassport.lblTitle.textColor = .white
        
        self.txtFirstName.placeholderMessage = "FirstNameTitle".localized
        self.txtLastName.placeholderMessage = "LastNameTitle".localized
        self.txtNationality.placeholderMessage = "NationalityPlaceHolder".localized
        self.txtDNIPassport.placeholderMessage = "DNIPassPortPlaceHolder".localized
        
        
        self.txtFirstName.textField.setPlaceholder(txt: "FirstNamePlaceHolder".localized, color: UIColor.CommonText)
        self.txtLastName.textField.setPlaceholder(txt: "LastNamePlaceHolder".localized, color: UIColor.CommonText)
        self.txtNationality.textField.setPlaceholder(txt: "NationalityPlaceHolder".localized, color: UIColor.CommonText)
        self.txtDNIPassport.textField.setPlaceholder(txt: "DNIPassPortPlaceHolder".localized, color: UIColor.CommonText)
        
        
        
       // ===================== Contact Details =====================
        self.lblContactDetail.text = "Contact details".localized
        self.txtEmail.lblTitle.textColor = .white
        self.txtTelephone.lblTitle.textColor = .white
        self.txtStreetName.lblTitle.textColor = .white
        self.txtPostCode.lblTitle.textColor = .white
        self.txtCity.lblTitle.textColor = .white
        self.txtCountry.lblTitle.textColor = .white
        
        self.txtEmail.placeholderMessage = "Email".localized
        self.txtTelephone.placeholderMessage = "TelephonePlaceHolder".localized
        self.txtStreetName.placeholderMessage = "StreetNamePlaceHolder".localized
        self.txtPostCode.placeholderMessage = "PostCodePlaceHolder".localized
        self.txtCity.placeholderMessage = "CityPlaceHolder".localized
        self.txtCountry.placeholderMessage = "CountryPlaceHolder".localized

        self.txtEmail.textField.setPlaceholder(txt: "dummy_Email".localized, color: UIColor.CommonText)
        self.txtTelephone.textField.setPlaceholder(txt: "TelephonePlaceHolder".localized, color: UIColor.CommonText)
        self.txtStreetName.textField.setPlaceholder(txt: "StreetNamePlaceHolder".localized, color: UIColor.CommonText)
        self.txtPostCode.textField.setPlaceholder(txt: "PostCodePlaceHolder".localized, color: UIColor.CommonText)
        self.txtCity.textField.setPlaceholder(txt: "CityPlaceHolder".localized, color: UIColor.CommonText)
        self.txtCountry.textField.setPlaceholder(txt: "CountryPlaceHolder".localized, color: UIColor.CommonText)
        
        
        self.btnConfirm.setTitle("SUBMIT".localized, for: .normal)
    }
    
    func registerForKeyboardNotifications() {
      NotificationCenter.default.addObserver(self, selector:#selector(keyboardWillShown(_:)),name: UIResponder.keyboardWillShowNotification, object: nil)
    NotificationCenter.default.addObserver(self, selector:
    #selector(keyboardWillBeHidden(_:)),name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    
    @objc func keyboardWillShown(_ notification: NSNotification) {
        
        /*
        guard let keyboardSize = (notificiation.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
               // if keyboard size is not available for some reason, dont do anything
               return
            }
          
        self.keyboardHeight = keyboardSize.height
          // move the root view up by the distance of keyboard height
          self.view.frame.origin.y = 0 - keyboardSize.height

      // write source code handle when keyboard will show
         */
        
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            else {
              // if keyboard size is not available for some reason, dont do anything
              return
            }

            let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardSize.height , right: 0.0)
            scrollView.contentInset = contentInsets
            scrollView.scrollIndicatorInsets = contentInsets
    }
    @objc func keyboardWillBeHidden(_ notification: NSNotification) {
       // write source code handle when keyboard will be hidden
        let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
                
            
            // reset back the content inset to zero after keyboard is gone
            scrollView.contentInset = contentInsets
            scrollView.scrollIndicatorInsets = contentInsets

    }
    
    @objc func dismissKeyboardThrougOutSideClick() {
        view.endEditing(true)
        self.view.resignFirstResponder()
    }

}
//MARK:  Extension for button clicked
extension PreRegUserDetailsVC{
    @IBAction func btnClicked(_ sender: UIButton) {
        self.view.endEditing(true)
        switch sender.tag{
        case 0: //Submit clicked
            if isValidate(){
                print("ALL value fill")
                self.callAPIRegistrationDetails()
            }
        case 1: //Male Clicked
            print("Male Clicked")
            if self.btnMale.isSelected == false{
                self.btnMale.isSelected = !self.btnMale.isSelected
                self.btnFemale.isSelected = !self.btnMale.isSelected
                self.btnOther.isSelected = !self.btnMale.isSelected
            }
            
            
        case 2: //Female Clicked
            print("Female Clicked")
            if self.btnFemale.isSelected == false{
                self.btnFemale.isSelected = !self.btnFemale.isSelected
                self.btnMale.isSelected = !self.btnFemale.isSelected
                self.btnOther.isSelected = !self.btnFemale.isSelected
            }
            
        case 3: //Recreational Clicked
            print("Recreational Clicked")
            if self.btnRecreational.isSelected == false{
                self.btnRecreational.isSelected = !self.btnRecreational.isSelected
                self.btnMedicinal.isSelected = !self.btnRecreational.isSelected
            }
            
        case 4: //Medicinal Clicked
            print("Medicinal Clicked")
            if self.btnMedicinal.isSelected == false{
                self.btnMedicinal.isSelected = !self.btnMedicinal.isSelected
                self.btnRecreational.isSelected = !self.btnMedicinal.isSelected
            }
            
        case 5: //Other Clicked
            print("Other Clicked")
            if self.btnOther.isSelected == false{
                self.btnOther.isSelected = !self.btnOther.isSelected
                self.btnMale.isSelected = !self.btnOther.isSelected
                self.btnFemale.isSelected = !self.btnOther.isSelected
            }
            
        default:
            break;
        }
    }
    
    func isValidate () -> Bool {
        var isCompleted = true
        
            
        if self.txtFirstName.text ?? "" == ""{
            self.txtFirstName.errorMessage = "msg_enter_firstName".localized
            self.txtFirstName.errorLabel.textColor = UIColor(hexString: "#EBEDEF")
        }else{
            self.txtFirstName.errorMessage = ""
        }
        if self.txtLastName.text ?? "" == ""{
            self.txtLastName.errorMessage = "msg_enter_lastName".localized
            self.txtLastName.errorLabel.textColor = UIColor(hexString: "#EBEDEF")
        }else{
            self.txtLastName.errorMessage = ""
        }
        /*
        if self.txtNationality.text ?? "" == ""{
            self.txtNationality.errorMessage = "msg_enter_nationality".localized
            self.txtNationality.errorLabel.textColor = UIColor(hexString: "#EBEDEF")
        }else{
            self.txtNationality.errorMessage = ""
        }*/
        if self.txtDNIPassport.text ?? "" == ""{
            self.txtDNIPassport.errorMessage = "msg_enter_DNIPassport".localized
            self.txtDNIPassport.errorLabel.textColor = UIColor(hexString: "#EBEDEF")
        }else{
            self.txtDNIPassport.errorMessage = ""
        }
        
        
        if self.txtEmail.text ?? "" == ""{
            self.txtEmail.errorMessage = "msg_enter_Email".localized
            self.txtEmail.errorLabel.textColor = UIColor(hexString: "#EBEDEF")
        }else{
            if isValidEmail(strEmail: self.txtEmail.text ?? "") == false{
            //if (self.txtEmail.text ?? "").isValidEmail() == false{
                self.txtEmail.errorMessage = "Please enter a valid email address".localized
                self.txtEmail.errorLabel.textColor = UIColor(hexString: "#EBEDEF")
            }else{
                self.txtEmail.errorMessage = ""
            }
        }
        
        if self.txtTelephone.text ?? "" == ""{
            self.txtTelephone.errorMessage = "msg_enter_telephone".localized
            self.txtTelephone.errorLabel.textColor = UIColor(hexString: "#EBEDEF")
        }else{
            if isValidMobileNumber(strMobileNumber: self.txtTelephone.text ?? "") == false{
                self.txtTelephone.errorMessage = "msg_enter_valid_telephone".localized
                self.txtTelephone.errorLabel.textColor = UIColor(hexString: "#EBEDEF")
            }else{
                self.txtTelephone.errorMessage = ""
            }
            
        }
        
        
        /*
        if self.txtStreetName.text ?? "" == ""{
            self.txtStreetName.errorMessage = "msg_enter_streetName".localized
            self.txtStreetName.errorLabel.textColor = UIColor(hexString: "#EBEDEF")
        }else{
            self.txtStreetName.errorMessage = ""
        }
        if self.txtPostCode.text ?? "" == ""{
            self.txtPostCode.errorMessage = "msg_enter_postCode".localized
            self.txtPostCode.errorLabel.textColor = UIColor(hexString: "#EBEDEF")
        }else{
            self.txtPostCode.errorMessage = ""
        }
        if self.txtCity.text ?? "" == ""{
            self.txtCity.errorMessage = "msg_enter_city".localized
            self.txtCity.errorLabel.textColor = UIColor(hexString: "#EBEDEF")
        }else{
            self.txtCity.errorMessage = ""
        }
        if self.txtCountry.text ?? "" == ""{
            self.txtCountry.errorMessage = "msg_enter_country".localized
            self.txtCountry.errorLabel.textColor = UIColor(hexString: "#EBEDEF")
        }else{
            self.txtCountry.errorMessage = ""
        }*/
        
        /*if self.txtFirstName.text ?? "" == "" || self.txtLastName.text ?? "" == "" || self.txtNationality.text ?? "" == "" || self.txtDNIPassport.text ?? "" == "" || self.txtTelephone.text ?? "" == "" || self.txtEmail.text ?? "" == "" || self.txtStreetName.text ?? "" == "" || self.txtPostCode.text ?? "" == "" || self.txtCity.text ?? "" == "" || self.txtCountry.text ?? "" == "" {//}|| isValidEmail(strEmail: self.txtEmail.text ?? "") == false{
            return false
        }*/
        
        if self.txtFirstName.text ?? "" == "" || self.txtLastName.text ?? "" == ""  || self.txtDNIPassport.text ?? "" == "" || self.txtTelephone.text ?? "" == "" || self.txtEmail.text ?? "" == "" || isValidEmail(strEmail: self.txtEmail.text ?? "") == false || isValidMobileNumber(strMobileNumber: self.txtTelephone.text ?? "") == false {//}|| isValidEmail(strEmail: self.txtEmail.text ?? "") == false{
            return false
        }else{
           /* if self.btnMale.isSelected == false && self.btnFemale.isSelected == false{
                self.showAlert(title: "", message: "msg_select_gender".localized)
                return false
            }else*/
            /*
            if self.btnRecreational.isSelected == false && self.btnMedicinal.isSelected == false{
                self.showAlert(title: "", message: "msg_select_usage".localized)
                return false
            }
             */
        }
        return isCompleted
        //let vc = storyboardName.storyBoard_PreRegistration.instantiateViewController(withIdentifier: "PreRegistrationTermsAndCondVC") as! PreRegistrationTermsAndCondVC
        //self.navigationController?.pushViewController(vc, animated: true)
    }
}

//MARK: Extension for api call
extension PreRegUserDetailsVC:NVActivityIndicatorViewable{
    func callAPIRegistrationDetails() {
        //usage: self.btnRecreational.isSelected ? "Recreational" : "Medicinal",
        startAnimating(CGSize(width: 100, height: 100), message: "", type: NVActivityIndicatorType.ballRotate, fadeInAnimation: nil)
        APIManager.callAPIRequest(Method: .post, url: "\(api_PreRegFinalUserDetails)", parameters: APIParam.PreRegFinalUserDetails(first_name: self.txtFirstName.text ?? "", last_name:  self.txtLastName.text ?? "", email: self.txtEmail.text ?? "", nationality: self.txtNationality.text ?? "", gender: self.btnOther.isSelected ? "Other" : self.btnMale.isSelected ? "Male" : "Female" , street: self.txtStreetName.text ?? "", streetnumber: "", flat: "", postcode: self.txtPostCode.text ?? "", city: self.txtCity.text ?? "", country: self.txtCountry.text ?? "", telephone: self.txtTelephone.text ?? "", device_id: UIDevice.current.identifierForVendor!.uuidString, platform: Shared().device_platform, fcm_key: deviceTokenString,dni: self.txtDNIPassport.text ?? "",club_code: appDelegateShared.preRegClubCode).getParam(), headers: nil, showAlert: false, completion: { (jsonResult, msg) in
            logD(jsonResult)
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                self.stopAnimating(nil)
                
            }
            if jsonResult["flag"].stringValue == "1"{
            /*
                self.btnConfirm.isEnabled = false
                ///use dataFiltro here
                let storyBoard = UIStoryboard(name: "Common", bundle: nil)
                let nextVC = storyBoard.instantiateViewController(withIdentifier: "SnackBarVC") as! SnackBarVC
                nextVC.snackBarMsg = "\(jsonResult["message"].stringValue)"
                //                                nextVC.snackBarColor = "#51a351" // Green color
                nextVC.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
                self.present(nextVC, animated: true, completion: nil)
                */
                
               // DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: {
                  //  nextVC.dismissSnackBar()
                    // post a notification
                
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationName().SetParticularIndexInSideMenu), object: nil, userInfo: ["txt": "My_Clubs".localized])
                    // `default` is now a property, not a method call
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let appDelegate = UIApplication.shared.delegate as? AppDelegate
                    let initialViewController = storyboard.instantiateViewController(withIdentifier: "AddNewClubVC") as! AddNewClubVC
                    let leftViewController = storyboard.instantiateViewController(withIdentifier: "SlideMenuScreenVC") as! SlideMenuScreenVC
                    //appDelegateShared.selectedIndexMenu = 0
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateMenuSelection"), object: nil)
                    let nvc: UINavigationController = UINavigationController(rootViewController: initialViewController)
                    let slideMenuController = SlideMenuController(mainViewController: nvc,  leftMenuViewController: leftViewController)
                    slideMenuController.automaticallyAdjustsScrollViewInsets = true
                    appDelegate?.window?.backgroundColor = UIColor(red: 236.0, green: 238.0, blue: 241.0, alpha: 1.0)
                    appDelegate?.window?.rootViewController = slideMenuController
                    appDelegate?.window?.makeKeyAndVisible()
                    SlideMenuOptions.contentViewScale = 1
                    SlideMenuOptions.hideStatusBar = false
                    SlideMenuOptions.simultaneousGestureRecognizers = false
                
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationName().PreRegistrationSucessFully), object: nil, userInfo: ["txt": jsonResult["message"].stringValue])
                    })
                //})
                /*
                self.showAlert(title: "", message: jsonResult["message"].stringValue, buttonTitles: ["Ok".localized], highlightedButtonIndex: 0, completion: { (idx) in
                    if idx == 0 {
                        
                    }
                })*/
                
            }else{
                self.showAlert(title: "Error".localized, message: jsonResult["message"].stringValue)
                
                
            }
                
        }) { (httpResponse, errorMsg) in
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                self.stopAnimating(nil)
            }
            self.showAlert(title: "Error".localized, message: errorMsg)
        }
    }
}
extension PreRegUserDetailsVC : UITextFieldDelegate {
  // when user select a textfield, this method will be called
  func textFieldDidBeginEditing(_ textField: UITextField) {
    // set the activeTextField to the selected textfield
    self.activeTextField = textField
  }
    
  // when user click 'done' or dismiss the keyboard
  func textFieldDidEndEditing(_ textField: UITextField) {
    self.activeTextField = nil
  }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let empty = textField.text?.isEmpty ?? true
        if(empty) {
            textField.text = string.uppercased()
            return false
        }

        return true
    }
}
