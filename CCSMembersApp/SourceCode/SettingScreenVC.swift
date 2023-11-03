/*//
//  SettingScreenVC.swift
//  CCSMembersApp
//
//  Created by Jaimin Patel on 8/7/19.
//  Copyright © 2019 Jaimin Patel. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire
import NVActivityIndicatorView

class SettingScreenVC: UIViewController,NVActivityIndicatorViewable {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var tblMacAddressHeight: NSLayoutConstraint!
    @IBOutlet weak var tblHeight: NSLayoutConstraint!
    @IBOutlet weak var tblMacAddress: UITableView!
    @IBOutlet weak var imgBackground: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    
    var arrDict=[[String:Any]]()
    var arrDictMac=[[String:Any]]()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource=self
        self.tableView.delegate=self
        self.tblMacAddress.dataSource=self
        self.tblMacAddress.delegate=self
        //self.tableView.isHidden=true
        //self.imgBackground.isHidden=true
        
        self.navigationController?.navigationBar.isHidden=false
        navigationController?.navigationBar.barTintColor = UIColor(named: "backgroundViewColor")
        navigationController?.navigationBar.topItem?.title = "Settings".localized
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font: UIFont(name: "ProductSans-Bold", size: 17)!]
        navigationItem.leftBarButtonItem?.tintColor = UIColor.white
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(tap)
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.imgBackground.image = UIImage(named : Shared().getImgName())
        self.setNavigationBarItem()
        
        var imageSubmit = Shared().imageWithImage(image: UIImage(named: "settingDone")!, scaledToSize: CGSize(width: 23, height: 23))
        imageSubmit = imageSubmit.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        
        let btn2 = UIButton(type: .custom)
      //  btn2.setImage(imageSubmit, for: .normal)
        btn2.setTitle("Save", for: .normal)
        btn2.frame = CGRect(x: 0, y: 0, width: 28, height: 28)
        btn2.addTarget(self, action:#selector(submitAPICall), for: .touchUpInside)
        let item2 = UIBarButtonItem(customView: btn2)
        
        self.navigationItem.setRightBarButtonItems([item2], animated: true)
        
        self.navigationController?.navigationBar.isHidden=false
        navigationController?.navigationBar.barTintColor = UIColor(named: "backgroundViewColor")
        navigationController?.navigationBar.topItem?.title = "Settings".localized
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font: UIFont(name: "ProductSans-Bold", size: 17)!]
        navigationItem.leftBarButtonItem?.tintColor = UIColor.white
    }
    
    @objc func submitAPICall(){
        self.dismissKeyboard()
        var dictArr=[[String:Any]]()
        var i=0
        for itrm in 0..<self.arrDictMac.count{
            var dictVal=[String:Any]()
            if Shared().isValid(text: JSON(self.arrDictMac[itrm]["macaddress"]!).stringValue){
                self.arrDictMac[itrm]["verify"]!="false"
                dictVal["macaddress"]=JSON(self.arrDictMac[itrm]["macaddress"]!).stringValue
                dictVal["macid"]=JSON(self.arrDictMac[itrm]["macaddress"]!).stringValue
                dictArr.append(dictVal)
            } else{
                i=i+1
                self.arrDictMac[itrm]["verify"]!="true"
            }
        }
        if i > 0{
            self.tblMacAddress.reloadData()
            self.tblMacAddressHeight.constant=self.tblMacAddress.contentSize.height
        } else{
            let macData=["Top_up_credit": self.arrDict[0]["switchStatus"],"Pre_order": self.arrDict[1]["switchStatus"],"Show_price": self.arrDict[2]["switchStatus"],"user_id":"\(UserDefaults.standard.string(forKey: "user_id")!)","data":dictArr]
            let jsonData = try! JSONSerialization.data(withJSONObject: macData, options: JSONSerialization.WritingOptions.prettyPrinted)
            let jsonString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)! as String
            submitMacAddress(macData:jsonString)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden=false
        navigationController?.navigationBar.barTintColor = UIColor(named: "backgroundViewColor")
        navigationController?.navigationBar.topItem?.title = "Settings".localized
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font: UIFont(name: "ProductSans-Bold", size: 17)!]
        navigationItem.leftBarButtonItem?.tintColor = UIColor.white
       // self.listDict.removeAll()
        let when = DispatchTime.now() + 0.2
        DispatchQueue.main.asyncAfter(deadline: when) {
            self.macAddressListAPI()
        }
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
        self.view.resignFirstResponder()
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        self.scrollView.isScrollEnabled = true
        let userInfo: NSDictionary = notification.userInfo! as NSDictionary
        let keyboardInfo = userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue
        let keyboardSize = keyboardInfo.cgRectValue.size
        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
    }
    @objc func keyboardWillHide(notification: NSNotification) {
        scrollView.contentInset = .zero
        scrollView.scrollIndicatorInsets = .zero
    }
    
    @IBAction func btnMacAddress(_ sender: UIButton) {
        self.fillupMacTextData(macaddress:"",macid:"EMPTY TEXT",verify:"false")
        self.tblMacAddress.reloadData()
        self.tblMacAddressHeight.constant=self.tblMacAddress.contentSize.height
    }
    
    func fillAdminSettingData(){
        self.tableView.reloadData()
        self.tblHeight.constant=self.tableView.contentSize.height
        self.tblMacAddress.reloadData()
        self.tblMacAddressHeight.constant=self.tblMacAddress.contentSize.height
    }
    
    func fillupSwitchData(lblSettingName:String,switchStatus:String){
        var dictData=[String:Any]()
        dictData["lblSettingName"]=lblSettingName
        dictData["switchStatus"]=switchStatus
        self.arrDict.append(dictData)
    }
    
    func fillupMacTextData(macaddress:String,macid:String,verify:String){
        var dictData=[String:Any]()
        dictData["macaddress"]=macaddress
        dictData["macid"]=macid
        dictData["verify"]=verify
        self.arrDictMac.append(dictData)
    }
}

extension SettingScreenVC:UITableViewDataSource,UITableViewDelegate,setting{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.tableView==tableView{
            return self.arrDict.count
        } else{
            return self.arrDictMac.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if self.tableView==tableView{
            let dictList=self.arrDict[indexPath.row]
            let cell=tableView.dequeueReusableCell(withIdentifier: "adminSetting") as! adminSetting
            cell.lblSettingName.text=JSON(dictList["lblSettingName"]!).stringValue
            if JSON(dictList["switchStatus"]!).stringValue=="0"{
                cell.settingSwitch.isOn=false
            } else{
                cell.settingSwitch.isOn=true
            }
            cell.settingSwitch.tag=indexPath.row
            cell.settingSwitch.addTarget(self, action: #selector(self.switchChanges(sender:)), for: .valueChanged)
            return cell
        } else{
            let dictList=self.arrDictMac[indexPath.row]
            let cell=tableView.dequeueReusableCell(withIdentifier: "adminSettingAddMacAddress") as! adminSettingAddMacAddress
            cell.txtMacAddress.text=JSON(dictList["macaddress"]!).stringValue
            cell.delegateSetting=self
            if JSON(dictList["verify"]!).stringValue == "true"{
                cell.lblVerify.isHidden=false
                cell.lblVerifyHeight.constant=14
            } else{
                cell.lblVerify.isHidden=true
                cell.lblVerifyHeight.constant=0
            }
            let deleteBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 35, height: 25))
            deleteBtn.setImage(UIImage(named: "traceIcon"), for: UIControl.State())
            deleteBtn.imageView?.contentMode = UIView.ContentMode.scaleAspectFit
            deleteBtn.tag=indexPath.row
            deleteBtn.addTarget(self, action: #selector(removeMacText(sender:)), for: .touchUpInside)
            cell.tag=indexPath.row
            let rightViewPassword = UIView(frame: CGRect(x: 0, y: 0, width: 35, height: 25))
            rightViewPassword.addSubview(deleteBtn)
            cell.txtMacAddress.rightView = deleteBtn
            cell.txtMacAddress.rightViewMode = .always
            return cell
        }
    }
    
    func deleteMacText(sender: Int, txtMac: String) {
        self.arrDictMac[sender]["macaddress"]=txtMac
    }
    
    @objc func removeMacText(sender:UIButton){
        let macID=JSON(self.arrDictMac[sender.tag]["macid"]!).stringValue
        if macID=="EMPTY TEXT"{
            self.arrDictMac.remove(at: sender.tag)
            self.tblMacAddress.reloadData()
            self.tblMacAddressHeight.constant=self.tblMacAddress.contentSize.height
        } else{
            let uiAlert = UIAlertController(title: Shared().title, message: "Are you sure you want to delete this macAddress?".localized , preferredStyle:.alert)
            self.present(uiAlert, animated: true, completion: nil)
            uiAlert.addAction(UIAlertAction(title: "No".localized, style: .default, handler: { action in }))
            uiAlert.addAction(UIAlertAction(title: "Yes".localized, style: .destructive, handler: { action in
               self.macAddressDeleteAPI(macID: macID, macIDInt: sender.tag)
            }))
            
        }
    }
    
    @objc func switchChanges(sender:UISwitch){
        var dictList=self.arrDict[sender.tag]
        if JSON(dictList["switchStatus"]!).stringValue=="0"{
            self.arrDict[sender.tag]["switchStatus"]="1"
        } else{
            self.arrDict[sender.tag]["switchStatus"]="0"
        }
        self.tableView.reloadData()
    }
}

//Mark :: Mac Adrress Fetch API Call
extension SettingScreenVC{
    func macAddressListAPI(){
        startAnimating(CGSize(width: 100, height: 100), message: "", type: NVActivityIndicatorType.ballRotate, fadeInAnimation: nil)
        let parameters: Parameters = [
            "language" : "\(Language.language)",
            "club_name" : UserDefaults.standard.object(forKey: "club_name") as! String,
            "platform" : Shared().device_platform,
            "device_id" : UIDevice.current.identifierForVendor!.uuidString,
            "user_id" : UserDefaults.standard.object(forKey: "user_id") as! String,
        ]
        print("\(Shared().webCall)macaddressDetail?language=\(Language.language)&club_name=\(UserDefaults.standard.object(forKey: "club_name") as! String)&user_id=\(UserDefaults.standard.object(forKey: "user_id") as! String)&platform=\(Shared().device_platform)&device_id=\(UIDevice.current.identifierForVendor!.uuidString)")
        Alamofire.request("\(Shared().webCall)macaddressDetail", method: .post, parameters: parameters)
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
                            let topcredit_option = JSON(jsonData["topcredit_option"]!).stringValue
                            self.fillupSwitchData(lblSettingName: "Top-up credit", switchStatus: topcredit_option)
                            let preorder_option = JSON(jsonData["preorder_option"]!).stringValue
                            self.fillupSwitchData(lblSettingName: "Pre-ordering", switchStatus: preorder_option)
                            let showprice_option = JSON(jsonData["showprice_option"]!).stringValue
                            self.fillupSwitchData(lblSettingName: "Show prices in menu", switchStatus: showprice_option)
                            
                            if let jsonDict = jsonData["data"] as? [[String:Any]]{
                                for macItem in jsonDict{
                                       self.fillupMacTextData(macaddress: JSON(macItem["macaddress"]!).stringValue, macid: JSON(macItem["macid"]!).stringValue, verify: "false")
                                }
                            }
                            self.fillAdminSettingData()
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

//Mark :: Delete macAddress API Call
extension SettingScreenVC{
    func macAddressDeleteAPI(macID:String,macIDInt:Int){
        startAnimating(CGSize(width: 100, height: 100), message: "", type: NVActivityIndicatorType.ballRotate, fadeInAnimation: nil)
        let parameters: Parameters = [
            "language" : "\(Language.language)",
            "club_name" : UserDefaults.standard.object(forKey: "club_name") as! String,
            "platform" : Shared().device_platform,
            "device_id" : UIDevice.current.identifierForVendor!.uuidString,
            "user_id" : UserDefaults.standard.object(forKey: "user_id") as! String,
            "macid" : macID,
        ]
        print("\(Shared().webCall)deleteMacaddress?language=\(Language.language)&club_name=\(UserDefaults.standard.object(forKey: "club_name") as! String)&platform=\(Shared().device_platform)&device_id=\(UIDevice.current.identifierForVendor!.uuidString)&macid=\(macID)&user_id=\(UserDefaults.standard.object(forKey: "user_id") as! String)")
        Alamofire.request("\(Shared().webCall)deleteMacaddress", method: .post, parameters: parameters)
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
                            self.arrDictMac.remove(at: macIDInt)
                            self.tblMacAddress.reloadData()
                            self.tblMacAddressHeight.constant=self.tblMacAddress.contentSize.height
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

//Mark :: Submit macAddress API Call
extension SettingScreenVC{
    func submitMacAddress(macData:String){
        startAnimating(CGSize(width: 100, height: 100), message: "", type: NVActivityIndicatorType.ballRotate, fadeInAnimation: nil)
        let parameters: Parameters = [
            "language" : "\(Language.language)",
            "club_name" : UserDefaults.standard.object(forKey: "club_name") as! String,
            "macadd_request" : macData,
        ]
        print("\(Shared().webCall)addMacaddress?language=\(Language.language)&club_name=\(UserDefaults.standard.object(forKey: "club_name") as! String)&macadd_request=\(macData)")
        Alamofire.request("\(Shared().webCall)addMacaddress", method: .post, parameters: parameters)
            .responseJSON { response in
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()) {
                    self.stopAnimating(nil)
                }
                switch response.result {
                case .success:
                    print("JSON::",response.result.value!)
                    if let jsonData = response.result.value as? [String:Any] {
                        let flag = JSON(jsonData["flag"]!).stringValue
                        if flag == "1"{
                            let uiAlert = UIAlertController(title: Shared().title, message: JSON(jsonData["message"]!).stringValue , preferredStyle:.alert)
                            self.present(uiAlert, animated: true, completion: nil)
                            uiAlert.addAction(UIAlertAction(title: "Ok".localized, style: .default, handler: { action in
                                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                var vc: UIViewController!
                                let vcCon = storyboard.instantiateViewController(withIdentifier: "HomeScreenVC") as! HomeScreenVC
                                vc = UINavigationController(rootViewController: vcCon)
                                self.slideMenuController()?.changeMainViewController(vc, close: true)
                            }))
                        } else{
                            let message : String = JSON(jsonData["message"]!).stringValue
                            Shared().showAlert(uIViewController: self, title: Shared().error, message: message)
                        }
                    }
                    break
                    
                case .failure(let error):
                    let errorCode = error._code
                    if(errorCode == -1001 || errorCode == -1005 || errorCode == -1009) {
                        Shared().showAlert(uIViewController: self, title: Shared().error, message: error.localizedDescription)
                    } else {
                        Shared().showAlert(uIViewController: self)
                    }
                    print("Server:",error.localizedDescription)
                    break
                }
        }
    }
}*/

