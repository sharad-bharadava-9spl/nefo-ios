//
//  ProductDescriptionVC.swift
//  CCSMembersApp
//
//  Created by Jaimin Patel on 12/11/19.
//  Copyright © 2019 Jaimin Patel. All rights reserved.
//

import UIKit

class ProductDescriptionVC: UIViewController,UITextViewDelegate {
//Medical_Product
    //Info_Product
    @IBOutlet weak var viewHeight: NSLayoutConstraint!
    @IBOutlet weak var txtProductDescription: UITextView!
    @IBOutlet weak var lblProductName: UILabel!
    @IBOutlet weak var btnProduct: UIButton!
    var productDescription:String=""
    var itemName:String=""
    var imgVerify:String="1"
    override func viewDidLoad() {
        super.viewDidLoad()
        self.txtProductDescription.delegate=self
        self.lblProductName.text=itemName
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let height = txtProductDescription.heightForView(text: productDescription, font: self.txtProductDescription.font!, width: self.txtProductDescription.frame.size.width)
        txtProductDescription.text=productDescription
        if height >= 96{
            if height >= 450{
                viewHeight.constant=450
            } else{
                viewHeight.constant=height+84
            }
        } else{
            viewHeight.constant=170
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if imgVerify=="1"{
            self.btnProduct.setImage(UIImage(named: "Info_Product"), for: .normal)
        } else{
            self.btnProduct.setImage(UIImage(named: "Medical_Product"), for: .normal)
        }
    }
    
    @IBAction func btnClose(_ sender: UIButton) {
        self.dismiss(animated: false, completion: nil)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let scrollColour=self.txtProductDescription.subviews.last as? UIImageView
        scrollColour?.backgroundColor = UIColor.green
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
