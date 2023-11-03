//
//  APIManager.swift
//


import Foundation
import Alamofire
import SwiftyJSON
//import SVProgressHUD

//Redirect to Login
//401 = (UNAUTHORIZED) : Sorry, API key is invalid.
//403 = (FORBIDDEN) :
////417 = (Expectation Failed) : Sorry, API key is missng.
////503 = (Service Unavailable) : Header data are missing.
////505 = (HTTP Version Not Supported) : Current version of API is wrong or not supported. Please update the app.

//Show Message
//404 = (NOT_FOUND) : No data available. Message / Refresh
//405 = (METHOD_NOT_FOUND) :
//406 = (NOT_ACCEPTABLE) :
//423 = (OTHER_ERROR) :
//429 = (TOO_MANY_REQUESTS) :
//501 = (NOT_IMPLEMENTED) :
////409 = (Conflict) : User with given email / username is already exist. Pleaes try with other.
////500 = (InternalServerError) : Sorry, some internal server error occurs.

//Show Message When Required Only to Respective View Controller
//200 = (SUCCESS) : Thank you for registering. Admin will review the details and activate you to login into the application.
//204 = (NO_CONTENT) : Message / Refresh



//let URL_FOR_PUSHNOTIFICATION                = "https://fcm.googleapis.com/fcm/send"


// MARK: - API Action 
//Login
let api_Login                        =    "\(Shared().webCall)login.php/"

let api_CheckUserStatus              =    "\(Shared().webCall)checkBannedorDelete.php"
let api_DeleteUserAccount            =    "\(Shared().webCall)memberDelete.php"
let api_CheckAppVersion              =    "\(Shared().webCall)appVersion.php"
let api_RemoveFCMToken               =    "\(Shared().webCall)removefcm.php"

//Pre-registartion
let api_PreRegAddCode              =    "\(Shared().webCall)prereg.php"
let api_PreRegFirstForrm           =    "\(Shared().webCall)reg.php"
let api_PreRegSecondAForrm         =    "\(Shared().webCall)reg-2a.php"
let api_PreRegSecondBForrm         =    "\(Shared().webCall)reg-2b.php"
let api_PreRegUploadPassport       =    "\(Shared().webCall)reg-2c-upload.php"
let api_PreRegUploadProfileImage   =    "\(Shared().webCall)reg-2d-upload.php"
let api_PreRegFinalUserDetails     =    "\(Shared().webCall)reg-2.php"
let api_ChangeLanguage             =    "\(Shared().webCall)changeLanguage.php"


//Chat Module
let api_searchFriend                =    "\(Shared().webCall)searchFriend.php"
let api_globlesearchFriend          =     "\(Shared().webCall)globalFriend.php"
let api_listOfFriends               =    "\(Shared().webCall)listOfFriend.php"
let api_listOfFriendRequest         =    "\(Shared().webCall)listOfFriendRequest.php"
let api_sendFriendRequest           =    "\(Shared().webCall)friendRequest.php"
let api_acceptOrRejectRequest       =    "\(Shared().webCall)acceptOrRejectRequest.php"
let api_blockUser                   =    "\(Shared().webCall)blockuser.php"
let api_unFriendUser                =    "\(Shared().webCall)unfriend.php"
let api_searchFriendByQRCode        =    "\(Shared().webCall)userFindQrCode.php"
let api_unreadMessageCount      =    "\(Shared().webCall)unreadNotifications.php"
let api_blockAndReportUser          =    "\(Shared().webCall)blockuser.php"
let api_googleAccessToken           =    "\(Shared().webCall)getAccessToken.php"

//CCSMap
let api_filterlocation   = "\(Shared().webCall)province.php"
let api_getClubsMap      = "\(Shared().webCall)getClubsMap.php"
// MARK: - API Param
enum APIParam {
    // Login and signup
    case login(email: String, password: String, device_token: String, device_type: Int)
    case checkUserStatus(club_name: String, member_id: String, language: String)
    case deleteUserAccount(member_id: String, language: String)
    case checkAppVersion(app_version: String, platform: String, language: String)
    //-------------------
    
    // Pre Registartion Parameters
    case PreRegAddCode(code: String)
    case PreRegFirstForm(date: String,image: String)
    case PreRegSecondAForm(date: String)
    case PreRegSecondBForm(time: String)
    case PreRegUploadImage(image:String)
    //case PreRegFinalUserDetails(first_name: String,last_name: String,email: String,nationality: String,gender: String,street: String,streetnumber: String,flat: String,postcode: String,city: String,country: String,telephone: String,device_id: String,platform: String,fcm_key: String,dni: String,usage: String,day: String,month: String,year: String,tempnumber:String,orderdateDB:String,orderTime:String,club_name:String)
    case PreRegFinalUserDetails(first_name: String,last_name: String,email: String,nationality: String,gender: String,street: String,streetnumber: String,flat: String,postcode: String,city: String,country: String,telephone: String,device_id: String,platform: String,fcm_key: String,dni: String,club_code: String)
    case changeLanguage
    case removeFCMToken(memberId: String,fcmToken: String)

    
    
    //Chat Module
    case messageNotificationsCount(club_name: String, user_id: String, language: String, macAddress: String)
    case searchFriend(user_id: String, username: String, language: String,searchFriend:Bool)
    case listOfFriends(user_id: String, language: String)
    case listOfFriendRequest(user_id: String, language: String,send_request:String)
    case sendFriendRequest(user_id: String, receive_id: String, unfriend: Int, language: String)
    case acceptOrRejectRequest(user_id: String, request_id: String, language: String, request_status: Int)
    case blockUser(user_id: String, block_id: String, language: String, block_status: String,report_reason:String)
    case unFriendUser(user_id: String, unfriend_user_id: String, language: String)
    case searchFriendByQRCode(member_id: String, language: String, qrcode: String)
    
