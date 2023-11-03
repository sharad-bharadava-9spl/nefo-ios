//
//  PreRegUploadPassportAndPhotosVC.swift
//  CCSMembersApp
//
//  Created by Divyesh Dabhi on 05/05/23.
//  Copyright © 2023 Jaimin Patel. All rights reserved.
//

import UIKit
import MobileCoreServices
import Photos
import NVActivityIndicatorView

class PreRegUploadPassportAndPhotosVC: UIViewController {

    @IBOutlet weak var lblPassportTitle: UILabel!
    @IBOutlet weak var btnPassport: UIButton!
    @IBOutlet weak var imgPassport: UIImageView!
    @IBOutlet weak var lblPhotoYourSelfTitle: UILabel!
    @IBOutlet weak var btnPhotoYourSelf: UIButton!
    @IBOutlet weak var imgPhotoYourSelf: UIImageView!
    
    @IBOutlet weak var btnSubmit: UIButton!
    
    var dataPassport = Data()
    var dataProfilePic = Data()
    
    var isClickOnTakePassportPhoto = false;
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }
    
    func setupUI(){
        self.setupLanguage()
        self.setupNavigationItem()
    }
    
    func setupNavigationItem(){
        self.title = "Pre_Registration".localized.uppercased()
        self.removeNavigationBarItem()
        self.navigationController?.navigationBar.tintColor = .white
       // self.setNavigationBarItem()
        self.setLeftAlignTitleView(font: UIFont(name: "ProductSans-Bold", size: 17)!, text: "Pre_Registration".localized, textColor: .white)
        
        
    }
    
    func setupLanguage(){
        self.btnSubmit.setTitle("SUBMIT".localized, for: .normal)
        self.btnPassport.setTitle("TAKE PHOTO / UPLOAD FILE".localized, for: .normal)
        self.btnPhotoYourSelf.setTitle("TAKE PHOTO / UPLOAD FILE".localized, for: .normal)
        
        self.lblPassportTitle.text = "DNI or Passport".localized
        self.lblPhotoYourSelfTitle.text = "Submit a photo of yourself".localized
    }

}

//MARK:  Extension for button clicked
extension PreRegUploadPassportAndPhotosVC{
    @IBAction func btnClicked(_ sender: UIButton) {
        self.view.endEditing(true)
        
        switch sender.tag{
        case 0:
            print("Upload Passport")
            DispatchQueue.main.async(execute: {
                self.openAlertForImage(isForPassport: true)
            })
            
        case 1:
            print("Upload Self Photo")
            DispatchQueue.main.async(execute: {
                self.openAlertForImage(isForPassport: false)
            })
            
        case 2:
            print("Submit clicked")
            
            if self.isValidate() {
                self.callAPIUploadPassport()
            }
            
            
        default:
            break;
        }
    }
    
    func openAlertForImage(isForPassport:Bool = false){
        self.isClickOnTakePassportPhoto = isForPassport
        let alert = UIAlertController(title: "", message: "title_select_options".localized, preferredStyle: .actionSheet)
        
            alert.addAction(UIAlertAction(title: "Camera", style: .default , handler:{ (UIAlertAction)in
                checkPermissionForMedia(attachmentTypeEnum: .camera, viewController: self)
            }))
            
            alert.addAction(UIAlertAction(title: "Photo Library", style: .default , handler:{ (UIAlertAction)in
                checkPermissionForMedia(attachmentTypeEnum: .photoLibrary, viewController: self)
            }))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:{ (UIAlertAction)in
                print("User click Dismiss button")
            }))

            
            //uncomment for iPad Support
            //alert.popoverPresentationController?.sourceView = self.view

            self.present(alert, animated: true, completion: {
                print("completion block")
            })
    }
    
    func isValidate () -> Bool {
        var isCompleted = true
        
        if self.dataPassport.count == 0{
            self.showAlert(title: "", message: "msg_err_upload_passport".localized)
            isCompleted = false
            
        }else if self.dataProfilePic.count == 0{
            self.showAlert(title: "", message: "msg_err_upload_profile".localized)
            isCompleted = false
            
        }
        return isCompleted
    }
}
//MARK: - ImagePicker Delegate
extension PreRegUploadPassportAndPhotosVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    //If user successfully picked images
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard info[UIImagePickerController.InfoKey.mediaType] != nil else {
            return
        }
        let mediaType = info[UIImagePickerController.InfoKey.mediaType] as! CFString
        
        if mediaType  == kUTTypeImage{
            let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
            let compressedData = selectedImage.jpegData(compressionQuality: 0.7)
            
            if self.isClickOnTakePassportPhoto{
                self.imgPassport.image = selectedImage
                self.dataPassport = compressedData ?? Data()
            }else{
                self.imgPhotoYourSelf.image = selectedImage
                self.dataProfilePic = compressedData ?? Data()
            }
            picker.dismiss(animated: true, completion: nil)
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    //If user cancelled image picker
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
        self.dismiss(animated: true, completion: nil)
    }
}
extension PreRegUploadPassportAndPhotosVC:NVActivityIndicatorViewable{
    func callAPIUploadPassport() {
        startAnimating(CGSize(width: 100, height: 100), message: "", type: NVActivityIndicatorType.ballRotate, fadeInAnimation: nil)
        
        APIManager.callAPIRequest(Method: .post, url: "\(api_PreRegUploadPassport)", parameters: APIParam.PreRegUploadImage(image: self.dataPassport.base64EncodedString()).getParam(), headers: nil, showAlert: false, completion: { (jsonResult, msg) in
           
            if jsonResult["flag"].stringValue == "1"{
                self.callAPIUploadProfileImage()
            }else{
                DispatchQueue.main.asyncAfter(deadline: .now()) {
                    self.stopAnimating(nil)
                }
                self.showAlert(title: "Error".localized, message: jsonResult["message"].stringValue)
            }
            
        }) { (httpResponse, errorMsg) in
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                self.stopAnimating(nil)
            }
            self.showAlert(title: "Error".localized, message: errorMsg)
        }
    }
    func callAPIUploadProfileImage() {
        startAnimating(CGSize(width: 100, height: 100), message: "", type: NVActivityIndicatorType.ballRotate, fadeInAnimation: nil)
        
        APIManager.callAPIRequest(Method: .post, url: "\(api_PreRegUploadProfileImage)", parameters: APIParam.PreRegUploadImage(image: self.dataProfilePic.base64EncodedString()).getParam(), headers: nil, showAlert: false, completion: { (jsonResult, msg) in
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                self.stopAnimating(nil)
            }
            if jsonResult["flag"].stringValue == "1"{
                let vc = storyboardName.storyBoard_PreRegistration.instantiateViewController(withIdentifier: "PreRegUserDetailsVC") as! PreRegUserDetailsVC
                self.navigationController?.pushViewController(vc, animated: true)
            }else{
                self.showAlert(title: "Error".localized, message: jsonResult["message"].stringValue)
            }
            
        }) { (httpResponse, errorMsg) in
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                self.stopAnimating(nil)
            }
            self.showAlert(title: "Error".localized, message: errorMsg)
        }
    }
}
