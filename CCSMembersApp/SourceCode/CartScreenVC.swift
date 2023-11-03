//
//  CartScreenVC.swift
//  CCSMembersApp
//
//  Created by Jaimin Patel on 6/17/19.
//  Copyright © 2019 Jaimin Patel. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SDWebImage
import NVActivityIndicatorView
import Stripe

class CartScreenVC: UIViewController,NVActivityIndicatorViewable {

    @IBOutlet weak var lblTotalItem: UILabel!
    @IBOutlet weak var lblTotalAmountOutlet: UILabel!
    @IBOutlet weak var btnPlaceOrderOutlet: UIButton!
    @IBOutlet weak var lblOrderOutlet: UILabel!
    @IBOutlet weak var lblCancel: UILabel!
    @IBOutlet weak var gradientView1: UIView!
    @IBOutlet weak var lblPayableTotalOutlet: UILabel!
    @IBOutlet weak var lblCreditOutlet: UILabel!
    @IBOutlet weak var lblItemTotalOutlet: UILabel!
    @IBOutlet weak var lblDiscountOutlet: UILabel!
    @IBOutlet weak var lblPriceOutlet: UILabel!
    @IBOutlet weak var lblPlaceOrder: UILabel!
    @IBOutlet weak var lblEmptyCartErrMsg: UILabel!
    //@IBOutlet weak var discountTopConstraints: NSLayoutConstraint!
    //@IBOutlet weak var dicountHeightConstraints: NSLayoutConstraint!
    @IBOutlet weak var lblDiscount: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var placeOrderView: UIView!
    @IBOutlet weak var lblPayAmount: UILabel!
    //@IBOutlet weak var priceView: UIView!
    @IBOutlet weak var paymentView: UIView!
    @IBOutlet weak var lblPayableItem: UILabel!
    @IBOutlet weak var lblCredit: UILabel!
    @IBOutlet weak var lblItemTotal: UILabel!
    @IBOutlet weak var imgBackground: UIImageView!
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
   
    var listDictArr=[HomeCategoryList]()
    var userupdatecredit:String?
    var Pre_order:String="0"
    var dictArr=[[String:Any]]()
    var fullDictArr=[String:Any]()
    var item1:UIBarButtonItem?
    var item2:UIBarButtonItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.lblEmptyCartErrMsg.isHidden=true
        self.tableView.dataSource=self
        self.tableView.delegate=self
        
        self.tableView.isHidden=true
        self.paymentView.isHidden=true
        //self.priceView.isHidden=true
        self.placeOrderView.isHidden=true
        
        self.navigationController?.navigationBar.isHidden=false
        