    //CCSMap
    case filterlocation(language: String)
    case getClubsMap (language: String)
    //-------------------
    func getParam() -> Parameters {
        switch self {
        case .login(let email, let password, let device_token, let device_type) :
            return ["email":email, "password":password, "device_token":device_token, "device_type":device_type] as [String:AnyObject]
            
        case .checkUserStatus(let club_name, let member_id, let language) :
            return ["club_name":club_name, "member_id":member_id, "language":language] as Parameters
        case .deleteUserAccount(let member_id, let language) :
            return ["member_id":member_id, "language":language] as Parameters
        case .checkAppVersion(let app_version, let platform, let language) :
            return ["version":app_version, "platform":platform, "language":language] as Parameters
        case .PreRegAddCode( code: let code):
            return ["code":code, "language":"\(Language.language)","member_id": UserDefaults.standard.object(forKey: "member_id") as? String ?? ""] as Parameters
        case .PreRegFirstForm(date: let date,image: let image):
            return ["date":date, "language":"\(Language.language)","image":"data:image/png;base64,\(image)","club_name":"\(appDelegateShared.preRegClubName)"] as Parameters
        case .PreRegSecondAForm(date: let date):
            return ["date":date, "language":"\(Language.language)","club_name":"\(appDelegateShared.preRegClubName)"] as Parameters
        case .PreRegSecondBForm(time: let time):
            return ["time":time, "language":"\(Language.language)","club_name":"\(appDelegateShared.preRegClubName)"] as Parameters
        case .PreRegUploadImage(image: let image):
            return ["language":"\(Language.language)","image":"data:image/png;base64,\(image)","club_name":"\(appDelegateShared.preRegClubName)","tempnumber":"\(appDelegateShared.arrPreRegistartionsData["tempnumber"].stringValue)"] as Parameters
            /*
        case .PreRegFinalUserDetails(first_name: let first_name, last_name: let last_name, email: let email, nationality: let nationality, gender: let gender, street: let street, streetnumber: let streetnumber, flat: let flat, postcode: let postcode, city: let city, country: let country, telephone: let telephone, device_id: let device_id, platform: let platform, fcm_key: let fcm_key, dni: let dni, usage: let usage, day: let day, month: let month, year: let year, tempnumber: let tempnumber, orderdateDB: let orderdateDB, orderTime: let orderTime, club_name: let club_name):
            return ["first_name":first_name, "last_name":last_name, "email":email,"nationality":nationality, "gender":gender, "street":street,"streetnumber":streetnumber, "flat":flat, "postcode":postcode,"city":city, "country":country, "telephone":telephone,"device_id":device_id, "platform":platform,"fcm_key":fcm_key,"dni":dni,"usage":usage,"day":day,"month":month, "year":year,"tempnumber":tempnumber,"order-dateDB":orderdateDB,"order-time":orderTime,"club_name":club_name] as Parameters*/
            //,"order-dateDB":"orderdateDB","order-time":"orderTime"
        case .PreRegFinalUserDetails(first_name: let first_name, last_name: let last_name, email: let email, nationality: let nationality, gender: let gender, street: let street, streetnumber: let streetnumber, flat: let flat, postcode: let postcode, city: let city, country: let country, telephone: let telephone, device_id: let device_id, platform: let platform, fcm_key: let fcm_key, dni: let dni,club_code: let club_code):
            return ["first_name":first_name, "last_name":last_name, "email":email,"nationality":nationality, "gender":gender, "street":street,"streetnumber":streetnumber, "flat":flat, "postcode":postcode,"city":city, "country":country, "telephone":telephone,"device_id":device_id, "platform":platform,"fcm_key":fcm_key,"dni":dni,"day":"\(appDelegateShared.arrPreRegistartionsData["day"].stringValue)","month": "\(appDelegateShared.arrPreRegistartionsData["month"].stringValue)", "year":"\(appDelegateShared.arrPreRegistartionsData["year"].stringValue)","tempnumber":"\(appDelegateShared.arrPreRegistartionsData["tempnumber"].stringValue)","club_name":"\(appDelegateShared.preRegClubName)","order-dateDB":"\(appDelegateShared.arrPreRegistartionsData["order-dateDB"].stringValue)","order-time":"\(appDelegateShared.arrPreRegistartionsData["order-time"].stringValue)","language":"\(Language.language)","member_id": UserDefaults.standard.object(forKey: "member_id") as? String ?? "","club_code":club_code] as Parameters
        case .changeLanguage:
            return ["member_id":UserDefaults.standard.object(forKey: "member_id") as? String ?? "", "language":"\(Language.language)"] as Parameters
        case .removeFCMToken(let memberId,let fcmToken) :
            return ["language":"\(Language.language)","member_id":memberId,"fcm_token":fcmToken] as [String:AnyObject]

            
        //Chat Module
        case .messageNotificationsCount(let club_name, let user_id, let language, let macAddress) :
            return ["club_name":club_name, "user_id":user_id, "language":language, "macAddress":macAddress] as Parameters
        case .searchFriend(let user_id, let username, let language,let searchFriend) :
            return ["user_id": user_id, "username": username, "language":language,"searchFriend":searchFriend] as Parameters
        case .listOfFriends(let user_id, let language) :
            return ["user_id": user_id, "language":language] as Parameters
        case .listOfFriendRequest(let user_id, let language,let send_request) :
            return ["user_id": user_id, "language":language,"send_request":send_request] as Parameters
        case .sendFriendRequest(let user_id, let receive_id, let unfriend, let language) :
            return ["user_id": user_id, "receive_id": receive_id, "unfriend": unfriend, "language":language] as Parameters
        case .acceptOrRejectRequest(let user_id, let request_id, let language, let request_status) :
            return ["user_id": user_id, "request_id": request_id, "language":language, "request_status":request_status] as Parameters
        case .blockUser(let user_id, let block_id, let language, let block_status, let report_reason) :
            return ["user_id": user_id, "block_id": block_id, "language":language, "block_status":block_status,"report_reason":report_reason] as Parameters
        case .unFriendUser(let user_id, let unfriend_user_id, let language) :
            return ["user_id": user_id, "unfriend_user_id":unfriend_user_id, "language":language] as Parameters
        case .searchFriendByQRCode(let member_id, let language, let qrCode) :
            return ["member_id": member_id,"language": language, "qrcode": qrCode] as Parameters
            
            //CCSMap
        case .filterlocation(language: let language):
            return [language: "language"] as Parameters
            
        case .getClubsMap(language: let language):
            return [language: "language"] as Parameters
        }
    }
}

extension  UIViewController {

    func showAlert(title : String, message :String){
        DispatchQueue.main.async {
            let uiAlert = UIAlertController(title: title, message: message , preferredStyle:.alert)
//            self.present(uiAlert, animated: true, completion: nil)
            UIApplication.shared.keyWindow?.rootViewController?.present(uiAlert, animated: true, completion: nil)
            let action = UIAlertAction(title: "Ok".localized, style: .default, handler: { action in })
            action.setValue(UIColor(named: "TextBorder"), forKey: "titleTextColor")
            uiAlert.addAction(action)
            
            //uiAlert.addAction(UIAlertAction(title: "Ok".localized, style: .default, handler: { action in }))
        }
    }
    
