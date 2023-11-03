//
//  DispenseHistoryVC.swift
//  CCSMembersApp
//
//  Created by Jaimin Patel on 7/15/19.
//  Copyright © 2019 Jaimin Patel. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import NVActivityIndicatorView
import ActionSheetPicker_3_0

class DispenseHistoryVC: UIViewController,NVActivityIndicatorViewable {

    @IBOutlet weak var gradientView1: UIView!
    @IBOutlet weak var HeightGradientView: NSLayoutConstraint!
    @IBOutlet weak var lblDonationHistoryOutlet: UILabel!
    @IBOutlet weak var lblFilterBy: UILabel!
    @IBOutlet weak var lblFilterYear: UILabel!
    @IBOutlet weak var lblLast30Orders: UILabel!
    @IBOutlet weak var btnCancelFilterOutlet: UIButton!
    @IBOutlet weak var btnOkOutlet: UIButton!
    @IBOutlet weak var btnCancelOutlet: UIButton!
    
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var btn30Outlet: UIButton!
    @IBOutlet weak var btnYearOutlet: UIButton!
    @IBOutlet weak var yearView: UIView!
    @IBOutlet weak var lblCurrentYear: UILabel!
    @IBOutlet weak var halfFilterHeight: NSLayoutConstraint!
    @IBOutlet weak var halfFilterView: UIView!
    @IBOutlet weak var fullFilterView: UIView!
    @IBOutlet weak var imgBackground: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var gradientView: UIView!
    
    var listDictArr=[dispanseHistory]()
    var selectedDate:String=""
    var selected30:String=""
    var yearArr=[String]()
    var item1:UIBarButtonItem?
    var item2:UIBarButtonItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Shared().setGradientBackground(gradientView:gradientView1)
        
        self.tableView.isHidden=true
        self.tableView.dataSource=self
        self.tableView.delegate=self
        
        self.pickerView.dataSource=self
        self.pickerView.delegate=self
        
