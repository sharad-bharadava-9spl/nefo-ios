//
//  MyFriendsVC.swift
//  CCSMembersApp
//
//  Created by mac-18 on 18/01/23.
//  Copyright © 2023 Jaimin Patel. All rights reserved.
//

import UIKit
import SwiftyJSON
import NVActivityIndicatorView

class MyFriendsVC: UIViewController, NVActivityIndicatorViewable {
    
    @IBOutlet weak var tblFriendList: UITableView!
    @IBOutlet weak var lblNewChat: UILabel!
    @IBOutlet weak var txtSearch: UITextField!
    @IBOutlet weak var lblYourFriend: UILabel!
    @IBOutlet weak var lblGoBackTitle: UILabel!
    
    var arrData = JSON("")
    var arrMainData = JSON("")
    
    var item1:UIBarButtonItem?
    var item2:UIBarButtonItem?
    let refreshControl = UIRefreshControl()
    // MARK: - ViewController life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        
        self.setNavigationBarItem()
        
        self.navigationController?.navigationBar.isHidden = false
        self.setLeftAlignTitleView(font: UIFont(name: "ProductSans-Bold", size: 17)!, text: "New Chat".localized, textColor: .white)
        navigationItem.leftBarButtonItem?.tintColor = UIColor(named: "NavigationText")!
        
        /*
         var imageShopingCart = Shared().imageWithImage(image: UIImage(named: "Shoping_Cart")!, scaledToSize: CGSize(width: 23, height: 23))
         imageShopingCart = imageShopingCart.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
         
         var imageNotification = Shared().imageWithImage(image: UIImage(named: "Notification_icon")!, scaledToSize: CGSize(width: 23, height: 23))
         imageNotification = imageNotification.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
         
         
         if targetName != Shared().cannibisAppName {
         let btn1 = UIButton(type: .custom)
         btn1.setImage(imageShopingCart, for: .normal)
         btn1.frame = CGRect(x: 0, y: 0, width: 28, height: 28)
         btn1.addTarget(self, action:#selector(self.cartRedirection), for: .touchUpInside)
         item1 = UIBarButtonItem(customView: btn1)
         item1?.removeBadge()
         }
         
         
         let btn2 = UIButton(type: .custom)
         btn2.setImage(imageNotification, for: .normal)
         btn2.addTarget(self, action: #selector(self.notificationScreenRedirection), for: .touchUpInside)
         btn2.frame = CGRect(x: 0, y: 0, width: 28, height: 28)
         item2 = UIBarButtonItem(customView: btn2)
         item2?.removeBadge()
         if targetName != Shared().cannibisAppName {
         self.navigationItem.setRightBarButtonItems([item1!,item2!], animated: true)
         } else {
         self.navigationItem.setRightBarButtonItems([item2!], animated: true)
         }
         if let cartCount = UserDefaults.standard.object(forKey: "Badge_cart_count") as? String{
         self.item1?.removeBadge()
         if cartCount != "0"{
         self.item1?.addBadge(number: Int(cartCount)!)
         } else{
         self.item1?.removeBadge()
         }
         } else{
         
         }
         */
        