    func showAlert(title: String?, message: String?, buttonTitles: [String]? = nil, highlightedButtonIndex: Int? = nil, buttonStyles: [UIAlertAction.Style]? = nil, completion: ((Int) -> Void)? = nil) -> UIAlertController {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        
        //to change font of title and message.
        let titleFont = [NSAttributedString.Key.font: UIFont(name: "Roboto-Bold", size: 17.0)!]
        let messageFont = [NSAttributedString.Key.font: UIFont(name: "Roboto-Regular", size: 16.0)!,NSAttributedString.Key.foregroundColor:UIColor.black]

        let titleAttrString = NSMutableAttributedString(string: title ?? "", attributes: titleFont)
        let messageAttrString = NSMutableAttributedString(string: message ?? "", attributes: messageFont)

        alertController.setValue(titleAttrString, forKey: "attributedTitle")
        alertController.setValue(messageAttrString, forKey: "attributedMessage")
        
        
        var allButtons = buttonTitles ?? [String]()
        var allStyles = buttonStyles ?? [UIAlertAction.Style]()
        
        if allButtons.count == 0 {
            allButtons.append("OK")
        }
        
        //If no button styles are passed, default will be .default
        if allStyles.count == 0{
            for _ in 0..<allButtons.count{
                allStyles.append(.default)
            }
        }

        for index in 0..<allButtons.count {
            let buttonTitle = allButtons[index]
            let btnStyle = allStyles[index] ?? .default
            let action = UIAlertAction(title: buttonTitle, style: btnStyle, handler: { (_) in
                completion?(index)
            })
            action.setValue(UIColor(named: "TextBorder"), forKey: "titleTextColor")
            alertController.addAction(action)
            // Check which button to highlight
            if let highlightedButtonIndex = highlightedButtonIndex, index == highlightedButtonIndex {
                alertController.preferredAction = action
            }
        }
        
        alertController.view.tintColor = UIColor(named: "TextBorder") //UIColor.blue
        present(alertController, animated: true, completion: nil)
        return alertController
    }
}

// MARK: - Remove User Data: LogOut
func removeUserData() {
 
    // For force logout and set to root viewcontroller
    if let vc = (appDelegateShared.window?.rootViewController as? UINavigationController)?.viewControllers {
        for controller in vc {
            if controller.isKind(of: LoginScreenVC.self) {
                (appDelegateShared.window?.rootViewController as? UINavigationController)?.popToViewController(((appDelegateShared.window?.rootViewController as? UINavigationController)?.viewControllers[1])!, animated: false)
                break
            }
        }
    }
}

class APIManager{
    
//    let topVC = UIApplication.shared.topMostViewController()
    
    // MARK: - Check Status Code and Error
    class func checkError(UrlResponse urlResponse: DataResponse<Any>!, error: Error, message: String, showAlert : Bool){
        
//        let topVC = UIApplication.shared.topMostViewController()
        
        //In case of response code in body
        //var response = JSON(removeNulls(urlResponse.result.value as AnyObject))
        //response["ResponseCode"].intValue
        
        switch urlResponse.response!.statusCode {
        case 200:break
        //success   OR  data_found      //no alert
        case 204:break
        //success   OR  no_data_found      //no alert
        case 401, 404:      //case 400,401:break
            /*
             let _ = UIAlertController.init(title1: "", message1: message)
             self.redirectToLogin()
             */
            
            //            let topMostViewController = UIApplication.shared.inputViewController
            //            if topMostViewController!.isKind(of: UIAlertController.self) {
            //                return
            //            }
            //
            //            let window: UIWindow? = UIApplication.shared.keyWindow
            //            for controller in (window?.rootViewController as? UINavigationController)?.viewControllers as! [UIViewController] {
            //                if controller.isKind(of: UIAlertController.self) {
            //                    (window?.rootViewController as? UINavigationController)?.popToViewController(controller, animated: false)
            //                    return
            //                }
            //            }
            
            /*
             //No Message To Show
             let _ = UIAlertController(title: "", message: message, okTitle: "OK", cancelTitle: "", okCompletion: { (AlertAction
             ) in
             self.logOutUser()
             }, cancelCompletion: nil)
             */
            self.logOutUser()
            
        /*
         let _ = UIAlertController(title: "", message: message, okTitle: "Ok", cancelTitle: "Cancel", okCompletion: { (action) in
         self.redirectToLogin()
         }, cancelCompletion: nil)
         */
        
        /*let _ = UIAlertController(title: "", message: message, okTitle: nil, cancelTitle: nil, okCompletion: { (UIAlertAction) in
         self.redirectToLogin()
         }, cancelCompletion: nil)*/
        
        
        case 302:
            /*if !UIAlertController.topViewController((APP_DELEGATE.window?.rootViewController)!).isKind(of: UIAlertController.classForCoder()) {
             let _ = UIAlertController(title: "", message: message, okTitle: "Ok", cancelTitle: "", okCompletion: { (action) in
             //                    self.logOut()
             self.logOutUser()
             }, cancelCompletion: nil)
             }*/
//            let _ = UIAlertController(title: "", message: message, okTitle: "Ok", cancelTitle: "", okCompletion: { (action) in
//                self.logOutUser()
//            }, cancelCompletion: nil)
            
            UIApplication.shared.topMostViewController()!.showAlert(title: nil, message: message, buttonTitles: ["Ok"], highlightedButtonIndex: nil, completion: { (action) in
                self.logOutUser()
            })
            
            break
        default:
            //Show Message
            if showAlert {
                print("Inside Show Alert")
                UIApplication.shared.topMostViewController()!.showAlert(title: "", message: message)
//                let _ = UIAlertController.init(title1: "", message1: message)
                
            }
        }
    }
    
    // MARK: - Log Out / Sign Out
    class func redirectToLogin() {
        removeUserData()  //Add
    }
    class func logOutUser() {
        removeUserData()  //Add
    }
    
    // MARK: - Call API
    class func callAPIRequest(Method method:HTTPMethod,url:String,parameters:Parameters?,headers:Dictionary<String,String>?,showAlert:Bool, completion:  @escaping (_ result: JSON, _ headerMessage:String) -> Void,  failure:@escaping (_ httpresponse: HTTPURLResponse?,_ errorMessage: String) -> Void){
                
        let headersTemp = headers
        
        logD("💜💜💜💜💜Request Data💜💜💜💜💜\nURL:\(url)\nParams:\(String(describing: parameters))\nHeaders:\(String(describing: headersTemp))")
//        Alamofire.request(url, method: method, parameters: parameters == nil ? nil : parameters!, encoding: JSONEncoding.default, headers: headersTemp == nil ? nil : headersTemp).validate().responseJSON { response in
        Alamofire.request(url, method: .post, parameters: parameters == nil ? nil : parameters!).responseJSON { response in
            switch response.result {
            case .success:
                logD("💜💜💜💜💜Response Data💜💜💜💜💜\nresponseCode:\(String(describing: response.response?.statusCode))\nResponse String: \(String(describing: response.result.value))\n")
                
                let responseHeader = JSON(response.response!.allHeaderFields)
                let message = responseHeader["message"].stringValue     //Message   //"message" - Live
                let responseJSON = JSON(removeNulls(response.result.value as AnyObject))
                completion(responseJSON,message)
            case .failure(let error):
                
                if error._code == NSURLErrorTimedOut {
                    //timeout here
                }
                print("\n\nrequest with error:\n \(error)")
                var message = error.localizedDescription
                /*if !showAlert {
                 failure(response.response, message)
                 return
                 }*/
                if response.response != nil {
                    message = JSON(response.response!.allHeaderFields)["message"].stringValue   //Message   //"message" - Live
                    
                    //In case  of Response Message in body
                    
                    if let json = dataToJSON(data: response.data!) {
                        message = JSON(json)["message"].stringValue
                        if message == "" {
                            message = JSON(json)["message"].stringValue
                        }
                        print(JSON(json))
                    }
                    //if let json = dataToJSON2(data: response.data!) {
                    
                    if message == "" || message == "Response status code was unacceptable: 404." {
                        message = "Something went wrong!!!"
                    }
                    
                    if response.result.error != nil {
                        checkError(UrlResponse: response, error: response.result.error!, message: message, showAlert: showAlert)
                    }
                    else {
                        let errorTemp = NSError(domain:"", code:response.response!.statusCode, userInfo:nil)
                        checkError(UrlResponse: response, error: errorTemp, message: message, showAlert: showAlert)
                    }
                    //checkError(UrlResponse: response, error: response.result.error!, message: message,showAlert: showAlert)
                }
                else {
                    if showAlert {
//                        let _ = UIAlertController(title1: "", message1: message)
                        UIApplication.shared.topMostViewController()?.showAlert(title: nil, message: message)
                    }
                }
                failure(response.response, message)
            }
        }
    }
    
