//
//  AppDelegate.swift
//  CCSMembersApp
//
//  Created by Jaimin Patel on 6/6/19.
//  Copyright © 2019 Jaimin Patel. All rights reserved.
//

import UIKit
import Foundation
import SlideMenuControllerSwift
import CoreData
import Firebase
import FirebaseMessaging
import UserNotifications
import InAppNotify
import SwiftyJSON
import GoogleMaps
import GooglePlaces

import NVActivityIndicatorView
var deviceTokenString = ""

// MARK: - App version
let k_App_Version           = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
let k_AppStore_URL          = "itms-apps://apps.apple.com/us/app/ccs-members-app/id1658717530"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, NVActivityIndicatorViewable {

    var window: UIWindow?
    var selectedIndexMenu = 0
    var isRemember = false
    var isFromLogout = false
    var Email = ""
    var Password = ""
    var nameU = ""
    var isSkip = false
    
    var selectedPreregistrationData = [String:Any]()
    
    
    var arrPreRegistartionsData = JSON("")
    var preRegClubName = ""
    var preRegClubCode = ""
    //var selectedImage = [String:UIImage()]
    var currentVC: UIViewController?
    
    var chatDetailController: UIViewController?
    

    var parentCurrentVC: UIViewController?
    var isFromNotification : Bool = false
    
    var chatRedirectionType : Int = 0
    var isChatDetailScreenOpen : Bool = false
//    let MERCHANT_ID = "merchant.com.iflair.cannabisapp"     // OLD
    let MERCHANT_ID = "merchant.com.nefos.ccsmembersapp"
//    let regexPassword = NSPredicate(format: "SELF MATCHES %@", "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[d$@$!%*?&#])[A-Za-z\\dd$@$!%*?&#]{8,}")
    let regexPassword = NSPredicate(format: "SELF MATCHES %@", "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[d !\"#$%&'()*+,-./:;<=>?@\\[\\\\\\]^_`{|}~])[A-Za-z\\dd !\"#$%&'()*+,-./:;<=>?@\\[\\\\\\]^_`{|}~]{8,}")
    var isOpenFriendsRequestFromNotification : Bool = false

    //MARK: - Merchant IDs
    /// Old merchant ids
    ///
    /// 1 - merchant.com.iflair.cannabisapp
    /// 2 - merchant.com.cannabisapp
    ///
    /// New merchant ids
    ///
    /// 1 - merchant.com.nefos.ccsmembersapp
    ///
    ///
    ///
    //MARK: - App Life Cycle
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UIApplication.shared.statusBarUIView?.backgroundColor=UIColor(named: "statusBackgroundColour")
        // UIApplication.shared.statusBarView?.backgroundColor = UIColor(named: "statusBackgroundColour")
        // Override point for customization after application launch.
        //  InAppNotify.theme = Themes.dark
        //AIzaSyA3JTPYHRBUt4Wa_eDf6ubK5Ai-HI84KcU
        //GMSServices.provideAPIKey("AIzaSyA3JTPYHRBUt4Wa_eDf6ubK5Ai-HI84KcU")
        GMSServices.provideAPIKey("AIzaSyB37T3DT1fLza9MGhJgDYbqh8oODJTuYsk")
        GMSPlacesClient.provideAPIKey("AIzaSyB37T3DT1fLza9MGhJgDYbqh8oODJTuYsk")
        
        //GMSPlacesClient.provideAPIKey("AIzaSyA3JTPYHRBUt4Wa_eDf6ubK5Ai-HI84KcU")
        // STPPaymentConfiguration.shared().appleMerchantIdentifier = "merchant.com.iflair.cannabisapp"
        targetName = Bundle.main.infoDictionary?["CFBundleName"] as? String ?? ""
        if targetName == "CCSMembersApp" {
            targetName = Shared().cannibisAppName
        }
        print(targetName)
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        //self.firebaseSignInAnonymous()
        /*
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            let center = UNUserNotificationCenter.current()
            center.delegate=self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            center.requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
            // For iOS 10 data message (sent via FCM
            
            Messaging.messaging().delegate = self
            
            let deafultCategory = UNNotificationCategory(identifier: "CustomSamplePush", actions: [], intentIdentifiers: [], options: [])
            center.setNotificationCategories(Set([deafultCategory]))
        } else {
            let settings: UIUserNotificationSettings =
            UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }*/
        //For Push Notification
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .sound]  //[.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        if let options = launchOptions {
            if let notification = options[UIApplication.LaunchOptionsKey.remoteNotification] {
                if getFromUserDefaultForKey(key_isLogin) != nil {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                        self.handlePushNotification(userInfo: JSON(notification))
                    })
                }
            }
        }
        
        application.registerForRemoteNotifications()
        
        /*if let _ : AnyObject = UserDefaults.standard.object(forKey: "user_id") as AnyObject? {
            
            if "true" == UserDefaults.standard.string(forKey: "addMemberAccount"){
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let appDelegate = UIApplication.shared.delegate as? AppDelegate
                let initialViewController = storyboard.instantiateViewController(withIdentifier: "MainMenuVC") as! MainMenuVC
                let leftViewController = storyboard.instantiateViewController(withIdentifier: "SlideMenuScreenVC") as! SlideMenuScreenVC
                let nvc: UINavigationController = UINavigationController(rootViewController: initialViewController)
                let slideMenuController = SlideMenuController(mainViewController: nvc,  leftMenuViewController: leftViewController)
                slideMenuController.automaticallyAdjustsScrollViewInsets = true
                appDelegate?.window?.backgroundColor = UIColor(red: 236.0, green: 238.0, blue: 241.0, alpha: 1.0)
                appDelegate?.window?.rootViewController = slideMenuController
                appDelegate?.window?.makeKeyAndVisible()
                SlideMenuOptions.contentViewScale = 1
                SlideMenuOptions.hideStatusBar = false
                SlideMenuOptions.simultaneousGestureRecognizers = false
            } else{
                
                
            }
        }*/
