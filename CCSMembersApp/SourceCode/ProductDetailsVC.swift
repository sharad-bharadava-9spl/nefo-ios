//
//  ProductDetailsVC.swift
//  CCSMembersApp
//
//  Created by Apple on 21/07/22.
//  Copyright © 2022 Jaimin Patel. All rights reserved.
//

import UIKit
import SDWebImage

class ProductDetailsVC: UIViewController {
    
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var titlelbl: UILabel!
    @IBOutlet weak var tag1: UIButton!
    @IBOutlet weak var tag2: UIButton!
    @IBOutlet weak var dislbl: UILabel!
    @IBOutlet weak var pricelbl: UILabel!
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var tblHeader: UIView!
    
    var imgString = String()
    var titleString = String()
    var discString = String()
    var strProductMedicalDesc = String()
    var priceString = String()
    var flowerType = String()
    var grow_type = String()
    var extract_type = String()
    var item2:UIBarButtonItem?
    var Show_price = String()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden=true
        self.navigationItem.setHidesBackButton(true, animated: true)
        self.setNavigationBarItem()
        self.setLeftAlignTitleView(font: UIFont(name: "ProductSans-Bold", size: 17)!, text: "Menu", textColor: .white)
        var imageNotification = Shared().imageWithImage(image: UIImage(named: "Notification_icon")!, scaledToSize: CGSize(width: 23, height: 23))
        imageNotification = imageNotification.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        
        
        self.img.sd_setImage(with: URL(string:imgString), placeholderImage: #imageLiteral(resourceName: "backgroundImg") )
        self.titlelbl.text = titleString
        if self.Show_price == "1" {
            self.pricelbl.isHidden = false
            self.pricelbl.text = priceString
        } else {
            self.pricelbl.isHidden = true
            self.pricelbl.text = priceString
        }
        
        if discString == "" {
            dislbl.text = "\(strProductMedicalDesc)"
        } else {
            dislbl.text = "\(discString) \n\n\(strProductMedicalDesc)"
        }
        
        let btn2 = UIButton(type: .custom)
        btn2.setImage(imageNotification, for: .normal)
        btn2.frame = CGRect(x: 0, y: 0, width: 28, height: 28)
        btn2.addTarget(self, action: #selector(self.notificationScreenRedirection), for: .touchUpInside)
        item2 = UIBarButtonItem(customView: btn2)
        item2?.removeBadge()
        self.navigationItem.setRightBarButtonItems([item2!], animated: true)
        
        tag1.backgroundColor = UIColor(hexString: "#1C85FF")
        tag2.backgroundColor = UIColor(hexString: "#1C85FF")
        
        
        if flowerType.isEmpty{
            tag1.isHidden=true
            if extract_type.isEmpty{
                tag1.isHidden=true
            } else{
                tag1.isHidden=false
                tag1.setTitle(extract_type, for: .normal)
            }
        } else{
            tag1.isHidden=false
            tag1.setTitle(flowerType, for: .normal)
        }
        
        
        if grow_type.isEmpty{
            tag2.isHidden=true
        } else{
            tag2.isHidden=false
            tag2.setTitle(grow_type, for: .normal)
        }
        
        DispatchQueue.main.async {
            self.table.tableHeaderView = self.tblHeader
            self.table.updateHeaderViewHeight()
            self.table.reloadData()
        }
        
    }
    
    
    @objc func notificationScreenRedirection(){
        let storyBoard=UIStoryboard(name: "Main", bundle: nil)
        let vc=storyBoard.instantiateViewController(withIdentifier: "NotificationVC") as! NotificationVC
        let navVC=UINavigationController(rootViewController: vc)
        self.slideMenuController()?.changeMainViewController(navVC, close: true)
    }
    
    
    @IBAction func back (_ sender: UIButton){
        self.navigationController?.popViewController(animated: false)
    }

   

}
