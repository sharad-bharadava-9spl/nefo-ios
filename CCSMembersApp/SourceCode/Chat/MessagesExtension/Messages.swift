//
//  Messages.swift
//  CCSMembersApp
//
//  Created by Divvyesh on 27/06/23.
//  Copyright © 2023 Jaimin Patel. All rights reserved.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseMessaging
import Alamofire
import SwiftyJSON

//Users Chat Data
let ENVIRONMENT = "" //Live
fileprivate let USERSDATAKEY = "UsersData\(ENVIRONMENT)" //"UsersDataLive"
fileprivate let USERSCHATKEY = "UsersChat\(ENVIRONMENT)" //"UsersChatLive"
fileprivate let CHATCONVERSIONKEY = "ChatConversations\(ENVIRONMENT)" //"ChatConversationsLive"

//Clubs Chat Data
fileprivate let CLUBSDATAKEY = "ClubsData\(ENVIRONMENT)" //"ClubsDataLive"
fileprivate let CLUBSCHATKEY = "ClubsChat\(ENVIRONMENT)"//"ClubsChatLive"
//https://console.firebase.google.com/project/cannabis-club-system/database/cannabis-club-system/data/~2FtempClubChats


fileprivate let MESSAGESFETCHCOUNT = 20
var lastLoadedMessageKey: String? = ""
var arrLoadedMessageKey = [String]()

//FRIENDS COUNT
 var FRIENDSUNREADCOUNT: Int? {
    didSet {
        if let count = FRIENDSUNREADCOUNT {
            //Notification add
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationName().UpdateGlobalChatCount), object: ["count": count + (CLUBUNREADCOUNT ?? 0)], userInfo: nil)
        }
    }
}

//CLUBS COUNT
 var CLUBUNREADCOUNT: Int? {
    didSet {
        if let count = CLUBUNREADCOUNT {
            //Notification add
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationName().UpdateGlobalChatCount), object: ["count": count + (FRIENDSUNREADCOUNT ?? 0)], userInfo: nil)
        }
    }
}
var dbRef = Database.database().reference()
class Messages:NSObject{
    var owner:MessageOwner
    var type:String
    var content:Any
    var timestamp:Int
    var toId:String?
    var fromId:String?
    var sendername:String?
    var senderProfile:String?
    var recname:String?
    var recProfile:String?
    var un_read:String
    var isBlockedYou:Bool? = false
    var isBlockedByYou:Bool? = false
    var blockByUser :String? = ""
    
    
    
    
    //MARK: - get User Last Message Details
    class func getUserLastConversationDetails(isFromClubChat:Bool = false,toId:String,fromId:String,completion:@escaping ([String:Any]) -> Void){
        Database.database().reference().child(isFromClubChat ? CLUBSCHATKEY : USERSCHATKEY).child(fromId).child("conversations").child(toId).observeSingleEvent(of: .value) { (snapshot)  in
            if snapshot.exists() {
                completion(snapshot.value as? [String:Any] ?? [:])
            }else{
                completion([:])
            }
        }
    }
    //MARK: - get User Last Message Details
    class func checkUserIsBlock(isFromClubChat:Bool = false,toId:String,fromId:String,completion:@escaping (String) -> Void){
        Database.database().reference().child(USERSCHATKEY).child(fromId).child("conversations").child(toId).child("blockByUser").observe(.value, with: {(snapshot) in
            completion(snapshot.value as? String ?? "")
        })
    }
    //MARK: - get User is Friends or not
    class func checkUserIsUnfriend(fromId:String,toId:String,completion:@escaping (Bool) -> Void){
        Database.database().reference().child(USERSCHATKEY).child(fromId).child("conversations").child(toId).child("isUnFriend").observe(.value, with: {(snapshot) in
            completion(snapshot.value as? Bool ?? false)
        })
    }
    //MARK: - get User is Deleted by club
    class func checkUserDeletedByClub(fromId:String,toId:String,completion:@escaping (Bool) -> Void){
        Database.database().reference().child(CLUBSCHATKEY).child(fromId).child("conversations").child(toId).child("isDeletedByClub").observe(.value, with: {(snapshot) in
            completion(snapshot.value as? Bool ?? false)
        })
    }
    //MARK: - get User is Banned by club
    class func checkUserBannedByClub(fromId:String,toId:String,completion:@escaping (Bool) -> Void){
        Database.database().reference().child(CLUBSCHATKEY).child(fromId).child("conversations").child(toId).child("isBannedByClub").observe(.value, with: {(snapshot) in
            completion(snapshot.value as? Bool ?? false)
        })
    }
    
    //MARK: - Fetch Chat list
    class func fetchMessageConversationList(onCompletion: @escaping ([[String:Any]]) -> Void){
        Database.database().reference().child(USERSCHATKEY).child(MEMBER_ID).child("conversations").queryOrdered(byChild: "timestamp").observe(.value, with: {(snapshot) in
            if snapshot.exists() {
                var tempData = [[String:Any]]()
                for d in snapshot.value as? [String:Any] ?? [:]{
                    //                    let values = d.value as! [String:Any]
                    //                    tempData.append(values)
                    if let values = d.value as? [String:Any]{
                        tempData.append(values)
                    }
                }
                
                tempData = tempData.filter({ dict in
                    if dict["message"] as? String ?? "" == ""{
                    //if dict["message"] as? String ?? "" == "" || dict["isUnFriend"] as? Bool ?? false == true{
                        return false
                    }else{
                        return true
                    }
                })
                
                tempData.sort { (dict1, dict2) -> Bool in
                    let timestamp1 = Int(dict1["timestamp"] as? String ?? "0") ?? 0
                    let timestamp2 = Int(dict2["timestamp"] as? String ?? "0") ?? 0
                    
                    return timestamp1 > timestamp2
//                    if let timestamp1 = dict1["timestamp"], let timestamp2 = dict2["timestamp"] {
//                        return Int(timestamp1 as? String ?? "0") ?? 0 > Int(timestamp2 as? String ?? "0") ?? 0
//                    }
//                    return false // If timestamps are not available, we can keep the order as it is
                }
                
                let countArray = tempData.filter { dict in
                    return dict["count"] as? Int ?? 0 > 0
                }
                
                FRIENDSUNREADCOUNT = countArray.count
                
                print("Friend Chat list :- \(tempData)")
                onCompletion(tempData)
            }else{
                onCompletion([])
            }
        })
    }
    
    //MARK: - Fetch CLUB Chat list
    class func fetchMessageConversationClubList(onCompletion: @escaping ([[String:Any]]) -> Void){
        Database.database().reference().child(CLUBSCHATKEY).child(MEMBER_ID).child("conversations").queryOrdered(byChild: "timestamp").observe(.value, with: {(snapshot) in
            if snapshot.exists() {
                var tempData = [[String:Any]]()
                for d in snapshot.value as? [String:Any] ?? [:]{
                    //                    let values = d.value as! [String:Any]
                    //                    tempData.append(values)
                    if let values = d.value as? [String:Any]{
                        tempData.append(values)
                    }
                }
                
                tempData = tempData.filter({ dict in
                    if dict["message"] as? String ?? "" == ""{
                    //if dict["message"] as? String ?? "" == "" || dict["isBannedByClub"] as? Bool ?? false == true || dict["isDeletedByClub"] as? Bool ?? false == true{
                        return false
                    }else{
                        return true
                    }
                })
                tempData.sort { (dict1, dict2) -> Bool in
                    let timestamp1 = Int(dict1["timestamp"] as? String ?? "0") ?? 0
                    let timestamp2 = Int(dict2["timestamp"] as? String ?? "0") ?? 0
                    
                    return timestamp1 > timestamp2
                    /*
                    if let timestamp1 = dict1["timestamp"], let timestamp2 = dict2["timestamp"] {
                        return Int(timestamp1 as? String ?? "0") ?? 0 > Int(timestamp2 as? String ?? "0") ?? 0
                    }
                    return false // If timestamps are not available, we can keep the order as it is
                     */
                }
                
                let countArray = tempData.filter { dict in
                    return dict["count"] as? Int ?? 0 > 0
                }
                CLUBUNREADCOUNT = countArray.count
                
                print("Friend Chat list :- \(tempData)")
                onCompletion(tempData)
            }else{
                onCompletion([])
            }
        })
    }
    
    //Remove Message conversations list Observer
    class func removeObserverMessageConversationList(isFromClubChat:Bool = false){
        Database.database().reference().child(isFromClubChat ? CLUBSCHATKEY : USERSCHATKEY).child(MEMBER_ID).child("conversations").removeAllObservers()
    }
    class func getUserConversationsKey(isFromClubChat:Bool = false,forId:String,completion:@escaping(String)->Void) {
        Database.database().reference().child(isFromClubChat ? CLUBSCHATKEY : USERSCHATKEY).child(MEMBER_ID).child("conversations").child(forId).observeSingleEvent(of: .value) { (snapshot)  in
            if snapshot.exists() {
                let data = snapshot.value as? [String: Any] ?? [:]
                if data["message"] == nil{
                    completion("")
                }else{
                    completion(data["message"] as? String ?? "")
                }
            }else{
                completion("")
            }
        }
    }
    
