//
//  gramEuro.swift
//  CCSMembersApp
//
//  Created by Jaimin Patel on 7/2/19.
//  Copyright © 2019 Jaimin Patel. All rights reserved.
//

import Foundation
import UIKit

@objc protocol gramEuro{
    @objc optional func selectedGrm(sender:Int,txtEuro:String,txtGrm:String)
}

@objc protocol setting{
    @objc optional func deleteMacText(sender:Int,txtMac:String)
}
