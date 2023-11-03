//
//  ChatDetailsVC.swift
//  CCSMembersApp
//
//  Created by Divvyesh on 26/06/23.
//  Copyright © 2023 Jaimin Patel. All rights reserved.
//

import UIKit
import DKImagePickerController
import Firebase
import FirebaseDatabase
import SwiftyJSON
import SDWebImage
import SlideMenuControllerSwift
import NVActivityIndicatorView

protocol RemoveChatDetailsFirebaseObserver{
    func removeChatDetailsObserver(userId:String,isFromClubChat:Bool)
}

class ChatDetailsVC: UIViewController,NVActivityIndicatorViewable {
    
    //MARK: Variable Declaration
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var lblOnlineStatus: UILabel!
    @IBOutlet weak var imgUserProfile: UIImageView!
    @IBOutlet weak var sendTxtViewHeight: NSLayoutConstraint!
    @IBOutlet weak var txtWriteMSG: UITextView!
    @IBOutlet weak var imgBackground: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var sendBtnOutlet: UIButton!
    @IBOutlet weak var viewSend: UIView!
    //@IBOutlet weak var bottomChatViewHeight: NSLayoutConstraint!
    @IBOutlet weak var cnstViewMessageBottom: NSLayoutConstraint!
    @IBOutlet weak var viewMessage: UIView!
    @IBOutlet weak var viewBlock: UIView!
    @IBOutlet weak var lblBlockUserMessage: UILabel!
    @IBOutlet weak var btnBlockUser: UIButton!
    @IBOutlet weak var lblBlockUser: UILabel!
    @IBOutlet weak var lblMessagePlaceholder: UILabel!
    
    //Popup View
    @IBOutlet weak var viewMore: UIView!
    @IBOutlet weak var lblBlock: UILabel!
    @IBOutlet weak var lblBlockAndReport: UILabel!
    @IBOutlet weak var stckViewBlockPopup: UIStackView!
    
    var chatDetailsDelegate : RemoveChatDetailsFirebaseObserver?
    
    var selectedImage : UIImage?
    var lastChatBubbleY: CGFloat = 10.0
    var internalPadding: CGFloat = 30.0
    var lastMessageType: BubbleDataType?
    var chatDict = [[String:Any]]()
    var no:Int?
    var comparePreviousDate:String=""
    var notifiction="false"
    var item1:UIBarButtonItem?
    
    
    var blockByUserID = ""
    var userid = ""
    var receiverName = ""
    var conversationObject = [String:Any]()
    var timestamparray:[Int] = []
    //Database
    var ref = Database.database().reference()
    var arrMessages=[Messages]()
    var  timeStamp = 0
    var lastMessage = ""
    
    var receiverUsersLastMessageData = [String:Any]()
    var usersConversationKey = ""
    
    var lastConversationKey = ""
    var isNextPageAvailable = false
    var availableToCheckForNextLoadData = false
    var isInitialLoad = true
    var currentCellOffset: CGPoint?
    let spinner = UIActivityIndicatorView(style: .medium)

    var isFromClubChat = false
    
    
    //MARK: ViewController LifeCycle
    override func viewDidLoad() {
        self.setupUI()
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.removeObserver()
        self.addObserver()
        self.setUserIsOnline(isOnline: true)
        appDelegateShared.isChatDetailScreenOpen = true
        appDelegateShared.chatDetailController = self
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.removeObserver()
        UserDefaults.standard.set("false", forKey: "ChattingScreenOn")
        Shared().firebaseProcess(visibility:"OFFLINE")
        self.setUserIsOnline(isOnline: false)
        var handle:UInt = 0
        handle = ref.observe(.value) { (snapshot) in
            self.ref.removeObserver(withHandle: handle)
        }
        appDelegateShared.isChatDetailScreenOpen = false
        appDelegateShared.chatDetailController = nil
    }
    deinit{
        self.removeObserver()
    }
    