    class func fetchFirstTimeMessageAndAddObserver(conversationKey:String,lastKey:String = "",completion:@escaping([Messages],String,Bool,[Int],Bool)->Void) {
        //var query = DatabaseQuery()
        var count = MESSAGESFETCHCOUNT
        var arrMessage = [Messages]()
        var lastFetchedMessageKey = ""
        var timestamparray = [Int]()
        var isNextPageAvailable = false
        let messagesRef = dbRef.child(CHATCONVERSIONKEY).child(conversationKey)
        var query = messagesRef.queryOrderedByKey().queryLimited(toLast: UInt(count))
        if lastKey != "" {
            query = query.queryStarting(atValue: lastKey)
            count += 1
        }
        query.observeSingleEvent(of: .value) { snapshot in
            
            print("ALL CHILDREN ==> \(snapshot.children.allObjects)")
            var children = snapshot.children.allObjects as? [DataSnapshot] ?? []
//            guard var children = snapshot.children.allObjects as? [DataSnapshot] else {
//            // Handle error
//                return
//            }

          if lastKey != "" && !children.isEmpty {
            children.removeFirst()
          }
            
        
            lastFetchedMessageKey = children.first?.key ?? ""
            print("After Sorting Data :- \(lastFetchedMessageKey)")
            if lastLoadedMessageKey == ""{
                lastLoadedMessageKey = children.last?.key ?? ""
            }
            
        
        if children.count > (MESSAGESFETCHCOUNT - 1) {
            isNextPageAvailable = true
        }else{
            isNextPageAvailable = false
        }
            
            
            var fetchedList = JSON("")
            //children = children.reversed()
        
            for child in children as! [DataSnapshot] {
                if let receivedMessage = child.value as? [String:Any]{
                    arrLoadedMessageKey.append(child.key as? String ?? "")
                    let messageType = receivedMessage["type"] as? String ?? ""
                    let content = receivedMessage["content"] as? String ?? ""
                    let fromID = receivedMessage["fromId"] as? String ?? ""
                    let toId = receivedMessage["toId"] as? String ?? ""
                    let isDeletedFrom = receivedMessage["isDeletedFrom"] as? String ?? ""
                    let timestamp = Int(receivedMessage["timestamp"] as? String ?? "")
                    let sendername = receivedMessage["sendername"] as? String ?? ""
                    let senderProfile = receivedMessage["senderProfile"] as? String ?? ""
                    let recname = receivedMessage["recname"] as? String ?? ""
                    let recProfile = receivedMessage["recProfile"] as? String ?? ""
                    let unread = receivedMessage["un_read"] as? String ?? ""
                    let blockByUser = receivedMessage["blockByUser"] as? String ?? ""
                    let isBlockedYou = receivedMessage["isBlockedYou"] as? Bool ?? false
                    let isBlockedByYou = receivedMessage["isBlockedByYou"] as? Bool ?? false
                    
                    timestamparray.append(timestamp ?? 0)
                    if isDeletedFrom != MEMBER_ID{
                        if fromID == MEMBER_ID {
                            let message = Messages.init(type: messageType, content: content, owner: .sender, timestamp: timestamp ?? 0, sendername: sendername, senderProfile: senderProfile, recname: recname, recProfile: recProfile, un_read:unread, fromId: fromID, toId:toId,isBlockedYou:isBlockedYou,isBlockedByYou:isBlockedByYou,blockByUser:blockByUser)
                            arrMessage.append(message)
                        } else {
                            let message = Messages.init(type: messageType, content: content, owner: .reciever, timestamp: timestamp ?? 0, sendername: recname, senderProfile: recProfile, recname: sendername, recProfile: senderProfile, un_read:unread, fromId: fromID,toId: toId,isBlockedYou:isBlockedYou,isBlockedByYou:isBlockedByYou,blockByUser:blockByUser)
                            arrMessage.append(message)
                        }
                    }
                }
            }
            print("children =====> \(fetchedList)")
            if arrMessage.count > 0{
                if lastKey == ""{
                    messagesRef.queryOrderedByKey().queryLimited(toLast: 2).observe(.childAdded) { snap in
                        // Process and display the newly added message
                        // Update lastLoadedMessageKey if necessary
                        print("Inside Observer :- \(snap.value as? [String:Any] ?? [:])")
                        if snap.key > lastLoadedMessageKey ?? "" || arrLoadedMessageKey.contains(snap.key) == false{
                            lastLoadedMessageKey = snap.key
                            arrLoadedMessageKey.append(snap.key)
                            if snap.exists() {
                                let receivedMessage = snap.value as! [String: Any]
                                let messageType = receivedMessage["type"] as? String ?? ""
                                let content = receivedMessage["content"] as? String ?? ""
                                let fromID = receivedMessage["fromId"] as? String ?? ""
                                let toId = receivedMessage["toId"] as? String ?? ""
                                let isDeletedFrom = receivedMessage["isDeletedFrom"] as? String ?? ""
                                let timestamp = Int(receivedMessage["timestamp"] as? String ?? "")
                                let sendername = receivedMessage["sendername"] as? String ?? ""
                                let senderProfile = receivedMessage["senderProfile"] as? String ?? ""
                                let recname = receivedMessage["recname"] as? String ?? ""
                                let recProfile = receivedMessage["recProfile"] as? String ?? ""
                                let unread = receivedMessage["un_read"] as? String ?? ""
                                let isBlockedYou = receivedMessage["isBlockedYou"] as? Bool ?? false
                                let isBlockedByYou = receivedMessage["isBlockedByYou"] as? Bool ?? false
                                let blockByUser = receivedMessage["blockByUser"] as? String ?? ""
                                
                                //timestamparray.append(timestamp ?? 0)
                                if isDeletedFrom != MEMBER_ID{
                                   if fromID == MEMBER_ID {
                                       let message = Messages.init(type: messageType, content: content, owner: .sender, timestamp: timestamp ?? 0, sendername: sendername, senderProfile: senderProfile, recname: recname, recProfile: recProfile, un_read:unread, fromId: fromID, toId:toId,isBlockedYou:isBlockedYou,isBlockedByYou:isBlockedByYou, blockByUser: blockByUser)
                                       
                                       if timestamparray.contains(timestamp ?? 0) == false{
                                           completion([message],lastFetchedMessageKey,isNextPageAvailable,[timestamp ?? 0],true)
                                       }
                                       
                                   } else {
                                       let message = Messages.init(type: messageType, content: content, owner: .reciever, timestamp: timestamp ?? 0, sendername: recname, senderProfile: recProfile, recname: sendername, recProfile: senderProfile, un_read:unread, fromId: fromID,toId: toId,isBlockedYou:isBlockedYou,isBlockedByYou:isBlockedByYou,blockByUser: blockByUser)
                                       if timestamparray.contains(timestamp ?? 0) == false{
                                           completion([message],lastFetchedMessageKey,isNextPageAvailable,[timestamp ?? 0],true)
                                           
                                       }
                                   }
                               }
                            }
                        }else{
                            return
                        }
                    }
                     
                    
                    /*self.setMessageObserver(conversationKey: conversationKey) { (messages, lastKey, isNextPageAvailable,arrTime,isFromMessageObserver) in
                        completion(messages,lastKey,isNextPageAvailable,arrTime,isFromMessageObserver)
                    }*/
                }
            }
            
            completion(arrMessage,lastFetchedMessageKey,isNextPageAvailable,timestamparray,false)
          // Do something with children
        }
    }
    
    
    class func setMessageObserver(conversationKey:String,lastKey:String = "",completion:@escaping([Messages],String,Bool,[Int],Bool)->Void) {
        //var query = DatabaseQuery()
        var count = MESSAGESFETCHCOUNT
        var arrMessage = [Messages]()
        var lastFetchedMessageKey = ""
        var timestamparray = [Int]()
        var isNextPageAvailable = false
        let messagesRef = dbRef.child(CHATCONVERSIONKEY).child(conversationKey)
        var query = messagesRef.queryOrderedByKey().queryLimited(toLast: UInt(count))
        if lastKey != "" {
            query = query.queryStarting(atValue: lastKey)
            count += 1
        }
        var tempQuery = messagesRef.queryOrderedByKey().queryEnding(atValue: lastLoadedMessageKey).queryLimited(toLast: 1)
        messagesRef.queryOrderedByKey().queryLimited(toLast: 2).observe(.childAdded) { snap in
                if snap.exists() {
                    let receivedMessage = snap.value as! [String: Any]
                    let messageType = receivedMessage["type"] as? String ?? ""
                    let content = receivedMessage["content"] as? String ?? ""
                    let fromID = receivedMessage["fromId"] as? String ?? ""
                    let toId = receivedMessage["toId"] as? String ?? ""
                    let isDeletedFrom = receivedMessage["isDeletedFrom"] as? String ?? ""
                    let timestamp = Int(receivedMessage["timestamp"] as? String ?? "")
                    let sendername = receivedMessage["sendername"] as? String ?? ""
                    let senderProfile = receivedMessage["senderProfile"] as? String ?? ""
                    let recname = receivedMessage["recname"] as? String ?? ""
                    let recProfile = receivedMessage["recProfile"] as? String ?? ""
                    let unread = receivedMessage["un_read"] as? String ?? ""
                    let isBlockedYou = receivedMessage["isBlockedYou"] as? Bool ?? false
                    let isBlockedByYou = receivedMessage["isBlockedByYou"] as? Bool ?? false
                    let blockByUser = receivedMessage["blockByUser"] as? String ?? ""
                    
                    //timestamparray.append(timestamp ?? 0)
                    if isDeletedFrom != MEMBER_ID{
                       if fromID == MEMBER_ID {
                           let message = Messages.init(type: messageType, content: content, owner: .sender, timestamp: timestamp ?? 0, sendername: sendername, senderProfile: senderProfile, recname: recname, recProfile: recProfile, un_read:unread, fromId: fromID, toId:toId,isBlockedYou:isBlockedYou,isBlockedByYou:isBlockedByYou, blockByUser: blockByUser)
                           
                           if timestamparray.contains(timestamp ?? 0) == false{
                               completion([message],lastFetchedMessageKey,isNextPageAvailable,[timestamp ?? 0],true)
                           }
                           
                       } else {
                           let message = Messages.init(type: messageType, content: content, owner: .reciever, timestamp: timestamp ?? 0, sendername: recname, senderProfile: recProfile, recname: sendername, recProfile: senderProfile, un_read:unread, fromId: fromID,toId: toId,isBlockedYou:isBlockedYou,isBlockedByYou:isBlockedByYou,blockByUser: blockByUser)
                           if timestamparray.contains(timestamp ?? 0) == false{
                               completion([message],lastFetchedMessageKey,isNextPageAvailable,[timestamp ?? 0],true)
                               
                           }
                       }
                   }
                }
        }
    }
    
    class func removeMessageObserver(conversationKey:String){
        dbRef.child(CHATCONVERSIONKEY).child(conversationKey).removeAllObservers()
    }
    class func fetchMessagePaginationWise(conversationKey:String,lastKey:String = "",completion:@escaping([Messages],String,Bool,[Int])->Void) {
        //var query = DatabaseQuery()
        var count = MESSAGESFETCHCOUNT + 1
        var arrMessage = [Messages]()
        var lastFetchedMessageKey = ""
        var timestamparray = [Int]()
        var isNextPageAvailable = false
        let messagesRef = Database.database().reference().child(CHATCONVERSIONKEY).child(conversationKey)
        var query = messagesRef.queryOrderedByKey().queryEnding(atValue: lastKey).queryLimited(toLast: UInt(count))
       
