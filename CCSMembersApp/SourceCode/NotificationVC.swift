//
//  NotificationVC.swift
//  CCSMembersApp
//
//  Created by Jaimin Patel on 7/3/19.
//  Copyright © 2019 Jaimin Patel. All rights reserved.
//https://stackoverflow.com/questions/27182023/getting-the-difference-between-two-nsdates-in-months-days-hours-minutes-seconds

import UIKit
import Alamofire
import SwiftyJSON
import SlideMenuControllerSwift
import NVActivityIndicatorView
import SDWebImage
import libxml2

class NotificationVC: UIViewController,NVActivityIndicatorViewable {
  
    @IBOutlet weak var imgBackground: UIImageView!
   
    @IBOutlet weak var tableView: UITableView!
    
    var rowcount : Int = 1
    var offset:String="1"
    var item1:UIBarButtonItem?
    var listDict=[notificationList]()
    var userID = UserDefaults.standard.string(forKey: "user_id") ?? ""
    var clubName = UserDefaults.standard.object(forKey: "club_name") ?? ""
    var unreadStatus = false
  
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource=self
        self.tableView.delegate=self
        self.tableView.rowHeight=UITableView.automaticDimension
        self.tableView.estimatedRowHeight=100 // 300
        self.tableView.isHidden=true
        self.imgBackground.isHidden=true
        
        self.navigationController?.navigationBar.isHidden=false
        navigationController?.navigationBar.barTintColor = UIColor.white//UIColor(named: "backgroundViewColor")
        navigationController?.navigationBar.topItem?.title = "Notifications".localized.capitalized
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(named: "NavigationText")!, NSAttributedString.Key.font: UIFont(name: "ProductSans-Bold", size: 17)!]
        navigationItem.leftBarButtonItem?.tintColor = UIColor(named: "NavigationText")!//UIColor.white
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        UserDefaults.standard.set("0", forKey: "notifcount")
        UIApplication.shared.applicationIconBadgeNumber = 0
        self.imgBackground.image = UIImage(named : Shared().getImgName())
        self.setNavigationBarItem()
        self.setLeftAlignTitleView(font: UIFont(name: "ProductSans-Bold", size: 17)!, text: "Notifications".localized.capitalized	, textColor: .white)
        self.navigationController?.navigationBar.isHidden=false
        navigationController?.navigationBar.barTintColor = UIColor.white//UIColor(named: "backgroundViewColor")
        navigationController?.navigationBar.topItem?.title = "Notifications".localized.uppercased()
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
        if self.unreadStatus == false{
            let btn2 = UIButton(type: .custom)
            btn2.setImage(imageNotification, for: .normal)
            btn2.frame = CGRect(x: 0, y: 0, width: 28, height: 28)
            let item2 = UIBarButtonItem(customView: btn2)
            if targetName != Shared().cannibisAppName {
                self.navigationItem.setRightBarButtonItems([item1!], animated: true)
            } else {
                //self.navigationItem.setRightBarButtonItems([item2], animated: true)
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
        
//        
//        if #available(iOS 13.0, *) {
//            let statusBar = UIView(frame: (UIApplication.shared.keyWindow?.windowScene?.statusBarManager?.statusBarFrame)!)
//            statusBar.backgroundColor = UIColor(named: "statusBackgroundColour")!
//            UIApplication.shared.keyWindow?.addSubview(statusBar)
//        }
    }
    
    @objc func cartRedirection(){
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "CartScreenVC") as! CartScreenVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    override func viewDidAppear(_ animated: Bool) {
        
        self.navigationController?.navigationBar.isHidden=false
        navigationController?.navigationBar.barTintColor = UIColor.white//UIColor(named: "backgroundViewColor")
        navigationController?.navigationBar.topItem?.title = "Notifications".localized.uppercased()
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(named: "NavigationText")!, NSAttributedString.Key.font: UIFont(name: "ProductSans-Bold", size: 17)!]
        navigationItem.leftBarButtonItem?.tintColor = UIColor(named: "NavigationText")!
        self.listDict.removeAll()
        let when = DispatchTime.now() + 0.2
        DispatchQueue.main.asyncAfter(deadline: when) {
            self.notficationViewAPI(offset: "\(self.rowcount)")
        }
    }
    
    @objc func deleteNotification(sender:UIButton){
        let uiAlert = UIAlertController(title: Shared().title, message: "Are you sure you want to delete this notification?".localized , preferredStyle:.alert)
        self.present(uiAlert, animated: true, completion: nil)
        uiAlert.addAction(UIAlertAction(title: "No".localized, style: .default, handler: { action in }))
        uiAlert.addAction(UIAlertAction(title: "Yes".localized, style: .destructive, handler: { action in
            let notificationData=self.listDict[sender.tag]
            self.deleteNotificationView(notificationId: notificationData.notification_id)
            uiAlert.dismiss(animated: true, completion: nil)
        }))
    }
    
}

