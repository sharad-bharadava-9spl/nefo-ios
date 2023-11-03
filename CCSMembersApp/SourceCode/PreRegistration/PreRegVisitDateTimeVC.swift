//
//  PreRegVisitDateTimeVC.swift
//  CCSMembersApp
//
//  Created by Divyesh Dabhi on 09/05/23.
//  Copyright © 2023 Jaimin Patel. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import SwiftyJSON

class PreRegVisitDateTimeVC: UIViewController {
    
    @IBOutlet weak var btnSubmit: UIButton!
    @IBOutlet weak var lblDateDetails: UILabel!
    @IBOutlet weak var lblTimeDetails: UILabel!
    @IBOutlet weak var txtTime: UITextField!
    //@IBOutlet weak var timePicker: UIPickerView!
    var timePicker = UIPickerView()
    
    var selectedDate = ""
    var selectedTimeHour = ""
    var selectedTimeMinute = ""
    var myDatePicker = MyDatePicker()
    let pickerData: [[String]] = [
        ["12", "13", "14", "15", "16", "17", "18", "19", "20"],
            ["00", "15", "30", "45"]]
    
    let toolBar = UIToolbar()
    override func viewDidLoad() {
        super.viewDidLoad()
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
        //self.timePicker.isHidden = true
        self.setupDatePicker()
        self.setupLanguage()
        self.setupNavigationItem()
    }
    
    func setupNavigationItem(){
        self.title = "Pre_Registration".localized.uppercased()
        self.removeNavigationBarItem()
        self.navigationController?.navigationBar.tintColor = .white
       // self.setNavigationBarItem()
        self.setLeftAlignTitleView(font: UIFont(name: "ProductSans-Bold", size: 17)!, text: "Pre_Registration".localized, textColor: .white)
        
        
    }
    
    func setupLanguage(){
        self.btnSubmit.setTitle("SUBMIT".localized, for: .normal)
        
        self.lblTimeDetails.text = "msg_choose_visit_time".localized
        self.lblDateDetails.text = "msg_choose_visit_date".localized
       
    }
    