    // MARK: - Upload  Single Images
    class func uploadSingleImages(Method method:HTTPMethod,url:String,parameters:Parameters?,headers:Dictionary<String,String>?,imageData:Data!,uploadParamName:String,showProgress:Bool,showAlert:Bool,completion: @escaping (_ result: JSON, _ headerMessage:String) -> Void,  failure:@escaping (_ httpresponse: HTTPURLResponse?,_ errorMessage: String) -> Void, progressCompletion: @escaping (_ progress: Double) -> Void){
                
        var headersTemp = headers
        
        
        if showProgress{
            //SVProgressHUD.show()
        }
        logD("💜💜💜💜💜Request Data💜💜💜💜💜\nURL:\(url)\nParams:\(String(describing: parameters))\nHeaders:\(String(describing: headersTemp))")
        //let authorisation = Request.authorizationHeader(user: auth_user, password: auth_password);
        
        
        Alamofire.upload(multipartFormData: { multipartFormData in
            if parameters != nil
       {
                for (key,value) in  parameters!
           {
                    multipartFormData.append((value as AnyObject).data(using: String.Encoding.utf8.rawValue)!, withName: key)
                    //multipartFormData.append(data:value.data(using: String.Encoding.utf8.rawValue, allowLossyConversion: false) as! Data, name :key)
                }
            }
            //            multipartFormData.append(imageData, withName: "profileImage", fileName: uploadParamName, mimeType: "image/png")
            if imageData != nil {
                multipartFormData.append(imageData, withName: "\(uploadParamName)", fileName: uploadParamName, mimeType: "image/jpeg")
            }
            
        },usingThreshold:UInt64.init(),
        to:url,
        method:.post,
        headers:headersTemp, //headers,//authorisation,
        encodingCompletion: { encodingResult in
            switch encodingResult
       {
            case .success(let upload, _, _):
                //                upload.authenticate(user: "admin", password: "Test105*")
                /* upload.progress { (bytesWritten, totalBytesWritten, totalBytesExpectedToWrite) in
                 logD("\(totalBytesWritten) / \(totalBytesExpectedToWrite)")
                 }*/
                upload.uploadProgress(closure: { (progress) in
                    print("Upload Progress: \(progress.fractionCompleted)")
                    progressCompletion(progress.fractionCompleted)
                })
                upload.responseJSON(completionHandler: { (response) in
                    //SVProgressHUD.dismiss()
                    if response.response?.statusCode == 200
               {
                        logD("💜💜💜💜💜Response Data💜💜💜💜💜\nresponseCode:\(String(describing: response.response?.statusCode))\nResponse String: \(String(describing: response.result.value))\n")
                        
                        //let responseHeader = JSON(response.response!.allHeaderFields)
                        //                let message = JSON(response.response!.allHeaderFields)["ResponseMessage"].stringValue
                        let responseJSON = JSON(removeNulls(response.result.value as AnyObject))
                        completion(responseJSON,JSON(response.response!.allHeaderFields)["response"].stringValue)
                    }
                    else
               {
                        logD("Error:\(String(describing: response.result.error?.localizedDescription))")
                        var message = response.result.error?.localizedDescription
                        /*if !showAlert {
                         failure(response.response, message)
                         return
                         }*/
                        if response.response != nil {
                            if let json = dataToJSON(data: response.data!) {
                                message = JSON(json)["message"].stringValue
                            }
                            if response.result.error != nil {
                                checkError(UrlResponse: response, error: response.result.error!, message: message!, showAlert: showAlert)
                            }
                            else {
                                
                                let errorTemp = NSError(domain:"", code:response.response!.statusCode, userInfo:nil)
                                checkError(UrlResponse: response, error: errorTemp, message: message!, showAlert: showAlert)
                            }
                            //checkError(UrlResponse: response, error: response.result.error!, message: message!,showAlert: showAlert)
                        }
                        else {
                            if showAlert {
//                                let _ = UIAlertController(title1: "", message1: message!)
                                UIApplication.shared.topMostViewController()?.showAlert(title: nil, message: message)
                            }
                        }
                        failure(response.response, message!)
                        
                        /* //In case  of responsemessage in body
                         let message = JSON(dataToJSON(data: response.data!)!)["response"].stringValue
                         let error : Error? = NSError(domain: "somedomain", code: 123, userInfo: [:])
                         checkError(UrlResponse: response, error: error!, message: message,showAlert: showAlert)
                         failure(response.response, message)*/
                    }
                })
            case .failure(let encodingError):
                
                logD("ERROR:-\(encodingError)")
            }
        })
    }
    
    // MARK: - Upload  Multiple Images
    class func uploadMultipleImages(Method method:HTTPMethod,url:String,parameters:Dictionary<String,AnyObject>?,headers:Dictionary<String,String>?,imageData:[Data]!,uploadParamName:String,showProgress:Bool,showAlert:Bool,fileExtension:[String],isUsedExtension:Bool,completion: @escaping (_ result: JSON, _ headerMessage:String) -> Void,  failure:@escaping (_ httpresponse: HTTPURLResponse?,_ errorMessage: String) -> Void, progressCompletion: @escaping (_ progress: Double) -> Void){
        
        /* if showProgress{
         SVProgressHUD.show()
         }*/
        logD("💜💜💜💜💜Request Data💜💜💜💜💜\nURL:\(url)\nParams:\(String(describing: parameters))\nHeaders:\(String(describing: headers))")
        //let authorisation = Request.authorizationHeader(user: auth_user, password: auth_password);
        
        
        
