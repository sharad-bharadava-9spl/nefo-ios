//
//  ChatingVC.swift
//  CCSMembersApp
//
//  Created by Jaimin Patel on 7/19/19.
//  Copyright © 2019 Jaimin Patel. All rights reserved.
//

import UIKit
import DKImagePickerController
import Firebase
import FirebaseDatabase
import SwiftyJSON
import SDWebImage
import SlideMenuControllerSwift

class ChatingVC: UIViewController {

    @IBOutlet weak var sendTxtViewHeight: NSLayoutConstraint!
    @IBOutlet weak var txtWriteMSG: UITextView!
    @IBOutlet weak var imgBackground: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var sendBtnOutlet: UIButton!
    @IBOutlet weak var bottomChatViewHeight: NSLayoutConstraint!
   // @IBOutlet weak var txtWriteMSG: UITextField!
    
    var selectedImage : UIImage?
    var lastChatBubbleY: CGFloat = 10.0
    var internalPadding: CGFloat = 30.0
    var lastMessageType: BubbleDataType?
    var chatDict = [[String:Any]]()
    var no:Int?
    var comparePreviousDate:String=""
    var notifiction="false"
    var item1:UIBarButtonItem?
    
    var userid = ""
    var receiverName = ""
    
    //Database
    var ref = Database.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.no=0
        self.tableView.dataSource=self
        self.tableView.delegate=self
        self.txtWriteMSG.delegate=self
        
        self.navigationController?.navigationBar.isHidden=false
        
