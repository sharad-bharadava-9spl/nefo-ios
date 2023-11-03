//
//  LanguageVC.swift
//  CCSMembersApp
//
//  Created by Jaimin Patel on 11/16/19.
//  Copyright © 2019 Jaimin Patel. All rights reserved.
//

import UIKit
import SlideMenuControllerSwift
import DropDown
import NVActivityIndicatorView

class LanguageVC: UIViewController {

    @IBOutlet weak var btnSaveOutlet: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var lblSelectedLanguage: UILabel!
    @IBOutlet weak var selectedLangauge: UILabel!
    @IBOutlet weak var langaugeDropSelecte: UIView!
    
    var languageArr=[[String:String]]()
    var item1:UIBarButtonItem?
    let dropDown = DropDown()
    var controller = UIViewController()
    var item2:UIBarButtonItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource=self
        self.tableView.delegate=self
        
        self.navigationController?.navigationBar.isHidden=false
        navigationController?.navigationBar.barTintColor = UIColor.white//UIColor(named: "backgroundViewColor")
        navigationController?.navigationBar.topItem?.title = "Language".localized.uppercased()
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(named: "NavigationText")!, NSAttributedString.Key.font: UIFont(name: "ProductSans-Bold", size: 17)!]
        navigationItem.leftBarButtonItem?.tintColor = UIColor(named: "NavigationText")!
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.setupLanguage()
        self.setupLanguageData()
        
        
        
        self.setNavigationBarItem()
        self.setLeftAlignTitleView(font: UIFont(name: "ProductSans-Bold", size: 17)!, text: "Language".localized.capitalized, textColor: .white)
        self.navigationController?.navigationBar.isHidden=false
        navigationController?.navigationBar.barTintColor = UIColor.white//UIColor(named: "backgroundViewColor")
        navigationController?.navigationBar.topItem?.title = "Language".localized.uppercased()
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(named: "NavigationText")!, NSAttributedString.Key.font: UIFont(name: "ProductSans-Bold", size: 17)!]
        navigationItem.leftBarButtonItem?.tintColor = UIColor(named: "NavigationText")!
        
        var imageShopingCart = Shared().imageWithImage(image: UIImage(named: "Shoping_Cart")!, scaledToSize: CGSize(width: 23, height: 23))
        imageShopingCart = imageShopingCart.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        
        var imageNotification = Shared().imageWithImage(image: UIImage(named: "Notification_icon")!, scaledToSize: CGSize(width: 23, height: 23))
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
        let notification_count = UserDefaults.standard.string(forKey: "notifcount") as? String ?? "0"
        if notification_count != "0" {
            self.item2?.addBadge(number: Int(notification_count ?? "") ?? 0)
        } else{
            self.item2?.removeBadge()
        }
        
        
    let item2 = UIBarButtonItem(customView: btn2)
        
        
        
        if targetName != Shared().cannibisAppName {
            if let _ = UserDefaults.standard.object(forKey: "club_name"){
                self.navigationItem.setRightBarButtonItems([item1!,item2], animated: true)
            }else{
                self.navigationItem.setRightBarButtonItems([item1!], animated: true)
            }
        } else {
            if let _ = UserDefaults.standard.object(forKey: "club_name"){
                self.navigationItem.setRightBarButtonItems([item2], animated: true)
            }
            
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
        self.slideMenuController()?.changeMainViewController(navVC, close: true)
    }
    
    @IBAction func langaugedropdown(_ sender: UIButton){
        setdropdown(vw: self.langaugeDropSelecte, dataSource: self.languageArr.compactMap({$0["name"]}) , dropDown: dropDown)
        dropDown.show()
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            self.selectedLangauge.text = item
           
        }
        
    }
    
    @objc func cartRedirection(){
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "CartScreenVC") as! CartScreenVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden=false
        navigationController?.navigationBar.barTintColor = UIColor.white//UIColor(named: "backgroundViewColor")
        navigationController?.navigationBar.topItem?.title = "Language".localized.uppercased()
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(named: "NavigationText")!, NSAttributedString.Key.font: UIFont(name: "ProductSans-Bold", size: 17)!]
        navigationItem.leftBarButtonItem?.tintColor = UIColor(named: "NavigationText")!
    }
    
    func setupLanguage(){
        navigationController?.navigationBar.topItem?.title = "Language".localized
        self.lblSelectedLanguage.text="choose_your_language".localized
        self.btnSaveOutlet.setTitle("Choose Language".localized, for: .normal)
    }
    
    func setupLanguageData(){
        self.languageArr.removeAll()
        if "\(Language.language)" == "en"{
            self.setupLanguageDict(lngName: "English".localized, img: "select_RadioButton")
            self.setupLanguageDict(lngName: "Spanish".localized, img: "unselect_RadioButton")
            self.selectedLangauge.text = "English".localized
        } else{
            self.setupLanguageDict(lngName: "English".localized, img: "unselect_RadioButton")
            self.setupLanguageDict(lngName: "Spanish".localized, img: "select_RadioButton")
            self.selectedLangauge.text = "Spanish".localized
        }
    }
    
    func setupLanguageDict(lngName:String,img:String){
        var objData=[String:String]()
        objData["name"]=lngName
        objData["img"]=img
        self.languageArr.append(objData)
    }
    
    @IBAction func btnSaveAction(_ sender: UIButton) {
        if selectedLangauge.text == "English".localized{
            Language.language = .en
        } else{
            Language.language = .es
        }
        self.setupLanguage()
        self.setupLanguageData()
        self.callAPIChangeLanguage()
    }

    
}