//        else {
//            let storyboard = UIStoryboard(name: "Main", bundle: nil)
//            let appDelegate = UIApplication.shared.delegate as? AppDelegate
//            let initialViewController = storyboard.instantiateViewController(withIdentifier: "LoginScreenVC") as! LoginScreenVC
//            let leftViewController = storyboard.instantiateViewController(withIdentifier: "SlideMenuScreenVC") as! SlideMenuScreenVC
//            let nvc: UINavigationController = UINavigationController(rootViewController: initialViewController)
//            let slideMenuController = SlideMenuController(mainViewController: nvc,  leftMenuViewController: leftViewController)
//            slideMenuController.automaticallyAdjustsScrollViewInsets = true
//            appDelegate?.window?.backgroundColor = UIColor(red: 236.0, green: 238.0, blue: 241.0, alpha: 1.0)
//            appDelegate?.window?.rootViewController = slideMenuController
//            appDelegate?.window?.makeKeyAndVisible()
//            SlideMenuOptions.contentViewScale = 1
//            SlideMenuOptions.hideStatusBar = false
//            SlideMenuOptions.simultaneousGestureRecognizers = false
//        }
//        
        if #available(iOS 13.0, *) {
            let coloredAppearance = UINavigationBarAppearance()
            coloredAppearance.configureWithOpaqueBackground()
            coloredAppearance.backgroundColor = UIColor.clear
            coloredAppearance.titleTextAttributes = [.foregroundColor: UIColor.clear]
            coloredAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.ColorTitle]
            coloredAppearance.shadowColor = UIColor.clear
            
            UINavigationBar.appearance().standardAppearance = coloredAppearance
            UINavigationBar.appearance().scrollEdgeAppearance = coloredAppearance
            
        }
        
        UIApplication.shared.applicationIconBadgeNumber = 0
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        
        self.CallAPIGetGoogleAccessToken { _, _ in
            
        }
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        let activityData = ActivityData(size: CGSize(width: 100, height: 100), message: "", type: NVActivityIndicatorType.ballRotate)
        NVActivityIndicatorPresenter.sharedInstance.startAnimating(activityData)
        UIApplication.shared.topMostViewController()!.dismiss(animated: false)

    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        if getFromUserDefaultForKey(key_isLogin) != nil{
            FirebaseManager.sharedInstance.setUserIsOnlineGlobally(loginStatus: false)
        }
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        application.applicationIconBadgeNumber = 0
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        if getFromUserDefaultForKey(key_isLogin) != nil{
            FirebaseManager.sharedInstance.setUserIsOnlineGlobally(loginStatus: true)
        }
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        self.callAPICheckAppVersion()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        Shared().clearData()
        if getFromUserDefaultForKey(key_isRememberMe)?.boolValue == false {
            UserDefaults.standard.removeObject(forKey: "email")
            removeFromUserDefaultForKey(key_Password)
            removeFromUserDefaultForKey(key_MyEmail)
            removeFromUserDefaultForKey(key_isRememberMe)

        }
