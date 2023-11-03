//
//  hexcolor.swift
//  CCSMembersApp
//
//  Created by Apple on 19/07/22.
//  Copyright © 2022 Jaimin Patel. All rights reserved.
//

import Foundation
import UIKit
import DropDown

extension UIColor {
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt64()
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}

extension UIView {
   func roundCorners(corners: UIRectCorner, radius: CGFloat) {
       DispatchQueue.main.async { [self] in
           let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
           let mask = CAShapeLayer()
           mask.path = path.cgPath
           layer.mask = mask
       }
    }
}

extension UITableView {
    func updateHeaderViewHeight() {
        if let header = self.tableHeaderView {
            let newSize = header.systemLayoutSizeFitting(CGSize(width: self.bounds.width, height: 0))
            header.frame.size.height = newSize.height
        }
    }
}

extension UIViewController {
  func setdropdown(vw: UIView, dataSource: [String], dropDown: DropDown){
        dropDown.anchorView = vw
        dropDown.dataSource =   dataSource
        dropDown.width = vw.frame.width
        let appearance = DropDown.appearance()
       // appearance.backgroundColor = Color_lightGray
        appearance.cellHeight = 44
        appearance.separatorColor = .lightGray
        appearance.textColor = .black
     appearance.selectionBackgroundColor = .white
        dropDown.direction = .any
       // dropDown.topOffset = CGPoint(x: 0, y:-(dropDown.anchorView?.plainView.bounds.height ?? 0))
        dropDown.bottomOffset = CGPoint(x: 0, y:(dropDown.anchorView?.plainView.bounds.height) ?? 0 )
    }
}

