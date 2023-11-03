//
//  DonationVC.swift
//  CCSMembersApp
//
//  Created by Jaimin Patel on 7/4/19.
//  Copyright © 2019 Jaimin Patel. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SlideMenuControllerSwift
import NVActivityIndicatorView

class DonationVC: UIViewController,UITextViewDelegate,NVActivityIndicatorViewable{

    @IBOutlet weak var creditOutletView: UIView!
    @IBOutlet weak var DonationTblHeight: NSLayoutConstraint!
    @IBOutlet weak var HeightAddNoteView: NSLayoutConstraint!
    @IBOutlet weak var btnAddMinushSign: UIButton!
    @IBOutlet weak var addNoteView: UIView!
    @IBOutlet weak var imgDonationCard: UIImageView!
    @IBOutlet weak var lblDonationOutlet: UILabel!
    @IBOutlet weak var btnCancelOutlet: UIButton!
    @IBOutlet weak var lblDebitOutlet: UILabel!
    @IBOutlet weak var lblCreditOutlet: UILabel!
    @IBOutlet weak var lblFilterBy: UILabel!
    @IBOutlet weak var lblDonationHistry: UILabel!
    @IBOutlet weak var btnAddCredit: UIButton!
    @IBOutlet weak var lblNotes: UILabel!
    @IBOutlet weak var lblDonation: UILabel!
    @IBOutlet weak var lblMaxCredit: UILabel!
    @IBOutlet weak var btnDebitOutlet: UIButton!
    @IBOutlet weak var btnCreditOutlet: UIButton!
    @IBOutlet weak var halfFilterView: UIView!
    @IBOutlet weak var halfFilterHeight: NSLayoutConstraint!
    @IBOutlet weak var fullFilterView: UIView!
    @IBOutlet weak var filterView: UIView!
    @IBOutlet weak var creditView: UIView!
    @IBOutlet weak var txtNote: UITextView!
    @IBOutlet weak var txtDonation: UITextField!
    @IBOutlet weak var lblAvailableCredit: UILabel!
    //@IBOutlet weak var imgBackground: UIImageView!lDonation
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var lblMaxCreditOutlet: UILabel!
    @IBOutlet weak var lblAvailableCreditOutlet: UILabel!
    
    var listDict=[donationList]()
    var Top_up_credit:String="0"
    var item1:UIBarButtonItem?
    var item2:UIBarButtonItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource=self
        self.tableView.delegate=self
        self.tableView.isHidden=true
        //self.imgBackground.isHidden=true
        self.creditView.isHidden=true
        self.creditOutletView.isHidden=true
        self.filterView.isHidden=true
        self.txtDonation.delegate=self
        self.txtNote.delegate=self
        
        self.creditView.shadowColor(color: UIColor.black.withAlphaComponent(0.2), border: 1.2, offHeight: 0)
        self.creditView.layer.cornerRadius = 10.0
        self.creditView.layer.masksToBounds=true
        
