//
//  FriendRequestListVC.swift
//  CCSMembersApp
//
//  Created by mac-18 on 29/12/22.
//  Copyright © 2022 Jaimin Patel. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import SwiftyJSON

class FriendRequestListVC: UIViewController, NVActivityIndicatorViewable {
    
    //MARK: Outlets
    @IBOutlet weak var tblFriendRequestList: UITableView!
    @IBOutlet weak var lblGoBack: UILabel!
    @IBOutlet weak var lblFrndReq: UILabel!
    @IBOutlet weak var btnsend: UIButton!
    @IBOutlet weak var btnrecived: UIButton!
    @IBOutlet weak var viewSeperatorSend: UIView!
    @IBOutlet weak var viewSeperatorReceive: UIView!
    @IBOutlet weak var lblOutgoingRequest: UILabel!
    @IBOutlet weak var lblIncomingRequest: UILabel!
    @IBOutlet weak var viewIncomingRequest: UIView!
    @IBOutlet weak var viewOutGoingRequest: UIView!
    
    
    var isSelectedIncomingRequest : Bool = true
    var arrData = JSON("")
    let refreshControl = UIRefreshControl()
    // MARK: - ViewController life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.setPullToRefresh()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if appDelegateShared.isOpenFriendsRequestFromNotification{
            appDelegateShared.isOpenFriendsRequestFromNotification = false
            self.selectReceiveOrSend(isSelectIncomingRequest: true)
            self.CallAPIGetListOfFriendRequestAndReceived(isFromSend: false)
        }
    }
    
    // MARK: - Setup View
    func setupUI() {
        self.navigationController?.navigationBar.isHidden = true
        self.setupNIB()
        self.setupLanguage()
        
        self.selectReceiveOrSend(isSelectIncomingRequest: true)
        self.CallAPIGetListOfFriendRequestAndReceived(isFromSend: false)
        //self.CallAPIGetListOfFriendRequest()
        self.viewIncomingRequest.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleIncomingRequest)))
        self.viewOutGoingRequest.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleOutgoingRequest)))
        
    }
    func setupLanguage() {
        self.lblGoBack.text = "Go Back".localized
        self.lblFrndReq.text = "Friend Requests".localized
        self.btnsend.setTitle("Send".localized, for: .normal)
        self.btnrecived.setTitle("Received".localized, for: .normal)
        
        self.lblIncomingRequest.text = "Incoming requests".localized
        self.lblOutgoingRequest.text = "Outgoing requests".localized
    }
    
    func selectReceiveOrSend(isSelectIncomingRequest: Bool = true) {
        self.isSelectedIncomingRequest = isSelectIncomingRequest
        if isSelectIncomingRequest {
            // Select Incoming request
            self.viewSeperatorReceive.isHidden = true
            self.viewSeperatorSend.isHidden = false // Show the separator for outgoing
            self.lblIncomingRequest.textColor = .white//UIColor(named: "out_Req_colour")
            self.lblOutgoingRequest.textColor = UIColor(named: "TabUnselectedColor") // Set the appropriate color
        } else {
            // Select Outgoing request
            self.viewSeperatorReceive.isHidden = false // Show the separator for incoming
            self.viewSeperatorSend.isHidden = true
            self.lblIncomingRequest.textColor = UIColor(named: "TabUnselectedColor") // Set the appropriate color
            self.lblOutgoingRequest.textColor = .white//UIColor(named: "out_Req_colour")
        }
    }
    fileprivate func setupNIB() {
        self.tblFriendRequestList.register(UINib(nibName: "\(CustomChatCell.self)", bundle: nil), forCellReuseIdentifier: "\(CustomChatCell.self)")
    }
    
    @objc func handleIncomingRequest(){
        self.selectReceiveOrSend(isSelectIncomingRequest: true)
        self.CallAPIGetListOfFriendRequestAndReceived(isFromSend: false)
    }
    @objc func handleOutgoingRequest(){
        self.selectReceiveOrSend(isSelectIncomingRequest: false)
        self.CallAPIGetListOfFriendRequestAndReceived(isFromSend: true)
    }
    func setPullToRefresh(){
        //refreshControl Pull to refresh
        self.refreshControl.tintColor = .white
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        self.tblFriendRequestList.addSubview(refreshControl)
    }
    @objc func refresh(_ sender: AnyObject) {
        // Code to refresh table view based on the selected request type

        if isSelectedIncomingRequest {
            // Refresh for incoming requests
            self.selectReceiveOrSend(isSelectIncomingRequest: true)
            self.CallAPIGetListOfFriendRequestAndReceived(isFromSend: false)
        } else {
            // Refresh for outgoing requests
            self.selectReceiveOrSend(isSelectIncomingRequest: false)
            self.CallAPIGetListOfFriendRequestAndReceived(isFromSend: true)
        }
        checkRecordAvailable(for: self.tblFriendRequestList, count: self.arrData.count, ctrlRefresh: nil, targetController: self, detail: noDataAvaiableDetail.init(msg: "msg_no_friend_requests".localized, img: nil, desc: ""), shouldShowCenter: true)
        self.refreshControl.endRefreshing()
    }
   }