//        offlineFirebase()
//        let defaults = UserDefaults.standard
//        defaults.removeObject(forKey: "user_id")
//        defaults.synchronize()
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func offlineFirebase(){
        let checkChattingScreenStatus=UserDefaults.standard.string(forKey: "ChattingScreenOn")
        if checkChattingScreenStatus == "true"{
            UserDefaults.standard.set("false", forKey: "ChattingScreenOn")
            Shared().firebaseProcess(visibility:"OFFLINE")
        }
    }
    
    @available(iOS 10.0, *)
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "Database")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    @available(iOS 10.0, *)
    func saveContext () {
        
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
        
    }
}
// MARK: - Extension UIViewController / Top Most View Controller
extension UIViewController {
    func topMostViewController() -> UIViewController {
        
        if let presented = self.presentedViewController {
            return presented.topMostViewController()
        }
        
        if let navigation = self as? UINavigationController {
            return navigation.visibleViewController?.topMostViewController() ?? navigation
        }
        
        if let tab = self as? UITabBarController {
            return tab.selectedViewController?.topMostViewController() ?? tab
        }
        
        return self
    }
}

extension UIApplication {
    func topMostViewController() -> UIViewController? {
        return self.keyWindow?.rootViewController?.topMostViewController()
    }
}

extension AppDelegate:MessagingDelegate  {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("Firebase registration token: \(fcmToken)")
        deviceTokenString = fcmToken ?? ""
    }
    
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingDelegate) {
        print("Received data message: \(remoteMessage.description)")
    }
}

extension AppDelegate:UNUserNotificationCenterDelegate{
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
        Messaging.messaging().token { token, error in
            deviceTokenString = token ?? ""
        }
//        InstanceID.instanceID().instanceID { (result, error) in
//            if let error = error {
//                print("Error fetching remote instance ID: \(error)")
//            } else if let result = result {
//                print("Remote instance ID token: \(result.token)")
//            }
//        }
        
        if UserDefaults.standard.value(forKey: "member_id") != nil {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                Messaging.messaging().subscribe(toTopic: getFromUserDefaultForKey("member_id") as? String ?? "")
            }
            //Messaging.messaging().subscribe(toTopic: self.strLoggedUserId)
        }
    }
//    func application(application: UIApplication,  didReceiveRemoteNotification userInfo: [NSObject : AnyObject],  fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
//        print("Recived: \(userInfo)")
//        if getFromUserDefaultForKey(key_isLogin) != nil{
//            DispatchQueue.main.async {
//                self.handlePushNotification(userInfo: JSON(userInfo))
//            }
//        }
//        completionHandler(.newData)
//
//    }
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        
        print("Recived: \(userInfo)")
        if getFromUserDefaultForKey(key_isLogin) != nil{
            DispatchQueue.main.async {
                self.handlePushNotification(userInfo: JSON(userInfo))
            }
        }
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Registration failed!",error.localizedDescription)
    }
    
    /*
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        print(userInfo)
        
        //completionHandler()
        
        let push = userInfo[AnyHashable("aps")] as? NSDictionary
        let alertDic = push?["alert"] as? NSDictionary
        
        let id = JSON(userInfo["gcm.message_id"]).stringValue
        let nav_id = JSON(userInfo["gcm.notification.screen_no"]).stringValue
        let message = JSON(alertDic?["body"]).stringValue
        let title = JSON(alertDic?["title"]).stringValue
        let category="custom"
        let clubName = JSON(userInfo["gcm.notification.club_name"]).stringValue
        let myClube = UserDefaults.standard.string(forKey: "club_name")
        if let _ : AnyObject = UserDefaults.standard.object(forKey: "user_id") as AnyObject? {
            if(myClube == clubName) {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let appDelegate = UIApplication.shared.delegate as? AppDelegate
                let initialViewController = storyboard.instantiateViewController(withIdentifier: "NotificationVC") as! NotificationVC
                //initialViewController.order_id = id
                //initialViewController.notificationStatus=check_Notification
                
                let leftViewController = storyboard.instantiateViewController(withIdentifier: "SlideMenuScreenVC") as! SlideMenuScreenVC
                let nvc: UINavigationController = UINavigationController(rootViewController: initialViewController)
                let slideMenuController = SlideMenuController(mainViewController: nvc,  leftMenuViewController: leftViewController)
                slideMenuController.automaticallyAdjustsScrollViewInsets = true
                appDelegate?.window?.backgroundColor = UIColor(red: 236.0, green: 238.0, blue: 241.0, alpha: 1.0)
                appDelegate?.window?.rootViewController = slideMenuController
                appDelegate?.window?.makeKeyAndVisible()
                SlideMenuOptions.contentViewScale = 1
                SlideMenuOptions.hideStatusBar = false
                SlideMenuOptions.simultaneousGestureRecognizers = false
            } else  {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let appDelegate = UIApplication.shared.delegate as? AppDelegate
                let initialViewController = storyboard.instantiateViewController(withIdentifier: "AddNewClubVC") as! AddNewClubVC
                initialViewController.fromNotification = true
                initialViewController.notifClub = clubName
                //initialViewController.order_id = id
                //initialViewController.notificationStatus=check_Notification
                
                let leftViewController = storyboard.instantiateViewController(withIdentifier: "SlideMenuScreenVC") as! SlideMenuScreenVC
                let nvc: UINavigationController = UINavigationController(rootViewController: initialViewController)
                let slideMenuController = SlideMenuController(mainViewController: nvc,  leftMenuViewController: leftViewController)
                slideMenuController.automaticallyAdjustsScrollViewInsets = true
                appDelegate?.window?.backgroundColor = UIColor(red: 236.0, green: 238.0, blue: 241.0, alpha: 1.0)
                appDelegate?.window?.rootViewController = slideMenuController
                appDelegate?.window?.makeKeyAndVisible()
                SlideMenuOptions.contentViewScale = 1
                SlideMenuOptions.hideStatusBar = false
                SlideMenuOptions.simultaneousGestureRecognizers = false
            }
        }
    }*/
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        print("notification--\(userInfo)")
        UIApplication.shared.applicationIconBadgeNumber = 0
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        completionHandler([.alert, .badge, .sound])
        