        self.navigationController?.navigationBar.isHidden=false
        navigationController?.navigationBar.barTintColor = UIColor.white//UIColor(named: "backgroundViewColor")
        navigationController?.navigationBar.topItem?.title = "Slide_Donation".localized.uppercased()
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(named: "NavigationText")!, NSAttributedString.Key.font: UIFont(name: "ProductSans-Bold", size: 17)!]
        navigationItem.leftBarButtonItem?.tintColor = UIColor(named: "NavigationText")!
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(tap)
        
        fullFilterView.isHidden=true
        halfFilterView.isHidden=true
        halfFilterHeight.constant = -162
        let filterFull: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(filterFullView))
        self.fullFilterView.addGestureRecognizer(filterFull)
        self.setupToolBar()
        // Do any additional setup after loading the view.
    }
    
    func setupToolBar(){
        let flexible = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: self, action: nil)
        let toolbar1 = UIToolbar()
        toolbar1.sizeToFit()
        toolbar1.center = CGPoint(x: view.frame.width/2, y: 100)
        
        // let doneBtn1 = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.done, target: self, action: #selector(self.dismissKeyboard))
        let nextExpire = UIBarButtonItem(title: "Next".localized, style:.done, target:self, action: #selector(self.donationAmount))
        toolbar1.items=[flexible, nextExpire]
        self.txtDonation.inputAccessoryView = toolbar1
    }
    
    @objc func donationAmount(){
        self.txtNote.becomeFirstResponder()
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
        self.view.resignFirstResponder()
    }
    
    @objc func filterFullView() {
        filterhideView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.addNoteView.shadowColor(color: UIColor(named: "AddCreditBG")!.withAlphaComponent(0.6), border: 1.2, offHeight: 2)
        self.creditView.shadowColor(color: UIColor.black.withAlphaComponent(0.2), border: 1.2, offHeight: 1)
        self.HeightAddNoteView.constant=0
        self.btnAddMinushSign.setImage(UIImage(named: "plushSign"), for: .normal)
        self.imgDonationCard.setImageFromSVG("Icono-donacion")
        self.btnDebitOutlet.setImage(UIImage(named: "select_RadioButton"), for: .normal)
        self.btnCreditOutlet.setImage(UIImage(named: "unselect_RadioButton"), for: .normal)
      //  self.imgBackground.image = UIImage(named : Shared().getImgName())
        self.setNavigationBarItem()
        
        self.navigationController?.navigationBar.isHidden=false
        navigationController?.navigationBar.barTintColor = UIColor.white//UIColor(named: "backgroundViewColor")
        navigationController?.navigationBar.topItem?.title = "Slide_Donation".localized.uppercased()
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(named: "NavigationText")!, NSAttributedString.Key.font: UIFont(name: "ProductSans-Bold", size: 17)!]
        navigationItem.leftBarButtonItem?.tintColor = UIColor(named: "NavigationText")!
        self.setupLanguage()
        
        var imageShopingCart = Shared().imageWithImage(image: UIImage(named: "Shoping_Cart")!, scaledToSize: CGSize(width: 23, height: 23))
        imageShopingCart = imageShopingCart.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        
        var imageNotification = Shared().imageWithImage(image: UIImage(named: "notification")!, scaledToSize: CGSize(width: 23, height: 23))
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
        btn2.frame = CGRect(x: 0, y: 0, width: 28, height: 28)
        btn2.addTarget(self, action: #selector(self.notificationScreenRedirection), for: .touchUpInside)
        item2 = UIBarButtonItem(customView: btn2)
        item2?.removeBadge()
        if targetName != Shared().cannibisAppName {
        self.navigationItem.setRightBarButtonItems([item1!,item2!], animated: true)
        } else {
            self.navigationItem.setRightBarButtonItems([item2!], animated: true)
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
    }
    
    @objc func notificationScreenRedirection(){
        let storyBoard=UIStoryboard(name: "Main", bundle: nil)
        let vc=storyBoard.instantiateViewController(withIdentifier: "NotificationVC") as! NotificationVC
        let navVC=UINavigationController(rootViewController: vc)
        slideMenuController()?.changeMainViewController(navVC, close: true)
    }
    
    @objc func cartRedirection(){
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "CartScreenVC") as! CartScreenVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func setupLanguage(){
        self.lblDonation.text="Slide_Donation".localized
        self.lblNotes.text="Note".localized
        self.btnAddCredit.setTitle("Add Credit".localized, for: .normal)
        self.lblDonationHistry.text="Donation History".localized.uppercased()
        self.lblFilterBy.text="Filter By".localized
        self.lblCreditOutlet.text="Credit".localized
        self.lblDebitOutlet.text="Debit".localized
        self.btnCancelOutlet.setTitle("Cancel".localized, for: .normal)
        self.lblCreditOutlet.text="Available Credit : ".localized.uppercased()
        self.lblMaxCreditOutlet.text="Max Credit : ".localized.uppercased()
        self.lblDonationOutlet.text="ADD DONATION".localized
        self.lblAvailableCreditOutlet.text="Available Credit : ".localized.uppercased()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden=false
        navigationController?.navigationBar.barTintColor = UIColor.white//UIColor(named: "backgroundViewColor")
        navigationController?.navigationBar.topItem?.title = "Slide_Donation".localized.uppercased()
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(named: "NavigationText")!, NSAttributedString.Key.font: UIFont(name: "ProductSans-Bold", size: 17)!]
        navigationItem.leftBarButtonItem?.tintColor = UIColor(named: "NavigationText")!//UIColor.white
        
        let when = DispatchTime.now() + 0.2
        DispatchQueue.main.asyncAfter(deadline: when) {
            self.donationHistryViewAPI()
        }
    }
    
    @IBAction func btnAddMinush(_ sender: UIButton) {
        if (self.btnAddMinushSign.currentImage?.isEqual(UIImage(named: "plushSign")))!{
            self.HeightAddNoteView.constant=80
            self.btnAddMinushSign.setImage(UIImage(named: "minushSign"), for: .normal)
        } else{
            self.txtNote.text=""
            self.HeightAddNoteView.constant=0
             self.btnAddMinushSign.setImage(UIImage(named: "plushSign"), for: .normal)
        }
    }
    
    @IBAction func btnDebitAction(_ sender: UIButton) {
        self.btnDebitOutlet.setImage(UIImage(named: "select_RadioButton"), for: .normal)
        self.btnCreditOutlet.setImage(UIImage(named: "unselect_RadioButton"), for: .normal)
        donationHistryFilterAPI(flag:"2")
    }
    @IBAction func btnCreditAction(_ sender: UIButton) {
        self.btnDebitOutlet.setImage(UIImage(named: "unselect_RadioButton"), for: .normal)
        self.btnCreditOutlet.setImage(UIImage(named: "select_RadioButton"), for: .normal)
        donationHistryFilterAPI(flag:"1")
    }
    @IBAction func btnFilterCancel(_ sender: UIButton) {
        filterhideView()
    }
    
    func filterhideView(){
        UIView.animate(withDuration: 0.15,
                       delay: 0.1,
                       options: UIView.AnimationOptions.curveEaseIn,
                       animations: { () -> Void in
            self.halfFilterHeight.constant = -162
            self.view.layoutIfNeeded()
            
            //self.superview?.layoutIfNeeded()
        }, completion: { Void in
            self.halfFilterView.isHidden=true
            self.fullFilterView.isHidden=true
            self.view.endEditing(true)
            self.view.resignFirstResponder()
            
            //  self.isOpen = true
        })
    }
    @IBAction func btnAddCredit(_ sender: UIButton) {
        if self.Top_up_credit == "1"{
            let amount:String = (self.txtDonation.text!.trimmingCharacters(in: .whitespacesAndNewlines))
            let note :String = (self.txtNote.text!.trimmingCharacters(in: .whitespacesAndNewlines))
            var error = ""
            if amount==""{
                error = "Please enter valid amount.".localized
            }
//            else if note == ""{
//                error = "Please enter valid notes.".localized
//            }
            
            if(error != "") {
                self.dismissKeyboard()
                let when = DispatchTime.now() + 0.5
                DispatchQueue.main.asyncAfter(deadline: when) {
                    Shared().showAlert(uIViewController: self, title: Shared().title, message: error)
                }
            } else{
                self.dismissKeyboard()
                self.getStripeToken(costVal:amount,noteVal:note)
            }
        } else{
            self.dismissKeyboard()
            Shared().showAlert(uIViewController: self, title: Shared().wifiNoteError, message: Shared().wifiPermissionNote)
        }
    }
    
    @IBAction func btnFilterAction(_ sender: UIButton) {
        fullFilterView.isHidden=false
        halfFilterView.isHidden=false
        UIView.animate(withDuration: 0.15,
                       delay: 0.1,
                       options: UIView.AnimationOptions.curveEaseIn,
                       animations: { () -> Void in
                        
                         self.halfFilterHeight.constant=12
                        
                        self.view.layoutIfNeeded()
                        
                        //self.superview?.layoutIfNeeded()
        }, completion: { Void in
            
            //  self.isOpen = true
        })
        
    }
    
    
    
    
}