        Alamofire.upload(multipartFormData: { multipartFormData in
            if parameters != nil{
                for (key,value) in  parameters!{
                    
                    multipartFormData.append(value.data(using: String.Encoding.utf8.rawValue)!, withName: key)
                    //multipartFormData.append(data:value.data(using: String.Encoding.utf8.rawValue, allowLossyConversion: false) as! Data, name :key)
                }
            }
            //            multipartFormData.append(imageData, withName: "profileImage", fileName: uploadParamName, mimeType: "image/png")
            if isUsedExtension {
                for (i,value) in imageData.enumerated() {
                    var exten = ""
                    if fileExtension[i] == "jpeg" || fileExtension[i] == "jpeg" {
                        exten = "image/jpeg"
                    }else {
                        exten = fileExtension[i]
                    }
                    multipartFormData.append(value, withName: "scriptImage[\(i)]", fileName: "scriptImage[\(i)].\(fileExtension[i])", mimeType: "\(exten)")
                    //image/jpeg
                }
            }else {
                for (i,value) in imageData.enumerated() {
                    multipartFormData.append(value, withName: "scriptImage[\(i)]", fileName: "scriptImage[\(i)].jpeg", mimeType: "image/jpeg")
                    //image/jpeg
                }
            }
            
            print(multipartFormData)
            
            
        },usingThreshold:UInt64.init(),
        to:url,
        method:.post,
        headers:headers,//authorisation,
        encodingCompletion: { encodingResult in
            switch encodingResult
       {
            case .success(let upload, _, _):
                //                upload.authenticate(user: "admin", password: "Test105*")
                /* upload.progress { (bytesWritten, totalBytesWritten, totalBytesExpectedToWrite) in
                 logD("\(totalBytesWritten) / \(totalBytesExpectedToWrite)")
                 }*/
                upload.uploadProgress(closure: { (progress) in
                    print("Upload Progress: \(progress.fractionCompleted)")
                    progressCompletion(progress.fractionCompleted)
                })
                upload.responseJSON(completionHandler: { (response) in
                    //SVProgressHUD.dismiss()
                    if response.response?.statusCode == 200
               {
                        logD("💜💜💜💜💜Response Data💜💜💜💜💜\nresponseCode:\(String(describing: response.response?.statusCode))\nResponse String: \(String(describing: response.result.value))\n")
                        
                        //let responseHeader = JSON(response.response!.allHeaderFields)
                        //                let message = JSON(response.response!.allHeaderFields)["ResponseMessage"].stringValue
                        let responseJSON = JSON(removeNulls(response.result.value as AnyObject))
                        completion(responseJSON,JSON(response.response!.allHeaderFields)["response"].stringValue)
                    }
                    else
               {
                        logD("Error:\(String(describing: response.result.error?.localizedDescription))")
                        var message = response.result.error?.localizedDescription
                        /*if !showAlert {
                         failure(response.response, message)
                         return
                         }*/
                        if response.response != nil {
                            if let json = dataToJSON(data: response.data!) {
                                message = JSON(json)["message"].stringValue
                            }
                            if response.result.error != nil {
                                checkError(UrlResponse: response, error: response.result.error!, message: message!, showAlert: showAlert)
                            }
                            else {
                                let errorTemp = NSError(domain:"", code:response.response!.statusCode, userInfo:nil)
                                checkError(UrlResponse: response, error: errorTemp, message: message!, showAlert: showAlert)
                            }
                            //checkError(UrlResponse: response, error: response.result.error!, message: message!,showAlert: showAlert)
                        }
                        else {
                            if showAlert {
//                                let _ = UIAlertController(title1: "", message1: message!)
                                UIApplication.shared.topMostViewController()?.showAlert(title: nil, message: message)
                            }
                        }
                        failure(response.response, message!)
                        
                        /* //In case  of responsemessage in body
                         let message = JSON(dataToJSON(data: response.data!)!)["response"].stringValue
                         let error : Error? = NSError(domain: "somedomain", code: 123, userInfo: [:])
                         checkError(UrlResponse: response, error: error!, message: message,showAlert: showAlert)
                         failure(response.response, message)*/
                    }
                })
            case .failure(let encodingError):
                
                logD("ERROR:-\(encodingError)")
            }
        })
    }
    
    
    class func uploadDataWithImages(Method method:HTTPMethod,url:String,parameters:Parameters?,headers:Dictionary<String,String>?,imageData:Data! = nil,uploadParamName:String = "",withName:String = "image",showProgress:Bool,showAlert:Bool,completion: @escaping (_ result: JSON, _ headerMessage:String) -> Void,  failure:@escaping (_ httpresponse: HTTPURLResponse?,_ errorMessage: String) -> Void, progressCompletion: @escaping (_ progress: Double) -> Void)
 {
        