        Database.database().reference().child(CHATCONVERSIONKEY).child(conversationKey).queryOrderedByKey().queryLimited(toLast: UInt(count)).queryEnding(atValue: lastKey).observeSingleEvent(of: .value) { snapshot in
            
            print("ALL CHILDREN ==> \(snapshot.children.allObjects)")
            guard var children = snapshot.children.allObjects as? [DataSnapshot] else {
            // Handle error
                return
            }

          if lastKey != "" && !children.isEmpty {
            children.removeLast()
          }
            
        
            lastFetchedMessageKey = children.first?.key ?? ""
            print("After Sorting Data :- \(lastFetchedMessageKey)")
            
        
        if children.count > (MESSAGESFETCHCOUNT - 1) {
            isNextPageAvailable = true
        }else{
            isNextPageAvailable = false
        }
            
            
            var fetchedList = JSON("")
            //children = children.reversed()
        
            for child in children as! [DataSnapshot] {
                if let receivedMessage = child.value as? [String:Any]{
                    let messageType = receivedMessage["type"] as? String ?? ""
                    let content = receivedMessage["content"] as? String ?? ""
                    let fromID = receivedMessage["fromId"] as? String ?? ""
                    let toId = receivedMessage["toId"] as? String ?? ""
                    let isDeletedFrom = receivedMessage["isDeletedFrom"] as? String ?? ""
                    let timestamp = Int(receivedMessage["timestamp"] as? String ?? "")
                    let sendername = receivedMessage["sendername"] as? String ?? ""
                    let senderProfile = receivedMessage["senderProfile"] as? String ?? ""
                    let recname = receivedMessage["recname"] as? String ?? ""
                    let recProfile = receivedMessage["recProfile"] as? String ?? ""
                    let unread = receivedMessage["un_read"] as? String ?? ""
                    let blockByUser = receivedMessage["blockByUser"] as? String ?? ""
                    let isBlockedYou = receivedMessage["isBlockedYou"] as? Bool ?? false
                    let isBlockedByYou = receivedMessage["isBlockedByYou"] as? Bool ?? false
                    
                    timestamparray.append(timestamp ?? 0)
                    if isDeletedFrom != MEMBER_ID{
                        if fromID == MEMBER_ID {
                            let message = Messages.init(type: messageType, content: content, owner: .sender, timestamp: timestamp ?? 0, sendername: sendername, senderProfile: senderProfile, recname: recname, recProfile: recProfile, un_read:unread, fromId: fromID, toId:toId,isBlockedYou:isBlockedYou,isBlockedByYou:isBlockedByYou,blockByUser:blockByUser)
                            arrMessage.append(message)
                        } else {
                            let message = Messages.init(type: messageType, content: content, owner: .reciever, timestamp: timestamp ?? 0, sendername: recname, senderProfile: recProfile, recname: sendername, recProfile: senderProfile, un_read:unread, fromId: fromID,toId: toId,isBlockedYou:isBlockedYou,isBlockedByYou:isBlockedByYou,blockByUser:blockByUser)
                            arrMessage.append(message)
                        }
                    }
                }
            }
            completion(arrMessage,lastFetchedMessageKey,isNextPageAvailable,timestamparray)
          // Do something with children
        }
    }
    /*
    class func fetchMessagePaginationWise(conversationKey:String,lastKey:String = "",completion:@escaping([Messages],String,Bool,[Int])->Void) {
        let messagesRef = Database.database().reference().child(CHATCONVERSIONKEY).child(conversationKey)
        var query = messagesRef.queryOrdered(byChild: "timestamp").queryEnding(atValue: lastKey).queryLimited(toLast: UInt(MESSAGESFETCHCOUNT + 1))
        
       
        var arrMessage = [Messages]()
        var lastFetchedMessageKey = ""
        var timestamparray = [Int]()
        var isNextPageAvailable = false
        
        var isFromChatObserver = false
        query.observeSingleEvent(of: .value) { (snapshot)   in
                guard let messagesData = snapshot.value as? [String: Any] else {
                    // Handle error or empty snapshot
                    completion([Messages](),"",false,[Int]())
                    return
                }
            
            guard var children = snapshot.children.allObjects as? [DataSnapshot] else {
            // Handle error
            return
          }
            
            //let abcData = messagesData.sorted( by: { $0.value["timestamp"] as? Int ?? 0 < $1.value["timestamp"] as? Int ?? 0 })
            
            
            
                let messageKeys = Array(messagesData.keys)
                lastFetchedMessageKey = messageKeys.first ?? ""
                print("After Sorting Data :- \(messageKeys)")
                lastLoadedMessageKey = messageKeys.last ?? ""
            
            if messageKeys.count > (MESSAGESFETCHCOUNT - 1) {
                isNextPageAvailable = true
            }
                
                let fetchedMessages = messageKeys.compactMap { key in
                    //let receivedMessage = snap.value as! [String: Any]
                    if let receivedMessage = messagesData[key] as? [String: Any]{
                        let messageType = receivedMessage["type"] as? String ?? ""
                        let content = receivedMessage["content"] as? String ?? ""
                        let fromID = receivedMessage["fromId"] as? String ?? ""
                        let toId = receivedMessage["toId"] as? String ?? ""
                        let isDeletedFrom = receivedMessage["isDeletedFrom"] as? String ?? ""
                        let timestamp = Int(receivedMessage["timestamp"] as? String ?? "")
                        let sendername = receivedMessage["sendername"] as? String ?? ""
                        let senderProfile = receivedMessage["senderProfile"] as? String ?? ""
                        let recname = receivedMessage["recname"] as? String ?? ""
                        let recProfile = receivedMessage["recProfile"] as? String ?? ""
                        let unread = receivedMessage["un_read"] as? String ?? ""
                        let blockByUser = receivedMessage["blockByUser"] as? String ?? ""
                        let isBlockedYou = receivedMessage["isBlockedYou"] as? Bool ?? false
                        let isBlockedByYou = receivedMessage["isBlockedByYou"] as? Bool ?? false
                        
                        timestamparray.append(timestamp ?? 0)
                        if isDeletedFrom != MEMBER_ID{
                            if fromID == MEMBER_ID {
                                let message = Messages.init(type: messageType, content: content, owner: .sender, timestamp: timestamp ?? 0, sendername: sendername, senderProfile: senderProfile, recname: recname, recProfile: recProfile, un_read:unread, fromId: fromID, toId:toId,isBlockedYou:isBlockedYou,isBlockedByYou:isBlockedByYou,blockByUser:blockByUser)
                                arrMessage.append(message)
                            } else {
                                let message = Messages.init(type: messageType, content: content, owner: .reciever, timestamp: timestamp ?? 0, sendername: recname, senderProfile: recProfile, recname: sendername, recProfile: senderProfile, un_read:unread, fromId: fromID,toId: toId,isBlockedYou:isBlockedYou,isBlockedByYou:isBlockedByYou,blockByUser:blockByUser)
                                arrMessage.append(message)
                            }
                        }
                    }
                    
                }
            
            //let tempData = messagesData.sorted{$0.value["timestamp"] as? Int ?? 0 > $0.value["timestamp"] as? Int ?? 0}
            //print("Afyer Sorting data is :- \(tempData)")

            arrMessage = arrMessage.sorted { $0.timestamp < $1.timestamp }
            //arrMessage = arrMessage.reversed()
            
            if lastKey == ""{
                query.observe(.childAdded) { snap in
                    // Process and display the newly added message
                    
                    // Update lastLoadedMessageKey if necessary
                    if snap.key > lastLoadedMessageKey ?? "" {
                        lastLoadedMessageKey = snapshot.key
                        if snap.exists() {
                            let receivedMessage = snap.value as! [String: Any]
                            let messageType = receivedMessage["type"] as? String ?? ""
                            let content = receivedMessage["content"] as? String ?? ""
                            let fromID = receivedMessage["fromId"] as? String ?? ""
                            let toId = receivedMessage["toId"] as? String ?? ""
                            let isDeletedFrom = receivedMessage["isDeletedFrom"] as? String ?? ""
                            let timestamp = Int(receivedMessage["timestamp"] as? String ?? "")
                            let sendername = receivedMessage["sendername"] as? String ?? ""
                            let senderProfile = receivedMessage["senderProfile"] as? String ?? ""
                            let recname = receivedMessage["recname"] as? String ?? ""
                            let recProfile = receivedMessage["recProfile"] as? String ?? ""
                            let unread = receivedMessage["un_read"] as? String ?? ""
                            let isBlockedYou = receivedMessage["isBlockedYou"] as? Bool ?? false
                            let isBlockedByYou = receivedMessage["isBlockedByYou"] as? Bool ?? false
                            let blockByUser = receivedMessage["blockByUser"] as? String ?? ""
                            
                            timestamparray.append(timestamp ?? 0)
                            if isDeletedFrom != MEMBER_ID{
                               if fromID == MEMBER_ID {
                                   let message = Messages.init(type: messageType, content: content, owner: .sender, timestamp: timestamp ?? 0, sendername: sendername, senderProfile: senderProfile, recname: recname, recProfile: recProfile, un_read:unread, fromId: fromID, toId:toId,isBlockedYou:isBlockedYou,isBlockedByYou:isBlockedByYou, blockByUser: blockByUser)
                                   completion([message],lastFetchedMessageKey,isNextPageAvailable,timestamparray)
                               } else {
                                   let message = Messages.init(type: messageType, content: content, owner: .reciever, timestamp: timestamp ?? 0, sendername: recname, senderProfile: recProfile, recname: sendername, recProfile: senderProfile, un_read:unread, fromId: fromID,toId: toId,isBlockedYou:isBlockedYou,isBlockedByYou:isBlockedByYou,blockByUser: blockByUser)
                                   
                                   completion([message],lastFetchedMessageKey,isNextPageAvailable,timestamparray)
                               }
                           }
                        }
                    }
                }
            }
            completion(arrMessage,lastFetchedMessageKey,isNextPageAvailable,timestamparray)
            }
        }
    */
    
