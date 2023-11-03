//
//  SelectClubVC.swift
//  CCSMembersApp
//
//  Created by Rajneesh on 19/06/20.
//  Copyright © 2020 Jaimin Patel. All rights reserved.
//

import UIKit
import SlideMenuControllerSwift
import ActionSheetPicker_3_0
import NVActivityIndicatorView
import Alamofire
import SwiftyJSON
import CoreData
import Firebase

class SelectClubVC: UIViewController,NVActivityIndicatorViewable {
    @IBOutlet weak var constraintsSearchBarTop: NSLayoutConstraint!
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var clubFullView: UIView!
    @IBOutlet weak var clubView: UIView!
    @IBOutlet weak var btnLoginWidth: NSLayoutConstraint!
    @IBOutlet weak var btnLoginHeight: NSLayoutConstraint!
    
    @IBOutlet weak var btnClose: UIButton!
    @IBOutlet weak var selectClubLabel: UILabel!
    @IBOutlet weak var dropdownHeight: NSLayoutConstraint!
    
    @IBOutlet weak var languageViewWidth: NSLayoutConstraint!
    @IBOutlet weak var languageViewHeight: NSLayoutConstraint!
    @IBOutlet weak var logoHeight: NSLayoutConstraint!
    
    @IBOutlet weak var btnBack: UIButton!
    
    @IBOutlet weak var constraintsSelectClubBottom: NSLayoutConstraint!
    @IBOutlet weak var constraintEnterPasscodeHeight: NSLayoutConstraint!
    @IBOutlet weak var constraintMemberCode: NSLayoutConstraint!
    @IBOutlet weak var constraintEnterPasscodeCenterY: NSLayoutConstraint!
    
    @IBOutlet weak var logotopConstraints: NSLayoutConstraint!
    @IBOutlet weak var btnSelectClubOutlet: UIButton!
    @IBOutlet weak var imgBackground: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var btnLoginOutlet: UIButton!
    @IBOutlet weak var addClubView: UIView!
    @IBOutlet weak var txtAddClub: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var addclubLabel: UILabel!
    @IBOutlet weak var addClubButton: UIButton!
    @IBOutlet weak var selectClubView: UIView!
    @IBOutlet weak var noClubLabel: UILabel!
    
