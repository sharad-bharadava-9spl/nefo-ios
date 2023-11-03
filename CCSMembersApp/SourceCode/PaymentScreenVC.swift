//
//  PaymentScreenVC.swift
//  CCSMembersApp
//
//  Created by Jaimin Patel on 7/18/19.
//  Copyright © 2019 Jaimin Patel. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SlideMenuControllerSwift
import NVActivityIndicatorView
import SkyFloatingLabelTextField
import Stripe
import ActionSheetPicker_3_0
import PassKit

class PaymentScreenVC: UIViewController,UITextFieldDelegate,NVActivityIndicatorViewable{

   // @IBOutlet weak var btnChoosePaymentOption: UIButton!
    @IBOutlet weak var creditCardView: UIView!
    @IBOutlet weak var exprycvcStackView: UIStackView!
    @IBOutlet weak var btnPayNowOutlet: UIButton!
    @IBOutlet weak var txtCardNumber: SkyFloatingLabelTextFieldWithIcon!
    //@IBOutlet weak var txtCardNumber: SkyFloatingLabelTextField!
    @IBOutlet weak var txtExpireDate: SkyFloatingLabelTextField!
    @IBOutlet weak var txtCVC: SkyFloatingLabelTextField!
    @IBOutlet weak var imgBackground: UIImageView!
    var apiCallScreen="" //Donation Or Cart Screen
    var donationScreenAmount=""
    var donationScreenNotes=""
    var fullDictArr=[String:Any]()
    var paymentSelection:[String] = []
    var paymentOption:String=""
    
    //Apple Payment Regarding
    var paymentRequest: PKPaymentRequest!
    var transactionId = ""
    var status = ""
    var amount = 0
    var item1:UIBarButtonItem?
    var jsonStripeToken:String=""
    var stripeTokenIS:String=""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.txtCardNumber.delegate=self
        self.txtExpireDate.delegate=self
        self.txtCVC.delegate=self
        
        self.creditCardView.shadowColor(color: UIColor.black.withAlphaComponent(0.2), border: 1.2, offHeight: 1)
        self.txtCardNumber.placeholder="Card number".localized
        self.txtExpireDate.placeholder="Expiration date".localized
        self.txtCVC.placeholder="CVC".localized
        self.btnPayNowOutlet.setTitle("PAY NOW".localized, for: .normal)
       // self.btnChoosePaymentOption.setTitle("Choose Payment Options".localized, for: .normal)
        
        self.btnPayNowOutlet.isHidden=true
        self.txtCardNumber.isHidden=true
        self.exprycvcStackView.isHidden=true
        self.paymentSelection=["Pay with Credit/Debit Card".localized,"Pay with Apple".localized]
        self.navigationController?.navigationBar.isHidden=false
        