extension DonationVC:UITableViewDataSource,UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listDict.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "donationCell") as! donationCell
        let dictData=listDict[indexPath.row]
        cell.mainView.shadowColor(color: UIColor.black.withAlphaComponent(0.2), border: 1.4, offHeight: 1)
        //cell.mainView.layer.cornerRadius = 10.0
        //cell.mainView.layer.masksToBounds=true
        cell.lblDateTime.text=dictData.donationDate
        cell.lblTime.text=dictData.donationTime
        cell.lblDonationID.text="#"+dictData.donationid
       // cell.lblOldCredit.text=dictData.creditBefore
        cell.lblNewCredit.text=dictData.creditBefore+" €"
        cell.lblPrice.text=dictData.amount+" €"
        cell.lblNewCreditOutlet.text="New Credit: ".localized
        cell.lblDonationAdded.text=dictData.donation_status//"ORDER PAYMENT".localized//dictData.donation_status
//        if dictData.operationType == "Donation"{
//            cell.lblPrice.textColor=UIColor(named: "addToCartView")
//            cell.lblDonationAdded.text="Donation Added".localized
//        } else{
//            cell.lblPrice.textColor=UIColor.red
//            cell.lblDonationAdded.text="Paid For Order".localized
//        }
        return cell
    }
}

