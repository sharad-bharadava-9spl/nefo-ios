//
//  AddNewClubVC.swift
//  CCSMembersApp
//
//  Created by Vishnu Chippa on 11/04/22.
//  Copyright © 2022 Jaimin Patel. All rights reserved.
//

import UIKit
import UIKit
import SlideMenuControllerSwift
import ActionSheetPicker_3_0
import NVActivityIndicatorView
import Alamofire
import SwiftyJSON
import CoreData
import Firebase

class AddNewClubVC: UIViewController, NVActivityIndicatorViewable {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var btnAddNew: UIButton!
    
    @IBOutlet weak var popUpView: UIView!
    
    @IBOutlet weak var poplbl: UILabel!
    @IBOutlet weak var firstview: UIView!
    @IBOutlet weak var lblActiveClub: UILabel!
    @IBOutlet weak var okBtnObj: UIButton!
    @IBOutlet weak var cancelBtnObj: UIButton!
    @IBOutlet weak var lblWelcomeTitle: UILabel!
    @IBOutlet weak var lblWelcomeDescription: UILabel!
    
    var nxtIndex = Int()
    
    var popupType = Int()
    var clubId = String()
    var fromNotification = false

    var item1:UIBarButtonItem?

    var selectedIndex :Int = -1
    var clubListing=[clubList]()
    var selectedClub : clubList?
    var clubfilteredData=[clubList]()
    var backBtn:String=""
    var selectedClubStr = ""
    
    
    
    var isFromLogin = true
    var notifClub = String()
    var isOpenPopupFromNotificationClicked = false

    override func viewDidLoad() {
        super.viewDidLoad()
        lblActiveClub.text = "Active_Clubs".localized
        okBtnObj.setTitle("Ok".localized, for: .normal)
        cancelBtnObj.setTitle("Cancel".localized, for: .normal)
        btnAddNew.setTitle("Add_New_Club".localized, for: .normal)
        btnAddNew.titleLabel?.font = setCustomFont.MontserratSemiBoldWith(size: 16.0).withWeight(UIFont.Weight(600))
        tableView.dataSource=self
        tableView.delegate=self
        popUpView.isHidden = true
        
        lblWelcomeTitle.text = "welcome_to_the_ccs_member_app".localized
        lblWelcomeDescription.text = "to_get_started".localized
        
        self.setNavigationBarItem()
        self.setLeftAlignTitleView(font: UIFont(name: "ProductSans-Bold", size: 17)!, text: "My_Clubs".localized.uppercased(), textColor: .white)
       
        
       
        
//        if isFromLogin{
//            self.title = "My_Clubs".localized.uppercased()
//            self.setNavigationBarItem()
//           // CommonFunctions.setLeftBarButtonItemWith(image: UIImage(), action: #selector(backButtonAction), view: self)
//           // Shared().showAlert(uIViewController: self, title: "", message: "We will show welcome message here with some instructions")
//        }else{
//            self.setNavigationBarItem()
//            self.setLeftAlignTitleView(font: UIFont(name: "ProductSans-Bold", size: 17)!, text: "My_Clubs".localized.uppercased(), textColor: .white)
//        }
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.removeObserver()
        self.addObserver()
    }
    deinit {
        self.removeObserver()
    }
    
    //Add Observer
    func addObserver(){
        NotificationCenter.default.addObserver(self, selector: #selector(self.showAlertForPreRegistartionSucessFully(_:)), name: NSNotification.Name(rawValue: NotificationName().PreRegistrationSucessFully), object: nil)
    }
    
    //Remove Observer
    func removeObserver(){
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: NotificationName().PreRegistrationSucessFully), object: nil)
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        popUpView.isHidden = true
        selectedClubStr = UserDefaults.standard.value(forKey: "club_name") as? String ?? ""
        getclubListAPI()
        self.navigationController?.navigationBar.isHidden=false
        navigationController?.navigationBar.barTintColor = UIColor.white//UIColor(named: "backgroundViewColor")
        navigationController?.navigationBar.backgroundColor = .clear
        navigationController?.navigationBar.topItem?.title = "My_Clubs".localized.uppercased()
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.red, NSAttributedString.Key.font: UIFont(name: "ProductSans-Bold", size: 17)!]
        navigationItem.leftBarButtonItem?.tintColor = UIColor(named: "NavigationText")!
