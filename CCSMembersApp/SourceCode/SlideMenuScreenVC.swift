//
//  SlideMenuScreenVC.swift
//  CCSMembersApp
//
//  Created by Jaimin Patel on 6/7/19.
//  Copyright © 2019 Jaimin Patel. All rights reserved.
//

import UIKit
import SlideMenuControllerSwift
import CoreData
import SwiftyJSON
import SDWebImage
import Alamofire
import NVActivityIndicatorView

class SlideMenuScreenVC: UIViewController, NVActivityIndicatorViewable {

    @IBOutlet weak var btnSwitchAccountSecond: UIButton!
    @IBOutlet weak var btnSwitchAcountThird: UIButton!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var imgSwitchAccountFirst: UIImageView!
    @IBOutlet weak var imgSwitchAccountSecond: UIImageView!
    @IBOutlet weak var imgSwicthAccountThird: UIImageView!
    @IBOutlet weak var userImgView: UIView!
    @IBOutlet weak var btnSwitchAccount: UIButton!
    @IBOutlet weak var switchImg: UIImageView!
    @IBOutlet weak var lblUserEmailID: UILabel!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var tableView: UITableView!
    var localDataStorage : [NSManagedObject] = []
    var listDictArr=[[String:Any]]()
    var viewDid=true
    var fromLogin = false
    
    //First Button
    var c_id_first:String?
    var email_first:String?
    var image_first:Data?
    var name_first:String?
    var Name_first:String?
    var user_id_first:String?
    var user_type_first:String?
    
    //Second Button
    var c_id_second:String?
    var email_second:String?
    var image_second:Data?
    var name_second:String?
    var Name_second:String?
    var user_id_second:String?
    var user_type_second:String?
    
    //Third Button
    var c_id_third:String?
    var email_third:String?
    var image_third:Data?
    var name_third:String?
    var user_id_third:String?
    var Name_third:String?
    var UserImae:String?
    var user_type_third:String?
    
    override func viewDidAppear(_ animated: Bool) {
        if let _ : AnyObject = UserDefaults.standard.object(forKey: "user_id") as AnyObject? {
            self.callAPICheckUserStatus()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(callAPICheckUserStatus), name: Notification.Name("callAPICheckUserStatus"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateMenu), name: NSNotification.Name(rawValue: "updateMenuSelection"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.setParticularIndex(_:)), name: NSNotification.Name(rawValue: NotificationName().SetParticularIndexInSideMenu), object: nil)

        self.tableView.dataSource=self
        self.tableView.delegate=self
      //  self.switchImg.image=UIImage(named:"switch_down_arrow")
        self.btnSwitchAccount.tag=1
        tableView.rowHeight=60
        self.imgSwitchAccountFirst.isHidden=false
        self.imgSwitchAccountSecond.isHidden=true
        self.btnSwitchAccountSecond.isHidden=true
        self.btnSwitchAcountThird.isHidden=true
        self.imgSwicthAccountThird.isHidden=true
        DispatchQueue.main.async {
         if let _ : AnyObject = UserDefaults.standard.object(forKey: "first_name") as AnyObject? {
            let id=UserDefaults.standard.object(forKey: "user_id") as! String
            self.lblUserName.text=UserDefaults.standard.object(forKey: "NickName") as! String
            self.lblName.text=UserDefaults.standard.object(forKey: "NickName") as! String
            self.lblUserEmailID.text=UserDefaults.standard.object(forKey: "email") as! String
            self.imgSwitchAccountFirst.sd_setImage(with: URL(string: UserDefaults.standard.object(forKey: "image") as? String ?? ""), placeholderImage: #imageLiteral(resourceName: "SlideMyProfileIcon"))
            if let imageData = UserDefaults.standard.object(forKey: "image") as? Data{
                //self.imgSwitchAccountFirst.image=UIImage(data: imageData)
                self.fetch()
                self.setupMenu()
            } else{
                let imgName = UserDefaults.standard.object(forKey: "image") as! String
               // self.imgSwitchAccountFirst.sd_setImage(with: URL(string: imgName), placeholderImage: #imageLiteral(resourceName: "SlideMyProfileIcon"))
                
                let imageDownloader = SDWebImageDownloader.shared
                let asset = URL(string: imgName)
                imageDownloader.downloadImage(with:asset, options: [], progress: nil) {
                    (image, error, url, data) in
                    if image != nil{
                        let data=image!.pngData()
                        let user_type=UserDefaults.standard.object(forKey: "check_adminLogin") as! String
                        self.save(email: self.lblUserEmailID.text!,name :self.lblUserName.text!,user_id:id, data:data!,Name: self.lblName.text!,user_type:user_type)
                        self.fetch()
                        self.setupMenu()
                        
                    }else{
                        self.fetch()
                        self.setupMenu()
                    }
                }
            }
            //self.setupMenu()
         } else {
             self.lblUserEmailID.text = appDelegateShared.Email
             self.lblName.text = appDelegateShared.nameU
             self.setupNewMenu()
         }
            
        }
        viewDid=true
        // Do any additional setup after loading the view.
    }
    @objc func updateMenu() {
       self.tableView.reloadData() // a refresh the tableView.
   }

    @IBAction func btnSecondSwitchAC(_ sender: UIButton) {
        self.updateCartCount(email: self.email_second!, name: self.name_second!, user_id: self.user_id_second!, data: self.image_second!, Name: Name_second!,user_type:self.user_type_second!)//(user_id:self.user_id_second!)
       /* self.deleteData(email: self.email_second!, name: self.name_second!, user_id: self.user_id_second!, data: self.image_second!, Name: Name_second!,user_type:self.user_type_second!)//(user_id:self.user_id_second!)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        var vc: UIViewController!
        let vcCon = storyboard.instantiateViewController(withIdentifier: "MainMenuVC") as! MainMenuVC
        vc = UINavigationController(rootViewController: vcCon)
        self.slideMenuController()?.changeMainViewController(vc, close: true)*/

    }
    
    @IBAction func btnThirdSwitchAC(_ sender: UIButton) {
        self.updateCartCount(email: self.email_third!, name: self.name_third!, user_id: self.user_id_third!, data: self.image_third!, Name: self.Name_third!,user_type:self.user_type_third!)
        /*self.deleteData(email: self.email_third!, name: self.name_third!, user_id: self.user_id_third!, data: self.image_third!, Name: self.Name_third!,user_type:self.user_type_third!)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        var vc: UIViewController!
        let vcCon = storyboard.instantiateViewController(withIdentifier: "MainMenuVC") as! MainMenuVC
        vc = UINavigationController(rootViewController: vcCon)
        self.slideMenuController()?.changeMainViewController(vc, close: true)*/
    }
    
    func deleteData(email: String,name :String,user_id:String, data:Data,Name:String,user_type:String){
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let context = appDelegate!.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "FileStore")
        fetchRequest.predicate = NSPredicate(format: "user_id contains[c] %@", user_id)
        if let result = try? context.fetch(fetchRequest) {
            for object in result {
                context.delete(object as! NSManagedObject)
                try! context.save()
                save(email: email,name :name,user_id:user_id, data:data,Name: Name,user_type:user_type)
                fetch()
               // print("self.switchImg.tag",self.btnSwitchAccount.tag)
                if self.btnSwitchAccount.tag==1{
                    self.setupMenu()
                }
            }
        }
    }
    
//    func saveCoreData(){
//        let id=UserDefaults.standard.object(forKey: "user_id") as! String
//        let data=self.imgSwitchAccountFirst.image?.pngData()//UIImage(named: "SlideMyProfileIcon")!.pngData()
//        let email=UserDefaults.standard.object(forKey: "email") as! String
//        let first_name=UserDefaults.standard.object(forKey: "first_name") as! String
//        let name=UserDefaults.standard.object(forKey: "Name") as! String
//
//        self.save(email: email, name: first_name, user_id: id, data:data!,Name: name)
//    }
    