        navigationController?.navigationBar.barTintColor = UIColor.white//UIColor(named: "backgroundViewColor")
        navigationController?.navigationBar.topItem?.title = "Payment".localized.uppercased()
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(named: "NavigationText")!, NSAttributedString.Key.font: UIFont(name: "ProductSans-Bold", size: 17)!]
        navigationItem.leftBarButtonItem?.tintColor = UIColor(named: "NavigationText")!
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(tap)
        
        self.setupToolBar()
        
        // Do any additional setup after loading the view.
    }
    
    func setupToolBar(){
        let flexible = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: self, action: nil)
        let toolbar1 = UIToolbar()
        toolbar1.sizeToFit()
        toolbar1.center = CGPoint(x: view.frame.width/2, y: 100)
        
        let doneBtn1 = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.done, target: self, action: #selector(self.dismissKeyboard))
        let nextExpire = UIBarButtonItem(title: "Next".localized, style:.done, target:self, action: #selector(self.nextExpireDate))
        toolbar1.items=[nextExpire,flexible, doneBtn1]
        self.txtCardNumber.inputAccessoryView = toolbar1
        
        let toolbar2 = UIToolbar()
        toolbar2.sizeToFit()
        toolbar2.center = CGPoint(x: view.frame.width/2, y: 100)
        
        let doneBtn2 = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.done, target: self, action: #selector(self.dismissKeyboard))
        let nextCVC = UIBarButtonItem(title: "Next".localized, style:.done, target:self, action: #selector(self.nextDone))
        toolbar2.items=[nextCVC,flexible, doneBtn2]
        self.txtExpireDate.inputAccessoryView = toolbar2
        
        let toolbar3 = UIToolbar()
        toolbar3.sizeToFit()
        toolbar3.center = CGPoint(x: view.frame.width/2, y: 100)
        
        let doneBtn3 = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.done, target: self, action: #selector(self.dismissKeyboard))
        toolbar3.items=[flexible, doneBtn3]
        self.txtCVC.inputAccessoryView = toolbar3
    }
    
    @objc func nextExpireDate() {
        self.txtExpireDate.becomeFirstResponder()
    }
    
    @objc func nextDone() {
        self.txtCVC.becomeFirstResponder()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("Encoding Text IS=========self.jsonStripeToken",self.jsonStripeToken)
        let decodedData = Data(base64Encoded: self.jsonStripeToken)!
        let decodedString = String(data: decodedData, encoding: .utf8)!
        
        self.stripeTokenIS=decodedString//String(utf8String: self.jsonStripeToken.cString(using: String.Encoding.utf8)!)!//(UTF8String: self.jsonStripeToken.cStringUsingEncoding(NSUTF8StringEncoding))//self.jsonStripeToken
        print("Encoding Text IS=========self.stripeTokenIS",decodedString)
        self.removeNavigationBarItem()
      //  self.imgBackground.image = UIImage(named : Shared().getImgName())
        
        var leftBack = Shared().imageWithImage(image: UIImage(named: "whiteBack")!, scaledToSize: CGSize(width: 20, height: 20))
        leftBack = leftBack.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: leftBack, style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.backVC))
        
        navigationController?.navigationBar.barTintColor = UIColor.white//UIColor(named: "backgroundViewColor")
        navigationController?.navigationBar.topItem?.title = "Payment".localized.uppercased()
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(named: "NavigationText")!, NSAttributedString.Key.font: UIFont(name: "ProductSans-Bold", size: 17)!]
        navigationItem.leftBarButtonItem?.tintColor = UIColor(named: "NavigationText")!
        if paymentOption=="Credit"{
            self.btnPayNowOutlet.isHidden=false
            self.txtCardNumber.isHidden=false
            self.exprycvcStackView.isHidden=false
            self.imgBackground.isHidden=true
            self.creditCardView.isHidden=false
        } else if paymentOption=="Apple"{
            self.imgBackground.isHidden=false
            self.btnPayNowOutlet.isHidden=true
            self.txtCardNumber.isHidden=true
            self.exprycvcStackView.isHidden=true
            self.creditCardView.isHidden=true
            self.applePayment()
        } else{
            
        }
        
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
        
       // self.navigationItem.setRightBarButtonItems([item1!,item2], animated: true)
        
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
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
        self.view.resignFirstResponder()
    }
    
    @objc func backVC(){
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnChoosePayment(_ sender: UIButton) {
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        
        let clubOptionPicker = ActionSheetStringPicker(title: "Select Payment".localized, rows: self.paymentSelection, initialSelection: 0, doneBlock: { (pickerSheet, selectedIndex, selectedValue) in
            print("Selected language option index",selectedIndex)
            if selectedIndex == 0{
                self.btnPayNowOutlet.isHidden=false
                self.txtCardNumber.isHidden=false
                self.exprycvcStackView.isHidden=false
            } else{
                self.btnPayNowOutlet.isHidden=true
                self.txtCardNumber.isHidden=true
                self.exprycvcStackView.isHidden=true
                self.applePayment()
            }
            //self.btnChoosePaymentOption.setTitle(selectedValue as? String, for: .normal)
            
        }, cancel: {pickerSheet in return }, origin: (sender as AnyObject).superview!)
        
        clubOptionPicker?.pickerTextAttributes = [NSAttributedString.Key.font: UIFont(name: "ProductSans-Medium", size: 15)!, NSAttributedString.Key.paragraphStyle: paragraph]
        clubOptionPicker?.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "ProductSans-Medium", size: 17)!]
        
        let btnDone = UIBarButtonItem(title: "Done".localized, style: .plain, target: self, action: nil)
        btnDone.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "ProductSans-Medium", size: 16)!], for: .normal)
        clubOptionPicker?.setDoneButton(btnDone)
        
        let btnCancel = UIBarButtonItem(title: "Cancel".localized, style: .plain, target: self, action: nil)
        btnCancel.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "ProductSans-Medium", size: 16)!], for: .normal)
        clubOptionPicker?.setCancelButton(btnCancel)
        clubOptionPicker?.show();
    }
    
    func applePayment(){
        //merchant.com.iflair.cannabisapp
        let paymentRequest = PKPaymentRequest()
        paymentRequest.currencyCode = "EUR"
        paymentRequest.countryCode = "FR"
        paymentRequest.merchantIdentifier = "\(appDelegateShared.MERCHANT_ID)"
        // Payment networks array
        //.amex
        //.visa
        //.masterCard
        //.discover
        //.carteBancaires
        //.cartesBancaires
        //.chinaUnionPay
        //.eftpos
        //.electron
        //.elo
        //.idCredit
        //.interac
        //.JCB
        //.mada
        //.maestro
        //let paymentNetworks = [PKPaymentNetwork.amex, .visa, .masterCard, .discover, .carteBancaires, .cartesBancaires, .chinaUnionPay, .eftpos, .electron, .elo, .idCredit, .interac, .JCB, .mada, .maestro, .privateLabel, .quicPay , .suica, .vPay]
        var paymentNetworks = [PKPaymentNetwork.amex, .visa, .masterCard, .discover, .carteBancaires, .chinaUnionPay,.idCredit, .interac, .JCB, .privateLabel, .quicPay , .suica]
        if #available(iOS 11.2, *) {
            if #available(iOS 12.0, *) {
                if #available(iOS 12.1.1, *) {
                    paymentNetworks = [PKPaymentNetwork.amex, .visa, .masterCard, .discover, .carteBancaires, .cartesBancaires, .chinaUnionPay, .eftpos, .electron, .elo, .idCredit, .interac, .JCB, .mada, .maestro, .privateLabel, .quicPay , .suica, .vPay]
                } else{
                    paymentNetworks = [PKPaymentNetwork.amex, .visa, .masterCard, .discover, .carteBancaires, .cartesBancaires, .chinaUnionPay, .eftpos, .electron, .idCredit, .interac, .JCB, .maestro, .privateLabel, .quicPay , .suica, .vPay]
                }
                
            } else {
                paymentNetworks = [PKPaymentNetwork.amex, .visa, .masterCard, .discover, .carteBancaires, .cartesBancaires, .chinaUnionPay, .idCredit, .interac, .JCB,.privateLabel, .quicPay , .suica]
            }
        } else {
             paymentNetworks = [PKPaymentNetwork.amex, .visa, .masterCard, .discover, .carteBancaires, .chinaUnionPay,.idCredit, .interac, .JCB, .privateLabel, .quicPay , .suica]
        }
        
        if PKPaymentAuthorizationViewController.canMakePayments(usingNetworks:        paymentNetworks)
        {
            paymentRequest.supportedNetworks = paymentNetworks
            paymentRequest.merchantCapabilities = .capability3DS
            print("self.donationScreenAmount",self.donationScreenAmount)
            let item = PKPaymentSummaryItem(label: "to CCS Members App", amount: NSDecimalNumber(floatLiteral:(self.donationScreenAmount as NSString).doubleValue))//(string: "\(self.donationScreenAmount)"))
            paymentRequest.paymentSummaryItems = [item]
            let applePayVC = PKPaymentAuthorizationViewController(paymentRequest: paymentRequest)
            applePayVC!.delegate = self
            self.present(applePayVC!, animated: true, completion: nil)
        }
        else
        {
            // Notify the user that he/she needs to set up the Apple Pay on the device
            // Below code calls a common function to display alert message. You can either create an alert or  can just print something on console.
            // CommonMethods.displayAlert(message: "Apple Pay is not available on this device.", viewController: self)
            print("Apple Pay is not available on this device")
            //Please first add at least one credit card to your Apple Wallet.
            Shared().showAlert(uIViewController: self, title: Shared().error, message: "Please first add at least one credit card to your Apple Wallet.".localized)
        }
    }
    
    @IBAction func btnPayNow(_ sender: UIButton) {
        let cardNum :String = (self.txtCardNumber.text!.trimmingCharacters(in: .whitespacesAndNewlines))
        let cvc :String = (self.txtCVC.text!.trimmingCharacters(in: .whitespacesAndNewlines))
        
        let str1 :String = self.txtExpireDate.text!
        var month : String!
        var year :String!
        
        if let range = str1.range(of: "/") {
            let firstPart = str1[str1.startIndex..<range.lowerBound]
            month  = "\(firstPart)"
        }
        
        let split = str1.split(separator: "/")
        year = String(split.suffix(1).joined(separator: ["/"]))
        
        if cardNum == "" {
            Shared().showAlert(uIViewController: self, title: Shared().error, message: "Please enter card number.".localized)
        } else if self.txtExpireDate.text! == "" {
            Shared().showAlert(uIViewController: self, title: Shared().error, message: "Please enter expiry date.".localized)
        } else if cvc == "" {
            Shared().showAlert(uIViewController: self, title: Shared().error, message: "Please enter cvc number.".localized)
        } else{
            self.dismissKeyboard()
            let creditCard: STPCardParams = STPCardParams()
            creditCard.number = cardNum
            creditCard.expMonth = UInt(month)!
            creditCard.expYear =  UInt(year)!
            creditCard.cvc = cvc
            print("creditCard::",creditCard)
            getStripeToken(card: creditCard)
        }
    }
    
    func getStripeToken(card:STPCardParams) {
        print("================self.stripeTokenIS",self.stripeTokenIS)
        STPAPIClient.shared.publishableKey = self.stripeTokenIS
        startAnimating(CGSize(width: 100, height: 100), message: "", type: NVActivityIndicatorType.ballRotate, fadeInAnimation: nil)
        STPAPIClient.shared.createToken(withCard: card) { token, error in
//            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()) {
//                self.stopAnimating(nil)
//            }
            if let token = token {
                print("Before self.fullDictArr",self.fullDictArr)
                print(token)
                self.fullDictArr["stripe_token"]="\(token)"
                print("After self.fullDictArr",self.fullDictArr)
                if self.apiCallScreen == "DonationScreen"{
                    self.donationApi(stripe_token: "\(token)")
                } else if self.apiCallScreen == "CartScreen"{
                    self.placeHolderApi()
                }
            }
            else {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()) {
                    self.stopAnimating(nil)
                }
                print(error!.localizedDescription)
                Shared().showAlert(uIViewController: self, title: Shared().error, message: "\(error!.localizedDescription)")
            }
        }
    }
    
}