//        let push = userInfo[AnyHashable("aps")] as? NSDictionary
//        let alertDic = push?["alert"] as? NSDictionary
//
//        let id = JSON(userInfo["gcm.message_id"]).stringValue
//        let nav_id = JSON(userInfo["gcm.notification.screen_no"]).stringValue
//        let message = JSON(alertDic?["body"]).stringValue
//        let title = JSON(alertDic?["title"]).stringValue
//        let clubName = JSON(userInfo["gcm.notification.club_name"]).stringValue
//        print("club-\(clubName)")
        
    /*if nav_id == "2"{
        let checkChattingScreenStatus=UserDefaults.standard.string(forKey: "ChattingScreenOn")
        if checkChattingScreenStatus == "false"{

            DispatchQueue.main.async{
                let NavVccVar = UIApplication.shared.keyWindow?.rootViewController as! SlideMenuController
                let ShnSrnVar = NavVccVar.mainViewController
                
                let announce = Announcement(
                    title : title,
                    subtitle : message,
                    image : UIImage(named: "AppIcon"),
                    duration : 5,
                    interactionType : InteractionType.none,
                    userInfo : ["id" : id, "nav_id" : nav_id],
                    action: { (type, string, announcement) in
                        if type == CallbackType.tap{
                            let userInfo : [String:String] = announcement.userInfo as! [String : String]
                            let id_inside = JSON(userInfo["id"]!).stringValue
                            let nav_id_inside = JSON(userInfo["nav_id"]!).stringValue
                            // let check_Notification = JSON(userInfo["gcm.notification.is_customer"]!).stringValue
                            
                            if let _ : AnyObject = UserDefaults.standard.object(forKey: "user_id") as AnyObject? {
                                if(nav_id_inside == "1") {
                                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                    let appDelegate = UIApplication.shared.delegate as? AppDelegate
                                    let initialViewController = storyboard.instantiateViewController(withIdentifier: "NotificationVC") as! NotificationVC
                                    //initialViewController.order_id = id_inside
                                    //initialViewController.notificationStatus=check_Notification as! String
                                    
                                    let leftViewController = storyboard.instantiateViewController(withIdentifier: "SlideMenuScreenVC") as! SlideMenuScreenVC
                                    let nvc: UINavigationController = UINavigationController(rootViewController: initialViewController)
                                    let slideMenuController = SlideMenuController(mainViewController: nvc,  leftMenuViewController: leftViewController)
                                    slideMenuController.automaticallyAdjustsScrollViewInsets = true
                                    appDelegate?.window?.backgroundColor = UIColor(red: 236.0, green: 238.0, blue: 241.0, alpha: 1.0)
                                    appDelegate?.window?.rootViewController = slideMenuController
                                    appDelegate?.window?.makeKeyAndVisible()
                                    SlideMenuOptions.contentViewScale = 1
                                    SlideMenuOptions.hideStatusBar = false
                                    SlideMenuOptions.simultaneousGestureRecognizers = false
                                } else if (nav_id_inside == "2") {
                                    
                                    //if checkChattingScreenStatus! == "false"{
                                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                    let appDelegate = UIApplication.shared.delegate as? AppDelegate
                                    let initialViewController = storyboard.instantiateViewController(withIdentifier: "ChatingVC") as! ChatingVC
                                    initialViewController.notifiction="true"
                                    //initialViewController.shipment_id = id_inside
                                    //initialViewController.shipment_prefix = "SHP-\(id_inside )"
                                    //initialViewController.notificationStatus=check_Notification as! String
                                    
                                    let leftViewController = storyboard.instantiateViewController(withIdentifier: "SlideMenuScreenVC") as! SlideMenuScreenVC
                                    let nvc: UINavigationController = UINavigationController(rootViewController: initialViewController)
                                    let slideMenuController = SlideMenuController(mainViewController: nvc,  leftMenuViewController: leftViewController)
                                    slideMenuController.automaticallyAdjustsScrollViewInsets = true
                                    appDelegate?.window?.backgroundColor = UIColor(red: 236.0, green: 238.0, blue: 241.0, alpha: 1.0)
                                    appDelegate?.window?.rootViewController = slideMenuController
                                    appDelegate?.window?.makeKeyAndVisible()
                                    SlideMenuOptions.contentViewScale = 1
                                    SlideMenuOptions.hideStatusBar = false
                                    SlideMenuOptions.simultaneousGestureRecognizers = false
                                    //                                } else{
                                    //
                                    //                                }
                                    
                                }
                            }
                        }
                })
                InAppNotify.Show(announce, to: ShnSrnVar!)
            }
        }else{
            
        }
    } else{
        DispatchQueue.main.async{
            let NavVccVar = UIApplication.shared.keyWindow?.rootViewController as! SlideMenuController
            let ShnSrnVar = NavVccVar.mainViewController
            
            let announce = Announcement(
                title : title,
                subtitle : message,
                image : UIImage(named: "AppIcon"),
                duration : 5,
                interactionType : InteractionType.none,
                userInfo : ["id" : id, "nav_id" : nav_id],
                action: { (type, string, announcement) in
                    if type == CallbackType.tap{
                        let userInfo : [String:String] = announcement.userInfo as! [String : String]
                        let id_inside = JSON(userInfo["id"]!).stringValue
                        let nav_id_inside = JSON(userInfo["nav_id"]!).stringValue
                        // let check_Notification = JSON(userInfo["gcm.notification.is_customer"]!).stringValue
                        
                        if let _ : AnyObject = UserDefaults.standard.object(forKey: "user_id") as AnyObject? {
                            if(nav_id_inside == "1") {
                                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                let appDelegate = UIApplication.shared.delegate as? AppDelegate
                                let initialViewController = storyboard.instantiateViewController(withIdentifier: "NotificationVC") as! NotificationVC
                                //initialViewController.order_id = id_inside
                                //initialViewController.notificationStatus=check_Notification as! String
                                
                                let leftViewController = storyboard.instantiateViewController(withIdentifier: "SlideMenuScreenVC") as! SlideMenuScreenVC
                                let nvc: UINavigationController = UINavigationController(rootViewController: initialViewController)
                                let slideMenuController = SlideMenuController(mainViewController: nvc,  leftMenuViewController: leftViewController)
                                slideMenuController.automaticallyAdjustsScrollViewInsets = true
                                appDelegate?.window?.backgroundColor = UIColor(red: 236.0, green: 238.0, blue: 241.0, alpha: 1.0)
                                appDelegate?.window?.rootViewController = slideMenuController
                                appDelegate?.window?.makeKeyAndVisible()
                                SlideMenuOptions.contentViewScale = 1
                                SlideMenuOptions.hideStatusBar = false
                                SlideMenuOptions.simultaneousGestureRecognizers = false
                            } else if (nav_id_inside == "2") {
        
                                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                let appDelegate = UIApplication.shared.delegate as? AppDelegate
                                let initialViewController = storyboard.instantiateViewController(withIdentifier: "ChatingVC") as! ChatingVC
                                initialViewController.notifiction="true"
                                //initialViewController.shipment_id = id_inside
                                //initialViewController.shipment_prefix = "SHP-\(id_inside )"
                                //initialViewController.notificationStatus=check_Notification as! String
                                
                                let leftViewController = storyboard.instantiateViewController(withIdentifier: "SlideMenuScreenVC") as! SlideMenuScreenVC
                                let nvc: UINavigationController = UINavigationController(rootViewController: initialViewController)
                                let slideMenuController = SlideMenuController(mainViewController: nvc,  leftMenuViewController: leftViewController)
                                slideMenuController.automaticallyAdjustsScrollViewInsets = true
                                appDelegate?.window?.backgroundColor = UIColor(red: 236.0, green: 238.0, blue: 241.0, alpha: 1.0)
                                appDelegate?.window?.rootViewController = slideMenuController
                                appDelegate?.window?.makeKeyAndVisible()
                                SlideMenuOptions.contentViewScale = 1
                                SlideMenuOptions.hideStatusBar = false
                                SlideMenuOptions.simultaneousGestureRecognizers = false
                            }
                        }
                    }
            })
            InAppNotify.Show(announce, to: ShnSrnVar!)
        }
        }*/
    }
    
    func firebaseSignInAnonymous()
    {
        
        Auth.auth().signInAnonymously() { (authResult, error) in
            if let aUser = authResult {
                /*
                 let user = authResult.user
                 let isAnonymous = user.isAnonymous  // true
                 let uid = user.uid
                 */
                
                //let user = authResult.user
                //let isAnonymous = aUser.isAnonymous  // true
                
                //Pod Change Updates
                //let uid = aUser.uid
                let uid = aUser.user.uid
                
                //FirebaseManager.sharedInstance.addAnonymousUser(uid: uid)
            }
        }
    }
}