extension NotificationVC{
    
    func deleteNotificationView(notificationId:String){
        
        startAnimating(CGSize(width: 100, height: 100), message: "", type: NVActivityIndicatorType.ballRotate, fadeInAnimation: nil)
        let parameters: Parameters = [
            "language" : "\(Language.language)",
            "club_name" : self.clubName,
            "user_id" : self.userID,
            "notification_id" : notificationId,
            "macAddress" : Shared().getWifi(),
        ]
        print("params: ~~~ \(parameters)")
        print("\(Shared().webCall)deleteNotification?language=\(Language.language)&clubname=\(self.clubName)&user_id=\(self.userID)&macAddress=\(Shared().getWifi())&notification_id=\(notificationId)")
        Alamofire.request("\(Shared().webCall)deleteNotification.php", method: .post, parameters: parameters)
            .responseJSON { response in
//                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()) {
//                    self.stopAnimating(nil)
//                }
                switch response.result {
                case .success:
                    print("JSON::",response.result.value!)
                    if let jsonData = response.result.value as? [String:Any] {
                        let flag = JSON(jsonData["flag"]!).stringValue
                        if flag == "1"{
                            self.listDict.removeAll()
                            self.notficationViewAPI(offset: "\(self.rowcount)")
                            let message : String = JSON(jsonData["message"]!).stringValue
                            Shared().showAlert(uIViewController: self, title: "", message: message)
                        } else{
                            let message : String = JSON(jsonData["message"]!).stringValue
                            Shared().showAlert(uIViewController: self, title: Shared().error, message: message)
                        }
                    }
                    break
                    
                case .failure(let error):
                    self.stopAnimating()
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
    func notficationViewAPI(offset: String){
        startAnimating(CGSize(width: 100, height: 100), message: "", type: NVActivityIndicatorType.ballRotate, fadeInAnimation: nil)
        let parameters: Parameters = [
            "user_id" : self.userID,
            "member_id" : UserDefaults.standard.string(forKey: "member_id") ?? "",
            "language" : "\(Language.language)",
            "club_name" : self.clubName,
            "limit" : "",
            "offset" : offset,
            "platform" : Shared().device_platform,
            "device_id" : UIDevice.current.identifierForVendor!.uuidString
        ]
        //"unread_status":unreadStatus
        
//        print("\(Shared().webCall)notificationView?user_id=\(UserDefaults.standard.string(forKey: "user_id")!)&language=\(Language.language)&club_name=\(UserDefaults.standard.object(forKey: "club_name") as! String)&limit=\(5)&offset=\(offset)&platform=\(Shared().device_platform)&device_id=\(UIDevice.current.identifierForVendor!.uuidString)")
        Alamofire.request("\(Shared().webCall)notificationView.php", method: .post, parameters: parameters)
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
                            UIApplication.shared.applicationIconBadgeNumber=JSON("0").intValue
                            if let jsonDict = jsonData["data"] as? [[String:Any]]{
                                self.rowcount = jsonData["rowcount"] as? Int ?? 0
                                let jsonIs = JSON(jsonDict)
                                for item in 0..<jsonIs.count{
                                    let arrObj=notificationList(json: jsonIs[item])
                                    self.listDict.append(arrObj)
                                }
                                if self.listDict.count != 0{
                                    self.tableView.isHidden=false
                                    self.imgBackground.isHidden=false
                                    
                                }
                                self.tableView.isHidden=false
                                
                                checkRecordAvailable(for: self.tableView, count: self.listDict.count, ctrlRefresh: nil, targetController: self, detail: noDataAvaiableDetail.init(msg: "No data available".localized, img: nil, desc: ""), shouldShowCenter: true)


                                
                                    //self.tableView.reloadData()
                            }else{
                                self.tableView.isHidden=false
                                checkRecordAvailable(for: self.tableView, count: self.listDict.count, ctrlRefresh: nil, targetController: self, detail: noDataAvaiableDetail.init(msg: "No data available".localized, img: nil, desc: ""), shouldShowCenter: true)
                            }
                        } else{
                            checkRecordAvailable(for: self.tableView, count: self.listDict.count, ctrlRefresh: nil, targetController: self, detail: noDataAvaiableDetail.init(msg: "No data available".localized, img: nil, desc: ""), shouldShowCenter: true)

                            let message : String = JSON(jsonData["message"]!).stringValue
                            Shared().showAlert(uIViewController: self, title: Shared().error, message: message)
                        }
                    }
                    break
                    
                case .failure(let error):
                    checkRecordAvailable(for: self.tableView, count: self.listDict.count, ctrlRefresh: nil, targetController: self, detail: noDataAvaiableDetail.init(msg: "No data available".localized, img: nil, desc: ""), shouldShowCenter: true)
                    //alert.dismiss(animated: true, completion: {
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

extension NotificationVC:UITableViewDataSource,UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listDict.count
    }
    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "notificationCell") as! notificationCell
//        let dictData=listDict[indexPath.row]
//        if dictData.image == ""{
//            cell.imgViewHeight.constant=0
//            cell.imgBottomHeight.constant=0
//        } else{
//            cell.imgViewHeight.constant=200
//            cell.imgBottomHeight.constant=8
//            cell.imgView.sd_setImage(with: URL(string:dictData.image), placeholderImage: #imageLiteral(resourceName: "backgroundImg"))
//        }
//
//        cell.mainView.shadowColor(color: UIColor.black.withAlphaComponent(0.2), border: 1.2, offHeight: 1)
//       // cell.mainView.layer.cornerRadius = 10.0
//       // cell.mainView.layer.masksToBounds=true
//        cell.lblTitle.text=dictData.title
//        cell.lblDescription.text=dictData.description
//        cell.lblNotificationDate.text=Date().offsetFrom(date:Shared().convertStringToDate(strDate: dictData.create_at))
//        cell.btnTraceOutlet.tag=indexPath.row
//        cell.btnTraceOutlet.addTarget(self, action: #selector(self.deleteNotification(sender:)), for: .touchUpInside)
//
//        //cell.layoutIfNeeded()
//        return cell
//    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let dictData=listDict[indexPath.row]
        
