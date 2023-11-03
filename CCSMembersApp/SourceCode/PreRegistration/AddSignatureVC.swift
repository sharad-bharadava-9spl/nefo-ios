//
//  AddSignatureVC.swift
//  CCSMembersApp
//
//  Created by Divyesh Dabhi on 04/05/23.
//  Copyright © 2023 Jaimin Patel. All rights reserved.
//

import UIKit



protocol setImageDelegate {
    func setImage(image:UIImage)
}


class AddSignatureVC: UIViewController {
    
    //MARK: - Variable Declaration
    @IBOutlet weak var btnClear: UIButton!
    @IBOutlet weak var btnDone: UIButton!
    @IBOutlet weak var lblAddSignature: UILabel!
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var mainImageView: UIImageView!
    
    @IBOutlet weak var signatureMainView: UIView!
    
    var signatureView = CanvasView()
    var selectedImage = UIImage()
    
    // Interface Links
    //@IBOutlet weak var signatureView: Canvas!       //EFF4F7
    
    var lastPoint = CGPoint.zero
    var color = UIColor.black
    var brushWidth: CGFloat = 10.0
    var opacity: CGFloat = 1.0
    var swiped = false
    var delegate: setImageDelegate?
    
    //MARK: - ViewController Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.signatureView.setStrokeColor(color: UIColor.black)
        self.signatureView.setStrokeWidth(width: 5.0)
        //self.view.isUserInteractionEnabled = false
        
        if self.selectedImage.cgImage == nil && self.selectedImage.ciImage == nil {
            self.mainImageView.isHidden = true
        }else{
            self.mainImageView.isHidden = false
            self.mainImageView.image = selectedImage
        }
        
        //self.mainImageView.isHidden = false
        //self.mainImageView.image = selectedImage
        
        self.signatureView.backgroundColor = .white
        self.setupLanguage()
    }
    override func viewDidLayoutSubviews () {
        super.viewDidLayoutSubviews()
        self.signatureView.frame = CGRect(x: 0, y: 0, width: self.signatureMainView.frame.size.width, height: self.signatureMainView.frame.size.height)
        
        self.signatureMainView.addSubview(self.signatureView)
        //print ("viewDidLayoutSubviews position" ,button.frame)
        
    }
    func setupLanguage(){
        self.btnClear.setTitle("CLEAR".localized, for: .normal)
        self.btnDone.setTitle("DONE".localized, for: .normal)
        self.lblAddSignature.text = "ADD SIGNATURE".localized
    }

    @IBAction func btnClicked(_ sender: UIButton) {
        
        switch sender.tag {
        case 0:
            //self.mainImageView.image = nil
            self.signatureView.clear()
            self.signatureView.isDraw = false
        case 1:
            if signatureView.isDraw{
                //self.mainImageView.isHidden = false
                self.mainImageView.image = self.signatureView.asImage()
                self.signatureView.backgroundColor = .clear
                self.delegate?.setImage(image: self.signatureView.asImage())
                self.close()
            }else{
                print("you have does not any signature")
                self.showAlert(title: "", message: "msg_enter_signature".localized)
            }
        case 2:
            self.close()
        default:
            break;
        }
        
    }
}
//MARK: - Extension for Close
extension AddSignatureVC {
    //MARK:- Close Popup
    func close() {
        UIView .animate(withDuration:0.3 , delay: 0.0, options: UIView.AnimationOptions.curveLinear, animations: {
            self.popupView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        }, completion: {
            (value: Bool) in
            self.view.removeFromSuperview()
            //self.removeFromParentViewController()
            self.removeFromParent()
        })
    }
}