    /*
    class func fetchMessagePaginationWise(conversationKey:String,lastKey:String = "",completion:@escaping([Messages],String,Bool,[Int])->Void) {
        self.MessageUsingPaginationWise(conversationKey: conversationKey,lastKey: lastKey) { messagesData, isFromObserver in
            let sortData = messagesData.sorted { (dict1, dict2) in
                let timestamp1 = dict1.value["timestamp"] as? Int ?? 0
                let timestamp2 = dict2.value["timestamp"] as? Int ?? 0
                return timestamp1 > timestamp2
            }
            
            let sortedByAge = messagesData.sorted { (dict1, dict2) in
                
            }
            
            
            lastLoadedMessageKey = lastFetchedMessageKey
            
            
        }
        
        
        let messagesRef = Database.database().reference().child(CHATCONVERSIONKEY).child(conversationKey)
        var query = messagesRef.queryOrdered(byChild: "timestamp").queryLimited(toLast: UInt(MESSAGESFETCHCOUNT))
        
        if lastKey != ""{
            query = messagesRef.queryOrdered(byChild: "timestamp").queryEnding(atValue: lastKey).queryLimited(toLast: UInt(MESSAGESFETCHCOUNT + 1))
        }
        var arrMessage = [Messages]()
        var lastFetchedMessageKey = ""
        var timestamparray = [Int]()
        var isNextPageAvailable = false
        
        var isFromChatObserver = false
        query.observeSingleEvent(of: .value) { (snapshot)   in
                guard let messagesData = snapshot.value as? [String: Any] else {
                    // Handle error or empty snapshot
                    completion([Messages](),"",false,[Int]())
                    return
                }
            
            //let abcData = messagesData.sorted( by: { $0.value["timestamp"] as? Int ?? 0 < $1.value["timestamp"] as? Int ?? 0 })
            
            
            
                let messageKeys = Array(messagesData.keys)
                lastFetchedMessageKey = messageKeys.first ?? ""
                print("After Sorting Data :- \(messageKeys)")
                lastLoadedMessageKey = lastFetchedMessageKey
            
            if messageKeys.count > (MESSAGESFETCHCOUNT - 1) {
                isNextPageAvailable = true
            }
                
                let fetchedMessages = messageKeys.compactMap { key in
                    //let receivedMessage = snap.value as! [String: Any]
                    if let receivedMessage = messagesData[key] as? [String: Any]{
                        let messageType = receivedMessage["type"] as? String ?? ""
                        let content = receivedMessage["content"] as? String ?? ""
                        let fromID = receivedMessage["fromId"] as? String ?? ""
                        let toId = receivedMessage["toId"] as? String ?? ""
                        let isDeletedFrom = receivedMessage["isDeletedFrom"] as? String ?? ""
                        let timestamp = Int(receivedMessage["timestamp"] as? String ?? "")
                        let sendername = receivedMessage["sendername"] as? String ?? ""
                        let senderProfile = receivedMessage["senderProfile"] as? String ?? ""
                        let recname = receivedMessage["recname"] as? String ?? ""
                        let recProfile = receivedMessage["recProfile"] as? String ?? ""
                        let unread = receivedMessage["un_read"] as? String ?? ""
                        let blockByUser = receivedMessage["blockByUser"] as? String ?? ""
                        let isBlockedYou = receivedMessage["isBlockedYou"] as? Bool ?? false
                        let isBlockedByYou = receivedMessage["isBlockedByYou"] as? Bool ?? false
                        
                        timestamparray.append(timestamp ?? 0)
                        if isDeletedFrom != MEMBER_ID{
                            if fromID == MEMBER_ID {
                                let message = Messages.init(type: messageType, content: content, owner: .sender, timestamp: timestamp ?? 0, sendername: sendername, senderProfile: senderProfile, recname: recname, recProfile: recProfile, un_read:unread, fromId: fromID, toId:toId,isBlockedYou:isBlockedYou,isBlockedByYou:isBlockedByYou,blockByUser:blockByUser)
                                arrMessage.append(message)
                            } else {
                                let message = Messages.init(type: messageType, content: content, owner: .reciever, timestamp: timestamp ?? 0, sendername: recname, senderProfile: recProfile, recname: sendername, recProfile: senderProfile, un_read:unread, fromId: fromID,toId: toId,isBlockedYou:isBlockedYou,isBlockedByYou:isBlockedByYou,blockByUser:blockByUser)
                                arrMessage.append(message)
                            }
                        }
                    }
                    
                }
            
            //let tempData = messagesData.sorted{$0.value["timestamp"] as? Int ?? 0 > $0.value["timestamp"] as? Int ?? 0}
            //print("Afyer Sorting data is :- \(tempData)")

            arrMessage.sorted { $0.timestamp > $1.timestamp }
            //arrMessage = arrMessage.reversed()
            
            if lastKey == ""{
                query.observe(.childAdded) { snap in
                    // Process and display the newly added message
                    
                    if lastKey != ""{
                        isFromChatObserver = true
                    }
                    // Update lastLoadedMessageKey if necessary
                    if snap.key > lastLoadedMessageKey ?? "" {
                        lastLoadedMessageKey = snapshot.key
                        if snap.exists() {
                            let receivedMessage = snap.value as! [String: Any]
                            let messageType = receivedMessage["type"] as? String ?? ""
                            let content = receivedMessage["content"] as? String ?? ""
                            let fromID = receivedMessage["fromId"] as? String ?? ""
                            let toId = receivedMessage["toId"] as? String ?? ""
                            let isDeletedFrom = receivedMessage["isDeletedFrom"] as? String ?? ""
                            let timestamp = Int(receivedMessage["timestamp"] as? String ?? "")
                            let sendername = receivedMessage["sendername"] as? String ?? ""
                            let senderProfile = receivedMessage["senderProfile"] as? String ?? ""
                            let recname = receivedMessage["recname"] as? String ?? ""
                            let recProfile = receivedMessage["recProfile"] as? String ?? ""
                            let unread = receivedMessage["un_read"] as? String ?? ""
                            let isBlockedYou = receivedMessage["isBlockedYou"] as? Bool ?? false
                            let isBlockedByYou = receivedMessage["isBlockedByYou"] as? Bool ?? false
                            let blockByUser = receivedMessage["blockByUser"] as? String ?? ""
                            
                            timestamparray.append(timestamp ?? 0)
                            if isDeletedFrom != MEMBER_ID{
                               if fromID == MEMBER_ID {
                                   let message = Messages.init(type: messageType, content: content, owner: .sender, timestamp: timestamp ?? 0, sendername: sendername, senderProfile: senderProfile, recname: recname, recProfile: recProfile, un_read:unread, fromId: fromID, toId:toId,isBlockedYou:isBlockedYou,isBlockedByYou:isBlockedByYou, blockByUser: blockByUser)
                                   completion([message],lastFetchedMessageKey,isNextPageAvailable,timestamparray)
                               } else {
                                   let message = Messages.init(type: messageType, content: content, owner: .reciever, timestamp: timestamp ?? 0, sendername: recname, senderProfile: recProfile, recname: sendername, recProfile: senderProfile, un_read:unread, fromId: fromID,toId: toId,isBlockedYou:isBlockedYou,isBlockedByYou:isBlockedByYou,blockByUser: blockByUser)
                                   
                                   completion([message],lastFetchedMessageKey,isNextPageAvailable,timestamparray)
                               }
                           }
                        }
                    }
                }
            }
            
            
            
            completion(arrMessage,lastFetchedMessageKey,isNextPageAvailable,timestamparray)
            }
        }
    */
    
    
    class func MessageUsingPaginationWise(conversationKey:String,lastKey:String = "",completion:@escaping([String: Any],Bool)->Void) {
        let messagesRef = Database.database().reference().child(CHATCONVERSIONKEY).child(conversationKey)
        var query = messagesRef.queryOrdered(byChild: "timestamp").queryLimited(toLast: UInt(MESSAGESFETCHCOUNT))
        
        if lastKey != ""{
            query = messagesRef.queryOrdered(byChild: "timestamp").queryEnding(atValue: lastKey).queryLimited(toLast: UInt(MESSAGESFETCHCOUNT + 1))
        }
        var arrMessage = [Messages]()
        var lastFetchedMessageKey = ""
        var timestamparray = [Int]()
        var isNextPageAvailable = false
        
        var isFromChatObserver = false
        query.observeSingleEvent(of: .value) { snapshot in
            if snapshot.exists(){
                
                
                guard let messagesData = snapshot.value as? [String: Any] else {
                    // Handle error or empty snapshot
                    completion([String: Any](),false)
                    return
                }
                let messageKeys = Array(messagesData.keys)
                lastLoadedMessageKey = messageKeys.first ?? ""
                completion(messagesData,false)
            }
            
            if lastKey == ""{
                query.observe(.childAdded) { snap in
                    if snap.key > lastLoadedMessageKey ?? "" {
                        guard let messagesData = snap.value as? [String: Any] else {
                            // Handle error or empty snapshot
                            completion([String: Any](),false)
                            return
                        }
                        completion(messagesData,true)
                    }
                    
                }
            }
        }
        /*
        query.observeSingleEvent(of: .value) { (snapshot)   in
            if snapshot.exists(){
                completion(snapshot)
                
            }
            
            if lastKey == ""{
                query.observe(.childAdded) { snap in
                    // Process and display the newly added message
                    
                    if lastKey != ""{
                        isFromChatObserver = true
                    }
                    // Update lastLoadedMessageKey if necessary
                    if snap.key > lastLoadedMessageKey ?? "" {
                        lastLoadedMessageKey = snapshot.key
                        if snap.exists() {
                            let receivedMessage = snap.value as! [String: Any]
                            let messageType = receivedMessage["type"] as? String ?? ""
                            let content = receivedMessage["content"] as? String ?? ""
                            let fromID = receivedMessage["fromId"] as? String ?? ""
                            let toId = receivedMessage["toId"] as? String ?? ""
                            let isDeletedFrom = receivedMessage["isDeletedFrom"] as? String ?? ""
                            let timestamp = Int(receivedMessage["timestamp"] as? String ?? "")
                            let sendername = receivedMessage["sendername"] as? String ?? ""
                            let senderProfile = receivedMessage["senderProfile"] as? String ?? ""
                            let recname = receivedMessage["recname"] as? String ?? ""
                            let recProfile = receivedMessage["recProfile"] as? String ?? ""
                            let unread = receivedMessage["un_read"] as? String ?? ""
                            let isBlockedYou = receivedMessage["isBlockedYou"] as? Bool ?? false
                            let isBlockedByYou = receivedMessage["isBlockedByYou"] as? Bool ?? false
                            let blockByUser = receivedMessage["blockByUser"] as? String ?? ""
                            
                            timestamparray.append(timestamp ?? 0)
                            if isDeletedFrom != MEMBER_ID{
                               if fromID == MEMBER_ID {
                                   let message = Messages.init(type: messageType, content: content, owner: .sender, timestamp: timestamp ?? 0, sendername: sendername, senderProfile: senderProfile, recname: recname, recProfile: recProfile, un_read:unread, fromId: fromID, toId:toId,isBlockedYou:isBlockedYou,isBlockedByYou:isBlockedByYou, blockByUser: blockByUser)
                                   completion([message],lastFetchedMessageKey,isNextPageAvailable,timestamparray)
                               } else {
                                   let message = Messages.init(type: messageType, content: content, owner: .reciever, timestamp: timestamp ?? 0, sendername: recname, senderProfile: recProfile, recname: sendername, recProfile: senderProfile, un_read:unread, fromId: fromID,toId: toId,isBlockedYou:isBlockedYou,isBlockedByYou:isBlockedByYou,blockByUser: blockByUser)
                                   
                                   completion([message],lastFetchedMessageKey,isNextPageAvailable,timestamparray)
                               }
                           }
                        }
                    }
                }
            }
            }*/
        
        }
        
    class func setObserveForMessages(conversationKey:String,completion:@escaping(Messages)->Void){
        Database.database().reference().child(CHATCONVERSIONKEY).child(conversationKey).observe(.childAdded, with: { (snap) in
            
            if snap.exists() {
                let receivedMessage = snap.value as! [String: Any]
                let messageType = receivedMessage["type"] as? String ?? ""
                let content = receivedMessage["content"] as? String ?? ""
                let fromID = receivedMessage["fromId"] as? String ?? ""
                let toId = receivedMessage["toId"] as? String ?? ""
                let isDeletedFrom = receivedMessage["isDeletedFrom"] as? String ?? ""
                let timestamp = Int(receivedMessage["timestamp"] as? String ?? "")
                let sendername = receivedMessage["sendername"] as? String ?? ""
                let senderProfile = receivedMessage["senderProfile"] as? String ?? ""
                let recname = receivedMessage["recname"] as? String ?? ""
                let recProfile = receivedMessage["recProfile"] as? String ?? ""
                let unread = receivedMessage["un_read"] as? String ?? ""
                let isBlockedYou = receivedMessage["isBlockedYou"] as? Bool ?? false
                let isBlockedByYou = receivedMessage["isBlockedByYou"] as? Bool ?? false
                let blockByUser = receivedMessage["blockByUser"] as? String ?? ""
                
                if isDeletedFrom != MEMBER_ID{
                   if fromID == MEMBER_ID {
                       let message = Messages.init(type: messageType, content: content, owner: .sender, timestamp: timestamp ?? 0, sendername: sendername, senderProfile: senderProfile, recname: recname, recProfile: recProfile, un_read:unread, fromId: fromID, toId:toId,isBlockedYou:isBlockedYou,isBlockedByYou:isBlockedByYou,blockByUser:blockByUser)
                       completion(message)
                   } else {
                       let message = Messages.init(type: messageType, content: content, owner: .reciever, timestamp: timestamp ?? 0, sendername: recname, senderProfile: recProfile, recname: sendername, recProfile: senderProfile, un_read:unread, fromId: fromID,toId: toId,isBlockedYou:isBlockedYou,isBlockedByYou:isBlockedByYou,blockByUser:blockByUser)
                       completion(message)
                   }
               }
            }
        })
    }
    