    //Setup UI
    func setupUI(){
        arrLoadedMessageKey.removeAll()
        lastLoadedMessageKey = ""
        self.fetchUserConversationKey()
        self.removeNavigationBarItem()
        self.navigationController?.isNavigationBarHidden = true
        self.setupLanguageData()
        self.txtWriteMSG.centerVertically()
        
        
        //self.hideKeyboardWhenTappedAround()
        self.tableView.register(UINib(nibName: "ChatConversionsCell", bundle: nil), forCellReuseIdentifier: "ChatConversionsCell")
        checkRecordAvailable(for: self.tableView, count: self.arrMessages.count, ctrlRefresh: nil, targetController: self, detail: noDataAvaiableDetail.init(msg: "msg_no_chat_available".localized, img: nil, desc: ""), shouldShowCenter: true)
        //self.fetchMessages()
        
        self.lblUserName.text = "@\(self.receiverName)"
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboardWhenClickOutside))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        
        let tableTap = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboardWhenClickOnTableview))
        self.tableView.addGestureRecognizer(tableTap)
        
        //self.txtWriteMSG.addObserver(self, forKeyPath: "contentSize", options: NSKeyValueObservingOptions.new, context: nil)
        
        //Set Spinner for lazy loading
        self.spinner.color = .white
        self.tableView.tableHeaderView = spinner
        
        
        if isFromClubChat == false{ //Normal user chat
            self.viewMore.isHidden = false
            self.checkUserIsBlocked(blockByUserId: self.blockByUserID)
            Messages.decreaseUnreadCount(userID: self.userid)
        }else{  //Club chat
            Messages.decreaseUnreadCount(isFromClubChat: true, userID: self.userid)
            self.viewMore.isHidden = true
        }
        self.getReceiverUserDetail()
        self.viewSend.alpha = 0.6
        self.sendBtnOutlet.isEnabled = false
    }
    
    //set language
    func setupLanguageData(){
        self.lblMessagePlaceholder.text = "Write Here".localized
        self.lblBlock.text = "Block".localized
        self.lblBlockAndReport.text = "BlockAndReport".localized
        //self.btnBlockUser.setTitle("Unblock User".localized, for: .normal)
        self.lblBlockUser.text = "Unblock User".localized
        //self.btnBlockUser.titleLabel?.font = setCustomFont.KarlaBoldWith(size: 17.0)
    }
    
    //Check user is block or not
    func checkUserIsBlocked(blockByUserId:String){
        if blockByUserId == ""{
            self.viewBlock.isHidden = true
            self.viewMessage.isHidden = false
            if self.isFromClubChat == false{
                self.viewMore.isHidden = false
            }
            
            self.lblBlockUserMessage.text = ""
        }else{
            if blockByUserId == MEMBER_ID{
                self.lblBlockUserMessage.text = "@\(self.receiverName) \("msg_block_user_by_you".localized)"
                self.btnBlockUser.isHidden = false
                self.lblBlockUser.isHidden = false
            }else{
                self.lblBlockUserMessage.text = "@\(self.receiverName) \("msg_block_you_by_user".localized)"
                self.btnBlockUser.isHidden = true
                self.lblBlockUser.isHidden = true
            }
            if self.isFromClubChat == false{
                self.viewMore.isHidden = true
            }
            self.viewBlock.isHidden = false
            self.viewMessage.isHidden = true
        }
    }
    
    func setUserIsOnline(isOnline:Bool = true){
        Messages.setUserConversationWithYou(isFromClubChat:isFromClubChat,userID: self.userid, isOnline: isOnline)
    }
    
    /*
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutableRawPointer) {

        var topCorrect : CGFloat = (textField.frame.height - textField.contentSize.height);
        topCorrect = topCorrect < 0.0 ? 0.0 : topCorrect / 2
        self.txtWriteMSG.contentOffset = CGPoint(x: 0, y: -topCorrect)

    }*/
    
    //Add observer
    func addObserver(){
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appMovedToForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(appMovedToForeground), name: UIApplication.didBecomeActiveNotification, object: nil)
        
        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        
        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)
    }
    
    //Remove Observer
    func removeObserver(){
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func appMovedToForeground() {
        print("App moved to ForeGround!")
        let checkChattingScreenStatus=UserDefaults.standard.string(forKey: "ChattingScreenOn")
        self.setUserIsOnline(isOnline: true)
        if checkChattingScreenStatus == "true"{
            Shared().firebaseProcess(visibility:"ONLINE")
        } else{
            
        }
    }
    
    @objc func appMovedToBackground() {
        print("App moved to Background!")
        let checkChattingScreenStatus=UserDefaults.standard.string(forKey: "ChattingScreenOn")
        self.setUserIsOnline(isOnline: false)
        if checkChattingScreenStatus == "true"{
            Shared().firebaseProcess(visibility:"OFFLINE")
        } else{
            
        }
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        var info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        UIView.animate(withDuration: 1.0, animations: { () -> Void in
            if hasNotch(){
                self.cnstViewMessageBottom.constant = -(keyboardFrame.size.height - 10)
            }else{
                self.cnstViewMessageBottom.constant = -(keyboardFrame.size.height + 10)
            }
            
            
            //self.bottomChatViewHeight.constant = -keyboardFrame.size.height-8.0
        }) { (completed: Bool) -> Void in
            //self.moveToLastMessage()
            if self.arrMessages.count > 0{
                self.tableView.scrollToRow(at: IndexPath.init(row: self.arrMessages.count - 1, section: 0), at: .bottom, animated: false)
            }
            
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        UIView.animate(withDuration: 1.0, animations: { () -> Void in
            self.cnstViewMessageBottom.constant = -10.0
        }) { (completed: Bool) -> Void in
           // self.moveToLastMessage()
            
        }
    }
    
    @objc override func dismissKeyboardWhenClickOutside() {
        if self.stckViewBlockPopup.isHidden == false{
            self.showHideBlockAndReportPopup()
        }
        
        //self.view.endEditing(true)
        
    }
    
    @objc func dismissKeyboardWhenClickOnTableview() {
        if self.stckViewBlockPopup.isHidden == false{
            self.showHideBlockAndReportPopup()
        }
        self.view.endEditing(true)
    }
    
    // Show and Hide Block and Report Popup
    func showHideBlockAndReportPopup(){
        UIView.transition(with: self.stckViewBlockPopup, duration: 0.4,
                          options: .transitionCrossDissolve,
                          animations: {
            self.stckViewBlockPopup.isHidden = !self.stckViewBlockPopup.isHidden
        })
    }
}

//MARK: Extension for Firebase Message methods
extension ChatDetailsVC{
    private func fetchUserConversationKey(isFirstTimeChat:Bool = false){
        startAnimating(CGSize(width: 100, height: 100), message: "", type: NVActivityIndicatorType.ballRotate, fadeInAnimation: nil)
        Messages.getUserConversationsKey(isFromClubChat:isFromClubChat,forId: self.userid) { conversationsKey in
            //self.setMessageObserver(conversationsKey: conversationsKey)
            if conversationsKey != ""{
                self.usersConversationKey = conversationsKey
                if isFirstTimeChat{
                    self.fetchObserverMessagesData()
                }else{
                    self.fetchMessages()
                }
            }else{
                self.stopAnimating(nil)
            }
            
        }
    }
    
    
    private func fetchMessages(){
        Messages.fetchFirstTimeMessageAndAddObserver(conversationKey: self.usersConversationKey,lastKey: self.lastConversationKey, completion: { [weak weakSelf = self] (messages, lastKey, isNextPageAvailable,arrTime,isFromMessageObserver) in
            weakSelf?.stopAnimating(nil)
            //weakSelf?.timestamparray = self.timestamparray + arrTime
            if weakSelf?.arrMessages.count ?? 0 > 0{
                weakSelf?.arrMessages = (weakSelf?.arrMessages ?? []) + messages
//                for i in messages{
//                    if weakSelf?.timestamparray.contains(i.timestamp) == false{
//                        weakSelf?.arrMessages = messages + (weakSelf?.arrMessages ?? [])
//                    }
//                }
            }else{
                weakSelf?.arrMessages = messages
            }
            weakSelf?.timestamparray = self.timestamparray + arrTime
            if isFromMessageObserver == false{
                weakSelf?.lastConversationKey = lastKey
                weakSelf?.isNextPageAvailable = isNextPageAvailable
            }
            checkRecordAvailable(for: weakSelf?.tableView ?? self.tableView, count: self.arrMessages.count, ctrlRefresh: nil, targetController: self, detail: noDataAvaiableDetail.init(msg: "msg_no_chat_available".localized, img: nil, desc: ""), shouldShowCenter: true)
            if self.arrMessages.count > 0{
                weakSelf?.tableView.scrollToRow(at: IndexPath.init(row: self.arrMessages.count - 1, section: 0), at: .bottom, animated: false)
            }
            
            
            if isFromMessageObserver == false{
                self.availableToCheckForNextLoadData = true
            }
//            if isCallFirstTime{
//                self.setMessageObserver(conversationsKey: conversationsKey)
//            }
            self.isInitialLoad = false
        })
    }
    
    private func fetchObserverMessagesData(){
        Messages.setMessageObserver(conversationKey: self.usersConversationKey,lastKey: self.lastConversationKey, completion: { [weak weakSelf = self] (messages, lastKey, isNextPageAvailable,arrTime,isFromMessageObserver) in
            weakSelf?.stopAnimating(nil)
            //weakSelf?.timestamparray = self.timestamparray + arrTime
            if weakSelf?.arrMessages.count ?? 0 > 0{
                weakSelf?.arrMessages = (weakSelf?.arrMessages ?? []) + messages
            }else{
                weakSelf?.arrMessages = messages
            }
            weakSelf?.timestamparray = self.timestamparray + arrTime
            if isFromMessageObserver == false{
                weakSelf?.lastConversationKey = lastKey
                weakSelf?.isNextPageAvailable = isNextPageAvailable
            }
            checkRecordAvailable(for: weakSelf?.tableView ?? self.tableView, count: self.arrMessages.count, ctrlRefresh: nil, targetController: self, detail: noDataAvaiableDetail.init(msg: "msg_no_chat_available".localized, img: nil, desc: ""), shouldShowCenter: true)
            if self.arrMessages.count > 0{
                weakSelf?.tableView.scrollToRow(at: IndexPath.init(row: self.arrMessages.count - 1, section: 0), at: .bottom, animated: false)
            }
            
            
            if isFromMessageObserver == false{
                self.availableToCheckForNextLoadData = true
            }
            self.isInitialLoad = false
        })
    }
    
    private func fetchMessagesPaginationWise(){
        self.tableView.isScrollEnabled = false
        Messages.fetchMessagePaginationWise(conversationKey: self.usersConversationKey,lastKey: self.lastConversationKey, completion: { [weak weakSelf = self] (messages, lastKey, isNextPageAvailable,arrTime) in
            
            weakSelf?.timestamparray = self.timestamparray + arrTime
            if weakSelf?.arrMessages.count ?? 0 > 0{
                weakSelf?.arrMessages = messages + (weakSelf?.arrMessages ?? [])
//                for i in messages{
//                    if weakSelf?.timestamparray.contains(i.timestamp) == false{
//                        weakSelf?.arrMessages = messages + (weakSelf?.arrMessages ?? [])
//                    }
//                }
            }else{
                weakSelf?.arrMessages = messages
            }
            weakSelf?.lastConversationKey = lastKey
            weakSelf?.isNextPageAvailable = isNextPageAvailable
            checkRecordAvailable(for: weakSelf?.tableView ?? self.tableView, count: self.arrMessages.count, ctrlRefresh: nil, targetController: self, detail: noDataAvaiableDetail.init(msg: "msg_no_chat_available".localized, img: nil, desc: ""), shouldShowCenter: true)
            weakSelf?.tableView.scrollToRow(at: IndexPath.init(row: messages.count, section: 0), at: .top, animated: false)
            //weakSelf?.tableView.moveRow(at: IndexPath(row: 0, section: 0), to: IndexPath(row: messages.count, section: 0))
            /*
            if let currentCellOffset = self.currentCellOffset {
                self.tableView.layoutIfNeeded()
                if let indexPaths = self.tableView.indexPathsForVisibleRows, let currentCellIndexPath = indexPaths.first(where: { self.tableView.rectForRow(at: $0).origin.y == currentCellOffset.y }) {
                    self.tableView.contentOffset = CGPoint(x: self.tableView.contentOffset.x, y: currentCellOffset.y)
                }
            }*/
            /*
            for (indx,_) in messages.enumerated(){
                self.tableView.beginUpdates()
                self.tableView.insertRows(at: [IndexPath(row: indx, section: 0)], with: .automatic)
                self.tableView.endUpdates()
            }*/
            
            self.spinner.stopAnimating()
            
            self.tableView.isScrollEnabled = true
            
            self.isInitialLoad = false
        })
    }
    
    /*
    private func setMessageObserver(conversationsKey:String){
        Messages.setObserveForMessages(conversationKey: conversationsKey) {
            [weak weakSelf = self] (messages) in
            
             if self.timestamparray.contains(messages.timestamp){
            }else{
                weakSelf?.arrMessages.append(messages)
                self.timestamparray.append(messages.timestamp)
                if messages.fromId == MEMBER_ID &&  messages.toId  == self.userid {
                                /*if messages.un_read.contains("1"){
                                }else{
                                    self.count = self.count+1
                                    let sCount = String(self.count)
                                Database.database().reference().child("Users").child(self.otherid).child("conversations").child(MEMBER_ID).updateChildValues(["count":sCount])
                            }*/
                }
            }
             DispatchQueue.main.async {
                if let state = weakSelf?.arrMessages.isEmpty, state == false {
                    weakSelf?.tableView.scrollToRow(at: IndexPath.init(row: self.arrMessages.count - 1, section: 0), at: .bottom, animated: false)
                }
            }
        }
    }*/
    
    /*
    func fetchMessages(){
        startAnimating(CGSize(width: 100, height: 100), message: "", type: NVActivityIndicatorType.ballRotate, fadeInAnimation: nil)
        Messages.downloadAllMessages(forId:userid,completion:{
            [weak weakSelf = self] (messages) in
            
             if self.timestamparray.contains(messages.timestamp){
            }else{
                weakSelf?.arrMessages.append(messages)
                self.timestamparray.append(messages.timestamp)
                if messages.fromId == MEMBER_ID &&  messages.toId  == self.userid {
                                /*if messages.un_read.contains("1"){
                                }else{
                                    self.count = self.count+1
                                    let sCount = String(self.count)
                                Database.database().reference().child("Users").child(self.otherid).child("conversations").child(MEMBER_ID).updateChildValues(["count":sCount])
                            }*/
                }
            }
             DispatchQueue.main.async {
                if let state = weakSelf?.arrMessages.isEmpty, state == false {
                    //weakSelf?.tableView.reloadData()
                    weakSelf?.stopAnimating(nil)
                    checkRecordAvailable(for: weakSelf?.tableView ?? self.tableView, count: self.arrMessages.count, ctrlRefresh: nil, targetController: self, detail: noDataAvaiableDetail.init(msg: "msg_no_chat_available".localized, img: nil, desc: ""), shouldShowCenter: true)
                    weakSelf?.tableView.scrollToRow(at: IndexPath.init(row: self.arrMessages.count - 1, section: 0), at: .bottom, animated: false)
                }
            }
        })
    }*/
}