        if dictData.image != "" {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "notificationCell") as! notificationCellNew
            cell.btnDelete.setTitle("", for: .normal)
            cell.btnDelete.setImage(UIImage(named: "P-1"), for: .normal)
            cell.btnColor.setTitle("", for: .normal)
            cell.imgView.sd_setImage(with: URL(string:dictData.image), placeholderImage: #imageLiteral(resourceName: "backgroundImg"))
            cell.lblTitle.text=dictData.title
            cell.lblDescription.text=dictData.description
            //cell.lblNotificationDate.text=Date().offsetFrom(date:Shared().convertStringToDate(strDate: dictData.create_at))
            cell.lblNotificationDate.text = getDisplayDate(date: dictData.create_at, dateFormat: dateFormateDisplayDash, displayFormat: dateTimeFromateDispalyWithOutAMPM).capitalized
            cell.btnColor.backgroundColor = setColorWithType(dictData.notification_type)
            
            cell.btnDelete.tag=indexPath.row
            cell.btnDelete.addTarget(self, action: #selector(self.deleteNotification(sender:)), for: .touchUpInside)
            
            if dictData.unread_flag{
                cell.mainView.backgroundColor =  UIColor(hexString: "212529")
            }else{
                cell.mainView.backgroundColor =  UIColor(hexString: "37404B")
            }
            return cell
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "notificationCellNew") as! notificationCellNew
            cell.btnDelete.setTitle("", for: .normal)
            cell.btnDelete.setImage(UIImage(named: "P-1"), for: .normal)
            cell.btnColor.setTitle("", for: .normal)
            
            cell.lblTitle.text=dictData.title
            cell.lblDescription.text=dictData.description
            cell.lblNotificationDate.text = getDisplayDate(date: dictData.create_at, dateFormat: dateFormateDisplayDash, displayFormat: dateTimeFromateDispalyWithOutAMPM) //Date().offsetFrom(date:Shared().convertStringToDate(strDate: dictData.create_at))
            cell.btnColor.backgroundColor = setColorWithType(dictData.notification_type)
        
            
            cell.btnDelete.tag=indexPath.row
            cell.btnDelete.addTarget(self, action: #selector(self.deleteNotification(sender:)), for: .touchUpInside)
            
            if dictData.unread_flag{
                cell.mainView.backgroundColor =  UIColor(hexString: "212529")
            }else{
                cell.mainView.backgroundColor =  UIColor(hexString: "37404B")
            }
            
            return cell
        }
        
        
        
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastElement = self.listDict.count - 1
        if indexPath.row == lastElement {
            if(self.listDict.count+1 < self.rowcount) {
                self.offset="\(self.listDict.count+1)"
                self.notficationViewAPI(offset: "\(self.listDict.count+1)")
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func setColorWithType(_ type : String)->UIColor{
        
        if type == "1"{
            return UIColor.addToCartView
        }
        
        if type == "2"{
            return UIColor.ColorfillBlue
        }
        
        if type == "3"{
            return UIColor.ColorThemeRed
        }
        
        if type == "4"{
            return UIColor.ColorYellow
        }
        
        return UIColor.ColorYellow
    }
}
