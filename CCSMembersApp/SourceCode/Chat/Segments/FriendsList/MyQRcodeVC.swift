//
//  tViewController.swift
//  
//
//  Created by Divvyesh on 18/07/23.
//

import UIKit

class MyQRcodeVC: UIViewController {
    //MARK: Variable Declarations
    @IBOutlet weak var imgQrCode: UIImageView!
    @IBOutlet weak var lblMessage: UILabel!
    @IBOutlet weak var lblUserName: UILabel!
    
    @IBOutlet weak var lblgoback: UILabel!
    //MARK: View-Controller LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }
    
    //SetupUI
    func setupUI(){
        setupLanguage()
        self.imgQrCode.sd_setImage(with: URL(string: getFromUserDefaultForKey(key_myQrCode) as? String ?? ""),placeholderImage:UIImage(named: "no_image_default"))
        
        // Retrieve the user's name from user defaults or any other source
        self.lblUserName.text = appDelegateShared.nameU
        /*       if let userName = UserDefaults.standard.string(forKey: "member_id") {
         lblUserName.text = userName
         } else {
         lblUserName.text = "User Name Not Available"
         }
         */
        
        // Retrieve QR code value from user defaults
        /* if let qrCodeValue = getFromUserDefaultForKey(key_myQrCode) as? String {
         // Load the QR code image using the URL
         if let qrCodeURL = URL(string: qrCodeValue) {
         imgQrCode.sd_setImage(with: qrCodeURL, placeholderImage: UIImage(named: "no_image_default"))
         } else if let qrCodeData = Data(base64Encoded: qrCodeValue) {
         imgQrCode.image = UIImage(data: qrCodeData)
         } else {
         // Handle the case when the QR code value is not a valid URL or image data
         imgQrCode.image = UIImage(named: "no_image_default")
         }
         } else {
         // Handle the case when the QR code value is not found in user defaults
         imgQrCode.image = UIImage(named: "no_image_default")
         }*/
        
    }
    func setupLanguage() {
        self.lblMessage.text = "msg_ask_your_friend_for_scan_your_qr".localized
        self.lblgoback.text = "Go Back".localized
    }
    @IBAction func backButtonClicked(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}

