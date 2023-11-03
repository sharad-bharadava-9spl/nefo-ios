//
//  HistoryVC.swift
//  CCSMembersApp
//
//  Created by Apple on 22/07/22.
//  Copyright © 2022 Jaimin Patel. All rights reserved.
//

import UIKit
import DropDown
import Alamofire
import SwiftyJSON
import NVActivityIndicatorView

class HistoryVC: UIViewController,NVActivityIndicatorViewable  {
    
    @IBOutlet weak var filtertitleView: UIView!
    @IBOutlet weak var filtericonView: UIView!
    @IBOutlet weak var filtertdropBtn: UIButton!
    @IBOutlet weak var filterbtn: UIButton!
    @IBOutlet weak var filtertitlelbl: UILabel!
    @IBOutlet weak var filterbylast : UIButton!
    @IBOutlet weak var filterbyYear : UIButton!
    @IBOutlet weak var Seletedyear: UILabel!
    @IBOutlet weak var SeletedyearDropSelecte: UIView!
    @IBOutlet weak var filterView: UIView!
    @IBOutlet weak var historyTable: UITableView!
    @IBOutlet weak var filterlast30Lbl: UILabel!
    @IBOutlet weak var filterbyyearLbl: UILabel!
    @IBOutlet weak var filterBtntext: UIButton!
    
    
    var item2:UIBarButtonItem?
    let dropDown = DropDown()
    var yearArr=[String]()
    var filterType = Int()
    var listDictArr=[dispanseHistory]()
    
    var selectedDate:String=""
    var selected30:String=""
    
    var isDispancePriceShown = false

    override func viewDidLoad() {
        super.viewDidLoad()

        let nib = UINib(nibName: "HistoryTblCellTableViewCell", bundle: nil)
        historyTable.register(nib, forCellReuseIdentifier: "HistoryTblCellTableViewCell")
        self.historyTable.register(UINib(nibName: "\(HistoryCustomHeader.self)", bundle: nil), forHeaderFooterViewReuseIdentifier: "\(HistoryCustomHeader.self)")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.isHidden=false
        self.navigationItem.setHidesBackButton(true, animated: true)
        self.navigationController?.navigationBar.backgroundColor = .clear
        self.setNavigationBarItem()
        self.setLeftAlignTitleView(font: UIFont(name: "ProductSans-Bold", size: 17)!, text: "Dispense History".localized.capitalized, textColor: .white)
        var imageNotification = Shared().imageWithImage(image: UIImage(named: "Notification_icon")!, scaledToSize: CGSize(width: 23, height: 23))
        imageNotification = imageNotification.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        filtertitlelbl.text = "Filter_Options".localized
        filterlast30Lbl.text = "filter_by_last_30_orders".localized
        filterbyyearLbl.text = "filter_by_year".localized
        filterBtntext.setTitle("filter".localized, for: .normal)
        Seletedyear.text = "select_year".localized
        yarDataSet()
      
        
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
        
        self.navigationItem.setRightBarButtonItems([item2!], animated: true)
        
        if #available(iOS 13.0, *) {
            let statusBar = UIView(frame: (UIApplication.shared.keyWindow?.windowScene?.statusBarManager?.statusBarFrame)!)
            statusBar.backgroundColor = .clear
            UIApplication.shared.keyWindow?.addSubview(statusBar)
        }
        
        
        filtericonView.roundCorners(corners: [.topLeft, .bottomLeft], radius: 4)
      //  filterView.roundCorners(corners: [.bottomLeft, .bottomRight], radius: 4)
        filterView.isHidden = true
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        let when = DispatchTime.now() + 0.2
        DispatchQueue.main.asyncAfter(deadline: when) {
            self.getDispenseHistoryList()
        }
    }
    
    
    @objc func notificationScreenRedirection(){
        let storyBoard=UIStoryboard(name: "Main", bundle: nil)
        let vc=storyBoard.instantiateViewController(withIdentifier: "NotificationVC") as! NotificationVC
        let navVC=UINavigationController(rootViewController: vc)
        self.slideMenuController()?.changeMainViewController(navVC, close: true)
    }
    
    func yarDataSet(){
        self.yearArr.removeAll()
        let date = Date()
        let calendar = Calendar.current
        print("calendar.component(.year, from: date)",calendar.component(.year, from: date))
        for item in 2010...Int(calendar.component(.year, from: date)){
            self.yearArr.append("\(item)")
        }
    }
    
    
    
    @IBAction func filterdroptapped(_ sender: UIButton){
        
        if sender.isSelected {
            sender.isSelected = false
            filtertdropBtn.setImage(UIImage(named: "icon-angle-right-1"), for: .normal)
            filtertitlelbl.textColor = .black
            filtericonView.backgroundColor = .black
            filtertitleView.backgroundColor = UIColor(hexString: "#33FF99")
            filterbtn.imageView?.setImageColor(color: UIColor(hexString: "#33FF99"))
            filterView.isHidden = false
        } else {
            sender.isSelected = true
            filtertdropBtn.setImage(UIImage(named: "icon-angle-right"), for: .normal)
            filtertitlelbl.textColor = UIColor(hexString: "#EBEDEF")
            filtericonView.backgroundColor = UIColor(hexString: "#37404B")
            filtertitleView.backgroundColor = UIColor(hexString: "#404D60")
            filterbtn.imageView?.setImageColor(color: UIColor(hexString: "#EBEDEF"))
            filterView.isHidden = true
        }
        
    }
    
    @IBAction func filterbyYearTapped(_ sender: UIButton){
       
        filterbyYear.setImage(UIImage(named: "checked"), for: .normal)
        filterbylast.setImage(UIImage(named: "default"), for: .normal)
        filterType = 2
    }
    
    @IBAction func filterbylastTapped(_ sender: UIButton){
        filterbylast.setImage(UIImage(named: "checked"), for: .normal)
        filterbyYear.setImage(UIImage(named: "default"), for: .normal)
        filterType = 1
        self.selected30 = "30"
        self.selectedDate = ""
    }

    
    @IBAction func yeardropdown(_ sender: UIButton){
        if filterType == 2 {
            setdropdown(vw: self.SeletedyearDropSelecte, dataSource: self.yearArr , dropDown: dropDown)
            dropDown.show()
            dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
                self.Seletedyear.text = item
                self.selected30 = ""
                self.selectedDate = item
            }
        }
        
        
    }
    
    @IBAction func saveFilter(_ sender: UIButton){
        if filterType != nil {
            self.filterDispenseHistoryList()
            
        }
    }
   
}