    func save(email: String,name :String,user_id:String, data:Data,Name:String,user_type:String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let id=user_id
        let allreadyExist = isExist(id:Int(id)!)
        if allreadyExist == false{
            // 1
            let managedContext = appDelegate.persistentContainer.viewContext
            
            // 2
            let entity = NSEntityDescription.entity(forEntityName: "FileStore",in: managedContext)!
            
            let fileStore = NSManagedObject(entity: entity, insertInto: managedContext)
            var uniqID="0"
            if let uniq = UserDefaults.standard.object(forKey: "c_id") as! String? {
                uniqID=uniq
                uniqID="\(Int(uniqID)!+1)"
                let nextUniq="\(Int(uniqID)!+1)"
                UserDefaults.standard.set(nextUniq, forKey: "c_id")
            } else{
                UserDefaults.standard.set("0", forKey: "c_id")
            }
            self.lblUserName.text=name
            self.lblUserEmailID.text=email
            self.lblName.text=Name
            // 3
            fileStore.setValue(uniqID, forKeyPath: "c_id")
            fileStore.setValue(email, forKeyPath: "email")
            fileStore.setValue(Name, forKeyPath: "first_name")
            fileStore.setValue(user_id, forKeyPath: "user_id")
            fileStore.setValue(user_type, forKeyPath: "user_type")
            fileStore.setValue(name, forKeyPath: "name")//user_id
            fileStore.setValue("\(Date())", forKeyPath: "date")//user_id
            fileStore.setValue(data.base64EncodedString(), forKeyPath: "image")
            
            // 4
            do {
                try managedContext.save()
            } catch let error as NSError {
                Shared().showAlert(uIViewController: self, title: "offline", message: "Offline Document Save Error is\(error)")
            }
        } else{
            deleteData(email: email, name: name, user_id: user_id, data: data,Name:Name,user_type:user_type)
        }
    }
    
    func isExist(id: Int) -> Bool {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let managedContext = appDelegate!.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "FileStore")
        fetchRequest.predicate = NSPredicate(format: "user_id = %d", id)
        
