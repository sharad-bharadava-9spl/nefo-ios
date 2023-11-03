//
//  dispenseDetailVC.swift
//  CCSMembersApp
//
//  Created by Jaimin Patel on 7/15/19.
//  Copyright © 2019 Jaimin Patel. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import NVActivityIndicatorView

class dispenseDetailVC: UIViewController,NVActivityIndicatorViewable {
    var order_id:String=""
    var order_status:String=""
    var arrModel=[HomeCategoryList]()

    @IBOutlet weak var lblProductItem: UILabel!
    @IBOutlet weak var lblProductItemOutlet: UILabel!
    @IBOutlet weak var btnCancelOrder: UIButton!
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var lblDiscountOutlet: UILabel!
    @IBOutlet weak var lblPayableTotalOutlet: UILabel!
    @IBOutlet weak var lblCreditOutlet: UILabel!
    @IBOutlet weak var lblTotalOutlet: UILabel!
    @IBOutlet weak var lblPriceOutlet: UILabel!
    @IBOutlet weak var lblDiscount: UILabel!
   // @IBOutlet weak var priceDetailInnerView: UIView!
    @IBOutlet weak var priceDetailView: UIView!
    @IBOutlet weak var lblOrderDateTitle: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblOrderID: UILabel!
    @IBOutlet weak var lblOrderIdTitle: UILabel!
    @IBOutlet weak var imgBackground: UIImageView!
    
    @IBOutlet weak var lblItemTotal: UILabel!
    @IBOutlet weak var lblCredit: UILabel!
    @IBOutlet weak var lblPayableTotal: UILabel!
    
    var item1:UIBarButtonItem?
    var item2:UIBarButtonItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource=self
        tableView.delegate=self
        
        self.navigationController?.navigationBar.isHidden=false
        navigationController?.navigationBar.barTintColor = UIColor.white//UIColor(named: "backgroundViewColor")
        navigationController?.navigationBar.topItem?.title = "Dispense Detail".localized.uppercased()
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(named: "NavigationText")!, NSAttributedString.Key.font: UIFont(name: "ProductSans-Bold", size: 17)!]
        navigationItem.leftBarButtonItem?.tintColor = UIColor(named: "NavigationText")!
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.removeNavigationBarItem()
        self.imgBackground.image = UIImage(named : Shared().getImgName())
        
        var leftBack = Shared().imageWithImage(image: UIImage(named: "whiteBack")!, scaledToSize: CGSize(width: 16, height: 16))
        leftBack = leftBack.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: leftBack, style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.backVC))
        
        self.navigationController?.navigationBar.isHidden=false
        navigationController?.navigationBar.barTintColor = UIColor.white//UIColor(named: "backgroundViewColor")
        navigationController?.navigationBar.topItem?.title = "Dispense Detail".localized.uppercased()
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(named: "NavigationText")!, NSAttributedString.Key.font: UIFont(name: "ProductSans-Bold", size: 17)!]
        navigationItem.leftBarButtonItem?.tintColor = UIColor(named: "NavigationText")!//UIColor.white
        self.btnCancelOrder.shadowColor(color: UIColor.black.withAlphaComponent(0.2), border: 2, offHeight: 2)
        self.btnCancelOrder.layer.cornerRadius=10
        self.btnCancelOrder.layer.masksToBounds=true
     //   self.priceDetailView.shadowColor(color: UIColor.black.withAlphaComponent(0.2), border: 1.2, offHeight: 1.4)
