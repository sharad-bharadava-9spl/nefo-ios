//
//  PopUpVC.swift
//  CCSMembersApp
//
//  Created by Parth Makwana on 07/07/23.
//  Copyright © 2023 Jaimin Patel. All rights reserved.
//

import UIKit
import Alamofire
import NVActivityIndicatorView

protocol BlockAndReportProtocol{
    func BlockAndReportVCResultData(isSucessFullyBlock:Bool,reason:String)
}

class BlockReportVC: UIViewController {
    //var lblReasonPlaceholder : UILabel!
    
    //MARK: Variable Declarations
    @IBOutlet weak var Viewpopup: UIView!
    @IBOutlet weak var txtView: UITextView!
    @IBOutlet weak var btnBlockreport: UIButton!
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var lblReasonPlaceholder: UILabel!
    
    @IBOutlet weak var btnblockandreport: UIButton!
    
    @IBOutlet weak var lblBlockreport: UILabel!
    @IBOutlet weak var lblCancel: UILabel!
    
    var delegate : BlockAndReportProtocol?
    
    var userId = ""
    
    //MARK: View Controller lify-cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupLanguageData()
        // Create a placeholder label
        self.txtView.delegate = self
        self.lblReasonPlaceholder.isHidden = false
        //self.lblMessagePlaceholder.text = "Write Here".localized
        self.lblReasonPlaceholder.text = "Reason".localized
    }
    // Dismiss the keyboard when user taps outside the text view
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    
    //Validate view
    func vadidateView() -> Bool{
        var isValidate = true
        if self.txtView.text.isEmpty{
            self.showAlert(title: "", message: "Please enter reason".localized)
            isValidate = false
        }
        return isValidate
    }
    
    func setupLanguageData(){
        self.lblReasonPlaceholder.text = "Reason".localized
        //self.lblBlockAndReport.text = "BlockAndReport".localized
        //self.btnBlockreport.setTitle("BlockAndReport".localized, for: .normal)
        //self.btnCancel.setTitle("Cancel".localized, for: .normal)
        
        
        self.lblBlockreport.text = "BlockAndReport".localized
        self.lblCancel.text = "Cancel".localized
        
        
    }
}

extension BlockReportVC {
    // MARK: Button Action
    @IBAction func btnClick(_ sender: UIButton) {
        
        switch sender.tag{
        case 1:
            if self.vadidateView(){
                //self.CallAPIBlockAndReportVC()
                self.showAlert(title: "", message: "msg_block_user".localized, buttonTitles: ["Cancel".localized, "Ok".localized], highlightedButtonIndex: 0, buttonStyles: [.default, .default]) { (btnIndex) in
                    if btnIndex == 1 {
                        self.dismiss(animated: true) {
                            self.delegate?.BlockAndReportVCResultData(isSucessFullyBlock: true, reason: self.txtView.text)
                        }
                    }
                }
            }
        case 2:
            self.dismiss(animated: true)
        default:
            break;
        }
        
    }
}

extension BlockReportVC : NVActivityIndicatorViewable{
    func CallAPIBlockAndReportVC() {     // Un-friend user
        startAnimating(CGSize(width: 100, height: 100), message: "", type: NVActivityIndicatorType.ballRotate, fadeInAnimation: nil)
        APIManager.callAPIRequest(Method: .post, url: "\(api_blockAndReportUser)", parameters: nil, headers: nil, showAlert: false, completion: { (jsonResult, msg) in
            DispatchQueue.main.async {
                self.stopAnimating(nil)
            }
            logD(jsonResult)
            
            self.dismiss(animated: true) {
                //self.delegate?.BlockAndReportVCResultData(isSucessFullyBlock: true)
            }
            
            
        }) { (httpResponse, errorMsg) in
            //logD(httpResponse ?? "")
            //logD(errorMsg ?? "")
            DispatchQueue.main.async {
                self.stopAnimating(nil)
            }
            self.showAlert(title: "", message: errorMsg)
        }
    }
}

// MARK: - Extension for TextView Delegate
extension BlockReportVC: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        self.lblReasonPlaceholder.isHidden = !textView.text.isEmpty
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        self.lblReasonPlaceholder.isHidden = !textView.text.isEmpty
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        self.lblReasonPlaceholder.isHidden = true
    }
}