        let res = try! managedContext.fetch(fetchRequest)
        return res.count > 0 ? true : false
    }
    
    func fetch() {
        listDictArr.removeAll()
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        //2
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "FileStore")
        let nameSort = NSSortDescriptor(key:"date", ascending:false)
        fetchRequest.sortDescriptors = [nameSort]
        //3
        do {
            let localDataStorage1 = try managedContext.fetch(fetchRequest)
            let imgdata = UIImage(named: "addAccount")!.pngData()
            self.switchLoginMenu(id:"",imgName:imgdata!,email:"Add club".localized,name:"",Name:"", user_type: "")
            var indexIs=0
            self.imgSwitchAccountSecond.isHidden=true
            self.imgSwitchAccountSecond.isHidden=true
            self.btnSwitchAccountSecond.isHidden=true
            self.btnSwitchAcountThird.isHidden=true
            for item in localDataStorage1{
                if indexIs == 0{
                    self.c_id_first=item.value(forKey: "c_id") as? String
                    self.email_first=item.value(forKey: "email") as? String
                    self.image_first=Data(base64Encoded: (item.value(forKey: "image") as! String))!
                    self.name_first=item.value(forKey: "name") as? String
                    self.Name_first=item.value(forKey: "first_name") as? String
                    self.user_id_first = item.value(forKey: "user_id") as? String
                    self.user_type_first = item.value(forKey: "user_type") as? String
                    //self.btnFirstSwitchAC.setImage(UIImage(data: Data(base64Encoded: (item.value(forKey: "image") as! String))!), for: .normal)
                    self.imgSwitchAccountFirst.sd_setImage(with: URL(string: UserDefaults.standard.object(forKey: "image") as? String ?? ""), placeholderImage: #imageLiteral(resourceName: "SlideMyProfileIcon"))
                    //self.imgSwitchAccountFirst.image=UIImage(data: Data(base64Encoded: (item.value(forKey: "image") as! String))!)
                    self.lblUserName.text=item.value(forKey: "name") as? String
                    self.lblName.text=item.value(forKey: "first_name") as? String
                    self.lblUserEmailID.text=item.value(forKey: "email") as? String
                    
                    UserDefaults.standard.set(item.value(forKey: "email") as! String, forKey: "email")
                    UserDefaults.standard.set(item.value(forKey: "name") as! String, forKey: "first_name")
                    UserDefaults.standard.set(item.value(forKey: "first_name") as! String, forKey: "Name")
                    //UserDefaults.standard.set(Data(base64Encoded: (item.value(forKey: "image") as! String))!, forKey: "image")
                    UserDefaults.standard.set(item.value(forKey: "user_id") as! String, forKey: "user_id")
                    UserDefaults.standard.set(item.value(forKey: "user_type") as! String, forKey: "check_adminLogin")
                } else if indexIs == 1{
                    //self.imgSwitchAccountSecond.isHidden=false
                    //self.btnSwitchAccountSecond.isHidden=false
                    self.c_id_second=item.value(forKey: "c_id") as? String
                    self.email_second=item.value(forKey: "email") as? String
                    self.image_second=Data(base64Encoded: (item.value(forKey: "image") as! String))!
                    self.name_second=item.value(forKey: "name") as? String
                    self.Name_second=item.value(forKey: "first_name") as? String
                    self.user_id_second = item.value(forKey: "user_id") as? String
                    self.imgSwitchAccountSecond.image=UIImage(data: Data(base64Encoded: (item.value(forKey: "image") as! String))!)
                    self.user_type_second = item.value(forKey: "user_type") as? String
                    let data = Data(base64Encoded: (item.value(forKey: "image") as! String))!
                    let id = item.value(forKey: "user_id") as! String
                    let email = item.value(forKey: "email") as! String
                    let first_name = item.value(forKey: "name") as! String
                    let Name = item.value(forKey: "first_name") as! String
                    let user_type = item.value(forKey: "user_type") as! String
                    self.switchLoginMenu(id:id,imgName:data,email:email,name:first_name,Name:Name, user_type: user_type)
                } else if indexIs == 2{
                    //self.imgSwicthAccountThird.isHidden=false
                    //self.btnSwitchAcountThird.isHidden=false
                    self.c_id_third=item.value(forKey: "c_id") as? String
                    self.email_third=item.value(forKey: "email") as? String
                    self.image_third=Data(base64Encoded: (item.value(forKey: "image") as! String))!
                    self.name_third=item.value(forKey: "name") as? String
                    self.Name_third=item.value(forKey: "first_name") as? String
                    self.user_id_third = item.value(forKey: "user_id") as? String
                    self.user_type_third = item.value(forKey: "user_type") as? String
                    self.imgSwicthAccountThird.image=UIImage(data: Data(base64Encoded: (item.value(forKey: "image") as! String))!)
                    let data = Data(base64Encoded: (item.value(forKey: "image") as! String))!
                    let id = item.value(forKey: "user_id") as! String
                    let email = item.value(forKey: "email") as! String
                    let first_name = item.value(forKey: "name") as! String
                    let Name = item.value(forKey: "first_name") as! String
                    let user_type = item.value(forKey: "user_type") as! String
                    self.switchLoginMenu(id:id,imgName:data,email:email,name:first_name,Name:Name, user_type: user_type)
                } else{
                    let data = Data(base64Encoded: (item.value(forKey: "image") as! String))!
                    let id = item.value(forKey: "user_id") as! String
                    let email = item.value(forKey: "email") as! String
                    let first_name = item.value(forKey: "name") as! String
                    let Name = item.value(forKey: "first_name") as! String
                    let user_type = item.value(forKey: "user_type") as! String
                    self.switchLoginMenu(id:id,imgName:data,email:email,name:first_name,Name:Name, user_type: user_type)
                }
                
                indexIs=indexIs+1
            }
             self.tableView.reloadData()
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    func setAllMenus() {
        listDictArr.removeAll()
        self.fillupMenu(id:"1",imgName: "Side_menu_home", lblName: "Home".localized)
        self.fillupMenu(id:"12",imgName: "Side_menu_menu", lblName: "Menu".localized)
        self.fillupMenu(id:"6",imgName: "Side_menu_profile", lblName: "Slide_My Profile".localized)
        self.fillupMenu(id:"5",imgName: "Side_menu_history", lblName: "History".localized)
        self.fillupMenu(id:"10",imgName: "Side_menu_map", lblName: "Map".localized)
        self.fillupMenu(id:"14",imgName: "Slide_Chat", lblName: "Chat".localized)
        self.fillupMenu(id:"18",imgName: "Side_menu_map", lblName: "CCS Map".localized)
        self.fillupMenu(id:"9",imgName: "Side_menu_language", lblName: "Language".localized)
        self.fillupMenu(id:"13",imgName: "Side_menu_Password", lblName: "Change Passcode".localized)
        self.fillupMenu(id:"8",imgName: "Slide_Setting", lblName: "Slide_Settings".localized)
        self.fillupMenu(id:"15",imgName: "Side_menu_club", lblName: "My_Clubs".localized)
        self.fillupMenu(id:"17",imgName: "Side_menu_preregistration", lblName: "Pre_Registration".localized)
        self.fillupMenu(id:"11",imgName: "Side_menu_logout", lblName: "Logout".localized)
        self.fillupMenu(id:"16",imgName: "delete", lblName: "Slide_Delete_Account".localized)
    }
    func setupMenu(){
        // MARK: VIS
        //        listDictArr.removeAll()
        //        self.fillupMenu(id:"1",imgName: "Slide_Home", lblName: "Slide_Home".localized)
        //        self.fillupMenu(id:"12",imgName: "Menu_Menu", lblName: "Menu".localized)
        //        self.fillupMenu(id:"6",imgName: "Slide_Profile", lblName: "Slide_My Profile".localized)
        //        self.fillupMenu(id:"2",imgName: "Slide_Category", lblName: "Slide_Categories".localized)
        //        if targetName != Shared().cannibisAppName {
        //        self.fillupMenu(id:"3",imgName: "Slide_Donation", lblName: "Slide_Donation".localized)
        //        }
        //        self.fillupMenu(id:"5",imgName: "Slide_DispenseHistory", lblName: "Slide_Dispense History".localized)
        //        self.fillupMenu(id:"13",imgName: "Chage_Passcode", lblName: "Change Passcode".localized)
        //        self.fillupMenu(id:"7",imgName: "Slide_Notification", lblName: "Slide_Notifications".localized)
        //        if let checkAdminLogin=UserDefaults.standard.object(forKey: "check_adminLogin") as? String{
        //            if checkAdminLogin == "Customer"{
        //                self.fillupMenu(id:"4",imgName: "Slide_Chat", lblName: "Slide_Chat".localized)
        //            } else{
        //
        //            }
        //        }
        //        if let checkAdminLogin=UserDefaults.standard.object(forKey: "check_adminLogin") as? String{
        //            if checkAdminLogin == "Admin"{
        //                self.fillupMenu(id:"8",imgName: "Slide_Setting", lblName: "Slide_Settings".localized)
        //            } else{
        //
        //            }
        //        }
        //        self.fillupMenu(id:"9",imgName: "Slide_Language", lblName: "Language".localized)
        //        self.fillupMenu(id:"10",imgName: "Slide_Map", lblName: "Map".localized)
        //        self.fillupMenu(id:"11",imgName: "Slide_Logout", lblName: "Logout".localized)
        //        self.tableView.reloadData()
        listDictArr.removeAll()
        
        
        
        
        
//        if let checkAdminLogin=UserDefaults.standard.object(forKey: "check_adminLogin") as? String{
//            if checkAdminLogin == "Customer"{
//                self.fillupMenu(id:"4",imgName: "Slide_Chat", lblName: "Slide_Chat".localized)
//            } else{
//
//            }
//        }
        if let checkAdminLogin=UserDefaults.standard.object(forKey: "check_adminLogin") as? String{ // 9s setup side menu
            let isMenuShow = getFromUserDefaultForKey(key_isMenuShow) as? Bool ?? true
            let isDispensShow = getFromUserDefaultForKey(key_isDispensShow) as? Bool ?? true
            if checkAdminLogin == "Admin"{
                self.setAllMenus()
                if UserDefaults.standard.bool(forKey: "ShowMap") == false {
                    self.listDictArr = listDictArr.filter({ (dictionary) -> Bool in
                        if let value = dictionary["txt"] as? String{
                            return value != "Map".localized
                        }
                        return false
                    })
                }
                if isMenuShow == false {
                    self.listDictArr = listDictArr.filter({ (dictionary) -> Bool in
                        if let value = dictionary["txt"] as? String{
                            return value != "Menu".localized
                        }
                        return false
                    })
                }
                if isDispensShow == false {
                    self.listDictArr = listDictArr.filter({ (dictionary) -> Bool in
                        if let value = dictionary["txt"] as? String{
                            return value != "History".localized
                        }
                        return false
                    })
                }
                
                
            } else{
                if UserDefaults.standard.bool(forKey: "ShowMap") == true {
                    if isMenuShow == true {
                        self.fillupMenu(id:"1",imgName: "Side_menu_home", lblName: "Home".localized)
                        self.fillupMenu(id:"12",imgName: "Side_menu_menu", lblName: "Menu".localized)
                        self.fillupMenu(id:"6",imgName: "Side_menu_profile", lblName: "Slide_My Profile".localized)
                        if isDispensShow{
                            self.fillupMenu(id:"5",imgName: "Side_menu_history", lblName: "History".localized)
                        }
                        self.fillupMenu(id:"10",imgName: "Side_menu_map", lblName: "Map".localized)
                        self.fillupMenu(id:"9",imgName: "Side_menu_language", lblName: "Language".localized)
                        self.fillupMenu(id:"13",imgName: "Side_menu_Password", lblName: "Change Passcode".localized)
                        self.fillupMenu(id:"15",imgName: "Side_menu_club", lblName: "My_Clubs".localized)
                        self.fillupMenu(id:"14",imgName: "Slide_Chat", lblName: "Chat".localized)
                        self.fillupMenu(id:"18",imgName: "Side_menu_map", lblName: "CCS Map".localized)
                        self.fillupMenu(id:"17",imgName: "Side_menu_preregistration", lblName: "Pre_Registration".localized)
                        self.fillupMenu(id:"11",imgName: "Side_menu_logout", lblName: "Logout".localized)
                        self.fillupMenu(id:"16",imgName: "delete", lblName: "Slide_Delete_Account".localized)
                    }else {
                        self.fillupMenu(id:"1",imgName: "Side_menu_home", lblName: "Home".localized)
                        self.fillupMenu(id:"6",imgName: "Side_menu_profile", lblName: "Slide_My Profile".localized)
                        if isDispensShow{
                            self.fillupMenu(id:"5",imgName: "Side_menu_history", lblName: "History".localized)
                        }
                        self.fillupMenu(id:"10",imgName: "Side_menu_map", lblName: "Map".localized)
                        self.fillupMenu(id:"14",imgName: "Slide_Chat", lblName: "Chat".localized)
                        self.fillupMenu(id:"18",imgName: "Side_menu_map", lblName: "CCS Map".localized)
                        self.fillupMenu(id:"9",imgName: "Side_menu_language", lblName: "Language".localized)
                        self.fillupMenu(id:"13",imgName: "Side_menu_Password", lblName: "Change Passcode".localized)
                        self.fillupMenu(id:"15",imgName: "Side_menu_club", lblName: "My_Clubs".localized)
                        self.fillupMenu(id:"17",imgName: "Side_menu_preregistration", lblName: "Pre_Registration".localized)
                        self.fillupMenu(id:"11",imgName: "Side_menu_logout", lblName: "Logout".localized)
                        self.fillupMenu(id:"16",imgName: "delete", lblName: "Slide_Delete_Account".localized)

                    }
                }else if isMenuShow == true{
                    self.fillupMenu(id:"1",imgName: "Side_menu_home", lblName: "Home".localized)
                    self.fillupMenu(id:"12",imgName: "Side_menu_menu", lblName: "Menu".localized)
                    self.fillupMenu(id:"6",imgName: "Side_menu_profile", lblName: "Slide_My Profile".localized)
                    if isDispensShow{
                        self.fillupMenu(id:"5",imgName: "Side_menu_history", lblName: "History".localized)
                    }
                    self.fillupMenu(id:"14",imgName: "Slide_Chat", lblName: "Chat".localized)
                    self.fillupMenu(id:"9",imgName: "Side_menu_language", lblName: "Language".localized)
                    self.fillupMenu(id:"13",imgName: "Side_menu_Password", lblName: "Change Passcode".localized)
                    self.fillupMenu(id:"15",imgName: "Side_menu_club", lblName: "My_Clubs".localized)
                    self.fillupMenu(id:"17",imgName: "Side_menu_preregistration", lblName: "Pre_Registration".localized)
                    self.fillupMenu(id:"11",imgName: "Side_menu_logout", lblName: "Logout".localized)
                    self.fillupMenu(id:"16",imgName: "delete", lblName: "Slide_Delete_Account".localized)
                }else {
                    
                    self.fillupMenu(id:"1",imgName: "Side_menu_home", lblName: "Home".localized)
                    self.fillupMenu(id:"6",imgName: "Side_menu_profile", lblName: "Slide_My Profile".localized)
                    if isDispensShow{
                        self.fillupMenu(id:"5",imgName: "Side_menu_history", lblName: "History".localized)
                    }
                    self.fillupMenu(id:"14",imgName: "Slide_Chat", lblName: "Chat".localized)
                   // self.fillupMenu(id:"10",imgName: "Side_menu_map", lblName: "Map".localized)
                    self.fillupMenu(id:"9", imgName: "Side_menu_language", lblName: "Language".localized)
                    self.fillupMenu(id:"13",imgName: "Side_menu_Password", lblName: "Change Passcode".localized)
                    self.fillupMenu(id:"15",imgName: "Side_menu_club", lblName: "My_Clubs".localized)
                    self.fillupMenu(id:"17",imgName: "Side_menu_preregistration", lblName: "Pre_Registration".localized)
                    self.fillupMenu(id:"11",imgName: "Side_menu_logout", lblName: "Logout".localized)
                    self.fillupMenu(id:"16",imgName: "delete", lblName: "Slide_Delete_Account".localized)
                    
                }
                
            }
        }
        
        self.tableView.reloadData()
    }
    
    func setupNewMenu(){
        self.fillupMenu(id:"9",imgName: "Side_menu_language", lblName: "Language".localized)
        self.fillupMenu(id:"13",imgName: "Side_menu_Password", lblName: "Change Passcode".localized)
        self.fillupMenu(id:"15",imgName: "Side_menu_club", lblName: "My_Clubs".localized)
        self.fillupMenu(id:"14",imgName: "Slide_Chat", lblName: "Chat".localized)
        self.fillupMenu(id:"18",imgName: "Side_menu_map", lblName: "CCS Map".localized)
        self.fillupMenu(id:"17",imgName: "Side_menu_preregistration", lblName: "Pre_Registration".localized)
        self.fillupMenu(id:"11",imgName: "Side_menu_logout", lblName: "Logout".localized)
        self.fillupMenu(id:"16",imgName: "delete", lblName: "Slide_Delete_Account".localized)
        self.tableView.reloadData()
    }
    
    
    
    func switchLoginMenu(id:String,imgName:Data,email:String,name:String,Name:String,user_type:String){
        var menuDic = [String:Any]()
        menuDic["img"] = imgName
        menuDic["email"] = email
        menuDic["id"] = id
        menuDic["name"] = name
        menuDic["type"] = "2"
        menuDic["Name"] = Name
        menuDic["user_type"] = user_type
        self.listDictArr.append(menuDic)
    }
    
    @IBAction func btnSwitchAccount(_ sender: UIButton) {
        self.listDictArr.removeAll()
        if self.btnSwitchAccount.tag == 1{
            if viewDid == true{
               // saveCoreData()
            }
            
            viewDid=false
            tableView.rowHeight=50
            self.btnSwitchAccount.tag=2
          //  self.switchImg.image=UIImage(named:"switch_up_arrow")
            self.fetch()
        } else{
            //self.imgSwitchAccountSecond.isHidden=true
            //self.imgSwicthAccountThird.isHidden=true
            tableView.rowHeight=60
            self.btnSwitchAccount.tag=1
           // self.switchImg.image=UIImage(named:"switch_down_arrow")
            self.setupMenu()
        }
    }
    
    func fillupMenu(id:String,imgName:String,lblName:String){
        var menuDic = [String:String]()
        menuDic["img"] = imgName
        menuDic["txt"] = lblName
        menuDic["id"] = id
        menuDic["type"] = "1"
        self.listDictArr.append(menuDic)
    }
    
    
}

extension SlideMenuScreenVC:UITableViewDataSource,UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listDictArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "slidemenucell") as! slidemenucell
        //cell.manageAccountView.backgroundColor=UIColor.clear
        //cell.switchAccountView.backgroundColor=UIColor.clear
        let listDict = listDictArr[indexPath.row]
        cell.imgView.contentMode = .scaleAspectFit
        if JSON(listDict["type"]!).stringValue == "2"{
            if JSON(listDict["id"]!).stringValue == ""{
                cell.manageAccountView.isHidden=false
                cell.switchAccountView.isHidden=true
                cell.accountlbl.text=JSON(listDict["email"]!).stringValue
                cell.accountImg.image=UIImage(data: listDict["img"] as! Data)
            } else{
                cell.manageAccountView.isHidden=true
                cell.switchAccountView.isHidden=false
                cell.lblName.text=JSON(listDict["email"]!).stringValue
                // cell.imgHeigt.constant=40
                if listDict["img"] == nil{
                  //  cell.lblSwitchName.isHidden=false
//                    cell.lblSwitchName.text=JSON(listDict["name"]!).stringValue.first?.uppercased()
//                    cell.lblSwitchName.layer.cornerRadius=cell.lblSwitchName.frame.height/2.0
//                    cell.lblSwitchName.layer.masksToBounds=true
                    cell.imgView.isHidden=true
                } else{
                    cell.imgView.contentMode = .scaleToFill
                   // cell.lblSwitchName.isHidden=true
                    cell.imgView.isHidden=false
                    cell.imgView.image=UIImage(data: listDict["img"] as! Data)//named: listDict["img"]!)
                    cell.imgView.layer.cornerRadius=cell.imgView.frame.height/2.0
                    cell.imgView.layer.masksToBounds=true
                }
            }
        } else{
            cell.manageAccountView.isHidden=true
            cell.switchAccountView.isHidden=false
            cell.imgView.isHidden=false
            cell.lblName.numberOfLines = 2
           // cell.lblSwitchName.isHidden=true
           // cell.imgHeigt.constant=34
            cell.imgView.image=UIImage(named: JSON(listDict["img"]!).stringValue)
            cell.lblName.text=JSON(listDict["txt"]!).stringValue
            cell.imgbgView.roundCorners(corners: [.topLeft, .bottomLeft], radius: 8)
            cell.lblView.roundCorners(corners: [.topRight, .bottomRight], radius: 8)
            cell.switchAccountView.roundCorners(corners: [.topRight, .bottomRight, .topLeft, .bottomLeft], radius: 8)
        }
        cell.selectionStyle = .none
        cell.isUserInteractionEnabled=true
        
        print("appDelegateShared_selectedIndexMenu",appDelegateShared.selectedIndexMenu)
        
        if indexPath.row == appDelegateShared.selectedIndexMenu{
            cell.lblName.textColor = UIColor.black
            cell.switchAccountView.backgroundColor = .clear
            cell.lblView.backgroundColor = UIColor(hexString: "#33FF99")
            cell.imgView.image = cell.imgView.image?.tinted(with: UIColor(hexString: "#33FF99"))
            cell.imgbgView.backgroundColor = UIColor(hexString: "#161D26")
        }else{
            cell.lblName.textColor = UIColor(hexString: "#EBEDEF")
            cell.switchAccountView.backgroundColor = UIColor(hexString: "#404D60")
            cell.lblView.backgroundColor = UIColor(hexString: "#404D60")
            cell.imgView.image = cell.imgView.image?.tinted(with: UIColor.white)
            cell.imgbgView.backgroundColor = UIColor(hexString: "#37404B")
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        appDelegateShared.selectedIndexMenu = indexPath.row
        tableView.reloadData()
        let selectadIs=listDictArr[indexPath.row]
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if JSON(selectadIs["type"]!).stringValue == "1"{
            switch JSON(selectadIs["id"]!).stringValue {
            case "12":
                var vc: UIViewController!
                let vcCon = storyboard.instantiateViewController(withIdentifier: "HomeScreenVC") as! HomeScreenVC
                vc = UINavigationController(rootViewController: vcCon)
                appDelegateShared.parentCurrentVC = vcCon
                self.slideMenuController()?.changeMainViewController(vc, close: true)
            case "2":
                var vc: UIViewController!
                let vcCon = storyboard.instantiateViewController(withIdentifier: "CategoryScreevVC") as! CategoryScreevVC
                vc = UINavigationController(rootViewController: vcCon)
                appDelegateShared.parentCurrentVC = vcCon
                self.slideMenuController()?.changeMainViewController(vc, close: true)
            
            case "3":
                var vc: UIViewController!
                let vcCon = storyboard.instantiateViewController(withIdentifier: "DonationVC") as! DonationVC
                vc = UINavigationController(rootViewController: vcCon)
                appDelegateShared.parentCurrentVC = vcCon
                self.slideMenuController()?.changeMainViewController(vc, close: true)
                
            case "4":
                var vc: UIViewController!
                let vcCon = storyboard.instantiateViewController(withIdentifier: "ChatListVC") as! ChatListVC
                vc = UINavigationController(rootViewController: vcCon)
                appDelegateShared.parentCurrentVC = vcCon
                self.slideMenuController()?.changeMainViewController(vc, close: true)

            case "5":
                var vc: UIViewController!
                let vcCon = storyboard.instantiateViewController(withIdentifier: "HistoryVC") as! HistoryVC
                vc = UINavigationController(rootViewController: vcCon)
                self.slideMenuController()?.changeMainViewController(vc, close: true)
            
            case "6":
                var vc: UIViewController!
                let vcCon = storyboard.instantiateViewController(withIdentifier: "NewProfileVC") as! NewProfileVC
                vc = UINavigationController(rootViewController: vcCon)
                SlideMenuOptions.hideStatusBar = true
                appDelegateShared.parentCurrentVC = vcCon
                self.slideMenuController()?.changeMainViewController(vc, close: true)
           
            case "7":
                var vc: UIViewController!
                let vcCon = storyboard.instantiateViewController(withIdentifier: "NotificationVC") as! NotificationVC
                vc = UINavigationController(rootViewController: vcCon)
                self.slideMenuController()?.changeMainViewController(vc, close: true)
                
            case "8":
                var vc: UIViewController!
                let vcCon = storyboard.instantiateViewController(withIdentifier: "SettingScreenVC") as! SettingScreenVC
                vc = UINavigationController(rootViewController: vcCon)
                appDelegateShared.parentCurrentVC = vcCon
                self.slideMenuController()?.changeMainViewController(vc, close: true)
                
            case "9":
                var vc: UIViewController!
                let vcCon = storyboard.instantiateViewController(withIdentifier: "LanguageVC") as! LanguageVC
                vc = UINavigationController(rootViewController: vcCon)
                appDelegateShared.parentCurrentVC = vcCon
                self.slideMenuController()?.changeMainViewController(vc, close: true)
                
            case "10":
                var vc: UIViewController!
                let vcCon = storyboard.instantiateViewController(withIdentifier: "MapScreenVC") as! MapScreenVC
                vc = UINavigationController(rootViewController: vcCon)
                appDelegateShared.parentCurrentVC = vcCon
                self.slideMenuController()?.changeMainViewController(vc, close: true)
            
            case "11":
                print("Click on logout button")
                DispatchQueue.main.async {
                let uiAlert = UIAlertController(title: Shared().title, message: "LogoutMsg".localized, preferredStyle:.alert)
                let NoAlert = UIAlertAction(title: "No".localized, style: .default, handler: { action in })
                NoAlert.setValue(UIColor(named: "TextBorder"), forKey: "titleTextColor")
                uiAlert.addAction(NoAlert)
                
                let YesAlert = UIAlertAction(title: "Yes".localized, style: .default, handler: { action in
                    self.logOut()
                    
                })
                YesAlert.setValue(UIColor(named: "TextBorder"), forKey: "titleTextColor")
                uiAlert.addAction(YesAlert)
                
                
                self.present(uiAlert, animated: true, completion: nil)
                }
                
            case "13":
                var vc: UIViewController!
                let vcCon = storyboard.instantiateViewController(withIdentifier: "ChangePasscodeVC") as! ChangePasscodeVC
                vc = UINavigationController(rootViewController: vcCon)
                appDelegateShared.parentCurrentVC = vcCon
                self.slideMenuController()?.changeMainViewController(vc, close: true)
                
            case "14":
//                appDelegateShared.selectedIndexMenu = 3
                var vc: UIViewController!
                let vcCon = storyboardName.storyBoard_Chat.instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
                vc = UINavigationController(rootViewController: vcCon)
                appDelegateShared.parentCurrentVC = vcCon
                self.slideMenuController()?.changeMainViewController(vc, close: true)
                
            case "15":
                var vc: UIViewController!
                let vcCon = storyboard.instantiateViewController(withIdentifier: "AddNewClubVC") as! AddNewClubVC
                vcCon.isFromLogin = false
                vc = UINavigationController(rootViewController: vcCon)
                appDelegateShared.parentCurrentVC = vcCon
                self.slideMenuController()?.changeMainViewController(vc, close: true)
                
            case "16":
                print("Delete account tapped")
                DispatchQueue.main.async {
                let uiAlert = UIAlertController(title: Shared().title, message: "DeleteAccountMsg".localized, preferredStyle:.alert)
                let NoAlert = UIAlertAction(title: "No".localized, style: .default, handler: { action in })
                NoAlert.setValue(UIColor(named: "TextBorder"), forKey: "titleTextColor")
                uiAlert.addAction(NoAlert)
                
                let YesAlert = UIAlertAction(title: "Yes".localized, style: .default, handler: { action in
                    self.callAPIDeleteAccount()
                    
                })
                YesAlert.setValue(UIColor(named: "TextBorder"), forKey: "titleTextColor")
                uiAlert.addAction(YesAlert)
                
                
                self.present(uiAlert, animated: true, completion: nil)
                }
            case "17":  //Pre Registartaion
                let preRegStoryboard = UIStoryboard(name: "PreRegistration", bundle: nil)
                var vc: UIViewController!
                let vcCon = preRegStoryboard.instantiateViewController(withIdentifier: "PreRegistrationCodeVC") as! PreRegistrationCodeVC
                vc = UINavigationController(rootViewController: vcCon)
                appDelegateShared.parentCurrentVC = vcCon
                self.slideMenuController()?.changeMainViewController(vc, close: true)
            case "18":  //Pre Registartaion
                var vc: UIViewController!
                let vcCon = storyboardName.storyBoard_CCSMap.instantiateViewController(withIdentifier: "GoogleMapVc") as! GoogleMapVc
                vc = UINavigationController(rootViewController: vcCon)
                appDelegateShared.parentCurrentVC = vcCon
                self.slideMenuController()?.changeMainViewController(vc, close: true)
            default:
                print("Default Case selected")
                var vc: UIViewController!
                let vcCon = storyboard.instantiateViewController(withIdentifier: "MainMenuVC") as! MainMenuVC
                vc = UINavigationController(rootViewController: vcCon)
                appDelegateShared.parentCurrentVC = vcCon
                self.slideMenuController()?.changeMainViewController(vc, close: true)
            }
        } else{
            switch indexPath.row {
            case 0:
               //self.clearData()
               UserDefaults.standard.set("false", forKey: "addMemberAccount")
               var vc: UIViewController!
               let vcCon = storyboard.instantiateViewController(withIdentifier: "LoginScreenVC") as! LoginScreenVC
               vc = UINavigationController(rootViewController: vcCon)
               appDelegateShared.parentCurrentVC = vcCon
               self.slideMenuController()?.changeMainViewController(vc, close: true)
            default:
                let email=JSON(selectadIs["email"]!).stringValue
                let name=JSON(selectadIs["name"]!).stringValue
                let Name=JSON(selectadIs["Name"]!).stringValue
                let user_id=JSON(selectadIs["id"]!).stringValue
                let user_type=JSON(selectadIs["user_type"]!).stringValue
                let data:Data=selectadIs["img"] as! Data
                self.updateCartCount(email: email, name: name, user_id: user_id, data: data,Name: Name, user_type: user_type)
                /*self.deleteData(email: email, name: name, user_id: user_id, data: data,Name: Name, user_type: user_type)
                print("Default Case selected")
                var vc: UIViewController!
                let vcCon = storyboard.instantiateViewController(withIdentifier: "MainMenuVC") as! MainMenuVC
                vc = UINavigationController(rootViewController: vcCon)
                self.slideMenuController()?.changeMainViewController(vc, close: true)*/
            }
        }
    }
    
}
// MARK: - API CALL
//Switch Account API Call(Update Cart Count)
extension SlideMenuScreenVC{
    
