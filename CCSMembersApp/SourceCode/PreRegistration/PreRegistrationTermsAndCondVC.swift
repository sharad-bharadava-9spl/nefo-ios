//
//  PreRegistrationTermsAndCondVC.swift
//  CCSMembersApp
//
//  Created by Divyesh Dabhi on 24/04/23.
//  Copyright © 2023 Jaimin Patel. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import SwiftyJSON
import WebKit

class PreRegistrationTermsAndCondVC: UIViewController {

    @IBOutlet weak var btnSubmit: UIButton!
    @IBOutlet weak var btnDateOfBirth: UIButton!
    @IBOutlet weak var btnYourSignature: UIButton!
    
    @IBOutlet weak var tvMessage: UITextView!
    @IBOutlet weak var btnFirstCheckBox: UIButton!
    @IBOutlet weak var btnSecondCheckBox: UIButton!
    @IBOutlet weak var btnThirdCheckBox: UIButton!
    
    @IBOutlet weak var lblCheckBoxFirstDesc: UILabel!
    @IBOutlet weak var lblCheckBoxSecondDesc: UILabel!
    @IBOutlet weak var lblCheckBoxThirdDesc: UILabel!
    
    @IBOutlet weak var webview: WKWebView!
    var imgSignature = UIImage()
    var dataSignature = Data()
    
    var selectedDate = ""
    var myDatePicker = MyDatePicker()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.setupUI()
        self.setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //self.setupLanguageData()
        
    }
    override func viewDidLayoutSubviews () {
        super.viewDidLayoutSubviews()
        self.myDatePicker.frame = self.view.frame
        
    }
    func setupUI(){
        self.setupDatePicker()
        self.setupLanguage()
        self.setUpWebViewData()
        self.setupNavigationItem()
    }
    
    func setupNavigationItem(){
        self.title = "Pre_Registration".localized.uppercased()
        self.removeNavigationBarItem()
        self.navigationController?.navigationBar.tintColor = .white
       // self.setNavigationBarItem()
        self.setLeftAlignTitleView(font: UIFont(name: "ProductSans-Bold", size: 17)!, text: "Pre_Registration".localized, textColor: .white)
        
        
    }
    
    func setUpWebViewData(){
        if let url = Bundle.main.url(forResource: "PreRegTermsAndCondition_\(Language.language)", withExtension: "html") {
            self.webview.loadFileURL(url, allowingReadAccessTo: url)
            let request = URLRequest(url: url)
            self.webview.load(request)
        }
        //let url = Bundle.main.url(forResource: "PreRegTermsAndConditionSpanish", withExtension: "html", subdirectory: "website")!
        
    }
    
    func setupLanguage(){
        self.btnSubmit.setTitle("SUBMIT".localized, for: .normal)
        self.btnDateOfBirth.setTitle("Date of Birth".localized, for: .normal)
        self.btnYourSignature.setTitle("Your Signature".localized, for: .normal)
        
        self.tvMessage.attributedText = "mag_pre_reg_terms_conditions".localized.htmlToAttributedString
        self.lblCheckBoxFirstDesc.text = "checkbox_provision_of_requested_service".localized
        self.lblCheckBoxSecondDesc.text = "checkbox_sending_emails_SMS_to_your_mobile".localized
        self.lblCheckBoxThirdDesc.text = "checkbox_member_confirms_statutes".localized
    }
    
    func setupDatePicker(){
        myDatePicker.isHidden = true
        myDatePicker.isShowTime = false
        myDatePicker.maximumDate = Date() //Calendar.current.date(byAdding: .year, value: -18, to: Date())
        
        myDatePicker.commonInit()
        self.view.addSubview(self.myDatePicker)
        // hide custom picker view
                
        // add closures to custom picker view
        myDatePicker.dismissClosure = { [weak self] in
            guard let self = self else {
                return
            }
            
            self.myDatePicker.isHidden = true
        }
        myDatePicker.changeClosure = { [weak self] val in
            guard let self = self else {
                return
            }
            
            //"MMM dd, yyyy"
            self.btnDateOfBirth.setTitle(getDateString(val, format: dateTimeFromateDispalyOnlyDate).capitalized, for: .normal)
            self.selectedDate = getDateString(val, format: "yyyy-MM-dd")
            self.myDatePicker.selectedDate = val
            print(self.selectedDate)
            // do something with the selected date
        }
    }
    
    /*
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
    }*/
    