// MARK: - API Call
extension AppDelegate {
    @objc func callAPICheckAppVersion() {       // Check app version
        APIManager.callAPIRequest(Method: .post, url: "\(api_CheckAppVersion)", parameters: APIParam.checkAppVersion(app_version: "\(k_App_Version)", platform: "IOS", language: "\(Language.language)").getParam(), headers: nil, showAlert: false, completion: { (jsonResult, msg) in
            logD(jsonResult)
            DispatchQueue.main.async {
                NVActivityIndicatorPresenter.sharedInstance.stopAnimating(nil)
            }
            if jsonResult["flag"].stringValue == "1"{
                if jsonResult["is_update_available"].boolValue == true {
                    if jsonResult["is_update_available"].boolValue == false && jsonResult["is_force_update"].boolValue == false{
                        return
                    }else if jsonResult["is_force_update"].boolValue == true {
                        UIApplication.shared.topMostViewController()!.showAlert(title: "Update Required".localized, message: jsonResult["message"].stringValue, buttonTitles: ["Update".localized], highlightedButtonIndex: 0, completion: { (idx) in
                            if idx == 0 {
                                if let url = URL(string: k_AppStore_URL) {
                                    UIApplication.shared.open(url)
                                }
                            }
                        })
                    }else{
                        if self.isSkip == false{
                            UIApplication.shared.topMostViewController()!.showAlert(title: "Update Available".localized, message: jsonResult["message"].stringValue, buttonTitles: ["Not Now".localized, "Update".localized], highlightedButtonIndex: 1, completion: { (idx) in
                                self.isSkip = true
                                if idx == 1 {
                                    if let url = URL(string: k_AppStore_URL) {
                                        UIApplication.shared.open(url)
                                    }
                                }
                            })
                        }
                    }
                }
            }else{
                UIApplication.shared.topMostViewController()!.showAlert(title: "", message: jsonResult["message"].stringValue)
            }
                
        }) { (httpResponse, errorMsg) in
            //logD(httpResponse ?? "")
            //logD(errorMsg ?? "")
            DispatchQueue.main.async {
                NVActivityIndicatorPresenter.sharedInstance.stopAnimating(nil)
            }
            UIApplication.shared.topMostViewController()!.showAlert(title: "", message: errorMsg)
        }
    }
    
