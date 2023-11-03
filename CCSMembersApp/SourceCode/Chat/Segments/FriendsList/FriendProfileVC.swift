//
//  FriendProfileVC.swift
//  CCSMembersApp
//
//  Created by mac-18 on 29/12/22.
//  Copyright © 2022 Jaimin Patel. All rights reserved.
//

import UIKit
import SwiftyJSON
import NVActivityIndicatorView


protocol AcceptRejectFriendRequestDelegate{
    func acceptRejectFriendRequest(screenOpenFrom:String)
}
class FriendProfileVC: UIViewController, NVActivityIndicatorViewable {
    
    //MARK: Outlets
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var imgBG: UIImageView!
    
    @IBOutlet weak var lblGoBack: UILabel!
    @IBOutlet weak var lblCancelRequest: UILabel!
    @IBOutlet weak var lblRequestSentMessage: UILabel!
    @IBOutlet weak var lblSendFriendRequest: UILabel!
    @IBOutlet weak var viewAddFriend: UIView!
    @IBOutlet weak var viewCancelRequest: UIView!
    @IBOutlet weak var viewFriendRequestSentInfo: UIView!
    @IBOutlet weak var viewFriendRequestCancle: UIView!
    var userData = JSON("")
    
    var acceptRejectDelegate : AcceptRejectFriendRequestDelegate?
    var screenOpenFrom = FriendsDetailsFrom.ReceiveRequest.get()
    
    // MARK: - ViewController life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        self.setupUI()
    }
    
    // MARK: - Setup View
    func setupUI() {
        self.setupData()
        self.setupMiddleView(friendStatus: self.userData["friendStatus"].intValue)
        self.setupLanguage()
        
    }
    func setupLanguage() {
        //       self.lblSendFriendRequest.text = "".localized
    }
    fileprivate func setupData() {
        // Friend Status
        ///friendStatus = 0 Both users unfriend
        ///friendStatus = 1 Both users are friend
        ///friendStatus = 2 Logged in user already sent friend request
        ///friendStatus = 3 Opponent/Searched user sent friend request to logged in user
        
        self.lblUserName.text = "@" + userData["username"].stringValue
    }
    func setupMiddleView(friendStatus: Int){
        switch screenOpenFrom{
        case FriendsDetailsFrom.ReceiveRequest.get():
            self.viewAddFriend.isHidden = false
             self.viewFriendRequestCancle.isHidden = false
             self.viewFriendRequestSentInfo.isHidden = true
            self.lblRequestSentMessage.text = "Reject Friend Request".localized
            self.lblSendFriendRequest.text = "Accept Friend Request".localized
            self.lblGoBack.text = "Go Back".localized
            
        case FriendsDetailsFrom.SentRequest.get():
            self.viewAddFriend.isHidden = true
            self.viewFriendRequestCancle.isHidden = false
            self.viewFriendRequestSentInfo.isHidden = false
            self.lblRequestSentMessage.text = "Success_Friend_Requests".localized
            self.lblCancelRequest.text = "Cancel Friend Request".localized
            self.lblGoBack.text = "Go Back".localized
            
             //self.lblRequestSentMessage.isHidden = true
        default:
            break;
        }
    }
}

// MARK: - Button Actions
extension FriendProfileVC {
    @IBAction func btnBack(_ sender: UIButton) {
        self.dismiss(animated: false , completion: nil)
    }
    
    @IBAction func btnSendFriendRequest(_ sender: UIButton) {
        self.CallAPIRespondFriendRequest(userID: self.userData["user_id"].stringValue, requestStatus: 1)
        }
    
