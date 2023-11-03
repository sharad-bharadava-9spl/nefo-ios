//
//  ProfileScreenVC.swift
//  CCSMembersApp
//
//  Created by Jaimin Patel on 7/8/19.
//  Copyright © 2019 Jaimin Patel. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire
import SDWebImage
import NVActivityIndicatorView

class ProfileScreenVC: UIViewController,NVActivityIndicatorViewable{
    
    @IBOutlet weak var lblContactDetailOutlet: UILabel!
    
    @IBOutlet weak var lblCreditOutlet: UILabel!
    @IBOutlet weak var lblGuardiansOutlet: UILabel!
    @IBOutlet weak var lblPersonalOutlet: UILabel!
    @IBOutlet weak var lblBirthdayOutlet: UILabel!
    @IBOutlet weak var lblDNIPassportOutlet: UILabel!
    
    @IBOutlet weak var lblUsageOutlet: UILabel!
    @IBOutlet weak var lblTypeOutlet: UILabel!
    @IBOutlet weak var lblMonthlyOutlet: UILabel!
    
    @IBOutlet weak var lblDiscountOutlet: UILabel!
    @IBOutlet weak var lblDiscountdispensary: UILabel!
    @IBOutlet weak var lblDiscountBarOutlet: UILabel!
    
    @IBOutlet weak var lblPreferencesOutlet: UILabel!
    @IBOutlet weak var lblWeeklyAvergesOutlet: UILabel!
    @IBOutlet weak var lblSpenditureOutlet: UILabel!
    
    @IBOutlet weak var lblDispenseOutlet: UILabel!
    @IBOutlet weak var lblAdministrator: UILabel!
    @IBOutlet weak var firstView: UIView!
    @IBOutlet weak var secondView: UIView!
    @IBOutlet weak var thirdView: UIView!
    @IBOutlet weak var fourthView: UIView!
    //Outlet :: First View
    @IBOutlet weak var imgUserProfile: UIImageView!
    @IBOutlet weak var imgName: UIImageView!
    
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblAge: UILabel!
    @IBOutlet weak var lblCredit: UILabel!
    @IBOutlet weak var imgMember: UIImageView!
    @IBOutlet weak var lblExpiryDate: UILabel!
    
    @IBOutlet weak var imgHighroller: UIImageView!
    @IBOutlet weak var lblHighRoller: UILabel!
    
    //Outlet :: SecondView
    @IBOutlet weak var imgGuardien: UIImageView!
    @IBOutlet weak var imgGuardian2: UIImageView!
    @IBOutlet weak var lblGuardien1: UILabel!
    @IBOutlet weak var lblGuardien2: UILabel!
    
    //Outlet :: ThirdView
    @IBOutlet weak var lblNationality: UILabel!
    @IBOutlet weak var lblBirthday: UILabel!
    @IBOutlet weak var lblDNIReport: UILabel!
    @IBOutlet weak var lblUsageType: UILabel!
    @IBOutlet weak var lblMonthlyConsumption: UILabel!
    
    @IBOutlet weak var lblContactDateTime: UILabel!
    @IBOutlet weak var lblContactEmail: UILabel!
    @IBOutlet weak var lblContactAddress: UILabel!
    @IBOutlet weak var lblDispesanaryAccount: UILabel!
    @IBOutlet weak var lblDiscountBar: UILabel!
    
    //Outlet :: FourthView
    @IBOutlet weak var lblCategory: UILabel!
    @IBOutlet weak var lblPreferences1: UILabel!
    @IBOutlet weak var lblPreferences2: UILabel!
    @IBOutlet weak var lblPreferences3: UILabel!
    @IBOutlet weak var lblPreferences4: UILabel!
    @IBOutlet weak var lblPreferences5: UILabel!
    @IBOutlet weak var lblDispencesWeekly: UILabel!
    @IBOutlet weak var lblSpenditure: UILabel!
    
    
    @IBOutlet weak var imgBackground: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.firstView.isHidden=true
        self.secondView.isHidden=true
        self.thirdView.isHidden=true
        self.fourthView.isHidden=true
        self.navigationController?.navigationBar.isHidden=false
        navigationController?.navigationBar.barTintColor = UIColor(named: "backgroundViewColor")
        navigationController?.navigationBar.topItem?.title = "My Profile".localized
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font: UIFont(name: "ProductSans-Bold", size: 17)!]
        navigationItem.leftBarButtonItem?.tintColor = UIColor.white
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.imgBackground.image = UIImage(named : Shared().getImgName())
        self.setNavigationBarItem()
        
        self.navigationController?.navigationBar.isHidden=false
        navigationController?.navigationBar.barTintColor = UIColor(named: "backgroundViewColor")
        navigationController?.navigationBar.topItem?.title = "My Profile".localized
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font: UIFont(name: "ProductSans-Bold", size: 17)!]
        navigationItem.leftBarButtonItem?.tintColor = UIColor.white
        setupLanguage()
    }
    
    func setupLanguage(){
        self.lblCreditOutlet.text="Credit".localized
        self.lblGuardiansOutlet.text="Guardian(s)".localized
        self.lblPersonalOutlet.text="Personal".localized
        self.lblBirthdayOutlet.text="Birthday :".localized
        self.lblDNIPassportOutlet.text="DNI or Passport".localized
        self.lblContactDetailOutlet.text="Contact Details".localized
        self.lblDiscountOutlet.text="Discounts".localized
        self.lblDiscountdispensary.text="Discount dispensary :".localized
        self.lblDiscountBarOutlet.text="Discount bar:".localized
        self.lblUsageOutlet.text="Usage".localized
        self.lblTypeOutlet.text="Type :".localized
        self.lblMonthlyOutlet.text="Monthly Consumption:".localized
        self.lblPreferencesOutlet.text="Preferences".localized
        
        self.lblWeeklyAvergesOutlet.text="Weekly Avereges".localized
        self.lblDispenseOutlet.text="Dispenses :".localized
        self.lblSpenditureOutlet.text="Spenditure:".localized
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden=false
        navigationController?.navigationBar.barTintColor = UIColor(named: "backgroundViewColor")
        navigationController?.navigationBar.topItem?.title = "My Profile".localized
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font: UIFont(name: "ProductSans-Bold", size: 17)!]
        navigationItem.leftBarButtonItem?.tintColor = UIColor.white
        
        let when = DispatchTime.now() + 0.2
        DispatchQueue.main.asyncAfter(deadline: when) {
            self.profileShowAPI()
        }
    }
}

extension ProfileScreenVC{
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
                            self.firstView.isHidden=false
                            self.secondView.isHidden=false
                            self.thirdView.isHidden=false
                            self.fourthView.isHidden=false
                            if let jsonDict = jsonData["data"] as? [String:Any]{
                                //First View
                                self.imgUserProfile.sd_setImage(with: URL(string: JSON(jsonDict["user_image"]!).stringValue), placeholderImage: #imageLiteral(resourceName: "SlideMyProfileIcon"))
                                self.imgName.sd_setImage(with: URL(string: JSON(jsonDict["first_section_img"]!).stringValue), placeholderImage: #imageLiteral(resourceName: "SlideMyProfileIcon"))
                                self.lblName.text=JSON(jsonDict["first_section"]!).stringValue
                                self.lblAge.text=JSON(jsonDict["second_section"]!).stringValue
                                self.lblCredit.text=JSON(jsonDict["user_credit"]!).stringValue
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
                                self.lblSpenditure.text=JSON(jsonDict["spenditure"]!).stringValue
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