        if showProgress
   {
            //SVProgressHUD.show()
        }
        logD("💜💜💜💜💜Request Data💜💜💜💜💜\nURL:\(url)\nParams:\(String(describing: parameters))\nHeaders:\(String(describing: headers))")
        //let authorisation = Request.authorizationHeader(user: auth_user, password: auth_password);
        
        
        Alamofire.upload(multipartFormData: { multipartFormData in
            if parameters != nil
       {
                
                for (key,value) in  parameters!
           {
                    
                    
                    multipartFormData.append((value as AnyObject).data(using: String.Encoding.utf8.rawValue)!, withName: key)
                    
                }
            }
            if let imageData = imageData {
                multipartFormData.append(imageData, withName: "image", fileName: "image", mimeType: "image/jpeg") //"avatar" //image/jpeg
            }
            
        },usingThreshold:UInt64.init(),
        to:url,
        method:.post,
        headers:headers,//authorisation,
        encodingCompletion: { encodingResult in
            switch encodingResult
       {
            case .success(let upload, _, _):
                //                upload.authenticate(user: "admin", password: "Test105*")
                /* upload.progress { (bytesWritten, totalBytesWritten, totalBytesExpectedToWrite) in
                 logD("\(totalBytesWritten) / \(totalBytesExpectedToWrite)")
                 }*/
                upload.uploadProgress(closure: { (progress) in
                    print("Upload Progress: \(progress.fractionCompleted)")
                    progressCompletion(0.0)
                })
                /* upload.response(completionHandler: { (response) in
                 if response.response?.statusCode == 200
            {
                 
                 }
                 else
            {
                 print("response \(response.response?.allHeaderFields)")
                 
                 
                 }
                 })
                 upload.responseString(completionHandler: { (response) in
                 
                 if response.response?.statusCode == 200
            {
                 print("response \(response.result.error?.localizedDescription)")
                 }
                 else
            {
                 print("response \(response.response?.allHeaderFields)")
                 print("response \(response.result.error?.localizedDescription)")
                 
                 }
                 })*/
                upload.responseJSON(completionHandler: { (response) in
                    //SVProgressHUD.dismiss()
                    
                    /* if let jsonData = response.data {
                     do {
                     let parsedData = try JSONSerialization.jsonObject(with: jsonData, options: .mutableLeaves) as! [String: AnyObject]
                     logD(parsedData)
                     }
                     catch let err {
                     print("\n\n===========Error===========")
                     print("Error Code: \(response.error!._code)")
                     print("Error Messsage: \(response.error!.localizedDescription)")
                     if let data = response.data, let str = String(data: data, encoding: String.Encoding.utf8) {
                     print("Server Error: " + str)
                     }
                     debugPrint(response.error as Any)
                     print("===========================\n\n")
                     
                     debugPrint(err)
                     }
                     }
                     else {
                     debugPrint(response.error as Any)
                     } */
                    if response.response?.statusCode == 200
               {
                        logD("💜💜💜💜💜Response Data💜💜💜💜💜\nresponseCode:\(String(describing: response.response?.statusCode))\nResponse String: \(String(describing: response.result.value))\n")
                        
                        //let responseHeader = JSON(response.response!.allHeaderFields)
                        //                let message = JSON(response.response!.allHeaderFields)["ResponseMessage"].stringValue
                        let responseJSON = JSON(removeNulls(response.result.value as AnyObject))
                        completion(responseJSON,JSON(response.response!.allHeaderFields)["response"].stringValue)
                    }
                    else
               {
                        
                        logD("Error:\(String(describing: response.result.error?.localizedDescription))")
                        var message = response.result.error?.localizedDescription
                        /*if !showAlert {
                         failure(response.response, message)
                         return
                         }*/
                        if response.response != nil {
                            if let json = dataToJSON(data: response.data!) {
                                message = JSON(json)["message"].stringValue
                            }
                            if response.result.error != nil {
                                checkError(UrlResponse: response, error: response.result.error!, message: message!, showAlert: showAlert)
                            }
                            else {
                                let errorTemp = NSError(domain:"", code:response.response!.statusCode, userInfo:nil)
                                checkError(UrlResponse: response, error: errorTemp, message: message!, showAlert: showAlert)
                            }
                            //checkError(UrlResponse: response, error: response.result.error!, message: message!,showAlert: showAlert)
                        }
                        else {
                            if showAlert {
//                                let _ = UIAlertController(title1: "", message1: message!)
                                UIApplication.shared.topMostViewController()?.showAlert(title: "", message: message)
                            }
                        }
                        failure(response.response, message!)
                        
                        /* //In case  of responsemessage in body
                         let message = JSON(dataToJSON(data: response.data!)!)["response"].stringValue
                         let error : Error? = NSError(domain: "somedomain", code: 123, userInfo: [:])
                         checkError(UrlResponse: response, error: error!, message: message,showAlert: showAlert)
                         failure(response.response, message)*/
                    }
                })
            case .failure(let encodingError):
                
                logD("ERROR:-\(encodingError)")
            }
        })
    }
    
    //Upload JSON File
    class func uploadDataWithFiles(Method method:HTTPMethod,url:String,parameters:Dictionary<String,AnyObject>?,headers:Dictionary<String,String>?,imageData:Data! = nil,uploadParamName:String = "",uploadFileName:String = "",showProgress:Bool,showAlert:Bool,completion: @escaping (_ result: JSON, _ headerMessage:String) -> Void,  failure:@escaping (_ httpresponse: HTTPURLResponse?,_ errorMessage: String) -> Void, progressCompletion: @escaping (_ progress: Double) -> Void){
        
        var headersTemp = headers
        
        
        if showProgress{
            //SVProgressHUD.show()
        }
        logD("💜💜💜💜💜Request Data💜💜💜💜💜\nURL:\(url)\nParams:\(String(describing: parameters))\nHeaders:\(String(describing: headers))")
        //let authorisation = Request.authorizationHeader(user: auth_user, password: auth_password);
        
        Alamofire.upload(multipartFormData: { multipartFormData in
            if parameters != nil{
                for (key,value) in  parameters!{
                    multipartFormData.append(value.data(using: String.Encoding.utf8.rawValue)!, withName: key)
                }
            }
            if let imageData = imageData {
                //multipartFormData.append(imageData, withName: uploadParamName, fileName: uploadParamName, mimeType: "application/json")
                multipartFormData.append(imageData, withName: uploadParamName, fileName: uploadFileName, mimeType: "application/json")
            }
            
        },usingThreshold:UInt64.init(),
          to:url,
          method: method, //.post
          headers:headersTemp,//authorisation,
            encodingCompletion: { encodingResult in
                switch encodingResult
           {
                case .success(let upload, _, _):
                    //upload.authenticate(user: "admin", password: "Test105*")
                    /*
                     upload.progress { (bytesWritten, totalBytesWritten, totalBytesExpectedToWrite) in
                        logD("\(totalBytesWritten) / \(totalBytesExpectedToWrite)")
                     }*/
                    upload.uploadProgress(closure: { (progress) in
                        print("Upload Progress: \(progress.fractionCompleted)")
                        progressCompletion(0.0)
                    })
                    
                    upload.responseJSON(completionHandler: { (response) in
                        //SVProgressHUD.dismiss()
                        
                        if response.response?.statusCode == 200
                   {
                            logD("💜💜💜💜💜Response Data💜💜💜💜💜\nresponseCode:\(String(describing: response.response?.statusCode))\nResponse String: \(String(describing: response.result.value))\n")
                            
                            //let responseHeader = JSON(response.response!.allHeaderFields)
                            //let message = JSON(response.response!.allHeaderFields)["ResponseMessage"].stringValue
                            let responseJSON = JSON(removeNulls(response.result.value as AnyObject))
                            completion(responseJSON,JSON(response.response!.allHeaderFields)["response"].stringValue)
                        }
                        else
                   {
                            logD("Error:\(String(describing: response.result.error?.localizedDescription))")
                            var message = response.result.error?.localizedDescription
                            /*if !showAlert {
                                failure(response.response, message)
                                return
                             }*/
                            if response.response != nil {
                                if let json = dataToJSON(data: response.data!) {
                                    message = JSON(json)["message"].stringValue
                                    
                                    if message == "" {
                                        message = JSON(json)["message"].stringValue
                                    }
                                    print(JSON(json))
                                    
                                    if message == "" {  //Iterate message in loop
                                        for (indx,value) in JSON(json)["message"] {
                                            //print(indx)
                                            //print(value[0].stringValue)
                                            var fieldMsg = value[0].stringValue
                                            fieldMsg = fieldMsg.replacingOccurrences(of: "This field", with: indx)
                                            
                                            if message == "" {
                                                message = "\(fieldMsg)"
                                            }
                                            else {
                                                message = "\(message ?? "")\n\(fieldMsg)"
                                            }
                                        }
                                    }
                                }
                                if response.result.error != nil {
                                    checkError(UrlResponse: response, error: response.result.error!, message: message!, showAlert: showAlert)
                                }
                                else {
                                    let errorTemp = NSError(domain:"", code:response.response!.statusCode, userInfo:nil)
                                    checkError(UrlResponse: response, error: errorTemp, message: message!, showAlert: showAlert)
                                }
                                //checkError(UrlResponse: response, error: response.result.error!, message: message!,showAlert: showAlert)
                            }
                            else {
                                if showAlert {
//                                    let _ = UIAlertController(title: "", message: message!)
                                    UIApplication.shared.topMostViewController()?.showAlert(title: nil, message: message)
                                }
                            }
                            failure(response.response, message!)
                            
                            /* //In case  of responsemessage in body
                             let message = JSON(dataToJSON(data: response.data!)!)["response"].stringValue
                             let error : Error? = NSError(domain: "somedomain", code: 123, userInfo: [:])
                             checkError(UrlResponse: response, error: error!, message: message,showAlert: showAlert)
                             failure(response.response, message)*/
                        }
                    })
                case .failure(let encodingError):
                    
                    logD("ERROR:-\(encodingError)")
                }
        })
    }
    
    
    //Upload Docuemnt For Amazon
    class func sendDocumentToAmazonAPI(Method method:HTTPMethod,url:String,parameters:Dictionary<String,AnyObject>?,headers:Dictionary<String,String>?,imageData:Data! = nil,uploadParamName:String = "",uploadFileName:String = "",showProgress:Bool,showAlert:Bool,completion: @escaping (_ isSuccess: Bool) -> Void,  failure:@escaping (_ httpresponse: HTTPURLResponse?,_ errorMessage: String) -> Void, progressCompletion: @escaping (_ progress: Double) -> Void)
 {
        var signature = ""
        /*if method == .get || method == .delete {
            signature = getSignature(getNewValueForSignature(method: "\(method)", url: url))
        }else {
            signature = getSignature(getValueForSignature(dict: parameters ?? [:], url: url))
        }
        
        var headersTemp = headers
        if headersTemp == const_dictHeader {
            const_dictHeader.updateValue(signature ?? "", forKey: "signature")
            headersTemp = const_dictHeader
        }else if headersTemp == const_dictHeaderWithToken {
            const_dictHeaderWithToken.updateValue(signature ?? "", forKey: "signature")
            headersTemp = const_dictHeaderWithToken
        }*/
        
        
        if showProgress
   {
            //SVProgressHUD.show()
        }
        logD("💜💜💜💜💜Request Data💜💜💜💜💜\nURL:\(url)\nParams:\(String(describing: parameters))\nHeaders:\(String(describing: headers))")
        //let authorisation = Request.authorizationHeader(user: auth_user, password: auth_password);
        