//        var imageShopingCart = Shared().imageWithImage(image: UIImage(named: "Shoping_Cart")!, scaledToSize: CGSize(width: 23, height: 23))
//        imageShopingCart = imageShopingCart.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
//
//        var imageNotification = Shared().imageWithImage(image: UIImage(named: "notification")!, scaledToSize: CGSize(width: 23, height: 23))
//        imageNotification = imageNotification.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
//        if targetName != Shared().cannibisAppName {
//        let btn1 = UIButton(type: .custom)
//        btn1.setImage(imageShopingCart, for: .normal)
//        btn1.frame = CGRect(x: 0, y: 0, width: 28, height: 28)
//        btn1.addTarget(self, action:#selector(self.cartRedirection), for: .touchUpInside)
//        item1 = UIBarButtonItem(customView: btn1)
//        item1?.removeBadge()
//        }
//        let btn2 = UIButton(type: .custom)
//        btn2.setImage(imageNotification, for: .normal)
//        btn2.frame = CGRect(x: 0, y: 0, width: 28, height: 28)
//        let item2 = UIBarButtonItem(customView: btn2)
//        if targetName != Shared().cannibisAppName {
//        self.navigationItem.setRightBarButtonItems([item1!,item2], animated: true)
//        } else {
//            self.navigationItem.setRightBarButtonItems([item2], animated: true)
//        }
//        if let cartCount = UserDefaults.standard.object(forKey: "Badge_cart_count") as? String{
//            self.item1?.removeBadge()
//            if cartCount != "0"{
//                self.item1?.addBadge(number: Int(cartCount)!)
//            } else{
//                self.item1?.removeBadge()
//            }
//        } else{
//
//        }
//

    }
    
    @objc func showAlertForPreRegistartionSucessFully(_ notification: NSNotification) {
        if let msg = notification.userInfo?["txt"] as? String {
            self.showAlert(title: "", message: msg)
        }
        
    }
    
    @IBAction func crossTapped(_ sender: UIButton){
        popUpView.isHidden = true
        self.firstview.isHidden = true
    }
    
    
    @IBAction func okTapped(_ sender: UIButton){
        popUpView.isHidden = true
        self.firstview.isHidden = true
        if popupType == 1 {
            let clubData=self.clubListing[nxtIndex]
            self.selectedClub = clubData
            self.selectedIndex = nxtIndex
            if selectedClub?.club_approve != "1" {
                Shared().showAlert(uIViewController: self, title: Shared().error, message: "awaiting_club_approval".localized)
            } else {
                clubAccessAPI(index: nxtIndex)
            }
        } else {
            self.deleteApi(clubeCode: clubId)
        }
        
        
    }
    
    @IBAction func cancelTapped(_ sender: UIButton){
        popUpView.isHidden = true
        self.firstview.isHidden = true
    }
    
    func showbackButton(){
        if isFromLogin &&  !clubListing.isEmpty{
            CommonFunctions.setLeftBarButtonItemWith(image: #imageLiteral(resourceName: "BackArrow"), action: #selector(backButtonAction), view: self)
            
        }
    }
    
    @objc func cartRedirection(){
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "CartScreenVC") as! CartScreenVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @objc func backButtonAction(){
        slideMenuController()?.toggleLeft()
        
        print("Menuhh")
//        if clubListing.isEmpty{
//            return
//        }
//        self.navigationController?.popViewController(animated: true)
    }
  
    func getclubListAPI(){
        self.clubListing.removeAll()
        self.clubfilteredData.removeAll()
        startAnimating(CGSize(width: 100, height: 100), message: "", type: NVActivityIndicatorType.ballRotate, fadeInAnimation: nil)
        var  member_id: String = String()
        if let memberId : String = UserDefaults.standard.object(forKey: "member_id") as? String {
            member_id = memberId
        }
        let parameters: Parameters = [
            "language" : "\(Language.language)",
            "member_id" : member_id
        ]
        print("parameters: ", parameters)
        
        Alamofire.request("\(Shared().webCall)clubMemberList.php", method: .post, parameters: parameters)
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
                            if let jsonDict = jsonData["data"] as? [[String:Any]]{
                                let jsonIs = JSON(jsonDict)
                                for item in 0..<jsonIs.count{
                                    let arrObj=clubList(json: jsonIs[item])
                                    self.clubListing.append(arrObj)
                                    self.clubfilteredData.append(arrObj)
                                    if jsonIs[item]["club_approve"].boolValue{
                                        self.clubAddIntoFirebase(dict: jsonIs[item])
                                    }
                                }
                                
                            }
                            
                            DispatchQueue.main.async {
                               // self.showbackButton()
                                self.selectedIndex = self.clubListing.firstIndex(where: {$0.club_name == self.selectedClubStr}) ?? -1
                                self.firstview.isHidden = true
                                self.tableView.reloadData()
                            }
                            
                        } else{
                            let message : String = JSON(jsonData["message"]!).stringValue
                            self.firstview.isHidden = false
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
    
    func clubAddIntoFirebase(dict:JSON){
        /*
        let message=Messages.init(type: "text", content: "", owner: .sender,timestamp: 0, sendername: dict["club_name"].stringValue, senderProfile: "", recname: appDelegateShared.nameU, recProfile: "", un_read:"0", fromId: dict["club_code"].stringValue, toId: MEMBER_ID,isBlockedYou: false,isBlockedByYou: false, blockByUser: "")
        
        Messages.sendMessage(isFromClubChat:true,type: "text", message: message, toID: MEMBER_ID, fromId: dict["club_code"].stringValue, sendername: dict["club_name"].stringValue, senderProfile: "", recname: appDelegateShared.nameU, recProfile: "", imageUrl:"") { (_) in
                //self.lastMsg()
            print("Sucessfully record add")
        }*/
        Messages.addClubDataFirstTime(dict: dict)
    }
    
    @IBAction func btnAddNew(sender:UIButton){
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "CreateNewClubVC") as! CreateNewClubVC
        vc.completionHandler = { [weak self] message in
            if let weakSelf = self {
                ///use dataFiltro here
                let storyBoard = UIStoryboard(name: "Common", bundle: nil)
                let nextVC = storyBoard.instantiateViewController(withIdentifier: "SnackBarVC") as! SnackBarVC
                nextVC.snackBarMsg = "\(message)"
                //                                nextVC.snackBarColor = "#51a351" // Green color
                nextVC.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
                weakSelf.present(nextVC, animated: true, completion: nil)
                
            }
        }
        self.navigationController?.pushViewController(vc, animated: true)

    }

}

