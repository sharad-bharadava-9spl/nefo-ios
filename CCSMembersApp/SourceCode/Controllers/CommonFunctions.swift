//
//  CommonFunctions.swift
//  CCSMembersApp
//
//  Created by Vishnu Chippa on 11/04/22.
//  Copyright © 2022 Jaimin Patel. All rights reserved.
//

import Foundation
import UIKit

class CommonFunctions: NSObject {
    //Mark: - Navigation bar methods
    static func setLeftBarButtonItemWith(image: UIImage, action: Selector, view: UIViewController)  {
        let barButton1 : UIBarButtonItem = UIBarButtonItem.init(image: image, style: UIBarButtonItem.Style.plain, target: view, action: action)
        view.navigationItem.leftBarButtonItems = [barButton1]
    }
}

extension UITextField{
    func setPlaceholder(txt:String,color:UIColor){
        self.attributedPlaceholder = NSAttributedString(
            string: txt,
            attributes: [NSAttributedString.Key.foregroundColor: color]
        )
    }
}


extension String {
    func capitalizingFirstLetter() -> String {
      return prefix(1).uppercased() + self.lowercased().dropFirst()
    }

    mutating func capitalizeFirstLetter() {
      self = self.capitalizingFirstLetter()
    }
}
extension UIColor{
    static var ThemDarkGreen : UIColor{
        return UIColor(named: "ThemDarkGreen") ?? UIColor.white
    }
    
    static var ColorTitle : UIColor{
        return UIColor(named: "ColorTitle") ?? UIColor.white
    }
    
    static var ViewBG : UIColor{
        return UIColor(named: "ViewBG") ?? UIColor.white
    }
    
    static var addToCartView : UIColor{
        return UIColor(named: "addToCartView") ?? UIColor.white
    }
    
    static var CommonText : UIColor{
        return UIColor(named: "CommonText") ?? UIColor.white
    }
    
    static var ColorThemeRed : UIColor{
        return UIColor(named: "ColorThemeRed") ?? UIColor.white
    }
    
    static var ColorYellow : UIColor{
        return UIColor(named: "ColorYellow") ?? UIColor.white
    }
    
    static var ColorfillBlue : UIColor{
        return UIColor(named: "ColorfillBlue") ?? UIColor.white
    }
    
}

let appDelegateShared = UIApplication.shared.delegate as! AppDelegate

extension UIImage {
    func tinted(with color: UIColor, isOpaque: Bool = false) -> UIImage? {
        let format = imageRendererFormat
        format.opaque = isOpaque
        return UIGraphicsImageRenderer(size: size, format: format).image { _ in
            color.set()
            withRenderingMode(.alwaysTemplate).draw(at: .zero)
        }
    }
}

extension UIView{
    
    func roundView(borderWidth : Double = 1 , borderColor : UIColor = .gray){
        self.layer.cornerRadius = self.frame.size.height/2
        self.layer.borderWidth = borderWidth
        self.layer.borderColor = borderColor.cgColor
        self.clipsToBounds = true
    }
}







class setCustomFont
{
    class func MontserratMediumWith(size:Double) -> UIFont{
        return UIFont(name: "Montserrat_Medium".localized, size: CGFloat(size)) ??  UIFont.systemFont(ofSize: 16, weight: .regular)
        
    }
    class func MontserratBoldWith(size:Double) -> UIFont{
        return UIFont(name: "Montserrat_Bold".localized, size: CGFloat(size)) ??  UIFont.systemFont(ofSize: 16, weight: .regular)
        
    }
    class func MontserratSemiBoldWith(size:Double) -> UIFont{
        return UIFont(name: "Montserrat_SemiBold".localized, size: CGFloat(size)) ??  UIFont.systemFont(ofSize: 16, weight: .regular)
        
    }
    class func KarlaBoldWith(size:Double) -> UIFont{
        return UIFont(name: "Karla-Regular_Bold".localized, size: CGFloat(size)) ??  UIFont.systemFont(ofSize: 18, weight: .regular)
        
    }
 
}
extension UIFont {
  func withWeight(_ weight: UIFont.Weight) -> UIFont {
    let newDescriptor = fontDescriptor.addingAttributes([.traits: [
      UIFontDescriptor.TraitKey.weight: weight]
    ])
    return UIFont(descriptor: newDescriptor, size: pointSize)
  }
}


class Helper: NSObject {
    static func convertDate(_ date: String) -> String
    {
        if date.isEmpty{
            return ""
        }
        let dateFormatterHH = DateFormatter()
        if "\(Language.language)" == "en"{
            let loc = Locale(identifier: "us") //Locale.init(identifier: "us")
            dateFormatterHH.locale = loc
        }else{
            let loc = Locale(identifier: "es")
            dateFormatterHH.locale = loc
        }
        dateFormatterHH.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = dateFormatterHH.date(from: date)!
        
        dateFormatterHH.dateFormat = "MMM yyyy"
        return dateFormatterHH.string(from: date)
        
    }
}
extension UIViewController {
    func popupAlert(title: String?, message: String?, actionTitles:[String?], actions:[((UIAlertAction) -> Void)?]) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        for (index, title) in actionTitles.enumerated() {
            let action = UIAlertAction(title: title, style: .default, handler: actions[index])
            alert.addAction(action)
        }
        self.present(alert, animated: true, completion: nil)
    }
}
