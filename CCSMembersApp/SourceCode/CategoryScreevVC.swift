//
//  CategoryScreevVC.swift
//  CCSMembersApp
//
//  Created by Jaimin Patel on 6/10/19.
//  Copyright © 2019 Jaimin Patel. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import NVActivityIndicatorView

class CategoryScreevVC: UIViewController,NVActivityIndicatorViewable {
    @IBOutlet weak var imgBackground: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var item1:UIBarButtonItem?
    var item2:UIBarButtonItem?
    var listDictArr=[categoryList]()
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource=self
        collectionView.delegate=self
        
        self.navigationController?.navigationBar.isHidden=false
        navigationController?.navigationBar.barTintColor = UIColor.white//UIColor(named: "backgroundViewColor")
        navigationController?.navigationBar.topItem?.title = "Categories".localized.uppercased()
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(named: "NavigationText")!, NSAttributedString.Key.font: UIFont(name: "ProductSans-Bold", size: 17)!]
        navigationItem.leftBarButtonItem?.tintColor = UIColor(named: "NavigationText")!
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
       // self.imgBackground.image = UIImage(named : Shared().getImgName())
        
        self.setNavigationBarItem()
        
        var imageShopingCart = Shared().imageWithImage(image: UIImage(named: "Shoping_Cart")!, scaledToSize: CGSize(width: 23, height: 23))
        imageShopingCart = imageShopingCart.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        
        var imageSearch = Shared().imageWithImage(image: UIImage(named: "notification")!, scaledToSize: CGSize(width: 23, height: 23))
        imageSearch = imageSearch.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        if targetName != Shared().cannibisAppName {
        let btn1 = UIButton(type: .custom)
        btn1.setImage(imageShopingCart, for: .normal)
        btn1.frame = CGRect(x: 0, y: 0, width: 28, height: 28)
        btn1.addTarget(self, action:#selector(self.testMethod), for: .touchUpInside)
        item1 = UIBarButtonItem(customView: btn1)
        item1!.removeBadge()
        }
        let btn2 = UIButton(type: .custom)
        btn2.setImage(imageSearch, for: .normal)
        btn2.frame = CGRect(x: 0, y: 0, width: 28, height: 28)
        btn2.addTarget(self, action: #selector(notificationScreenRedirection), for: .touchUpInside)
        item2 = UIBarButtonItem(customView: btn2)
        item2?.removeBadge()
        if targetName != Shared().cannibisAppName {
        self.navigationItem.setRightBarButtonItems([item1!,item2!], animated: true)
        } else {
            self.navigationItem.setRightBarButtonItems([item2!], animated: true)
        }
        navigationController?.navigationBar.barTintColor = UIColor.white//UIColor(named: "backgroundViewColor")
        navigationController?.navigationBar.topItem?.title = "Categories".localized.uppercased()
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(named: "NavigationText")!, NSAttributedString.Key.font: UIFont(name: "ProductSans-Bold", size: 17)!]
        navigationItem.leftBarButtonItem?.tintColor = UIColor(named: "NavigationText")!
    }
    
    @objc func testMethod(){
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "CartScreenVC") as! CartScreenVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func notificationScreenRedirection(){
        let storyBoard=UIStoryboard(name: "Main", bundle: nil)
        let vc=storyBoard.instantiateViewController(withIdentifier: "NotificationVC") as! NotificationVC
        let navVC=UINavigationController(rootViewController: vc)
        slideMenuController()?.changeMainViewController(navVC, close: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        navigationController?.navigationBar.barTintColor = UIColor.white//UIColor(named: "backgroundViewColor")//Shared().hexStringToUIColor("#00A0D6")
        navigationController?.navigationBar.topItem?.title = "Categories".localized.uppercased()
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(named: "NavigationText")!, NSAttributedString.Key.font: UIFont(name: "ProductSans-Bold", size: 17)!]
        navigationItem.leftBarButtonItem?.tintColor = UIColor(named: "NavigationText")!
        let when = DispatchTime.now() + 0.2
        DispatchQueue.main.asyncAfter(deadline: when) {
            self.getCategoryList()
        }
    }
}

extension CategoryScreevVC:UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return listDictArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "categoryCell", for: indexPath) as! categoryCell
        let dictData = listDictArr[indexPath.row]
        cell.lblName.text = dictData.categoryname.uppercased()
        cell.lblCount.text=dictData.product_count
        cell.imgView.sd_setImage(with: URL(string:dictData.icon), placeholderImage: #imageLiteral(resourceName: "backgroundImg"))
        cell.imgView.shadowColor(color: UIColor.black.withAlphaComponent(0.2), border: 1.2, offHeight: 1)
        cell.imgView.layer.cornerRadius = 5.0
        cell.imgView.layer.masksToBounds=true
        //Shared().applyShadow(view: cell)
        cell.shadowColor(color: UIColor.black.withAlphaComponent(0.2), border: 1.2, offHeight: 1)
        cell.layer.cornerRadius = 5.0
        cell.layoutIfNeeded()
        //cell.layer.masksToBounds=true
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let dictData = listDictArr[indexPath.row]
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        var vc: UIViewController!
        let vcCon = storyboard.instantiateViewController(withIdentifier: "HomeScreenVC") as! HomeScreenVC
        categoryStruct.categoryID=dictData.id
        categoryStruct.categoryIndex="\(indexPath.row)"
        vc = UINavigationController(rootViewController: vcCon)
        self.slideMenuController()?.changeMainViewController(vc, close: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        if self.view.frame.height == 667{
//            return CGSize(width: (self.collectionView.frame.width/2)-4, height:  (self.collectionView.frame.width/2))
//        } else if self.view.frame.height == 812{
//            return CGSize(width: (self.collectionView.frame.width/2)-4, height:  (self.collectionView.frame.width/2))
//        } else if self.view.frame.height == 896{
//           return CGSize(width: (self.collectionView.frame.width/2)-4, height:  (self.collectionView.frame.width/2))
//        } else if self.view.frame.height == 736{
//            return CGSize(width: (self.collectionView.frame.width/2)-4, height:  (self.collectionView.frame.width/2))
//        } else{
//            return CGSize(width: (self.collectionView.frame.width/2)-4, height:  (self.collectionView.frame.width/2))
//        }
        return CGSize(width:self.collectionView.frame.width, height: 60)
    }
}

extension CategoryScreevVC{
    func getCategoryList(){
        startAnimating(CGSize(width: 100, height: 100), message: "", type: NVActivityIndicatorType.ballRotate, fadeInAnimation: nil)
        let parameters: Parameters = [
            "language" : "\(Language.language)",
            "club_name" : UserDefaults.standard.object(forKey: "club_name") as! String,
            "user_id" : UserDefaults.standard.object(forKey: "user_id") as! String,
        ]
    
        print("\(Shared().webCall)homecategoryList?language=\(Language.language)&club_name=\(UserDefaults.standard.object(forKey: "club_name") as! String)&user_id=\(UserDefaults.standard.object(forKey: "user_id") as! String)")
        Alamofire.request("\(Shared().webCall)homecategoryList.php", method: .post, parameters: parameters)
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
                                categoryStruct.categoryDict=jsonData
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
                                self.listDictArr.removeAll()
                                let jsonIs = JSON(jsonDict)
                                for item in 0..<jsonIs.count{
                                    let arrObj=categoryList(json: jsonIs[item])
                                    self.listDictArr.append(arrObj)
                                }
                                if self.listDictArr.count != 0{
                                    self.collectionView.isHidden=false
                                    self.collectionView.reloadData()
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
    
}
