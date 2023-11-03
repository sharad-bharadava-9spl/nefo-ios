//
//  ClubMapDescriptionView.swift
//  CCSMembersApp
//
//  Created by Parth Makwana on 12/10/23.
//  Copyright © 2023 Jaimin Patel. All rights reserved.
//

import UIKit
import SwiftyJSON

class ClubMapDescriptionView: UIView {
    
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var imgClub: UIImageView!
    @IBOutlet weak var lblClubName: UILabel!
    @IBOutlet weak var lblClubAdress: UILabel!
    @IBOutlet weak var lblClubEmail: UILabel!
    @IBOutlet weak var lblClubPhonenumber: UILabel!
    @IBOutlet weak var btnSeemore: UIButton!
    @IBOutlet weak var ViewTelandmail: UIView!
    
    var clubData = JSON("")
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    
   
    
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


}