//MARK: Extension for button clcik
extension ChatDetailsVC{
    @IBAction func btnClick(_ sender: UIButton) {
        switch sender.tag{
        case 0: //Go back
            self.view.endEditing(true)
            print("Go back")
            
            self.chatDetailsDelegate?.removeChatDetailsObserver(userId: self.userid,isFromClubChat: self.isFromClubChat)
            if self.usersConversationKey != ""{
                Messages.removeMessageObserver(conversationKey: self.usersConversationKey)
            }
            //Messages.decreaseUnreadCountToZero(userID: self.userid)
            
//            self.removeObserver()
//            self.navigationController?.dismiss(animated: true)
            self.navigationController?.popViewController(animated: true)
        case 1: //More clicked
            self.view.endEditing(true)
            print("More clicked")
            if self.stckViewBlockPopup.isHidden{
                self.showHideBlockAndReportPopup()
            }
            
        case 2: //Open Attachment
            
            print("Open Attachment")
            //showImagePicker()
        case 3: //Send Message
            print("Send Message")
            let txtMsg :String = (self.txtWriteMSG.text!.trimmingCharacters(in: .whitespacesAndNewlines))
            if txtMsg == ""{
                
            } else{
                //firebaseChatProcess
                let msg = txtWriteMSG.text.trimmingCharacters(in: .whitespaces)
                
                if msg == ""{
                    txtWriteMSG.text = ""
                }else{
                    self.lastMessage = msg
                    self.composeMessage(type:"text", content: msg)
                    self.txtWriteMSG.text = ""
                    self.viewSend.alpha = 0.6
                    self.sendBtnOutlet.isEnabled = false
                    self.lblMessagePlaceholder.isHidden = false
                }
            }
        case 4:
            print("Click on Block")
           // if self.receiverUsersLastMessageData["blockByUser"] as? String ?? "" == ""{
                self.showAlert(title: "", message: "msg_block_user".localized, buttonTitles: ["Cancel".localized, "Ok".localized], highlightedButtonIndex: 0, buttonStyles: [.default, .default]) { (btnIndex) in
                    if btnIndex == 1 {
                        self.callAPIBlockAndUnblockUser(blockStatus: BlockUnBlockTypes.Block.get(), reportReason:"", blockId: self.userid)
                        self.blockUser()
                    }
                }
            //}
        case 5:
            print("Click on Block and Report")
            self.showBlockAndReportPopUp()
        case 6:
            //if self.receiverUsersLastMessageData["blockByUser"] as? String ?? "" == MEMBER_ID{
                print("Click on Block message section")
                self.showAlert(title: "", message: "msg_unblock_user".localized, buttonTitles: ["Cancel".localized, "Ok".localized], highlightedButtonIndex: 0, buttonStyles: [.default, .default]) { (btnIndex) in
                    if btnIndex == 1 {
                        self.callAPIBlockAndUnblockUser(blockStatus: BlockUnBlockTypes.UnBlock.get(), reportReason:"", blockId: self.userid)
                        self.unblockUser()
                    }
                }
            //}
        default:
            break;
        }
        
        /*
        func showPopUp() {
            let popUpVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "BlockAndReportVC") as! BlockAndReportVC
            popUpVC.modalPresentationStyle = .overCurrentContext
            self.present(popUpVC, animated: true, completion: nil)
        }
*/
    }
    //MARK: - Composing Message
    func composeMessage(type:String,content:Any){
//        self.count = 0
        self.timeStamp = Int(Date().timeIntervalSince1970)
        let message=Messages.init(type: type, content: content, owner: .sender,timestamp: timeStamp, sendername: appDelegateShared.nameU, senderProfile: "", recname: self.receiverName, recProfile: "", un_read:"0", fromId: MEMBER_ID, toId: self.userid,isBlockedYou: false,isBlockedByYou: false, blockByUser: "")
        Messages.sendMessage(isFromClubChat:isFromClubChat,type: type, message: message, toID: self.userid, fromId: MEMBER_ID, sendername: appDelegateShared.nameU, senderProfile: "", recname: receiverName, recProfile: "", imageUrl:"") { (_) in
                self.lastMsg()
            if self.arrMessages.count == 0{
                self.fetchUserConversationKey(isFirstTimeChat: true)
            }
        }
    }
    