//    @IBAction func btnSubmit(_ sender: UIButton) {
//        self.view.endEditing(true)
//
//
//    }
}

//MARK:  Extension for button clicked
extension PreRegistrationTermsAndCondVC{
    @IBAction func btnClicked(_ sender: UIButton) {
        self.view.endEditing(true)
        
        switch sender.tag{
        case 0:
            print("First checkbox")
            self.btnFirstCheckBox.isSelected = !self.btnFirstCheckBox.isSelected
        case 1:
            print("second checkbox")
            self.btnSecondCheckBox.isSelected = !self.btnSecondCheckBox.isSelected
        case 2:
            print("Third checkbox")
            self.btnThirdCheckBox.isSelected = !self.btnThirdCheckBox.isSelected
        case 3:
            print("Open Date picker")
            self.myDatePicker.isHidden = false
        case 4:
            print("Open Signature view")
            self.shownAddSignaturePopup(controller: self,image:self.imgSignature)
        case 5:
            print("Submit clicked")
            if validateView(){
                self.callAPIRegistartions()
            }
            
        default:
            break;
        }
    }
    
    func validateView() -> Bool{
        var isComplete = true
        
        if self.selectedDate == ""{
            self.showAlert(title: "", message: "msg_err_enter_date_of_birth".localized)
            isComplete = false
        }else if self.dataSignature.count == 0{
            self.showAlert(title: "", message: "msg_err_add_signature".localized)
            isComplete = false
//        }else if self.btnFirstCheckBox.isSelected == false{
//            self.showAlert(title: "", message: "msg_err_check_all_things".localized)
//            isComplete = false
//        }else if self.btnSecondCheckBox.isSelected == false{
//            self.showAlert(title: "", message: "msg_err_check_all_things".localized)
//            isComplete = false
        }else if self.btnThirdCheckBox.isSelected == false{
            self.showAlert(title: "", message: "msg_err_check_all_things".localized)
            isComplete = false
        }
        
        return isComplete
    }
    
}

//MARK:  Extension for set Signature delegate method
extension PreRegistrationTermsAndCondVC:setImageDelegate{
    //MARK: Shown Add Signature popup
    func shownAddSignaturePopup(controller: UIViewController,image:UIImage){
        let popoverVC  = storyboardName.storyBoard_PreRegistration.instantiateViewController(withIdentifier: "\(AddSignatureVC.self)") as? AddSignatureVC
        controller.addChild(popoverVC!)
        popoverVC?.selectedImage = image
        popoverVC?.delegate = controller as! setImageDelegate
        popoverVC?.view.frame = CGRect(x: 0, y: 0, width: controller.view.frame.width, height: controller.view.frame.height)
        popoverVC?.popupView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        controller.view.addSubview((popoverVC?.view)!)

        UIView .animate(withDuration:0.3, delay: 0.0, options: UIView.AnimationOptions.curveLinear, animations: {
            popoverVC?.popupView.transform = CGAffineTransform(scaleX: 1, y: 1)
        }, completion: {
            (value: Bool) in
        })
    }
    func setImage(image: UIImage) {
        if image != nil {
            //self.imgSignature.image = image
            self.imgSignature = image
            self.dataSignature = self.imgSignature.jpegData(compressionQuality: 1)!
            
            
        }
    }
}
extension PreRegistrationTermsAndCondVC:NVActivityIndicatorViewable{
    func callAPIRegistartions() {
        startAnimating(CGSize(width: 100, height: 100), message: "", type: NVActivityIndicatorType.ballRotate, fadeInAnimation: nil)
        
        APIManager.callAPIRequest(Method: .post, url: "\(api_PreRegFirstForrm)", parameters: APIParam.PreRegFirstForm(date: self.selectedDate,image: self.dataSignature.base64EncodedString()).getParam(), headers: nil, showAlert: false, completion: { (jsonResult, msg) in
            logD(jsonResult)
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                self.stopAnimating(nil)
            }
            
            if jsonResult["flag"].stringValue == "1"{
                appDelegateShared.arrPreRegistartionsData = JSON(jsonResult)
                let vc = storyboardName.storyBoard_PreRegistration.instantiateViewController(withIdentifier: "PreRegVisitDateTimeVC") as! PreRegVisitDateTimeVC
                self.navigationController?.pushViewController(vc, animated: true)
            }else{
                self.showAlert(title: "Error".localized, message: jsonResult["message"].stringValue)
            }
                
        }) { (httpResponse, errorMsg) in
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                self.stopAnimating(nil)
            }
            self.showAlert(title: "Error".localized, message: errorMsg)
        }
        
