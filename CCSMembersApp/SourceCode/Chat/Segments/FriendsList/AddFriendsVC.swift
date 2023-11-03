//
//  AddFriendsVC.swift
//  CCSMembersApp
//
//  Created by Divvyesh on 10/08/23.
//  Copyright © 2023 Jaimin Patel. All rights reserved.
//

import UIKit
import AVFoundation
import SwiftyJSON
import NVActivityIndicatorView

class AddFriendsVC: UIViewController, NVActivityIndicatorViewable {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var tblFriendList: UITableView!
    @IBOutlet weak var lblErrorMessage: UILabel!
    @IBOutlet weak var lblScanQR: UILabel!
    @IBOutlet weak var txtSearch: UITextField!
    @IBOutlet weak var lblSearchTitle: UILabel!
    @IBOutlet weak var lblGoBackTitle: UILabel!
    @IBOutlet weak var cnstTblListHeight        : NSLayoutConstraint!
    @IBOutlet weak var lblYourFriend: UILabel!
    @IBOutlet weak var stackFriendLabel: UIStackView!
    @IBOutlet weak var viewInfo: UIView!
    @IBOutlet weak var lblFriendRequestSentInfo: UILabel!
    
    var arrData = JSON("")
    
    //    let refreshControl = UIRefreshControl()
    var qrCode = ""
    
    // MARK: - ViewController life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        
        