    func lastMsg(){
       let Stamp = String(self.timeStamp)
       if Stamp == "0" || self.lastMessage.isEmpty{
       }else{
           Messages.updateLastMessageForUsers(isFromClubChat:isFromClubChat,lastMessage: self.lastMessage, timestamp: self.timeStamp, receiverID: self.userid)
       }
    }
    
    func showBlockAndReportPopUp() {
        let popUpVC = storyboardName.storyBoard_Chat.instantiateViewController(withIdentifier: "BlockReportVC") as! BlockReportVC
        popUpVC.userId = self.userid
        popUpVC.delegate = self
        popUpVC.modalPresentationStyle = .overCurrentContext
        self.present(popUpVC, animated: true, completion: nil)
    }
}

//MARK: Extension for Block and Report Protocol
extension ChatDetailsVC:BlockAndReportProtocol{
    func BlockAndReportVCResultData(isSucessFullyBlock: Bool,reason:String) {
        if isSucessFullyBlock{
            self.blockUser()
            self.callAPIBlockAndUnblockUser(blockStatus: BlockUnBlockTypes.BlockAndReport.get(), reportReason: reason, blockId: self.userid)
        }
    }
}
//MARK: Extension for Tableview delegate and datasource
extension ChatDetailsVC:UITableViewDelegate,UITableViewDataSource{
  
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrMessages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatConversionsCell") as! ChatConversionsCell
        