        Alamofire.upload(multipartFormData: { multipartFormData in
            if parameters != nil
       {
                for (key,value) in  parameters!
           {
                    multipartFormData.append(value.data(using: String.Encoding.utf8.rawValue)!, withName: key)
                }
            }
            if let imageData = imageData {
                //multipartFormData.append(imageData, withName: uploadParamName, fileName: uploadParamName, mimeType: "application/json")
                multipartFormData.append(imageData, withName: uploadParamName, fileName: uploadFileName, mimeType: "application/json")
            }
            
        },usingThreshold:UInt64.init(),
          to:url,
          method: method, //.post
          headers:headers,//authorisation,
            encodingCompletion: { encodingResult in
                switch encodingResult
           {
                case .success(let upload, _, _):
                    upload.responseJSON(completionHandler: { (response) in
                        print(response.response?.statusCode)
                        if response.response?.statusCode == 200 || response.response?.statusCode == 204
                   {
                            completion(true)
                        }else {
                            logD("ERROR:-\(response.response?.statusCode)")
                        }
                    })
                    
                case .failure(let encodingError):
                    
                    logD("ERROR:-\(encodingError)")
                }
        })
    }

    class func sendDocumentToAWSBySession(url:String, path:Data, method:HTTPMethod, token : String?, headers:[String:String]?, parameters: [String:AnyObject]?,imageNames : [String], images:[Data], completion: @escaping(Any?, Error?, Bool)->Void) {
        
        var stringUrl = url


        // generate boundary string using a unique per-app string
        let boundary = UUID().uuidString

        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)

        print("\n\ncomplete Url :-------------- ",stringUrl," \n\n-------------: complete Url")
        guard let url = URL(string: stringUrl) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST" //method.rawValue

        if headers != nil {
            print("\n\nHeaders :-------------- ",headers as Any,"\n\n --------------: Headers")
            for (key, value) in headers! {
                request.setValue(value, forHTTPHeaderField: key)

            }
        }

        // Set Content-Type Header to multipart/form-data, this is equivalent to submitting form data with file upload in a web browser
        // And the boundary is also set here
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var data = Data()
        if parameters != nil {
            for(key, value) in parameters! {
                // Add the reqtype field and its value to the raw http request data
                data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
                data.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
                data.append("\(value)".data(using: .utf8)!)
            }
        }
        for (index,imageData) in images.enumerated() {
            // Add the image data to the raw http request data
            data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
            data.append("Content-Disposition: form-data; name=\"\(imageNames[index])\"; filename=\"\(imageNames[index])\"\r\n".data(using: .utf8)!)
            data.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
            data.append(imageData)
        }