    //Chat Module
    func CallAPIRespondFriendRequest(userID:String, requestStatus: Int , completion:  @escaping (_ result: JSON?, Error?) -> Void) {
        
        APIManager.callAPIRequest(Method: .post, url: "\(api_acceptOrRejectRequest)", parameters: APIParam.acceptOrRejectRequest(user_id: getFromUserDefaultForKey("member_id") as? String ?? "", request_id: userID, language: "\(Language.language)", request_status: requestStatus).getParam(), headers: nil, showAlert: false) { jsonResult, headerMessage in
            logD(jsonResult)
            completion(jsonResult, nil)
        } failure: { httpresponse, errorMessage in
//            self.showAlert(title: "", message: errorMessage)
            completion(nil, errorMessage as? Error)
            logD(errorMessage )
        }

    }
    
    //Call API get google access token
    func CallAPIGetGoogleAccessToken(completion:  @escaping (_ result: JSON?, Error?) -> Void) {
        APIManager.callAPIRequest(Method: .post, url: "\(api_googleAccessToken)", parameters: nil, headers: nil, showAlert: false) { jsonResult, headerMessage in
            
            print("Access Token :- \(jsonResult)")
            if jsonResult["flag"].stringValue == "1"{
                setToUserDefaultForKey(jsonResult["message"].stringValue as AnyObject, key: key_googleAccessToken)
                completion(jsonResult, nil)
            }
        } failure: { httpresponse, errorMessage in
            logD(errorMessage )
        }
    }
    //Remove Old User FCM Token
    func callAPIRemoveFCMToken(completion: @escaping () -> Void) {
        let memberId = getFromUserDefaultForKey(key_oldUserMemberID)?.stringValue ?? ""
        let fcmToken = getFromUserDefaultForKey(key_oldUserFcmToken)?.stringValue ?? ""
        APIManager.callAPIRequest(Method: .post, url: "\(api_RemoveFCMToken)", parameters: APIParam.removeFCMToken(memberId: memberId, fcmToken: fcmToken).getParam(), headers: nil, showAlert: false, completion: { (jsonResult, msg) in
            FirebaseManager.sharedInstance.removeUserToken(userId: memberId) {
                removeFromUserDefaultForKey(key_oldUserMemberID)
                removeFromUserDefaultForKey(key_oldUserFcmToken)
                completion()
            }
        }) { (httpResponse, errorMsg) in
            completion()
        }
    }

}