extension HistoryVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.listDictArr.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        /*let headerView = HistorytblHeader()
        headerView.mainView.roundCorners(corners: [.topLeft, .topRight], radius: 4)
        headerView.mainView.backgroundColor = UIColor(hexString: "#37404B")
        let dateNtime = self.listDictArr[section].create_order_date + " " + self.listDictArr[section].create_order_time
        headerView.dateandtime.text = dateNtime
        headerView.totalLbl.text = "TOTAL: \(self.listDictArr[section].total_price)€"
        return headerView */
        
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "\(HistoryCustomHeader.self)") as! HistoryCustomHeader
        
        DispatchQueue.main.async {
            headerView.mainView.roundCorners(corners: [.topLeft, .topRight], radius: 4)
        }
        headerView.mainView.backgroundColor = UIColor(hexString: "#37404B")
        //let dateNtime = self.listDictArr[section].create_order_date + " " + self.listDictArr[section].create_order_time
        headerView.dateandtime.text = getDisplayDate(date: self.listDictArr[section].create_new_order_date, dateFormat: dateFormateDisplayDash, displayFormat: dateTimeFromateDispaly).capitalized //dictData.create_order_date
        if self.isDispancePriceShown{
            headerView.totalLbl.text = "TOTAL: \(self.listDictArr[section].total_price)"
        }else{
            headerView.totalLbl.text = ""
        }
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        
        return self.listDictArr[section].order_details.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryTblCellTableViewCell") as! HistoryTblCellTableViewCell
        
        if (indexPath.row % 2) != 0{
            cell.mainView.backgroundColor = UIColor(hexString: "#212A36")
            }else{
                cell.mainView.backgroundColor = UIColor(hexString: "#161D26")

            }
        
        cell.titleLbl.text = self.listDictArr[indexPath.section].order_details[indexPath.row]["product_name"].stringValue
        
        let qnt = Int(self.listDictArr[indexPath.section].order_details[indexPath.row]["quantity"] as? String ?? "")
        
        cell.quantity.text = "\(self.listDictArr[indexPath.section].order_details[indexPath.row]["quantity"].stringValue)"
        if self.isDispancePriceShown{
            cell.total.text = "\(self.listDictArr[indexPath.section].order_details[indexPath.row]["amount"].stringValue)"
        }else{
            cell.total.text = ""
        }
        
        
        if self.listDictArr[indexPath.section].order_details.count - 1 == indexPath.row {
            cell.bottomBoder.isHidden = false
        } else {
            cell.bottomBoder.isHidden = true
        }
        
        return cell
    }

    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 36
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    
    
}


extension HistoryVC {
    
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
                                
                                self.isDispancePriceShown = JSON(jsonData["dispensprice_option"]!).boolValue
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
                                    
                                    self.historyTable.isHidden=false
                                    self.historyTable.reloadData()
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
//                                    let message : String = JSON(jsonData["message"]!).stringValue
//                                    Shared().showAlert(uIViewController: self, title: Shared().error, message: message)
                                    self.historyTable.setEmptyMessage("no_dispenses_found".localized)
                                }else{
                                    self.historyTable.restore()
                                }
                                //if self.listDictArr.count != 0{
                                   // self.tableView.isHidden=false
                                    
                                    self.historyTable.reloadData()
                                //}
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
    
    
}