        navigationController?.navigationBar.barTintColor = UIColor.white//UIColor(named: "backgroundViewColor")
        navigationController?.navigationBar.topItem?.title = "Admin".localized.uppercased()
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(named: "NavigationText")!, NSAttributedString.Key.font: UIFont(name: "ProductSans-Bold", size: 17)!]
        navigationItem.leftBarButtonItem?.tintColor = UIColor(named: "NavigationText")!
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appMovedToForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(appMovedToForeground), name: UIApplication.didBecomeActiveNotification, object: nil)
        
        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        
        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(tap)
        self.chatDict.removeAll()
        Shared().firebaseProcess(visibility:"ONLINE")
        //singleobjseveChat()
        changesUpdateChat()
    }
    
    @objc func appMovedToForeground() {
        print("App moved to ForeGround!")
        let checkChattingScreenStatus=UserDefaults.standard.string(forKey: "ChattingScreenOn")
        if checkChattingScreenStatus == "true"{
            Shared().firebaseProcess(visibility:"ONLINE")
        } else{
            
        }
    }
    
    @objc func appMovedToBackground() {
        print("App moved to Background!")
        let checkChattingScreenStatus=UserDefaults.standard.string(forKey: "ChattingScreenOn")
        if checkChattingScreenStatus == "true"{
            Shared().firebaseProcess(visibility:"OFFLINE")
        } else{
            
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        UserDefaults.standard.set("true", forKey: "ChattingScreenOn")
       // self.txtWriteMSG.placeholder="Type a message".localized
        self.removeNavigationBarItem()
        self.imgBackground.image = UIImage(named : Shared().getImgName())
        
        var leftBack = Shared().imageWithImage(image: UIImage(named: "whiteBack")!, scaledToSize: CGSize(width: 16, height: 16))
        leftBack = leftBack.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: leftBack, style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.backVC))
        
        self.navigationController?.navigationBar.isHidden=false
        navigationController?.navigationBar.barTintColor = UIColor.white//UIColor(named: "backgroundViewColor")
        navigationController?.navigationBar.topItem?.title = "Admin".localized.uppercased()
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(named: "NavigationText")!, NSAttributedString.Key.font: UIFont(name: "ProductSans-Bold", size: 17)!]
        navigationItem.leftBarButtonItem?.tintColor = UIColor(named: "NavigationText")!
        
        var imageShopingCart = Shared().imageWithImage(image: UIImage(named: "Shoping_Cart")!, scaledToSize: CGSize(width: 23, height: 23))
        imageShopingCart = imageShopingCart.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        
        var imageNotification = Shared().imageWithImage(image: UIImage(named: "notification")!, scaledToSize: CGSize(width: 23, height: 23))
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
        btn2.frame = CGRect(x: 0, y: 0, width: 28, height: 28)
        let item2 = UIBarButtonItem(customView: btn2)
        if targetName != Shared().cannibisAppName {
        self.navigationItem.setRightBarButtonItems([item1!,item2], animated: true)
        } else {
            self.navigationItem.setRightBarButtonItems([item2], animated: true)
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
    }
    
    @objc func cartRedirection(){
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "CartScreenVC") as! CartScreenVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func backVC(){
        if notifiction=="true"{
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let appDelegate = UIApplication.shared.delegate as? AppDelegate
            let initialViewController = storyboard.instantiateViewController(withIdentifier: "ChatListVC") as! ChatListVC
            //initialViewController.shipment_id = id
            //initialViewController.shipment_prefix = "SHP-\(id)"
            //initialViewController.notificationStatus=check_Notification
            
            let leftViewController = storyboard.instantiateViewController(withIdentifier: "SlideMenuScreenVC") as! SlideMenuScreenVC
            let nvc: UINavigationController = UINavigationController(rootViewController: initialViewController)
            let slideMenuController = SlideMenuController(mainViewController: nvc,  leftMenuViewController: leftViewController)
            slideMenuController.automaticallyAdjustsScrollViewInsets = true
            appDelegate?.window?.backgroundColor = UIColor(red: 236.0, green: 238.0, blue: 241.0, alpha: 1.0)
            appDelegate?.window?.rootViewController = slideMenuController
            appDelegate?.window?.makeKeyAndVisible()
            SlideMenuOptions.contentViewScale = 1
            SlideMenuOptions.hideStatusBar = false
            SlideMenuOptions.simultaneousGestureRecognizers = false
        } else{
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        navigationController?.navigationBar.barTintColor = UIColor.white//UIColor(named: "backgroundViewColor")
        navigationController?.navigationBar.topItem?.title = "Admin".localized.uppercased()
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(named: "NavigationText")!, NSAttributedString.Key.font: UIFont(name: "ProductSans-Bold", size: 17)!]
        navigationItem.leftBarButtonItem?.tintColor = UIColor(named: "NavigationText")!
        
        self.tableView.reloadData()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        UserDefaults.standard.set("false", forKey: "ChattingScreenOn")
        Shared().firebaseProcess(visibility:"OFFLINE")
        var handle:UInt = 0
        handle = ref.observe(.value) { (snapshot) in
            self.ref.removeObserver(withHandle: handle)
        }
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
        self.view.resignFirstResponder()
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        var info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        UIView.animate(withDuration: 1.0, animations: { () -> Void in
            self.bottomChatViewHeight.constant = -keyboardFrame.size.height-8.0
        }) { (completed: Bool) -> Void in
            //self.moveToLastMessage()
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        UIView.animate(withDuration: 1.0, animations: { () -> Void in
            self.bottomChatViewHeight.constant = -8.0
        }) { (completed: Bool) -> Void in
           // self.moveToLastMessage()
        }
    }
    
    @IBAction func btnAttach(_ sender: UIButton) {
        showImagePicker()
        //self.present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func btnSendAction(_ sender: UIButton) {
        if self.txtWriteMSG.text==""{
            
        } else{
             let txtMsg :String = (self.txtWriteMSG.text!.trimmingCharacters(in: .whitespacesAndNewlines))
            //firebaseChatProcess
            Shared().firebaseChatProcess(text: txtMsg)
            self.txtWriteMSG.text=""
            var frame = txtWriteMSG.frame
            frame.size.height = 30
            if frame.size.height < 80{
                self.txtWriteMSG.frame = frame
                self.sendTxtViewHeight.constant=frame.size.height+20
            } else{
                
            }
        }
    }
    
    func imageData(randomno:Int,imgStr:String,date:String){
        self.fillChatData(txt:"",img:imgStr,nos: self.getRandomChatDataType(no:randomno), sendDate: date)
        self.no=self.no!+1
        // self.txtChat.text=""
        
        self.tableView.reloadData()
        //self.tblHeight.constant=self.chattblView.contentSize.height
        // self.chattblView.layoutIfNeeded()
        let lastRow: Int = self.tableView.numberOfRows(inSection: 0) - 1
        let indexPath = IndexPath(row: lastRow, section: 0);
        self.tableView.scrollToRow(at: indexPath, at: .top, animated: false)
    }
    
    func textData(randomno:Int,text:String,date:String){
        self.fillChatData(txt:text,img:"",nos: getRandomChatDataType(no:randomno), sendDate: date)
        no=no!+1
        // self.txtChat.text=""
        self.tableView.reloadData()
        //self.tblHeight.constant=self.chattblView.contentSize.height
        // self.chattblView.layoutIfNeeded()
        let lastRow: Int = self.tableView.numberOfRows(inSection: 0) - 1
        let indexPath = IndexPath(row: lastRow, section: 0);
        self.tableView.scrollToRow(at: indexPath, at: .top, animated: false)
    }
    
    func singleobjseveChat(){
    
//        let my_id :String = JSON(UserDefaults.standard.object(forKey: "user_id")!).stringValue
//        _ = ref.child("Chat").child(my_id).observeSingleEvent(of:DataEventType.value, with: { (snapshot) in
//            let postDict = snapshot.value as? [String : AnyObject] ?? [:]
//            print("JSON: =>",postDict)
//            print("Driver Id Is ::",my_id)
//            print("postDict.keys",postDict.keys)
//            if let val = snapshot.value as? [String : AnyObject]{
//                //for item in val{
//
//                for snap in snapshot.children{
//                    let userSnap = snap as! DataSnapshot
//                    let uid = userSnap.key //the uid of each user
//                    let userDict = userSnap.value as! [String:AnyObject]
//                    let text = userDict["text"] as! String
//
//                    print("key = \(uid) and timestamp = \(text)")
//                    let id = userDict["id"] as! String
//                    if id == "BOT"{
//                        self.textData(randomno:1,text: text)
//                    } else{
//                        if text == ""{
//                            let image = userDict["image"] as! String
////                            let imageDownloader = SDWebImageDownloader.shared()
////                            let asset = URL(string: image)
////                            imageDownloader.downloadImage(with:asset, options: [], progress: nil) {
////                                (img, error, url, data) in
////                                if img != nil{
////                                    self.imageData(randomno: 2, imgStr: img!)
////
////                                }else{
////
////                                }
////                            }
//
//
//                        } else{
//                            self.textData(randomno:2,text: text)
//                        }
//                    }
//                }
//
//            }
//        })
    }
    
    func changesUpdateChat(){
        
        let my_id :String = JSON(UserDefaults.standard.object(forKey: "user_id")!).stringValue
        _ = ref.child("Chat").child(my_id).observe(DataEventType.childAdded, with: { (snapshot) in
            let postDict = snapshot.value as? [String : AnyObject]
            print("JSON: =>",postDict)
            print("Driver Id Is ::",my_id)
           // print("postDict.keys",postDict.keys)
          //  if let val = snapshot.value as? [String : AnyObject]{
            //    for item in postDict{
                  //  let userDict = postDict!["Name"] as! String
            //createdAt
            
            let createdAt = self.convertTimestamptoDate(timeStamp:JSON(postDict!["createdAt"]!).double!)
            print("createdAt%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%",createdAt)
                    let text = postDict!["text"] as! String
                    let id = postDict!["id"] as! String
                    if id == "BOT"{
                        self.textData(randomno:1,text: text, date: createdAt)
                    } else{
                        if text == ""{
                            print("postDict![image] as! String ====================>>>>>>>>>>>>>",postDict!["image"] as? String)
                           // let image = postDict!["image"] as! String
                            if let image = postDict!["image"] as? String{
                                self.imageData(randomno: 2, imgStr: image, date: createdAt)
                            }
//                            let imageDownloader = SDWebImageDownloader.shared()
//                            let asset = URL(string: image)
//                            imageDownloader.downloadImage(with:asset, options: [], progress: nil) {
//                                (img, error, url, data) in
//                                if img != nil{
//                                    self.imageData(randomno: 2, imgStr: img!)
//
//                                }else{
//
//                                }
//                            }
                            
                            
                        } else{
                            self.textData(randomno:2,text: text, date: createdAt)
                        }
                    }
                //}
                //for item in val{
                
             /*   for snap in snapshot.children{
                    let userSnap = snap as! DataSnapshot
                    let uid = userSnap.key //the uid of each user
                    let userDict = userSnap.value as! [String:AnyObject]
                    let text = userDict["text"] as! String
                    
                    print("key = \(uid) and timestamp = \(text)")
                    let id = userDict["id"] as! String
                    if id == "BOT"{
                        self.textData(randomno:1,text: text)
                    } else{
                        if text == ""{
                            let image = userDict["image"] as! String
                            let imageDownloader = SDWebImageDownloader.shared()
                            let asset = URL(string: image)
                            imageDownloader.downloadImage(with:asset, options: [], progress: nil) {
                                (img, error, url, data) in
                                if img != nil{
                                    self.imageData(randomno: 2, imgStr: img!)
                                    
                                }else{
                                    
                                }
                            }
                            
                            
                        } else{
                            self.textData(randomno:2,text: text)
                        }
                    }
                }
             */
            //}
        })
    }
    
    func convertTimestamptoDate(timeStamp:Double) -> String{
        //if let timeResult = (jsonResult["dt"] as? Double) {
        let x = timeStamp / 1000
        let date = NSDate(timeIntervalSince1970: x)
        let dayTimePeriodFormatter = DateFormatter()
        dayTimePeriodFormatter.dateFormat = "MMM dd, yyyy"
        
        //let dateString = dayTimePeriodFormatter.stringFromDate(date)
        let localDate = dayTimePeriodFormatter.string(from: date as Date)
        
        if self.comparePreviousDate == localDate{
            return "false"
        } else{
            self.comparePreviousDate = localDate
            return localDate
        }
    }
    
    func showImagePicker() {
        let pickerController = DKImagePickerController()
        pickerController.assetType = .allPhotos
        pickerController.defaultAssetGroup = .smartAlbumUserLibrary
        //pickerController.maxSelectableCount = 5
        pickerController.singleSelect = true
        pickerController.didSelectAssets = { (assets: [DKAsset]) in
            if  assets.count>0
            {
                for var i in 0 ... assets.count-1 {
                    assets[i].fetchOriginalImage(completeBlock: { (image, info) in
                        if image?.imageOrientation.rawValue == 0{
                            //left
                            let rotatedImage = Shared().imageRotatedByDegrees(oldImage: image!, deg: 0)
                            Shared().firebaseChatProcessImage(image: rotatedImage)
                            //self.fillChatData(txt:"",img:rotatedImage,nos: self.getRandomChatDataType(no:2))
                        } else if image?.imageOrientation.rawValue == 3{
                            //up
                            let rotatedImage = Shared().imageRotatedByDegrees(oldImage: image!, deg: 90)
                            Shared().firebaseChatProcessImage(image: rotatedImage)
                            //self.fillChatData(txt:"",img:rotatedImage,nos: self.getRandomChatDataType(no:2))
                        } else if image?.imageOrientation.rawValue == 2 {
                            //down
                            let rotatedImage = Shared().imageRotatedByDegrees(oldImage: image!, deg: 270)
                            Shared().firebaseChatProcessImage(image: rotatedImage)
                            //self.fillChatData(txt:"",img:rotatedImage,nos: self.getRandomChatDataType(no:2))
                        } else if image?.imageOrientation.rawValue == 1 {
                            //right
                            let rotatedImage = Shared().imageRotatedByDegrees(oldImage: image!, deg: 180)
                            Shared().firebaseChatProcessImage(image: rotatedImage)
                            //self.fillChatData(txt:"",img:rotatedImage,nos: self.getRandomChatDataType(no:2))
                        }
//                        self.no=self.no!+1
//                        // self.txtChat.text=""
//                        
//                        self.tableView.reloadData()
//                        //self.tblHeight.constant=self.chattblView.contentSize.height
//                        // self.chattblView.layoutIfNeeded()
//                        let lastRow: Int = self.tableView.numberOfRows(inSection: 0) - 1
//                        let indexPath = IndexPath(row: lastRow, section: 0);
//                        self.tableView.scrollToRow(at: indexPath, at: .top, animated: false)
                    })
                    
                }
                
                //self.imgChanged = true
            }
            
        }
        self.present(pickerController, animated: false) {}
        
        
    }
    
    func getRandomChatDataType(no:Int) -> BubbleDataType {
        return BubbleDataType(rawValue:no%2)!
    }
    
    func fillChatData(txt:String,img:String,nos:BubbleDataType,sendDate:String){
        var valData = [String:Any]()
        valData["txtMsg"] = txt
        valData["ram"] = nos
        valData["id"] = no
        valData["img"] = img
        valData["sendDate"] = sendDate
        valData["date"] = getCurrentTime()
        
        chatDict.append(valData)
    }
    
    func getCurrentTime()->String{
        let date = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let minutes = calendar.component(.minute, from: date)
        let hoursStr = "\(hour)"
        let minutStr = "\(minutes)"
        print("Current time is",hoursStr+":"+minutStr)
        return hoursStr+":"+minutStr
    }
    
}

