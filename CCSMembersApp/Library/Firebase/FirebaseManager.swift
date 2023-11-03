//
//  FirebaseManager.swift
//  CCSMembersApp
//
//  Created by Divvyesh on 21/06/23.
//  Copyright © 2023 Jaimin Patel. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase
import FirebaseStorage
import SwiftyJSON



//Live/Upload Client Account
let BASE_URL_FIREBASE          =   "https://cannabis-club-system.firebaseio.com/"
let DATABASE_REFERENCE = Database.database().reference()


class FirebaseManager {
    static let sharedInstance = FirebaseManager()
    private let CHAT_ROOT = "UsersChat"
    private let USER_ROOT = "ChatConversions"
    private let USERS = "Users\(ENVIRONMENT)"
    
    
    func fetchChatData(convId: String, userId: String, onCompletion: @escaping (JSON) -> Void) {
        
    }
    
    
    func setUsersLoginData(userId:String,dict:[String:Any]){
        DATABASE_REFERENCE.child(USERS).child(userId).setValue(dict)
    }
    func getUserToken(userId:String, completion: @escaping (String) -> Void){
        DATABASE_REFERENCE.child(USERS).child(userId).child("token").observeSingleEvent(of: .value) { snapshot in
            if snapshot.exists(){
                completion(snapshot.value as? String ?? "")
            }else{
                completion("")
            }
        }
    }
    //Remove Previous user FCM Token
    func removeUserToken(userId:String,completion: @escaping () -> Void){
        DATABASE_REFERENCE.child(USERS).child(userId).child("token").observeSingleEvent(of: .value) { snapshot in
            if snapshot.exists(){
                if snapshot.value as? String ?? "" == deviceTokenString{
                    print("sucessfully removed previous user token")
                    DATABASE_REFERENCE.child(self.USERS).child(userId).child("token").removeValue()
                    completion()
                }else{
                    completion()
                }
            }else{
                completion()
            }
        }
    }
    //Update user status
    func setUserIsOnlineGlobally(loginStatus:Bool){
        DATABASE_REFERENCE.child(USERS).child(MEMBER_ID).child("isOnline").setValue(loginStatus)
    }
    /*
    func sendChatData(convId: String, userId: String, onCompletion: @escaping (JSON) -> Void) {
        DATABASE_REFERENCE.child(CHAT_ROOT).child(userId).childByAutoId().setValue(["createdAt":ServerValue.timestamp(),"id":JSON(UserDefaults.standard.object(forKey: "user_id")!).stringValue,"text":text,"user":["id":JSON(UserDefaults.standard.object(forKey: "user_id")!).stringValue,"name":JSON(UserDefaults.standard.object(forKey: "Name")!).stringValue]])
    }
     */
}