        // End the raw http request data, note that there is 2 extra dash ("-") at the end, this is to indicate the end of the data
        data.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)

        // Send a POST request to the URL, with the data we created earlier
        session.uploadTask(with: request, from: data, completionHandler: { data, response, error in

            if let checkResponse = response as? HTTPURLResponse {
                if error == nil {
                if checkResponse.statusCode == 200 || checkResponse.statusCode == 204 {
                    let json = ""
                    print(json)
                    completion(json, nil, true)
                }else {
                    completion(JSON(""), nil, false)
                }
                }else {
                    guard let data = data, let json = try? JSONSerialization.jsonObject(with: data, options: []) else {
                        completion(nil, error, false)
                        return
                    }
                    let jsonString = String(data: data, encoding: .utf8)!
                    print("\n\n---------------------------\n\n"+jsonString+"\n\n---------------------------\n\n")
                    print(json)
                    completion(json, nil, false)
                }
            }else {
                guard let data = data, let json = try? JSONSerialization.jsonObject(with: data, options: []) else {
                    completion(nil, error, false)
                    return
                }
                completion(json, nil, false)
            }

        }).resume()

    }

    // MARK: - Upload  Data &  Images
    /*class func uploadDataWithImages(Method method:HTTPMethod,url:String,parameters:Dictionary<String,AnyObject>?,headers:Dictionary<String,String>?,imageData:Data!,uploadParamName:String,showProgress:Bool,showAlert:Bool,completion: @escaping (_ result: JSON, _ headerMessage:String) -> Void,  failure:@escaping (_ httpresponse: HTTPURLResponse?,_ errorMessage: String) -> Void, progressCompletion: @escaping (_ progress: Double) -> Void)
 {
     
     if showProgress
 {
     //SVProgressHUD.show()
     }
     logD("💜💜💜💜💜Request Data💜💜💜💜💜\nURL:\(url)\nParams:\(String(describing: parameters))\nHeaders:\(String(describing: headers))")
     //let authorisation = Request.authorizationHeader(user: auth_user, password: auth_password);
     
     
     Alamofire.upload(multipartFormData: { multipartFormData in
     if parameters != nil
 {
     
     for (key,value) in  parameters!
 {
     print(key)
     print(value)
     /*  let jsonData = try? JSONSerialization.data(withJSONObject: value, options: [])
     let jsonString = String(data: jsonData!, encloding: .utf8)
     print(jsonString!)
     multipartFormData.append((jsonString?.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!)!, withName: key)*/
     multipartFormData.append(value.data(using: String.Encoding.utf8.rawValue)!, withName: key)
     //multipartFormData.append(data:value.data(using: String.Encoding.utf8.rawValue, allowLossyConversion: false) as! Data, name :key)
     }
     }
     multipartFormData.append(imageData, withName: "image", fileName: uploadParamName, mimeType: "image/png")
     
     },usingThreshold:UInt64.init(),
     to:url,
     method:.post,
     headers:headers,//authorisation,
     encodingCompletion: { encodingResult in
     switch encodingResult
 {
     case .success(let upload, _, _):
     //                upload.authenticate(user: "admin", password: "Test105*")
     /* upload.progress { (bytesWritten, totalBytesWritten, totalBytesExpectedToWrite) in
     logD("\(totalBytesWritten) / \(totalBytesExpectedToWrite)")
     }*/
     upload.uploadProgress(closure: { (progress) in
     print("Upload Progress: \(progress.fractionCompleted)")
     progressCompletion(0.0)
     })
     /* upload.response(completionHandler: { (response) in
     if response.response?.statusCode == 200
 {
     
     }
     else
 {
     print("response \(response.response?.allHeaderFields)")
     
     
     }
     })
     upload.responseString(completionHandler: { (response) in
     
     if response.response?.statusCode == 200
 {
     print("response \(response.result.error?.localizedDescription)")
     }
     else
 {
     print("response \(response.response?.allHeaderFields)")
     print("response \(response.result.error?.localizedDescription)")
     
     }
     })*/
     upload.responseJSON(completionHandler: { (response) in
     //SVProgressHUD.dismiss()
     
     /* if let jsonData = response.data {
     do {
     let parsedData = try JSONSerialization.jsonObject(with: jsonData, options: .mutableLeaves) as! [String: AnyObject]
     logD(parsedData)
     }
     catch let err {
     print("\n\n===========Error===========")
     print("Error Code: \(response.error!._code)")
     print("Error Messsage: \(response.error!.localizedDescription)")
     if let data = response.data, let str = String(data: data, encoding: String.Encoding.utf8) {
     print("Server Error: " + str)
     }
     debugPrint(response.error as Any)
     print("===========================\n\n")
     
     debugPrint(err)
     }
     }
     else {
     debugPrint(response.error as Any)
     } */
     if response.response?.statusCode == 200
 {
     logD("💜💜💜💜💜Response Data💜💜💜💜💜\nresponseCode:\(String(describing: response.response?.statusCode))\nResponse String: \(String(describing: response.result.value))\n")
     
     //let responseHeader = JSON(response.response!.allHeaderFields)
     //                let message = JSON(response.response!.allHeaderFields)["ResponseMessage"].stringValue
     let responseJSON = JSON(removeNulls(response.result.value as AnyObject))
     completion(responseJSON,JSON(response.response!.allHeaderFields)["response"].stringValue)
     }
     else
 {
     
     logD("Error:\(String(describing: response.result.error?.localizedDescription))")
     var message = response.result.error?.localizedDescription
     /*if !showAlert {
     failure(response.response, message)
     return
     }*/
     if response.response != nil {
     if let json = dataToJSON(data: response.data!) {
     message = JSON(json)["message"].stringValue
     }
     if response.result.error != nil {
     checkError(UrlResponse: response, error: response.result.error!, message: message!, showAlert: showAlert)
     }
     else {
     let errorTemp = NSError(domain:"", code:response.response!.statusCode, userInfo:nil)
     checkError(UrlResponse: response, error: errorTemp, message: message!, showAlert: showAlert)
     }
     //checkError(UrlResponse: response, error: response.result.error!, message: message!,showAlert: showAlert)
     }
     else {
     if showAlert {
     let _ = UIAlertController(title1: "", message1: message!)
     }
     }
     failure(response.response, message!)
     
     /* //In case  of responsemessage in body
     let message = JSON(dataToJSON(data: response.data!)!)["response"].stringValue
     let error : Error? = NSError(domain: "somedomain", code: 123, userInfo: [:])
     checkError(UrlResponse: response, error: error!, message: message,showAlert: showAlert)
     failure(response.response, message)*/
     }
     })
     case .failure(let encodingError):
     
     logD("ERROR:-\(encodingError)")
     }
     })
     }*/
    
    // MARK: - Remove Nulls from Dictionary/Array Recursively
    class func removeNulls(_ responseObject : AnyObject!) -> AnyObject
 {
        var response : AnyObject?
        if responseObject is [AnyObject] {
            response = removeNullFromArray(responseObject as! [AnyObject?]) as AnyObject?
        } else  if responseObject is Dictionary<String,AnyObject?> {
            response = removeNullFromDictionary(responseObject as! Dictionary<String, AnyObject?>) as AnyObject?
        }
        return response != nil ? response! : [:] as AnyObject
    }
    class func removeNullFromDictionary(_ dict:Dictionary<String,AnyObject?>)->Dictionary<String,AnyObject?>
 {
        var dictionary = dict
        for (key,value) in dictionary {
            
            if let _ = value {
                if value != nil && value! as! NSObject == NSNull() {
                    dictionary.updateValue("" as AnyObject?, forKey: key)
                }
                else if value is Dictionary<String,AnyObject> {
                    dictionary.updateValue(removeNullFromDictionary(value as! Dictionary<String, AnyObject?>) as AnyObject?, forKey: key)
                }
                else if value is [AnyObject?] {
                    dictionary.updateValue(removeNullFromArray(value as! [AnyObject?]) as AnyObject?, forKey: key)
                }
            }else {
                dictionary.updateValue("" as AnyObject?, forKey: key)
            }
            
        }
        return dictionary
    }
    class func removeNullFromArray(_ arr:[AnyObject?])->[AnyObject?]
 {
        var arr = arr
        for (index,value) in arr.enumerated() {
            
            if value != nil && value! as! NSObject == NSNull() {
                arr[index] = "" as AnyObject?
            }
            else if value is Dictionary<String,AnyObject> {
                arr[index] = removeNullFromDictionary(value as! Dictionary<String, AnyObject?>) as AnyObject?
            }
            else if value is [AnyObject?] {
                arr[index] = removeNullFromArray(value as! [AnyObject?]) as AnyObject?
            }
        }
        return arr;
    }
}

//
//extension APIManager {
//
//    func showNormalAlert(title: String?, message: String?) {
//        UIApplication.shared.topMostViewController()?.showAlert(title: title, message: message)
//    }
//
//}