// MARK: - Button Actions
extension FriendRequestListVC {
    @IBAction func btnSendReceived(_ sender: UIButton) {
        self.view.endEditing(true)
        sender.backgroundColor = UIColor(named: "in_Req_colour")
        
        switch sender.tag {
        case 0:
            self.selectReceiveOrSend(isSelectIncomingRequest: true)
            //self.btnrecived.backgroundColor = UIColor(named: "out_Req_colour")
            //if self.btnsend.isSelected{
            //  self.btnrecived.isSelected = true
            //            self.btnsend.isSelected = true
            // self.btnrecived.backgroundColor = UIColor(named: "tab_unselected")
            //self.CallAPIGetListOfFriendRequestAndReceived(userID: "user_id_here", forCancel: 0)
            self.CallAPIGetListOfFriendRequestAndReceived(isFromSend: false)
        case 1:
            self.selectReceiveOrSend(isSelectIncomingRequest: false)
            //self.btnsend.backgroundColor = UIColor(named: "out_Req_colour")
            // if self.btnsend.isSelected{
            //  self.btnrecived.isSelected = false
            //            self.btnrecived.isSelected = true
            //btnsend.backgroundColor = UIColor(named: "tab_unselected")
            //self.CallAPIGetListOfFriendRequestAndReceived(isFromSend: false)
            self.CallAPIGetListOfFriendRequestAndReceived(isFromSend: false)
        default:
            print()
        }
        
    }
    
    
}

extension FriendRequestListVC {
    @IBAction func btnBack(_ sender: UIButton) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
}