    //MARK: - Method to download all messages
    class func downloadAllMessages(forId:String,completion:@escaping(Messages)->Void){
        Database.database().reference().child(USERSCHATKEY).child(MEMBER_ID).child("conversations").child(forId).observe(.value, with: { (snapshot) in
            if snapshot.exists() {
                
                let data = snapshot.value as? [String: Any] ?? [:]
                if data["message"] == nil{}else{
                    let location = data["message"] as? String ?? ""
                    Database.database().reference().child(CHATCONVERSIONKEY).child(location).observe(.childAdded, with: { (snap) in
                        
                        if snap.exists() {
                            let receivedMessage = snap.value as! [String: Any]
                            let messageType = receivedMessage["type"] as? String ?? ""
                            let content = receivedMessage["content"] as? String ?? ""
                            let fromID = receivedMessage["fromId"] as? String ?? ""
                            let toId = receivedMessage["toId"] as? String ?? ""
                            let isDeletedFrom = receivedMessage["isDeletedFrom"] as? String ?? ""
                            let timestamp = Int(receivedMessage["timestamp"] as? String ?? "")
                            let sendername = receivedMessage["sendername"] as? String ?? ""
                            let senderProfile = receivedMessage["senderProfile"] as? String ?? ""
                            let recname = receivedMessage["recname"] as? String ?? ""
                            let recProfile = receivedMessage["recProfile"] as? String ?? ""
                            let unread = receivedMessage["un_read"] as? String ?? ""
                            let isBlockedYou = receivedMessage["isBlockedYou"] as? Bool ?? false
                            let isBlockedByYou = receivedMessage["isBlockedByYou"] as? Bool ?? false
                            let blockByUser = receivedMessage["blockByUser"] as? String ?? ""
                            
                            if isDeletedFrom != MEMBER_ID{
                               if fromID == MEMBER_ID {
                                   let message = Messages.init(type: messageType, content: content, owner: .sender, timestamp: timestamp ?? 0, sendername: sendername, senderProfile: senderProfile, recname: recname, recProfile: recProfile, un_read:unread, fromId: fromID, toId:toId,isBlockedYou:isBlockedYou,isBlockedByYou:isBlockedByYou, blockByUser: blockByUser)
                                   completion(message)
                               } else {
                                   let message = Messages.init(type: messageType, content: content, owner: .reciever, timestamp: timestamp ?? 0, sendername: recname, senderProfile: recProfile, recname: sendername, recProfile: senderProfile, un_read:unread, fromId: fromID,toId: toId,isBlockedYou:isBlockedYou,isBlockedByYou:isBlockedByYou,blockByUser: blockByUser)
                                   completion(message)
                               }
                           }
                        }
                    })
                    
                    
                }
            }
        })
    }
    
    
   

    /*func loadNextPageOfMessages() {
        var query = Database.database().reference().queryOrderedByKey()
        
        if let lastKey = lastLoadedMessageKey {
            query = query.queryStarting(atValue: lastKey)
        }
        
        query = query.queryLimited(toFirst: UInt(pageSize))
        
        query.observeSingleEvent(of: .value) { snapshot in
            guard let messagesSnapshot = snapshot.children.allObjects as? [DataSnapshot] else {
                return
            }
            
            // Process and display the retrieved messages
            
            if let lastMessage = messagesSnapshot.last {
                self.lastLoadedMessageKey = lastMessage.key
            }
        }
        
        // Listen for new child added events
        query.observe(.childAdded) { snapshot in
            // Process and display the newly added message
            
            // Update lastLoadedMessageKey if necessary
            if snapshot.key > self.lastLoadedMessageKey {
                self.lastLoadedMessageKey = snapshot.key
            }
        }
    }*/

    
    
    //MARK: - Prepare Message to send
    class func sendMessage(isFromClubChat:Bool = false,type:String,message:Messages,toID:String,fromId:String,sendername:String,senderProfile:String,recname:String,recProfile:String, imageUrl:String,completion:@escaping(Bool)->Void){
        if type == "text" {
            let values=["type":type,"content":message.content,"fromId":fromId,"toId":toID,"isDeletedFrom":"","timestamp":"\(message.timestamp)","sendername":sendername,"senderProfile":senderProfile,"recname":recname,"recProfile":recProfile,"un_read":message.un_read]
            
            self.uploadMessage(isFromClubChat: isFromClubChat,withValues:values, sendername:sendername,senderProfile:senderProfile,recname:recname,recProfile:recProfile,currentUserId: fromId,toId:toID, fromId: fromId, lastmsg:message.content as? String ?? "", timeStamp: message.timestamp, content: message.content as? String ?? "" ,completion:{(status) in
                completion(status)
            })
        }else{
            let values=["type":type,"content":message.content,"fromId":fromId,"toId":toID,"isDeletedFrom":"","timestamp":"\(message.timestamp)","sendername":sendername,"senderProfile":senderProfile,"recname":recname,"recProfile":recProfile,"un_read":message.un_read]
            
            self.uploadImageMeassage(isFromClubChat:isFromClubChat,withValues:values, sendername:sendername,senderProfile:senderProfile,recname:recname,recProfile:recProfile,currentUserId: fromId,toId:toID, fromId: fromId,completion:{(status) in
                completion(status)
            })
            
        }
    }
    
