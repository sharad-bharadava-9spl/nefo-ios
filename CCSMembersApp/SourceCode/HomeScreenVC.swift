//
//  HomeScreenVC.swift
//  CCSMembersApp
//
//  Created by Jaimin Patel on 6/7/19.
//  Copyright © 2019 Jaimin Patel. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SDWebImage
import NVActivityIndicatorView


class HomeScreenVC: UIViewController,NVActivityIndicatorViewable {
    @IBOutlet weak var selectedMainView: UIView!
    @IBOutlet weak var selectedItemName: UILabel!
    @IBOutlet weak var selectedView: UIView!
    @IBOutlet weak var selectedImage: UIImageView!
    @IBOutlet weak var btnViewCart: UIButton!
    @IBOutlet weak var gradientView1: UIView!
    @IBOutlet weak var lblAddToCartContinue: UILabel!
   // @IBOutlet weak var lblAddtoCartPlusTaxes: UILabel!
    @IBOutlet weak var lblAddToCartPrice: UILabel!
    @IBOutlet weak var lblAddToCartItem: UILabel!
    @IBOutlet weak var addToCartView: UIView!
    @IBOutlet weak var productView: UIView!
    @IBOutlet weak var productColletionViewHeight: NSLayoutConstraint!
    @IBOutlet weak var constraintsoptionViewHeight: NSLayoutConstraint!
    @IBOutlet weak var productCollectionView: UICollectionView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var imgBackground: UIImageView!
    
    @IBOutlet weak var pluseView: UIControl!
    @IBOutlet weak var minusView: UIControl!
 
    var produclistDictArr=[HomeCategoryList]()
    var listDictArr=[categoryList]()
    var listDictArrPOS=[categoryList]()
    var selectedIndex:String?
    var selectedCategory:String = ""
    var plusIndex:String?
    var moreOptionImg:String?
    var moreOptionTitle:String?
    var item1:UIBarButtonItem?
    var item2:UIBarButtonItem?
    
    //Customer Permission On/Off and also check in CCSMembersApp wifi range
    var Show_price:String="0"
    var Pre_order:String="0"
    
    
    
    enum ScrollDirection {
        case left
        case right
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        collectionView.dataSource=self
        collectionView.delegate=self
        
        productCollectionView.dataSource=self
        productCollectionView.delegate=self
        
        minusView.isHidden = true
     //   self.imgCard.setImageFromSVG("Icono-donacion")
        self.navigationController?.navigationBar.isHidden=false
        
        navigationController?.navigationBar.barTintColor = UIColor.white//UIColor(named: "backgroundViewColor")
        navigationController?.navigationBar.topItem?.title = "Menu".localized.uppercased()
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(named: "NavigationText"), NSAttributedString.Key.font: UIFont(name: "ProductSans-Bold", size: 17)!]
        navigationItem.leftBarButtonItem?.tintColor = UIColor(named: "NavigationText")
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView=false
        self.view.addGestureRecognizer(tap)
        
        let tap1: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissSelectedImage))
        tap1.cancelsTouchesInView=false
        self.selectedMainView.addGestureRecognizer(tap)
       
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidLayoutSubviews() {
        Shared().setGradientBackground(gradientView:gradientView1)
         //self.btnViewCart.setImageFromSVG("Icono-menu-carrito-w", for: .normal)//.setImage(, for: <#T##UIControl.State#>)
    }
    
    @objc func dismissSelectedImage() {
        self.selectedMainView.isHidden=true
        self.selectedView.isHidden=true
    }
    
    @objc func dismissKeyboard() {
        self.collectionView.contentInset = .zero
        self.collectionView.scrollIndicatorInsets = .zero
        view.endEditing(true)
        self.view.resignFirstResponder()
    }
    
    
    @IBAction func moveToRight(_ sender: UIControl){
        pluseView.isHidden = true
        minusView.isHidden = false
        let collectionBounds = self.productCollectionView.bounds
        let contentOffset = CGFloat(floor(self.productCollectionView.contentOffset.x + collectionBounds.size.width))
        self.moveCollectionToFrame(contentOffset: contentOffset)
    }
    
    @IBAction func moveToleft(_ sender: UIControl){
        pluseView.isHidden = false
        minusView.isHidden = true
        
        let collectionBounds = self.productCollectionView.bounds
        let contentOffset = CGFloat(floor(self.productCollectionView.contentOffset.x - collectionBounds.size.width))
        self.moveCollectionToFrame(contentOffset: contentOffset)
    }
    
    
    func moveCollectionToFrame(contentOffset : CGFloat) {
        let frame: CGRect = CGRect(x : contentOffset ,y : self.productCollectionView.contentOffset.y ,width : self.productCollectionView.frame.width,height : self.productCollectionView.frame.height)
        self.productCollectionView.scrollRectToVisible(frame, animated: true)
        }
    
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if collectionView == productCollectionView {
            if getScrollDirection() == .left {
                self.showScrollDirection(showArrow: .left)
            } else if getScrollDirection() == .right {
                self.showScrollDirection(showArrow: .right)
            }
        }
        
    }
    func showScrollDirection(showArrow: ScrollDirection) {
        if showArrow == .left {
            pluseView.isHidden = false
            minusView.isHidden = true
        }else{
            pluseView.isHidden = true
            minusView.isHidden = false
        }
    }
    
    private var lastContentOffset: CGFloat = 0
    func scrollViewDidScroll(_ scrollView: UIScrollView){

        if lastContentOffset >= scrollView.contentOffset.x && lastContentOffset < scrollView.contentSize.width - scrollView.frame.width {
            // move up
            print("move up")
            self.showScrollDirection(showArrow: .left)
        } else if lastContentOffset < scrollView.contentOffset.x && scrollView.contentOffset.x > 0 {
            // move down
            print("move down")
            self.showScrollDirection(showArrow: .right)
        }
        
        // update the new position acquired
        lastContentOffset = scrollView.contentOffset.x

    }

    
    func getScrollDirection() -> ScrollDirection? {
        guard let collectionView = collectionView else { return nil }

        let scrollVelocity = productCollectionView.panGestureRecognizer.velocity(in: productCollectionView.superview)
        if (scrollVelocity.x > 0.0) {
            
            return .right
        } else if (scrollVelocity.x < 0.0) {
            return .left
           
        } else {
            return nil
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
       // productView.shadowColor(color: UIColor.lightGray.withAlphaComponent(0.6), border: 2, offHeight: 1)
        self.navigationController?.navigationBar.isHidden=false
        self.selectedMainView.isHidden=true
        self.selectedView.isHidden=true
        UserDefaults.standard.set("false", forKey: "ChattingScreenOn")
       // self.lblAddtoCartPlusTaxes.text="plus taxes".localized
        self.lblAddToCartContinue.text="View Cart".localized
        self.selectedIndex="0"
        self.plusIndex="0"
        self.collectionView.isHidden=true
        self.productView.isHidden=true
        self.productCollectionView.isHidden=true
        self.addToCartView.isHidden=true
        self.lblAddToCartPrice.text=""
        self.lblAddToCartItem.text=""
        
        self.setNavigationBarItem()
        self.setLeftAlignTitleView(font: UIFont(name: "ProductSans-Bold", size: 17)!, text: "Menu".localized, textColor: .white)
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
        navigationController?.navigationBar.barTintColor = UIColor.white//UIColor(named: "backgroundViewColor")
        navigationController?.navigationBar.topItem?.title = "Menu".localized.uppercased()
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(named: "NavigationText")!, NSAttributedString.Key.font: UIFont(name: "ProductSans-Bold", size: 17)!]
        navigationItem.leftBarButtonItem?.tintColor = UIColor(named: "NavigationText")!
    }
    
    @objc func notificationScreenRedirection(){
        let storyBoard=UIStoryboard(name: "Main", bundle: nil)
        let vc=storyBoard.instantiateViewController(withIdentifier: "NotificationVC") as! NotificationVC
        let navVC=UINavigationController(rootViewController: vc)
        self.slideMenuController()?.changeMainViewController(navVC, close: true)
    }
    
    
    @IBAction func selectedImageClose(_ sender: UIButton) {
        self.selectedMainView.isHidden=true
        self.selectedView.isHidden=true
    }
    
    
    @objc func keyboardWillShow(notification: NSNotification) {
        //self.scrollView.isScrollEnabled = true
        let userInfo: NSDictionary = notification.userInfo! as NSDictionary
        let keyboardInfo = userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue
        let keyboardSize = keyboardInfo.cgRectValue.size
        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height+110, right: 0)
        self.collectionView.contentInset = contentInsets
        self.collectionView.scrollIndicatorInsets = contentInsets
