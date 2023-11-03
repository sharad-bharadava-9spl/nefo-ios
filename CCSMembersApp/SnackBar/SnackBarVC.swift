//
//  SnackBarVC.swift
//
//  Created by mac-18 on 15/02/22.
//  Copyright © 2022 9spl. All rights reserved.
//

import UIKit

class SnackBarVC: UIViewController {

    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var btnClose: UIButton!
    @IBOutlet weak var lblMessage: UILabel!
    @IBOutlet weak var imgExclamation   : UIImageView!
    @IBOutlet weak var btnBackground   : UIButton!
    
    
    var snackBarStatus: Bool = false
    var snackBarMsg: String = ""
    var snackBarColor: String = ""
    var duration: Int = 5
    var isForNoConnection       : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        self.imgExclamation.isHidden = true
        self.btnBackground.isUserInteractionEnabled = true
        if self.isForNoConnection{
            self.imgExclamation.isHidden = false
            self.btnBackground.isUserInteractionEnabled = false
            self.btnClose.isHidden = true
        }else{
            dismissSnackBar()
        }
        
    }
    
    func setupUI(){
//        self.popupView.backgroundColor = UIColor(hexString: snackBarColor)
        self.lblMessage.text = snackBarMsg
    }
    
    // MARK: - Dismiss SnackBar
    func dismissSnackBar() {
        DispatchQueue.main.asyncAfter(deadline: .now() + DispatchTimeInterval.seconds(duration)) {
            self.close()
        }
    }

}

//MARK:- Extension for button clicked
extension SnackBarVC{
    @IBAction func btnCicked(_ sender: UIButton) {
        switch sender.tag {
        case 0:
            print("BG tapped")
            self.close()
        case 1:
            print("Close clicked")
            self.close()
        default:
            break
        }
    }
    //MARK:- Close Popup
    func close() {
        self.dismiss(animated: true, completion: nil)
    }
}