    class func uploadImageMeassage(isFromClubChat:Bool = false,withValues:[String:Any],sendername:String,senderProfile:String,recname:String,recProfile:String,currentUserId:String,toId:String ,fromId:String,completion: @escaping(Bool)->Void){
        Database.database().reference().child(isFromClubChat ? CLUBSCHATKEY : USERSCHATKEY).child(currentUserId).child("conversations").child(toId).observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.exists(){
                let data=snapshot.value as? [String:Any] ?? [:]
                //Below variable hold the unique key for chat
                let location=data["message"] as? String ?? ""
                if location == ""{
                    var conId = Database.database().reference().child(CHATCONVERSIONKEY).childByAutoId()
                    
                    conId.childByAutoId().setValue(withValues, withCompletionBlock: { (error, reference) in
                        let data=["message":reference.parent?.key,"sendername":sendername,
                                  "senderProfile":senderProfile,"recname":recname,"recProfile":recProfile,"toId":toId,"fromId":fromId]
                        
                        Database.database().reference().child(USERSCHATKEY).child(currentUserId).child("conversations").child(toId).updateChildValues(data) { (err, references) in
                            Database.database().reference().child("Users").child(toId).child("conversations").child(currentUserId).updateChildValues(data) { (err, refrense) in
                                self.checkUserIsOnlineAndChatWithYou(isFromClubChat: isFromClubChat,userID: toId) { isOnline in
                                    if isOnline == false{
                                        if let _ = getFromUserDefaultForKey(key_googleAccessToken) as? String {
                                            self.sendPushNotification(senderName: sendername, userId: fromId, toId: toId, conversationId: conId.key ?? "", message: "\(sendername) sent you a image")
                                        }else{
                                            appDelegateShared.CallAPIGetGoogleAccessToken { result, error in
                                                self.sendPushNotification(senderName: sendername, userId: fromId, toId: toId, conversationId: conId.key ?? "", message: "\(sendername) sent you a image")
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        completion(true)
                    })
                }else{
                    Database.database().reference().child(CHATCONVERSIONKEY).child(location).childByAutoId().setValue(withValues, withCompletionBlock:{(error,_) in
                        if error == nil {
                            self.checkUserIsOnlineAndChatWithYou(isFromClubChat: isFromClubChat,userID: toId) { isOnline in
                                //send push notification
                                if isOnline == false{
                                    if let _ = getFromUserDefaultForKey(key_googleAccessToken) as? String {
                                        self.sendPushNotification(senderName: sendername, userId: fromId, toId: toId, conversationId: location ?? "", message: "\(sendername) sent you a image")
                                    }else{
                                        appDelegateShared.CallAPIGetGoogleAccessToken { result, error in
                                            self.sendPushNotification(senderName: sendername, userId: fromId, toId: toId, conversationId: location ?? "", message: "\(sendername) sent you a image")
                                        }
                                    }
                                }
                                
                            }
                            
                            
                            completion(true)
                        }else{
                            completion(false)
                        }
                        
                    })
                }
            } else {
                var conId = Database.database().reference().child(CHATCONVERSIONKEY).childByAutoId()
                
                conId.childByAutoId().setValue(withValues, withCompletionBlock: { (error, reference) in
                    let data=["message":reference.parent?.key,"sendername":sendername,
                              "senderProfile":senderProfile,"recname":recname,"recProfile":recProfile,"toId":toId,"fromId":fromId]
                    
                    Database.database().reference().child(USERSCHATKEY).child(currentUserId).child("conversations").child(toId).updateChildValues(data) { (err, references) in
                        Database.database().reference().child("Users").child(toId).child("conversations").child(currentUserId).updateChildValues(data) { (err, refrense) in
                            self.checkUserIsOnlineAndChatWithYou(isFromClubChat: isFromClubChat,userID: toId) { isOnline in
                                if isOnline == false{
                                    if let _ = getFromUserDefaultForKey(key_googleAccessToken) as? String {
                                        self.sendPushNotification(senderName: sendername, userId: fromId, toId: toId, conversationId: conId.key ?? "", message: "\(sendername) sent you a image")
                                    }else{
                                        appDelegateShared.CallAPIGetGoogleAccessToken { result, error in
                                            self.sendPushNotification(senderName: sendername, userId: fromId, toId: toId, conversationId: conId.key ?? "", message: "\(sendername) sent you a image")
                                        }
                                    }
                                }
                            }
                        }
                    }
                    completion(true)
                })
            }
        })
        
    }
    
    //MARK: - Upload Message to firebase
    class func uploadMessage(isFromClubChat:Bool = false,withValues:[String:Any],sendername:String,senderProfile:String,recname:String,recProfile:String,currentUserId:String,toId:String,fromId:String,lastmsg:String,timeStamp:Int,content:String,completion: @escaping(Bool)->Void){
        let stamp:String = String(timeStamp)
        
        Database.database().reference().child(isFromClubChat ? CLUBSCHATKEY : USERSCHATKEY).child(currentUserId).child("conversations").child(toId).observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.exists(){
                let data=snapshot.value as? [String:Any] ?? [:]
                //Below variable hold the unique key for chat
                let location = data["message"] as? String ?? ""
                if location == ""{
                        var conId = Database.database().reference().child(CHATCONVERSIONKEY).childByAutoId()
                        conId.childByAutoId().setValue(withValues, withCompletionBlock: { (error, reference) in
                            let senderData = ["message":reference.parent?.key ?? "","lastmessage":lastmsg,"sendername":sendername,
                                              "senderProfile":senderProfile,"recname":recname,"recProfile":recProfile,"toId":toId,"fromId":fromId,"timestamp":stamp,"count":0]    //timeStamp

                               let recivData = ["message":reference.parent?.key ?? "","lastmessage":lastmsg,"sendername":recname,
                                                "senderProfile":recProfile,"recname":sendername,"recProfile":senderProfile,"toId":fromId,"fromId":toId,"timestamp":stamp]
                            Database.database().reference().child(isFromClubChat ? CLUBSCHATKEY : USERSCHATKEY).child(currentUserId).child("conversations").child(toId).updateChildValues(senderData) { (err, references) in
                                Database.database().reference().child(isFromClubChat ? CLUBSCHATKEY : USERSCHATKEY).child(toId).child("conversations").child(currentUserId).updateChildValues(recivData) { (err, references) in
                                    print(references.key)
                                    //self.updateUnreadCount(isFromClubChat:isFromClubChat,userID: toId)
                                    self.checkUserIsOnlineAndChatWithYou(isFromClubChat: isFromClubChat,userID: toId) { isOnline in
                                        if isOnline == false{
                                            self.updateUnreadCount(isFromClubChat:isFromClubChat,userID: toId)
                                            if let _ = getFromUserDefaultForKey(key_googleAccessToken) as? String {
                                                self.sendPushNotification(senderName: sendername, userId: fromId, toId: toId, conversationId: conId.key ?? "", message: "\(content)")
                                            }else{
                                                appDelegateShared.CallAPIGetGoogleAccessToken { result, error in
                                                    self.sendPushNotification(senderName: sendername, userId: fromId, toId: toId, conversationId: conId.key ?? "", message: "\(content)")
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            completion(true)
                        })
                }else{
                    
                    Database.database().reference().child(CHATCONVERSIONKEY).child(location).childByAutoId().setValue(withValues, withCompletionBlock:{(error,_) in
                        if error == nil {
                            self.checkUserIsOnlineAndChatWithYou(isFromClubChat: isFromClubChat,userID: toId) { isOnline in
                                if isOnline == false{
                                    self.updateUnreadCount(isFromClubChat:isFromClubChat,userID: toId)
                                    if let _ = getFromUserDefaultForKey(key_googleAccessToken) as? String {
                                        self.sendPushNotification(senderName: sendername, userId: fromId, toId: toId, conversationId: location ?? "", message: "\(content)")
                                    }else{
                                        appDelegateShared.CallAPIGetGoogleAccessToken { result, error in
                                            self.sendPushNotification(senderName: sendername, userId: fromId, toId: toId, conversationId: location ?? "", message: "\(content)")
                                        }
                                    }
                                }
                                
                            }
                            
                            
                            completion(true)
                        }else{
                            completion(false)
                        }
                        
                    })
                    
                }
            } else {
                var conId = Database.database().reference().child(CHATCONVERSIONKEY).childByAutoId()
                
                
                conId.childByAutoId().setValue(withValues, withCompletionBlock: { (error, reference) in
                    let senderData = ["message":reference.parent?.key ?? "","lastmessage":lastmsg,"sendername":sendername,
                                      "senderProfile":senderProfile,"recname":recname,"recProfile":recProfile,"toId":toId,"fromId":fromId,"timestamp":stamp,"count":0]    //timeStamp

                       let recivData = ["message":reference.parent?.key ?? "","lastmessage":lastmsg,"sendername":recname,
                                        "senderProfile":recProfile,"recname":sendername,"recProfile":senderProfile,"toId":fromId,"fromId":toId,"timestamp":stamp]
                    Database.database().reference().child(isFromClubChat ? CLUBSCHATKEY : USERSCHATKEY).child(currentUserId).child("conversations").child(toId).updateChildValues(senderData) { (err, references) in
                        Database.database().reference().child(isFromClubChat ? CLUBSCHATKEY : USERSCHATKEY).child(toId).child("conversations").child(currentUserId).updateChildValues(recivData) { (err, references) in
                            print(references.key)
                            //self.updateUnreadCount(isFromClubChat:isFromClubChat,userID: toId)
                            self.checkUserIsOnlineAndChatWithYou(isFromClubChat: isFromClubChat,userID: toId) { isOnline in
                                if isOnline == false{
                                    self.updateUnreadCount(isFromClubChat:isFromClubChat,userID: toId)
                                    if let _ = getFromUserDefaultForKey(key_googleAccessToken) as? String {
                                        self.sendPushNotification(senderName: sendername, userId: fromId, toId: toId, conversationId: conId.key ?? "", message: "\(content)")
                                    }else{
                                        appDelegateShared.CallAPIGetGoogleAccessToken { result, error in
                                            self.sendPushNotification(senderName: sendername, userId: fromId, toId: toId, conversationId: conId.key ?? "", message: "\(content)")
                                        }
                                    }
                                }
                                
                            }
                            
                        }
                    }
                    completion(true)
                })
            }
        })
    }
    
   class func addClubDataFirstTime(dict:JSON){
       Database.database().reference().child(CLUBSCHATKEY).child(dict["club_code"].stringValue).child("conversations").child(MEMBER_ID).observeSingleEvent(of: .value, with: { (snapshot) in
           if snapshot.exists(){
           }else{
               var conId = Database.database().reference().child(CHATCONVERSIONKEY).childByAutoId()
               let senderData = ["message":conId.key ?? "","lastmessage":"","sendername":dict["club_name"].stringValue,
                                 "senderProfile":"","recname":appDelegateShared.nameU,"recProfile":"","toId":MEMBER_ID,"fromId":dict["club_code"].stringValue,"timestamp":"0","count":0,"isBannedByClub":false,"isDeletedByClub":false] as [String : Any]    //timeStamp

                  let recivData = ["message":conId.key ?? "","lastmessage":"","sendername":dict["club_name"].stringValue,
                                   "senderProfile":"","recname":appDelegateShared.nameU,"recProfile":"","toId":MEMBER_ID,"fromId":dict["club_code"].stringValue,"timestamp":"0","isBannedByClub":false,"isDeletedByClub":false] as [String : Any]
               
               Database.database().reference().child(CLUBSCHATKEY).child(dict["club_code"].stringValue).child("conversations").child(MEMBER_ID).updateChildValues(senderData) { (err, references) in
                   Database.database().reference().child(CLUBSCHATKEY).child(MEMBER_ID).child("conversations").child(dict["club_code"].stringValue).updateChildValues(recivData) { (err, references) in
                       print(references.key)
                   }
               }
           }
       })
    }
    
    //MARK: - Block user by me
    class func blockUserByMe(isFromClubChat:Bool = false,senderUserId:String,receiverUserId:String){
        Database.database().reference().child(USERSCHATKEY).child(senderUserId).child("conversations").child(receiverUserId).child("blockByUser").setValue(senderUserId as? String ?? "")
        Database.database().reference().child(USERSCHATKEY).child(receiverUserId).child("conversations").child(senderUserId).child("blockByUser").setValue(senderUserId as? String ?? "")
    }
    //MARK: - UnBlock user by me
    class func unBlockUserByMe(isFromClubChat:Bool = false,senderUserId:String,receiverUserId:String){
        Database.database().reference().child(USERSCHATKEY).child(senderUserId).child("conversations").child(receiverUserId).child("blockByUser").removeValue()
        Database.database().reference().child(USERSCHATKEY).child(receiverUserId).child("conversations").child(senderUserId).child("blockByUser").removeValue()
    }
    
    //MARK: - UnFriend user by me
    class func unFriendUserByMe(senderUserId:String,receiverUserId:String){
        Database.database().reference().child(USERSCHATKEY).child(senderUserId).child("conversations").child(receiverUserId).observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.exists(){
                Database.database().reference().child(USERSCHATKEY).child(senderUserId).child("conversations").child(receiverUserId).child("isUnFriend").setValue(true)
                Database.database().reference().child(USERSCHATKEY).child(senderUserId).child("conversations").child(receiverUserId).child("unFriendByUserId").setValue(senderUserId as? String ?? "")
                
                Database.database().reference().child(USERSCHATKEY).child(receiverUserId).child("conversations").child(senderUserId).child("isUnFriend").setValue(true)
                Database.database().reference().child(USERSCHATKEY).child(receiverUserId).child("conversations").child(senderUserId).child("unFriendByUserId").setValue(senderUserId as? String ?? "")
            }
        })
        
    }
    //MARK: - Friend user by me
    class func friendUserByMe(senderUserId:String,receiverUserId:String){
        Database.database().reference().child(USERSCHATKEY).child(senderUserId).child("conversations").child(receiverUserId).observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.exists(){
                Database.database().reference().child(USERSCHATKEY).child(senderUserId).child("conversations").child(receiverUserId).child("isUnFriend").setValue(false)
                Database.database().reference().child(USERSCHATKEY).child(senderUserId).child("conversations").child(receiverUserId).child("unFriendByUserId").removeValue()
                
                Database.database().reference().child(USERSCHATKEY).child(receiverUserId).child("conversations").child(senderUserId).child("isUnFriend").setValue(false)
                Database.database().reference().child(USERSCHATKEY).child(receiverUserId).child("conversations").child(senderUserId).child("unFriendByUserId").removeValue()
            }
        })
        
    }
    
//    //MARK: - UnBlock user by me
//    class func unFriendUserByMe(senderUserId:String,receiverUserId:String){
//        Database.database().reference().child(USERSCHATKEY).child(senderUserId).child("conversations").child(receiverUserId).child("blockByUser").removeValue()
//        Database.database().reference().child(USERSCHATKEY).child(receiverUserId).child("conversations").child(senderUserId).child("blockByUser").removeValue()
//    }
    
    //MARK: - Update Last message in both users when send message
    class func updateLastMessageForUsers(isFromClubChat:Bool = false,lastMessage:String,timestamp:Int,receiverID:String){
        Database.database().reference().child(isFromClubChat ? CLUBSCHATKEY : USERSCHATKEY).child(MEMBER_ID).child("conversations").child(receiverID).observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.exists(){
                let data=snapshot.value as? [String:Any] ?? [:]
                //Below variable hold the unique key for chat
                let location=data["message"] as? String ?? ""
                if location == nil{
                }else{
                    Database.database().reference().child(isFromClubChat ? CLUBSCHATKEY : USERSCHATKEY).child(MEMBER_ID).child("conversations").child(receiverID).updateChildValues(["lastmessage":lastMessage,"timestamp":"\(timestamp)"]) //timeStamp
                    Database.database().reference().child(isFromClubChat ? CLUBSCHATKEY : USERSCHATKEY).child(receiverID).child("conversations").child(MEMBER_ID).updateChildValues(["lastmessage":lastMessage,"timestamp":"\(timestamp)"]) //timeStamp
                }}
        })
    }
   
    //MARK: - Update user message count
    class func updateUnreadCount(isFromClubChat:Bool = false,userID:String,isIncreaseCount:Bool = true){
        // Get the unread count reference
        var currentCount = 0
        let unreadCountRef = Database.database().reference().child(isFromClubChat ? CLUBSCHATKEY : USERSCHATKEY).child(userID).child("conversations").child(MEMBER_ID).child("count")

        // Increase the count using a transaction
        unreadCountRef.runTransactionBlock({ (currentData) -> TransactionResult in
            currentCount = currentData.value as? Int ?? 0  // If the current count doesn't exist, assume 0 unread messages
            var updatedCount = currentCount + 1
            
            
            
            currentData.value = updatedCount
            return TransactionResult.success(withValue: currentData)
        }, andCompletionBlock: { (error, _, _) in
            if let error = error {
                print("Error increasing unread count: \(error.localizedDescription)")
            } else {
                if isIncreaseCount{
                    print("Unread count increased successfully!")
//                    updateTotalUnreadCount(isFromClubChat:isFromClubChat,userID: userID,isIncreaseCount:true)
                }else{
                    print("Unread count Decreased successfully!")
//                    updateTotalUnreadCount(isFromClubChat:isFromClubChat,userID: userID,count: currentCount, isIncreaseCount: false)
                }
            }
        })
    }
    
    class func decreaseUnreadCount(isFromClubChat:Bool = false,userID:String){
        var currentCount = 0
        Database.database().reference().child(isFromClubChat ? CLUBSCHATKEY : USERSCHATKEY).child(MEMBER_ID).child("conversations").child(userID).observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.exists(){
                // Get the unread count reference
                let unreadCountRef = Database.database().reference().child(isFromClubChat ? CLUBSCHATKEY : USERSCHATKEY).child(MEMBER_ID).child("conversations").child(userID).child("count")

                // Increase the count using a transaction
                unreadCountRef.runTransactionBlock({ (currentData) -> TransactionResult in
                    currentCount = currentData.value as? Int ?? 0  // If the current count doesn't exist, assume 0 unread messages
                    
                    
                    currentData.value = 0
                    return TransactionResult.success(withValue: currentData)
                }, andCompletionBlock: { (error, _, _) in
                    if let error = error {
                        print("Error increasing unread count: \(error.localizedDescription)")
                    } else {
//                        updateTotalUnreadCount(userID: MEMBER_ID,count: currentCount, isIncreaseCount: false)
                        print("Unread count decreased successfully!")
                    }
                })
            }})
    }
    