        navigationController?.navigationBar.barTintColor = UIColor.white//UIColor(named: "backgroundViewColor")
        navigationController?.navigationBar.topItem?.title = "Cart".localized.uppercased()
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(named: "NavigationText")!, NSAttributedString.Key.font: UIFont(name: "ProductSans-Bold", size: 17)!]
        navigationItem.leftBarButtonItem?.tintColor = UIColor(named: "NavigationText")!
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(tap)
        
        //self.priceView.shadowColor(color: UIColor.black.withAlphaComponent(0.2), border: 1.2, offHeight: 1.4)
        // Do any additional setup after loading the view.
    }
    
    override func viewDidLayoutSubviews() {
        Shared().setGradientBackground(gradientView:gradientView1)
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
    
    override func viewWillAppear(_ animated: Bool) {
        self.getViewCartList()
        self.removeNavigationBarItem()
        self.imgBackground.image = UIImage(named : Shared().getImgName())
        
        var leftBack = Shared().imageWithImage(image: UIImage(named: "whiteBack")!, scaledToSize: CGSize(width: 20, height: 20))
        leftBack = leftBack.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: leftBack, style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.backVC))
        
        var imageShopingCart = Shared().imageWithImage(image: UIImage(named: "Shoping_Cart")!, scaledToSize: CGSize(width: 23, height: 23))
        imageShopingCart = imageShopingCart.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        
        var imageNotification = Shared().imageWithImage(image: UIImage(named: "notification")!, scaledToSize: CGSize(width: 23, height: 23))
        imageNotification = imageNotification.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        if targetName != Shared().cannibisAppName {
        let btn1 = UIButton(type: .custom)
        btn1.setImage(imageShopingCart, for: .normal)
        btn1.frame = CGRect(x: 0, y: 0, width: 28, height: 28)
       // btn1.addTarget(self, action:#selector(self.cartRedirection), for: .touchUpInside)
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
        navigationController?.navigationBar.barTintColor = UIColor.white//UIColor(named: "backgroundViewColor")
        navigationController?.navigationBar.topItem?.title = "Cart".localized.uppercased()
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(named: "NavigationText")!, NSAttributedString.Key.font: UIFont(name: "ProductSans-Bold", size: 17)!]
        navigationItem.leftBarButtonItem?.tintColor = UIColor(named: "NavigationText")!
        self.setupMultilanguage()
    }
    
    @objc func notificationScreenRedirection(){
        let storyBoard=UIStoryboard(name: "Main", bundle: nil)
        let vc=storyBoard.instantiateViewController(withIdentifier: "NotificationVC") as! NotificationVC
        let navVC=UINavigationController(rootViewController: vc)
        slideMenuController()?.changeMainViewController(navVC, close: true)
    }
    
    @IBAction func btnCancelAction(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func setupMultilanguage(){
        self.lblEmptyCartErrMsg.text="Your cart is empty.".localized
        //self.lblPlaceOrder.text="Place Order".localized
        self.lblPriceOutlet.text="Totals".localized.uppercased()
        self.lblItemTotalOutlet.text="Products".localized.capitalized
        self.lblDiscountOutlet.text="- "+"Discount".localized.capitalized
        self.lblTotalAmountOutlet.text="Total Amount".localized.uppercased()
        self.lblCreditOutlet.text="Your Credit".localized.capitalized
        self.lblCancel.text="Cancel".localized
        self.lblOrderOutlet.text="Order".localized
        self.lblPayableTotalOutlet.text="To Pay".localized.capitalized
    }
    
    override func viewDidAppear(_ animated: Bool) {
        navigationController?.navigationBar.barTintColor = UIColor.white//UIColor(named: "backgroundViewColor")//Shared().hexStringToUIColor("#00A0D6")
        navigationController?.navigationBar.topItem?.title = "Cart".localized.uppercased()
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(named: "NavigationText")!, NSAttributedString.Key.font: UIFont(name: "ProductSans-Bold", size: 17)!]
        navigationItem.leftBarButtonItem?.tintColor = UIColor(named: "NavigationText")!
    }
    
    @objc func backVC(){
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnPlaceOrder(_ sender: UIButton) {
        if self.Pre_order == "1"{
            self.dictArr.removeAll()
            self.fullDictArr.removeAll()
            for itrm in listDictArr{
                var dictVal=[String:Any]()
                dictVal["product_id"]=JSON(itrm.product_id).stringValue
                dictVal["category_id"]=JSON(itrm.category_id).stringValue
                dictVal["category_name"]=JSON(itrm.category_name).stringValue
                dictVal["category_type"]=JSON(itrm.category_type).stringValue
                dictVal["product_name"]=JSON(itrm.product_name).stringValue
                dictVal["product_image"]=JSON(itrm.product_image).stringValue
                dictVal["product_description"]=JSON(itrm.product_description).stringValue
                dictVal["product_price"]=JSON(itrm.product_price).stringValue
                dictVal["extra_price"]=JSON(itrm.extra_price).stringValue
                dictVal["extra_price_count"]=JSON(itrm.extra_price_count).stringValue
                dictVal["is_discount"]=JSON(itrm.is_discount).stringValue
                dictVal["user_discount"]=JSON(itrm.user_discount).stringValue
                dictVal["user_discount_price"]=JSON(itrm.user_discount_price).stringValue
                dictVal["useroriginal_discount"]=JSON(itrm.useroriginal_discount).stringValue
                self.dictArr.append(dictVal)
            }
            
            self.fullDictArr=["user_discount":self.lblDiscount.text!.dropLast(),"userupdatecredit":self.userupdatecredit!,"total_price": self.lblItemTotal.text!.dropLast(),"user_credit": self.lblCredit.text!.dropLast(),"user_grand_total": self.lblPayableItem.text!.dropLast(),"payment_mode":"credit","stripe_token":"","user_id":"\(UserDefaults.standard.string(forKey: "user_id")!)","data":dictArr]
            print("=============33#############self.fullDictArr",self.fullDictArr)
            if let cost = Double(Shared().componentSepareted(fullValue: self.lblPayableItem.text!, separatedBy: " ")) {
                print("The item is valued at: \(cost)")
                if cost > 0{
                    self.getStripeToken(fullDictArrVal:self.fullDictArr,costVal:cost,apiCallScreenVal:"CartScreen")
                } else{
                    self.placeHolderApi()
                }
            } else {
                print("Not a valid number: \(self.lblPayableItem.text!)")
            }
            
        }else{
            self.dismissKeyboard()
            Shared().showAlert(uIViewController: self, title: Shared().wifiNoteError, message: Shared().wifiPermissionNote)
        }
    }
}

