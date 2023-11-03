//
//  ProfileSetupVC.swift
//  CCSMembersApp
//
//  Created by Jaimin Patel on 11/13/19.
//  Copyright © 2019 Jaimin Patel. All rights reserved.
//

import UIKit
import RFSVG
import SwiftyJSON
import Alamofire
import SDWebImage
import NVActivityIndicatorView

class ProfileSetupVC: UIViewController,NVActivityIndicatorViewable{
    
    @IBOutlet weak var scrollView: UIScrollView!
    //Mark:: FirstView
    @IBOutlet weak var firstView: UIView!
    @IBOutlet weak var personImg: UIImageView!
    @IBOutlet weak var lblHash: UILabel!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblVoluntary: UILabel!
    @IBOutlet weak var lblHighRoller: UILabel!
    @IBOutlet weak var lblExpireFeeOutlet: UILabel!
    @IBOutlet weak var imgExpireFee: UIImageView!
    @IBOutlet weak var lblExpireFee: UILabel!
    @IBOutlet weak var lblCredetoOutlet: UILabel!
    @IBOutlet weak var lblCredit: UILabel!
    @IBOutlet weak var imgCard: UIImageView!
    @IBOutlet weak var lblAdd: UILabel!
    
    //SecondView
    @IBOutlet weak var secondView: UIView!
    @IBOutlet weak var lblPersonalInfoOutlet: UILabel!
    @IBOutlet weak var imgFlag: UIImageView!
    @IBOutlet weak var lblCountryName: UILabel!
    @IBOutlet weak var imgYear: UIImageView!
    @IBOutlet weak var lblYears: UILabel!
    @IBOutlet weak var imgMonth: UIImageView!
    @IBOutlet weak var lblMonth: UILabel!
    @IBOutlet weak var lblUSO: UILabel!
    @IBOutlet weak var imgTherapiUser: UIImageView!
    @IBOutlet weak var lblTherapiUser: UILabel!
    @IBOutlet weak var imgHighRoller: UIImageView!
    @IBOutlet weak var lblPersonalHighRoller: UILabel!
    @IBOutlet weak var imgMonthlyConsumption: UIImageView!
    @IBOutlet weak var lblMonthlyConsumptionOutlet: UILabel!
    @IBOutlet weak var lblMonthlyConsumption: UILabel!
    @IBOutlet weak var lblContactInfoOutlet: UILabel!
    @IBOutlet weak var imgDirection: UIImageView!
    @IBOutlet weak var lblDirection: UILabel!
    @IBOutlet weak var imgTel: UIImageView!
    @IBOutlet weak var lblTelOutlet: UILabel!
    @IBOutlet weak var lblTel: UILabel!
    @IBOutlet weak var imgMail: UIImageView!
    @IBOutlet weak var lblEmail: UILabel!
    
    @IBOutlet weak var heightofQrView: NSLayoutConstraint!
    @IBOutlet weak var qrView: UIView!
    @IBOutlet weak var imgQrCode: UIImageView!
    
    //ThirdView
    @IBOutlet weak var thirdView: UIView!
    @IBOutlet weak var guardianHeight: NSLayoutConstraint!
    @IBOutlet weak var guardiansTblView: UITableView!
    @IBOutlet weak var lblGuardianOutlet: UILabel!
    @IBOutlet weak var lblEntervestedMember: UILabel!
    @IBOutlet weak var imgVerify: UIImageView!
    @IBOutlet weak var addCardButton: UIButton!
    
    //FourthView
    @IBOutlet weak var FourthView: UIView!
    @IBOutlet weak var pteferencesTblHeight: NSLayoutConstraint!
    @IBOutlet weak var preferencesTblView: UITableView!
    @IBOutlet weak var lblPreferenceOutlet: UILabel!
    