extension AddNewClubVC : UITableViewDelegate , UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.clubListing.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell=tableView.dequeueReusableCell(withIdentifier: "clubCell") as! clubCell
        let clubData=self.clubListing[indexPath.row]
        cell.lblClubName.text=clubData.shortName
        if clubData.club_address == "" {
            cell.lblCity.isHidden = true
        } else {
            cell.lblCity.isHidden = false
        }
        cell.lblCity.text = "\(clubData.club_state), \(clubData.club_country)"
       // cell.lblTime.text = "Registered_in".localized + Helper.convertDate(clubData.club_registeredDate)
        cell.selectionStyle = .none
        print("bannd-\(clubData.usergroup)")
        cell.btnCheck.setTitle("", for: .normal)
        cell.delteBtn.addTarget(self, action: #selector(deleteClub), for: .touchUpInside)
        cell.delteBtn.tag = indexPath.row
        if selectedIndex == indexPath.row{
            cell.btnCheck.isHidden = false
            cell.btnCheck.backgroundColor = UIColor(hexString: "#33FF99")
            cell.btnCheck.setImage(UIImage(named: "check"), for: .normal)
            cell.mainView.backgroundColor = UIColor(hexString: "#110F1D")
            cell.mainView.borderColors = UIColor(hexString: "#33FF99")
            cell.lblClubName.textColor = UIColor(hexString: "#EBEDEF")
            cell.lblCity.textColor = UIColor(hexString: "#EBEDEF")
            cell.lblTime.textColor = UIColor(hexString: "#A7B8CD")
            cell.borderView.backgroundColor = UIColor(hexString: "#33FF99")
            cell.delteBtn.isHidden = true
            cell.lblTime.text = "Registered_in".localized + Helper.convertDate(clubData.club_registeredDate)
            cell.lblTime.textColor = UIColor(hexString: "#A7B8CD")
            cell.banndImg.isHidden = true
            
            //Shown Notification club wise click event
            cell.btnNotification.addTarget(self, action: #selector(openNotificationScreenClubWise), for: .touchUpInside)
            cell.btnNotification.tag = indexPath.row
        }else if clubData.usergroup == "7" || clubData.usergroup == "8"{
            cell.delteBtn.isHidden = false
            cell.btnCheck.isHidden = true
            cell.btnCheck.backgroundColor = UIColor(hexString: "#D9DEE3")
            cell.btnCheck.setImage(nil, for: .normal)
            cell.mainView.backgroundColor = UIColor(hexString: "#5C3034")
            cell.mainView.borderColors = UIColor(hexString: "#FE5815")
            cell.lblClubName.textColor = UIColor(hexString: "#EBEDEF")
            cell.lblCity.textColor = UIColor(hexString: "#EBEDEF")
            cell.lblTime.textColor = UIColor(hexString: "#FFFFFF")
            cell.borderView.backgroundColor = UIColor(hexString: "#FE5815")
            if clubData.usergroup == "7" {
                cell.lblTime.text = "Banned".localized + Helper.convertDate(clubData.club_registeredDate)
            }else{
                cell.lblTime.text = "Deleted".localized + Helper.convertDate(clubData.club_registeredDate)
            }
            cell.lblTime.textColor = UIColor(hexString: "#FE5815")
            cell.banndImg.isHidden = false
        } else {
            cell.delteBtn.isHidden = false
            cell.btnCheck.backgroundColor = UIColor(hexString: "#D9DEE3")
            cell.btnCheck.setImage(nil, for: .normal)
            cell.mainView.backgroundColor = UIColor(hexString: "#2A3E56")
            cell.mainView.borderColors = UIColor(hexString: "#78899D")
            cell.lblClubName.textColor = UIColor(hexString: "#EBEDEF")
            cell.lblCity.textColor = UIColor(hexString: "#EBEDEF")
            cell.lblTime.textColor = UIColor(hexString: "#FFFFFF")
            cell.borderView.backgroundColor = UIColor(hexString: "#78899D")
            cell.lblTime.text = "Registered_in".localized + Helper.convertDate(clubData.club_registeredDate)
            cell.lblTime.textColor = UIColor(hexString: "#A7B8CD")
            cell.banndImg.isHidden = true
            
            //Shown Notification club wise click event
            cell.btnNotification.addTarget(self, action: #selector(openNotificationScreenClubWise), for: .touchUpInside)
            cell.btnNotification.tag = indexPath.row
        }
        
        //Shown Notification club wise click event
        if Int(clubData.unread_count ?? "0") ?? 0 > 0 && clubData.club_approve == "1" {
            cell.viewNotificationCount.isHidden = false
            cell.lblNotificationCount.text = clubData.unread_count
        }else{
            cell.viewNotificationCount.isHidden = true
            cell.lblNotificationCount.text = ""
        }
        
        //Qr code related check
        if clubData.qr_code == "" {
            cell.viewBarcode.isHidden = true
        } else {
            cell.viewBarcode.isHidden = false
            cell.btnBarcode.tag = indexPath.row
            cell.btnBarcode.addTarget(self, action: #selector(openQrCode), for: .touchUpInside)
            
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let clubData=self.clubListing[indexPath.row]
        if clubData.club_address != "" {
            UserDefaults.standard.set(true, forKey: "ShowMap")
        } else {
            UserDefaults.standard.set(false, forKey: "ShowMap")
        }
        let cell = tableView.cellForRow(at: indexPath) as! clubCell
        if cell.btnCheck.backgroundColor == UIColor(hexString: "#33FF99"){
            print("Club already selected")
            self.goHomeScreen(true)
        }else{
            self.isOpenPopupFromNotificationClicked = false
            self.popupType = 1
            self.firstview.isHidden = false
            popUpView.isHidden = false
            nxtIndex = indexPath.row
            poplbl.text = "alert_select_active_club".localized + " \(clubData.shortName)?"
            
        }
//        let clubData=self.clubListing[indexPath.row]
//        self.selectedClub = clubData
//        self.selectedIndex = indexPath.row
//        if selectedClub?.club_approve != "1" {
//            Shared().showAlert(uIViewController: self, title: Shared().error, message: "Awaiting club approval".localized)
//        } else {
//            clubAccessAPI(index: indexPath.row)
//        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 95
    }
    
    
    
    @objc func deleteClub(_ sender: UIButton){
        self.isOpenPopupFromNotificationClicked = false
        self.popupType = 2
        let clubData=self.clubListing[sender.tag]
        self.firstview.isHidden = false
        popUpView.isHidden = false
        self.clubId = self.clubListing[sender.tag].club_code
        poplbl.text = "alert_delete_club".localized + " \(clubData.club_name)?"
    }
    
    //Open Qr code
        @objc func openQrCode(_ sender: UIButton){
            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyBoard.instantiateViewController(withIdentifier: "OpenQrCodeVC") as! OpenQrCodeVC
            vc.imgUrl = self.clubListing[sender.tag].qr_code
            self.navigationController?.pushViewController(vc, animated: true)
        }
    
    
    //Open Notifications screen club wise
    @objc func openNotificationScreenClubWise(_ sender: UIButton){
        if self.clubListing[sender.tag].club_approve != "1" {
            Shared().showAlert(uIViewController: self, title: Shared().error, message: "awaiting_club_approval".localized)
        } else {
            let clubData=self.clubListing[sender.tag]
            if clubData.club_address != "" {
                UserDefaults.standard.set(true, forKey: "ShowMap")
            } else {
                UserDefaults.standard.set(false, forKey: "ShowMap")
            }
            let cell = tableView.cellForRow(at: IndexPath(row: sender.tag, section: 0)) as! clubCell
            if cell.btnCheck.backgroundColor == UIColor(hexString: "#33FF99"){
                print("Club already selected")
                let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyBoard.instantiateViewController(withIdentifier: "NotificationVC") as! NotificationVC
                vc.unreadStatus = true
                vc.userID = self.clubListing[sender.tag].club_user_id
                vc.clubName = self.clubListing[sender.tag].club_name
                self.navigationController?.pushViewController(vc, animated: true)
            }else{
                self.isOpenPopupFromNotificationClicked = true
                self.popupType = 1
                self.firstview.isHidden = false
                popUpView.isHidden = false
                nxtIndex = sender.tag
                poplbl.text = "alert_select_active_club".localized + " \(clubData.shortName)?"
            }
        }
        
    }
    
    
    
    
    func deleteApi(clubeCode: String){
        
        var  member_id: String = String()
        if let memberId : String = UserDefaults.standard.object(forKey: "member_id") as? String {
            member_id = memberId
        }
        
        let parameters: Parameters = [
            "member_id" : member_id,
            "club_code" : clubeCode,
            "language" : "\(Language.language)",
            "macAddress" : Shared().getWifi()
        ]
        
        
        Alamofire.request("\(Shared().webCall)deleteClubMember.php", method: .post,parameters: parameters).responseJSON { responce in
            switch responce.result {
            case .success :
                print(responce.result)
                self.getclubListAPI()
            case .failure :
                print(responce.error.debugDescription)
            }
        }
        
    }
    
}

extension AddNewClubVC{
    func clubAccessAPI(index:Int){
        startAnimating(CGSize(width: 100, height: 100), message: "", type: NVActivityIndicatorType.ballRotate, fadeInAnimation: nil)
       
        let clubData=self.clubListing[selectedIndex]
        var  member_id: String = String()
        if let memberId : String = UserDefaults.standard.object(forKey: "member_id") as? String {
            member_id = memberId
        }
        
        let parameters: Parameters = [
            "club_name" : clubData.club_name,
            "member_id" : member_id,
            "language" : "\(Language.language)",
            //"login_code" : clubData.login_code,
            //"member_no" : clubData.member_no,
            "platform" : Shared().device_platform,
            "device_id" : UIDevice.current.identifierForVendor!.uuidString,
            "fcm_key" : deviceTokenString,
            "macAddress" : "hhddhf",//Shared().getWifi(),
        ]
        print("parameters: ", parameters)
        
        Alamofire.request("\(Shared().webCall)clubAccess.php", method: .post, parameters: parameters)
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
                                let menuOption = JSON(jsonDict["showmenu_option"]).boolValue
                                let dispenseOption = JSON(jsonDict["dispensmenu_option"]).boolValue
                                setToUserDefaultForKey(menuOption as AnyObject, key: key_isMenuShow)
                                setToUserDefaultForKey(dispenseOption as AnyObject, key: key_isDispensShow)
                                self.setupLoginData(cart_count: JSON(jsonData["cart_count"] as? String ?? "").stringValue, domain:JSON(jsonDict["domain"] as? String ?? "").stringValue,email:JSON(jsonDict["email"] as? String ?? "").stringValue,first_name:JSON(jsonDict["first_name"] as? String ?? "").stringValue,memberno:JSON(jsonDict["memberno"] as? String ?? "").stringValue,userGroup:JSON(jsonDict["userGroup"] as? String ?? "").stringValue,user_id:JSON(jsonDict["user_id"] as? String ?? "").stringValue,workStation:JSON(jsonDict["workStation"] as? String ?? "").stringValue,image:JSON(jsonDict["image"] as? String ?? "").stringValue,user_type:JSON(jsonDict["user_type"] as? String ?? "").stringValue,userNickName: JSON(jsonDict["member_nickname"] as? String ?? "").stringValue)

                            }
                            
                            
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                            }
                        } else{
                            let message : String = JSON(jsonData["message"] as? String ?? "").stringValue
                            Shared().showAlert(uIViewController: self, title: Shared().error, message: message)
                        }
                    }
                    // })
                    break
                    
                case .failure(let error):
                    //alert.dismiss(animated: true, completion: {
                    let errorCode = error._code
                    if(errorCode == -1001 || errorCode == -1005 || errorCode == -1009) {
                        Shared().showAlert(uIViewController: self, title: "", message: error.localizedDescription)
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
    
    func setupLoginData(cart_count:String,domain:String,email:String,first_name:String,memberno:String,userGroup:String,user_id:String,workStation:String,image:String,user_type:String, userNickName: String? = ""){
        print("first_name",first_name)
        if let _ : AnyObject = UserDefaults.standard.object(forKey: "user_id") as AnyObject? {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
            }
            let id=user_id
            let allreadyExist = isExist(id:Int(user_id)!)
//            if allreadyExist == false{
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
                UserDefaults.standard.set(userNickName, forKey: "NickName")
                UserDefaults.standard.set(self.selectedClub?.club_name, forKey: "club_name")
                UserDefaults.standard.set(self.selectedClub?.club_name, forKey: "first_name")//For club_name
                Shared().firebaseProcess(visibility:"LOGIN")
            
            if self.isOpenPopupFromNotificationClicked{
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationName().SetParticularIndexInSideMenu), object: nil, userInfo: ["txt": "My_Clubs".localized])
                let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyBoard.instantiateViewController(withIdentifier: "NotificationVC") as! NotificationVC
                vc.unreadStatus = true
                vc.userID = self.clubListing[nxtIndex].club_user_id
                vc.clubName = self.clubListing[nxtIndex].club_name
                self.navigationController?.pushViewController(vc, animated: true)
            }else{
                self.goHomeScreen()
            }
                
            /*} else{
                self.view.endEditing(true)
                self.goHomeScreen(true)
//                Shared().showAlert(uIViewController: self, title: Shared().error, message: "Account already added".localized)
            }*/
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
            UserDefaults.standard.set(userNickName, forKey: "NickName")
            UserDefaults.standard.set(self.selectedClub?.club_name, forKey: "club_name")
            UserDefaults.standard.set(self.selectedClub?.club_name, forKey: "first_name")
            Shared().firebaseProcess(visibility:"LOGIN")
            
            if self.isOpenPopupFromNotificationClicked{
                let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyBoard.instantiateViewController(withIdentifier: "NotificationVC") as! NotificationVC
                vc.unreadStatus = true
                vc.userID = self.clubListing[nxtIndex].club_user_id
                vc.clubName = self.clubListing[nxtIndex].club_name
                self.navigationController?.pushViewController(vc, animated: true)
            }else{
                self.goHomeScreen()
            }
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

    func goHomeScreen(_ navigateToDashboard:Bool = false){
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
                if fromNotification == false {
                    appDelegateShared.selectedIndexMenu = 0
                    initialViewController = storyboard.instantiateViewController(withIdentifier: "MainMenuVC") as! MainMenuVC
                } else {
                    let cl = UserDefaults.standard.string(forKey: "club_name")
                    if notifClub == cl {
                        initialViewController = storyboard.instantiateViewController(withIdentifier: "NotificationVC") as! NotificationVC
                    } else {
                        appDelegateShared.selectedIndexMenu = 0
                        initialViewController = storyboard.instantiateViewController(withIdentifier: "MainMenuVC") as! MainMenuVC
                    }
                }
                
            }
        } else{
            if fromNotification == false {
                appDelegateShared.selectedIndexMenu = 0
                initialViewController = storyboard.instantiateViewController(withIdentifier: "MainMenuVC") as! MainMenuVC
            } else {
                let cl = UserDefaults.standard.string(forKey: "club_name")
                if notifClub == cl {
                    initialViewController = storyboard.instantiateViewController(withIdentifier: "NotificationVC") as! NotificationVC
                } else {
                    appDelegateShared.selectedIndexMenu = 0
                    initialViewController = storyboard.instantiateViewController(withIdentifier: "MainMenuVC") as! MainMenuVC
                }
            }
        }
        if navigateToDashboard == true {
            appDelegateShared.selectedIndexMenu = 0
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
    
}