extension PaymentScreenVC:PKPaymentAuthorizationViewControllerDelegate{
    func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, completion: @escaping (PKPaymentAuthorizationStatus) -> Void)
    {
        // Payment token can be found like this
        
        //Stripe.setDefaultPublishableKey("pk_test_aZSVCNprtniKhzrkIu8mUZQs00yATzHloY")  // Replace With Your Own Key!
        StripeAPI.defaultPublishableKey = self.stripeTokenIS
        StripeAPI.paymentRequest(
            withMerchantIdentifier: "\(appDelegateShared.MERCHANT_ID)",
            country: "", currency: "")
       // Stripe.paymentRequest(withMerchantIdentifier: "merchant.com.iflair.cannabisapp")
        STPAPIClient.shared.createToken(with: payment) {
            (token, error) -> Void in
            
            if (error != nil) {
                print(error)
                
                completion(.failure)
               
                print(error!.localizedDescription)
                Shared().showAlert(uIViewController: self, title: Shared().error, message: "\(error!.localizedDescription)")
                return
            } else{
                print("Apple Payment Token Is",token)
                print("Apple Payment Token Is token ID ====>>>>>====",token?.tokenId)
                completion(.success)
                let when = DispatchTime.now() + 2
                DispatchQueue.main.asyncAfter(deadline: when) {
                    self.startAnimating(CGSize(width: 100, height: 100), message: "", type: NVActivityIndicatorType.ballRotate, fadeInAnimation: nil)
                    print("Before self.fullDictArr",self.fullDictArr)
                    print(token)
                    self.fullDictArr["stripe_token"]="\(token!)"
                    print("After self.fullDictArr",self.fullDictArr)
                    if self.apiCallScreen == "DonationScreen"{
                        self.donationApi(stripe_token: "\(token!)")
                    } else if self.apiCallScreen == "CartScreen"{
                        self.placeHolderApi()
                    }
                }
                
                
                print("Apple Payment Token Is1",token)
                print("Apple Payment Token Is token ID1 ====>>>>>====",token?.tokenId)
            }
            print(payment.token)
        }
    }
    
    
    
}