    @IBOutlet weak var thirdViewHeight: NSLayoutConstraint!
    @IBOutlet weak var FourthViewHeight: NSLayoutConstraint!
    @IBOutlet weak var lblRecivedNotice: UILabel!

    
    var guardianDetail=[profileSetupGuardians]()
    var preferencesArr=[String]()
    var item1:UIBarButtonItem?
    var item2:UIBarButtonItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        /*
         self.personImg.layer.shadowPath = UIBezierPath(rect: self.personImg.bounds).cgPath
         self.personImg.layer.shadowRadius = 5
         self.personImg.layer.shadowOffset = .zero
         self.personImg.layer.shadowOpacity = 1
         self.personImg.layer.cornerRadius=self.personImg.frame.height/2.0
         
         self.personImg.layer.masksToBounds=true
         */
        self.guardiansTblView.dataSource=self
        self.guardiansTblView.delegate=self
        
        self.preferencesTblView.dataSource=self
        self.preferencesTblView.delegate=self
        
        self.personImg.shadowColor(color: UIColor.black.withAlphaComponent(0.2), border: 1.2, offHeight: 1)
        self.personImg.layer.cornerRadius=self.personImg.frame.height/2.0
        self.personImg.layer.masksToBounds=true
        
        self.navigationController?.navigationBar.isHidden=false
        navigationController?.navigationBar.barTintColor = UIColor.white//UIColor(named: "backgroundViewColor")
        navigationController?.navigationBar.topItem?.title = "My Profile".localized.uppercased()
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(named: "NavigationText")!, NSAttributedString.Key.font: UIFont(name: "ProductSans-Bold", size: 17)!]
        navigationItem.leftBarButtonItem?.tintColor = UIColor(named: "NavigationText")!
        if targetName != Shared().cannibisAppName {
            qrView.isHidden = true
            heightofQrView.constant = 0.0
        } else {
            qrView.isHidden = false
            heightofQrView.constant = 200
        }
        
        thirdView.isHidden = true
        FourthView.isHidden = true
        thirdViewHeight.constant = 0
        FourthViewHeight.constant = 0
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.scrollView.isHidden=true
        self.guardianHeight.constant=0
        self.pteferencesTblHeight.constant=0
        self.imgCard.setImageFromSVG("Icono-donacion")
        if targetName == Shared().cannibisAppName {
            lblAdd.isHidden = true
            imgCard.isHidden = true
            addCardButton.isHidden = true
        }
       // self.firstView.shadowColor(color: UIColor.black.withAlphaComponent(0.2), border: 1.2, offHeight: 1)
      //  self.secondView.shadowColor(color: UIColor.black.withAlphaComponent(0.2), border: 1.2, offHeight: 1)
       // self.thirdView.shadowColor(color: UIColor.black.withAlphaComponent(0.2), border: 1.2, offHeight: 1)
      //  self.FourthView.shadowColor(color: UIColor.black.withAlphaComponent(0.2), border: 1.2, offHeight: 1)
        //self.personImg.shadowColor(color: UIColor.black.withAlphaComponent(0.2), border: 1.2, offHeight: 1)
        
        self.setNavigationBarItem()
        self.navigationController?.navigationBar.isHidden=false
        navigationController?.navigationBar.barTintColor = UIColor.white//UIColor(named: "backgroundViewColor")
        navigationController?.navigationBar.topItem?.title = "My Profile".localized.uppercased()
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(named: "NavigationText")!, NSAttributedString.Key.font: UIFont(name: "ProductSans-Bold", size: 17)!]
        navigationItem.leftBarButtonItem?.tintColor = UIColor(named: "NavigationText")!
        self.setupLanguage()
        
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
        btn2.addTarget(self, action: #selector(self.notificationRedirection), for: .touchUpInside)
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
    
    @objc func notificationRedirection(){
        let storyBord=UIStoryboard(name: "Main", bundle: nil)
        let vc=storyBord.instantiateViewController(withIdentifier: "NotificationVC") as! NotificationVC
        let navVC=UINavigationController(rootViewController: vc)
        slideMenuController()?.changeMainViewController(navVC, close: true)
    }
    
    @objc func cartRedirection(){
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "CartScreenVC") as! CartScreenVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden=false
        navigationController?.navigationBar.barTintColor = UIColor.white//UIColor(named: "backgroundViewColor")
        navigationController?.navigationBar.topItem?.title = "My Profile".localized.uppercased()
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(named: "NavigationText")!, NSAttributedString.Key.font: UIFont(name: "ProductSans-Bold", size: 17)!]
        navigationItem.leftBarButtonItem?.tintColor = UIColor(named: "NavigationText")!
        self.guardiansTblView.reloadData()
        self.guardianHeight.constant=self.guardiansTblView.contentSize.height
        
        self.preferencesTblView.reloadData()
        self.pteferencesTblHeight.constant=self.preferencesTblView.contentSize.height
        let when = DispatchTime.now() + 0.2
        DispatchQueue.main.asyncAfter(deadline: when) {
            self.profileShowAPI()
        }
    }
    
    @IBAction func btnAddDonationAction(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        var vc: UIViewController!
        let vcCon = storyboard.instantiateViewController(withIdentifier: "DonationVC") as! DonationVC
        vc = UINavigationController(rootViewController: vcCon)
        self.slideMenuController()?.changeMainViewController(vc, close: true)
    }
    
    func setupLanguage(){
        //FirstView
        self.lblExpireFeeOutlet.text="EXPIRA FEE".localized
        self.lblCredetoOutlet.text="CREDIT:".localized
        self.lblAdd.text="Add".localized
        //SecondView
        self.lblPersonalInfoOutlet.text="PERSONAL INFORMATION".localized.capitalizingFirstLetter()//INFORMACION PERSONAL
        self.lblUSO.text="USO".localized
        self.lblMonthlyConsumptionOutlet.text="Monthly Consumption:".localized//Consumo mensual:
        self.lblContactInfoOutlet.text="CONTACT INFORMATION".localized//DATOS DE CONTACTO
        self.lblTelOutlet.text="Tel:".localized
        //ThirdView
        self.lblGuardianOutlet.text="GUARDIANES".localized
        self.lblEntervestedMember.text="MIEMBRO ENTERVESTADO".localized
        //FourthView
        self.lblPreferenceOutlet.text="PREFERENCIAS".localized
        
        self.lblRecivedNotice.text = "Received_a_notice".localized
    }
    
    func guardiansDetal(img:String,hashVal:String,name:String,usertype:String){
//        var objGuardian=profileSetupGuardians()
//        objGuardian.Guardian_first=
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

extension ProfileSetupVC:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.guardiansTblView == tableView{
            return guardianDetail.count
        } else{
            return self.preferencesArr.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.guardiansTblView == tableView{
            let cell=tableView.dequeueReusableCell(withIdentifier: "ProfileSetupGuardianCell") as! ProfileSetupGuardianCell
            let guardianDict=self.guardianDetail[indexPath.row]
            cell.imgView.shadowColor(color: UIColor.black.withAlphaComponent(0.2), border: 1.2, offHeight: 1)
            cell.imgView.sd_setImage(with: URL(string:guardianDict.Guardianfirst_img),placeholderImage:UIImage(named: "MainMenuBG"))
            cell.imgView.layer.cornerRadius=cell.imgView.frame.height/2.0
            cell.imgView.layer.masksToBounds=true
            cell.lblHash.text="#"+guardianDict.guardianfirst_member_no
            cell.lblName.text=guardianDict.guardianfirst_name
            print("sdg-\(guardianDict.guardianfirst_name)")
            cell.lblVoluntary.text=guardianDict.guardianfirst_type
            if guardianDict.guardianfirst_member_no == ""{
                
            } else{
                
            }
            //cell.imgView.sd_setImage(with: , placeholder: )
            return cell
        } else{
            let cell=tableView.dequeueReusableCell(withIdentifier: "ProfileSetupPreferencesCell") as! ProfileSetupPreferencesCell
            if indexPath.row%2==0{
                cell.contentView.backgroundColor=UIColor.clear
            } else{
                cell.contentView.backgroundColor=UIColor.white
            }
            cell.lblPreferenceName.text=self.preferencesArr[indexPath.row]
            return cell
        }
    }
}