// MARK: - Extension UITableView delegate / datasource
extension FriendRequestListVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "\(CustomChatCell.self)", for: indexPath) as! CustomChatCell
        
        let data = self.arrData[indexPath.row]
        
        
        cell.setupData(data: data)
        cell.lblDescription.isHidden = true
        
        cell.imgBtn1?.isUserInteractionEnabled = true
        cell.imgBtn1?.tag = indexPath.row
        cell.imgBtn2?.isUserInteractionEnabled = true
        cell.imgBtn2?.tag = indexPath.row
        cell.imgBtn1.image = UIImage(named: "icon_checkmark")
        cell.imgBtn2.image = UIImage(named: "icon_cross")
        
        
        if self.isSelectedIncomingRequest {
            cell.imgBtn1?.isHidden = false
            cell.imgBtn2.isHidden = false
        } else {
            cell.imgBtn1.isHidden = true
            cell.imgBtn2.isHidden = false
        }
        let approveGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(approveRequest(sender:)))
        approveGesture.numberOfTapsRequired = 1
        let denyGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(denyRequest(sender:)))
        denyGesture.numberOfTapsRequired = 1
        cell.imgBtn1?.addGestureRecognizer(approveGesture)
        cell.imgBtn2?.addGestureRecognizer(denyGesture)
        
        let clickOnViewGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(openFriendsProfile(sender:)))
        clickOnViewGesture.numberOfTapsRequired = 1
        cell.viewBG.tag = indexPath.row
        cell.viewBG.addGestureRecognizer(clickOnViewGesture)
        
        return cell
    }
    @objc func openFriendsProfile(sender: UITapGestureRecognizer) {
        let nextVC = storyboardName.storyBoard_Chat.instantiateViewController(withIdentifier: "FriendProfileVC") as! FriendProfileVC
        nextVC.userData = self.arrData[sender.view!.tag]
        nextVC.screenOpenFrom = self.isSelectedIncomingRequest ? FriendsDetailsFrom.ReceiveRequest.get() : FriendsDetailsFrom.SentRequest.get()
        nextVC.acceptRejectDelegate = self
        nextVC.modalPresentationStyle = .fullScreen
        self.present(nextVC, animated: true, completion: nil)
    }
    
    @objc func approveRequest(sender: UITapGestureRecognizer){
        print("Approve: \(sender.view?.tag)")
        let data = self.arrData[sender.view!.tag]
        self.CallAPIRespondFriendRequest(userID: data["user_id"].stringValue, requestStatus: 1)
    }
    
    @objc func denyRequest(sender: UITapGestureRecognizer) {
        print("Deny: \(sender.view?.tag)")
        
        let data = self.arrData[sender.view!.tag]
        if self.isSelectedIncomingRequest{
            self.showAlert(title: "", message: "msg_Reject_frd_Request".localized, buttonTitles: ["Cancel".localized, "Ok".localized], highlightedButtonIndex: 0, buttonStyles: [.default, .default]) { (btnIndex) in
                if btnIndex == 1{
                    // Call API to deny friend request
                    self.CallAPIRespondFriendRequest(userID: data["user_id"].stringValue, requestStatus: 0)
                }
            }
        }else{
            self.showAlert(title: "", message: "msg_cancle_frd_Request".localized, buttonTitles: ["Cancel".localized, "Ok".localized], highlightedButtonIndex: 0, buttonStyles: [.default, .default]) { (btnIndex) in
                if btnIndex == 1{
                    // Call API to Cancel friend request
                    self.CallAPICancelFriendRequest(userID: data["user_id"].stringValue)
                }
            }
        }
    }
}
// MARK: - Extesnion for Accept and Reject Delegate
extension FriendRequestListVC:AcceptRejectFriendRequestDelegate {
    func acceptRejectFriendRequest(screenOpenFrom: String) {
        if screenOpenFrom == FriendsDetailsFrom.SentRequest.get(){
            //Sent Request
            self.selectReceiveOrSend(isSelectIncomingRequest: false)
            self.CallAPIGetListOfFriendRequestAndReceived(isFromSend: true)
        }else{
            //Receive Request
            self.selectReceiveOrSend(isSelectIncomingRequest: true)
            self.CallAPIGetListOfFriendRequestAndReceived(isFromSend: false)
        }
    }
}

// MARK: - API Call
extension FriendRequestListVC {
    
