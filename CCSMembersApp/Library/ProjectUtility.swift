//
//  CommonExtension.swift
//  CCSMembersApp
//
//  Created by Divyesh Dabhi on 05/05/23.
//  Copyright © 2023 Jaimin Patel. All rights reserved.
//

import Foundation
import UIKit
import Photos
import MobileCoreServices

class MyDatePicker: UIView {
    
    var isShowTime = false
    var isShowFutureDate = true
    var minimumDate : Date? = nil
    var maximumDate : Date? = nil
    var changeClosure: ((Date)->())?
    
    var dismissClosure: (()->())?
    var selectedDate : Date? = nil
    let dPicker: UIDatePicker = {
        let v = UIDatePicker()
        if "\(Language.language)" == "en"{
            let loc = Locale.init(identifier: "us")
            v.locale = loc
        }else{
            let loc = Locale.init(identifier: "es")
            v.locale = loc
        }
        //let loc = Locale.init(identifier: "us")
        //v.locale = loc
        return v
    }()
    let doneButton: UIButton = {
        let v = UIButton()
        return v
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    func commonInit() -> Void {
        let blurEffect = UIBlurEffect(style: .dark)
        let blurredEffectView = UIVisualEffectView(effect: blurEffect)

        let pickerHolderView: UIView = {
            let v = UIView()
            v.backgroundColor = .white
            v.layer.cornerRadius = 8
            return v
        }()
        
        [blurredEffectView, pickerHolderView, dPicker,self.doneButton].forEach { v in
            v.translatesAutoresizingMaskIntoConstraints = false
        }

        addSubview(blurredEffectView)
        pickerHolderView.addSubview(self.doneButton)
        pickerHolderView.addSubview(dPicker)
        addSubview(pickerHolderView)
        
        
        NSLayoutConstraint.activate([
            
            blurredEffectView.topAnchor.constraint(equalTo: topAnchor),
            blurredEffectView.leadingAnchor.constraint(equalTo: leadingAnchor),
            blurredEffectView.trailingAnchor.constraint(equalTo: trailingAnchor),
            blurredEffectView.bottomAnchor.constraint(equalTo: bottomAnchor),

            pickerHolderView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20.0),
            pickerHolderView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20.0),
            pickerHolderView.centerYAnchor.constraint(equalTo: centerYAnchor),

            dPicker.topAnchor.constraint(equalTo: pickerHolderView.topAnchor, constant: 20.0),
            dPicker.leadingAnchor.constraint(equalTo: pickerHolderView.leadingAnchor, constant: 20.0),
            dPicker.trailingAnchor.constraint(equalTo: pickerHolderView.trailingAnchor, constant: -20.0),
            dPicker.bottomAnchor.constraint(equalTo: pickerHolderView.bottomAnchor, constant: -40.0),
            
            
            doneButton.trailingAnchor.constraint(equalTo: pickerHolderView.trailingAnchor, constant: -20.0),
            doneButton.bottomAnchor.constraint(equalTo: pickerHolderView.bottomAnchor, constant: -8.0),
            doneButton.heightAnchor.constraint(equalToConstant: 40.0),
            doneButton.widthAnchor.constraint(equalToConstant: 70.0)
            

        ])
        
        if #available(iOS 14.0, *) {
            dPicker.preferredDatePickerStyle = .inline
        } else {
            // use default
        }
        
        self.setButton()
        dPicker.datePickerMode = isShowTime ? .dateAndTime : .date
        //dPicker.minimumDate = isShowFutureDate ? .none : Date()
        if minimumDate != nil {
            dPicker.minimumDate = minimumDate
        }
        if maximumDate != nil {
            dPicker.maximumDate = maximumDate
        }
        dPicker.addTarget(self, action: #selector(didChangeDate(_:)), for: .valueChanged)
        
        let t = UITapGestureRecognizer(target: self, action: #selector(tapHandler(_:)))
        blurredEffectView.addGestureRecognizer(t)
    }
    private func setButton(){
        doneButton.setTitle("Done".localized, for: .normal)
        doneButton.setTitleColor(.blue, for: .normal)
        //doneButton.anchor(top: self.view.topAnchor, left: self.view.leftAnchor, bottom: self.view.bottomAnchor, right: self.view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)

        doneButton.addTarget(self, action: #selector(doneClicked), for: .touchUpInside)
    }
    
    @objc func tapHandler(_ g: UITapGestureRecognizer) -> Void {
        dismissClosure?()
    }
    
    @objc func didChangeDate(_ sender: UIDatePicker) -> Void {
        self.selectedDate = sender.date
        changeClosure?(sender.date)
    }
    @objc func doneClicked(){
        changeClosure?(self.selectedDate ?? Date())
        dismissClosure?()
    }
    
    
}

//MARK:- Function to check authorisation of different types of pickers


func checkPermissionForMedia(attachmentTypeEnum: AttachmentType, viewController: UIViewController) {
    let authStatus = AVCaptureDevice.authorizationStatus(for: .video)
    if attachmentTypeEnum == AttachmentType.camera {
        if AVCaptureDevice.authorizationStatus(for: .video) ==  AVAuthorizationStatus.authorized {
            // Already Authorized
            /*if attachmentTypeEnum == AttachmentType.camera {
                self.showCamera()
            }
            if attachmentTypeEnum == AttachmentType.photoLibrary {
                self.showPhotoGallery()
            }*/
            DispatchQueue.main.async(execute: {
                showCamera(viewController: viewController)
            })
        } else {
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { (granted: Bool) -> Void in
               if granted == true {
                   // User granted
                    /*if attachmentTypeEnum == AttachmentType.camera {
                        self.showCamera()
                    }
                    if attachmentTypeEnum == AttachmentType.photoLibrary {
                        self.showPhotoGallery()
                    }*/
                   DispatchQueue.main.async(execute: {
                       showCamera(viewController: viewController)
                   })
               } else {
                   // User rejected
                //self.addAlertForSettings(attachmentTypeEnum)
               }
           })
        }
    }else{
        authorisationStatus(attachmentTypeEnum: attachmentTypeEnum,viewController:viewController)
    }
}