    func updateCartCount(email:String,name:String,user_id:String,data:Data,Name:String,user_type:String){
        
        //startAnimating(CGSize(width: 100, height: 100), message: "", type: NVActivityIndicatorType.ballRotate, fadeInAnimation: nil)
        let parameters: Parameters = [
            "language" : "\(Language.language)",
            "club_name" : UserDefaults.standard.object(forKey: "club_name") as! String,
            "user_id" : user_id,
        ]
        
        print("\(Shared().webCall)userLoginSwitch?language=\(Language.language)&club_name=\(UserDefaults.standard.object(forKey: "club_name") as! String)&user_id=\(UserDefaults.standard.object(forKey: "user_id") as! String)")
        Alamofire.request("\(Shared().webCall)userLoginSwitch.php", method: .post, parameters: parameters)
            .responseJSON { response in
             //   let when = DispatchTime.now() + 0.1
//                DispatchQueue.main.asyncAfter(deadline: when) {
//                    self.stopAnimating(nil)
//                }
                
                switch response.result {
                case .success:
                    print("JSON::",response.result.value!)
                    // alert.dismiss(animated: true, completion: {
                    if let jsonData = response.result.value as? [String:Any] {
                        let flag = JSON(jsonData["flag"]!).stringValue
                        if flag == "1"{
                            print("=======user_type=====",user_type)
                            UserDefaults.standard.set(user_type, forKey: "check_adminLogin")
                            UserDefaults.standard.set(user_id, forKey: "user_id")
                            UserDefaults.standard.set(JSON(jsonData["cart_count"]!).stringValue, forKey: "Badge_cart_count")
                            self.deleteData(email: email, name: name, user_id: user_id, data: data,Name: Name, user_type: user_type)
                            NotificationCenter.default.post(name: Notification.Name("updateCartCount"), object: nil)
                            let storyboard = UIStoryboard(name: "Main", bundle: nil)
                            var vc: UIViewController!
                            let vcCon = storyboard.instantiateViewController(withIdentifier: "MainMenuVC") as! MainMenuVC
                            vc = UINavigationController(rootViewController: vcCon)
                            self.slideMenuController()?.changeMainViewController(vc, close: true)

                        } else{
                            let message : String = JSON(jsonData["message"]!).stringValue
                            Shared().showAlert(uIViewController: self, title: Shared().error, message: message)
                        }
                    }
                    // })
                    break
                    
                case .failure(let error):
                    //alert.dismiss(animated: true, completion: {
                    let errorCode = error._code
                    if(errorCode == -1001 || errorCode == -1005 || errorCode == -1009) {
                        Shared().showAlert(uIViewController: self, title: Shared().error, message: error.localizedDescription)
                    } else {
                        Shared().showAlert(uIViewController: self)
                    }
                    // })
                    print("Server:",error.localizedDescription)
                    break
                }
        }
        //})
    }
    
