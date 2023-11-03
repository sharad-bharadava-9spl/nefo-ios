//
//  Messages.swift
//  TraceRoute
//
//  Created by Techwin MacMini on 9/14/18.
//  Copyright © 2018 Techwin MacMini. All rights reserved.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseDatabase


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
    var image :String?
    var un_read:String
    
    //MARK: - Method to download all messages
    class func downloadAllMessages(forId:String,completion:@escaping(Messages)->Void){
        Database.database().reference().child("Users").child(AlertClass.sharedInstance.GetUserID()).child("conversations").child(forId).observe(.value, with: { (snapshot) in
            if snapshot.exists() {
                
                let data = snapshot.value as! [String: String]
                if data["message"] == nil{}else{
                    let location = data["message"]!
                    Database.database().reference().child("conversations").child(location).observe(.childAdded, with: { (snap) in
                        
                        if snap.exists() {
                            let receivedMessage = snap.value as! [String: Any]
                            let messageType = receivedMessage["type"] as! String
                            let content = receivedMessage["content"] as! String
                            let fromID = receivedMessage["fromId"] as! String
                            let toId = receivedMessage["toId"] as! String
                            let isDeletedFrom = receivedMessage["isDeletedFrom"] as! String
                            let timestamp = receivedMessage["timestamp"] as! Int
                            let sendername = receivedMessage["sendername"] as! String
                            let senderProfile = receivedMessage["senderProfile"] as! String
                            let recname = receivedMessage["recname"] as! String
                            let recProfile = receivedMessage["recProfile"] as! String
                            let unread = receivedMessage["un_read"] as! String
                            
                             if isDeletedFrom != AlertClass.sharedInstance.GetUserID(){
                                if fromID == AlertClass.sharedInstance.GetUserID() {
                                    let message = Messages.init(type: messageType, content: content, owner: .sender, timestamp: timestamp, sendername: sendername, senderProfile: senderProfile, recname: recname, recProfile: recProfile, un_read:unread, fromId: fromID, toId:toId )
                                    completion(message)
                                } else {
                                    let message = Messages.init(type: messageType, content: content, owner: .reciever, timestamp: timestamp, sendername: recname, senderProfile: recProfile, recname: sendername, recProfile: senderProfile, un_read:unread, fromId: fromID,toId: toId)
                                    completion(message)
                                }
                            }
                           
                            
                        }
                    })
                    
                }
            }
        })
    }
    
    
    //MARK: - Prepare Message to send
    class func sendMessage(type:String,message:Messages,toID:String,fromId:String,sendername:String,senderProfile:String,recname:String,recProfile:String, imageUrl:String,completion:@escaping(Bool)->Void){
        if type == "text" {
            let values=["type":type,"content":message.content,"fromId":fromId,"toId":toID,"isDeletedFrom":"","timestamp":message.timestamp,"sendername":sendername,"senderProfile":senderProfile,"recname":recname,"recProfile":recProfile,"un_read":message.un_read]
            
            self.uploadMessage(withValues:values, sendername:sendername,senderProfile:senderProfile,recname:recname,recProfile:recProfile,currentUserId: fromId,toId:toID, fromId: fromId, lastmsg:message.content as! String, timeStamp: message.timestamp ,completion:{(status) in
                completion(status)
            })
        }else{
            let values=["type":type,"content":message.content,"fromId":fromId,"toId":toID,"isDeletedFrom":"","timestamp":message.timestamp,"sendername":sendername,"senderProfile":senderProfile,"recname":recname,"recProfile":recProfile,"un_read":message.un_read]
            
            self.uploadImageMeassage(withValues:values, sendername:sendername,senderProfile:senderProfile,recname:recname,recProfile:recProfile,currentUserId: fromId,toId:toID, fromId: fromId,completion:{(status) in
                completion(status)
            })
            
        }
    }
    
    class func uploadImageMeassage(withValues:[String:Any],sendername:String,senderProfile:String,recname:String,recProfile:String,currentUserId:String,toId:String ,fromId:String,completion: @escaping(Bool)->Void){
        Database.database().reference().child("Users").child(currentUserId).child("conversations").child(toId).observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.exists(){
                let data=snapshot.value as! [String:String]
                //Below variable hold the unique key for chat
                let location=data["message"]
                if location == nil{
                }else{
                    Database.database().reference().child("conversations").child(location!).childByAutoId().setValue(withValues, withCompletionBlock:{(error,_) in
                        if error == nil {
                            completion(true)
                        }else{
                            completion(false)
                        }
                        
                    })
                }
            } else {
                
                Database.database().reference().child("conversations").childByAutoId().childByAutoId().setValue(withValues, withCompletionBlock: { (error, reference) in
                    
                    //This variable will hold the key generated by childByAutoId
                    
                    let data=["message":reference.parent?.key,"sendername":sendername,
                              "senderProfile":senderProfile,"recname":recname,"recProfile":recProfile,"toId":toId,"fromId":fromId]
                    Database.database().reference().child("Users").child(currentUserId).child("conversations").child(toId).updateChildValues(data)
                    Database.database().reference().child("Users").child(toId).child("conversations").child(currentUserId).updateChildValues(data)
                    
                    completion(true)
                })
            }
            
        })
        
    }
    
    //MARK: - Upload Message to firebase
    class func uploadMessage(withValues:[String:Any],sendername:String,senderProfile:String,recname:String,recProfile:String,currentUserId:String,toId:String,fromId:String,lastmsg:String,timeStamp:Int,completion: @escaping(Bool)->Void){
        let stamp:String = String(timeStamp)
        
        Database.database().reference().child("Users").child(currentUserId).child("conversations").child(toId).observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.exists(){
                let data=snapshot.value as! [String:String]
                //Below variable hold the unique key for chat
                let location=data["message"]
                if location == nil{
                }else{
                    Database.database().reference().child("conversations").child(location!).childByAutoId().setValue(withValues, withCompletionBlock:{(error,_) in
                        if error == nil {
                            
                            completion(true)
                        }else{
                            completion(false)
                        }
                        
                    })
                    
                }
            } else {
                
                Database.database().reference().child("conversations").childByAutoId().childByAutoId().setValue(withValues, withCompletionBlock: { (error, reference) in
                    
                    //This variable will hold the key generated by childByAutoId
                    
                    let senderData = ["message":reference.parent?.key!,"lastmessage":lastmsg,"sendername":sendername,
                                      "senderProfile":senderProfile,"recname":recname,"recProfile":recProfile,"toId":toId,"fromId":fromId,"timeStamp":stamp,"count":"0"]

                       let recivData = ["message":reference.parent?.key!,"lastmessage":lastmsg,"sendername":recname,
                                                         "senderProfile":recProfile,"recname":sendername,"recProfile":senderProfile,"toId":fromId,"fromId":toId,"timeStamp":stamp,"count":"1"]
                    Database.database().reference().child("Users").child(currentUserId).child("conversations").child(toId).updateChildValues(senderData)
                    
                    Database.database().reference().child("Users").child(toId).child("conversations").child(currentUserId).updateChildValues(recivData)
                    
                    completion(true)
                })
            }
            
        })
        
    }
    
    
    
      //MARK: - Method to download all messages
        class func readMark(content:[Int],currentUserId:String,fromId:String,completion: @escaping(Bool)->Void){
            Database.database().reference().child("Users").child(currentUserId).child("conversations").child(fromId).observeSingleEvent(of:.value, with: { (snapshot) in

                if snapshot.exists() {
                    let data = snapshot.value as! [String: String]
                    if data["message"] == nil{}else{
                        let location = data["message"]!
                        for contents in content{

                                Database.database().reference().child("conversations").child(location).queryOrdered(byChild: "timestamp").queryEqual(toValue: contents).observe(.value, with: { (snapshot) in
                                    if snapshot.exists(){
                                        if let messages = snapshot.value as? [String:[String:AnyObject]]{
                                            for (key, _) in messages{
                                                Database.database().reference().child("conversations").child(location).child(key).observeSingleEvent(of: .value, with: { (snapshot) in
                                                    if snapshot.exists(){

                                                        let msg = snapshot.value as! [String:Any]
                                                        let fromID = msg["fromId"] as! String
                                                        let toID = msg["toId"] as! String

                                                        if currentUserId == toID  && fromId == fromID   {

                                                Database.database().reference().child("conversations").child(location).child(key).updateChildValues(["un_read":"1"])
                                                            
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
        var ref = Database.database().reference().child("Users")
        ref.observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.childrenCount > 0 {
                if snapshot.hasChild(userId){
                }else{
                    ref=Database.database().reference().child("Users")
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
    
    init(type:String,content:Any,owner:MessageOwner,timestamp:Int,sendername:String,senderProfile:String,recname:String,recProfile:String,un_read:String,fromId:String,toId:String){
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