extension PaymentScreenVC{
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        guard let currentText = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) else { return true }
        if textField == self.txtCardNumber {
            let cardBrand = STPCardValidator.brand(forNumber: textField.text!)
            let cardImage = STPImageLibrary.cardBrandImage(for: cardBrand)
            print("cardImage====================>>>>>>>>>=======",cardImage)
            print("cardBrand====================>>>>>>>>>=======",cardBrand.rawValue)
            
            
            //let stringText=string
            let textStr=textField.text!+string
            if textStr.count > 1{
                self.txtCardNumber.iconImage=cardImage
            } else{
                self.txtCardNumber.iconImage=UIImage(named: "CardNumber")

            }
            if range.location == 19 {
                return false
            }
            textField.text = currentText.grouping(every: 4, with: " ")
            
            return false
        } else if textField == self.txtExpireDate{
            if(string.trimmingCharacters(in: .whitespacesAndNewlines) == ""){
                if ((textField.text?.count)! >= 1  && string.count == 0){
                    if range.location == 5 {
                        return false
                    }
                    textField.text = currentText.grouping(every: 2, with: "/")
                } else{
                    
                }
            } else{
                if range.location == 5 {
                    return false
                }
                textField.text = currentText.grouping(every: 2, with: "/")
            }
            return false
        } else if textField == self.txtCVC{
            if range.location == 3 {
                return false
            }
        }
        return true
    }
}