    var selectedIndex :Int = -1
    var clubListing=[clubList]()
    var selectedClub : clubList?
    var clubfilteredData=[clubList]()
    var backBtn:String=""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.searchBar.delegate=self
        self.searchBar.showsCancelButton=false
        UIBarButtonItem.appearance(whenContainedInInstancesOf:[UISearchBar.self]).tintColor = UIColor(named: "statusBackgroundColour")
        UIBarButtonItem.appearance(whenContainedInInstancesOf:[UISearchBar.self]).title = "Cancel".localized
        self.navigationController?.navigationBar.isHidden=true
        selectClubLabel.text = "select_club".localized
        btnClose.setTitle("close".localized, for: .normal)
        addclubLabel.text = "Add Club".localized
        addClubButton.setTitle("Add_New_Club".localized, for: .normal)
        addClubButton.titleLabel?.font = setCustomFont.MontserratSemiBoldWith(size: 16.0).withWeight(UIFont.Weight(600))
        submitButton.setTitle("SUBMIT".localized, for: .normal)
        tableView.dataSource=self
        tableView.delegate=self
        txtAddClub.delegate = self
        btnLoginOutlet.shadowColor(color: UIColor.black.withAlphaComponent(0.2), border: 1.0, offHeight: 3.0)
        noClubLabel.text = "No clubs found".localized
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        if let textField = searchBar.value(forKey: "searchField") as? UITextField {
            textField.backgroundColor = UIColor.white
            textField.borderColors = .white
            //textField.font = myFont
            //textField.textColor = myTextColor
            //textField.tintColor = myTintColor
            // And so on...
            
            let backgroundView = textField.subviews.first
            backgroundView?.borderColors = .white
            if #available(iOS 11.0, *) { // If `searchController` is in `navigationItem`
                backgroundView?.backgroundColor = UIColor.white.withAlphaComponent(0.3) //Or any transparent color that matches with the `navigationBar color`
                backgroundView?.subviews.forEach({ $0.removeFromSuperview() }) // Fixes an UI bug when searchBar appears or hides when scrolling
            }
            backgroundView?.layer.cornerRadius = 10.5
            backgroundView?.layer.masksToBounds = true
            //Continue changing more properties...
        }
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView=false
        self.view.addGestureRecognizer(tap)
        getclubListAPI()
        let flexible = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: self, action: nil)
        let toolbarDone = UIToolbar.init()
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done".localized, style: .done, target: self, action: #selector(dismissKeyboard))//UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissKeyboard))
        toolbarDone.sizeToFit()
        toolbarDone.items =  [flexible,done]
        
        
        self.clubView.isHidden=true
        self.clubFullView.isHidden=true
        
       
        
        //self.tableViewHeight.constant=0
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.removeNavigationBarItem()
        //        self.clubSelection=["demo"]
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
        
    }
    
    @IBAction func btnBack(_ sender: UIButton) {
        if let _ : AnyObject = UserDefaults.standard.object(forKey: "user_id") as AnyObject? {
            self.goHomeScreen()
        }
    }
    
    
    @IBAction func closeButtonClicked(_ sender: UIButton) {
        clubFullView.isHidden = true
        clubView.isHidden = true
    }
    @IBAction func cancelAction(_ sender: UIButton) {
        addClubView.isHidden = true
    }
    @IBAction func submitButtonAction(_ sender: UIButton) {
        var member_id: String = String()
        var club_code: String = txtAddClub.text ?? ""
        if let memberId : String = UserDefaults.standard.object(forKey: "member_id") as? String {
            member_id = memberId
        }
        if club_code == "" {
        Shared().showAlert(uIViewController: self, title: Shared().error, message: "Please add code received from your club".localized)
        }
        addclubApi(member_id: member_id, club_code: club_code)
    }
    @IBAction func addClubAction(_ sender: UIButton) {
        addClubView.alpha = 0
        addClubView.isHidden = false
        UIView.animate(withDuration: 0.3) {
            self.addClubView.alpha = 1
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
    
    
    func setupLanguage(){
        self.btnSelectClubOutlet.setTitle("Select Your Club".localized, for: .normal)
        self.btnLoginOutlet.setTitle("SUBMIT".localized, for: .normal)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
        self.view.resignFirstResponder()
    }
    
    override func viewDidLayoutSubviews() {
        self.languageViewHeight.constant=75
        self.logoHeight.constant=85
        self.dropdownHeight.constant=30
        
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
        
    }
    
    @IBAction func btnSelectClub(_ sender: UIButton) {
        self.clubView.isHidden=false
        self.clubFullView.isHidden=false
        self.tableView.reloadData()
        //self.tableViewHeight.constant=self.tableView.contentSize.height
        if self.view.frame.size.height >= 812{
         //   self.constraintsSearchBarTop.constant=44
        } else{
            
        }
        
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
        
        if (selectedIndex == -1) {
            Shared().showAlert(uIViewController: self, title: Shared().error, message: "Please select your club.".localized)
        } else if selectedClub?.club_approve != "1" {
            Shared().showAlert(uIViewController: self, title: Shared().error, message: "awaiting_club_approval".localized)
        } else {
            clubAccessAPI()
        }
        
        //        macAddress:Shared().getWifi()
    }
    
    func setupLoginData(cart_count:String,domain:String,email:String,first_name:String,memberno:String,userGroup:String,user_id:String,workStation:String,image:String,user_type:String, userNickName: String? = ""){
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

extension SelectClubVC:UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate{
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
        self.selectedClub = clubData
        self.btnSelectClubOutlet.setTitle(clubData.club_name, for: .normal)
        selectedIndex = indexPath.row
        self.clubFullView.isHidden=true
        self.clubView.isHidden=true
        self.view.endEditing(true)
    }
}


//login_code : XPE6BJ,club_name = demo ,member_no = AH3 ,device_id ,platform
extension SelectClubVC{
    func clubAccessAPI(){
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
                                self.setupLoginData(cart_count: JSON(jsonData["cart_count"] as? String ?? "").stringValue, domain:JSON(jsonDict["domain"]!).stringValue,email:JSON(jsonDict["email"] as? String ?? "").stringValue,first_name:JSON(jsonDict["first_name"] as? String ?? "").stringValue,memberno:JSON(jsonDict["memberno"] as? String ?? "").stringValue,userGroup:JSON(jsonDict["userGroup"] as? String ?? "").stringValue,user_id:JSON(jsonDict["user_id"] as? String ?? "").stringValue,workStation:JSON(jsonDict["workStation"] as? String ?? "").stringValue,image:JSON(jsonDict["image"]!).stringValue,user_type:JSON(jsonDict["user_type"] as? String ?? "").stringValue,userNickName: JSON(jsonDict["member_nickname"] as? String ?? "").stringValue)

                                print("NickName-\(JSON(jsonDict["member_nickname"]!).stringValue)")
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
    func loginAPI(){
        startAnimating(CGSize(width: 100, height: 100), message: "", type: NVActivityIndicatorType.ballRotate, fadeInAnimation: nil)
       
        let clubData=self.clubListing[selectedIndex]
        
        let parameters: Parameters = [
            "language" : "\(Language.language)",
            "club_name" : clubData.club_name,
            "login_code" : clubData.login_code,
            "member_no" : clubData.member_no,
            "platform" : Shared().device_platform,
            "device_id" : UIDevice.current.identifierForVendor!.uuidString,
            "fcm_key" : deviceTokenString,
            //                "macAddress" : macAddress,
        ]
        print("parameters: ", parameters)
        
        Alamofire.request("\(Shared().webCall)loginApi.php", method: .post, parameters: parameters)
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
                                self.setupLoginData(cart_count: JSON(jsonData["cart_count"]!).stringValue, domain:JSON(jsonDict["domain"]!).stringValue,email:JSON(jsonDict["email"]!).stringValue,first_name:JSON(jsonDict["first_name"]!).stringValue,memberno:JSON(jsonDict["memberno"]!).stringValue,userGroup:JSON(jsonDict["userGroup"]!).stringValue,user_id:JSON(jsonDict["user_id"]!).stringValue,workStation:JSON(jsonDict["workStation"]!).stringValue,image:JSON(jsonDict["image"]!).stringValue,user_type:JSON(jsonDict["user_type"]!).stringValue,userNickName: JSON(jsonDict["member_nickname"]!).stringValue)
                                print("NickName-\(JSON(jsonDict["member_nickname"]!).stringValue)")
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
    func getclubListAPI(){
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
                                }
                                if self.clubListing.count <= 0 {
                                    self.selectClubView.isHidden = true
                                    self.noClubLabel.isHidden = false
                                } else {
                                  //  self.selectClubView.isHidden = false
                                    self.noClubLabel.isHidden = true
                                }
                            }
                            
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                            }
                            
                        } else{
                            if self.clubListing.count <= 0 {
                                self.selectClubView.isHidden = true
                                self.noClubLabel.isHidden = false
                            } else {
                               // self.selectClubView.isHidden = false
                                self.noClubLabel.isHidden = true
                            }
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
    func addclubApi(member_id: String,club_code: String){
        startAnimating(CGSize(width: 100, height: 100), message: "", type: NVActivityIndicatorType.ballRotate, fadeInAnimation: nil)
        
        //  let clubData=self.clubListing[selectedIndex]
        
        let parameters: Parameters = [
            "language" : "\(Language.language)",
            "member_id" : member_id,
            "club_code" : club_code
        ]
        print("parameters: ", parameters)
        
        Alamofire.request("\(Shared().webCall)addClubMember.php", method: .post, parameters: parameters)
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
//                            if let jsonDict = jsonData["data"] as? [String:Any]{
//                            }
                            let message : String = JSON(jsonData["message"]!).stringValue
                            Shared().showAlert(uIViewController: self, title: "CCS Members App", message: message)
                            self.addClubView.isHidden = true
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

extension SelectClubVC:UISearchBarDelegate{
    
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
          //  self.tableViewHeight.constant=self.tableView.contentSize.height
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
            //self.tableViewHeight.constant=self.tableView.contentSize.height
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
           // self.tableViewHeight.constant=self.tableView.contentSize.height
        }
    }
}