extension LanguageVC:UITableViewDataSource,UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.languageArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell=tableView.dequeueReusableCell(withIdentifier: "LanguageSelectionCell") as! LanguageSelectionCell
        let lngVal=self.languageArr[indexPath.row]
        cell.lblLanguageName.text=lngVal["name"]
        if lngVal["img"] == "select_RadioButton"{
            cell.btnSelectionOption.setImage(UIImage(named: (lngVal["img"])!), for: .normal)
        } else{
            cell.btnSelectionOption.setImage(UIImage(named: (lngVal["img"])!), for: .normal)
        }
      //  cell.selectedBackgroundView?.backgroundColor=UIColor.clear
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let lngVal=self.languageArr[indexPath.row]
        for item in 0..<self.languageArr.count{
            if self.languageArr[item] == lngVal{
                self.languageArr[item]["img"]="select_RadioButton"
            } else{
                self.languageArr[item]["img"]="unselect_RadioButton"
            }
        }
        self.tableView.reloadData()
    }
}

extension LanguageVC : NVActivityIndicatorViewable{
    func callAPIChangeLanguage() {
        startAnimating(CGSize(width: 100, height: 100), message: "", type: NVActivityIndicatorType.ballRotate, fadeInAnimation: nil)
        APIManager.callAPIRequest(Method: .post, url: "\(api_ChangeLanguage)", parameters: APIParam.changeLanguage.getParam(), headers: nil, showAlert: false, completion: { (jsonResult, msg) in
            logD(jsonResult)
            DispatchQueue.main.async {
                self.stopAnimating(nil)
            }
            if jsonResult["flag"].stringValue == "1"{
                self.setLanguageDataAfterAPICall()
                self.showAlert(title: "", message: jsonResult["message"].stringValue)
            }else{
                self.showAlert(title: "", message: jsonResult["message"].stringValue)
            }
                
        }) { (httpResponse, errorMsg) in
            //logD(httpResponse ?? "")
            //logD(errorMsg ?? "")
            DispatchQueue.main.async {
                self.stopAnimating(nil)
            }
            self.showAlert(title: "", message: errorMsg)
        }
    }
    
    func setLanguageDataAfterAPICall(){
        if  UserDefaults.standard.object(forKey: "user_id") as? String != nil  {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let appDelegate = UIApplication.shared.delegate as? AppDelegate
            let initialViewController = storyboard.instantiateViewController(withIdentifier: "MainMenuVC") as! MainMenuVC
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
        } else {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let appDelegate = UIApplication.shared.delegate as? AppDelegate
            let initialViewController = storyboard.instantiateViewController(withIdentifier: "AddNewClubVC") as! AddNewClubVC
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
}