func authorisationStatus(attachmentTypeEnum: AttachmentType, viewController: UIViewController){
    let status = PHPhotoLibrary.authorizationStatus()
    if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
        switch status {
        case .authorized:
            if attachmentTypeEnum == AttachmentType.camera {
                DispatchQueue.main.async(execute: {
                    showCamera(viewController: viewController)
                })
                
            }
            if attachmentTypeEnum == AttachmentType.photoLibrary {
                DispatchQueue.main.async(execute: {
                    showPhotoGallery(viewController: viewController)
                })
                
            }
        case .denied:
            print("permission denied")
        //self.addAlertForSettings(attachmentTypeEnum)
        case .notDetermined:
            print("Permission Not Determined")
            PHPhotoLibrary.requestAuthorization({ (status) in
                if status == PHAuthorizationStatus.authorized {
                    // photo library access given
                    print("access given")
                    if attachmentTypeEnum == AttachmentType.camera {
                        DispatchQueue.main.async(execute: {
                            showCamera(viewController: viewController)
                        })
                    }
                    if attachmentTypeEnum == AttachmentType.photoLibrary {
                        DispatchQueue.main.async(execute: {
                            showPhotoGallery(viewController: viewController)
                        })
                    }
                }else {
                    print("restriced manually")
                    //self.addAlertForSettings(attachmentTypeEnum)
                }
            })
        case .restricted:
            print("permission restricted")
        default:
            break
        }
    }else if UIImagePickerController.isSourceTypeAvailable(.camera) {
        switch status {
        case .authorized:
            if attachmentTypeEnum == AttachmentType.camera {
                DispatchQueue.main.async(execute: {
                    showCamera(viewController: viewController)
                })
                
            }
            if attachmentTypeEnum == AttachmentType.photoLibrary {
                DispatchQueue.main.async(execute: {
                    showPhotoGallery(viewController: viewController)
                })
                
            }
        case .denied:
            print("permission denied")
        //self.addAlertForSettings(attachmentTypeEnum)
        case .notDetermined:
            print("Permission Not Determined")
            PHPhotoLibrary.requestAuthorization({ (status) in
                if status == PHAuthorizationStatus.authorized {
                    // photo library access given
                    print("access given")
                    if attachmentTypeEnum == AttachmentType.camera {
                        DispatchQueue.main.async(execute: {
                            showCamera(viewController: viewController)
                        })
                    }
                    if attachmentTypeEnum == AttachmentType.photoLibrary {
                        DispatchQueue.main.async(execute: {
                            showPhotoGallery(viewController: viewController)
                        })
                    }
                }else {
                    print("restriced manually")
                    //self.addAlertForSettings(attachmentTypeEnum)
                }
            })
        case .restricted:
            print("permission restricted")
        default:
            break
        }
    }
    
}

//Function to show photo gallery
func showPhotoGallery(viewController: UIViewController) {
    var imagePicker = UIImagePickerController()
    imagePicker.delegate = viewController as! UIImagePickerControllerDelegate & UINavigationControllerDelegate
    imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
    imagePicker.mediaTypes = [(kUTTypeImage as NSString) as String]
    viewController.present(imagePicker, animated: true, completion: nil)
}

//Function to open phone's camera
func showCamera(viewController: UIViewController) {
    var imagePicker = UIImagePickerController()
    imagePicker.delegate = viewController as! UIImagePickerControllerDelegate & UINavigationControllerDelegate
    if(UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera)) {
        imagePicker.sourceType = UIImagePickerController.SourceType.camera
        imagePicker.mediaTypes = [(kUTTypeImage as NSString) as String]
        viewController.present(imagePicker, animated: true, completion: nil)
    }
}


extension String {
    func isValidEmail() -> Bool {
        // here, `try!` will always succeed because the pattern is valid
        let regex = try! NSRegularExpression(pattern: "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$", options: .caseInsensitive)
        return regex.firstMatch(in: self, options: [], range: NSRange(location: 0, length: count)) != nil
    }
}
