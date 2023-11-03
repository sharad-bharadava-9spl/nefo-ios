//
//  ModelClass.swift
//  CCSMembersApp
//
//  Created by Jaimin Patel on 6/10/19.
//  Copyright © 2019 Jaimin Patel. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

struct categoryStruct{
    static var categoryDict:[String:Any]?
    static var categoryID:String?
    static var categoryIndex:String?
}

class clubList{
    var club_email=String()
    var club_name=String()
    var user_id=String()
    var member_no=String()
    var login_code=String()
    var club_code=String()
    var club_approve=String()
    var club_country=String()
    var club_state=String()
    var club_registeredDate=String()
    var usergroup = String()
    var club_address = String()
    var city = String()
    var shortName = String()
    var unread_count = String()
    var club_user_id = String()
    var qr_code = String()
    
    
    init(json:JSON) {
        self.club_email=json["email"].stringValue
        self.club_name=json["club_name"].stringValue
        self.user_id=json["user_id"].stringValue
        self.member_no=json["member_no"].stringValue
        self.login_code=json["login_code"].stringValue
        self.club_code=json["club_code"].stringValue
        self.club_approve=json["club_approve"].stringValue
        self.club_country=json["country"].stringValue
        self.club_state=json["state"].stringValue
        self.club_registeredDate=json["registeredSince"].stringValue
        self.usergroup = json["usergroup"].stringValue
        self.club_address = json["club_address"].stringValue
        self.city = json["city"].stringValue
        self.shortName = json["shortName"].stringValue
        self.unread_count = json["unread_count"].stringValue
        self.club_user_id = json["club_user_id"].stringValue
        self.qr_code = json["qr_code"].stringValue
    }
}

class HomeCategoryList{
    var add_cart=String()
    var breed2=String()
    var category_id=String()
    var category_name=String()
    var category_type=String()
    var flower_type=String()
    var grow_type=String()
    var percentageDisplay=String()
    var product_description=String()
    var product_id=String()
    var product_image=String()
    var product_medicaldescription=String()
    var product_name=String()
    var purchase_id=String()
    var realquantity=String()
    var sales_price=String()
    var plusIconImg=String()
    var extra_price_count=String()
    var extra_price=String()
    var product_price=String()
    var is_discount=String()
    var user_discount=String()
    var extract_type=String()
    
    //For Cart Screen
    var grmEditText=String()
    var euroEditText=String()
    var apiCall=String()
    
    //Home Screen With manage textBox Click
    var clickIs=String()
    
    // Cart screen Discount changes(01/08/19)
    var user_discount_price=String()
    var useroriginal_discount=String()
    var is_directprice=String()
   
    init(json:JSON) {
        self.add_cart=json["add_cart"].stringValue
        if self.add_cart == "0"{
            self.plusIconImg="Plus"
        } else{
            self.plusIconImg="Minus"
        }
        self.extract_type = json["extract_type"].stringValue ?? ""
        self.breed2=json["breed2"].stringValue
        self.breed2=json["breed2"].stringValue
        self.category_id=json["category_id"].stringValue
        self.category_name=json["category_name"].stringValue
        self.category_type=json["category_type"].stringValue
        self.flower_type=json["flower_type"].stringValue
        self.grow_type=json["grow_type"].stringValue
        self.percentageDisplay=json["percentageDisplay"].stringValue
        self.product_description=json["product_description"].stringValue
        self.product_id=json["product_id"].stringValue
        self.product_image=json["product_image"].stringValue
        self.product_medicaldescription=json["product_medicaldescription"].stringValue
        self.product_name=json["product_name"].stringValue
        self.purchase_id=json["purchase_id"].stringValue
        self.realquantity=json["realquantity"].stringValue
        self.sales_price=json["sales_price"].stringValue
        self.user_discount_price=json["user_discount_price"].stringValue
        if json["extra_price_count"].stringValue == ""{
            self.extra_price_count="0"
        } else{
            self.extra_price_count="\(Double(round(100*Double(Shared().componentSepareted(fullValue: "\(json["extra_price_count"].stringValue)", separatedBy: " "))!)/100))"
        }
        
        if json["extra_price"].stringValue == ""{
            self.extra_price="0"
        } else{
            self.extra_price="\(Double(round(100*Double(Shared().componentSepareted(fullValue: "\(json["extra_price"].stringValue)", separatedBy: " "))!)/100))"
        }
        
        self.grmEditText="false"
        self.euroEditText="false"
        self.apiCall="false"
        self.clickIs="false"
        self.product_price=json["product_price"].stringValue
        self.is_discount=json["is_discount"].stringValue
        if json["user_discount"].stringValue == ""{
            self.user_discount="0"
        } else{
            self.user_discount="\(Double(round(100*Double(Shared().componentSepareted(fullValue: "\(json["user_discount"].stringValue)", separatedBy: " "))!)/100))"
        }
        
        if json["user_discount_price"].stringValue == ""{
            self.user_discount_price="0"
        } else{
            self.user_discount_price="\(Double(round(100*Double(Shared().componentSepareted(fullValue: "\(json["user_discount_price"].stringValue)", separatedBy: " "))!)/100))"
        }
        self.useroriginal_discount=json["useroriginal_discount"].stringValue
        self.is_directprice=json["is_directprice"].stringValue
    }
}