//
//  SettingScreenVC.swift
//  CCSMembersApp
//
//  Created by Jaimin Patel on 8/7/19.
//  Copyright © 2019 Jaimin Patel. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire
import NVActivityIndicatorView

class SettingScreenVC: UIViewController,NVActivityIndicatorViewable {
    
    @IBOutlet weak var addWifiMacAddressView: UIView!
    @IBOutlet weak var btnAddclub: UIButton!
    @IBOutlet weak var lblAddclub: UILabel!
    @IBOutlet weak var topTblView: NSLayoutConstraint!
    @IBOutlet weak var topMacAddressErrorLabel: NSLayoutConstraint!
    @IBOutlet weak var topMacAddressView: NSLayoutConstraint!
    @IBOutlet weak var btnAddWifiOutlet: UIButton!
    @IBOutlet weak var heightMacAddressView: NSLayoutConstraint!
    @IBOutlet weak var lblAddWifiMacAddress: UILabel!
    @IBOutlet weak var lblVerifyMacAddress: UILabel!
    @IBOutlet weak var lblVerifyMacAddressHeight: NSLayoutConstraint!
    @IBOutlet weak var txtAddMacAddress: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var tblMacAddressHeight: NSLayoutConstraint!
    @IBOutlet weak var tblHeight: NSLayoutConstraint!
    @IBOutlet weak var tblMacAddress: UITableView!
    @IBOutlet weak var imgBackground: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    
    var arrDict=[[String:Any]]()
    var arrDictMac=[[String:Any]]()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.txtAddMacAddress.delegate=self
        
