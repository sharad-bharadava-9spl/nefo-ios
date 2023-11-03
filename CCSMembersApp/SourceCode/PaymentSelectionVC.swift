//
//  PaymentSelectionVC.swift
//  CCSMembersApp
//
//  Created by Jaimin Patel on 12/4/19.
//  Copyright © 2019 Jaimin Patel. All rights reserved.
//

import UIKit

class PaymentSelectionVC: UIViewController {
    var apiCallScreen="" //Donation Or Cart Screen
    var fullDictArr=[String:Any]()
    var donationScreenAmount=""
    var donationScreenNotes=""
    var item1:UIBarButtonItem?
    var jsonStripeToken:String=""

    @IBOutlet weak var creditCardView: UIView!
    @IBOutlet weak var applePaymentView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.creditCardView.shadowColor(color: UIColor.black.withAlphaComponent(0.2), border: 1.2, offHeight: 1)
        self.applePaymentView.shadowColor(color: UIColor.black.withAlphaComponent(0.2), border: 1.2, offHeight: 1)
        
        navigationController?.navigationBar.barTintColor = UIColor.white//UIColor(named: "backgroundViewColor")
        navigationController?.navigationBar.topItem?.title = "Payment".localized.uppercased()
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(named: "NavigationText")!, NSAttributedString.Key.font: UIFont(name: "ProductSans-Bold", size: 17)!]
        navigationItem.leftBarButtonItem?.tintColor = UIColor(named: "NavigationText")!
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.removeNavigationBarItem()
        
        var leftBack = Shared().imageWithImage(image: UIImage(named: "whiteBack")!, scaledToSize: CGSize(width: 20, height: 20))
        leftBack = leftBack.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: leftBack, style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.backVC))
        
        navigationController?.navigationBar.barTintColor = UIColor.white//UIColor(named: "backgroundViewColor")
        navigationController?.navigationBar.topItem?.title = "Payment".localized.uppercased()
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(named: "NavigationText")!, NSAttributedString.Key.font: UIFont(name: "ProductSans-Bold", size: 17)!]
        navigationItem.leftBarButtonItem?.tintColor = UIColor(named: "NavigationText")!
        
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
        
        //self.navigationItem.setRightBarButtonItems([item1!,item2], animated: true)
        
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
    
    override func viewDidAppear(_ animated: Bool) {
        navigationController?.navigationBar.barTintColor = UIColor.white//UIColor(named: "backgroundViewColor")
        navigationController?.navigationBar.topItem?.title = "Payment".localized.uppercased()
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(named: "NavigationText")!, NSAttributedString.Key.font: UIFont(name: "ProductSans-Bold", size: 17)!]
        navigationItem.leftBarButtonItem?.tintColor = UIColor(named: "NavigationText")!
    }
    
    @objc func backVC(){
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnCreditCardAction(_ sender: UIButton) {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "PaymentScreenVC") as! PaymentScreenVC
        vc.fullDictArr=self.fullDictArr
        vc.apiCallScreen=self.apiCallScreen
        vc.donationScreenNotes=self.donationScreenNotes
        vc.donationScreenAmount=self.donationScreenAmount
        vc.paymentOption="Credit"
        vc.jsonStripeToken=self.jsonStripeToken
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnApplePayment(_ sender: UIButton) {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "PaymentScreenVC") as! PaymentScreenVC
        vc.fullDictArr=self.fullDictArr
        vc.apiCallScreen=self.apiCallScreen
        vc.donationScreenNotes=self.donationScreenNotes
        vc.donationScreenAmount=self.donationScreenAmount
        vc.paymentOption="Apple"
        vc.jsonStripeToken=self.jsonStripeToken
        self.navigationController?.pushViewController(vc, animated: true)
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
