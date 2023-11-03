//
//  File.swift
//  CCSMembersApp
//
//  Created by Divvyesh on 27/06/23.
//  Copyright © 2023 Jaimin Patel. All rights reserved.
//

import Foundation
import UIKit

//extension Notification.Name{
//    static let sendLocation = Notification.Name("SendLocaiton")
//}

extension UIImage{
    enum JPEGQuality:CGFloat{
        case lowest = 0
        case low = 0.25
        case medium = 0.5
        case high = 0.75
        case highest = 1
    }
    
    func compressTo(_ quality: JPEGQuality)->Data?{
        let data:Data=self.jpegData(compressionQuality: quality.rawValue)!
        return data
    }
    
}

enum MessageOwner{
    case sender
    case reciever
}

enum MessageType{
    case text
}
