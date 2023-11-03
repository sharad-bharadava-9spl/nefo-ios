//
//  NewProfileVC.swift
//  CCSMembersApp
//
//  Created by Apple on 21/07/22.
//  Copyright © 2022 Jaimin Patel. All rights reserved.
//

import UIKit
import RFSVG
import SwiftyJSON
import Alamofire
import SDWebImage
import NVActivityIndicatorView

class NewProfileVC: UIViewController,NVActivityIndicatorViewable {
    
    @IBOutlet weak var imgQrCode: UIImageView!
    @IBOutlet weak var personImg: UIImageView!
    @IBOutlet weak var lblHash: UILabel!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var date : UILabel!
    @IBOutlet weak var balance : UILabel!
    @IBOutlet weak var balanceStatic  : UILabel!
    @IBOutlet weak var feesEndLbl  : UILabel!
    @IBOutlet weak var imgWarningIcon: UIImageView!
    
    var item2:UIBarButtonItem?
    var guardianDetail=[profileSetupGuardians]()

    override func viewDidLoad() {
        super.viewDidLoad()

       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.isHidden=false
        navigationController?.navigationBar.barTintColor = UIColor.white
        self.navigationItem.setHidesBackButton(true, animated: true)
        self.navigationController?.navigationBar.backgroundColor = .clear
        self.setNavigationBarItem()
        self.setLeftAlignTitleView(font: UIFont(name: "ProductSans-Bold", size: 17)!, text: "Slide_My Profile".localized.capitalized, textColor: .white)
        var imageNotification = Shared().imageWithImage(image: UIImage(named: "Notification_icon")!, scaledToSize: CGSize(width: 23, height: 23))
        imageNotification = imageNotification.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        
        self.balanceStatic.text = "Balance".localized
        self.feesEndLbl.text = "End_fee".localized
        self.imgWarningIcon.isHidden = true
        
        let btn2 = UIButton(type: .custom)
        btn2.setImage(imageNotification, for: .normal)
        btn2.frame = CGRect(x: 0, y: 0, width: 28, height: 28)
        btn2.addTarget(self, action: #selector(self.notificationScreenRedirection), for: .touchUpInside)
        item2 = UIBarButtonItem(customView: btn2)
        item2?.removeBadge()
        self.navigationItem.setRightBarButtonItems([item2!], animated: true)
        
        if #available(iOS 13.0, *) {
            let statusBar = UIView(frame: (UIApplication.shared.keyWindow?.windowScene?.statusBarManager?.statusBarFrame)!)
            statusBar.backgroundColor = .clear
            UIApplication.shared.keyWindow?.addSubview(statusBar)
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let when = DispatchTime.now() + 0.2
        DispatchQueue.main.asyncAfter(deadline: when) {
            self.profileShowAPI()
        }
    }
    
    @objc func notificationScreenRedirection(){
        let storyBoard=UIStoryboard(name: "Main", bundle: nil)
        let vc=storyBoard.instantiateViewController(withIdentifier: "NotificationVC") as! NotificationVC
        let navVC=UINavigationController(rootViewController: vc)
        self.slideMenuController()?.changeMainViewController(navVC, close: true)
    }
    

    

}


extension NewProfileVC {
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
                                let notification_count = UserDefaults.standard.string(forKey: "notifcount") as? String ?? "0"
                                UIApplication.shared.applicationIconBadgeNumber=JSON(notification_count).intValue
                                if notification_count != "0" {
                                    self.item2?.addBadge(number: Int(notification_count ?? "")!)
                                } else{
                                    self.item2?.removeBadge()
                                }
                            
                                //FirstView
                                self.personImg.sd_setImage(with: URL(string: JSON(jsonDict["user_image"]!).stringValue), placeholderImage: #imageLiteral(resourceName: "user_placeholder"))
                                self.imgQrCode.sd_setImage(with:  URL(string: JSON(jsonDict["qr_code"]!).stringValue),placeholderImage:UIImage(named: "no_image_default"))
                                self.lblHash.text="#"+JSON(jsonDict["memberno"]!).stringValue
//
                          //  MARK: vish   //  self.lblExpireFee.text=JSON(jsonDict["five_section"]!).stringValue
//
                                let address="\(JSON(jsonDict["street"]!).stringValue+" "+JSON(jsonDict["streetnumber"]!).stringValue+" "+JSON(jsonDict["postcode"]!).stringValue+" "+JSON(jsonDict["city"]!).stringValue+" "+JSON(jsonDict["country"]!).stringValue)"//Check
//
                                let attrs1 = [NSAttributedString.Key.font : UIFont(name: "Roboto-Bold", size: 16), NSAttributedString.Key.foregroundColor : UIColor.ColorTitle]
                                
                                let attrs2 = [NSAttributedString.Key.font : UIFont(name: "Roboto-Regular", size: 16), NSAttributedString.Key.foregroundColor : UIColor(named: "TextColorDark")]
                                
                                let attributedString1 = NSMutableAttributedString(string:"Direccion".localized, attributes:attrs1)
                                
                                let attributedString2 = NSMutableAttributedString(string:address, attributes:attrs2)
                                
                                attributedString1.append(attributedString2)


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
                                        self.lblName.text=JSON(jsonDict["first_name"]!).stringValue + " " + JSON(jsonDict["last_name"]!).stringValue
                                        self.lblHash.text="#"+JSON(jsonDict["memberno"]!).stringValue
                                        self.balance.text = JSON(jsonDict["third_section"] ?? "").stringValue
//                                        self.date.text = JSON(jsonDict["member_exp_date"]!).stringValue
                                        self.feesEndLbl.text = "\(JSON(jsonDict["groupName"] ?? "").stringValue) \(getDisplayDate(date: JSON(jsonDict["groupDate"] ?? "").stringValue, dateFormat: dateFormateDashOnlyDate, displayFormat: dateTimeFromateDispalyOnlyDate))"
//                                        self.lblName.text=guardianDict.guardianfirst_name
                                        if JSON(jsonDict["mark_icon"]!).intValue == 1{
                                            self.imgWarningIcon.isHidden = false
                                        }
                                    }
                                   
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