extension PaymentScreenVC{
    func placeHolderApi(){
        let jsonData = try! JSONSerialization.data(withJSONObject: self.fullDictArr, options: JSONSerialization.WritingOptions.prettyPrinted)
        let jsonString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)! as String
        startAnimating(CGSize(width: 100, height: 100), message: "", type: NVActivityIndicatorType.ballRotate, fadeInAnimation: nil)
        let parameters: Parameters = [
            "language" : "\(Language.language)",
            "club_name" : UserDefaults.standard.object(forKey: "club_name") as! String,
            "order_request" : jsonString,
            "macAddress" : Shared().getWifi(),
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
}

//Donation API Call
extension PaymentScreenVC{
    func donationApi(stripe_token:String){
        //donation_request:{↵ "transaction_id": "fgf5454 ",↵ "donation_amount": "3434",↵ "comment":"test",↵ "user_id" :"10"↵}
        let fullDictDonation=["stripe_token": stripe_token,"donation_amount": self.donationScreenAmount,"comment": self.donationScreenNotes,"user_id":"\(UserDefaults.standard.string(forKey: "user_id")!)"]
        let jsonData = try! JSONSerialization.data(withJSONObject: fullDictDonation, options: JSONSerialization.WritingOptions.prettyPrinted)
        let jsonString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)! as String
        startAnimating(CGSize(width: 100, height: 100), message: "", type: NVActivityIndicatorType.ballRotate, fadeInAnimation: nil)
        let parameters: Parameters = [
            "language" : "\(Language.language)",
            "club_name" : UserDefaults.standard.object(forKey: "club_name") as! String,
            "donation_request" : jsonString,
            "macAddress" : Shared().getWifi(),
        ]
        print("\(Shared().webCall)addDonation ?language=\(Language.language)&club_name=\(UserDefaults.standard.object(forKey: "club_name") as! String)&donation_request=\(jsonString)&macAddress=\(Shared().getWifi())")
        Alamofire.request("\(Shared().webCall)addDonation.php", method: .post, parameters: parameters)
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
                            for controller in self.navigationController!.viewControllers as Array {
                                if controller.isKind(of: DonationVC.self) {
                                    self.navigationController!.popToViewController(controller, animated: true)
                                    break
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