        self.navigationController?.navigationBar.isHidden=false
        navigationController?.navigationBar.barTintColor = UIColor.white//UIColor(named: "backgroundViewColor")
        navigationController?.navigationBar.topItem?.title = "Dispense History".localized.uppercased()
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(named: "NavigationText")!, NSAttributedString.Key.font: UIFont(name: "ProductSans-Bold", size: 17)!]
        navigationItem.leftBarButtonItem?.tintColor = UIColor(named: "NavigationText")!//UIColor.white
        
        fullFilterView.isHidden=true
        halfFilterView.isHidden=true
        halfFilterHeight.constant = -162
        yearView.isHidden=true
        let filterFull: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(filterFullView))
        self.fullFilterView.addGestureRecognizer(filterFull)
        // Do any additional setup after loading the view.
    }
    
    @IBAction func btnFilterAction(_ sender: UIButton) {
        self.gradientView1.isHidden=false
        HeightGradientView.constant=90
        self.gradientView.isHidden=false
        //self.filterAction()
    }
    
    override func viewDidLayoutSubviews() {
        Shared().setGradientBackground(gradientView:gradientView1)
    }

    override func viewWillAppear(_ animated: Bool) {
        self.gradientView1.isHidden=true
       Shared().setGradientBackground(gradientView:gradientView1)
        yarDataSet()
        self.btn30Outlet.setImage(UIImage(named: "unselect_RadioButton1"), for: .normal)
        self.btnYearOutlet.setImage(UIImage(named: "unselect_RadioButton1"), for: .normal)
        self.imgBackground.image = UIImage(named : Shared().getImgName())
        
        self.setNavigationBarItem()
        self.setLeftAlignTitleView(font: UIFont(name: "ProductSans-Bold", size: 17)!, text: "Dispense History".localized.uppercased(), textColor: .white)
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
        
        self.navigationController?.navigationBar.isHidden=false
        navigationController?.navigationBar.barTintColor = UIColor.white//UIColor(named: "backgroundViewColor")
        navigationController?.navigationBar.topItem?.title = "Dispense History".localized.uppercased()
       self.lblDonationHistoryOutlet.text = "Dispense History".localized.uppercased()
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(named: "NavigationText")!, NSAttributedString.Key.font: UIFont(name: "ProductSans-Bold", size: 17)!]
        navigationItem.leftBarButtonItem?.tintColor = UIColor(named: "NavigationText")!
        setupLanguage()
        Shared().setGradientBackground(gradientView:gradientView1)
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
        self.btnCancelOutlet.setTitle("Cancel".localized, for: .normal)
        self.btnOkOutlet.setTitle("Ok".localized, for: .normal)
        self.btnCancelFilterOutlet.setTitle("Cancel".localized, for: .normal)
        self.lblLast30Orders.text="Last 30 Orders".localized.uppercased()
        self.lblFilterYear.text="Year".localized.uppercased()
        self.lblFilterBy.text="Filter By".localized.uppercased()
        self.btnOkOutlet.setTitle("Ok".localized, for: .normal)
        self.btnCancelOutlet.setTitle("Cancel".localized, for: .normal)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        
        self.gradientView1.isHidden=true
        HeightGradientView.constant=0
        self.gradientView.isHidden=true
        self.pickerView.selectRow(self.yearArr.count-1, inComponent: 0, animated: true)
        self.navigationController?.navigationBar.isHidden=false
        navigationController?.navigationBar.barTintColor = UIColor.white//UIColor(named: "backgroundViewColor")
        navigationController?.navigationBar.topItem?.title = "Dispense History".localized.uppercased()
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(named: "NavigationText")!, NSAttributedString.Key.font: UIFont(name: "ProductSans-Bold", size: 17)!]
        navigationItem.leftBarButtonItem?.tintColor = UIColor(named: "NavigationText")!
        
        let when = DispatchTime.now() + 0.2
        DispatchQueue.main.asyncAfter(deadline: when) {
            self.getDispenseHistoryList()
        }
    }
    
    func yarDataSet(){
        self.yearArr.removeAll()
        let date = Date()
        let calendar = Calendar.current
        self.lblCurrentYear.text="\(calendar.component(.year, from: date))"
        print("calendar.component(.year, from: date)",calendar.component(.year, from: date))
        for item in 2010...Int(calendar.component(.year, from: date)){
            self.yearArr.append("\(item)")
        }
        print("self.yearArr",self.yearArr)
        print("self.yearArr Count",self.yearArr.count)
    }
    
    @objc func filterFullView() {
        if self.yearView.isHidden==false{
            
        } else{
            filterhideView()
        }
    }
    
    @IBAction func btnYearOk(_ sender: UIButton) {
        self.btn30Outlet.setImage(UIImage(named: "unselect_RadioButton1"), for: .normal)
        self.btnYearOutlet.setImage(UIImage(named: "select_RadioButton1"), for: .normal)
        self.yearView.isHidden=true
        self.fullFilterView.isHidden=true
        self.selectedDate=self.lblCurrentYear.text!
        self.selected30=""
        self.filterDispenseHistoryList()
    }
    @IBAction func btnYearCancel(_ sender: UIButton) {
     //   self.btn30Outlet.setImage(UIImage(named: "unselect_RadioButton1"), for: .normal)
    //    self.btnYearOutlet.setImage(UIImage(named: "unselect_RadioButton1"), for: .normal)
        
        self.yearView.isHidden=true
        self.fullFilterView.isHidden=true
    }
    @IBAction func btnFilterCancel(_ sender: UIButton) {
        self.btn30Outlet.setImage(UIImage(named: "unselect_RadioButton1"), for: .normal)
        self.btnYearOutlet.setImage(UIImage(named: "unselect_RadioButton1"), for: .normal)
        filterhideView()
    }
    
    @IBAction func btnYear(_ sender: UIButton) {
        self.view.endEditing(true)
       // self.btn30Outlet.setImage(UIImage(named: "unselect_RadioButton1"), for: .normal)
       // self.btnYearOutlet.setImage(UIImage(named: "select_RadioButton1"), for: .normal)
        UIView.animate(withDuration: 0.15,
                       delay: 0.1,
                       options: UIView.AnimationOptions.curveEaseIn,
                       animations: { () -> Void in
                       // self.halfFilterHeight.constant = -162
                        self.view.layoutIfNeeded()
                        
                        //self.superview?.layoutIfNeeded()
        }, completion: { Void in
            self.yearView.isHidden=false
            //self.halfFilterView.isHidden=true
            self.fullFilterView.isHidden=false
            self.view.endEditing(true)
            self.view.resignFirstResponder()
            
            //  self.isOpen = true
        })
    }
    
    @IBAction func btnLast30Orders(_ sender: UIButton) {
        self.btn30Outlet.setImage(UIImage(named: "select_RadioButton1"), for: .normal)
        self.btnYearOutlet.setImage(UIImage(named: "unselect_RadioButton1"), for: .normal)
        self.selectedDate=""
        self.selected30="30"
       // filterhideView()
        self.filterDispenseHistoryList()
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
            self.btn30Outlet.setImage(UIImage(named: "unselect_RadioButton1"), for: .normal)
            self.btnYearOutlet.setImage(UIImage(named: "unselect_RadioButton1"), for: .normal)
            self.halfFilterView.isHidden=true
            self.fullFilterView.isHidden=true
            self.view.endEditing(true)
            self.view.resignFirstResponder()
            
            //  self.isOpen = true
        })
    }
    
    @objc func filterAction(){
        
        fullFilterView.isHidden=false
        halfFilterView.isHidden=false
        UIView.animate(withDuration: 0.15,
                       delay: 0.1,
                       options: UIView.AnimationOptions.curveEaseIn,
                       animations: { () -> Void in
                        self.halfFilterHeight.constant=12
                        self.view.layoutIfNeeded()
        }, completion: { Void in
        })
    }
    
    
}

