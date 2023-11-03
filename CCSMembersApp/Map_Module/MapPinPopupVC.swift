//
//  MapPinPopupVC.swift
//  CCSMembersApp
//
//  Created by Parth Makwana on 04/10/23.
//  Copyright © 2023 Jaimin Patel. All rights reserved.
//
// MapPinPopupDelegate protocol
protocol MapPinPopupDelegate: AnyObject {
    func mapPinPopupDidDismiss()
}
import UIKit
import CoreLocation
import SwiftyJSON
import SDWebImage
class MapPinPopupVC: UIViewController {
    
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var Viewextra: UIView!
    @IBOutlet weak var imgClub: UIImageView!
    @IBOutlet weak var lblClubName: UILabel!
    @IBOutlet weak var lblClubAdress: UILabel!
    @IBOutlet weak var lblClubEmail: UILabel!
    @IBOutlet weak var lblClubPhonenumber: UILabel!
    @IBOutlet weak var btnSeemore: UIButton!
    @IBOutlet weak var btnRedirectGmap: UIButton!
    @IBOutlet weak var ViewRedirectGmap: UIView!
    @IBOutlet weak var lblRedirectGmap: UILabel!
    @IBOutlet weak var lblClose: UILabel!
    @IBOutlet weak var ViewTelandmail: UIView!
    @IBOutlet weak var Viewemail: UIView!
    @IBOutlet weak var ViewTelephone: UIView!
    
    // clubData can be either a [String: Any] dictionary or a CLLocation object
    var clubData = JSON("")
    // Declare a weak reference to the delegate
    weak var delegate: MapPinPopupDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.populateClubInfo()
        self.setupLanguage()
        self.updateViewVisibility()
        
    }
    
    func setupLanguage(){
        self.lblRedirectGmap.text = "Direction".localized
        self.lblClose.text = "Close".localized
    }
    
    @IBAction func dismissbtn(_ sender: Any) {
        // Call the delegate method before dismissing
        delegate?.mapPinPopupDidDismiss()
        self.dismiss(animated: true)
    }
    
    @IBAction func btnemailopen(_ sender: Any) {
        if let emailURL = URL(string: "mailto:\(clubData["email"].stringValue)") {
            UIApplication.shared.open(emailURL, options: [:], completionHandler: nil)
        }
    }
    
    @IBAction func btndialogopen(_ sender: Any) {
        guard let phoneNumber = URL(string: "tel://\(clubData["telephone"].stringValue)") else {
            print("Invalid phone number")
            return
        }
        
        UIApplication.shared.open(phoneNumber, options: [:], completionHandler: nil)
    }
    
    
    @IBAction func btnRedirectGmap(_ sender: UIButton){
        let address = lblClubAdress.text ?? "" // Get the address from the label
        
        if let encodedAddress = address.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
           let url = URL(string: "https://maps.google.com/?q=\(encodedAddress)") {
            UIApplication.shared.open(url)
        }
    }
}

extension MapPinPopupVC {
    func populateClubInfo() {
        lblClubName.text = clubData["club_name"].stringValue
        lblClubAdress.text = clubData["full_address"].stringValue
        lblClubEmail.text = clubData["email"].stringValue
        lblClubPhonenumber.text = clubData["telephone"].stringValue
        //imgClub.sd_setImage(with: URL(string: clubData["club_logo"].stringValue), placeholderImage: #imageLiteral(resourceName: "splash_app_logo"))
        if let url = URL(string: clubData["club_logo"].stringValue) {
            if let cachedImage = imageCache.object(forKey: self.clubData["club_logo"].stringValue as NSString) {
                self.imgClub.image = cachedImage
            } else {
                URLSession.shared.dataTask(with: url) { data, _, error in
                    if let data = data, let image = UIImage(data: data) {
                        DispatchQueue.main.async {
                            imageCache.setObject(image, forKey: self.clubData["club_logo"].stringValue as NSString)
                            self.imgClub.image = image
                        }
                    } else {
                        // Use a default image if download fails
                        DispatchQueue.main.async {
                            self.imgClub.image = UIImage(named: "Map_pin_deffualt")
                        }
                    }
                }.resume()
            }
        } else {
            // Use a default image if the URL is not valid
            self.imgClub.image = UIImage(named: "Map_pin_deffualt")
        }
    }
    //Dynimic Manage Telephone and Email lbl&icon
    func updateViewVisibility() {
        let emailIsEmpty = clubData["email"].stringValue.isEmpty
        let telephoneIsEmpty = clubData["telephone"].stringValue.isEmpty
        
        if !emailIsEmpty && !telephoneIsEmpty {
            // Both email and telephone have data
            ViewTelephone.isHidden = false
            Viewemail.isHidden = false
            let constraint = NSLayoutConstraint(item: ViewTelandmail, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 50)
            ViewTelandmail.addConstraint(constraint)
            
        } else if !emailIsEmpty {
            // Only email has data
            ViewTelephone.isHidden = true
            Viewemail.isHidden = false
            let constraint = NSLayoutConstraint(item: ViewTelandmail, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 25)
            self.ViewTelandmail.addConstraint(constraint)
        } else if !telephoneIsEmpty {
            // Only telephone has data
            ViewTelephone.isHidden = false
            Viewemail.isHidden = true
            let constraint = NSLayoutConstraint(item: ViewTelandmail, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 25)
            self.ViewTelandmail.addConstraint(constraint)
            
        } else {
            // Both email and telephone are empty
            self.ViewTelephone.isHidden = true
            self.Viewemail.isHidden = true
            let constraint = NSLayoutConstraint(item: ViewTelandmail, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 0)
            self.ViewTelandmail.addConstraint(constraint)
            
        }
    }
    
}
//