        if #available(iOS 13.0, *) {
            let statusBar = UIView(frame: (UIApplication.shared.keyWindow?.windowScene?.statusBarManager?.statusBarFrame)!)
            statusBar.backgroundColor = UIColor.clear
            UIApplication.shared.keyWindow?.addSubview(statusBar)
        }
    }
    // MARK: - Setup View
    func setupUI() {
        self.txtSearch.returnKeyType = UIReturnKeyType.search
        self.txtSearch.delegate = self
        self.txtSearch.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        self.hideKeyboardWhenTappedAround()
        self.setupNIB()
        self.setupLanguage()
        self.CallAPIGetListOfFriend()
        self.setPullToRefresh()
    }
    
    
    func setupLanguage() {
        self.txtSearch.placeholder = "Search for friends by username".localized
        //        self.lblGoBackTitle.text = "Go Back".localized
        self.lblYourFriend.text = "Your friends".localized
        self.lblGoBackTitle.text = "Go Back".localized
        self.lblNewChat.text = "New Chat".localized
    }
    fileprivate func setupNIB() {
        //        self.tblFriendList.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
        self.tblFriendList.register(UINib(nibName: "\(CustomChatCell.self)", bundle: nil), forCellReuseIdentifier: "\(CustomChatCell.self)")
    }
    
    
    func setView(view: UIView, hidden: Bool) {
        UIView.transition(with: view, duration: 0.3, options: .transitionCrossDissolve, animations: {
            view.isHidden = hidden
        })
    }
    
    //        self.filterData(textFild: textField)
    /*func filterData(textFild: UITextField){
     if textFild == txtSearch{
     if textFild.text != ""{
     arrData.dictionaryObject?.removeAll()
     let strchar = txtSearch.text?.lowercased()
     for data in arrMainData{
     if data["username"].lowercased().range(of:strchar!) != nil {
     arrData.append(data)
     }
     }
     tblFriendList.reloadData()
     }else{
     arrData = arrMainTask
     tblFriendList.reloadData()
     }
     }
     }*/
    // Handle search bar textfield
    func setPullToRefresh(){
        //refreshControl.add = NSAttributedString(string: "Pull to refresh")
        self.refreshControl.tintColor = .white
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        self.tblFriendList.addSubview(refreshControl)
    }
    @objc func refresh(_ sender: AnyObject) {
       // Code to refresh table view
        self.txtSearch.text = ""
        self.CallAPIGetListOfFriend()
    }
    
}

// MARK: - Button Actions
extension MyFriendsVC {
    @IBAction func btnBack(_ sender: UIButton) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
}

// MARK: - Extension UITableView delegate / datasource
extension MyFriendsVC: UITableViewDelegate, UITableViewDataSource {
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
        cell.imgBtn1?.addGestureRecognizer(approveGesture)
        
        cell.lblDescription.isHidden = true
        cell.setupData(data: data)
        
        // Friend Status
        ///friendStatus = 0 Both users unfriend
        ///friendStatus = 1 Both users are friend
        ///friendStatus = 2 Logged in user already sent friend request
        ///friendStatus = 3 Opponent/Searched user sent friend request to logged in user
        
        cell.imgBtn2.isHidden = true
        if data["friendStatus"].intValue == 1{ ///friendStatus = 1 Both users are friend
            cell.imgBtn1.isHidden = false
            cell.imgBtn1.image = UIImage(named: "icon_message")
        }
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //        let nextVC = storyboardName.storyBoard_Chat.instantiateViewController(withIdentifier: "FriendProfileVC") as! FriendProfileVC
        //        nextVC.userData = self.arrData[indexPath.row]
        //        self.navigationController?.pushViewController(nextVC, animated: true)
        self.openChatDetailScreen(index: indexPath.row)
    }
    
    @objc func btn1Action(sender: UITapGestureRecognizer){
        self.openChatDetailScreen(index: sender.view?.tag ?? 0)
        
    }
    
    func openChatDetailScreen(index:Int){
        print("btn 1: \(index)")
        let data = self.arrData[index]
        // Open chatting screen
        let vc = storyboardName.storyBoard_Chat.instantiateViewController(withIdentifier: "ChatDetailsVC") as! ChatDetailsVC
        vc.userid = data["send_user_id"].stringValue == MEMBER_ID ? data["receive_user_id"].stringValue : data["send_user_id"].stringValue
        vc.receiverName = data["username"].stringValue //data["send_user_id"].stringValue == MEMBER_ID ? data["recname"].stringValue : data["username"].stringValue
        self.navigationController?.pushViewController(vc, animated: true)
//        let navigationController = UINavigationController(rootViewController: vc)
//        navigationController.modalPresentationStyle = .fullScreen
//        self.present(navigationController, animated: true)
    }
}
// MARK: - Extenson for QRCodeScannerDelegate
extension MyFriendsVC: UITextFieldDelegate {
    // Handle search bar textfield
    @objc func textFieldDidChange(_ textField: UITextField) {
        if let text = textField.text, !text.isEmpty {
            print(text)
            self.lblYourFriend.isHidden = true
            self.CallAPISearchFriend(strUsername: text)
        }else {
            self.lblYourFriend.isHidden = false
            self.CallAPIGetListOfFriend()
        }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        self.view.endEditing(true)
        guard let username = textField.text else {return false}
        self.CallAPISearchFriend(strUsername: username)
        return false
    }
}