        //        txtSearch.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.removeObserver()
        self.addObserver()
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.removeObserver()
    }
    deinit{
        self.removeObserver()
    }
    override func viewWillAppear(_ animated: Bool) {
        //        if let text = txtSearch.text, !text.isEmpty{
        //            self.lblYourFriend.isHidden = true
        //            self.CallAPISearchFriend(strUsername: text)
        //        } else {
        //
        //        }
    }
    override func viewDidLayoutSubviews() {
        print(self.view.frame)
        print(self.stackFriendLabel.frame)
        print(self.tblFriendList.frame)
        self.cnstTblListHeight.constant = self.view.frame.height - (self.stackFriendLabel.frame.origin.y + self.stackFriendLabel.frame.height)
    }
    //Add observer
    func addObserver(){
        NotificationCenter.default.addObserver(self, selector: #selector(self.refreshMyFriendList(notification:)), name: Notification.Name(NotificationName().RefreshMyFriendList), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.openFriendRequestController(notification:)), name: Notification.Name(NotificationName().OpenFriendsRequest), object: nil)
        
    }
    //Remove Observer
    func removeObserver(){
        NotificationCenter.default.removeObserver(self, name: Notification.Name(NotificationName().RefreshMyFriendList), object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name(NotificationName().OpenFriendsRequest), object: nil)
        
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Setup View
    func setupUI() {
        self.txtSearch.returnKeyType = UIReturnKeyType.search
        self.txtSearch.delegate = self
        self.hideKeyboardWhenTappedAround()
        self.setupNIB()
        self.setupLanguage()
    }
    func setupLanguage() {
        self.lblSearchTitle.text = "Or Search for friends by username".localized
        //        self.lblGoBackTitle.text = "Go Back".localized
        self.lblYourFriend.text = "Your friends".localized
        self.lblGoBackTitle.text = "Go Back".localized
        self.lblScanQR.text = "Scan QR friend".localized
        self.txtSearch.placeholder = "Search username".localized
        self.lblFriendRequestSentInfo.text = "Success_Friend_Requests".localized
        
    }
    @objc func refresh(_ sender: AnyObject) {
        // Code to refresh table view
        self.qrCode = ""
        self.txtSearch.text = ""
        self.lblYourFriend.isHidden = false
    }
    fileprivate func setupNIB() {
        //        self.tblFriendList.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
        self.tblFriendList.register(UINib(nibName: "\(CustomChatCell.self)", bundle: nil), forCellReuseIdentifier: "\(CustomChatCell.self)")
    }
    
    //MARK: tableview height observer
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let obj = object as? UITableView {
            if obj == self.tblFriendList && keyPath == "contentSize" {
                if let newSize = change?[NSKeyValueChangeKey.newKey] as? CGSize {
                    //do stuff here
                    
                    self.cnstTblListHeight?.constant = newSize.height
                    self.view.layoutIfNeeded()
                }
            }
        }
    }
    //Update camara Permission
    func checkCameraPermission(completion: @escaping (Bool) -> Void) {
        if AVCaptureDevice.authorizationStatus(for: .video) == .authorized {
            // Camera access is already authorized
            completion(true)
        } else {
            AVCaptureDevice.requestAccess(for: .video) { granted in
                // Execute the completion handler with the result (granted or denied)
                completion(granted)
            }
        }
    }
    
    // Handle search bar textfield
    @objc func textFieldDidChange(_ textField: UITextField) {
        self.qrCode = ""
        if let text = textField.text, !text.isEmpty {
            print(text)
            self.lblYourFriend.isHidden = true
            self.CallAPISearchFriend(strUsername: text)
        }else {
            self.lblYourFriend.isHidden = false
            //            self.CallAPIGetListOfFriend()
            self.arrData.dictionaryObject?.removeAll()
            checkRecordAvailable(for: self.tblFriendList, count: self.arrData.count, ctrlRefresh: nil, targetController: self, detail: noDataAvaiableDetail.init(msg: "No data available".localized, img: nil, desc: ""), shouldShowCenter: true)
        }
    }
    
    // refreshMyFriendList
    @objc func refreshMyFriendList(notification: Notification) {
        self.qrCode = ""
        self.txtSearch.text = ""
        //        self.CallAPIGetListOfFriend()
        self.arrData.dictionaryObject?.removeAll()
        checkRecordAvailable(for: self.tblFriendList, count: self.arrData.count, ctrlRefresh: nil, targetController: self, detail: noDataAvaiableDetail.init(msg: "No data available".localized, img: nil, desc: ""), shouldShowCenter: true)
    }
    // open Friend Request Controller from notification
    @objc func openFriendRequestController(notification: Notification) {
        appDelegateShared.isOpenFriendsRequestFromNotification = false
        let vc = storyboardName.storyBoard_Chat.instantiateViewController(withIdentifier: "FriendRequestListVC") as! FriendRequestListVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func setView(view: UIView, hidden: Bool) {
        UIView.transition(with: view, duration: 0.3, options: .transitionCrossDissolve, animations: {
            view.isHidden = hidden
        })
    }
}

// MARK: - Button Actions
extension AddFriendsVC {
    @IBAction func btnScanQRCode(_ sender: UIButton) {
        checkCameraPermission { isAllowed in
            if isAllowed {
                DispatchQueue.main.async {
                    let vc = storyboardName.storyBoard_Chat.instantiateViewController(withIdentifier: "\(QRScannerVC.self)") as! QRScannerVC
                    vc.delegate = self
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            } else {
                DispatchQueue.main.async {
                    self.showAlert(title: "Error".localized, message: "Camera access required to scan QR code".localized, buttonTitles: ["Cancel".localized, "Open Settings".localized], highlightedButtonIndex: 0, buttonStyles: [.default, .default]) { (btnIndex) in
                        if btnIndex == 1 {
                            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func btnClickOnGoBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}

// MARK: - Extension UITableView delegate / datasource
extension AddFriendsVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "\(CustomChatCell.self)", for: indexPath) as! CustomChatCell
        let data = self.arrData[indexPath.row]
        
        cell.imgBtn1?.isUserInteractionEnabled = true
        cell.imgBtn1?.tag = indexPath.row
        cell.imgBtn2?.isUserInteractionEnabled = true
        cell.imgBtn2?.tag = indexPath.row
        
        let approveGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(btn1Action(sender:)))
        approveGesture.numberOfTapsRequired = 1
        let denyGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(btn2Action(sender:)))
        denyGesture.numberOfTapsRequired = 1
        cell.imgBtn1?.addGestureRecognizer(approveGesture)
        cell.imgBtn2?.addGestureRecognizer(denyGesture)
        
        cell.lblDescription.isHidden = true
        cell.setupData(data: data)
        
        // Friend Status
        ///friendStatus = 0 Both users unfriend
        ///friendStatus = 1 Both users are friend
        ///friendStatus = 2 Logged in user already sent friend request
        ///friendStatus = 3 Opponent/Searched user sent friend request to logged in user
        
        cell.imgBtn1.isHidden = false
        cell.imgBtn2.isHidden = true
        cell.imgBtn1.image = UIImage(named: "icon_plus")
        
        /*
         if data["friendStatus"].intValue == 0 { ///friendStatus = 0 Both users unfriend
         cell.imgBtn1.isHidden = false
         cell.imgBtn2.isHidden = true
         cell.imgBtn1.image = UIImage(named: "icon_plus")
         }else if data["friendStatus"].intValue == 1{ ///friendStatus = 1 Both users are friend
         cell.imgBtn1.isHidden = false
         cell.imgBtn2.isHidden = false
         cell.imgBtn1.image = UIImage(named: "icon_message")
         cell.imgBtn2.image = UIImage(named: "icon_trash")
         }else if data["friendStatus"].intValue == 2{ ///friendStatus = 2 Logged in user already sent friend request
         cell.imgBtn1.isHidden = true
         cell.imgBtn2.isHidden = false
         cell.imgBtn2.image = UIImage(named: "icon_cross")
         cell.lblDescription.isHidden = false
         }else { ///friendStatus = 3 Opponent/Searched user sent friend request to logged in user
         cell.imgBtn1.isHidden = false
         cell.imgBtn2.isHidden = false
         cell.imgBtn1.image = UIImage(named: "icon_checkmark")
         cell.imgBtn2.image = UIImage(named: "icon_cross")
         
         }*/
        return cell
    }
    @objc func btn1Action(sender: UITapGestureRecognizer){
        print("btn 1: \(sender.view?.tag)")
        let data = self.arrData[sender.view!.tag]
        
        if data["friendStatus"].intValue == 0 { ///friendStatus = 0 Both users unfriend
            // send friend request
            self.CallAPIFriendRequest(userID: data["id"].stringValue, forCancel: 0)
        }else if data["friendStatus"].intValue == 1{ ///friendStatus = 1 Both users are friend
            // Open chatting screen
            
            
            var userid = data["send_user_id"].stringValue == MEMBER_ID ? data["receive_user_id"].stringValue : data["send_user_id"].stringValue
            let receiverName = data["username"].stringValue
            if userid == ""{
                userid = data["id"].stringValue
            }
            
            let dict = ["userid":userid,"receiverName":receiverName]
            
            NotificationCenter.default.post(name: Notification.Name(NotificationName().OepnChatDetailScreen), object: dict)
            
        }else if data["friendStatus"].intValue == 2{ ///friendStatus = 2 Logged in user already sent friend request
        }else { ///friendStatus = 3 Opponent/Searched user sent friend request to logged in user
            // accept friend request
            //self.CallAPIRespondFriendRequest(userID: data["id"].stringValue, requestStatus: 1)
        }
    }
    @objc func btn2Action(sender: UITapGestureRecognizer){
        print("btn 2: \(sender.view?.tag)")
        
        let data = self.arrData[sender.view!.tag]
        
        if data["friendStatus"].intValue == 0 { ///friendStatus = 0 Both users unfriend
        }else if data["friendStatus"].intValue == 1{ ///friendStatus = 1 Both users are friend
            // Call api for unfriend
            self.showAlert(title: "", message: "msg_unfriend_user".localized, buttonTitles: ["Cancel".localized, "Ok".localized], highlightedButtonIndex: 0, buttonStyles: [.default, .default]) { (btnIndex) in
                if btnIndex == 1 {
                    self.CallAPIUnFriend(friendID: data["id"].stringValue)
                }
            }
        }else if data["friendStatus"].intValue == 2{ ///friendStatus = 2 Logged in user already sent friend request
            // cancel friend request
            self.CallAPIFriendRequest(userID: data["id"].stringValue, forCancel: 1)
            
        }else { ///friendStatus = 3 Opponent/Searched user sent friend request to logged in user
            // Deny friend request
            //self.CallAPIRespondFriendRequest(userID: data["id"].stringValue, requestStatus: 0)
        }
        
    }
}

// MARK: - Extenson for QRCodeScannerDelegate
extension AddFriendsVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        self.view.endEditing(true)
        guard let username = textField.text else {return false}
        self.CallAPISearchFriend(strUsername: username)
        return false
    }
}
// MARK: - Extenson for QRCodeScannerDelegate
extension AddFriendsVC: QRCodeScannerDelegate {
    func getQRData(QRString: String) {
        self.qrCode = QRString
        self.CallApiQrcodeSendrequest(QRCodeString: QRString) { isValidUser in
           // self.tblFriendList.isHidden = true
            if isValidUser {
                let data = self.arrData[self.view!.tag]
                if data["friendStatus"].intValue == 0 {
                    // send friend request
                    self.CallAPIFriendRequest(userID: data["id"].stringValue, forCancel: 0)
                } else if data["friendStatus"].intValue == 1 {
                    // Handle friendStatus == 1 case if needed
                }
            } else {
                // Handle the case when the user is not valid
            }
        }
    }
}
// MARK: - API Call
extension AddFriendsVC {
    func CallAPISearchFriend(strUsername: String) {     // Search friend by username
        APIManager.callAPIRequest(Method: .post, url: "\(api_globlesearchFriend)", parameters: APIParam.searchFriend(user_id: getFromUserDefaultForKey("member_id") as? String ?? "", username: strUsername, language: "\(Language.language)",searchFriend:false).getParam(), headers: nil, showAlert: false, completion: { (jsonResult, msg) in
            logD(jsonResult)
            self.arrData.dictionaryObject?.removeAll()
            
            let flag = jsonResult["flag"].intValue
            
            if flag == 1 {
                let userCount = jsonResult["user_count"].intValue
                if userCount > 0 {
                    
                    // Handle the friendStatus and isblock properties here
                    
                    let friendStatus = jsonResult["data"][0]["friendStatus"].intValue
                    let isBlock = jsonResult["data"][0]["isblock"].intValue
                    
                    if friendStatus == 0{
                        self.arrData = jsonResult["data"]
                    }else{
                        self.showAlert(title: "", message: jsonResult["data"][0]["message"].stringValue)
                    }
                    
                } else {
                    // Handle the case when user has no friends
                }
            } else {
                let message = jsonResult["message"].stringValue
                if message == "User not Found" {
                    // Handle the case when the user is not found
                } else {
                    // Handle other error cases
                }
            }
            
            // Show the appropriate message or data based on the response
            checkRecordAvailable(for: self.tblFriendList, count: self.arrData.count, ctrlRefresh: nil, targetController: self, detail: noDataAvaiableDetail.init(msg: "No data available".localized, img: nil, desc: ""), shouldShowCenter: true)
            
        }) { (httpResponse, errorMsg) in
            DispatchQueue.main.async {
                self.stopAnimating(nil)
            }
            checkRecordAvailable(for: self.tblFriendList, count: 0, ctrlRefresh: nil, targetController: self, detail: noDataAvaiableDetail.init(msg: "No data available".localized, img: nil, desc: ""), shouldShowCenter: true)
            self.showAlert(title: "", message: errorMsg)
        }
    }
    
    func CallAPIFriendRequest(userID: String, forCancel: Int) {     // Send/cancel friend Request
        startAnimating(CGSize(width: 100, height: 100), message: "", type: NVActivityIndicatorType.ballRotate, fadeInAnimation: nil)
        APIManager.callAPIRequest(Method: .post, url: "\(api_sendFriendRequest)", parameters: APIParam.sendFriendRequest(user_id: getFromUserDefaultForKey("member_id") as? String ?? "", receive_id: userID, unfriend: forCancel, language: "\(Language.language)").getParam(), headers: nil, showAlert: false, completion: { (jsonResult, msg) in
            DispatchQueue.main.async {
                self.stopAnimating(nil)
            }
            logD(jsonResult)
            if jsonResult["flag"].stringValue == "1"{   // ~~~9S flag = 1 ==>
                if forCancel == 0 {
                    self.lblFriendRequestSentInfo.text = jsonResult["message"].stringValue
                    self.setView(view: self.viewInfo, hidden: false)
                    Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { (_) in
                        self.setView(view: self.viewInfo, hidden: true)
                    }
                }
                self.arrData = JSON("")
                checkRecordAvailable(for: self.tblFriendList, count: self.arrData.count, ctrlRefresh: nil, targetController: self, detail: noDataAvaiableDetail.init(msg: "No data available".localized, img: nil, desc: ""), shouldShowCenter: true)
                
            }else{      // ~~~9S flag = 0 ==>
                //self.showAlert(title: "", message: jsonResult["message"].stringValue)
                openSnakBar(viewController: self, message: jsonResult["message"].stringValue)
            }
            
        }) { (httpResponse, errorMsg) in
            DispatchQueue.main.async {
                self.stopAnimating(nil)
            }
            self.showAlert(title: "", message: errorMsg)
        }
    }
    
    func CallAPIRespondFriendRequest(userID: String, requestStatus: Int) { // Accept/Deny friend Request
        startAnimating(CGSize(width: 100, height: 100), message: "", type: NVActivityIndicatorType.ballRotate, fadeInAnimation: nil)
        appDelegateShared.CallAPIRespondFriendRequest(userID: userID, requestStatus: requestStatus) { (jsonResult, error) in
            DispatchQueue.main.async {
                self.stopAnimating(nil)
            }
            if error == nil{
                if jsonResult?["flag"].stringValue == "1"{   // ~~~9S flag = 1 ==>
                    
                    if self.qrCode == ""{
                        guard let text = self.txtSearch.text, !text.isEmpty else { return }
                        self.CallAPISearchFriend(strUsername: text)
                    }else{
                        self.CallAPISearchFriendByQRCode(QRCodeString: self.qrCode)
                    }
                    
                    if requestStatus == 1{
                        Messages.friendUserByMe(senderUserId: MEMBER_ID, receiverUserId: userID)
                    }
                }else{      // ~~~9S flag = 0 ==>
                    //self.showAlert(title: "", message: jsonResult?["message"].stringValue)
                    openSnakBar(viewController: self, message: jsonResult?["message"].stringValue ?? "")
                }
            }else{
                logD(error)
                //                    self.showAlert(title: "", message: error)
            }
        }
    }
    
    func CallAPIUnFriend(friendID: String) {     // Un-friend user
        startAnimating(CGSize(width: 100, height: 100), message: "", type: NVActivityIndicatorType.ballRotate, fadeInAnimation: nil)
        APIManager.callAPIRequest(Method: .post, url: "\(api_unFriendUser)", parameters: APIParam.unFriendUser(user_id: getFromUserDefaultForKey("member_id") as? String ?? "", unfriend_user_id: friendID, language: "\(Language.language)").getParam(), headers: nil, showAlert: false, completion: { (jsonResult, msg) in
            DispatchQueue.main.async {
                self.stopAnimating(nil)
            }
            logD(jsonResult)
            if jsonResult["flag"].stringValue == "1"{   // ~~~9S flag = 1 ==>
                if self.qrCode == ""{
                    self.arrData.dictionaryObject?.removeAll()
                    checkRecordAvailable(for: self.tblFriendList, count: self.arrData.count, ctrlRefresh: nil, targetController: self, detail: noDataAvaiableDetail.init(msg: "No data available".localized, img: nil, desc: ""), shouldShowCenter: true)
                }else{
                    self.CallAPISearchFriendByQRCode(QRCodeString: self.qrCode)
                }
                
                Messages.unFriendUserByMe(senderUserId: MEMBER_ID, receiverUserId: friendID)
                
            }else{      // ~~~9S flag = 0 ==>
                //self.showAlert(title: "", message: jsonResult["message"].stringValue)
                openSnakBar(viewController: self, message: jsonResult["message"].stringValue)
            }
            
        }) { (httpResponse, errorMsg) in
            DispatchQueue.main.async {
                self.stopAnimating(nil)
            }
            self.showAlert(title: "", message: errorMsg)
        }
    }
    
    //API Call for get User using QR Code Scanner
    func CallAPISearchFriendByQRCode(QRCodeString:String){
        //    startAnimating(CGSize(width: 100, height: 100), message: "", type: NVActivityIndicatorType.ballRotate, fadeInAnimation: nil)
        APIManager.callAPIRequest(Method: .post, url: "\(api_searchFriendByQRCode)", parameters: APIParam.searchFriendByQRCode(member_id: getFromUserDefaultForKey("member_id") as? String ?? "", language:  "\(Language.language)", qrcode: QRCodeString).getParam(), headers: nil, showAlert: false, completion: { (jsonResult, msg) in
            DispatchQueue.main.async {
                self.stopAnimating(nil)
            }
            self.arrData.dictionaryObject?.removeAll()
            logD(jsonResult)
            if jsonResult["flag"].stringValue == "1"{
                
                let friendStatus = jsonResult["data"][0]["friendStatus"].intValue
                let isBlock = jsonResult["data"][0]["isblock"].intValue
                
                if friendStatus == 0{
                    self.arrData = jsonResult["data"]
                }else{
                    self.showAlert(title: "", message: jsonResult["data"][0]["message"].stringValue)
                }
            }else{
                //self.showAlert(title: "", message: jsonResult["message"].stringValue)
                openSnakBar(viewController: self, message: jsonResult["message"].stringValue)
            }
            checkRecordAvailable(for: self.tblFriendList, count: self.arrData.count, ctrlRefresh: nil, targetController: self, detail: noDataAvaiableDetail.init(msg: "No data available".localized, img: nil, desc: ""), shouldShowCenter: true)
        }) { (httpResponse, errorMsg) in
            DispatchQueue.main.async {
                self.stopAnimating(nil)
            }
            self.showAlert(title: "", message: errorMsg)
        }
    }
    
    //Scane Qr Code And direct Send request
    func CallApiQrcodeSendrequest(QRCodeString: String, completion: @escaping (Bool) -> Void) {
        APIManager.callAPIRequest(Method: .post, url: "\(api_searchFriendByQRCode)", parameters: APIParam.searchFriendByQRCode(member_id: getFromUserDefaultForKey("member_id") as? String ?? "", language: "\(Language.language)", qrcode: QRCodeString).getParam(), headers: nil, showAlert: false, completion: { (jsonResult, msg) in
            DispatchQueue.main.async {
                self.stopAnimating(nil)
            }
            self.arrData.dictionaryObject?.removeAll()
            logD(jsonResult)
            if jsonResult["flag"].stringValue == "1" {
                let friendStatus = jsonResult["data"][0]["friendStatus"].intValue
                let isBlock = jsonResult["data"][0]["isblock"].intValue
                
                if friendStatus == 0 {
                    self.arrData = jsonResult["data"]
                    completion(true) // User is valid
                } else {
                    self.showAlert(title: "", message: jsonResult["data"][0]["message"].stringValue)
                    completion(false) // User is not valid
                }
            } else {
                openSnakBar(viewController: self, message: jsonResult["message"].stringValue)
                completion(false) // User is not valid
            }
        }) { (httpResponse, errorMsg) in
            DispatchQueue.main.async {
                self.stopAnimating(nil)
            }
            self.showAlert(title: "", message: errorMsg)
            completion(false) // User is not valid
        }
    }
}