// MARK: - AppDelegate Extension for Handle Push Notifications
extension AppDelegate {
    // Handle Push Notification
    func handlePushNotification(userInfo: JSON) {
        //let vc = self.window!.rootViewController as! UINavigationController
        self.currentVC = UIApplication.topViewController()
        //UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        if getFromUserDefaultForKey(key_isLogin) == nil {
            return
        }

        let strNotificationType = userInfo["type"].stringValue
        let conId = userInfo["conversationId"].stringValue

//        if userInfo["receiverId"].stringValue != MEMBER_ID{
//            return
//        }
        switch strNotificationType {
        case PUSHNOTIFICATION.USER_CHAT.get():
            print("Open User Chat")
            /*Messages.getUserLastConversationDetails(toId: MEMBER_ID, fromId: userInfo["userId"].stringValue) { userData in
                if userData["isUnFriend"] as? Bool ?? false == false{
                    self.redirectToChatDetails(jsonData: userInfo,type: 1)
                }else{
                    return
                }
            }*/
            self.redirectToChatDetails(jsonData: userInfo,type: 1)
            
        case PUSHNOTIFICATION.CLUB_CHAT.get():
            print("Open Club Chat")
            /*
            Messages.getUserLastConversationDetails(isFromClubChat:true,toId: MEMBER_ID, fromId: userInfo["userId"].stringValue) { userData in
                if userData["isBannedByClub"] as? Bool ?? false == false && userData["isDeletedByClub"] as? Bool ?? false == false{
                    self.redirectToChatDetails(jsonData: userInfo,type: 2)
                }else{
                    return
                }
            }*/
            self.redirectToChatDetails(jsonData: userInfo,type: 2)
            
        case PUSHNOTIFICATION.REQUEST_RECEIVED.get():
            print("Open Request Received")
            self.redirectToFriends()
        case PUSHNOTIFICATION.REQUEST_ACEEPTED.get():
            print("Open Request Accepted")
            self.redirectToFriends()
        default:
            break;
        }
         
    }
    
    //MARK: Redirect to Script Request List
    func redirectToChatDetails(jsonData:JSON,type:Int) {
        self.isFromNotification = true
        self.chatRedirectionType = type
        
        if self.isChatDetailScreenOpen{
            //let vc = storyboardName.storyBoard_Chat.instantiateViewController(withIdentifier: "ChatDetailsVC") as! ChatDetailsVC
            if let chatDetailsVC = (self.chatDetailController as? ChatDetailsVC){
                chatDetailsVC.updateUserData(jsonData: jsonData)
            }
            return
        }
        else if let chatViewController = (self.parentCurrentVC as? ChatViewController){
            chatViewController.notificationPayload = jsonData
            chatViewController.openChatDetailsFromNotification()
//            if jsonData["type"].stringValue == PUSHNOTIFICATION.CLUB_CHAT.get(){
//
//            }else{
//                let dict = ["userid":jsonData["userId"].stringValue,"receiverName":jsonData["userName"].stringValue]
//                NotificationCenter.default.post(name: Notification.Name(NotificationName().OepnChatDetailScreen), object: dict)
//            }
            
        }else{
            //let storyboard = UIStoryboard(name: "Main", bundle: nil)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationName().SetParticularIndexInSideMenu), object: nil, userInfo: ["txt": "Chat".localized])
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateMenuSelection"), object: nil)
            let initialViewController = storyboardName.storyBoard_Chat.instantiateViewController(withIdentifier: "\(ChatViewController.self)") as! ChatViewController
            initialViewController.notificationPayload = jsonData
            self.parentCurrentVC = initialViewController
            let leftViewController = storyboardName.storyBoard_Main.instantiateViewController(withIdentifier: "SlideMenuScreenVC") as! SlideMenuScreenVC
            let nvc: UINavigationController = UINavigationController(rootViewController: initialViewController)
            let slideMenuController = SlideMenuController(mainViewController: nvc,  leftMenuViewController: leftViewController)
            slideMenuController.automaticallyAdjustsScrollViewInsets = true
            self.window?.backgroundColor = UIColor(red: 236.0, green: 238.0, blue: 241.0, alpha: 1.0)
            self.window?.rootViewController = slideMenuController
            self.window?.makeKeyAndVisible()
            SlideMenuOptions.contentViewScale = 1
            SlideMenuOptions.hideStatusBar = false
            SlideMenuOptions.simultaneousGestureRecognizers = false
        }
        
//        let vc = storyboardName.storyBoard_Chat.instantiateViewController(withIdentifier: "\(ChatDetailsVC.self)") as! ChatDetailsVC
//        UIApplication.topViewController()?.navigationController?.pushViewController(vc, animated: true)
    }
    //MARK: Redirect to Friends request List
    func redirectToFriends() {
        if let friendRequestListVC = (self.currentVC as? FriendRequestListVC){
            friendRequestListVC.selectReceiveOrSend(isSelectIncomingRequest: true)
            friendRequestListVC.CallAPIGetListOfFriendRequestAndReceived(isFromSend: false)
        }else{
            if let chatViewController = (self.parentCurrentVC as? ChatViewController){
                //chatViewController.btnSegmentAction(chatViewController.btnFriendList)
                //chatViewController.openFriendsRequestListFromNotification()
                if let profileVC = (self.currentVC as? FriendProfileVC){
                    self.isOpenFriendsRequestFromNotification = true
                    profileVC.dismiss(animated: true) {
                    }
                }else{
                    if let qrVC = (self.currentVC as? MyQRcodeVC){
                        self.isOpenFriendsRequestFromNotification = true
                        qrVC.dismiss(animated: false) {
                            if let chatViewController = (self.parentCurrentVC as? ChatViewController){
                                chatViewController.btnSegmentAction(chatViewController.btnFriendList)
                                chatViewController.openFriendsRequestListFromNotification()
                            }
                        }
                    }else{
                        self.isOpenFriendsRequestFromNotification = true
                        chatViewController.btnSegmentAction(chatViewController.btnFriendList)
                        chatViewController.openFriendsRequestListFromNotification()
                    }
                }
            }else{
                self.isOpenFriendsRequestFromNotification = true
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationName().SetParticularIndexInSideMenu), object: nil, userInfo: ["txt": "Chat".localized])
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateMenuSelection"), object: nil)
                let initialViewController = storyboardName.storyBoard_Chat.instantiateViewController(withIdentifier: "\(ChatViewController.self)") as! ChatViewController
                
                let leftViewController = storyboardName.storyBoard_Main.instantiateViewController(withIdentifier: "SlideMenuScreenVC") as! SlideMenuScreenVC
                let nvc: UINavigationController = UINavigationController(rootViewController: initialViewController)
                let slideMenuController = SlideMenuController(mainViewController: nvc,  leftMenuViewController: leftViewController)
                slideMenuController.automaticallyAdjustsScrollViewInsets = true
                self.window?.backgroundColor = UIColor(red: 236.0, green: 238.0, blue: 241.0, alpha: 1.0)
                self.window?.rootViewController = slideMenuController
                self.window?.makeKeyAndVisible()
                SlideMenuOptions.contentViewScale = 1
                SlideMenuOptions.hideStatusBar = false
                SlideMenuOptions.simultaneousGestureRecognizers = false
            }
        }
        
    }
}