//        APIManager.uploadDataWithImages(Method: .post, url: "\(api_PreRegFirstForrm)", parameters: APIParam.PreRegFirstForrm(date: self.selectedDate).getParam(), headers: nil, imageData: self.dataSignature, uploadParamName: "image", showProgress: false, showAlert: false) { jsonResult, headerMessage in
//            logD(jsonResult)
//            DispatchQueue.main.asyncAfter(deadline: .now()) {
//                self.stopAnimating(nil)
//            }
//            if jsonResult["flag"].stringValue == "1"{
//                let vc = storyboardName.storyBoard_PreRegistration.instantiateViewController(withIdentifier: "PreRegVisitDateTimeVC") as! PreRegVisitDateTimeVC
//                self.navigationController?.pushViewController(vc, animated: true)
//            }else{
//                self.showAlert(title: "", message: jsonResult["message"].stringValue)
//                let vc = storyboardName.storyBoard_PreRegistration.instantiateViewController(withIdentifier: "PreRegVisitDateTimeVC") as! PreRegVisitDateTimeVC
//                self.navigationController?.pushViewController(vc, animated: true)
//            }
//        } failure: { httpresponse, errorMessage in
//            DispatchQueue.main.asyncAfter(deadline: .now()) {
//                self.stopAnimating(nil)
//            }
//            self.showAlert(title: "", message: errorMessage)
//        } progressCompletion: { progress in
//            print("Upload Progress ==== \(progress)")
////                SVProgressHUD.dismiss()
//        }
        
        
//        APIManager.uploadSingleImages(Method: .post, url: api_PreRegFirstForrm, parameters: APIParam.PreRegFirstForrm(date: self.selectedDate).getParam(), headers: nil, imageData: self.dataSignature, uploadParamName: "image", showProgress: false, showAlert: false, completion: { (jsonResult, msg) in
//            logD(jsonResult)
//            DispatchQueue.main.asyncAfter(deadline: .now()) {
//                self.stopAnimating(nil)
//            }
//            if jsonResult["flag"].stringValue == "1"{
//                let vc = storyboardName.storyBoard_PreRegistration.instantiateViewController(withIdentifier: "PreRegUploadPassportAndPhotosVC") as! PreRegUploadPassportAndPhotosVC
//                self.navigationController?.pushViewController(vc, animated: true)
//            }else{
//                self.showAlert(title: "", message: jsonResult["message"].stringValue)
//                let vc = storyboardName.storyBoard_PreRegistration.instantiateViewController(withIdentifier: "PreRegVisitDateTimeVC") as! PreRegVisitDateTimeVC
//                self.navigationController?.pushViewController(vc, animated: true)
//            }
//        }, failure: { (response, msg) in
//            DispatchQueue.main.asyncAfter(deadline: .now()) {
//                self.stopAnimating(nil)
//            }
//            self.showAlert(title: "", message: msg)
//        }) { (progress) in
//            print(progress)
//        }
        
    }
    
    
        func uploadImage(paramName: String, fileName: String, image: UIImage) {
            let url = URL(string: "http://api-host-name/v1/api/uploadfile/single")

            // generate boundary string using a unique per-app string
            let boundary = UUID().uuidString

            let session = URLSession.shared

            // Set the URLRequest to POST and to the specified URL
            var urlRequest = URLRequest(url: url!)
            urlRequest.httpMethod = "POST"

            // Set Content-Type Header to multipart/form-data, this is equivalent to submitting form data with file upload in a web browser
            // And the boundary is also set here
            urlRequest.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

            var data = Data()

            // Add the image data to the raw http request data
            data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
            data.append("Content-Disposition: form-data; name=\"\(paramName)\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
            data.append("Content-Type: image/png\r\n\r\n".data(using: .utf8)!)
            data.append(image.pngData()!)

            data.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)

            // Send a POST request to the URL, with the data we created earlier
            session.uploadTask(with: urlRequest, from: data, completionHandler: { responseData, response, error in
                if error == nil {
                    let jsonData = try? JSONSerialization.jsonObject(with: responseData!, options: .allowFragments)
                    if let json = jsonData as? [String: Any] {
                        print(json)
                    }
                }
            }).resume()
        }
}