extension ChatingVC:UITextViewDelegate{
    func textViewDidChange(_ textView: UITextView) {
        var frame = textView.frame
        frame.size.height = textView.contentSize.height
        if frame.size.height < 80{
            self.txtWriteMSG.frame = frame
            self.sendTxtViewHeight.constant=frame.size.height+20
        } else{
            
        }
        
    }
}

extension ChatingVC:UITableViewDataSource,UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatDict.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "chattingCell") as! chattingCell
        let chatData = chatDict[indexPath.row]
        //sendDate
        if JSON(chatData["sendDate"]!).stringValue == "false"{
            cell.lblMainDate.isHidden=true
            cell.mainDateHeight.constant=0
        } else{
            cell.mainDateHeight.constant=18
            cell.lblMainDate.isHidden=false
            cell.lblMainDate.text=JSON(chatData["sendDate"]!).stringValue
        }
        if JSON(chatData["txtMsg"]!).stringValue == ""{
//            let imageView=UIImageView()
//            imageView.sd_setImage(with: URL(string: JSON(chatData["img"]!).stringValue), placeholderImage: #imageLiteral(resourceName: "SlideHomeIcon"))
//            let image:UIImage=imageView.image!
            let bubbleData = ChatBubbleData(text: chatData["txtMsg"] as? String, image:  chatData["img"] as? String , date: NSDate(), type: chatData["ram"] as! BubbleDataType)
            let chatBubble = ChatBubble(data: bubbleData, startY:5)
            print("Chat Bubble frame is",chatBubble.frame)
            cell.mainCellView.frame = chatBubble.frame
            cell.mainViewHeight.constant=chatBubble.frame.size.height+5
            cell.mainCellView.addSubview(chatBubble)
            cell.lblDate.text=chatData["date"] as? String
            if bubbleData.type == .Mine{
                print("Mine Side(Send by self)")
                cell.lblDate.textAlignment = .right
                
            } else{
                cell.lblDate.textAlignment = .left
                print("Opponent Side(Send by opponent)")
            }
            print("cell Bubble frame is",cell.mainCellView.frame)
        } else{
            let bubbleData = ChatBubbleData(text: chatData["txtMsg"] as? String, image: ""  , date: NSDate(), type: chatData["ram"] as! BubbleDataType)
            let chatBubble = ChatBubble(data: bubbleData, startY:5)
            print("Chat Bubble frame is",chatBubble.frame)
            cell.mainCellView.frame = chatBubble.frame
            cell.mainViewHeight.constant=chatBubble.frame.size.height+5
            cell.mainCellView.addSubview(chatBubble)
            cell.lblDate.text=chatData["date"] as? String
            if bubbleData.type == .Mine{
                print("Mine Side(Send by self)")
                cell.lblDate.textAlignment = .right
                
            } else{
                cell.lblDate.textAlignment = .left
                print("Opponent Side(Send by opponent)")
            }
            print("cell Bubble frame is",cell.mainCellView.frame)
        }
        
        return cell
    }
    
    
    
    //    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    //        return UITableView.automaticDimension
    //    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