//        scrollView.contentInset = contentInsets
//        scrollView.scrollIndicatorInsets = contentInsets
    }
    @objc func keyboardWillHide(notification: NSNotification) {
        self.collectionView.contentInset = .zero
        self.collectionView.scrollIndicatorInsets = .zero
    }
    
    
    @IBAction func btnAddToCartAction(_ sender: UIButton) {
        if self.Pre_order == "0"{
            Shared().showAlert(uIViewController: self, title: Shared().title, message: "You don't have permission.Please contact admin".localized)
        } else{
            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyBoard.instantiateViewController(withIdentifier: "CartScreenVC") as! CartScreenVC
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @objc func cartRedirection(){
        if self.Pre_order == "0"{
            Shared().showAlert(uIViewController: self, title: Shared().title, message: "You don't have permission.Please contact admin".localized)
        } else{
            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyBoard.instantiateViewController(withIdentifier: "CartScreenVC") as! CartScreenVC
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func btnUndu(_ sender: UIButton) {
        self.unduOperation()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        navigationController?.navigationBar.barTintColor = UIColor.white//UIColor(named: "backgroundViewColor")
        navigationController?.navigationBar.topItem?.title = "Menu".localized.uppercased()
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(named: "NavigationText")!, NSAttributedString.Key.font: UIFont(name: "ProductSans-Bold", size: 17)!]
        navigationItem.leftBarButtonItem?.tintColor = UIColor(named: "NavigationText")
        
        let when = DispatchTime.now() + 0.2
        DispatchQueue.main.asyncAfter(deadline: when) {
            print("categoryStruct.categoryID",categoryStruct.categoryID)
            print("categoryStruct.categoryDict",categoryStruct.categoryDict)
            print("categoryStruct.categoryIndex",categoryStruct.categoryIndex)
            if categoryStruct.categoryID == nil{
                self.getHomeCategoryList()
            } else{
                self.selectedIndex=categoryStruct.categoryIndex
                self.categoryScreenRedirection(jsonData: categoryStruct.categoryDict!, id: categoryStruct.categoryID!)
            }
        }
        
    }
    
    func categoryScreenRedirection(jsonData:[String:Any],id:String){
        categoryStruct.categoryDict?.removeAll()
        categoryStruct.categoryID=nil
        categoryStruct.categoryIndex=nil
        if let jsonDict = jsonData["data"] as? [[String:Any]]{
            let cartCount = JSON(jsonData["cart_count"]!).stringValue
            if cartCount != "0"{
                self.item1?.addBadge(number: Int(cartCount)!)
            } else{
                self.item1?.removeBadge()
            }
            if cartCount != "0"{
                self.addToCartView.isHidden=false
                self.lblAddToCartItem.text="Product".localized+"\(cartCount + "added".localized)"
                //self.lblAddToCartPrice.text=JSON(jsonData["total_price"]!).stringValue
                if JSON(jsonData["total_price"]!).stringValue == ""{
                    self.lblAddToCartPrice.text="0"
                } else{
                    self.lblAddToCartPrice.text="\(Double(round(100*Double(Shared().componentSepareted(fullValue: "\(JSON(jsonData["total_price"]!).stringValue)", separatedBy: " "))!)/100))"
                }
            } else{
                self.addToCartView.isHidden=true
            }
            self.listDictArr.removeAll()
            let jsonIs = JSON(jsonDict)
            for item in 0..<jsonIs.count{
                let arrObj=categoryList(json: jsonIs[item])
                self.listDictArr.append(arrObj)
                
            }
    
            if self.listDictArr.count != 0{
                self.plusIconSet()
                getProductList(categoryID:id)
            }
        }
    }
    
    func numberOfIndex()->Int{
        /*if self.view.frame.width == 375{
            return 5
        } else if self.view.frame.width == 414{
            return 5
        } else{
            return 5
        }*/
        self.listDictArr.count
    }
    
    func minusIconSet(){
        self.listDictArrPOS.removeAll()
        UIView.animate(withDuration: 0.15,
                       delay: 0.1,
                       options: UIView.AnimationOptions.curveEaseIn,
                       animations: { () -> Void in
                        for item in 0..<self.listDictArr.count{
                            self.listDictArrPOS.append(self.listDictArr[item])
                        }
                        self.listDictArrPOS.append(categoryList(json: "Plush"))
                        self.moreOptionImg="Minus_Icon"
                        self.moreOptionTitle="Less".localized
                        self.productView.isHidden=false
                        self.productCollectionView.isHidden=false
                        self.productCollectionView.reloadData()
                        self.productColletionViewHeight.constant=self.productCollectionView.collectionViewLayout.collectionViewContentSize.height
                        self.constraintsoptionViewHeight.constant=self.productCollectionView.collectionViewLayout.collectionViewContentSize.height
                        self.view.layoutIfNeeded()
                        
                        //self.superview?.layoutIfNeeded()
        }, completion: { Void in
            
            //  self.isOpen = true
        })
        
        
        print("Minus Setup Constraints",self.constraintsoptionViewHeight.constant)
    }
    
    func plusIconSet(){
        self.listDictArrPOS.removeAll()
        UIView.animate(withDuration: 0.15,
                       delay: 0.1,
                       options: UIView.AnimationOptions.curveEaseIn,
                       animations: { () -> Void in
                        for item in 0..<self.listDictArr.count{
                            if item <= self.numberOfIndex(){
                                self.listDictArrPOS.append(self.listDictArr[item])
                            }
                        }
                       // self.listDictArrPOS.append(categoryList(json: "Plush"))
                        self.moreOptionImg="Plus_Icon"
                        self.moreOptionTitle="More".localized
                        self.productView.isHidden=false
                        self.productCollectionView.isHidden=false
                        self.productCollectionView.reloadData()
                        self.productColletionViewHeight.constant=self.productCollectionView.collectionViewLayout.collectionViewContentSize.height
                        self.constraintsoptionViewHeight.constant=self.productCollectionView.collectionViewLayout.collectionViewContentSize.height
                        self.view.layoutIfNeeded()
                        
                        //self.superview?.layoutIfNeeded()
        }, completion: { Void in
            
            //  self.isOpen = true
        })
        print("Plus Setup Constraints",self.constraintsoptionViewHeight.constant)
    }
    
    @objc func moreOption(sender:UIButton){
        if listDictArrPOS.count == numberOfIndex()+1{
            self.minusIconSet()
        } else{
            self.plusIconSet()
        }
    }
    
    func addToCartViewLogic(type:String,price:String){
        var val:String=""
        var totalPrice=0.0
        print("price is",price)
        if type == "plus"{
            //Logic For Total Price
            
            
            if self.lblAddToCartPrice.text != ""{
                print("textVal",self.lblAddToCartPrice.text)
                val=JSON(self.lblAddToCartPrice.text!).stringValue
                val="\(val.dropFirst())"
               // val=componentSepareted(fullValue: val, separatedBy: " ")
                print("Val IS",val)
                totalPrice=Double(val)!.rounded(toPlaces: 1) + Double(price)!.rounded(toPlaces: 1)//roundToPlaces(2)//Double(price)!
            } else{
                totalPrice=Double(price)!.rounded(toPlaces: 1)
            }
            self.lblAddToCartPrice.text="€"+"\(totalPrice)"
            //Logic for Total Items
            if self.lblAddToCartItem.text != ""{
                self.lblAddToCartItem.text="Product".localized+"\(Int(Shared().componentSepareted(fullValue: self.lblAddToCartItem.text!, separatedBy: " "))! + 1)"+" \("added".localized)"
            } else{
                self.lblAddToCartItem.text="Product".localized+"1"+" \("added".localized)"
            }
            self.addToCartView.isHidden=false
            
        } else{
            //Logic For Total Price
            if self.lblAddToCartPrice.text != ""{
                val=JSON(self.lblAddToCartPrice.text!).stringValue
                val="\(val.dropFirst())"
                totalPrice=Double(val)!.rounded(toPlaces: 1) - Double(price)!.rounded(toPlaces: 1)
            } else{
                //totalPrice=Int(price)!
            }
            self.lblAddToCartPrice.text="€"+"\(totalPrice)"
            //Logic for Total Items
            if self.lblAddToCartItem.text != ""{
                self.lblAddToCartItem.text="Product".localized+"\(Int(Shared().componentSepareted(fullValue: self.lblAddToCartItem.text!, separatedBy: " "))! - 1)"+" \("added".localized)"
                if Int(Shared().componentSepareted(fullValue: self.lblAddToCartItem.text!, separatedBy: " "))! == 0 {
                    self.addToCartView.isHidden=true
                } else{
                    self.addToCartView.isHidden=false
                }
            } else{
               // self.lblAddToCartItem.text="1"+" \("Items".localized)"
            }
            
            
        }
    }

}

//CollectionView Method
extension HomeScreenVC:UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,UITextFieldDelegate,gramEuro{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.productCollectionView{
            return listDictArrPOS.count
        } else{
            return produclistDictArr.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.productCollectionView{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "productSelection", for: indexPath) as! productSelection
            cell.btnProduct.roundView(borderWidth: 0.0 , borderColor: .clear)
            
            if indexPath.row == selectedIndex?.intoInt(){
                cell.lblProductName.textColor = UIColor(hexString: "#EBEDEF")
            }else{
                cell.lblProductName.textColor = UIColor(hexString: "#EBEDEF")
            }
            
            let dictData = listDictArrPOS[indexPath.row]
            print("DictData Is",dictData.id)
            cell.btnProduct.backgroundColor=UIColor.black
            if self.selectedIndex == "\(indexPath.row)"{
                //cell.btnProduct.layer.borderWidth=3
                //cell.btnProduct.layer.borderColor=UIColor(named: "selectedCategoryColour")!.cgColor
            } else{
                //cell.btnProduct.layer.borderWidth=0
               // cell.btnProduct.layer.borderColor=UIColor.clear.cgColor
            }
            cell.lblProductName.text=dictData.categoryname.capitalized
           // cell.btnProduct.layer.cornerRadius=5
         //   cell.btnProduct.layer.masksToBounds=true
            cell.btnProduct.backgroundColor=UIColor.clear
            cell.btnProduct.imageEdgeInsets=UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
            if dictData.id == ""{
                cell.btnProduct.backgroundColor=UIColor.clear
                cell.btnProductView.backgroundColor = .clear
                //cell.isUserInteractionEnabled = false
                //cell.btnProduct.backgroundColor = UIColor.clear
                cell.btnProduct.setImage(UIImage(named: self.moreOptionImg!), for: .normal)
                cell.lblProductName.text=self.moreOptionTitle?.uppercased()
                cell.btnProduct.isUserInteractionEnabled=true
                cell.btnProduct.addTarget(self, action: #selector(self.moreOption(sender:)), for: .touchUpInside)
                cell.btnProduct.imageEdgeInsets=UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            } else{
                cell.isUserInteractionEnabled = true
                cell.btnProduct.isUserInteractionEnabled=false
                //cell.btnProduct.sd_setBackgroundImage(with: URL(string:dictData.icon), for: .normal)//setImage(UIImage(named: dictData.icon), for: .normal)
                //cell.btnProduct.setImage(cell.btnProduct.imageView!.sd_setImage(with: URL(string: dictData.icon), placeholderImage: #imageLiteral(resourceName: "backgroundImg")), for: .normal)
                if self.selectedCategory == "\(dictData.id)"{
                    cell.img.image = UIImage(named: dictData.icon)
                    cell.btnProduct.sd_setImage(with: URL(string: dictData.icon), for: .normal,placeholderImage: #imageLiteral(resourceName: "grey-leaf-3x"))
                    cell.btnProductView.backgroundColor=UIColor(hexString: "#33FF99")
                } else{
                    cell.img.image = UIImage(named: dictData.icon)
                    cell.btnProduct.sd_setImage(with: URL(string: dictData.icon), for: .normal,placeholderImage: #imageLiteral(resourceName: "grey-leaf-3x"))
                    cell.btnProductView.backgroundColor=UIColor(hexString: "#D9DEE3")
                }
                //(with: URL(string: dictData.icon), placeholderImage: #imageLiteral(resourceName: "backgroundImg"))
                // cell.btnProduct.imageView!.sd_setImage(with: URL(string: dictData.icon), placeholderImage: #imageLiteral(resourceName: "backgroundImg"))
            }
            return cell
        } else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "homeCell", for: indexPath) as! homeCell
            let dictData = produclistDictArr[indexPath.row]//Error Crash
            cell.delegateGrm=self
            cell.txtGram.placeholder="Gr".localized
            cell.txtEuros.placeholder="Euros".localized
            if targetName != Shared().cannibisAppName {
                cell.addminusStackView.isHidden = false
                cell.gramStckView.isHidden = false
                cell.mainStackView.isHidden = false
                cell.btnPlush.isHidden = false
            }
            if dictData.category_type == "1"{
                cell.addminusStackView.isHidden=false
                cell.gramStckView.isHidden=true
            } else{
                cell.addminusStackView.isHidden=true
                cell.gramStckView.isHidden=false
            }
            
            if dictData.is_discount == "true"{
                cell.discountView.isHidden=false
                if dictData.is_directprice == "false"{
                    cell.lblDiscount.text=dictData.user_discount+" %"
                } else{
                    cell.lblDiscount.text=dictData.user_discount
                }
                
            } else{
                cell.discountView.isHidden=true
                //cell.lblDiscount.text=dictData.user_discount
            }
            
            cell.discountView.isHidden = true
            cell.lblDiscount.isHidden = true
            
            if dictData.plusIconImg == "Plus"{
                cell.txtEuros.isUserInteractionEnabled=true
                cell.txtGram.isUserInteractionEnabled=true
            } else{
                cell.txtEuros.isUserInteractionEnabled=false
                cell.txtGram.isUserInteractionEnabled=false
            }
            cell.txtEuros.text=Shared().componentSepareted(fullValue: dictData.extra_price,separatedBy: " ")
            cell.txtGram.text=dictData.extra_price_count
            if cell.txtEuros.text == "0.0"{
                cell.txtEuros.text=""
            }
            if cell.txtGram.text == "0.0"{
                cell.txtGram.text=""
            }
            cell.txtGram.tag=indexPath.row
            cell.txtEuros.tag=indexPath.row
            cell.lbladdMinusValue.text="\(JSON(dictData.extra_price_count).intValue)"
            cell.minusDelete.tag=indexPath.row
            cell.minusDelete.addTarget(self, action: #selector(self.decreseCategoryCount(sender:)), for: .touchUpInside)
            cell.plusAdd.tag=indexPath.row
            cell.plusAdd.addTarget(self, action: #selector(self.increaseCategoryCount(sender:)), for: .touchUpInside)
            print("Product Sales Price is",dictData.sales_price)
            cell.btnPlush.setImage(UIImage(named: dictData.plusIconImg), for: .normal)
            
             let range = dictData.product_image.components(separatedBy: ".")
            let extention = range.last
                print("ImgWEB-\(extention)")
           
            if extention == "webp" {
                
                cell.imgView.image = UIImage(url: URL(string: dictData.product_image))
                
                
                
            } 
            
            cell.imgView.sd_setImage(with: URL(string: dictData.product_image), placeholderImage: #imageLiteral(resourceName: "ImgProductBG"))
           
            cell.lblDetail.text=dictData.product_name
//            if dictData.flower_type.isEmpty{
//                cell.btnSativa.isHidden=true
//            } else{
//                cell.btnSativa.isHidden=false
//                cell.btnSativa.setTitle(dictData.flower_type, for: .normal)
//            }
//
//            if dictData.grow_type.isEmpty{
//                cell.btnExttrior.isHidden=true
//            } else{
//                cell.btnExttrior.isHidden=false
//                cell.btnExttrior.setTitle(dictData.grow_type, for: .normal)
//            }
//            self.Show_price = "1"
           
            if self.Show_price=="1"{
                cell.lblPrice.isHidden=false
                cell.lblPrice.text = dictData.sales_price //Shared().componentSepareted(fullValue: dictData.sales_price,separatedBy: " ")//dictData
            } else{
                cell.lblPrice.isHidden=true
                cell.lblPrice.text = dictData.sales_price //Shared().componentSepareted(fullValue: dictData.sales_price,separatedBy: " ")//dictData
                //self.dismissKeyboard()
                //Shared().showAlert(uIViewController: self, title: Shared().wifiNoteError, message: Shared().wifiPermissionNote)
            }
            if dictData.add_cart == "1"{
                cell.shadowColor(color: UIColor(named: "AddCreditBG")!.withAlphaComponent(0.6), border: 2, offHeight: 1)
                //cell.layer.cornerRadius=7.0
            } else{
                cell.shadowColor(color: UIColor.black.withAlphaComponent(0.2), border: 1.2, offHeight: 0)
                cell.layer.cornerRadius=7.0
            }
            
            //            cell.layer.masksToBounds=true
//            cell.shadowColor(color: UIColor.black.withAlphaComponent(0.2), border: 2.0, offHeight: 0)
//            cell.layer.cornerRadius=5.0
//            cell.layer.masksToBounds=true
//            cell.imgBGView.shadowColor(color: UIColor.black.withAlphaComponent(0.1), border: 2.0, offHeight: 0)
            //cell.imgBGView.shadowColor(color: UIColor.black.withAlphaComponent(0.2), border: 1.0, offHeight: 1.4)
            //cell.imgBGView.layer.cornerRadius=5.0
            //cell.imgBGView.layer.masksToBounds=true
  //MARK: VIS       //   Shared().applyShadow(view: cell.imgBGView)
            cell.btnPlush.tag = indexPath.row
            cell.btnPlush.addTarget(self, action: #selector(self.addToCartMethod(sender:)), for: .touchUpInside)
         //   if targetName == Shared().cannibisAppName {
//            if dictData.product_description == ""{
//                cell.btnInformation.isHidden=true
//                cell.mainStackView.isHidden = true
//                cell.viewInfo.isHidden = false
//                cell.viewMoreInfo.isHidden = true
//
//            } else{
//                cell.btnInformation.isHidden=false
//                cell.mainStackView.isHidden = false
//                cell.viewInfo.isHidden = false
//
//                if self.Show_price=="1"{
//                    cell.mainStackView.isHidden = false
//                    cell.viewInfo.isHidden = false
//                    cell.viewMoreInfo.isHidden = true
//
//                }else{
//                    cell.mainStackView.isHidden = false
//                    cell.viewInfo.isHidden = true
//                    cell.viewMoreInfo.isHidden = false
//                }
//            }
//
//            if dictData.product_medicaldescription == ""{
//                cell.btnMedicalInformation.isHidden=true
//                cell.mainStackView.isHidden = true
//            } else{
//                cell.btnMedicalInformation.isHidden=false
//                cell.mainStackView.isHidden = false
//            }
//            } else {
//                if dictData.product_description == ""{
//                    cell.btnInformation.isHidden=true
//                    cell.viewInfo.isHidden = false
//                    cell.viewMoreInfo.isHidden = true
//                } else{
////                    cell.btnInformation.isHidden=false
////                    cell.viewInfo.isHidden = false
//                    if self.Show_price=="1"{
//                        cell.viewInfo.isHidden = false
//                        cell.btnInformation.isHidden=false
//                        cell.viewMoreInfo.isHidden = true
//
//                    }else{
//                        cell.viewInfo.isHidden = true
//                        cell.viewMoreInfo.isHidden = false
//                        cell.btnInformation.isHidden=true
//                    }
//                }
//
//                if dictData.product_medicaldescription == ""{
//                    cell.btnMedicalInformation.isHidden=true
//                } else{
//                    cell.btnMedicalInformation.isHidden=false
//                }
//            }
            
            if dictData.flower_type.isEmpty && dictData.grow_type.isEmpty && dictData.product_description.isEmpty && dictData.product_medicaldescription.isEmpty && dictData.extract_type.isEmpty{
                print("~~ Properties not found")
                cell.btnInformation.isHidden=true
                cell.viewInfo.isHidden = true
//                cell.mainStackView.isHidden = true
//                cell.viewMoreInfo.isHidden = true
                
            }else{
                print("~~ Properties found")
                cell.btnInformation.isHidden = false
                cell.viewInfo.isHidden = false
//                cell.mainStackView.isHidden = false
//                cell.viewMoreInfo.isHidden = false
            }
            
            cell.btnActionViewMore.tag=indexPath.row
            cell.btnActionViewMore.addTarget(self, action: #selector(self.informationDescription(sender:)), for: .touchUpInside)
            cell.btnInformation.tag=indexPath.row
            cell.btnMedicalInformation.tag=indexPath.row
            cell.btnInformation.addTarget(self, action: #selector(self.informationDescription(sender:)), for: .touchUpInside)
            cell.btnMedicalInformation.addTarget(self, action: #selector(self.medicalDescription(sender:)), for: .touchUpInside)
            let tapImg = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
            cell.imgBGView.tag=indexPath.row
            cell.imgBGView.addGestureRecognizer(tapImg)
            
            let flexible = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: self, action: nil)
            let toolbarDone = UIToolbar.init()
            let done: UIBarButtonItem = UIBarButtonItem(title: "Done".localized, style: .done, target: self, action: #selector(dismissEuroGram))//UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissKeyboard))
            toolbarDone.sizeToFit()
            toolbarDone.items =  [flexible,done]
            
            cell.txtEuros.inputAccessoryView = toolbarDone
            cell.txtGram.inputAccessoryView = toolbarDone
            if targetName == Shared().cannibisAppName {
                cell.addminusStackView.isHidden = true
                cell.gramStckView.isHidden = true
            }
            
      //  MARK:VISH
            cell.mainStackView.isHidden = true
            cellSetup(cell:cell)
            cell.setNeedsLayout()
            cell.layoutIfNeeded()
            
            return cell
        }
    }
    
    @objc func dismissEuroGram(){
        self.view.endEditing(true)
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        let index=sender?.view?.tag
        let dictData = produclistDictArr[index!]
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "ProductDetailsVC") as! ProductDetailsVC
        vc.imgString = dictData.product_image
        vc.titleString = dictData.product_name
        vc.discString = dictData.product_description
        vc.strProductMedicalDesc = dictData.product_medicaldescription
        vc.priceString = dictData.sales_price
        vc.flowerType = dictData.flower_type
        vc.grow_type = dictData.grow_type
        vc.extract_type = dictData.extract_type
        vc.Show_price = self.Show_price
        self.navigationController?.pushViewController(vc, animated: false)
//        self.selectedImage.sd_setImage(with: URL(string:dictData.product_image), placeholderImage: #imageLiteral(resourceName: "backgroundImg") )
//        self.selectedItemName.text=dictData.product_name
//        //.sd_setBackgroundImage(with: URL(string:dictData.product_image), for: .normal)
//        self.selectedMainView.isHidden=false
//        self.selectedView.isHidden=false
    }
    
    @objc func informationDescription(sender:UIButton){
        let dictData = produclistDictArr[sender.tag]
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "ProductDetailsVC") as! ProductDetailsVC
        vc.imgString = dictData.product_image
        vc.titleString = dictData.product_name
        vc.discString = dictData.product_description
        vc.strProductMedicalDesc = dictData.product_medicaldescription
        vc.priceString = dictData.sales_price
        vc.flowerType = dictData.flower_type
        vc.grow_type = dictData.grow_type
        vc.extract_type = dictData.extract_type
        self.navigationController?.pushViewController(vc, animated: false)
//        let dictData = produclistDictArr[sender.tag]
//        let storyBoard=UIStoryboard(name: "Main", bundle: nil)
//        let vc=storyBoard.instantiateViewController(withIdentifier: "ProductDescriptionVC") as! ProductDescriptionVC
//        vc.productDescription=dictData.product_description
//        vc.itemName="Product Description".localized
//        vc.imgVerify="1"
//        vc.modalPresentationStyle = .overFullScreen
//        self.present(vc, animated: false, completion: nil)
//        let dictData = produclistDictArr[sender.tag]
//        Shared().showAlert(uIViewController: self, title: "Product Description".localized, message: dictData.product_description)
    }
    
    @objc func medicalDescription(sender:UIButton){
        let dictData = produclistDictArr[sender.tag]
        let storyBoard=UIStoryboard(name: "Main", bundle: nil)
        let vc=storyBoard.instantiateViewController(withIdentifier: "ProductDescriptionVC") as! ProductDescriptionVC
        vc.productDescription=dictData.product_description
        vc.itemName="Product Medical Description".localized
        vc.imgVerify="2"
        vc.modalPresentationStyle = .overFullScreen
        self.present(vc, animated: false, completion: nil)
//        let dictData = produclistDictArr[sender.tag]
//        Shared().showAlert(uIViewController: self, title: "Product Medical Description".localized, message: dictData.product_description)
    }
    
    func selectedGrm(sender: Int, txtEuro: String, txtGrm: String) {
        let dictData = produclistDictArr[sender]
        dictData.extra_price=txtEuro
        dictData.extra_price_count=txtGrm
        print("Selected Tag",sender)
        print("txtEuro String",txtEuro)
        print("txtGrm String",txtGrm)
        //self.collectionView.reloadData()
    }
    
    @objc func increaseCategoryCount(sender:UIButton){
        let dictData = produclistDictArr[sender.tag]
        if dictData.plusIconImg == "Plus"{
            plusIconSet()//Changes 31/07/19
            let incVal=JSON(dictData.extra_price_count).intValue+1
            dictData.extra_price_count=JSON(incVal).stringValue
            self.collectionView.reloadData()
        } else{
            
        }
    }
    
    @objc func decreseCategoryCount(sender:UIButton){
        let dictData = produclistDictArr[sender.tag]
        print("dictData.extra_price_count",dictData.extra_price_count)
        if dictData.plusIconImg == "Plus"{
            if JSON(dictData.extra_price_count).doubleValue == 0{
                
            } else{
                plusIconSet()//Changes 31/07/19
                let incVal=JSON(dictData.extra_price_count).intValue-1
                dictData.extra_price_count=JSON(incVal).stringValue
                self.collectionView.reloadData()
            }
        } else{
            
        }
    }
    
    @objc func addToCartMethod(sender:UIButton){
        if self.Pre_order == "1"{
            let dictData = produclistDictArr[sender.tag]
            if dictData.extra_price_count == "0"{
                
            } else{
                if dictData.plusIconImg == "Plus"{
                    print("extraPrice",dictData.extra_price_count)
                    if dictData.extra_price_count != "" && dictData.extra_price_count != "0.0" && dictData.extra_price_count != "0"{
                        self.addToCart(product_id: dictData.product_id, category_type: dictData.category_type, category_id: dictData.category_id,extra_price:dictData.extra_price_count,selectedIndexIS:sender.tag)
                    } else{
                        
                    }
                    
                } else{
                    self.dismissKeyboard()
                    let uiAlert = UIAlertController(title: Shared().title, message: "Are you sure you want to delete this product?".localized , preferredStyle:.alert)
                    self.present(uiAlert, animated: true, completion: nil)
                    uiAlert.addAction(UIAlertAction(title: "No".localized, style: .default, handler: { action in }))
                    uiAlert.addAction(UIAlertAction(title: "Yes".localized, style: .destructive, handler: { action in
                        self.deleteToCart(product_id: dictData.product_id,selectedIndexIS:sender.tag)
                        uiAlert.dismiss(animated: true, completion: nil)
                    }))
                }
            }
        } else{
            self.dismissKeyboard()
            Shared().showAlert(uIViewController: self, title: Shared().wifiNoteError, message: Shared().wifiPermissionNote)
        }
    }
    
    func cellSetup(cell:homeCell){
        
        if self.view.frame.height == 667{
            cell.lblDetail.font=cell.lblDetail.font.withSize(13)
            cell.imageHeight.constant = cell.imgView.frame.size.width //100
            cell.satvanaHeight.constant=18
            cell.detailHeight.constant=18
            cell.btnInfoMedicineHeight.constant=35
//            let dictData = produclistDictArr[indexPath.row]
//            if dictData.product_medicaldescription == "" | dictData.product_medicaldescription == ""{
//                cell.btnMedicalInformation.isHidden=true
//            } else{
//                cell.btnMedicalInformation.isHidden=false
//            }
            
            
//            if self.Pre_order == "0"{
//                cell.bottomViewHeight.constant=0
//             //   cell.mainStackView.isHidden=true
//            } else{
//               // cell.mainStackView.isHidden=false
//                cell.bottomViewHeight.constant=45
//            }
            cell.bottomViewHeight.constant=45
            cell.plushBtnHeight.constant=23
            cell.sativaWidth.constant=55
            cell.extratriorWidth.constant=70
        } else if self.view.frame.height == 812{
            cell.lblDetail.font=cell.lblDetail.font.withSize(13)
            cell.imageHeight.constant = cell.imgView.frame.size.width //110
            cell.satvanaHeight.constant=18
            cell.detailHeight.constant=18
            cell.btnInfoMedicineHeight.constant=38
//            if self.Pre_order == "0"{
//                cell.bottomViewHeight.constant=0
//               // cell.mainStackView.isHidden=true
//            } else{
//                cell.bottomViewHeight.constant=50
//               // cell.mainStackView.isHidden=false
//            }
            cell.bottomViewHeight.constant=50
            cell.plushBtnHeight.constant=23
            cell.sativaWidth.constant=55
            cell.extratriorWidth.constant=70
        } else if self.view.frame.height == 896{
            //label.font = label.font.withSize(20)
            cell.lblDetail.font=cell.lblDetail.font.withSize(16)
            cell.imageHeight.constant = cell.imgView.frame.size.width //115
            cell.satvanaHeight.constant=20
            cell.detailHeight.constant=20
            cell.btnInfoMedicineHeight.constant=36
//            if self.Pre_order == "0"{
//                cell.bottomViewHeight.constant=0
//               // cell.mainStackView.isHidden=true
//            } else{
//                cell.bottomViewHeight.constant=50
//             //   cell.mainStackView.isHidden=false
//            }
            cell.bottomViewHeight.constant=50
            cell.plushBtnHeight.constant=25
            cell.sativaWidth.constant=55
            cell.extratriorWidth.constant=70
        } else if self.view.frame.height == 736{
            cell.lblDetail.font=cell.lblDetail.font.withSize(14)
            cell.imageHeight.constant = cell.imgView.frame.size.width //110
            cell.satvanaHeight.constant=19
            cell.detailHeight.constant=18
            cell.btnInfoMedicineHeight.constant=36
//            if self.Pre_order == "0"{
//                cell.bottomViewHeight.constant=0
//              //  cell.mainStackView.isHidden=true
//            } else{
//                cell.bottomViewHeight.constant=48
//               // cell.mainStackView.isHidden=false
//            }
            cell.bottomViewHeight.constant=48
            cell.plushBtnHeight.constant=24
            cell.sativaWidth.constant=65
            cell.extratriorWidth.constant=80
        } else{
            cell.lblDetail.font=cell.lblDetail.font.withSize(12)
            cell.imageHeight.constant = cell.imgView.frame.size.width //80
            cell.satvanaHeight.constant=18
            cell.detailHeight.constant=18
            cell.btnInfoMedicineHeight.constant=30
//            if self.Pre_order == "0"{
//                cell.bottomViewHeight.constant=0
//              //  cell.mainStackView.isHidden=true
//            } else{
//                cell.bottomViewHeight.constant=40
//              //  cell.mainStackView.isHidden=false
//            }
            cell.plushBtnHeight.constant=22
            cell.sativaWidth.constant=50
            cell.extratriorWidth.constant=65
        }
        //self.collectionView.collectionViewLayout.invalidateLayout()
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if collectionView == productCollectionView{
            self.productCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)

            let dictData = listDictArrPOS[indexPath.row]
            self.selectedCategory = "\(dictData.id)"
            if dictData.id == ""{
                
            } else{
                self.selectedIndex="\(indexPath.row)"
                let when = DispatchTime.now() + 0.3
                DispatchQueue.main.asyncAfter(deadline: when) {
                    self.getProductList(categoryID: dictData.id)
                }
            }
        } else{
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == self.productCollectionView{
            if self.view.frame.width == 375{
                return CGSize(width: 75, height: 80)
            } else if self.view.frame.width == 414{
                return CGSize(width: 70, height: 80)
            } else{
                return CGSize(width: 80, height: 80)
            }
        } else{
            if targetName == Shared().cannibisAppName {
                let itemSize = (collectionView.frame.width - (collectionView.contentInset.left + collectionView.contentInset.right + 16)) / 2
                let dictData = produclistDictArr[indexPath.row]
//                if dictData.product_description == ""{
//                    return CGSize(width: itemSize - 3, height: 200.0)
//                } else{
//                    return CGSize(width: itemSize - 3, height: 250.0)
//                }
//                if dictData.product_medicaldescription == ""{
//                    return CGSize(width: itemSize - 3, height: 200.0)
//                } else{
//                    return CGSize(width: itemSize - 3, height: 250.0)
//                }
                if dictData.product_description == "" {
                    return CGSize(width: itemSize - 3, height: ((itemSize - 3) - 24) + 90)
                } else {
                    return CGSize(width: itemSize - 3, height: ((itemSize - 3) - 24) + 90)
                }
                
                
            } else {
                if self.view.frame.height == 667{
                let itemSize = (collectionView.frame.width - (collectionView.contentInset.left + collectionView.contentInset.right + 16)) / 2
                var itemHeight:CGFloat = 0.0
//                if self.Pre_order == "0"{
//                    itemHeight = collectionView.frame.height / 2.4
//                } else{
//                    itemHeight = collectionView.frame.height / 1.9
//                }
                    itemHeight = ((collectionView.frame.height / 1.9) - 100) + ((itemSize - 3) - 24)
                return CGSize(width: itemSize-3, height: itemHeight)
            } else if self.view.frame.height == 812{
                let itemSize = (collectionView.frame.width - (collectionView.contentInset.left + collectionView.contentInset.right + 16)) / 2
//                var itemHeight:CGFloat = 0.0
//                if self.Pre_order == "0"{
//                    itemHeight = collectionView.frame.height / 2.69
//                } else{
//                    itemHeight = collectionView.frame.height / 2.1
//                }
                let itemHeight = ((collectionView.frame.height / 2.1) - 110) + ((itemSize - 3) - 24)
                return CGSize(width: itemSize-3, height: itemHeight)
            } else if self.view.frame.height == 896{
                let itemSize = (collectionView.frame.width - (collectionView.contentInset.left + collectionView.contentInset.right + 16)) / 2
//                var itemHeight:CGFloat = 0.0
//                if self.Pre_order == "0"{
//                    itemHeight = collectionView.frame.height / 2.90
//                } else{
//                    itemHeight = collectionView.frame.height / 2.35
//                }
                let itemHeight = ((collectionView.frame.height / 2.35) - 115) + ((itemSize - 3) - 24)
                return CGSize(width: itemSize-3, height: itemHeight)
            } else if self.view.frame.height == 736{
                let itemSize = (collectionView.frame.width - (collectionView.contentInset.left + collectionView.contentInset.right + 16)) / 2
//                var itemHeight:CGFloat = 0.0
//                if self.Pre_order == "0"{
//                    itemHeight = collectionView.frame.height / 2.55
//                } else{
//                    itemHeight = collectionView.frame.height / 2
//                }
                let itemHeight = ((collectionView.frame.height / 2) - 110) + ((itemSize - 3) - 24)
                return CGSize(width: itemSize-3, height: itemHeight)
            } else{
                let itemSize = (collectionView.frame.width - (collectionView.contentInset.left + collectionView.contentInset.right + 16)) / 2
//                var itemHeight:CGFloat = 0.0
//                if self.Pre_order == "0"{
//                    itemHeight = collectionView.frame.height / 2.2
//                } else{
//                    itemHeight = collectionView.frame.height / 1.7
//                }
//
                let itemHeight = ((collectionView.frame.height / 1.7) - 80) + ((itemSize - 3) - 24)
                return CGSize(width: itemSize-3, height: itemHeight)
            }
            }
        }
    }
}

//API Integration
extension HomeScreenVC{
    func getHomeCategoryList(){
        
        startAnimating(CGSize(width: 100, height: 100), message: "", type: NVActivityIndicatorType.ballRotate, fadeInAnimation: nil)
        let parameters: Parameters = [
            "user_id" : UserDefaults.standard.object(forKey: "user_id") as! String,
            "language" : "\(Language.language)",
            "club_name" : UserDefaults.standard.object(forKey: "club_name") as! String,
            "macAddress" : Shared().getWifi(),
        ]
        print("\(Shared().webCall)categoryList?user_id=\(UserDefaults.standard.object(forKey: "user_id") as! String)&language=\(Language.language)&club_name=\(UserDefaults.standard.object(forKey: "club_name") as! String)&macAddress=\(Shared().getWifi())")
        Alamofire.request("\(Shared().webCall)categoryList.php", method: .post, parameters: parameters)
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
                                self.selectedIndex="0"
                                self.Show_price=JSON(jsonData["Show_price"]!).stringValue
                                self.Pre_order=JSON(jsonData["Pre_order"]!).stringValue
                                
                                if let jsonDict = jsonData["data"] as? [[String:Any]]{
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
                                    
                                    if cartCount != "0"{
                                        self.addToCartView.isHidden=false
                                        self.lblAddToCartItem.text="Product".localized+"\(cartCount + "added".localized)"
                                        //self.lblAddToCartPrice.text=JSON(jsonData["total_price"]!).stringValue
                                        if JSON(jsonData["total_price"]!).stringValue == ""{
                                            self.lblAddToCartPrice.text="0"
                                        } else{
                                            self.lblAddToCartPrice.text="\(Double(round(100*Double(Shared().componentSepareted(fullValue: "\(JSON(jsonData["total_price"]!).stringValue)", separatedBy: " "))!)/100))"
                                        }
                                    } else{
                                        self.addToCartView.isHidden=true
                                    }
                                    UserDefaults.standard.set(cartCount, forKey: "Badge_cart_count")
                                    self.listDictArr.removeAll()
                                    let jsonIs = JSON(jsonDict)
                                    for item in 0..<jsonIs.count{
                                        let arrObj=categoryList(json: jsonIs[item])
                                        self.listDictArr.append(arrObj)
                                        if let jsonDict = jsonDict[item]["categoryproduct"] as? [[String:Any]]{
                                            self.produclistDictArr.removeAll()
                                            let jsonProductIs = JSON(jsonDict)
                                            for item in 0..<jsonProductIs.count{
                                                let arrObj=HomeCategoryList(json:jsonProductIs[item])
                                                self.produclistDictArr.append(arrObj)
                                            }
                                        }
                                    }
                                    if self.produclistDictArr.count != 0{
                                        self.collectionView.isHidden=false
                                        self.collectionView.reloadData()
                                    }
                                    if self.listDictArr.count != 0{
                                        self.plusIconSet()
                                        let dictData = self.listDictArrPOS[0]
                                        if self.selectedCategory == "" || ((self.selectedCategory.isEmpty) == nil) {
                                            self.selectedCategory = "\(dictData.id)"
                                            DispatchQueue.main.async{
                                                self.getProductList(categoryID: dictData.id)
                                                self.productCollectionView.reloadData()
                                            }
                                        }else{
                                            DispatchQueue.main.async{
                                                self.getProductList(categoryID: self.selectedCategory)
                                                self.productCollectionView.reloadData()
                                            }
                                        }
                                        /*if dictData.id == ""{
                                            
                                        } else{
                                            self.selectedIndex="\(0)"
                                            let when = DispatchTime.now() + 0.3
                                            DispatchQueue.main.asyncAfter(deadline: when) {
                                                self.getProductList(categoryID: dictData.id)
                                                self.productCollectionView.reloadData()
                                            }
                                        }*/
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

extension HomeScreenVC{
    func getProductList(categoryID:String){
        startAnimating(CGSize(width: 100, height: 100), message: "", type: NVActivityIndicatorType.ballRotate, fadeInAnimation: nil)
        let parameters: Parameters = [
            "user_id" : UserDefaults.standard.object(forKey: "user_id") as? String ?? "",
            "language" : "\(Language.language)",
            "club_name" : UserDefaults.standard.object(forKey: "club_name") as? String ?? "",
            "categoryid" : categoryID,
        ]
        print("\(Shared().webCall)productList?user_id=\(UserDefaults.standard.object(forKey: "user_id") as! String)&language=\(Language.language)&club_name=\(UserDefaults.standard.object(forKey: "club_name") as! String)&categoryid=\(categoryID)")
        Alamofire.request("\(Shared().webCall)productList.php", method: .post, parameters: parameters)
            .responseJSON { response in
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()) {
                    self.stopAnimating(nil)
                }
                switch response.result {
                case .success:
                    print("JSONpro::",response.result.value!)
                    if let jsonData = response.result.value as? [String:Any] {
                        let flag = JSON(jsonData["flag"]!).stringValue
                        if flag == "1"{
                            self.Show_price=JSON(jsonData["Show_price"]!).stringValue
                            self.Pre_order=JSON(jsonData["Pre_order"]!).stringValue
                            
                            let cartCount = JSON(jsonData["cart_count"]!).stringValue
                            if cartCount != "0"{
                                self.item1?.addBadge(number: Int(cartCount)!)
                                self.addToCartView.isHidden=false
                                self.lblAddToCartItem.text="Product".localized+"\(cartCount + "added".localized)"
                                //self.lblAddToCartPrice.text=JSON(jsonData["total_price"]!).stringValue
                                if JSON(jsonData["total_price"]!).stringValue == ""{
                                    self.lblAddToCartPrice.text="0"
                                } else{
                                    self.lblAddToCartPrice.text="\(Double(round(100*Double(Shared().componentSepareted(fullValue: "\(JSON(jsonData["total_price"]!).stringValue)", separatedBy: " "))!)/100))"
                                }
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
                            if let jsonDict = jsonData["data"] as? [[String:Any]]{
                                //self.plusIconSet()
                                self.produclistDictArr.removeAll()
                                let jsonProductIs = JSON(jsonDict)
                                for item in 0..<jsonProductIs.count{
                                    let arrObj=HomeCategoryList(json:jsonProductIs[item])
                                    self.produclistDictArr.append(arrObj)
                                }
                                if self.produclistDictArr.count != 0{
                                    self.collectionView.isHidden=false
                                    self.collectionView.reloadData()
                                }
                                self.productCollectionView.reloadData()
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

//AddToCart Api call Integration
extension HomeScreenVC{
    /*language
    club_name
    user_id
    product_id
    category_type = 0 gram , 1 unit , 2 static ( As of now static consider as a gram for design)
    extra_price
    category_id*/
    func addToCart(product_id:String,category_type:String,category_id:String,extra_price:String,selectedIndexIS:Int){
        startAnimating(CGSize(width: 100, height: 100), message: "", type: NVActivityIndicatorType.ballRotate, fadeInAnimation: nil)
        let parameters: Parameters = [
            "language" : "\(Language.language)",
            "club_name" : UserDefaults.standard.object(forKey: "club_name") as! String,
            "user_id" : UserDefaults.standard.string(forKey: "user_id")!,
            "product_id" : product_id,
            "category_type" : category_type,
            "extra_price" : extra_price,
            "category_id" : category_id,
        ]
        print("\(Shared().webCall)addCart?language=\(Language.language)&club_name=\(UserDefaults.standard.object(forKey: "club_name") as! String)&user_id=\(UserDefaults.standard.string(forKey: "user_id")!)&product_id=\(product_id)&category_type=\(category_type)&extra_price=\(extra_price)&category_id=\(category_id)")
        Alamofire.request("\(Shared().webCall)addCart.php", method: .post, parameters: parameters)
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
                            let cartCount = JSON(jsonData["cart_count"]!).stringValue
                            if cartCount != "0"{
                                self.item1?.updateBadge(number: Int(cartCount)!)
                            } else{
                                self.item1?.removeBadge()
                            }
                            
                            let notification_count = JSON(jsonData["notification_count"]!).stringValue
                            UIApplication.shared.applicationIconBadgeNumber=JSON(notification_count).intValue
                            if notification_count != "0" {
                                 self.item2?.updateBadge(number: Int(notification_count)!)
                            } else{
                                self.item2?.removeBadge()
                            }
                            UserDefaults.standard.set(cartCount, forKey: "Badge_cart_count")
                            print("self.selectedIndex!",self.selectedIndex!)
                            print("self.listDictArrPOS",self.listDictArrPOS)
                            if Int(self.selectedIndex!)! > 2 {
                                let dictData = self.listDictArr[Int(self.selectedIndex!)!]
                                if dictData.id == ""{
                                   self.stopAnimating(nil)
                                } else{
                                    // self.selectedIndex="\(indexPath.row)"
                                    let when = DispatchTime.now() + 0.3
                                    DispatchQueue.main.asyncAfter(deadline: when) {
                                        self.getProductList(categoryID: dictData.id)
                                    }
                                }
                            } else{
                                let dictData = self.listDictArrPOS[Int(self.selectedIndex!)!]
                                if dictData.id == ""{
                                    self.stopAnimating(nil)
                                } else{
                                    // self.selectedIndex="\(indexPath.row)"
                                    let when = DispatchTime.now() + 0.3
                                    DispatchQueue.main.asyncAfter(deadline: when) {
                                        self.getProductList(categoryID: dictData.id)
                                    }
                                }
                            }
                            
                            //self.getHomeCategoryList()
//                            self.addToCartViewLogic(type: "plus", price: extra_price)
//                            print("cart_count",JSON(jsonData["flag"]!).stringValue)
//                            self.produclistDictArr[selectedIndexIS].plusIconImg="Minus"
//                            self.collectionView.reloadData()
                        } else{
                            self.stopAnimating(nil)
                            let message : String = JSON(jsonData["message"]!).stringValue
                            Shared().showAlert(uIViewController: self, title: Shared().error, message: message)
                        }
                    }
                    break
                    
                case .failure(let error):
                    self.stopAnimating(nil)
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
extension HomeScreenVC{
    func deleteToCart(product_id:String,selectedIndexIS:Int){
        startAnimating(CGSize(width: 100, height: 100), message: "", type: NVActivityIndicatorType.ballRotate, fadeInAnimation: nil)
        let parameters: Parameters = [
            "language" : "\(Language.language)",
            "club_name" : UserDefaults.standard.object(forKey: "club_name") as! String,
            "user_id" : UserDefaults.standard.string(forKey: "user_id")!,
            "product_id" : product_id,
        ]
        print("\(Shared().webCall)deleteCart?language=\(Language.language)&club_name=\(UserDefaults.standard.object(forKey: "club_name") as! String)&user_id=\(UserDefaults.standard.string(forKey: "user_id")!)&product_id=\(product_id)")
        Alamofire.request("\(Shared().webCall)deleteCart.php", method: .post, parameters: parameters)
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
                            let cartCount = JSON(jsonData["cart_count"]!).stringValue
                            if cartCount != "0"{
                                self.item1?.updateBadge(number: Int(cartCount)!)
                            } else{
                                self.addToCartView.isHidden=true
                                self.item1?.removeBadge()
                            }
                            let notification_count = JSON(jsonData["notification_count"]!).stringValue
                            UIApplication.shared.applicationIconBadgeNumber=JSON(notification_count).intValue
                            if notification_count != "0" {
                                 self.item2?.updateBadge(number: Int(notification_count)!)
                            } else{
                                self.item2?.removeBadge()
                            }
                            
                            UserDefaults.standard.set(cartCount, forKey: "Badge_cart_count")
//                            self.addToCartViewLogic(type: "minus", price: extra_price)
//                            print("cart_count",JSON(jsonData["flag"]!).stringValue)
//                            self.produclistDictArr[selectedIndexIS].plusIconImg="Plus"
//                            self.collectionView.reloadData()
                            if Int(self.selectedIndex!)! > 2 {
                                let dictData = self.listDictArr[Int(self.selectedIndex!)!]
                                if dictData.id == ""{
                                    self.stopAnimating(nil)
                                } else{
                                    // self.selectedIndex="\(indexPath.row)"
                                    let when = DispatchTime.now() + 0.3
                                    DispatchQueue.main.asyncAfter(deadline: when) {
                                        self.getProductList(categoryID: dictData.id)
                                    }
                                }
                            } else{
                                let dictData = self.listDictArrPOS[Int(self.selectedIndex!)!]
                               // self.selectedIndex="\(indexPath.row)"
                                let when = DispatchTime.now() + 0.3
                                DispatchQueue.main.asyncAfter(deadline: when) {
                                    self.getProductList(categoryID: dictData.id)
                                }
                            }
                            //self.getHomeCategoryList()
                        } else{
                            self.stopAnimating(nil)
                            let message : String = JSON(jsonData["message"]!).stringValue
                            Shared().showAlert(uIViewController: self, title: Shared().error, message: message)
                        }
                    }
                    break
                    
                case .failure(let error):
                    self.stopAnimating(nil)
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
    
    func unduOperation(){
        startAnimating(CGSize(width: 100, height: 100), message: "", type: NVActivityIndicatorType.ballRotate, fadeInAnimation: nil)
        let parameters: Parameters = [
            "language" : "\(Language.language)",
            "club_name" : UserDefaults.standard.object(forKey: "club_name") as! String,
            "user_id" : UserDefaults.standard.string(forKey: "user_id")!,
            "macAddress" : Shared().getWifi(),
        ]
        print("\(Shared().webCall)undoCategory?language=\(Language.language)&club_name=\(UserDefaults.standard.object(forKey: "club_name") as! String)&user_id=\(UserDefaults.standard.string(forKey: "user_id")!)&macAddress=\(Shared().getWifi())")
        Alamofire.request("\(Shared().webCall)undoCategory.php", method: .post, parameters: parameters)
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
                            self.getHomeCategoryList()
                        } else{
                            self.stopAnimating(nil)
                            let message : String = JSON(jsonData["message"]!).stringValue
                            Shared().showAlert(uIViewController: self, title: Shared().error, message: message)
                        }
                    }
                    break
                    
                case .failure(let error):
                    self.stopAnimating(nil)
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

extension String{
    
    func intoInt()->Int{
        return (self as NSString).integerValue
    }
}