        // Configure the cell with the message
        //let reversedIndex = arrMessages.count - 1 - indexPath.row
        let chatData = arrMessages[indexPath.row]
        //sendDate
        
        
        if indexPath.row > 0{
            let currentDateFromTimeStamp = getDefaultDate( UTCToLocal(date: getDateFromTimeStamp(Double(chatData.timestamp), format: dateTimeFromateDisplaySlash), formate: dateTimeFromateDisplaySlash, displayFormate: dateTimeFromateDisplaySlash), format: dateTimeFromateDisplaySlash)
            let previousDateFromTimeStamp =  getDefaultDate( UTCToLocal(date: getDateFromTimeStamp(Double(self.arrMessages[indexPath.row - 1].timestamp), format: dateTimeFromateDisplaySlash), formate: dateTimeFromateDisplaySlash, displayFormate: dateTimeFromateDisplaySlash), format: dateTimeFromateDisplaySlash)
            cell.isAvailableNewDate = !(Calendar.current.isDate(currentDateFromTimeStamp, equalTo: previousDateFromTimeStamp, toGranularity: .day))
            //print("Same day :- \(cell.isAvailableNewDate)")
        }else{
            cell.isAvailableNewDate = true
        }
        
        cell.lblDate.text =  UTCToLocal(date: getDateFromTimeStamp(Double(chatData.timestamp), format: dateTimeFromateDisplaySlash), formate: dateTimeFromateDisplaySlash, displayFormate: dateTimeFromateDispalyOnlyDate)
        if chatData.fromId ?? "" == MEMBER_ID{ //User as a sender
            cell.viewSender.isHidden = false
            cell.viewReceiver.isHidden = true
            cell.lblSenderMessage.text = chatData.content as? String ?? ""
            cell.lblReceiverMessage.text = ""
            cell.lblReceiverMessageTime.text =  ""
            cell.lblSenderMessageTime.text = UTCToLocal(date: getDateFromTimeStamp(Double(chatData.timestamp), format: dateTimeFromateDisplaySlash), formate: dateTimeFromateDisplaySlash, displayFormate: dateTimeFromatOnlyDisplayTime)
        }else{ //User as a receiver
            cell.viewSender.isHidden = true
            cell.viewReceiver.isHidden = false
            cell.lblSenderMessage.text = ""
            cell.lblReceiverMessage.text = chatData.content as? String ?? ""
            cell.lblSenderMessageTime.text =  ""
            cell.lblReceiverMessageTime.text = UTCToLocal(date: getDateFromTimeStamp(Double(chatData.timestamp), format: dateTimeFromateDisplaySlash), formate: dateTimeFromateDisplaySlash, displayFormate: dateTimeFromatOnlyDisplayTime)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == 0 && self.isInitialLoad == false{
            print("call will Display method")
            if isNextPageAvailable{
                spinner.startAnimating()
                self.isInitialLoad = true
                if let visibleIndexPaths = tableView.indexPathsForVisibleRows, visibleIndexPaths.contains(indexPath) {
                    currentCellOffset = tableView.contentOffset
                }
                self.fetchMessagesPaginationWise()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

//MARK: Extension for Textview delegate
extension ChatDetailsVC: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        self.lblMessagePlaceholder.isHidden = !textView.text.isEmpty
        self.viewSend.alpha = textView.text.isEmpty ? 0.6 : 1.0
        self.sendBtnOutlet.isEnabled = !textView.text.isEmpty
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        self.lblMessagePlaceholder.isHidden = !textView.text.isEmpty

    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        self.lblMessagePlaceholder.isHidden = true
    }
}
//MARK: Extension for API call
extension ChatDetailsVC {
    //Block User
    func blockUser(){
        Messages.blockUserByMe(senderUserId: MEMBER_ID, receiverUserId: self.userid)
    }
    //Unblock user
    func unblockUser(){
        Messages.unBlockUserByMe(senderUserId: MEMBER_ID, receiverUserId: self.userid)
    }
    //get UserDetails
    func getReceiverUserDetail(){
        if self.isFromClubChat{
            self.btnBlockUser.isHidden = true
            self.lblBlockUser.isHidden = true
            Messages.checkUserDeletedByClub(fromId: MEMBER_ID,toId: self.userid, completion: { isDeleted in
                if isDeleted{
                    self.lblBlockUserMessage.text = "@\(self.receiverName) \("msg_deleted_you_by_club".localized)"
                    self.viewBlock.isHidden = false
                    self.viewMessage.isHidden = true
                }else{
                    Messages.checkUserBannedByClub(fromId: MEMBER_ID,toId: self.userid, completion: { isBanned in
                        if isBanned{
                            self.lblBlockUserMessage.text = "@\(self.receiverName) \("msg_banned_you_by_club".localized)"
                            self.viewBlock.isHidden = false
                            self.viewMessage.isHidden = true
                        }else{
                            self.lblBlockUserMessage.text = ""
                            self.viewBlock.isHidden = true
                            self.viewMessage.isHidden = false
                        }
                    })
                }
            })
        }else{
            Messages.checkUserIsUnfriend(fromId:MEMBER_ID, toId:self.userid ) { isUnfriend in
                if isUnfriend{
                    self.lblBlockUserMessage.text = "\("msg_both_are_unfriend".localized)"//"@\(self.receiverName) \("msg_unfriend_both_of_you".localized)"
                    self.btnBlockUser.isHidden = true
                    self.lblBlockUser.isHidden = true
                    self.viewBlock.isHidden = false
                    self.viewMessage.isHidden = true
                    self.viewMore.isHidden = true
                }else{
                    Messages.checkUserIsBlock(toId: MEMBER_ID, fromId: self.userid, completion: { userData in
                        print("Check user is blocked or not called")
                        print(userData)
                        self.checkUserIsBlocked(blockByUserId: userData)
                    })
                }
            }
        }
        /*
        Messages.getUserLastConversationDetails(toId: MEMBER_ID, fromId: self.userid) { userData in
            self.receiverUsersLastMessageData = userData
            
            self.checkUserIsBlocked(blockByUserId: self.receiverUsersLastMessageData["blockByUser"] as? String ?? "")
            /*if self.receiverUsersLastMessageData["blockByUser"] as? String ?? "" == ""{
                self.viewBlock.isHidden = true
                self.viewMessage.isHidden = false
                self.viewMore.isHidden = false
                self.lblBlockUserMessage.text = ""
            }else{
                if self.receiverUsersLastMessageData["blockByUser"] as? String ?? "" == MEMBER_ID{
                    self.lblBlockUserMessage.text = "msg_block_user_by_you".localized
                }else{
                    self.lblBlockUserMessage.text = "\("msg_block_you_by_user".localized) \(appDelegateShared.nameU)"
                }
                self.viewMore.isHidden = true
                self.viewBlock.isHidden = false
                self.viewMessage.isHidden = true
            }*/
        }
         */
    }
}

//MARK: Extension for api call
extension ChatDetailsVC{
    func callAPIBlockAndUnblockUser(blockStatus:String,reportReason:String,blockId:String){
        startAnimating(CGSize(width: 100, height: 100), message: "", type: NVActivityIndicatorType.ballRotate, fadeInAnimation: nil)
        APIManager.callAPIRequest(Method: .post, url: "\(api_blockUser)", parameters: APIParam.blockUser(user_id: MEMBER_ID, block_id: blockId, language: "\(Language.language)", block_status: blockStatus, report_reason: reportReason).getParam(), headers: nil, showAlert: false) { (jsonResult, msg) in
            logD(jsonResult)
            DispatchQueue.main.async {
                self.stopAnimating(nil)
            }
            //self.getReceiverUserDetail()
        } failure: { httpresponse, errorMessage in
            DispatchQueue.main.async {
                self.stopAnimating(nil)
            }
        }
    }
}

//MARK: Extension for Notification
extension ChatDetailsVC{
    func updateUserData(jsonData:JSON){
        if appDelegateShared.isFromNotification{
            appDelegateShared.isFromNotification = false
            self.removeObserver()
            self.lastConversationKey = ""
            self.arrMessages.removeAll()
            self.blockByUserID = ""
            self.isNextPageAvailable = false
            self.availableToCheckForNextLoadData = false
            self.isInitialLoad = true
            self.lastMessage = ""
            self.timeStamp = 0
            self.timestamparray.removeAll()
            
            UserDefaults.standard.set("false", forKey: "ChattingScreenOn")
            Shared().firebaseProcess(visibility:"OFFLINE")
            self.setUserIsOnline(isOnline: false)
            var handle:UInt = 0
            handle = ref.observe(.value) { (snapshot) in
                self.ref.removeObserver(withHandle: handle)
            }
            self.chatDetailsDelegate?.removeChatDetailsObserver(userId: self.userid,isFromClubChat: self.isFromClubChat)
            if self.usersConversationKey != ""{
                Messages.removeMessageObserver(conversationKey: self.usersConversationKey)
            }
            
            self.addObserver()
            self.userid = jsonData["userId"].stringValue
            self.usersConversationKey = jsonData["conversationId"].stringValue
            
            if appDelegateShared.chatRedirectionType == 1{ //User chat redirection
                self.isFromClubChat = false
                self.receiverName = jsonData["userName"].stringValue
            }else if appDelegateShared.chatRedirectionType == 2{ //Club chat redirection
                self.isFromClubChat = true
                self.receiverName = jsonData["clubName"].stringValue
            }
            appDelegateShared.chatRedirectionType = 0
            self.setUserIsOnline(isOnline: true)
            self.setupUI()
        }
    }
}
