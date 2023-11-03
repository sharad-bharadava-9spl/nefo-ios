//
//  OpenQrCodeVC.swift
//  CCSMembersApp
//
//  Created by Divyesh Dabhi on 24/05/23.
//  Copyright © 2023 Jaimin Patel. All rights reserved.
//

import UIKit

class OpenQrCodeVC: UIViewController {

    @IBOutlet weak var imgQrCode: UIImageView!
    var imgUrl = ""
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        
    }
    override func viewDidLayoutSubviews () {
        super.viewDidLayoutSubviews()
        
        
    }
    func setupUI(){
        self.imgQrCode.sd_setImage(with: URL(string:imgUrl), placeholderImage: #imageLiteral(resourceName: "backgroundImg"))
        self.setupNavigationItem()
    }
    
    func setupNavigationItem(){
        self.title = "QR_CODE".localized.uppercased()
        self.removeNavigationBarItem()
        self.navigationController?.navigationBar.tintColor = .white
       // self.setNavigationBarItem()
        self.setLeftAlignTitleView(font: UIFont(name: "ProductSans-Bold", size: 17)!, text: "QR_CODE".localized, textColor: .white)
        
        
    }

}