//        self.detailView.shadowColor(color: UIColor.black.withAlphaComponent(0.2), border: 1.0, offHeight: 1)
//        self.detailView.layer.cornerRadius=10.0
//        self.detailView.layer.masksToBounds=true
        
      //  self.priceDetailInnerView.shadowColor(color: UIColor.black.withAlphaComponent(0.2), border: 1.0, offHeight: 1)
       // self.priceDetailInnerView.layer.cornerRadius=10.0
       // self.priceDetailInnerView.layer.masksToBounds=true
        
        self.hideShowView(flag: true)
        self.getDispenseHistoryList()
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
        self.slideMenuController()?.changeMainViewController(navVC, close: true)
    }
    
    @objc func cartRedirection(){
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "CartScreenVC") as! CartScreenVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func setupLanguage(){
        self.lblOrderIdTitle.text="Order Id:-".localized
        self.lblOrderDateTitle.text="Order Date:-".localized
        self.lblPriceOutlet.text="Totals".localized.uppercased()
        self.lblTotalOutlet.text="Products".localized.capitalized
        self.lblDiscountOutlet.text="- "+"Discount".localized.capitalized
        self.lblCreditOutlet.text="Your Credit".localized.capitalized
        self.lblPayableTotalOutlet.text="To Pay".localized.capitalized
        self.lblProductItemOutlet.text="Total Amount".localized.uppercased()
    }
    
    func hideShowView(flag:Bool){
        self.lblOrderID.isHidden=flag
        self.lblOrderIdTitle.isHidden=flag
        self.lblDate.isHidden=flag
        self.lblOrderDateTitle.isHidden=flag
        //self.priceDetailInnerView.isHidden=flag
        self.priceDetailView.isHidden=flag
        self.btnCancelOrder.isHidden=flag
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden=false
        navigationController?.navigationBar.barTintColor = UIColor.white//UIColor(named: "backgroundViewColor")
        navigationController?.navigationBar.topItem?.title = "Dispense Detail".localized.uppercased()
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(named: "NavigationText")!, NSAttributedString.Key.font: UIFont(name: "ProductSans-Bold", size: 17)!]
        navigationItem.leftBarButtonItem?.tintColor = UIColor(named: "NavigationText")!//UIColor.white
    }
    
    @objc func backVC(){
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnCancelOrderAction(_ sender: UIButton) {
        self.cancelOrder()
    }

}

extension dispenseDetailVC:UITableViewDataSource,UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrModel.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell=tableView.dequeueReusableCell(withIdentifier: "DispenseDetaiCell") as! DispenseDetaiCell
        let arrModelVal=self.arrModel[indexPath.row]
        cell.imgView.shadowColor(color: UIColor.black.withAlphaComponent(0.2), border: 1.4, offHeight: 1)
        cell.detailView.shadowColor(color: UIColor.black.withAlphaComponent(0.2), border: 1.4, offHeight: 1)
        //cell.detailView.layer.cornerRadius=10.0
        //cell.detailView.layer.masksToBounds=true
        cell.imgProduct.sd_setImage(with: URL(string:arrModelVal.product_image), placeholderImage: #imageLiteral(resourceName: "backgroundImg"))
        cell.lblProductName.text=arrModelVal.product_name
        cell.lblExtraPrice.text=arrModelVal.extra_price+" grm"
        cell.lblExtraPriceCount.text=arrModelVal.extra_price_count
        
        return cell
    }
    
    
}