extension DispenseHistoryVC:UITableViewDataSource,UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        
            return self.listDictArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell=tableView.dequeueReusableCell(withIdentifier: "dispanseHistoryCell") as! dispanseHistoryCell
            let dictData=listDictArr[indexPath.row]
            cell.lblOrderIDOutlet.text="ID".localized
            //cell.lblItemsOutlet.text="Items".localized
            cell.lblTotalPriceOutlet.text="Totals".localized.uppercased()
            cell.mainView.shadowColor(color: UIColor.black.withAlphaComponent(0.2), border: 1.2, offHeight: 1.4)
           // cell.mainView.layer.cornerRadius = 10.0
            //cell.mainView.layer.masksToBounds=true
            cell.lblDate.text = "getDisplayDate" //getDisplayDate(date: "\(dictData.create_order_date) \(dictData.create_order_time)", dateFormat: dateTimeFromateDispaly, displayFormat: dateTimeFromateDispaly).capitalized //dictData.create_order_date
            cell.lblTimes.text = ""//dictData.create_order_time
            cell.lblItemsOutlet.text=dictData.order_status
//            if dictData.order_status == "Ordered"{
//             /   cell.bottomCancelBtn.constant=8
//                cell.hightCancelBtn.constant=40
//            } else{
//                cell.bottomCancelBtn.constant=0
//                cell.hightCancelBtn.constant=0
//            }
            //cell.imgView.sd_setImage(with: URL(string:dictData.product_image), placeholderImage: #imageLiteral(resourceName: "backgroundImg"))
        cell.lblOrderId.text="#"+dictData.order_id
            cell.lblItems.text=dictData.itemcount+" "+"Products".localized.uppercased()
           // cell.btnCancelOutlet.setTitle("Cancel Order".localized, for: .normal)
         //   cell.btnCancelOutlet.tag=indexPath.row
       // cell.btnCancelOutlet.addTarget(self, action: #selector(self.cancelOrderBtn(sender:)), for: .touchUpInside)
            cell.lblTotalPrice.text=dictData.total_price
            cell.btnDidselect.tag=indexPath.row
            cell.btnDidselect.addTarget(self, action: #selector(self.didSelect(sender:)), for: .touchUpInside)
            return cell
    }
    
    @objc func cancelOrderBtn(sender:UIButton){
        let dictData=listDictArr[sender.tag]
        self.cancelOrdere(order_id: dictData.order_id)
    }
    
    @objc func didSelectYear(sender:UIButton){
        self.lblCurrentYear.text=yearArr[sender.tag]
    }
    
    @objc func didSelect(sender:UIButton){
        let dictData=listDictArr[sender.tag]
        let storyBoard=UIStoryboard(name: "Main", bundle: nil)
        let vc=storyBoard.instantiateViewController(withIdentifier: "dispenseDetailVC") as! dispenseDetailVC
        vc.order_id=dictData.order_id
        vc.order_status=dictData.order_status
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension DispenseHistoryVC:UIPickerViewDataSource,UIPickerViewDelegate{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return yearArr.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return yearArr[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.lblCurrentYear.text=yearArr[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 44
    }
}

extension DispenseHistoryVC{
    func getDispenseHistoryList(){
        
        startAnimating(CGSize(width: 100, height: 100), message: "", type: NVActivityIndicatorType.ballRotate, fadeInAnimation: nil)
        let parameters: Parameters = [
            "language" : "\(Language.language)",
            "club_name" : UserDefaults.standard.object(forKey: "club_name") as! String,
            "user_id" : UserDefaults.standard.object(forKey: "user_id") as! String,
        ]
        
        print("\(Shared().webCall)viewOrder?language=\(Language.language)&club_name=\(UserDefaults.standard.object(forKey: "club_name") as! String)&user_id=\(UserDefaults.standard.object(forKey: "user_id") as! String)")
        Alamofire.request("\(Shared().webCall)viewOrder.php", method: .post, parameters: parameters)
            .responseJSON { response in
                let when = DispatchTime.now() + 0.1
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
                                let notification_count = UserDefaults.standard.string(forKey: "notifcount") as? String ?? "0"
                                UIApplication.shared.applicationIconBadgeNumber=JSON(notification_count).intValue
                                if notification_count != "0" {
                                    self.item2?.addBadge(number: Int(notification_count ?? "")!)
                                } else{
                                    self.item2?.removeBadge()
                                }
                                self.listDictArr.removeAll()
                                let jsonIs = JSON(jsonDict)
                                for item in 0..<jsonIs.count{
                                    let arrObj=dispanseHistory(json: jsonIs[item])
                                    self.listDictArr.append(arrObj)
                                }
                                if self.listDictArr.count != 0{
                                    self.tableView.isHidden=false
                                    self.tableView.reloadData()
                                }
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
                        print("err----\(error.localizedDescription)")
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
    
    func filterDispenseHistoryList(){
        //server :http://devsj72web.websiteserverhost.com/api/orderFilter
        startAnimating(CGSize(width: 100, height: 100), message: "", type: NVActivityIndicatorType.ballRotate, fadeInAnimation: nil)
        let parameters: Parameters = [
            "language" : "\(Language.language)",
            "club_name" : UserDefaults.standard.object(forKey: "club_name") as! String,
            "last_order" : self.selected30,
            "year" : self.selectedDate,
            "user_id" : UserDefaults.standard.object(forKey: "user_id") as! String,
        ]
        
        print("\(Shared().webCall)orderFilter?language=\(Language.language)&club_name=\(UserDefaults.standard.object(forKey: "club_name") as! String)&user_id=\(UserDefaults.standard.object(forKey: "user_id") as! String)&last_order=\(self.selected30)&year=\(self.selectedDate)")
        Alamofire.request("\(Shared().webCall)orderFilter.php", method: .post, parameters: parameters)
            .responseJSON { response in
                let when = DispatchTime.now() + 0.1
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
                                self.listDictArr.removeAll()
                                let notification_count = JSON(jsonData["notification_count"]!).stringValue
                                UIApplication.shared.applicationIconBadgeNumber=JSON(notification_count).intValue
                                if notification_count != "0" {
                                     self.item2?.updateBadge(number: Int(notification_count)!)
                                } else{
                                    self.item2?.removeBadge()
                                }
                                let jsonIs = JSON(jsonDict)
                                for item in 0..<jsonIs.count{
                                    let arrObj=dispanseHistory(json: jsonIs[item])
                                    self.listDictArr.append(arrObj)
                                }
                                
                                if self.listDictArr.count == 0{
                                    let message : String = JSON(jsonData["message"]!).stringValue
                                    Shared().showAlert(uIViewController: self, title: Shared().error, message: message)
                                    print("err----\(message)")
                                }
                                
                               
                                //if self.listDictArr.count != 0{
                                   // self.tableView.isHidden=false
                                    self.tableView.reloadData()
                                //}
                            }
                        } else{
                            let message : String = JSON(jsonData["message"]!).stringValue
                            Shared().showAlert(uIViewController: self, title: Shared().error, message: message)
                            print("err----\(message)")
                        }
                    }
                    // })
                    break
                    
                case .failure(let error):
                    //alert.dismiss(animated: true, completion: {
                    let errorCode = error._code
                    if(errorCode == -1001 || errorCode == -1005 || errorCode == -1009) {
                        Shared().showAlert(uIViewController: self, title: Shared().error, message: error.localizedDescription)
                        print("err----\(error.localizedDescription)")
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
    
    func cancelOrdere(order_id:String){
        /*
         language
         club_name : demo
         user_id
         order_id
         macAddress
         */
       // self.lblMaxCredit.isHidden=true
        startAnimating(CGSize(width: 100, height: 100), message: "", type: NVActivityIndicatorType.ballRotate, fadeInAnimation: nil)
        let parameters: Parameters = [
            "language" : "\(Language.language)",
            "club_name" : UserDefaults.standard.object(forKey: "club_name") as! String,
            "order_id" : order_id,
            "macAddress" : Shared().getWifi(),
            "user_id" : UserDefaults.standard.string(forKey: "user_id")!,
            "platform" : Shared().device_platform,
            "device_id" : UIDevice.current.identifierForVendor!.uuidString,
        ]
        print("\(Shared().webCall)cancelOrder?user_id=\(UserDefaults.standard.string(forKey: "user_id")!)&language=\(Language.language)&club_name=\(UserDefaults.standard.object(forKey: "club_name") as! String)&platform=\(Shared().device_platform)&device_id=\(UIDevice.current.identifierForVendor!.uuidString)&macAddress=\(Shared().getWifi())&order_id=\(order_id)")
        Alamofire.request("\(Shared().webCall)cancelOrder.php", method: .post, parameters: parameters)
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
                                
                            }
                            let notification_count = JSON(jsonData["notification_count"]!).stringValue
                            UIApplication.shared.applicationIconBadgeNumber=JSON(notification_count).intValue
                            
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