    class func decreaseUnreadCountToZero(isFromClubChat:Bool = false,userID:String){
        Database.database().reference().child(isFromClubChat ? CLUBSCHATKEY : USERSCHATKEY).child(MEMBER_ID).child("conversations").child(userID).child("count").observeSingleEvent(of: .value, with: { (snapshot) in
            print("Count is :- \(snapshot as? Int ?? 0)")
            Database.database().reference().child(isFromClubChat ? CLUBSCHATKEY : USERSCHATKEY).child(MEMBER_ID).child("conversations").child(userID).child("count").setValue(0)
//            updateTotalUnreadCount(userID: MEMBER_ID,count: snapshot.value as? Int ?? 0, isIncreaseCount: false)
        })
        /*
        Database.database().reference().child(isFromClubChat ? CLUBSCHATKEY : USERSCHATKEY).child(MEMBER_ID).child("conversations").child(userID).observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.exists(){
                // Get the unread count reference
                let unreadCountRef = Database.database().reference().child(isFromClubChat ? CLUBSCHATKEY : USERSCHATKEY).child(MEMBER_ID).child("conversations").child(userID).child("count")

                // Increase the count using a transaction
                unreadCountRef.runTransactionBlock({ (currentData) -> TransactionResult in
                    var currentCount = currentData.value as? Int ?? 0  // If the current count doesn't exist, assume 0 unread messages
                    updateTotalUnreadCount(userID: MEMBER_ID,count: currentCount, isIncreaseCount: false)
                    
                    currentData.value = 0
                    return TransactionResult.success(withValue: currentData)
                }, andCompletionBlock: { (error, _, _) in
                    if let error = error {
                        print("Error increasing unread count: \(error.localizedDescription)")
                    } else {
                        print("Unread count increased successfully!")
                    }
                })
            }})*/
    }
    
    //set User chat with you or not
    class func setUserConversationWithYou(isFromClubChat:Bool = false,userID:String,isOnline:Bool){
        Database.database().reference().child(isFromClubChat ? CLUBSCHATKEY : USERSCHATKEY).child(userID).child("conversations").child(MEMBER_ID).child("isOnline").setValue(isOnline)
        
    }
    //check User chat with you or not
    class func checkUserIsOnlineAndChatWithYou(isFromClubChat:Bool = false,userID:String,completion: @escaping(Bool)->Void){
        Database.database().reference().child(isFromClubChat ? CLUBSCHATKEY : USERSCHATKEY).child(MEMBER_ID).child("conversations").child(userID).child("isOnline").observeSingleEvent(of: .value, with: { (snapshot) in
            print("isOnline :- \(snapshot.value as? Bool ?? false)")
            completion(snapshot.value as? Bool ?? false)
        })
    }
    
    //MARK: - Update user total message count for global
    class func updateTotalUnreadCount(isFromClubChat:Bool = false,userID:String,count:Int = 1,isIncreaseCount : Bool = true){
        Database.database().reference().child(isFromClubChat ? CLUBSCHATKEY : USERSCHATKEY).child(userID).child("totalUnreadCount").observeSingleEvent(of: .value, with: { (snapshot) in
            print("Count is :- \(snapshot.value as? Int ?? 0)")
            let currentCount = snapshot.value as? Int ?? 0
            var updatedCount = currentCount
            if isIncreaseCount{
                updatedCount = currentCount + count
            }else{
                updatedCount = currentCount - count
                if updatedCount < 0{
                    updatedCount = 0
                }
            }
            Database.database().reference().child(isFromClubChat ? CLUBSCHATKEY : USERSCHATKEY).child(userID).child("totalUnreadCount").setValue(updatedCount)
        })
        
        /*
        // Get the unread count reference
        let unreadCountRef = Database.database().reference().child(isFromClubChat ? CLUBSCHATKEY : USERSCHATKEY).child(userID).child("totalUnreadCount")

        // Increase the count using a transaction
        unreadCountRef.runTransactionBlock({ (currentData) -> TransactionResult in
            let currentCount = currentData.value as? Int ?? 0  // If the current count doesn't exist, assume 0 unread messages
            var updatedCount = currentCount
            if isIncreaseCount{
                updatedCount = currentCount + count
            }else{
                updatedCount = currentCount - count
                if updatedCount < 0{
                    updatedCount = 0
                }
            }
            currentData.value = updatedCount
            return TransactionResult.success(withValue: currentData)
            
            
        }, andCompletionBlock: { (error, _, _) in
            if let error = error {
                print("Error increasing unread count: \(error.localizedDescription)")
            } else {
                print("Unread count increased successfully!")
            }
        })*/
    }
    
    
    //MARK: - Get Total unread count
    class func getTotalUnreadCount(completion: @escaping(String)->Void){
        Database.database().reference().child(USERSCHATKEY).child(MEMBER_ID).child("totalUnreadCount").observe(.value, with: { (snapshot) in
            Database.database().reference().child(CLUBSCHATKEY).child(MEMBER_ID).child("totalUnreadCount").observeSingleEvent(of: .value) { childSnap in
                let totalCount = (snapshot.value as? Int ?? 0) +  (childSnap.value as? Int ?? 0)
                completion("\(totalCount)")
            }
        })
        Database.database().reference().child(CLUBSCHATKEY).child(MEMBER_ID).child("totalUnreadCount").observe(.value, with: { (snapshot) in
            Database.database().reference().child(USERSCHATKEY).child(MEMBER_ID).child("totalUnreadCount").observeSingleEvent(of: .value) { childSnap in
                let totalCount = (snapshot.value as? Int ?? 0) +  (childSnap.value as? Int ?? 0)
                completion("\(totalCount)")
            }
        })
    }
    
