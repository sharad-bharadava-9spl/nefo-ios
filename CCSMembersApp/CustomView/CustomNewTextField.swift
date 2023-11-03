//
//  CustomTextField.swift
//  CCSMembersApp
//
//  Created by Apple on 12/04/22.
//  Copyright © 2022 Jaimin Patel. All rights reserved.
//

import UIKit

class CustomNewTextField: UIView {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var txtView: UIView!
    
    var leftImage: UIImage? {
        didSet {
            self.imageView.image = leftImage
            self.imageView.isHidden = false
        }
    }
    
    var errorMessage: String? {
        didSet {
            self.updateTextfield()
        }
    }
    var placeholderMessage: String? {
        didSet {
            self.updateTextfield()
        }
    }
    var text: String? {
        textField.text
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
   
    
    deinit {
         NotificationCenter.default.removeObserver(self)
       }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        let name = String(describing: type(of: self))
        let nib = UINib(nibName: name, bundle: .main)
        nib.instantiate(withOwner: self, options: nil)
        self.addSubview(self.containerView)
        self.containerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.containerView.topAnchor.constraint(equalTo: self.topAnchor),
            self.containerView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            self.containerView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.containerView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
        ])
        
        //self.setToolBar()
        //NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(sender:)), name: UIResponder.keyboardWillShowNotification, object: nil);
        //NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(sender:)), name: UIResponder.keyboardWillHideNotification, object: nil);

//        NotificationCenter.default.addObserver(self,
//               selector: #selector(self.keyboardNotification(notification:)),
//               name: UIResponder.keyboardWillChangeFrameNotification,
//               object: nil)
      
    }
    func updateTextfield() {
        self.errorLabel.text = errorMessage
        self.errorLabel.textColor = errorMessage?.isEmpty == true ? .white : Shared().hexStringToUIColor("#EBEDEF")
        self.lblTitle.text = placeholderMessage
    }
    
    @objc func keyboardWillShow(sender: NSNotification) {
         self.frame.origin.y = -150 // Move view 150 points upward
    }

    @objc func keyboardWillHide(sender: NSNotification) {
         self.frame.origin.y = 0 // Move view to original position
    }
    
//    @objc func keyboardNotification(notification: NSNotification) {
//         guard let userInfo = notification.userInfo else { return }
//
//         let endFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
//         let endFrameY = endFrame?.origin.y ?? 0
//         let duration:TimeInterval = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
//         let animationCurveRawNSN = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber
//         let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIView.AnimationOptions.curveEaseInOut.rawValue
//         let animationCurve:UIView.AnimationOptions = UIView.AnimationOptions(rawValue: animationCurveRaw)
//
//         if endFrameY >= UIScreen.main.bounds.size.height {
//           self.keyboardHeightLayoutConstraint?.constant = 0.0
//         } else {
//           self.keyboardHeightLayoutConstraint?.constant = endFrame?.size.height ?? 0.0
//         }
//
//         UIView.animate(
//           withDuration: duration,
//           delay: TimeInterval(0),
//           options: animationCurve,
//           animations: { self.view.layoutIfNeeded() },
//           completion: nil)
//       }
    
    private func setToolBar(){
//        let flexible = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: self, action: nil)
//        let toolbarDone = UIToolbar.init()
//        let done: UIBarButtonItem = UIBarButtonItem(title: "Done".localized, style: .done, target: self, action: #selector(dismissKeyboard))//UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissKeyboard))
//        toolbarDone.sizeToFit()
//        toolbarDone.items =  [flexible,done]
        
        
        
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor(red: 76/255, green: 217/255, blue: 100/255, alpha: 1)
        toolBar.sizeToFit()
        
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.done, target: self, action: #selector(self.donePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        doneButton.tintColor = .black
        toolBar.setItems([spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        
        self.textField.inputAccessoryView = toolBar
    }
    @objc func donePicker() {
        self.endEditing(true)
        //self.view.resignFirstResponder()
    }
}
