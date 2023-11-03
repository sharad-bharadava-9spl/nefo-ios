//
//  CreateNewClubVC.swift
//  CCSMembersApp
//
//  Created by Vishnu Chippa on 11/04/22.
//  Copyright © 2022 Jaimin Patel. All rights reserved.
//

import UIKit
import UIKit
import SlideMenuControllerSwift
import ActionSheetPicker_3_0
import NVActivityIndicatorView
import Alamofire
import SwiftyJSON
import CoreData
import Firebase

class CreateNewClubVC: UIViewController, NVActivityIndicatorViewable {
    
    @IBOutlet weak var txtCOde: UITextField!
    @IBOutlet weak var btnAddNew: UIButton!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblError: UILabel!
    
    @IBOutlet weak var errView: UIControl!
    @IBOutlet weak var errtxt: UILabel!


    var item1:UIBarButtonItem?

    var selectedIndex :Int = -1
    var clubListing=[clubList]()
    var selectedClub : clubList?
    var clubfilteredData=[clubList]()
    var backBtn:String=""
    var item2:UIBarButtonItem?
    var completionHandler: ((_ message: String) -> ())?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        btnAddNew.setTitle("Confirm".localized, for: .normal)
        btnAddNew.titleLabel?.font = setCustomFont.MontserratSemiBoldWith(size: 16.0).withWeight(UIFont.Weight(600))
        lblTitle.text = "Enter_Code".localized
        
        self.title = "Add_New".localized.uppercased()
        self.removeNavigationBarItem()
        self.navigationController?.navigationBar.tintColor = .white
       // self.setNavigationBarItem()
        self.setLeftAlignTitleView(font: UIFont(name: "ProductSans-Bold", size: 17)!, text: "Add_New".localized.capitalized, textColor: .white)
        var imageNotification = Shared().imageWithImage(image: UIImage(named: "Notification_icon")!, scaledToSize: CGSize(width: 23, height: 23))
        imageNotification = imageNotification.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        
      
        
        let btn2 = UIButton(type: .custom)
        btn2.setImage(imageNotification, for: .normal)
        btn2.frame = CGRect(x: 0, y: 0, width: 28, height: 28)
        btn2.addTarget(self, action: #selector(self.notificationScreenRedirection), for: .touchUpInside)
        item2 = UIBarButtonItem(customView: btn2)
        item2?.removeBadge()
        self.navigationItem.setRightBarButtonItems([item2!], animated: true)
        btn2.isHidden = true
        //CommonFunctions.setLeftBarButtonItemWith(image: #imageLiteral(resourceName: "BackArrow"), action: #selector(backButtonAction), view: self)

        txtCOde.setPlaceholder(txt: "Insert_code_here".localized, color: UIColor.ColorTitle)
        lblError.isHidden = true
        txtCOde.delegate = self
        
        self.txtCOde.autocapitalizationType = .allCharacters
        txtCOde.keyboardType = .asciiCapable
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView=false
        self.view.addGestureRecognizer(tap)
        
        let flexible = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: self, action: nil)
        let toolbarDone = UIToolbar.init()
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done".localized, style: .done, target: self, action: #selector(dismissKeyboard))//UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissKeyboard))
        toolbarDone.sizeToFit()
        toolbarDone.items =  [flexible,done]


    }
    
    @IBAction func hidepop(_ sender: UIControl){
        self.navigationController?.popViewController(animated: true)
        self.errView.isHidden = true
    }
    
    @objc func notificationScreenRedirection(){
        let storyBoard=UIStoryboard(name: "Main", bundle: nil)
        let vc=storyBoard.instantiateViewController(withIdentifier: "NotificationVC") as! NotificationVC
        let navVC=UINavigationController(rootViewController: vc)
        self.slideMenuController()?.changeMainViewController(navVC, close: true)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
        self.view.resignFirstResponder()
    }
    
    
    @objc func keyboardWillShow(notification: NSNotification) {
       
        let userInfo: NSDictionary = notification.userInfo! as NSDictionary
        let keyboardInfo = userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue
        let keyboardSize = keyboardInfo.cgRectValue.size
        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height+20, right: 0)
      
    }
    @objc func keyboardWillHide(notification: NSNotification) {
       
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }

    
    @objc func cartRedirection(){
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "CartScreenVC") as! CartScreenVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
  
    @IBAction func btnAddNew(sender:UIButton){
        if (txtCOde.text ?? "").isEmpty{
            lblError.text = "error_add_new_club".localized
            lblError.isHidden = false
            return
        }
        
        
        print(true)
        addNewClub()
    }
    
    @objc func backButtonAction(){
        self.navigationController?.popViewController(animated: true)
    }
    
   

    
    func addNewClub(){
        var member_id: String = String()
        var club_code: String = txtCOde.text ?? ""
        if let memberId : String = UserDefaults.standard.object(forKey: "member_id") as? String {
            member_id = memberId
        }
        if club_code == "" {
        Shared().showAlert(uIViewController: self, title: Shared().error, message: "Please add code received from your club".localized)
        }
        addclubApi(member_id: member_id, club_code: club_code)
    }
    
    func addclubApi(member_id: String,club_code: String){
        startAnimating(CGSize(width: 100, height: 100), message: "", type: NVActivityIndicatorType.ballRotate, fadeInAnimation: nil)
        
        //  let clubData=self.clubListing[selectedIndex]
        
        let parameters: Parameters = [
            "language" : "\(Language.language)",
            "member_id" : member_id,
            "club_code" : club_code
        ]
        print("parameters: ", parameters)
        
        Alamofire.request("\(Shared().webCall)addClubMember.php", method: .post, parameters: parameters)
            .responseJSON { response in
                let when = DispatchTime.now()
                DispatchQueue.main.asyncAfter(deadline: when) {
                    self.stopAnimating(nil)
                }
                
                switch response.result {
                case .success:
                    print("JSON::",response.result.value!)
                    // alert.dismiss(animated: true, completion: {
                    if let jsonData = response.result.value as? [String:Any] {
                        let flag = JSON(jsonData["flag"]!).stringValue
                        if flag == "1"{
//                            if let jsonDict = jsonData["data"] as? [String:Any]{
//                            }
                            let message : String = JSON(jsonData["message"]!).stringValue
//                            self.errView.isHidden = false
//                            self.errtxt.text = message
                            self.navigationController?.popViewController(animated: true)
                            self.completionHandler?(message)

                        } else{
                            let message : String = JSON(jsonData["message"]!).stringValue
                            Shared().showAlert(uIViewController: self, title: Shared().error, message: message)
//                            self.errView.isHidden = false
//                            self.errtxt.text = message
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

    
    
}
extension CreateNewClubVC: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let validString = CharacterSet(charactersIn: " !@#$%^&*()_+{}[]|\"<>,.~`/:;?-=\\¥'£•¢")

        if (textField.textInputMode?.primaryLanguage == "emoji") || textField.textInputMode?.primaryLanguage == nil {
            return false
        }
        if let range = string.rangeOfCharacter(from: validString)
        {
           
            return false
        }

        
        
        if let text = textField.text,
           let textRange = Range(range, in: text) {
           let updatedText = text.replacingCharacters(in: textRange,
                                                       with: string)
            lblError.isHidden = true
            textField.text = (textField.text! as NSString).replacingCharacters(in: range, with: string.uppercased())
            return false
        }
        return true
    }

}