            @objc func setParticularIndex(_ notification: NSNotification) {
                if let name = notification.userInfo?["txt"] as? String {
                    for (indx,value) in listDictArr.enumerated(){
                        print(indx)
                        if value["txt"] as? String ?? "" == name{
                            appDelegateShared.selectedIndexMenu = indx
                            self.tableView.reloadData()
                        }
                    }
                }
                
            }
    @objc func callAPICheckUserStatus() {
        APIManager.callAPIRequest(Method: .post, url: "\(api_CheckUserStatus)", parameters: APIParam.checkUserStatus(club_name: UserDefaults.standard.object(forKey: "club_name") as? String ?? "", member_id: UserDefaults.standard.object(forKey: "member_id") as? String ?? "",language: "\(Language.language)").getParam(), headers: nil, showAlert: false, completion: { (jsonResult, msg) in
            logD(jsonResult)
            if jsonResult["flag"].stringValue == "1"{   // ~~~9S flag = 1 ==> for check Menu option allow to show/hide
                let data = jsonResult["data"]
                setToUserDefaultForKey((data["showmenu_option"].boolValue) as AnyObject, key: key_isMenuShow)
                setToUserDefaultForKey((data["dispensmenu_option"].boolValue) as AnyObject, key: key_isDispensShow)
                self.setupMenu()
            }else{      // ~~~9S flag = 0 ==> user is banned or deleted from the club
//                self.showAlert(title: "", message: jsonResult["message"].stringValue)
//                self.logOut()
                let uiAlert = UIAlertController(title: "", message: jsonResult["message"].stringValue , preferredStyle:.alert)
                self.present(uiAlert, animated: true, completion: nil)
                uiAlert.addAction(UIAlertAction(title: "Ok".localized, style: .default, handler: { action in
                    self.logOut()
                    uiAlert.dismiss(animated: true, completion: nil)
                }))
            }
                
        }) { (httpResponse, errorMsg) in
            //logD(httpResponse ?? "")
            //logD(errorMsg ?? "")
            self.showAlert(title: "", message: errorMsg)
        }
    }
    func callAPIDeleteAccount() {
        startAnimating(CGSize(width: 100, height: 100), message: "", type: NVActivityIndicatorType.ballRotate, fadeInAnimation: nil)
        APIManager.callAPIRequest(Method: .post, url: "\(api_DeleteUserAccount)", parameters: APIParam.deleteUserAccount(member_id: UserDefaults.standard.object(forKey: "member_id") as? String ?? "",language: "\(Language.language)").getParam(), headers: nil, showAlert: false, completion: { (jsonResult, msg) in
            logD(jsonResult)
            DispatchQueue.main.async {
                self.stopAnimating(nil)
            }
            if jsonResult["flag"].stringValue == "1"{
                let uiAlert = UIAlertController(title: "", message: jsonResult["message"].stringValue , preferredStyle:.alert)
                self.present(uiAlert, animated: true, completion: nil)
                uiAlert.addAction(UIAlertAction(title: "Ok".localized, style: .default, handler: { action in
                    self.logOut()
                    uiAlert.dismiss(animated: true, completion: nil)
                }))
            }else{
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

extension UIViewController {
   open func removeData(){
       FirebaseManager.sharedInstance.setUserIsOnlineGlobally(loginStatus: false)
        Shared().firebaseProcess(visibility:"LOGOUT")
        if getFromUserDefaultForKey(key_isRememberMe)?.boolValue == true {
            Shared().clearData()
        } else {
            Shared().clearData()
            UserDefaults.standard.removeObject(forKey: "email")
            removeFromUserDefaultForKey(key_Password)
            removeFromUserDefaultForKey(key_MyEmail)
            removeFromUserDefaultForKey(key_isRememberMe)
        }
        
       

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        
//        let appDelegate = UIApplication.shared.delegate as? AppDelegate
//        let initialViewController = storyboard.instantiateViewController(withIdentifier: "LoginScreenVC") as! LoginScreenVC
//        let leftViewController = storyboard.instantiateViewController(withIdentifier: "SlideMenuScreenVC") as! SlideMenuScreenVC
//        let nvc: UINavigationController = UINavigationController(rootViewController: initialViewController)
//
//        let slideMenuController = SlideMenuController(mainViewController: nvc,  leftMenuViewController: leftViewController)
//        slideMenuController.automaticallyAdjustsScrollViewInsets = true
//        appDelegate?.window?.backgroundColor = UIColor(red: 236.0, green: 238.0, blue: 241.0, alpha: 1.0)
//        appDelegate?.window?.rootViewController = slideMenuController
//        appDelegate?.window?.makeKeyAndVisible()
        SlideMenuOptions.contentViewScale = 1
        SlideMenuOptions.hideStatusBar = true
        SlideMenuOptions.simultaneousGestureRecognizers = false
        
        
        let SelectStepVC = storyboard.instantiateViewController(withIdentifier: "LoginScreenVC") as! LoginScreenVC
        let navigationController = UINavigationController()
        navigationController.viewControllers.append(SelectStepVC)
        UIApplication.shared.windows.first?.rootViewController = navigationController
        UIApplication.shared.windows.first?.makeKeyAndVisible()
    }
    
   open func logOut(){
       
        if let id = UserDefaults.standard.object(forKey: "user_id") as? String {
            appDelegateShared.selectedIndexMenu = 0
            appDelegateShared.isFromLogout = true
          //  let id=UserDefaults.standard.object(forKey: "user_id") as! String
            let appDelegate = UIApplication.shared.delegate as? AppDelegate
            let context = appDelegate!.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "FileStore")
            fetchRequest.predicate = NSPredicate(format: "user_id contains[c] %@", id)
            if let result = try? context.fetch(fetchRequest) {
                for object in result {
                    context.delete(object as! NSManagedObject)
                    try! context.save()
                }
            }
            self.removeData()
        } else {
            self.removeData()
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            SlideMenuOptions.contentViewScale = 1
            SlideMenuOptions.hideStatusBar = true
            SlideMenuOptions.simultaneousGestureRecognizers = false
            
            
            let SelectStepVC = storyboard.instantiateViewController(withIdentifier: "LoginScreenVC") as! LoginScreenVC
            let navigationController = UINavigationController()
            navigationController.viewControllers.append(SelectStepVC)
            UIApplication.shared.windows.first?.rootViewController = navigationController
            UIApplication.shared.windows.first?.makeKeyAndVisible()
        }
      
    }
}
