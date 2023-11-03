//
//  UserChatListViewController.swift
//  CCSMembersApp
//
//  Created by mac-18 on 28/12/22.
//  Copyright © 2022 Jaimin Patel. All rights reserved.
//

import UIKit
import SwiftyJSON
import Firebase
import FirebaseDatabase
import NVActivityIndicatorView

class UserChatListViewController: UIViewController,NVActivityIndicatorViewable {

    // MARK: - Outlets
    @IBOutlet weak var tblChatList: UITableView!
    @IBOutlet weak var lblNewChat: UILabel!
    
    var arrClubList = JSON("")

    var arrUsersList = [[String:Any]]()
    var username:String = ""
    var picUrl:String = ""
    var uerType = ""
    var forId = ""

    // MARK: - ViewController life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
        //self.removeFirebaseObserver()
        self.getUsersConversationList()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.getUsersConversationList()
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.removeFirebaseObserver()
    }
    // MARK: - Setup View
    func setupUI() {
        self.hideKeyboardWhenTappedAround()
        self.setupNIB()
        self.setupLanguage()
    }
    func setupLanguage() {
        self.lblNewChat.text = "New Chat".localized
    }
    fileprivate func setupNIB() {
        tblChatList.register(UINib(nibName: "\(ChatListCell.self)", bundle: nil), forCellReuseIdentifier: "\(ChatListCell.self)")
    }
    func getUsersConversationList(){
        DispatchQueue.main.async {
            self.startAnimating(CGSize(width: 100, height: 100), message: "", type: NVActivityIndicatorType.ballRotate, fadeInAnimation: nil)
            Messages.fetchMessageConversationList { usersList in
                print("Conversations Users list :- \(usersList)")
                self.stopAnimating(nil)
                self.arrUsersList = usersList
                checkRecordAvailable(for: self.tblChatList, count: self.arrUsersList.count, ctrlRefresh: nil, targetController: self, detail: noDataAvaiableDetail.init(msg: "No data available".localized, img: nil, desc: ""), shouldShowCenter: true)
                
            }
        }
        
    }
    
    func removeFirebaseObserver(){
        Messages.removeObserverMessageConversationList(isFromClubChat: false)
    }
    
}

// MARK: - Extension for Button Actions
extension UserChatListViewController {
    @IBAction func btnClicked(_ sender: UIButton) {
        self.view.endEditing(true)
        let vc = storyboardName.storyBoard_Chat.instantiateViewController(withIdentifier: "MyFriendsVC") as! MyFriendsVC
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
}
// MARK: - Extension UITableView delegate / datasource
extension UserChatListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrUsersList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "\(ChatListCell.self)", for: indexPath) as! ChatListCell
        let arrMessage = self.arrUsersList[indexPath.row]
        
        cell.lblName.text = arrMessage["fromId"] as? String ?? "" == MEMBER_ID ? "@\(arrMessage["recname"] as? String ?? "")" : "@\(arrMessage["sendername"] as? String ?? "")"
        
        cell.lblMessage.text = arrMessage["lastmessage"] as? String ?? ""
        cell.lblDateTime.text = dayDifferenceForMessage(from: Double(arrMessage["timestamp"] as? String ?? "0") ?? 0.0)
        if arrMessage["count"] as? Int ?? 0 > 0{
            cell.lblMsgUnreadCount.isHidden = false
            cell.lblMsgUnreadCount.text = arrMessage["count"] as? Int ?? 0 > 99 ? "+99" : "+\(arrMessage["count"] as? Int ?? 0)"
        }else{
            cell.lblMsgUnreadCount.isHidden = true
        }
        
        return cell

    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let vc = storyboardName.storyBoard_Main.instantiateViewController(withIdentifier: "ChatingVC") as! ChatingVC
//        vc.userid = self.arrUsersList[indexPath.row]["toId"] as? String ?? "" == MEMBER_ID ? self.arrUsersList[indexPath.row]["fromId"] as? String ?? "" : self.arrUsersList[indexPath.row]["toId"] as? String ?? ""
//        vc.receiverName = self.arrUsersList[indexPath.row]["toId"] as? String ?? "" == MEMBER_ID ? self.arrUsersList[indexPath.row]["recname"] as? String ?? "" : self.arrUsersList[indexPath.row]["sendername"] as? String ?? ""
//        let navigationController = UINavigationController(rootViewController: vc)
//        navigationController.modalPresentationStyle = .fullScreen
//        self.present(navigationController, animated: true)
        
        self.removeFirebaseObserver()
        let vc = storyboardName.storyBoard_Chat.instantiateViewController(withIdentifier: "ChatDetailsVC") as! ChatDetailsVC
        vc.userid = self.arrUsersList[indexPath.row]["toId"] as? String ?? "" == MEMBER_ID ? self.arrUsersList[indexPath.row]["fromId"] as? String ?? "" : self.arrUsersList[indexPath.row]["toId"] as? String ?? ""
        vc.receiverName = self.arrUsersList[indexPath.row]["toId"] as? String ?? "" == MEMBER_ID ? self.arrUsersList[indexPath.row]["sendername"] as? String ?? "" : self.arrUsersList[indexPath.row]["recname"] as? String ?? ""
        
        vc.chatDetailsDelegate = self
        vc.blockByUserID = self.arrUsersList[indexPath.row]["blockByUser"] as? String ?? ""
        //self.navigationController?.pushViewController(vc, animated: true)
        
//        let navigationController = UINavigationController(rootViewController: vc)
//        navigationController.modalPresentationStyle = .fullScreen
//        self.present(navigationController, animated: true)
        
        self.navigationController?.pushViewController(vc, animated: true)

    }
}


// MARK: - Chat Details Delegate
extension UserChatListViewController:RemoveChatDetailsFirebaseObserver {
    func removeChatDetailsObserver(userId: String, isFromClubChat: Bool) {
        
        if isFromClubChat == false{
            print("removeChatDetailsObserver fire from UserChatListViewController")
            Messages.decreaseUnreadCountToZero(userID: userId)
        }
    }
}