extension dispenseDetailVC{
    //server :http://devsj72web.websiteserverhost.com/api/orderDetail
    func getDispenseHistoryList(){
        
        startAnimating(CGSize(width: 100, height: 100), message: "", type: NVActivityIndicatorType.ballRotate, fadeInAnimation: nil)
        let parameters: Parameters = [
            "language" : "\(Language.language)",
            "club_name" : UserDefaults.standard.object(forKey: "club_name") as! String,
            "user_id" : UserDefaults.standard.object(forKey: "user_id") as! String,
            "order_id" : self.order_id,
        ]
        
        print("\(Shared().webCall)orderDetail?language=\(Language.language)&club_name=\(UserDefaults.standard.object(forKey: "club_name") as! String)&user_id=\(UserDefaults.standard.object(forKey: "user_id") as! String)&order_id=\(self.order_id)")
        Alamofire.request("\(Shared().webCall)orderDetail.php", method: .post, parameters: parameters)
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
                            if let jsonDictData = jsonData["data"] as? [[String:Any]]{
                                let notification_count = UserDefaults.standard.string(forKey: "notifcount") as? String ?? "0"
                                UIApplication.shared.applicationIconBadgeNumber=JSON(notification_count).intValue
                                if notification_count != "0" {
                                    self.item2?.addBadge(number: Int(notification_count ?? "")!)
                                } else{
                                    self.item2?.removeBadge()
                                }
                                self.arrModel.removeAll()
                                self.hideShowView(flag: false)
                                if self.order_status=="Ordered"{
                                    self.btnCancelOrder.isHidden=false
                                } else{
                                    self.btnCancelOrder.isHidden=true
                                }
                                let jsonVal=JSON(jsonDictData)
                                for item in jsonDictData{
                                    print("JSON(jsonVal[order_id][jsonDict]).stringValue",JSON(item["order_id"]!).stringValue)
                                    print("JSON(jsonVal[create_order_date][jsonDict]).stringValue",JSON(item["create_order_date"]!).stringValue)
                                    self.lblOrderID.text=JSON(item["order_id"]!).stringValue
                                    
                                    self.lblDate.text=JSON(item["create_order_date"]!).stringValue
                                }
                                for jsonDict in 0..<jsonVal.count{
                                    let jsonObj=HomeCategoryList(json: jsonVal[jsonDict])
                                    self.arrModel.append(jsonObj)
                                   // self.imgProduct.sd_setImage(with: URL(string:JSON(jsonDict["product_image"]!).stringValue), placeholderImage: #imageLiteral(resourceName: "backgroundImg"))
                                    //self.lblProductName.text=JSON(jsonDict["product_name"]!).stringValue
                                    //self.lblExtraPrice.text=JSON(jsonDict["extra_price"]!).stringValue+" grm"
                                    //self.lblExtraPriceCount.text=JSON(jsonDict["extra_price_count"]!).stringValue+" €"
                                }
                                self.tableView.reloadData()
                                self.tableViewHeight.constant=self.tableView.contentSize.height
                                self.lblItemTotal.text=JSON(jsonData["total_price"]!).stringValue
                                self.lblCredit.text=JSON(jsonData["user_credit"]!).stringValue
                                self.lblDiscount.text=JSON(jsonData["user_discount"]!).stringValue
                                self.lblProductItem.text=JSON(jsonData["user_discountprice"]!).stringValue
                                if JSON(jsonData["user_grand_total"]!).stringValue == "" {
                                    self.lblPayableTotal.text="0.0"
                                } else{
                                    self.lblPayableTotal.text=JSON(jsonData["user_grand_total"]!).stringValue
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
    
    func cancelOrder(){
        
        startAnimating(CGSize(width: 100, height: 100), message: "", type: NVActivityIndicatorType.ballRotate, fadeInAnimation: nil)
        let parameters: Parameters = [
            "language" : "\(Language.language)",
            "club_name" : UserDefaults.standard.object(forKey: "club_name") as! String,
            "user_id" : UserDefaults.standard.object(forKey: "user_id") as! String,
            "order_id" : self.order_id,
            "macAddress" : Shared().getWifi(),
        ]
        
        print("\(Shared().webCall)cancelOrder?language=\(Language.language)&club_name=\(UserDefaults.standard.object(forKey: "club_name") as! String)&user_id=\(UserDefaults.standard.object(forKey: "user_id") as! String)&order_id=\(self.order_id)&macAddress=\(Shared().getWifi())")
        Alamofire.request("\(Shared().webCall)cancelOrder.php", method: .post, parameters: parameters)
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
                            let notification_count = JSON(jsonData["notification_count"]!).stringValue
                            UIApplication.shared.applicationIconBadgeNumber=JSON(notification_count).intValue
                            if notification_count != "0" {
                                 self.item2?.updateBadge(number: Int(notification_count)!)
                            } else{
                                self.item2?.removeBadge()
                            }
                            self.navigationController?.popViewController(animated: true)
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