        self.tableView.dataSource=self
        self.tableView.delegate=self
        self.tblMacAddress.dataSource=self
        self.tblMacAddress.delegate=self
        //self.tableView.isHidden=true
        //self.imgBackground.isHidden=true
        
        self.navigationController?.navigationBar.isHidden=false
        navigationController?.navigationBar.barTintColor = UIColor.white//UIColor(named: "backgroundViewColor")
        navigationController?.navigationBar.topItem?.title = "Settings".localized.uppercased()
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.font: UIFont(name: "ProductSans-Bold", size: 17)!]
        navigationItem.leftBarButtonItem?.tintColor = UIColor(named: "NavigationText")!
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(tap)
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("gs-\(arrDictMac.count)")
        self.addWifiMacAddressView.shadowColor(color: UIColor(named: "AddCreditBG")!.withAlphaComponent(0.6), border: 2, offHeight: 1)
        self.txtAddMacAddress.placeholder="Enter mac address".localized
        self.lblAddWifiMacAddress.text="Add Wifi Mac Address".localized
        self.scrollView.isHidden=true
        self.lblVerifyMacAddressHeight.constant=0
        self.imgBackground.image = UIImage(named : Shared().getImgName())
        self.setNavigationBarItem()
        
        var imageSubmit = Shared().imageWithImage(image: UIImage(named: "settingDone")!, scaledToSize: CGSize(width: 23, height: 23))
        imageSubmit = imageSubmit.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        
        let btn2 = UIButton(type: .custom)
        //  btn2.setImage(imageSubmit, for: .normal)
        btn2.setTitle("Save".localized, for: .normal)
        btn2.setTitleColor(UIColor(named: "ColorMainGreen")!, for: .normal)
        btn2.frame = CGRect(x: 0, y: 0, width: 28, height: 28)
        btn2.addTarget(self, action:#selector(submitAPICall), for: .touchUpInside)
        let item2 = UIBarButtonItem(customView: btn2)
        
        self.navigationItem.setRightBarButtonItems([item2], animated: true)
        self.setLeftAlignTitleView(font: UIFont(name: "ProductSans-Bold", size: 17)!, text: "Settings".localized, textColor: .white)
        self.navigationController?.navigationBar.isHidden=false
        navigationController?.navigationBar.barTintColor = UIColor.white//UIColor(named: "backgroundViewColor")
        navigationController?.navigationBar.topItem?.title = "Settings".localized.uppercased()
        
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(named: "NavigationText")!, NSAttributedString.Key.font: UIFont(name: "ProductSans-Bold", size: 17)!]
        navigationItem.leftBarButtonItem?.tintColor = UIColor(named: "NavigationText")!
    }
    
    @objc func submitAPICall(){
        
        print("gs-\(arrDictMac.count)")
    
        if arrDictMac.count > 0 {
            self.dismissKeyboard()
            var dictArr=[[String:Any]]()
            var i=0
            for itrm in 0..<self.arrDictMac.count{
                var dictVal=[String:Any]()
                if JSON(self.arrDictMac[itrm]["editStatus"]!).stringValue == "0"{
                    self.arrDictMac[itrm]["errMsg"]!=""
                    dictVal["macaddress"]=JSON(self.arrDictMac[itrm]["macaddress"]!).stringValue
                    dictVal["macid"]=JSON(self.arrDictMac[itrm]["macaddress"]!).stringValue
                    dictArr.append(dictVal)
                } else{
                    i=i+1
                    self.arrDictMac[itrm]["errMsg"]!=Shared().saveMacAddressErrMsg
                }
            }
            if i > 0{
                self.tblMacAddress.reloadData()
                self.tblMacAddressHeight.constant=self.tblMacAddress.contentSize.height
            } else{
//                let macData=["Top_up_credit": self.arrDict[0]["switchStatus"],"Pre_order": self.arrDict[2]["switchStatus"],"Show_price": self.arrDict[1]["switchStatus"],"user_id":"\(UserDefaults.standard.string(forKey: "user_id")!)","data":dictArr]
                let macData=["Top_up_credit": self.arrDict[0]["switchStatus"],"Pre_order": self.arrDict[0]["switchStatus"],"Show_price": self.arrDict[0]["switchStatus"],"user_id":"\(UserDefaults.standard.string(forKey: "user_id")!)","data":dictArr]
                let jsonData = try! JSONSerialization.data(withJSONObject: macData, options: JSONSerialization.WritingOptions.prettyPrinted)
                let jsonString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)! as String
                submitMacAddress(macData:jsonString)
            }
        }else{
            let macData=["Top_up_credit": "0", "Pre_order": "0","Show_price": self.arrDict[0]["switchStatus"], "user_id":"\(UserDefaults.standard.string(forKey: "user_id")!)", "data":""]
            let jsonData = try! JSONSerialization.data(withJSONObject: macData, options: JSONSerialization.WritingOptions.prettyPrinted)
            let jsonString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)! as String
            submitMacAddress(macData:jsonString)
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.btnAddWifiOutlet.setImage(UIImage(named: "settingPlushImage"), for: .normal)
        self.btnAddclub.setImage(UIImage(named: "settingPlushImage"), for: .normal)
        macAddressHideShow(flag: false)
        self.navigationController?.navigationBar.isHidden=false
        navigationController?.navigationBar.barTintColor = UIColor.black//UIColor(named: "backgroundViewColor")
        navigationController?.navigationBar.topItem?.title = "Settings".localized.uppercased()
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.font: UIFont(name: "ProductSans-Bold", size: 17)!]
        navigationItem.leftBarButtonItem?.tintColor = UIColor(named: "NavigationText")!//UIColor.white
        // self.listDict.removeAll()
        let when = DispatchTime.now() + 0.2
        DispatchQueue.main.asyncAfter(deadline: when) {
            self.macAddressListAPI()
        }
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
        self.view.resignFirstResponder()
    }
    
    @IBAction func btnAddWifiAction(_ sender: UIButton) {
        if (self.btnAddWifiOutlet.currentImage?.isEqual(UIImage(named: "settingPlushImage")))!{
            self.btnAddWifiOutlet.setImage(UIImage(named: "settingMinushImage"), for: .normal)
            macAddressHideShow(flag: true)
        } else{
            self.btnAddWifiOutlet.setImage(UIImage(named: "settingPlushImage"), for: .normal)
            macAddressHideShow(flag: false)
        }
    }
    
    @IBAction func btnAddClubAction(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        UserDefaults.standard.set("falseSetting", forKey: "addMemberAccount")
        var vc: UIViewController!
        let vcCon = storyboard.instantiateViewController(withIdentifier: "LoginScreenVC") as! LoginScreenVC
        vc = UINavigationController(rootViewController: vcCon)
        self.slideMenuController()?.changeMainViewController(vc, close: true)
    }
    
    func macAddressHideShow(flag:Bool){
        if flag==true{
            self.topMacAddressView.constant=8
            self.heightMacAddressView.constant=50
            self.lblVerifyMacAddressHeight.constant=0
            self.topMacAddressErrorLabel.constant=4
            self.topTblView.constant=8
            self.tblMacAddressHeight.constant=self.tblMacAddress.contentSize.height
        } else{
            self.topMacAddressView.constant=0
            self.heightMacAddressView.constant=0
            self.lblVerifyMacAddressHeight.constant=0
            self.topMacAddressErrorLabel.constant=0
            self.topTblView.constant=8
            self.tblMacAddressHeight.constant=0
        }
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        self.scrollView.isScrollEnabled = true
        let userInfo: NSDictionary = notification.userInfo! as NSDictionary
        let keyboardInfo = userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue
        let keyboardSize = keyboardInfo.cgRectValue.size
        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
    }
    @objc func keyboardWillHide(notification: NSNotification) {
        scrollView.contentInset = .zero
        scrollView.scrollIndicatorInsets = .zero
    }
    
    @IBAction func btnMacAddress(_ sender: UIButton) {
        if Shared().isValid(text: JSON(self.txtAddMacAddress.text!).stringValue){
            let array = arrDictMac.filter { $0["macaddress"] as! String == "\(self.txtAddMacAddress.text!)" }
            
            print ("array = \(array)")
            
            if(array.count == 0){
                self.lblVerifyMacAddressHeight.constant=0
                self.fillupMacTextData(macaddress:JSON(self.txtAddMacAddress.text!).stringValue,macid:"EMPTY TEXT",verify:"false", editStatus: "0", errMsg: "")
                self.tblMacAddress.reloadData()
                self.tblMacAddressHeight.constant=self.tblMacAddress.contentSize.height
            } else {
                self.lblVerifyMacAddress.text=Shared().verifyAllreadyMacAddressErrMsg
                self.lblVerifyMacAddressHeight.constant=14
            }
            
        } else{
            self.lblVerifyMacAddress.text=Shared().verifyMacAddressErrMsg
            self.lblVerifyMacAddressHeight.constant=14
        }
    }
    
    func fillAdminSettingData(){
        self.tableView.reloadData()
        self.tblHeight.constant=self.tableView.contentSize.height
//        self.tblMacAddress.reloadData()           // Handle MAC Address table height
//        self.tblMacAddressHeight.constant=self.tblMacAddress.contentSize.height
    }
    
    func fillupSwitchData(lblSettingName:String,switchStatus:String){
        var dictData=[String:Any]()
        dictData["lblSettingName"]=lblSettingName
        dictData["switchStatus"]=switchStatus
        self.arrDict.append(dictData)
    }
    
    func fillupMacTextData(macaddress:String,macid:String,verify:String,editStatus:String,errMsg:String){
        var dictData=[String:Any]()
        dictData["macaddress"]=macaddress
        dictData["macid"]=macid
        dictData["verify"]=verify
        dictData["editStatus"]=editStatus
        dictData["errMsg"]=errMsg
        self.arrDictMac.append(dictData)
    }
}