extension CartScreenVC:UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.listDictArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell=tableView.dequeueReusableCell(withIdentifier: "viewCartCell")  as! viewCartCell
        let dictData = listDictArr[indexPath.row]
        if dictData.apiCall=="true"{
            var qty:String?
            
            if dictData.category_type == "1"{
                qty="0"
                if let qtyity = qty{
                    print("dictData.apiCall Flag Is ===>>>",qtyity)
                    self.editQtyOrEuroCart(product_id: dictData.product_id, selectedIndexIS: indexPath.row, extra_price_count: cell.lblQtyPlusMinus.text!, product_price: cell.txtEuro.text!,flag:qtyity)
                }
            } else{
                if dictData.euroEditText == "true"{
                    qty="1"
                } else if dictData.grmEditText == "true" {
                    qty="0"
                }
                if cell.txtGrm.text! == dictData.extra_price && cell.txtEuro.text! == dictData.user_discount_price{
                    
                } else{
                    if let qtyity = qty{
                        if JSON(cell.txtGrm.text!).doubleValue > 0 && JSON(cell.txtEuro.text!).doubleValue > 0 {
                            print("dictData.apiCall Flag Is ===>>>",qtyity)
                            self.editQtyOrEuroCart(product_id: dictData.product_id, selectedIndexIS: indexPath.row, extra_price_count: cell.txtGrm.text!, product_price: cell.txtEuro.text!,flag:qtyity)
                        } else{
                            
                        }
                        
                    }
                }
            }
        } else{
        cell.imgProduct.sd_setImage(with: URL(string:dictData.product_image), placeholderImage: #imageLiteral(resourceName: "backgroundImg"))
        //cell.lblDetail.text=dictData.product_description
        cell.lblName.text=dictData.product_name

        if dictData.is_discount == "true"{
            cell.lblDiscount.isHidden=false
            cell.lblDiscountPercentage.isHidden=false
            cell.lblDiscountPercentage.text="\(Double(round(100*Double(Shared().componentSepareted(fullValue: "\(dictData.useroriginal_discount)", separatedBy: " "))!)/100)) %"//"200000000000.546521 %"//dictData.useroriginal_discount
            cell.lblDiscount.attributedText="\(Double(round(100*Double(Shared().componentSepareted(fullValue: dictData.extra_price_count+" €", separatedBy: " "))!)/100)) €".strikeThrough()//"\("500000.5346546546546546546 %"+" €")".strikeThrough()//"\(dictData.extra_price_count+" €")".strikeThrough()
        } else{
            cell.lblDiscount.isHidden=true
            cell.lblDiscountPercentage.isHidden=true
        }
        if dictData.category_type == "1"{
            cell.qtyView.isHidden=false
            cell.gramStackView.isHidden=true
            cell.lblQtyPlusMinus.text="\(JSON(dictData.extra_price).intValue)"
            cell.btnPlushQty.tag=indexPath.row
            cell.btnPlushQty.addTarget(self, action: #selector(increaseCategoryCount(sender:)), for: .touchUpInside)
            cell.btnMinusQty.tag=indexPath.row
            cell.btnMinusQty.addTarget(self, action: #selector(decreseCategoryCount(sender:)), for: .touchUpInside)
            cell.lblQty.text="qty"
            cell.btnEditEuro.isHidden=true
            cell.btnEditGrm.isHidden=false
        } else{
            cell.qtyView.isHidden=true
            cell.gramStackView.isHidden=false
            cell.lblQty.text="gr."
            cell.btnEditEuro.isHidden=false
            cell.btnEditGrm.isHidden=false
        }
        cell.mainView.shadowColor(color: UIColor.black.withAlphaComponent(0.2), border: 1.2, offHeight: 1.4)
            cell.viewImg.shadowColor(color: UIColor.black.withAlphaComponent(0.2), border: 1.2, offHeight: 1.4)
       // cell.mainView.layer.cornerRadius = 10.0
        //cell.btnRemove.setTitle("Remove".localized, for: .normal)
        cell.lblRemoveOutlet.text="Remove".localized
        cell.btnRemove.tag=indexPath.row
        cell.btnRemove.addTarget(self, action: #selector(self.removeProduct(sender:)), for: .touchUpInside)
        cell.selectionStyle = .none
        cell.layoutIfNeeded()
        cell.txtGrm.delegate=self
        cell.txtEuro.delegate=self
        cell.txtGrm.tag=indexPath.row
        cell.txtEuro.tag=indexPath.row
        cell.txtGrm.isUserInteractionEnabled=false
        if dictData.euroEditText == "false"{
            cell.txtEuro.isUserInteractionEnabled=false
            cell.btnEditEuro.setImage(UIImage(named: "EditIcon"), for: .normal)
        } else{
            cell.txtEuro.isUserInteractionEnabled=true
            cell.btnEditEuro.setImage(UIImage(named: "DoneIcon"), for: .normal)
        }
        if dictData.grmEditText == "false"{
            cell.btnPlushQty.isUserInteractionEnabled=false
            cell.btnMinusQty.isUserInteractionEnabled=false
            cell.txtGrm.isUserInteractionEnabled=false
            cell.btnEditQTY.setImage(UIImage(named: "EditIcon"), for: .normal)
            cell.btnEditGrm.setImage(UIImage(named: "EditIcon"), for: .normal)
        } else{
            cell.btnEditQTY.setImage(UIImage(named: "DoneIcon"), for: .normal)
            cell.btnPlushQty.isUserInteractionEnabled=true
            cell.btnMinusQty.isUserInteractionEnabled=true
            cell.txtGrm.isUserInteractionEnabled=true
            cell.btnEditGrm.setImage(UIImage(named: "DoneIcon"), for: .normal)
        }
        
        
        cell.txtEuro.text=dictData.user_discount_price
        cell.txtGrm.text=dictData.extra_price
        cell.btnEditGrm.tag=indexPath.row
        cell.btnEditQTY.tag=indexPath.row
        cell.btnEditEuro.tag=indexPath.row
        cell.btnEditQTY.addTarget(self, action: #selector(self.editGrm(sender:)), for: .touchUpInside)
        cell.btnEditGrm.addTarget(self, action: #selector(self.editGrm(sender:)), for: .touchUpInside)
        cell.btnEditEuro.addTarget(self, action: #selector(self.editEuro), for: .touchUpInside)
        cellSetup(cell:cell)
        }
        
        //cell.txtEuro.addTarget(self, action: #selector(self.euroEdit(cell:)), for: .editingDidBegin)
        //cell.txtEuro.addTarget(self, action: #selector(self.gramEdit(cell:)), for: .editingDidBegin)
        
        return cell
    }
    
    @objc func increaseCategoryCount(sender:UIButton){
        let dictData = listDictArr[sender.tag]
       // dictData.apiCall="false"
        let incVal=JSON(dictData.extra_price).intValue+1
        dictData.extra_price=JSON(incVal).stringValue
        self.tableView.reloadData()
//        let dictData = listDictArr[sender.tag]
//        if dictData.grmEditText == "true"{
//            dictData.apiCall="true"
//            self.tableView.reloadData()
//        } else{
//            for item in 0..<listDictArr.count{
//                if item == sender.tag{
//                    listDictArr[item].apiCall="false"
//                    listDictArr[item].euroEditText="false"
//                    listDictArr[item].grmEditText="true"
//                } else{
//                    listDictArr[item].apiCall="false"
//                    listDictArr[item].euroEditText="false"
//                    listDictArr[item].grmEditText="false"
//                }
//            }
//
//
//        }
    }
    
    @objc func decreseCategoryCount(sender:UIButton){
        let dictData = listDictArr[sender.tag]
        //dictData.apiCall="false"
        let incVal=JSON(dictData.extra_price).intValue-1
        if incVal>0{
            dictData.extra_price=JSON(incVal).stringValue
            self.tableView.reloadData()
        }
//        let dictData = listDictArr[sender.tag]
//        if dictData.grmEditText == "true"{
//            dictData.apiCall="true"
//            self.tableView.reloadData()
//        } else{
//            for item in 0..<listDictArr.count{
//                if item == sender.tag{
//                    listDictArr[item].apiCall="false"
//                    listDictArr[item].euroEditText="false"
//                    listDictArr[item].grmEditText="true"
//                } else{
//                    listDictArr[item].apiCall="false"
//                    listDictArr[item].euroEditText="false"
//                    listDictArr[item].grmEditText="false"
//                }
//            }
//
//
//        }
    }
    
    func cellSetup(cell:viewCartCell){
        if self.view.frame.width == 375{
            cell.imgHeight.constant=105
            cell.sativaHeight.constant=24
            cell.sativaWidth.constant=75
            cell.exttriorWidth.constant=85
//            cell.stackViewWidth.constant=120
//            cell.stackViewHeight.constant=30
//            cell.btnEditHeight.constant=32
        } else if self.view.frame.width == 414{
            cell.imgHeight.constant=105
            cell.sativaHeight.constant=26
            cell.sativaWidth.constant=90
            cell.exttriorWidth.constant=100
//            cell.stackViewWidth.constant=150
//            cell.stackViewHeight.constant=30
//            cell.btnEditHeight.constant=32
        } else{
            cell.imgHeight.constant=91
            cell.sativaHeight.constant=20
            cell.sativaWidth.constant=60
            cell.exttriorWidth.constant=70
//            cell.stackViewWidth.constant=100
//            cell.stackViewHeight.constant=25
//            cell.btnEditHeight.constant=30
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        let dictData = listDictArr[indexPath.row]
        if dictData.is_discount == "false"{
            if self.view.frame.width == 375{
                return 198
            } else if self.view.frame.width == 414{
                return 198
            } else{
                return 185
            }
        } else{
            if self.view.frame.width == 375{
                return 217
            } else if self.view.frame.width == 414{
                return 217
            } else{
                return 202
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let dictData = listDictArr[indexPath.row]
        if dictData.is_discount == "false"{
            if self.view.frame.width == 375{
                return 198
            } else if self.view.frame.width == 414{
                return 198
            } else{
                return 185
            }
        } else{
            if self.view.frame.width == 375{
                return 217
            } else if self.view.frame.width == 414{
                return 217
            } else{
                return 202
            }
        }
    }
    
    
    @objc func removeProduct(sender:UIButton){
        let dictData = listDictArr[sender.tag]
        let uiAlert = UIAlertController(title: Shared().title, message: "Are you sure you want to delete this product?".localized , preferredStyle:.alert)
        self.present(uiAlert, animated: true, completion: nil)
        uiAlert.addAction(UIAlertAction(title: "No".localized, style: .default, handler: { action in }))
        uiAlert.addAction(UIAlertAction(title: "Yes".localized, style: .destructive, handler: { action in
           self.deleteToCart(product_id:dictData.product_id, selectedIndexIS: sender.tag)
            uiAlert.dismiss(animated: true, completion: nil)
        }))
    }
    
    @objc func editGrm(sender:UIButton){
        let dictData = listDictArr[sender.tag]
        if dictData.grmEditText == "true"{
            dictData.apiCall="true"
            self.tableView.reloadData()
        } else{
            for item in 0..<listDictArr.count{
                if item == sender.tag{
                    listDictArr[item].apiCall="false"
                    listDictArr[item].euroEditText="false"
                    listDictArr[item].grmEditText="true"
                } else{
                    listDictArr[item].apiCall="false"
                    listDictArr[item].euroEditText="false"
                    listDictArr[item].grmEditText="false"
                }
            }
            
            self.tableView.reloadData()
        }
    }
    
    @objc func editEuro(sender:UIButton){
        let dictData = listDictArr[sender.tag]
        if dictData.euroEditText == "true"{
            dictData.apiCall="true"
            self.tableView.reloadData()
        } else{
            for item in 0..<listDictArr.count{
                if item == sender.tag{
                    listDictArr[item].apiCall="false"
                    listDictArr[item].euroEditText="true"
                    listDictArr[item].grmEditText="false"
                } else{
                    listDictArr[item].apiCall="false"
                    listDictArr[item].euroEditText="false"
                    listDictArr[item].grmEditText="false"
                }
            }
            self.tableView.reloadData()
        }
        
    }
    
}

extension CartScreenVC{
    func getViewCartList(){
        self.tableView.isHidden=true
        self.paymentView.isHidden=true
        //self.priceView.isHidden=true
        self.placeOrderView.isHidden=true
        startAnimating(CGSize(width: 100, height: 100), message: "", type: NVActivityIndicatorType.ballRotate, fadeInAnimation: nil)
        let parameters: Parameters = [
            "user_id" : UserDefaults.standard.object(forKey: "user_id") as! String,
            "language" : "\(Language.language)",
            "club_name" : UserDefaults.standard.object(forKey: "club_name") as! String,
            "macAddress" : Shared().getWifi(),
        ]
        print("\(Shared().webCall)viewCart?language=\(Language.language)&club_name=\(UserDefaults.standard.object(forKey: "club_name") as! String)&user_id=\(UserDefaults.standard.object(forKey: "user_id") as! String)&macAddress=\(Shared().getWifi())")
        Alamofire.request("\(Shared().webCall)viewCart.php", method: .post, parameters: parameters)
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
                            self.Pre_order = JSON(jsonData["Pre_order"]!).stringValue
                            if self.Pre_order == "0"{
                                Shared().showAlert(uIViewController: self, title: Shared().title, message: "You don't have permission.Please contact admin".localized)
                            } else{
                            self.lblPlaceOrder.text = JSON(jsonData["usercredit_title"]!).stringValue
                            let cartCount = JSON(jsonData["cart_count"]!).stringValue
                            if cartCount != "0"{
                                self.item1?.addBadge(number: Int(cartCount)!)
                            } else{
                                self.item1?.removeBadge()
                            }
                                let notification_count = UserDefaults.standard.string(forKey: "notifcount") as? String ?? "0"
                                UIApplication.shared.applicationIconBadgeNumber=JSON(notification_count).intValue
                                if notification_count != "0" {
                                    self.item2?.addBadge(number: Int(notification_count ?? "")!)
                                } else{
                                    self.item2?.removeBadge()
                                }
                            UserDefaults.standard.set(cartCount, forKey: "Badge_cart_count")
                            
                            self.lblEmptyCartErrMsg.isHidden=true
                            self.tableView.isHidden=false
                            self.paymentView.isHidden=false
                            //self.priceView.isHidden=false
                            self.placeOrderView.isHidden=false
                            
                            if let jsonDict = jsonData["data"] as? [[String:Any]]{
                                self.listDictArr.removeAll()
                                let jsonIs = JSON(jsonDict)
                                for item in 0..<jsonIs.count{
                                    let arrObj=HomeCategoryList(json: jsonIs[item])
                                    self.listDictArr.append(arrObj)
                                }
                               // self.paymentView.shadowColor(color: UIColor.black.withAlphaComponent(0.2), border: 1.0, offHeight: 1)
                               // self.paymentView.layer.cornerRadius=10
                               // self.extra_price_count="\(Double(round(100*Double(Shared().componentSepareted(fullValue: "\(JSON(jsonData["user_credit_detail"]!).stringValue)", separatedBy: " "))!)/100))"+" €"
                                self.lblItemTotal.text="\(Double(round(100*Double(Shared().componentSepareted(fullValue: "\(JSON(jsonData["total_price"]!).stringValue)", separatedBy: " "))!)/100))"+" €"
                                self.lblDiscount.text="\(Double(round(100*Double(Shared().componentSepareted(fullValue: "\(JSON(jsonData["user_discount"]!).stringValue)", separatedBy: " "))!)/100))"+" €"
                                self.lblCredit.text="\(Double(round(100*Double(Shared().componentSepareted(fullValue: "\(JSON(jsonData["user_credit"]!).stringValue)", separatedBy: " "))!)/100))"+" €"
                                
                                self.lblPayableItem.text="\(Double(round(100*Double(Shared().componentSepareted(fullValue: "\(JSON(jsonData["user_grand_total"]!).stringValue)", separatedBy: " "))!)/100))"+" €"
                               self.lblTotalItem.text="\(Double(round(100*Double(Shared().componentSepareted(fullValue: "\(JSON(jsonData["user_discountprice"]!).stringValue)", separatedBy: " "))!)/100))"+" €"
                                self.userupdatecredit=JSON(jsonData["userupdatecredit"]!).stringValue
                                self.lblPayAmount.text=JSON(jsonData["user_credit_detail"]!).stringValue
                                self.tableView.reloadData()
                                self.tableViewHeight.constant=self.tableView.contentSize.height
                            }
                        }
                        } else{
                            self.lblEmptyCartErrMsg.isHidden=false
                            //let message : String = JSON(jsonData["message"]!).stringValue
                            //Shared().showAlert(uIViewController: self, title: Shared().error, message: message)
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

//Delete to Cart api call Integration
extension CartScreenVC{
    func deleteToCart(product_id:String,selectedIndexIS:Int){
        startAnimating(CGSize(width: 100, height: 100), message: "", type: NVActivityIndicatorType.ballRotate, fadeInAnimation: nil)
        let parameters: Parameters = [
            "language" : "\(Language.language)",
            "club_name" : UserDefaults.standard.object(forKey: "club_name") as! String,
            "user_id" : UserDefaults.standard.string(forKey: "user_id")!,
            "product_id" : product_id,
            "macAddress" : Shared().getWifi(),
        ]
        print("\(Shared().webCall)deleteCart?language=\(Language.language)&club_name=\(UserDefaults.standard.object(forKey: "club_name") as! String)&user_id=\(UserDefaults.standard.string(forKey: "user_id")!)&product_id=\(product_id)&macAddress=\(Shared().getWifi())")
        Alamofire.request("\(Shared().webCall)deleteCart.php", method: .post, parameters: parameters)
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
                            let cartCount = JSON(jsonData["cart_count"]!).stringValue
                            if cartCount != "0"{
                                self.item1?.addBadge(number: Int(cartCount)!)
                            } else{
                                self.item1?.removeBadge()
                            }
                            
                            let notification_count = UserDefaults.standard.string(forKey: "notifcount") as? String ?? "0"
                            UIApplication.shared.applicationIconBadgeNumber=JSON(notification_count).intValue
                            if notification_count != "0" {
                                self.item2?.addBadge(number: Int(notification_count ?? "")!)
                            } else{
                                self.item2?.removeBadge()
                            }
                            UserDefaults.standard.set(cartCount, forKey: "Badge_cart_count")
                            self.Pre_order = JSON(jsonData["Pre_order"]!).stringValue
                            self.lblEmptyCartErrMsg.isHidden=true
                            if JSON(jsonData["total_price"]!).stringValue == ""{
                                self.tableView.isHidden=true
                                self.paymentView.isHidden=true
                                //self.priceView.isHidden=true
                                self.placeOrderView.isHidden=true
                            } else{
                                self.listDictArr.remove(at: selectedIndexIS)
                                self.tableView.isHidden=false
                                self.paymentView.isHidden=false
                               // self.priceView.isHidden=false
                                self.placeOrderView.isHidden=false
                                self.lblItemTotal.text="\(Double(round(100*Double(Shared().componentSepareted(fullValue: "\(JSON(jsonData["total_price"]!).stringValue)", separatedBy: " "))!)/100))"+" €"
                                self.lblCredit.text="\(Double(round(100*Double(Shared().componentSepareted(fullValue: "\(JSON(jsonData["user_credit"]!).stringValue)", separatedBy: " "))!)/100))"+" €"
                                self.lblDiscount.text="\(Double(round(100*Double(Shared().componentSepareted(fullValue: "\(JSON(jsonData["user_discount"]!).stringValue)", separatedBy: " "))!)/100))"+" €"
                                self.lblPayableItem.text="\(Double(round(100*Double(Shared().componentSepareted(fullValue: "\(JSON(jsonData["user_grand_total"]!).stringValue)", separatedBy: " "))!)/100))"+" €"
                                //user_discountprice
                                self.lblTotalItem.text="\(Double(round(100*Double(Shared().componentSepareted(fullValue: "\(JSON(jsonData["user_discountprice"]!).stringValue)", separatedBy: " "))!)/100))"+" €"
                                self.lblPayAmount.text=JSON(jsonData["user_credit_detail"]!).stringValue
                                self.tableView.reloadData()
                                self.tableViewHeight.constant=self.tableView.contentSize.height
                            }
                            if JSON(jsonData["cart_count"]!).stringValue == "0"{
                                self.lblEmptyCartErrMsg.isHidden=false
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

//Update Qty Or Euro Api call Integration
extension CartScreenVC{
    func editQtyOrEuroCart(product_id:String,selectedIndexIS:Int,extra_price_count:String,product_price:String,flag:String){
        startAnimating(CGSize(width: 100, height: 100), message: "", type: NVActivityIndicatorType.ballRotate, fadeInAnimation: nil)
        let parameters: Parameters = [
            "language" : "\(Language.language)",
            "club_name" : UserDefaults.standard.object(forKey: "club_name") as! String,
            "user_id" : UserDefaults.standard.string(forKey: "user_id")!,
            "product_id" : product_id,
            "qty" : extra_price_count,
            "flag" : flag,
           // "extra_price" : extra_price_count,
            "product_price" : product_price,
            "macAddress" : Shared().getWifi(),
        ]
        print("\(Shared().webCall)updateCart?language=\(Language.language)&club_name=\(UserDefaults.standard.object(forKey: "club_name") as! String)&user_id=\(UserDefaults.standard.string(forKey: "user_id")!)&product_id=\(product_id)&qty=\(extra_price_count)&product_price=\(product_price)&flag=\(flag)&macAddress=\(Shared().getWifi())")
        Alamofire.request("\(Shared().webCall)updateCart.php", method: .post, parameters: parameters)
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
                            //self.Pre_order = JSON(jsonData["Pre_order"]!).stringValue
                            self.listDictArr[selectedIndexIS].apiCall="false"
                            self.listDictArr[selectedIndexIS].euroEditText="false"
                            self.listDictArr[selectedIndexIS].grmEditText="false"
                            self.listDictArr[selectedIndexIS].extra_price_count="\(Double(round(100*Double(Shared().componentSepareted(fullValue: "\(JSON(jsonData["extraprice_total"]!).stringValue)", separatedBy: " "))!)/100))"//JSON(jsonData["extraprice_total"]!).stringValue
                            self.listDictArr[selectedIndexIS].user_discount_price="\(Double(round(100*Double(Shared().componentSepareted(fullValue: "\(JSON(jsonData["user_discount_price"]!).stringValue)", separatedBy: " "))!)/100))"//JSON(jsonData["user_discount_price"]!).stringValue
                            self.listDictArr[selectedIndexIS].extra_price="\(Double(round(100*Double(Shared().componentSepareted(fullValue: "\(JSON(jsonData["qty"]!).stringValue)", separatedBy: " "))!)/100))"//JSON(jsonData["qty"]!).stringValue
                            self.lblItemTotal.text="\(Double(round(100*Double(Shared().componentSepareted(fullValue: "\(JSON(jsonData["total_price"]!).stringValue)", separatedBy: " "))!)/100))"+" €"
                            self.lblCredit.text="\(Double(round(100*Double(Shared().componentSepareted(fullValue: "\(JSON(jsonData["user_credit"]!).stringValue)", separatedBy: " "))!)/100))"+" €"
                            self.lblDiscount.text="\(Double(round(100*Double(Shared().componentSepareted(fullValue: "\(JSON(jsonData["user_discount"]!).stringValue)", separatedBy: " "))!)/100))"+" €"
                            self.lblPayableItem.text="\(Double(round(100*Double(Shared().componentSepareted(fullValue: "\(JSON(jsonData["user_grand_total"]!).stringValue)", separatedBy: " "))!)/100))"+" €"
                            //user_discountprice
                            self.lblTotalItem.text="\(Double(round(100*Double(Shared().componentSepareted(fullValue: "\(JSON(jsonData["user_discountprice"]!).stringValue)", separatedBy: " "))!)/100))"+" €"
                            self.lblPayAmount.text=JSON(jsonData["user_credit_detail"]!).stringValue
                            self.tableView.reloadData()
                            self.tableViewHeight.constant=self.tableView.contentSize.height
                        } else if flag == "0"{
                            self.listDictArr[selectedIndexIS].apiCall="false"
                            self.listDictArr[selectedIndexIS].euroEditText="false"
                            self.listDictArr[selectedIndexIS].grmEditText="false"
                            self.listDictArr[selectedIndexIS].extra_price_count="\(Double(round(100*Double(Shared().componentSepareted(fullValue: "\(JSON(jsonData["extraprice_total"]!).stringValue)", separatedBy: " "))!)/100))"//JSON(jsonData["extraprice_total"]!).stringValue
                            self.listDictArr[selectedIndexIS].user_discount_price="\(Double(round(100*Double(Shared().componentSepareted(fullValue: "\(JSON(jsonData["user_discount_price"]!).stringValue)", separatedBy: " "))!)/100))"//JSON(jsonData["user_discount_price"]!).stringValue
                            self.listDictArr[selectedIndexIS].extra_price="\(Double(round(100*Double(Shared().componentSepareted(fullValue: "\(JSON(jsonData["qty"]!).stringValue)", separatedBy: " "))!)/100))"//JSON(jsonData["qty"]!).stringValue
                            self.lblItemTotal.text="\(Double(round(100*Double(Shared().componentSepareted(fullValue: "\(JSON(jsonData["total_price"]!).stringValue)", separatedBy: " "))!)/100))"+" €"
                            self.lblCredit.text="\(Double(round(100*Double(Shared().componentSepareted(fullValue: "\(JSON(jsonData["user_credit"]!).stringValue)", separatedBy: " "))!)/100))"+" €"
                            self.lblDiscount.text="\(Double(round(100*Double(Shared().componentSepareted(fullValue: "\(JSON(jsonData["user_discount"]!).stringValue)", separatedBy: " "))!)/100))"+" €"
                            self.lblPayableItem.text="\(Double(round(100*Double(Shared().componentSepareted(fullValue: "\(JSON(jsonData["user_grand_total"]!).stringValue)", separatedBy: " "))!)/100))"+" €"
                            //user_discountprice
                            self.lblTotalItem.text="\(Double(round(100*Double(Shared().componentSepareted(fullValue: "\(JSON(jsonData["user_discountprice"]!).stringValue)", separatedBy: " "))!)/100))"+" €"
                            self.lblPayAmount.text=JSON(jsonData["user_credit_detail"]!).stringValue
                            self.tableView.reloadData()
                            self.tableViewHeight.constant=self.tableView.contentSize.height
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

extension CartScreenVC{
    func placeHolderApi(){
        let jsonData = try! JSONSerialization.data(withJSONObject: self.fullDictArr, options: JSONSerialization.WritingOptions.prettyPrinted)
        let jsonString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)! as String
        startAnimating(CGSize(width: 100, height: 100), message: "", type: NVActivityIndicatorType.ballRotate, fadeInAnimation: nil)
        let parameters: Parameters = [
            "language" : "\(Language.language)",
            "club_name" : UserDefaults.standard.object(forKey: "club_name") as! String,
            "macAddress" : Shared().getWifi(),
            "order_request" : jsonString,
        ]
        print("\(Shared().webCall)orderPlace?language=\(Language.language)&club_name=\(UserDefaults.standard.object(forKey: "club_name") as! String)&order_request=\(jsonString)&macAddress=\(Shared().getWifi())")
        Alamofire.request("\(Shared().webCall)orderPlace.php", method: .post, parameters: parameters)
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
                            self.dismissKeyboard()
                            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                            let vc = storyBoard.instantiateViewController(withIdentifier: "OrderSucessVC") as! OrderSucessVC
                            self.navigationController?.pushViewController(vc, animated: true)
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
    
    func getStripeToken(fullDictArrVal:[String:Any],costVal:Double,apiCallScreenVal:String){
        self.btnPlaceOrderOutlet.isEnabled=false
       // startAnimating(CGSize(width: 100, height: 100), message: "", type: NVActivityIndicatorType.ballRotate, fadeInAnimation: nil)
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
                self.btnPlaceOrderOutlet.isEnabled=true
                switch response.result {
                case .success:
                    print("JSON::",response.result.value!)
                    if let jsonData = response.result.value as? [String:Any] {
                        let flag = JSON(jsonData["flag"]!).stringValue
                        if flag == "1"{
                            if let jsonStripe=jsonData["data"] as? [String:Any]{
                                print("jsonStripe===============",JSON(jsonStripe["stripe_key"]!).stringValue)
                                let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                                let vc = storyBoard.instantiateViewController(withIdentifier: "PaymentSelectionVC") as! PaymentSelectionVC
                                vc.fullDictArr=fullDictArrVal
                                vc.donationScreenAmount="\(costVal)"
                                vc.apiCallScreen=apiCallScreenVal
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
