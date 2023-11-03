//
//  ForgotPasswordScreenVC.swift
//  CCSMembersApp
//
//  Created by Apple on 12/04/22.
//  Copyright © 2022 Jaimin Patel. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import Alamofire
import SwiftyJSON
import CoreData
import Firebase

class ForgotPasswordScreenVC: UIViewController, NVActivityIndicatorViewable, UITextFieldDelegate {

    // MARK: - IBOutlets
    
    
    @IBOutlet weak var dummyTitleLabel: UILabel!
    @IBOutlet weak var btnSubmit: UIButton!
    @IBOutlet weak var lblForgotPassword: UILabel!
    @IBOutlet weak var txtEmail: CustomNewTextField!

    // MARK: - Variables
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        startActivity()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        //        signupButton.addCurve()
    }
    private func startActivity() {
        configure()
        setUI()
        setData()
    }
    private func configure() {
    }
    private func setUI() {
        dummyTitleLabel.text = "A_verification_link_will_be_sent".localized
        txtEmail.placeholderMessage = "Email".localized
        txtEmail.lblTitle.text = "Email".localized
        txtEmail.lblTitle.textColor = .white
        txtEmail.textField.delegate = self
        txtEmail.leftImage = UIImage(named: "ic_email")
        btnSubmit.setTitle("SUBMIT".localized, for: .normal)
        txtEmail.textField.setPlaceholder(txt: "dummy_Email".localized, color: UIColor.CommonText)
        lblForgotPassword.text = "FORGOT_PASSWORD_TITLE".localized.uppercased()
                
    }
    
    private func setData() {
    }
    @objc func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
      func validateEmail(_ email: String? = nil) -> Bool {
          guard let userEmail = email, userEmail.isEmpty == false else { return false }
          let isEmailValid = NSPredicate(format: "SELF MATCHES %@", "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,10}").evaluate(with: email)
          guard isEmailValid else { return false  }
          return true
      }
    @IBAction func btnSubmitAction(_ sender: UIButton) {
        if !validateEmail(txtEmail.textField.text) {
            txtEmail.errorMessage = "Please enter a valid email address".localized
            return
        }
        self.view.endEditing(true)
        ForgotAPI(userName: txtEmail.text ?? "", fcm_key: deviceTokenString, macAddress: Shared().getWifi())
    }
    
    
    @IBAction func backBtnAction(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension ForgotPasswordScreenVC{
    func ForgotAPI(userName:String,fcm_key:String,macAddress:String) {
        startAnimating(CGSize(width: 100, height: 100), message: "", type: NVActivityIndicatorType.ballRotate, fadeInAnimation: nil)
        let parameters: Parameters = [
            "language" : "\(Language.language)",
            "email" : userName,
            "platform" : Shared().device_platform,
            "device_id" : UIDevice.current.identifierForVendor!.uuidString,
            "fcm_key" : fcm_key,
            "macAddress" : macAddress,
        ]
        
        Alamofire.request("\(Shared().webCall)resetMemberPassword.php", method: .post, parameters: parameters)
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
                            let message : String = JSON(jsonData["message"]!).stringValue
                          //  Shared().showAlert(uIViewController: self, title: Shared().error, message: message)
                            self.alertForgot(message: message)
                        }
                        else if flag == "2"{
                         
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
    
    func alertForgot(message:String){
        self.popupAlert(title: "", message: message, actionTitles: ["Ok".localized], actions:[{action1 in
            self.navigationController?.popViewController(animated: true)
        },{action2 in
          
        }, nil])
    }
}