    func setupDatePicker(){
        
        self.setTimePicker()
        //self.timePicker.delegate = self
        //.timePicker.dataSource = self

                // Give the label a default value
        //self.selectedTimeHour = self.pickerData[0][0]
        //self.selectedTimeMinute = self.pickerData[1][0]
        
        myDatePicker.isHidden = true
        myDatePicker.isShowTime = false
        myDatePicker.minimumDate = Date()
        
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
            self.lblDateDetails.text = getDateString(val, format: dateTimeFromateDispalyOnlyDate).capitalized
            self.selectedDate = getDateString(val, format: "yyyy-MM-dd")
            self.myDatePicker.selectedDate = val
            print(self.selectedDate)
            // do something with the selected date
        }
    }
    
    func setTimePicker(){
        
        self.timePicker.frame = CGRect(x: 0, y: self.view.frame.size.height - 200, width: self.view.frame.size.width, height: 200)
        self.timePicker.backgroundColor = .white

       // self.selectedTimeHour = self.pickerData[0][0]
        //self.selectedTimeMinute = self.pickerData[1][0]
        
        self.timePicker.showsSelectionIndicator = true
        self.timePicker.delegate = self
        self.timePicker.dataSource = self

        
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor(red: 76/255, green: 217/255, blue: 100/255, alpha: 1)
        toolBar.sizeToFit()
        
        
        let doneButton = UIBarButtonItem(title: "Done".localized, style: UIBarButtonItem.Style.done, target: self, action: #selector(self.donePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel".localized, style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.cancelClickedPicker))

        doneButton.tintColor = .black //UIColor(red: 14/255, green: 255/255, blue: 134/255, alpha: 1)
        cancelButton.tintColor = .black //UIColor(red: 14/255, green: 255/255, blue: 134/255, alpha: 1)
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        

        self.txtTime.inputView = self.timePicker
        self.txtTime.inputAccessoryView = toolBar
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }

    func keyboardWillHide(notification: NSNotification) {
        if view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
    @objc func donePicker(){
        self.view.endEditing(true)
        if self.selectedTimeHour == "" {
            self.selectedTimeHour = self.pickerData[0][0]
        }
        if self.selectedTimeMinute == "" {
            self.selectedTimeMinute = self.pickerData[1][0]
        }
        self.lblTimeDetails.text = "\(self.selectedTimeHour) : \(self.selectedTimeMinute)"
    }
    
    @objc func cancelClickedPicker(){
        self.view.endEditing(true)
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
extension PreRegVisitDateTimeVC{
    @IBAction func btnClicked(_ sender: UIButton) {
        self.view.endEditing(true)
        
        switch sender.tag{
        case 0:
            if validateView(){
                self.callAPIDate()
            }
        case 1:
            print("Open Date picker")
            self.myDatePicker.isHidden = false
        default:
            break;
        }
    }
    
    func validateView() -> Bool{
        var isComplete = true
        
        if self.selectedDate == ""{
            isComplete = false
            self.showAlert(title: "", message: "msg_choose_visit_date".localized)
        }else if self.selectedTimeHour == ""{
            isComplete = false
            self.showAlert(title: "", message: "msg_choose_visit_time".localized)
        }
        return isComplete
    }
}

//MARK:  Extension for API call
extension PreRegVisitDateTimeVC:NVActivityIndicatorViewable{
    func callAPIDate() {
        startAnimating(CGSize(width: 100, height: 100), message: "", type: NVActivityIndicatorType.ballRotate, fadeInAnimation: nil)
        APIManager.callAPIRequest(Method: .post, url: "\(api_PreRegSecondAForrm)", parameters: APIParam.PreRegSecondAForm(date: self.selectedDate).getParam(), headers: nil, showAlert: false, completion: { (jsonResult, msg) in
            logD(jsonResult)
            
            if jsonResult["flag"].stringValue == "1"{
                //var arrTempData = appDelegateShared.arrPreRegistartionsData
                
                for (key,item) in jsonResult {
                     print("\(key) -> \(item)")
                    appDelegateShared.arrPreRegistartionsData[key] = item
                }
                //appDelegateShared.arrPreRegistartionsData = JSON(appDelegateShared.arrPreRegistartionsData + jsonResult)
                print("appDelegateShared.arrPreRegistartionsData ")
                print(appDelegateShared.arrPreRegistartionsData )
                self.callAPITime()
            }else{
                DispatchQueue.main.asyncAfter(deadline: .now()) {
                    self.stopAnimating(nil)
                }
                self.showAlert(title: "Error".localized, message: jsonResult["message"].stringValue)
            }
        }) { (httpResponse, errorMsg) in
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                self.stopAnimating(nil)
            }
            self.showAlert(title: "Error".localized, message: errorMsg)
        }
    }
    func callAPITime() {
        APIManager.callAPIRequest(Method: .post, url: "\(api_PreRegSecondBForrm)", parameters: APIParam.PreRegSecondBForm(time: "\(self.selectedTimeHour):\(self.selectedTimeMinute)").getParam(), headers: nil, showAlert: false, completion: { (jsonResult, msg) in
            logD(jsonResult)
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                self.stopAnimating(nil)
            }
            if jsonResult["flag"].stringValue == "1"{
                for (key,item) in jsonResult {
                     print("\(key) -> \(item)")
                    appDelegateShared.arrPreRegistartionsData[key] = item
                }
                //appDelegateShared.arrPreRegistartionsData = JSON(appDelegateShared.arrPreRegistartionsData + jsonResult)
                print("appDelegateShared.arrPreRegistartionsData \n")
                print(appDelegateShared.arrPreRegistartionsData )
                let vc = storyboardName.storyBoard_PreRegistration.instantiateViewController(withIdentifier: "PreRegUploadPassportAndPhotosVC") as! PreRegUploadPassportAndPhotosVC
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
    }
}

//MARK:  Extension for Picker Deligate and Datasource
extension PreRegVisitDateTimeVC: UIPickerViewDelegate,UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
            return pickerData.count
        }

        func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
            return pickerData [component].count
        }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[component][row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        switch component {
        case 0:
            self.selectedTimeHour = pickerData[component][row]
        case 1:
            
            self.selectedTimeMinute = pickerData[component][row]
        default:
            break
        }
    }
}