extension ProfileSetupVC{
    func profileShowAPI(){
        startAnimating(CGSize(width: 100, height: 100), message: "", type: NVActivityIndicatorType.ballRotate, fadeInAnimation: nil)
        let parameters: Parameters = [
            "language" : "\(Language.language)",
            "club_name" : UserDefaults.standard.object(forKey: "club_name") as! String,
            "user_id" : UserDefaults.standard.string(forKey: "user_id")!,
            "platform" : Shared().device_platform,
            "device_id" : UIDevice.current.identifierForVendor!.uuidString,
        ]
        print("\(Shared().webCall)userProfile?user_id=\(UserDefaults.standard.string(forKey: "user_id")!)&language=\(Language.language)&club_name=\(UserDefaults.standard.object(forKey: "club_name") as! String)&platform=\(Shared().device_platform)&device_id=\(UIDevice.current.identifierForVendor!.uuidString)")
        Alamofire.request("\(Shared().webCall)userProfile.php", method: .post, parameters: parameters)
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
                                let notification_count = JSON(jsonData["notification_count"]!).stringValue
                                UIApplication.shared.applicationIconBadgeNumber=JSON(notification_count).intValue
                                if notification_count != "0" {
                                     self.item2?.addBadge(number: Int(notification_count)!)
                                } else{
                                    self.item2?.removeBadge()
                                }
                                
                                self.scrollView.isHidden=false
                                self.preferencesArr.removeAll()
                                self.guardianDetail.removeAll()
                                //FirstView
                                self.personImg.sd_setImage(with: URL(string: JSON(jsonDict["user_image"]!).stringValue), placeholderImage: #imageLiteral(resourceName: "user_placeholder"))
                                self.imgQrCode.sd_setImage(with:  URL(string: JSON(jsonDict["qr_code"]!).stringValue),placeholderImage:UIImage(named: "no_image_default"))
                                self.lblHash.text="#"+JSON(jsonDict["memberno"]!).stringValue
                                self.lblHighRoller.text=JSON(jsonDict["sex_section"]!).stringValue
                                self.lblVoluntary.text=JSON(jsonDict["user_type"]!).stringValue
                                //lblExpireFee
                          //  MARK: vish   //  self.lblExpireFee.text=JSON(jsonDict["five_section"]!).stringValue
                                self.lblExpireFee.text=JSON(jsonDict["member_exp_date"]!).stringValue
                                //self.lblCredetoOutlet.text=JSON(jsonDict["user_credit"]!).stringValue+" €"
                                self.lblCredit.text=JSON(jsonDict["user_credit"]!).stringValue+" €"
                                self.lblCountryName.text=JSON(jsonDict["country"]!).stringValue
                                self.lblYears.text=JSON(jsonDict["second_section_title"]!).stringValue//Check
                                self.lblMonth.text=JSON(jsonDict["birth_date"]!).stringValue
                                self.lblTherapiUser.text=JSON(jsonDict["usageType"]!).stringValue
                                self.lblPersonalHighRoller.text=JSON(jsonDict["sex_section"]!).stringValue
                                self.lblMonthlyConsumption.text=JSON(jsonDict["mconsumption"]!).stringValue
                                let address="\(JSON(jsonDict["street"]!).stringValue+" "+JSON(jsonDict["streetnumber"]!).stringValue+" "+JSON(jsonDict["postcode"]!).stringValue+" "+JSON(jsonDict["city"]!).stringValue+" "+JSON(jsonDict["country"]!).stringValue)"//Check
                                self.lblTel.text=JSON(jsonDict["telephone"]!).stringValue
                                self.lblEmail.text=JSON(jsonDict["email"]!).stringValue
                                self.preferencesArr.append(JSON(jsonDict["Preferences1"]!).stringValue)
                                self.preferencesArr.append(JSON(jsonDict["Preferences2"]!).stringValue)
                                self.preferencesArr.append(JSON(jsonDict["Preferences3"]!).stringValue)
                                self.preferencesArr.append(JSON(jsonDict["Preferences4"]!).stringValue)
                                self.preferencesArr.append(JSON(jsonDict["Preferences5"]!).stringValue)
                                //ProductSans-Light 14.0
                                let attrs1 = [NSAttributedString.Key.font : UIFont(name: "Roboto-Bold", size: 16), NSAttributedString.Key.foregroundColor : UIColor.ColorTitle]
                                
                                let attrs2 = [NSAttributedString.Key.font : UIFont(name: "Roboto-Regular", size: 16), NSAttributedString.Key.foregroundColor : UIColor(named: "TextColorDark")]
                                
                                let attributedString1 = NSMutableAttributedString(string:"Direccion".localized, attributes:attrs1)
                                
                                let attributedString2 = NSMutableAttributedString(string:address, attributes:attrs2)
                                
                                attributedString1.append(attributedString2)
                                self.lblDirection.attributedText = attributedString1
                                self.imgExpireFee.sd_setImage(with: URL(string: JSON(jsonDict["five_section_image"]!).stringValue),placeholderImage:#imageLiteral(resourceName: "FeeExpire_Profile"))
                               
                                self.preferencesTblView.reloadData()
                                self.pteferencesTblHeight.constant=self.preferencesTblView.contentSize.height
                                
                                if let guardianData = jsonDict["guardian"] as? [[String:Any]]{
                                    //let guardianDetails=JSON(guardianData)
                                    for i in 0..<guardianData.count{
                                        let objGuardian=profileSetupGuardians()
                                        if i == 0{
                                            objGuardian.Guardian_first=JSON(guardianData[i]["Guardian_first"]!).stringValue
                                         //   objGuardian.Guardianfirst_detail=JSON(guardianData[i]["Guardianfirst_detail"]!).stringValue
                                            objGuardian.Guardianfirst_img=JSON(guardianData[i]["Guardian_first"]!).stringValue
                                            objGuardian.guardianfirst_member_no=JSON(guardianData[i]["guardianfirst_member_no"]!).stringValue
                                            objGuardian.guardianfirst_name=JSON(guardianData[i]["guardianfirst_name"]!).stringValue
                                            objGuardian.guardianfirst_type=JSON(guardianData[i]["guardianfirst_type"]!).stringValue
                                        } else if i == 1{
                                            objGuardian.Guardian_first=JSON(guardianData[i]["Guardian_second"]!).stringValue
                                         //   objGuardian.Guardianfirst_detail=JSON(guardianData[i]["Guardiansecond_detail"]!).stringValue
                                            objGuardian.Guardianfirst_img=JSON(guardianData[i]["Guardian_second"]!).stringValue
                                            objGuardian.guardianfirst_member_no=JSON(guardianData[i]["guardiansecond_member_no"]!).stringValue
                                            objGuardian.guardianfirst_name=JSON(guardianData[i]["guardiansecond_name"]!).stringValue
                                            objGuardian.guardianfirst_type=JSON(guardianData[i]["guardiansecond_type"]!).stringValue
                                        } else{
                                            
                                        }
                                        self.guardianDetail.append(objGuardian)
                                    }
                                    self.guardiansTblView.reloadData()
                                    self.guardianHeight.constant=self.guardiansTblView.contentSize.height
                                }
                               // var val=Shared().componentSeparetedGuardians(fullValue: "\(JSON(jsonDict["Guardianfirst_detail"]!).stringValue)", separatedBy: " - ")
                               // self.guardiansDetal(img:JSON(jsonDict["Guardian_first"]!).stringValue, hashVal: val, name: JSON(jsonDict["Guardian_first"]!).stringValue, usertype: JSON(jsonDict["Guardian_first"]!).stringValue)
                                //member_interviewedself.lblEmail.text=JSON(jsonDict["member_interviewed"]!).stringValue//Check
                                //Third View
                               // self.guardianDetail.append()
                                
                                /*self.imgUserProfile.sd_setImage(with: URL(string: JSON(jsonDict["user_image"]!).stringValue), placeholderImage: #imageLiteral(resourceName: "SlideMyProfileIcon"))
                                self.imgName.sd_setImage(with: URL(string: JSON(jsonDict["first_section_img"]!).stringValue), placeholderImage: #imageLiteral(resourceName: "SlideMyProfileIcon"))
                                self.lblName.text=JSON(jsonDict["first_section"]!).stringValue
                                self.lblAge.text=JSON(jsonDict["second_section"]!).stringValue
                                self.lblCredit.text=JSON(jsonDict["user_credit"]!).stringValue+" €"
                                self.imgMember.sd_setImage(with: URL(string: JSON(jsonDict["five_section_image"]!).stringValue), placeholderImage: #imageLiteral(resourceName: "SlideMyProfileIcon"))
                                self.lblExpiryDate.text=JSON(jsonDict["five_section"]!).stringValue
                                self.lblAdministrator.text=JSON(jsonDict["user_type"]!).stringValue
                                self.imgHighroller.sd_setImage(with: URL(string: JSON(jsonDict["sex_section_image"]!).stringValue), placeholderImage: #imageLiteral(resourceName: "SlideMyProfileIcon"))
                                self.lblHighRoller.text=JSON(jsonDict["sex_section"]!).stringValue
                                
                                //Second View
                                self.imgGuardien.sd_setImage(with: URL(string: JSON(jsonDict["Guardian_first"]!).stringValue), placeholderImage: #imageLiteral(resourceName: "SlideMyProfileIcon"))
                                self.imgGuardian2.sd_setImage(with: URL(string: JSON(jsonDict["Guardian_second"]!).stringValue), placeholderImage: #imageLiteral(resourceName: "SlideMyProfileIcon"))
                                self.lblGuardien1.text=JSON(jsonDict["Guardianfirst_detail"]!).stringValue
                                self.lblGuardien2.text=JSON(jsonDict["Guardiansecond_detail"]!).stringValue
                                
                                //Third View
                                //Personal
                                self.lblNationality.text=JSON(jsonDict["nationality"]!).stringValue
                                self.lblBirthday.text=JSON(jsonDict["birth_date"]!).stringValue
                                self.lblDNIReport.text=JSON(jsonDict["dnipassport"]!).stringValue
                                self.lblUsageType.text=JSON(jsonDict["usageType"]!).stringValue
                                self.lblMonthlyConsumption.text=JSON(jsonDict["mconsumption"]!).stringValue
                                //ContactDetail
                                self.lblContactDateTime.text=JSON(jsonDict["telephone"]!).stringValue
                                self.lblContactEmail.text=JSON(jsonDict["email"]!).stringValue
                                self.lblContactAddress.text="\(JSON(jsonDict["street"]!).stringValue+" "+JSON(jsonDict["streetnumber"]!).stringValue+" "+JSON(jsonDict["postcode"]!).stringValue+" "+JSON(jsonDict["city"]!).stringValue+" "+JSON(jsonDict["country"]!).stringValue)"
                                self.lblDispesanaryAccount.text=JSON(jsonDict["discountdispensary"]!).stringValue
                                self.lblDiscountBar.text=JSON(jsonDict["discountBar"]!).stringValue
                                
                                //FourthView
                                //Preferences
                                self.lblCategory.text=JSON(jsonDict["category"]!).stringValue
                                self.lblPreferences1.text=JSON(jsonDict["Preferences1"]!).stringValue
                                self.lblPreferences2.text=JSON(jsonDict["Preferences2"]!).stringValue
                                self.lblPreferences3.text=JSON(jsonDict["Preferences3"]!).stringValue
                                self.lblPreferences4.text=JSON(jsonDict["Preferences4"]!).stringValue
                                self.lblPreferences5.text=JSON(jsonDict["Preferences5"]!).stringValue
                                //Weekly Avereges
                                self.lblDispencesWeekly.text=JSON(jsonDict["dispenses"]!).stringValue
                                self.lblSpenditure.text=JSON(jsonDict["spenditure"]!).stringValue*/
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