extension DonationVC:UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.txtDonation{
            self.txtNote.becomeFirstResponder()
        } else{
            self.dismissKeyboard()
        }
        return true
    }
}

extension DonationVC{
    func donationHistryViewAPI(){
        self.lblMaxCredit.isHidden=true
        startAnimating(CGSize(width: 100, height: 100), message: "", type: NVActivityIndicatorType.ballRotate, fadeInAnimation: nil)
        let parameters: Parameters = [
            "language" : "\(Language.language)",
            "club_name" : UserDefaults.standard.object(forKey: "club_name") as! String,
            "macAddress" : Shared().getWifi(),
            "user_id" : UserDefaults.standard.string(forKey: "user_id")!,
            "platform" : Shared().device_platform,
            "device_id" : UIDevice.current.identifierForVendor!.uuidString,
        ]
        print("\(Shared().webCall)donationHistory?user_id=\(UserDefaults.standard.string(forKey: "user_id")!)&language=\(Language.language)&club_name=\(UserDefaults.standard.object(forKey: "club_name") as! String)&platform=\(Shared().device_platform)&device_id=\(UIDevice.current.identifierForVendor!.uuidString)&macAddress=\(Shared().getWifi())")
        Alamofire.request("\(Shared().webCall)donationHistory.php", method: .post, parameters: parameters)
            .responseJSON { response in
                let when = DispatchTime.now()
                DispatchQueue.main.asyncAfter(deadline: when) {
                    self.stopAnimating(nil)
                }
                switch response.result {
                case .success:
                    print("JSON::",response.result.value!)
                    if let jsonData = response.result.value as? [String:Any] {
                        let flag = JSON(jsonData["flag"]!).stringValue
                        if flag == "1"{
                            if let jsonDict = jsonData["data"] as? [String:Any]{
                                let notification_count = UserDefaults.standard.string(forKey: "notifcount") as? String ?? "0"
                                UIApplication.shared.applicationIconBadgeNumber=JSON(notification_count).intValue
                                if notification_count != "0" {
                                    self.item2?.addBadge(number: Int(notification_count ?? "")!)
                                } else{
                                    self.item2?.removeBadge()
                                }
                                self.Top_up_credit=JSON(jsonDict["Top_up_credit"]!).stringValue
                                self.lblAvailableCredit.text="\(Double(round(100*Double(Shared().componentSepareted(fullValue: JSON(jsonData["avalible_credit"]!).stringValue, separatedBy: " "))!)/100))"+" €"//JSON(jsonData["avalible_credit"]!).stringValue+" €"
                                let maxCreditIs=JSON(jsonData["maxcredit"]!).doubleValue
                                if maxCreditIs > 0.0{
                                    self.lblMaxCredit.isHidden=false
                                    self.lblMaxCredit.text="-"+JSON(jsonData["maxcresdit"]!).stringValue+" €"
                                    self.lblMaxCreditOutlet.isHidden=false
                                } else{
                                    self.lblMaxCredit.isHidden=true
                                    self.lblMaxCreditOutlet.isHidden=true
                                }
                                
                                if let jsonDict = jsonDict["history"] as? [[String:Any]]{
                                    let jsonIs = JSON(jsonDict)
                                    self.listDict.removeAll()
                                    for item in 0..<jsonIs.count{
                                        let arrObj=donationList(json: jsonIs[item])
                                        self.listDict.append(arrObj)
                                    }
                                   // if self.listDict.count != 0{
                                        self.tableView.isHidden=false
                                      //  self.imgBackground.isHidden=false
                                        self.creditView.isHidden=false
                                    self.creditOutletView.isHidden=false
                                        self.filterView.isHidden=false
                                    self.tableView.reloadData()
                                    self.DonationTblHeight.constant=self.tableView.contentSize.height
                                    //}
                                }
                            }
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

extension DonationVC{
    func donationHistryFilterAPI(flag:String){
        startAnimating(CGSize(width: 100, height: 100), message: "", type: NVActivityIndicatorType.ballRotate, fadeInAnimation: nil)
        let parameters: Parameters = [
            "language" : "\(Language.language)",
            "club_name" : UserDefaults.standard.object(forKey: "club_name") as! String,
            "user_id" : UserDefaults.standard.string(forKey: "user_id")!,
            "flag" : flag,
            "platform" : Shared().device_platform,
            "device_id" : UIDevice.current.identifierForVendor!.uuidString,
        ]
        print("\(Shared().webCall)donationFilter?user_id=\(UserDefaults.standard.string(forKey: "user_id")!)&language=\(Language.language)&club_name=\(UserDefaults.standard.object(forKey: "club_name") as! String)&platform=\(Shared().device_platform)&device_id=\(UIDevice.current.identifierForVendor!.uuidString)&flag=\(flag)")
        Alamofire.request("\(Shared().webCall)donationFilter.php", method: .post, parameters: parameters)
            .responseJSON { response in
                let when = DispatchTime.now()
                DispatchQueue.main.asyncAfter(deadline: when) {
                    self.stopAnimating(nil)
                }
                switch response.result {
                case .success:
                    print("JSON::",response.result.value!)
                    if let jsonData = response.result.value as? [String:Any] {
                        let flag = JSON(jsonData["flag"]!).stringValue
                        if flag == "1"{
                            if let jsonDict = jsonData["data"] as? [String:Any]{
                                self.lblAvailableCredit.text="Available Credit : ".localized+"\(Double(round(100*Double(Shared().componentSepareted(fullValue: JSON(jsonData["avalible_credit"]!).stringValue, separatedBy: " "))!)/100))"+" €"//JSON(jsonData["avalible_credit"]!).stringValue+" €"
                                self.lblMaxCredit.text="Max Credit : ".localized+JSON(jsonData["maxcredit"]!).stringValue+" €"
                                if let jsonDict = jsonDict["history"] as? [[String:Any]]{
                                    let jsonIs = JSON(jsonDict)
                                    self.filterhideView()
                                    self.listDict.removeAll()
                                    for item in 0..<jsonIs.count{
                                        let arrObj=donationList(json: jsonIs[item])
                                        self.listDict.append(arrObj)
                                    }
                                    
                                    // if self.listDict.count != 0{
//                                    self.tableView.isHidden=false
//                                    self.imgBackground.isHidden=false
//                                    self.creditView.isHidden=false
//                                    self.filterView.isHidden=false
                                    self.tableView.reloadData()
                                    self.DonationTblHeight.constant=self.tableView.contentSize.height
                                    //}
                                }
                            }
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
    
    func getStripeToken(costVal:String,noteVal:String){
        self.btnAddCredit.isEnabled=false
     //   startAnimating(CGSize(width: 100, height: 100), message: "", type: NVActivityIndicatorType.ballRotate, fadeInAnimation: nil)
        let parameters: Parameters = [
            "language" : "\(Language.language)",
            "club_name" : UserDefaults.standard.object(forKey: "club_name") as! String
        ]
        print("\(Shared().webCall)getStripekey?club_name=\(UserDefaults.standard.object(forKey: "club_name") as! String)")
        Alamofire.request("\(Shared().webCall)getStripekey.php", method: .post, parameters: parameters)
            .responseJSON { response in
//                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()) {
//                    self.stopAnimating(nil)
//                }
                self.btnAddCredit.isEnabled=true
                switch response.result {
                case .success:
                    print("JSON::",response.result.value!)
                    if let jsonData = response.result.value as? [String:Any] {
                        let flag = JSON(jsonData["flag"]!).stringValue
                        if flag == "1"{
                            if let jsonStripe=jsonData["data"] as? [String:Any]{
                                self.txtDonation.text=""
                                self.txtNote.text=""
                                print("jsonStripe===============",JSON(jsonStripe["stripe_key"]!).stringValue)
                                let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                                let vc = storyBoard.instantiateViewController(withIdentifier: "PaymentSelectionVC") as! PaymentSelectionVC
                                vc.apiCallScreen="DonationScreen"
                                vc.donationScreenAmount=costVal
                                vc.donationScreenNotes=noteVal
                                vc.jsonStripeToken=JSON(jsonStripe["stripe_key"]!).stringValue
                                self.navigationController?.pushViewController(vc, animated: true)
                            } else{
                                Shared().showAlert(uIViewController: self, title: Shared().error, message: "Stripe token is not available")
                            }
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