// MARK: - API Call
extension MyFriendsVC {
    func CallAPISearchFriend(strUsername: String) {     // Search friend by username
        APIManager.callAPIRequest(Method: .post, url: "\(api_searchFriend)", parameters: APIParam.searchFriend(user_id: getFromUserDefaultForKey("member_id") as? String ?? "", username: strUsername, language: "\(Language.language)",searchFriend:true).getParam(), headers: nil, showAlert: false, completion: { (jsonResult, msg) in
            logD(jsonResult)
            self.arrData.dictionaryObject?.removeAll()
            if jsonResult["flag"].stringValue == "1"{   // ~~~9S flag = 1 ==>
                self.arrData = jsonResult["data"]
            }else{      // ~~~9S flag = 0 ==>
//                self.showAlert(title: "", message: jsonResult["message"].stringValue)
            }
            checkRecordAvailable(for: self.tblFriendList, count: self.arrData.count, ctrlRefresh: nil, targetController: self, detail: noDataAvaiableDetail.init(msg: "No data available".localized, img: nil, desc: ""), shouldShowCenter: true)
        }) { (httpResponse, errorMsg) in
            //logD(httpResponse ?? "")
            //logD(errorMsg ?? "")
            DispatchQueue.main.async {
                self.stopAnimating(nil)
            }
            checkRecordAvailable(for: self.tblFriendList, count: self.arrData.count, ctrlRefresh: nil, targetController: self, detail: noDataAvaiableDetail.init(msg: "No data available".localized, img: nil, desc: ""), shouldShowCenter: true)
            self.showAlert(title: "", message: errorMsg)
        }
    }
    
    func CallAPIGetListOfFriend() {     // Get friend list
        startAnimating(CGSize(width: 100, height: 100), message: "", type: NVActivityIndicatorType.ballRotate, fadeInAnimation: nil)
        APIManager.callAPIRequest(Method: .post, url: "\(api_listOfFriends)", parameters: APIParam.listOfFriends(user_id: getFromUserDefaultForKey("member_id") as? String ?? "", language: "\(Language.language)").getParam(), headers: nil, showAlert: false, completion: { (jsonResult, msg) in
            logD(jsonResult)
            self.refreshControl.endRefreshing()
            DispatchQueue.main.async {
                self.stopAnimating(nil)
            }
            self.arrData.dictionaryObject?.removeAll()
            if jsonResult["flag"].stringValue == "1"{   // ~~~9S flag = 1 ==>
                self.arrData = jsonResult["data"]
                self.arrMainData = jsonResult["data"]
            }else{      // ~~~9S flag = 0 ==>
                //self.showAlert(title: "", message: jsonResult["message"].stringValue)
            }
            checkRecordAvailable(for: self.tblFriendList, count: self.arrData.count, ctrlRefresh: nil, targetController: self, detail: noDataAvaiableDetail.init(msg: "No data available".localized, img: nil, desc: ""), shouldShowCenter: true)
        }) { (httpResponse, errorMsg) in
            //logD(httpResponse ?? "")
            //logD(errorMsg ?? "")
            self.refreshControl.endRefreshing()
            checkRecordAvailable(for: self.tblFriendList, count: self.arrData.count, ctrlRefresh: nil, targetController: self, detail: noDataAvaiableDetail.init(msg: "No data available".localized, img: nil, desc: ""), shouldShowCenter: true)
            DispatchQueue.main.async {
                self.stopAnimating(nil)
            }
            self.showAlert(title: "", message: errorMsg)
        }
    }
  
}
