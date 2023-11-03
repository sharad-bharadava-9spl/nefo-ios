//
//  CommonGlobal.swift
//  CCSMembersApp
//
//  Created by mac-18 on 21/12/22.
//

import Foundation
import UIKit
import NVActivityIndicatorView




// MARK: - User default keys
let key_isMenuShow          = "isMenuShow"
let key_isMenuPriceShow     = "isMenuPriceShow"
let key_isRememberMe        = "isRememberMe"
let key_MyEmail             = "MyEmail"
let key_Password            = "Password"
let key_isDispensShow          = "isDispensShow"
let key_isDispensPriceShow     = "isDispensPriceShow"
let key_isLogin             = "isLogin"
let key_myQrCode             = "myQrCode"
let key_googleAccessToken   = "googleAccessToken"
let key_oldUserMemberID             = "oldUserMemberID"
let key_oldUserFcmToken             = "oldUserFcmToken"

//MARK: - DateTime
let dateFormateDisplayDash = "dd-MM-yyyy HH:mm:ss"
let dateFormateDashOnlyDate = "dd-MM-yyyy"
let dateTimeFromateDisplaySlash     = "dd/MM/yyyy, HH:mm:ss"
let dateTimeFromateDispaly     = "dd MMM yyyy HH:mm a"
let dateTimeFromateDispalyWithOutAMPM     = "dd MMM yyyy HH:mm"
let dateTimeFromateDispalyOnlyDate     = "dd MMM yyyy"
let dateTimeFromatOnlyDisplayTime     = "HH:mm"
let dateTimeFromatOnlyDisplayDayShortName     = "EE"
let dateFormateDashShortDate = "dd-MM"

var MEMBER_ID = getFromUserDefaultForKey("member_id") as? String ?? ""

// Create a simple image cache
var imageCache = NSCache<NSString, UIImage>()

struct NotificationName {
    let SetParticularIndexInSideMenu     = "SetParticularIndexInSideMenu"
    let PreRegistrationSucessFully       = "PreRegistrationSucessFully"
    let OepnChatDetailScreen             = "openChatDetailScreen"
    let RefreshMyFriendList              = "refreshMyFriendList"
    let UpdateChatUserData               = "UpdateChatUserData"
    let UpdateGlobalChatCount            = "UpdateGlobalChatCount"
    let OpenFriendsRequest               = "OpenFriendsRequest"
}

let API_SERVER_KEY = "AAAAeJy7Bm0:APA91bEF1NNNbKfZA9p0vBl0r9S1IT4nZTFodgbdcdv5CQL7PcR_zMqzVuKMQeZ6jLvF6x9DyqMUT3xpzxJbkcd2TSXci6G2S86uLdDVkmVrZs9JL78DcBKyOeXuGSp9mFPeNciDlc0C"
let URL_FOR_PUSHNOTIFICATION = "https://fcm.googleapis.com/v1/projects/cannabis-club-system/messages:send"
//MARK:- Push Notification / AppDelegate
enum NotificationType : Int {
    case Message = 0
    func get() -> String {
        switch self {
        case .Message: return "1"
        }
    }
}




//MARK: - Storyboard
struct storyboardName {
    static let storyBoard_Main = UIStoryboard(name: "Main", bundle: nil)
    static let storyBoard_PreRegistration = UIStoryboard(name: "PreRegistration", bundle: nil)
    static let storyBoard_Chat = UIStoryboard(name: "Chat", bundle: nil)
    static let storyBoard_CCSMap = UIStoryboard(name: "CCSMap", bundle: nil)
}

//MARK:- Set the Image
enum MediaType: String{
    case image, video, document
}
enum AttachmentType: String{
    case camera, video, photoLibrary
}



//MARK:- Block and UnBlock Types
enum BlockUnBlockTypes {
    case UnBlock
    case Block
    case BlockAndReport
    func get() -> String {
        switch self {
        case .UnBlock: return "0"
        case .Block: return "2"
        case .BlockAndReport: return "3"
        }
    }
}

enum PUSHNOTIFICATION
{
    case USER_CHAT  //GROUP SCRIPT REQUEST
    case CLUB_CHAT  //NORMAL SCRIPT REQUEST
    case REQUEST_RECEIVED     //NEW CHAT MESSAGE
    case REQUEST_ACEEPTED     //NEW CHAT MESSAGE
    
    func get() -> String
    {
        switch self
        {
        case .USER_CHAT :
            return "1"  //"user_chat"
        case .CLUB_CHAT :
            return "2" //"club_chat"
        case .REQUEST_RECEIVED :
            return "3"  //"request_received"
        case .REQUEST_ACEEPTED :
            return "4"  //"request_accepted"
        }
    }
}

//Friends Details From screen
enum FriendsDetailsFrom
{
    case SentRequest
    case ReceiveRequest
    
    func get() -> String
    {
        switch self
        {
        case .SentRequest :
            return "SentRequest"
        case .ReceiveRequest :
            return "ReceiveRequest"
            
        }
    }
}
