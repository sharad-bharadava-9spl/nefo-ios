//
//  OrderSucessVC.swift
//  CCSMembersApp
//
//  Created by Jaimin Patel on 8/2/19.
//  Copyright © 2019 Jaimin Patel. All rights reserved.
//

import UIKit

class OrderSucessVC: UIViewController {

    @IBOutlet weak var btnGoToHome: UIButton!
    @IBOutlet weak var lblOrderSucessMsg: UILabel!
   // @IBOutlet weak var orderScuessIMG: UIImageView!
    
    var item1:UIBarButtonItem?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden=false
        navigationController?.navigationBar.barTintColor = UIColor.white//UIColor(named: "backgroundViewColor")
        navigationController?.navigationBar.topItem?.title = "Order Success".localized.uppercased()
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(named: "NavigationText")!, NSAttributedString.Key.font: UIFont(name: "ProductSans-Bold", size: 17)!]
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItem.Style.plain, target: nil, action: nil)
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
//        let jeremyGif = UIImage.gifImageWithName("orderScucess")
//       self.orderScuessIMG.image=jeremyGif
     self.navigationController?.navigationBar.isHidden=false
        navigationController?.navigationBar.barTintColor = UIColor.white//UIColor(named: "backgroundViewColor")
        navigationController?.navigationBar.topItem?.title = "Order Success".localized.uppercased()
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(named: "NavigationText")!, NSAttributedString.Key.font: UIFont(name: "ProductSans-Bold", size: 17)!]
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItem.Style.plain, target: nil, action: nil)
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
        let item2 = UIBarButtonItem(customView: btn2)
        
     //   self.navigationItem.setRightBarButtonItems([item1!,item2], animated: true)
        
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
    
    @objc func cartRedirection(){
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "CartScreenVC") as! CartScreenVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func setupLanguage(){
        self.lblOrderSucessMsg.text="Your order has been placed sucessfully!!".localized
        self.btnGoToHome.setTitle("Go To Home".localized, for: .normal)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden=false
        navigationController?.navigationBar.barTintColor = UIColor.white//UIColor(named: "backgroundViewColor")
        navigationController?.navigationBar.topItem?.title = "Order Success".localized.uppercased()
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(named: "NavigationText")!, NSAttributedString.Key.font: UIFont(name: "ProductSans-Bold", size: 17)!]
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItem.Style.plain, target: nil, action: nil)
    }
    
    
    @IBAction func btnOrderSucess(_ sender: UIButton) {
        for controller in self.navigationController!.viewControllers as Array {
            if controller.isKind(of: HomeScreenVC.self) {
                self.navigationController!.popToViewController(controller, animated: true)
                break
            }
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