class categoryList{
    var categoryname=String()
    var categorytype=String()
    var icon=String()
    var iconselected=String()
    var id=String()
    var product_count=String()
  //  var HomeCategory=HomeCategoryList()
    
    init(json:JSON) {
        self.categoryname=json["categoryname"].stringValue
        self.categorytype=json["categorytype"].stringValue
        self.icon=json["icon"].stringValue
        self.iconselected=json["iconselected"].stringValue
        self.id=json["id"].stringValue
        self.product_count=json["product_count"].stringValue
       // self.HomeCategory=HomeCategoryList(json:json["categoryproduct"])
    }
}

class notificationList{
    var title=String()
    var description=String()
    var image=String()
    var create_at=String()
    var notification_id=String()
    var notification_type = String()
    var unread_flag : Bool = false
    
    init(json:JSON) {
        self.title=json["title"].stringValue
        self.description=json["description"].stringValue
        self.image=json["image"].stringValue
        self.create_at=json["create_at"].stringValue
        self.notification_id=json["notification_id"].stringValue
        self.notification_type=json["notification_type"].stringValue
        self.unread_flag=json["unread_flag"].boolValue ?? false
    }
}

class donationList{
    var amount=String()
    var creditAfter=String()
    var creditBefore=String()
    var donationDate=String()
    var donationid=String()
    var operationType=String()
    var donationTime=String()
    var donation_status=String()
   
    init(json:JSON) {
        self.amount=json["amount"].stringValue
        self.creditAfter=json["creditAfter"].stringValue
        self.creditBefore=json["creditBefore"].stringValue
        self.donationDate=json["donationDate"].stringValue
        self.donationTime=json["donationTime"].stringValue
        self.donationid=json["donationid"].stringValue
        self.operationType=json["operationType"].stringValue
        self.donation_status=json["donation_status"].stringValue
    }
}

class dispanseHistory{
    var create_order_date=String()
    var create_order_time=String()
    var itemcount=String()
    var order_id=String()
    var order_status=String()
    var order_details = [JSON]()
   // var product_image=String()
    var total_price=String()
    var create_new_order_date=String()
    
    init(json:JSON) {
        self.create_order_date=json["create_order_date"].stringValue
        self.create_order_time=json["create_order_time"].stringValue
        self.itemcount=json["itemcount"].stringValue
        self.order_status=json["order_status"].stringValue
        self.order_id=json["order_id"].stringValue
     //   self.product_image=json["product_image"].stringValue
        self.order_details = json["order_details"].arrayValue
        self.total_price=json["product_total"].stringValue
        self.create_new_order_date=json["create_new_order_date"].stringValue
    }
}

class profileSetupGuardians{
    var Guardian_first=String()
    var Guardianfirst_detail=String()
    var Guardianfirst_img=String()
    var guardianfirst_member_no=String()
    var guardianfirst_name=String()
    var guardianfirst_type=String()
    
//    init(json:JSON) {
//        self.Guardian_first=json["Guardian_first"].stringValue
//        self.Guardianfirst_detail=json["Guardianfirst_detail"].stringValue
//        self.Guardianfirst_img=json["Guardianfirst_img"].stringValue
//        self.guardianfirst_member_no=json["guardianfirst_member_no"].stringValue
//        self.guardianfirst_name=json["guardianfirst_name"].stringValue
//        self.guardianfirst_type=json["guardianfirst_type"].stringValue
//    }
}