    func CallAPIGetListOfFriendRequestAndReceived(isFromSend:Bool) {     // Get list of friend requests
        startAnimating(CGSize(width: 100, height: 100), message: "", type: NVActivityIndicatorType.ballRotate, fadeInAnimation: nil)
        
        APIManager.callAPIRequest(Method: .post, url: "\(api_listOfFriendRequest)", parameters: APIParam.listOfFriendRequest(user_id: getFromUserDefaultForKey("member_id") as? String ?? "", language: "\(Language.language)", send_request: isFromSend ? "1":"0").getParam(), headers: nil, showAlert: false, completion: { (jsonResult, msg) in
            DispatchQueue.main.async {
                self.stopAnimating(nil)
            }
            logD(jsonResult)
            self.arrData.dictionaryObject?.removeAll()
            if jsonResult["flag"].stringValue == "1"{   // ~~~9S flag = 1 ==>
                self.arrData = jsonResult["data"]
            }else{      // ~~~9S flag = 0 ==>
                //self.showAlert(title: "", message: jsonResult["message"].stringValue)
            }
            
            checkRecordAvailable(for: self.tblFriendRequestList, count: self.arrData.count, ctrlRefresh: nil, targetController: self, detail: noDataAvaiableDetail.init(msg: "msg_no_friend_requests".localized, img: nil, desc: ""), shouldShowCenter: true)
            
            
        }) { (httpResponse, errorMsg) in
            //logD(httpResponse ?? "")
            //logD(errorMsg ?? "")
            DispatchQueue.main.async {
                self.stopAnimating(nil)
            }
            checkRecordAvailable(for: self.tblFriendRequestList, count: 0, ctrlRefresh: nil, targetController: self, detail: noDataAvaiableDetail.init(msg: "msg_no_friend_requests".localized, img: nil, desc: ""), shouldShowCenter: true)
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
                    // Show alert message
                    self.showAlert(title: "", message: jsonResult?["message"].stringValue)
                    
                    // If the request was accepted, update data and reload table view
                    if requestStatus == 1 {
                        // Remove the accepted request from arrData
                        
                    }
                    let indexToRemove = self.arrData.arrayValue.firstIndex { $0["user_id"].stringValue == userID }
                    if let index = indexToRemove {
                        self.arrData.arrayObject?.remove(at: index)
                        checkRecordAvailable(for: self.tblFriendRequestList, count: self.arrData.count, ctrlRefresh: nil, targetController: self, detail: noDataAvaiableDetail.init(msg: "msg_no_friend_requests".localized, img: nil, desc: ""), shouldShowCenter: true)
                    }
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
    
    func CallAPICancelFriendRequest(userID: String) {     // Send/cancel friend Request
        startAnimating(CGSize(width: 100, height: 100), message: "", type: NVActivityIndicatorType.ballRotate, fadeInAnimation: nil)
        APIManager.callAPIRequest(Method: .post, url: "\(api_sendFriendRequest)", parameters: APIParam.sendFriendRequest(user_id: getFromUserDefaultForKey("member_id") as? String ?? "", receive_id: userID, unfriend: 1, language: "\(Language.language)").getParam(), headers: nil, showAlert: false, completion: { (jsonResult, msg) in
            DispatchQueue.main.async {
                self.stopAnimating(nil)
            }
            logD(jsonResult)
            if jsonResult["flag"].stringValue == "1"{   // ~~~9S flag = 1 ==>
                let indexToRemove = self.arrData.arrayValue.firstIndex { $0["user_id"].stringValue == userID }
                if let index = indexToRemove {
                    self.arrData.arrayObject?.remove(at: index)
                    checkRecordAvailable(for: self.tblFriendRequestList, count: self.arrData.count, ctrlRefresh: nil, targetController: self, detail: noDataAvaiableDetail.init(msg: "msg_no_friend_requests".localized, img: nil, desc: ""), shouldShowCenter: true)
                }
                
            }else{      // ~~~9S flag = 0 ==>
                //self.showAlert(title: "", message: jsonResult["message"].stringValue)
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
    
    func CallAPIFriendRequest(userID: String, forCancel: Int) {     // Send/cancel friend Request
        startAnimating(CGSize(width: 100, height: 100), message: "", type: NVActivityIndicatorType.ballRotate, fadeInAnimation: nil)
        APIManager.callAPIRequest(Method: .post, url: "\(api_sendFriendRequest)", parameters: APIParam.sendFriendRequest(user_id: getFromUserDefaultForKey("member_id") as? String ?? "", receive_id: userID, unfriend: forCancel, language: "\(Language.language)").getParam(), headers: nil, showAlert: false, completion: { (jsonResult, msg) in
            DispatchQueue.main.async {
                self.stopAnimating(nil)
            }
            
            if jsonResult["flag"].stringValue == "1" {
                // Successful unfriending logic
                // For example, you might want to remove the user from the arrData array and reload the table view
                // Remove the unfriended user from the arrData array
                if let indexToRemove = self.arrData.arrayValue.firstIndex(where: { $0["id"].stringValue == userID }) {
                    self.arrData.arrayObject?.remove(at: indexToRemove)
                    checkRecordAvailable(for: self.tblFriendRequestList, count: self.arrData.count, ctrlRefresh: nil, targetController: self, detail: noDataAvaiableDetail.init(msg: "msg_no_friend_requests".localized, img: nil, desc: ""), shouldShowCenter: true)
                }
                
                // Perform any other actions needed after unfriending
                
                Messages.unFriendUserByMe(senderUserId: MEMBER_ID, receiverUserId: userID)
            } else {
                // Show alert for failure
                self.showAlert(title: "", message: jsonResult["message"].stringValue)
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