      //MARK: - Method to download all messages
        class func readMark(isFromClubChat:Bool = false,content:[Int],currentUserId:String,fromId:String,completion: @escaping(Bool)->Void){
            Database.database().reference().child(isFromClubChat ? CLUBSCHATKEY : USERSCHATKEY).child(currentUserId).child("conversations").child(fromId).observeSingleEvent(of:.value, with: { (snapshot) in
                if snapshot.exists() {
                    let data = snapshot.value as! [String: String]
                    if data["message"] == nil{}else{
                        let location = data["message"]!
                        for contents in content{

                                Database.database().reference().child(CHATCONVERSIONKEY).child(location).queryOrdered(byChild: "timestamp").queryEqual(toValue: contents).observe(.value, with: { (snapshot) in
                                    if snapshot.exists(){
                                        if let messages = snapshot.value as? [String:[String:AnyObject]]{
                                            for (key, _) in messages{
                                                Database.database().reference().child(CHATCONVERSIONKEY).child(location).child(key).observeSingleEvent(of: .value, with: { (snapshot) in
                                                    if snapshot.exists(){

                                                        let msg = snapshot.value as! [String:Any]
                                                        let fromID = msg["fromId"] as! String
                                                        let toID = msg["toId"] as! String

                                                        if currentUserId == toID  && fromId == fromID   {

                                                Database.database().reference().child(CHATCONVERSIONKEY).child(location).child(key).updateChildValues(["un_read":"1"])
                                                            
                                                        }
                                                    }
                                                })
                                            }
                                            completion(true)
                                        }
                                    }
                                })
                        }
                    }
                }
            })
        }
//
//
//
//
    
    
    
//
//    
//    class func un_Read_Count(content:[Int],currentUserId:String,fromId:String, completion: @escaping(Bool)->Void){
//        var count = 0
//        Database.database().reference().child("Users").child(currentUserId).child("conversations").child(fromId).observeSingleEvent(of:.value, with: { (snapshot) in
//            if snapshot.exists(){
//                let data = snapshot.value as! [String:String]
//                let location = data["message"]
//                for contents in content{
//                    
//                    Database.database().reference().child("conversations").child(location!).queryOrdered(byChild: "timestamp").queryEqual(toValue: contents).observe(.value, with: { (snapshot) in
//                        if snapshot.exists(){
//                            if let messages = snapshot.value as? [String:[String:AnyObject]]{
//                                for (key, _) in messages{
//                                    Database.database().reference().child("conversations").child(location!).child(key).observe( .value, with: { (snapshot) in
//                                        if snapshot.exists(){
//                                            
//                                            let msg = snapshot.value as! [String:Any]
//                                            let to = msg["toId"] as! String
//                                            let from = msg["fromId"] as! String
//
//                                            if fromId == to && currentUserId == from {
//                                                let unread = msg["un_read"] as! String
//                                                let unread_Count = Int(unread)
//                                                if unread_Count == 0{
//                                                    count = count+1
//                                                    let sCount = String(count)
//                                                    Database.database().reference().child("Users").child(fromId).child("conversations").child(currentUserId).updateChildValues(["count":sCount])
//                                                    
//                                                }else{
//                                                    Database.database().reference().child("Users").child(fromId).child("conversations").child(currentUserId).updateChildValues(["count":"0"])
//                                                }
//                                            }
//                                            
//                                            
//                                        }
//                                        
//                                        
//                                    })
//                                }
//                                completion(true)
//                            }
//                        }
//                    })
//                    
//                }
//            }
//        })
//    }
//    
//    
   
    
    
//    //Delete Message method
//    class func deleteMessage(content:[Int],fromId:String, completion: @escaping(Bool)->Void){
//        //        print(content)
//        if let currentUserId=Auth.auth().currentUser?.uid{
//            Database.database().reference().child("Users").child(currentUserId).child("conversations").child(fromId).observe(.value, with: { (snapshot) in
//                if snapshot.exists(){
//                    let data = snapshot.value as! [String:String]
//
//                    let location = data["message"]
//                    for contents in content{
//
//                        Database.database().reference().child("conversations").child(location!).queryOrdered(byChild: "timestamp").queryEqual(toValue: contents).observe(.value, with: { (snapshot) in
//                            if snapshot.exists(){
//                                if let messages = snapshot.value as? [String:[String:AnyObject]]{
//                                    for (key, _) in messages{
//                                        Database.database().reference().child("conversations").child(location!).child(key).observe( .value, with: { (snapshot) in
//                                            if snapshot.exists(){
//                                                let msg = snapshot.value as! [String:Any]
//                                                let id = msg["isDeletedFrom"] as! String
//                                                if id != currentUserId && id != ""{
//                                                    Database.database().reference().child("conversations").child(location!).child(key).removeValue()
//                                                }else{
//                                                    Database.database().reference().child("conversations").child(location!).child(key).updateChildValues(["isDeletedFrom":currentUserId])
//                                                }
//                                            }
//                                        })
//                                    }
//                                    completion(true)
//                                }
//                            }
//                        })
//                    }
//                }
//            })
//
//        }
//    }
//
    class  func saveInFirebase(userId:String,email:String){
        var ref = Database.database().reference().child(USERSCHATKEY)
        ref.observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.childrenCount > 0 {
                if snapshot.hasChild(userId){
                }else{
                    ref=Database.database().reference().child(USERSCHATKEY)
                    let userDictionary=["email":email,"id":userId]
                    ref.child(userId).setValue(userDictionary){
                        (error,ref) in
                        if error == nil{
                            print("saved successfully")
                        }else{
                            print("user isn't saved")
                        }
                    }
                }
            }
        }
    }
    
    init(type:String,content:Any,owner:MessageOwner,timestamp:Int,sendername:String,senderProfile:String,recname:String,recProfile:String,un_read:String,fromId:String,toId:String,isBlockedYou:Bool,isBlockedByYou:Bool,blockByUser:String){
        self.sendername = sendername
        self.senderProfile = senderProfile
        self.recname = recname
        self.recProfile = recProfile
        self.owner=owner
        self.type=type
        self.content=content
        self.timestamp=timestamp
        self.un_read = un_read
        self.fromId = fromId
        self.toId = toId
        self.isBlockedYou = isBlockedYou
        self.isBlockedByYou = isBlockedByYou
        self.blockByUser = blockByUser
    }
    
    /*
    //MARK: - Extension for Push Notification
    class func sendPushNotification(senderName: String, userId: String, toId: String, conversationId: String, message: String) {
        
        /*let headers: HTTPHeaders = [
            "Authorization": "Bearer \(API_SERVER_KEY)",
            "Content-Type": "application/json"
        ]
        
        let payload = ["to" : "/topics/\(toId)",
            "priority" : "high",
            "notification" : ["sound": "default",
                              "body" : "\(message)" ,
                "title": "\(senderName)"],
            "data":["type" : NotificationType.Message.get(),
                    "userId": AlertClass.sharedInstance.GetUserID(),
                    "conversationId" : conversationId,"message": "\(message)",
                    "title": "\(senderName)",
            ]] as [String : Any]
        
        Alamofire.request(URL_FOR_PUSHNOTIFICATION, method: .post, parameters: payload, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            debugPrint(response)*/
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(API_SERVER_KEY)",
            "Content-Type": "application/json"
        ]
        
        let payload: [String: Any] = [
            "message": [
                "to": "/topics/\(toId)",
                "notification": [
                    "sound": "default",
                    "body": "\(message)",
                    "title": "\(senderName)"
                ],
                "data": [
                    "type": NotificationType.Message.get(),
                    "userId": MEMBER_ID,
                    "conversationId": conversationId,
                    "message": "\(message)",
                    "title": "\(senderName)"
                ]
            ]
        ]
        
        
        
        
        Alamofire.request(URL_FOR_PUSHNOTIFICATION, method: .post, parameters: payload, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            debugPrint(response)
        }
    }
    */
    
    class func sendPushNotification(senderName: String, userId: String, toId: String, conversationId: String, message: String,isCalledSecondTime:Bool = true) {
        FirebaseManager.sharedInstance.getUserToken(userId: toId) { userToken in
            if userToken != ""{
                let url = URL(string: URL_FOR_PUSHNOTIFICATION)!
                //let apiKey = API_SERVER_KEY // You can find this in the Firebase Console under Project Settings > Cloud Messaging

                let accessToken = getFromUserDefaultForKey(key_googleAccessToken) as? String ?? ""
                
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
                
                let messageData: [String: Any] = [
                    "message": [
                        "token": userToken,
                        "notification": [
                            "body": "\(message)",
                            "title": "\(senderName)"
                        ],
                        "data": [
                            "type": NotificationType.Message.get(),
                            "userId": MEMBER_ID,
                            "receiverId": toId,
                            "userName": "\(senderName)",
                            "conversationId": conversationId,
                            "message": "\(message)",
                            "title": "\(senderName)"
                        ],"apns" : [
                            "payload" : [
                                "aps" : [
                                    "sound" : "default",
                                    "body": "\(message)",
                                    "title": "\(senderName)"
                                ],
                            ],
                        ]
                    ]
                ]
                    // You can also use 'topic' instead of 'token' to send notifications to a topic.

                    do {
                        let jsonData = try JSONSerialization.data(withJSONObject: messageData, options: [])
                        request.httpBody = jsonData
                    } catch {
                        print("Error serializing JSON: \(error)")
                        return
                    }

                    let task = URLSession.shared.dataTask(with: request) { data, response, error in
                        if let error = error {
                            print("Error sending notification: \(error)")
                            return
                        }

                        if let data = data {
                            if let json = try? JSONSerialization.jsonObject(with: data, options: []) {
                                let dict = json as? [String:AnyObject] ?? [:]
                                print(dict["error"] as? [String:Any] ?? [:])
                                let errorObject = dict["error"] as? [String:AnyObject] ?? [:]
                                
                                if errorObject.isEmpty == false{
                                    if isCalledSecondTime{
                                        appDelegateShared.CallAPIGetGoogleAccessToken { result, error in
                                            self.sendPushNotification(senderName: senderName, userId: userId, toId: toId, conversationId: conversationId, message: message,isCalledSecondTime: false)
                                        }
                                    }
                                }
                                print("Notification sent successfully: \(json)")
                            }
                        }
                    }
                    task.resume()
            }
        }
        
    }

}



// MARK: - Adddate
class Adddate: Codable {
    let data: [Datum]
    let code, status: String
    
    init(data: [Datum], code: String, status: String) {
        self.data = data
        self.code = code
        self.status = status
    }
}

// MARK: - Datum
class Datum: Codable {
    let date: String
    
    init(date: String) {
        self.date = date
    }
}




/*

import UIKit
import Firebase

class ChatViewContrkoller: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    var messages: [Message] = []
    var lastFetchedMessageKey: String? = nil
    let messagesPerPage: UInt = 10
    
    override func viewDidLoad() {
        super.viewDidLoad()
        observeMessages()
        fetchInitialMessages()
    }
    
    func fetchInitialMessages() {
        let messagesRef = Database.database().reference().child("chat-messages")
        let query = messagesRef.queryOrderedByKey().queryLimited(toLast: messagesPerPage)
        
        query.observeSingleEvent(of: .value) { [weak self] snapshot in
            guard let self = self else { return }
            
            guard let messagesDict = snapshot.value as? [String: Any] else {
                // Handle error or empty snapshot
                return
            }
            
            let messageKeys = Array(messagesDict.keys)
            self.lastFetchedMessageKey = messageKeys.first
            
            let fetchedMessages = messageKeys.compactMap { key in
                guard let messageData = messagesDict[key] as? [String: Any],
                      let text = messageData["text"] as? String,
                      let sender = messageData["sender"] as? String else {
                    return nil
                }
                
                let message = Message(text: text, sender: sender)
                return message
            }
            
            self.messages = fetchedMessages.reversed()
            self.tableView.reloadData()
        }
    }
    
    func fetchMoreMessages() {
        guard let lastKey = lastFetchedMessageKey else {
            // No more messages to fetch
            return
        }
        
        let messagesRef = Database.database().reference().child("chat-messages")
        let query = messagesRef.queryOrderedByKey().queryEnding(atValue: lastKey).queryLimited(toLast: messagesPerPage + 1)
        
        query.observeSingleEvent(of: .value) { [weak self] snapshot in
            guard let self = self else { return }
            
            guard let messagesDict = snapshot.value as? [String: Any] else {
                // Handle error or empty snapshot
                return
            }
            
            let messageKeys = Array(messagesDict.keys)
            if messageKeys.count > 1 {
                self.lastFetchedMessageKey = messageKeys[1]
            } else {
                self.lastFetchedMessageKey = nil
            }
            
            let fetchedMessages = messageKeys.compactMap { key in
                guard let messageData = messagesDict[key] as? [String: Any],
                      let text = messageData["text"] as? String,
                      let sender = messageData["sender"] as? String else {
                    return nil
                }
                
                let message = Message(text: text, sender: sender)
                return message
            }
            
            self.messages.append(contentsOf: fetchedMessages.reversed())
            self.tableView.reloadData()
        }
    }
    
    func observeMessages() {
        let messagesRef = Database.database().reference().child("chat-messages")
        messagesRef.observe(.childAdded) { [weak self] snapshot in
            guard let self = self else { return }
            
            guard let messageData = snapshot.value as? [String: Any],
                  let text = messageData["text"] as? String,
                  let sender = messageData["sender"] as? String else {
                // Handle error or unexpected data format
                return
            }
            
            let message = Message(text: text, sender: sender)
            self.messages.append(message)
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
                let indexPath = IndexPath(row
*/