extension SettingScreenVC:UITableViewDataSource,UITableViewDelegate,setting{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.tableView==tableView{
            return self.arrDict.count
        } else{
            return self.arrDictMac.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if self.tableView==tableView{
            let dictList=self.arrDict[indexPath.row]
            let cell=tableView.dequeueReusableCell(withIdentifier: "adminSetting") as! adminSetting
           // cell.lblSettingName.text=JSON(dictList["lblSettingName"]!).stringValue
            cell.lblSettingName.text = JSON(dictList["lblSettingName"]!).stringValue
            if JSON(dictList["switchStatus"]!).stringValue=="0"{
                cell.settingSwitch.isOn=false
            } else{
                cell.settingSwitch.isOn=true
            }
            cell.settingSwitch.tag=indexPath.row
            cell.settingSwitch.addTarget(self, action: #selector(self.switchChanges(sender:)), for: .valueChanged)
            return cell
        } else{
            let dictList=self.arrDictMac[indexPath.row]
            let cell=tableView.dequeueReusableCell(withIdentifier: "adminSettingAddMacAddress") as! adminSettingAddMacAddress
            cell.txtMacAddress.tag=indexPath.row
            cell.txtMacAddress.text=JSON(dictList["macaddress"]!).stringValue
            cell.delegateSetting=self
            cell.lblVerify.isHidden=false
            cell.lblVerifyHeight.constant=14
            cell.lblVerify.text=""
//            if JSON(dictList["verify"]!).stringValue == "true"{
//                cell.lblVerify.isHidden=false
//                cell.lblVerifyHeight.constant=14
//            } else{
//                cell.lblVerify.isHidden=true
//                cell.lblVerifyHeight.constant=0
//            }
            /*if JSON(dictList["errMsg"]!).stringValue == ""{
                cell.lblVerify.text=""
            } else{
                cell.lblVerify.text=JSON(dictList["errMsg"]!).stringValue
            }*/
            
            cell.btnTrace.tag=indexPath.row
            cell.btnTrace.addTarget(self, action: #selector(self.removeMacText(sender:)), for: .touchUpInside)
            
            /*if JSON(dictList["editStatus"]!).stringValue == "1"{
                cell.txtMacAddress.isUserInteractionEnabled=true
                cell.btnEdit.setImage(UIImage(named: "DoneIcon"), for: .normal)
            } else{
                cell.txtMacAddress.isUserInteractionEnabled=false
                cell.btnEdit.setImage(UIImage(named: "EditIcon"), for: .normal)
            }*/
            cell.btnEdit.tag=indexPath.row
            cell.btnEdit.addTarget(self, action: #selector(self.editMacText(sender:)), for: .touchUpInside)
            return cell
        }
    }
    
    func deleteMacText(sender: Int, txtMac: String) {
        print("=========>>>>>>",sender,txtMac)
        self.arrDictMac[sender]["macaddress"]=txtMac
        self.arrDictMac[sender]["editStatus"]="1"
    }
    
    @objc func editMacText(sender:UIButton){
        var dictList=self.arrDictMac[sender.tag]
        if JSON(dictList["editStatus"]!).stringValue == "1"{
            if Shared().isValid(text: JSON(dictList["macaddress"]!).stringValue){
                let array = arrDictMac.filter { $0["macaddress"] as! String == JSON(dictList["macaddress"]!).stringValue }
                
                print ("array = \(array)")
                
                if(array.count == 1){
                    self.arrDictMac[sender.tag]["editStatus"]="0"
                    self.arrDictMac[sender.tag]["errMsg"]=""
                } else {
                    self.arrDictMac[sender.tag]["editStatus"]="1"
                    self.arrDictMac[sender.tag]["errMsg"]=Shared().verifyAllreadyMacAddressErrMsg
                }
                
            } else{
                self.arrDictMac[sender.tag]["editStatus"]="1"
                self.arrDictMac[sender.tag]["errMsg"]=Shared().verifyMacAddressErrMsg
            }
        } else{
            self.arrDictMac[sender.tag]["editStatus"]="1"
            self.arrDictMac[sender.tag]["errMsg"]=""
        }
        self.tblMacAddress.reloadData()
    }
    
    @objc func removeMacText(sender:UIButton){
        let macID=JSON(self.arrDictMac[sender.tag]["macid"]!).stringValue
        if macID=="EMPTY TEXT"{
            self.arrDictMac.remove(at: sender.tag)
            self.tblMacAddress.reloadData()
            self.tblMacAddressHeight.constant=self.tblMacAddress.contentSize.height
        } else{
            let uiAlert = UIAlertController(title: Shared().title, message: "Are you sure you want to delete this macAddress?".localized , preferredStyle:.alert)
            self.present(uiAlert, animated: true, completion: nil)
            uiAlert.addAction(UIAlertAction(title: "No".localized, style: .default, handler: { action in }))
            uiAlert.addAction(UIAlertAction(title: "Yes".localized, style: .destructive, handler: { action in
                self.macAddressDeleteAPI(macID: macID, macIDInt: sender.tag)
            }))
            
        }
    }
    
    @objc func switchChanges(sender:UISwitch){
        var dictList=self.arrDict[sender.tag]
        if sender.tag == 0{
            if JSON(dictList["switchStatus"]!).stringValue=="0"{
                self.arrDict[sender.tag]["switchStatus"]="1"
                
               
                var tempArrDispenseHistory = [self.arrDict[1]]
                self.arrDict.remove(at: 1)
                
                if self.arrDict.count > 1{
                    tempArrDispenseHistory.append(self.arrDict[1])
                    self.arrDict.remove(at: 1)
                }
                
                
                self.fillupSwitchData(lblSettingName: "Show prices in menu".localized, switchStatus: "0")
                
                self.fillupSwitchData(lblSettingName: "Show dispense history".localized, switchStatus: tempArrDispenseHistory[0]["switchStatus"] as? String ?? "0")
                if JSON(tempArrDispenseHistory[0]["switchStatus"]!).stringValue=="1"{
                    var switchStatus = "0"
                    if tempArrDispenseHistory.count > 1{
                        switchStatus = tempArrDispenseHistory[1]["switchStatus"] as? String ?? "0"
                    }
                    self.fillupSwitchData(lblSettingName: "Show prices in dispense history".localized, switchStatus: switchStatus)
                }
            } else{
                self.arrDict[sender.tag]["switchStatus"]="0"
//                self.arrDict[sender.tag+1]["switchStatus"]="0"
                self.arrDict.remove(at: 1)
            }
        } else if sender.tag == 1{
            if JSON(self.arrDict[0]["switchStatus"]!).stringValue=="1"{
                if JSON(dictList["switchStatus"]!).stringValue=="0"{
                    var dictList1=self.arrDict[1]
                    if JSON(dictList["switchStatus"]!).stringValue=="0"{
                        self.arrDict[sender.tag]["switchStatus"]="1"
                    } else{
                        self.arrDict[sender.tag]["switchStatus"]="0"
                    }
                    
                } else{
                    self.arrDict[sender.tag]["switchStatus"]="0"
                }
            }else{
                if JSON(dictList["switchStatus"]!).stringValue=="0"{
                    self.arrDict[sender.tag]["switchStatus"]="1"
                    self.fillupSwitchData(lblSettingName: "Show prices in dispense history".localized, switchStatus: "0")
                } else{
                    self.arrDict[sender.tag]["switchStatus"]="0"
    //                self.arrDict[sender.tag+1]["switchStatus"]="0"
                    self.arrDict.remove(at: 2)
                }
            }
            
        } else if sender.tag == 2{
            /*if JSON(dictList["switchStatus"]!).stringValue=="0"{
                var dictList1=self.arrDict[2]
             
                if JSON(dictList1["switchStatus"]!).stringValue=="0"{
                    self.arrDict[sender.tag]["switchStatus"]="0"
                } else{
                    self.arrDict[sender.tag]["switchStatus"]="1"
                }
                
            } else{
                self.arrDict[sender.tag]["switchStatus"]="0"
            }*/
            if JSON(dictList["switchStatus"]!).stringValue=="0"{
                self.arrDict[sender.tag]["switchStatus"]="1"
                self.fillupSwitchData(lblSettingName: "Show prices in dispense history".localized, switchStatus: "0")
            } else{
                self.arrDict[sender.tag]["switchStatus"]="0"
//                self.arrDict[sender.tag+1]["switchStatus"]="0"
                self.arrDict.remove(at: 3)
            }
        }else if sender.tag == 3{
            if JSON(dictList["switchStatus"]!).stringValue=="0"{
                var dictList1=self.arrDict[1]
                if JSON(dictList["switchStatus"]!).stringValue=="0"{
                    self.arrDict[sender.tag]["switchStatus"]="1"
                } else{
                    self.arrDict[sender.tag]["switchStatus"]="0"
                }
                
            } else{
                self.arrDict[sender.tag]["switchStatus"]="0"
            }
        } else{
            if JSON(dictList["switchStatus"]!).stringValue=="0"{
                self.arrDict[sender.tag]["switchStatus"]="1"
            } else{
                self.arrDict[sender.tag]["switchStatus"]="0"
            }
        }
        
        self.tableView.reloadData()
        self.tblHeight.constant=self.tableView.contentSize.height

    }
}

//Mark :: Enter mac address textfield
extension SettingScreenVC:UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

//Mark :: Mac Adrress Fetch API Call
extension SettingScreenVC{
    func macAddressListAPI(){
        startAnimating(CGSize(width: 100, height: 100), message: "", type: NVActivityIndicatorType.ballRotate, fadeInAnimation: nil)
        let parameters: Parameters = [
            "language" : "\(Language.language)",
            "club_name" : UserDefaults.standard.object(forKey: "club_name") as! String,
            "platform" : Shared().device_platform,
            "device_id" : UIDevice.current.identifierForVendor!.uuidString,
            "user_id" : UserDefaults.standard.object(forKey: "user_id") as! String,
        ]
        print("\(Shared().webCall)macaddressDetail?language=\(Language.language)&club_name=\(UserDefaults.standard.object(forKey: "club_name") as! String)&user_id=\(UserDefaults.standard.object(forKey: "user_id") as! String)&platform=\(Shared().device_platform)&device_id=\(UIDevice.current.identifierForVendor!.uuidString)")
        Alamofire.request("\(Shared().webCall)macaddressDetail.php", method: .post, parameters: parameters)
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
                            self.scrollView.isHidden=false
//                            let topcredit_option = JSON(jsonData["topcredit_option"]!).stringValue
//                            self.fillupSwitchData(lblSettingName: "Top-up credit".localized, switchStatus: topcredit_option)
                            let showprice_option = JSON(jsonData["showprice_option"]!).stringValue
                            let showMenu_option = JSON(jsonData["showmenu_option"]!).intValue
                            self.fillupSwitchData(lblSettingName: "Show menu".localized, switchStatus: "\(showMenu_option)")
                            if showMenu_option == 1 {
                                self.fillupSwitchData(lblSettingName: "Show prices in menu".localized, switchStatus: showprice_option)
                            }
                            
                            //need to change
                            let showDispenseMenu_option = JSON(jsonData["dispensmenu_option"] ?? 0).intValue
                            let showDispensePrice_option = JSON(jsonData["dispensprice_option"] ?? 0).stringValue
                            self.fillupSwitchData(lblSettingName: "Show dispense history".localized, switchStatus: "\(showDispenseMenu_option)")
                            if showDispenseMenu_option == 1 {
                                self.fillupSwitchData(lblSettingName: "Show prices in dispense history".localized, switchStatus: showDispensePrice_option)
                            }
                            
//                            let preorder_option = JSON(jsonData["preorder_option"]!).stringValue
//                            self.fillupSwitchData(lblSettingName: "Pre-ordering".localized, switchStatus: preorder_option)
                            
                            if let jsonDict = jsonData["data"] as? [[String:Any]]{
                                for macItem in jsonDict{
                                    self.fillupMacTextData(macaddress: JSON(macItem["macaddress"]!).stringValue, macid: JSON(macItem["macid"]!).stringValue, verify: "false", editStatus: "0", errMsg: "")
                                }
                            }
                            self.fillAdminSettingData()
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

//Mark :: Delete macAddress API Call
extension SettingScreenVC{
    func macAddressDeleteAPI(macID:String,macIDInt:Int){
        startAnimating(CGSize(width: 100, height: 100), message: "", type: NVActivityIndicatorType.ballRotate, fadeInAnimation: nil)
        let parameters: Parameters = [
            "language" : "\(Language.language)",
            "club_name" : UserDefaults.standard.object(forKey: "club_name") as! String,
            "platform" : Shared().device_platform,
            "device_id" : UIDevice.current.identifierForVendor!.uuidString,
            "user_id" : UserDefaults.standard.object(forKey: "user_id") as! String,
            "macid" : macID,
        ]
        print("\(Shared().webCall)deleteMacaddress?language=\(Language.language)&club_name=\(UserDefaults.standard.object(forKey: "club_name") as! String)&platform=\(Shared().device_platform)&device_id=\(UIDevice.current.identifierForVendor!.uuidString)&macid=\(macID)&user_id=\(UserDefaults.standard.object(forKey: "user_id") as! String)")
        Alamofire.request("\(Shared().webCall)deleteMacaddress.php", method: .post, parameters: parameters)
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
                            self.arrDictMac.remove(at: macIDInt)
                            self.tblMacAddress.reloadData()
                            self.tblMacAddressHeight.constant=self.tblMacAddress.contentSize.height
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

//Mark :: Submit macAddress API Call
extension SettingScreenVC{
    func submitMacAddress(macData:String){
        startAnimating(CGSize(width: 100, height: 100), message: "", type: NVActivityIndicatorType.ballRotate, fadeInAnimation: nil)
        /*let parameters: Parameters = [                // 9S~~~ OLD REQUEST DATA
            "language" : "\(Language.language)",
            "club_name" : UserDefaults.standard.object(forKey: "club_name") as! String,
            "macadd_request" : macData,
        ]*/
        
        //9spl:- Change re
        var isDispenseMenuAvailable = "0"
        var isDispensePriceAvailable = "0"
        
        for i in self.arrDict {
            if (i["lblSettingName"] as? String ?? "") == "Show dispense history".localized{
                isDispenseMenuAvailable = i["switchStatus"] as? String ?? ""
                print("dispense history is Available and status is :- \(isDispenseMenuAvailable)")
            }
            
            if (i["lblSettingName"] as? String ?? "") == "Show prices in dispense history".localized{
                isDispensePriceAvailable = i["switchStatus"] as? String ?? ""
                print("dispense history price is Available and status is :- \(isDispensePriceAvailable)")
            }
        }
        
        
        
        let parameters: Parameters = [
            "language" : "\(Language.language)",
            "club_name" : UserDefaults.standard.object(forKey: "club_name") as! String,
            "macadd_request" : macData,
            "macAddress" : "",
            "Top_up_credit" : "0",
            "Pre_order" : "0",
            "Show_menu" : "\(self.arrDict[0]["switchStatus"]!)",
            "Show_price" : self.arrDict[0]["switchStatus"] as? String == "1" ? "\(self.arrDict[1]["switchStatus"]!)" : "0",
            "Dispens_menu" : "\(isDispenseMenuAvailable)",
            "Dispens_price" : "\(isDispensePriceAvailable)",
            "user_id" : "\(UserDefaults.standard.string(forKey: "user_id")!)",
        ]
        print("Params: ~~~ \(parameters)")
//        print("\(Shared().webCall)addMacaddress?language=\(Language.language)&club_name=\(UserDefaults.standard.object(forKey: "club_name") as! String)&macadd_request=\(macData)")
        Alamofire.request("\(Shared().webCall)addMacaddress.php", method: .post, parameters: parameters)
            .responseJSON { response in
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()) {
                    self.stopAnimating(nil)
                }
                switch response.result {
                case .success:
                    NotificationCenter.default.post(name: Notification.Name("callAPICheckUserStatus"), object: nil)
                    print("JSON::",response.result.value!)
                    if let jsonData = response.result.value as? [String:Any] {
                        let flag = JSON(jsonData["flag"]!).stringValue
                        if flag == "1"{
                            let uiAlert = UIAlertController(title: Shared().title, message: JSON(jsonData["message"]!).stringValue , preferredStyle:.alert)
                            self.present(uiAlert, animated: true, completion: nil)
                            uiAlert.addAction(UIAlertAction(title: "Ok".localized, style: .default, handler: { action in
                                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                var vc: UIViewController!
                                appDelegateShared.selectedIndexMenu = 0
                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateMenuSelection"), object: nil)
                                let vcCon = storyboard.instantiateViewController(withIdentifier: "MainMenuVC") as! MainMenuVC
                                vc = UINavigationController(rootViewController: vcCon)
                                self.slideMenuController()?.changeMainViewController(vc, close: true)
                            }))
                        } else{
                            let message : String = JSON(jsonData["message"]!).stringValue
                            Shared().showAlert(uIViewController: self, title: Shared().error, message: message)
                        }
                    }
                    break
                    
                case .failure(let error):
                    let errorCode = error._code
                    if(errorCode == -1001 || errorCode == -1005 || errorCode == -1009) {
                        Shared().showAlert(uIViewController: self, title: Shared().error, message: error.localizedDescription)
                    } else {
                        Shared().showAlert(uIViewController: self)
                    }
                    print("Server:",error.localizedDescription)
                    break
                }
        }
    }
}