    @IBAction func btnCancelFriendRequest(_ sender: UIButton) {
        if screenOpenFrom == FriendsDetailsFrom.SentRequest.get(){
            self.showAlert(title: "", message: "msg_cancle_frd_Request".localized, buttonTitles: ["Cancel".localized, "Ok".localized], highlightedButtonIndex: 0, buttonStyles: [.default, .default]) { (btnIndex) in
                if btnIndex == 1 {
                    self.CallAPIFriendRequest(userID: self.userData["user_id"].stringValue, forCancel: 1)
        
                }
            }
        }else if screenOpenFrom == FriendsDetailsFrom.ReceiveRequest.get(){
            self.showAlert(title: "", message: "msg_Reject_frd_Request".localized, buttonTitles: ["Cancel".localized, "Ok".localized], highlightedButtonIndex: 0, buttonStyles: [.default, .default]) { (btnIndex) in
                if btnIndex == 1 {
                    self.CallAPIRespondFriendRequest(userID: self.userData["user_id"].stringValue, requestStatus: 0)
                }
                else{
                    
                }
            }
        }
    }
}


// MARK: - API Call
extension FriendProfileVC {
    
    func CallAPIFriendRequest(userID: String, forCancel: Int) {
        startAnimating(CGSize(width: 100, height: 100), message: "", type: NVActivityIndicatorType.ballRotate, fadeInAnimation: nil)
        
        let receiveID = self.userData["user_id"].stringValue  // Adjust the key based on your data structure
        
        APIManager.callAPIRequest(Method: .post, url: "\(api_sendFriendRequest)", parameters: APIParam.sendFriendRequest(user_id: getFromUserDefaultForKey("member_id") as? String ?? "", receive_id: receiveID, unfriend: forCancel, language: "\(Language.language)").getParam(), headers: nil, showAlert: false, completion: { (jsonResult, msg) in
            DispatchQueue.main.async {
                self.stopAnimating(nil)
            }
            
            // Logging the JSON result
            logD(jsonResult)
            
            // Check if the friend request was successfully handled
            if jsonResult["flag"].stringValue == "1" {
                // Friend request handled successfully, so dismiss the current view controller
                self.showAlert(title: "", message: jsonResult["message"].stringValue, buttonTitles: ["Ok".localized], highlightedButtonIndex: 0, buttonStyles: [.default, .default]) { (btnIndex) in
                    self.acceptRejectDelegate?.acceptRejectFriendRequest(screenOpenFrom: self.screenOpenFrom)
                    self.dismiss(animated: true)
                }
                
            } else {
                // Show an alert for failure
                self.showAlert(title: "", message: jsonResult["message"].stringValue)
            }
            
        }) { (httpResponse, errorMsg) in
            // Show an alert for API request failure
            self.showAlert(title: "", message: errorMsg)
        }
    }
    func CallAPIRespondFriendRequest(userID: String, requestStatus: Int) {
        startAnimating(CGSize(width: 100, height: 100), message: "", type: NVActivityIndicatorType.ballRotate, fadeInAnimation: nil)
        
        appDelegateShared.CallAPIRespondFriendRequest(userID: userID, requestStatus: requestStatus) { (jsonResult, error) in
            DispatchQueue.main.async {
                self.stopAnimating(nil)
            }
            
            if error == nil {
                if jsonResult?["flag"].stringValue == "1" {
                    // Show an alert when the request is accepted
                    self.showAlert(title: "", message: jsonResult?["message"].stringValue, buttonTitles: ["Ok".localized], highlightedButtonIndex: 0, buttonStyles: [.default, .default]) { (btnIndex) in
                        self.acceptRejectDelegate?.acceptRejectFriendRequest(screenOpenFrom: self.screenOpenFrom)
                        self.dismiss(animated: true, completion: nil)
                    }
                    
//                    let alert = UIAlertController(title: "", message: "Accept Friend Request".localized, preferredStyle: .alert)
//                    let okayAction = UIAlertAction(title: "Ok".localized, style: .default) { _ in
//                        // Call the delegate method and dismiss the view controller
//                        self.acceptRejectDelegate?.acceptRejectFriendRequest(screenOpenFrom: self.screenOpenFrom)
//                        self.dismiss(animated: true, completion: nil)
//                    }
//                    alert.addAction(okayAction)
//                    self.present(alert, animated: true, completion: nil)
                    
                } else {
                    // Show alert for failure
                    self.showAlert(title: "", message: jsonResult?["message"].stringValue)
                }
            } else {
                logD(error)
                // Show alert for error
                // self.showAlert(title: "", message: error)
            }
        }
    }
    
}
