//
//  Localizable.swift
//  CCSMembersApp
//
//  Created by Jaimin Patel on 6/12/19.
//  Copyright © 2019 Jaimin Patel. All rights reserved.
//

import UIKit

private let appleLanguagesKey = "AppleLanguages"
enum Language: String {
    
    case en = "en" //English
    case es = "es" //spanis
    
    static var language: Language {
        get {
            if let languageCode = UserDefaults.standard.string(forKey: appleLanguagesKey),
                let language = Language(rawValue: languageCode) {
                return language
            } else {
                let preferredLanguage = NSLocale.preferredLanguages[0] as String
                let index = preferredLanguage.index(
                    preferredLanguage.startIndex,
                    offsetBy: 2
                )
                guard let localization = Language(
                    rawValue: preferredLanguage.substring(to: index)
                    ) else {
                        return Language.en
                }
                
                return localization
            }
        }
        set {
            guard language != newValue else {
                return
            }
            
            //change language in the app
            //the language will be changed after restart
            UserDefaults.standard.set([newValue.rawValue], forKey: appleLanguagesKey)
            UserDefaults.standard.synchronize()
        }
    }
}


extension String {
    
    var localized: String {
        return Bundle.localizedBundle.localizedString(forKey: self, value: nil, table: nil)
    }
    
    var localizedImage: UIImage? {
        return localizedImage()
            ?? localizedImage(type: ".png")
            ?? localizedImage(type: ".jpg")
            ?? localizedImage(type: ".jpeg")
            ?? UIImage(named: self)
    }
    
    private func localizedImage(type: String = "") -> UIImage? {
        guard let imagePath = Bundle.localizedBundle.path(forResource: self, ofType: type) else {
            return nil
        }
        return UIImage(contentsOfFile: imagePath)
    }
}

extension Bundle {
    //Here magic happens
    //when you localize resources: for instance Localizable.strings, images
    //it creates different bundles
    //we take appropriate bundle according to language
    static var localizedBundle: Bundle {
        let languageCode = Language.language.rawValue
        guard let path = Bundle.main.path(forResource: languageCode, ofType: "lproj") else {
            return Bundle.main
        }
        return Bundle(path: path)!
    }
}

