//
//  MapScreenVC.swift
//  CCSMembersApp
//
//  Created by Jaimin Patel on 11/16/19.
//  Copyright © 2019 Jaimin Patel. All rights reserved.
//

import UIKit
import GoogleMaps
import Alamofire
import SwiftyJSON
import SDWebImage
import NVActivityIndicatorView
import SystemConfiguration.CaptiveNetwork

class MapScreenVC: UIViewController,CLLocationManagerDelegate, GMSMapViewDelegate,NVActivityIndicatorViewable {

    @IBOutlet weak var mapView: GMSMapView!
    var locationManager: CLLocationManager!
    @IBOutlet weak var lblNavigationTitle: UILabel!
    
     var camera:GMSCameraPosition?
     var item1:UIBarButtonItem?
    var item2:UIBarButtonItem?
    var badgeLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate=self
        self.lblNavigationTitle.text = "Map".localized.uppercased()
        self.navigationController?.navigationBar.isHidden=false
        navigationController?.navigationBar.barTintColor = UIColor.white//UIColor(named: "backgroundViewColor")
       
        navigationController?.navigationBar.topItem?.title = "Map".localized.uppercased()
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(named: "NavigationText")!, NSAttributedString.Key.font: UIFont(name: "ProductSans-Bold", size: 17)!]
        navigationItem.leftBarButtonItem?.tintColor = UIColor(named: "NavigationText")!
        // Do any additional setup after loading the view.
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.setNavigationBarItem()
        self.setLeftAlignTitleView(font: UIFont(name: "ProductSans-Bold", size: 17)!, text: "Map".localized.uppercased(), textColor: .white)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        self.navigationController?.navigationBar.isHidden=false
        navigationController?.navigationBar.barTintColor = UIColor.white
        //UIColor(named: "backgroundViewColor")
        navigationController?.navigationBar.topItem?.title = "Map".localized.uppercased()
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(named: "NavigationText")!, NSAttributedString.Key.font: UIFont(name: "ProductSans-Bold", size: 17)!]
        navigationItem.leftBarButtonItem?.tintColor = UIColor(named: "NavigationText")!


        var imageShopingCart = Shared().imageWithImage(image: UIImage(named: "Shoping_Cart")!, scaledToSize: CGSize(width: 23, height: 23))
        imageShopingCart = imageShopingCart.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        
        var imageNotification = Shared().imageWithImage(image: UIImage(named: "Notification_icon")!, scaledToSize: CGSize(width: 23, height: 23))
        imageNotification = imageNotification.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        if targetName != Shared().cannibisAppName {
        let btn1 = UIButton(type: .custom)
        btn1.setImage(imageShopingCart, for: .normal)
        btn1.frame = CGRect(x: 0, y: 0, width: 28, height: 28)
        btn1.addTarget(self, action:#selector(self.cartRedirection), for: .touchUpInside)
        item1 = UIBarButtonItem(customView: btn1)
        item1?.removeBadge()
        }
        let btn2 = UIButton(type: .custom)
        btn2.setImage(imageNotification, for: .normal)
        btn2.addTarget(self, action: #selector(self.notificatin(_:)), for: .touchUpInside)
        btn2.frame = CGRect(x: 0, y: 0, width: 28, height: 28)
        item2 = UIBarButtonItem(customView: btn2)
        let notification_count = UserDefaults.standard.string(forKey: "notifcount") as? String ?? "0"
        if notification_count != "0" {
            self.item2?.addBadge(number: Int(notification_count ?? "") ?? 0)
        } else{
            self.item2?.removeBadge()
        }
        if targetName != Shared().cannibisAppName {
        self.navigationItem.setRightBarButtonItems([item1!,item2!], animated: true)
        } else {
            self.navigationItem.setRightBarButtonItems([item2!], animated: true)
        }
        if let cartCount = UserDefaults.standard.object(forKey: "Badge_cart_count") as? String{
            self.item1?.removeBadge()
            if cartCount != "0"{
                self.item1?.addBadge(number: Int(cartCount)!)
            } else{
                self.item1?.removeBadge()
            }
        } else{
            
        }
    }
    private func setupBadgeLabel() {
        self.badgeLabel = UILabel(frame: CGRect(x: 10, y: -5, width: 25, height: 15))
        self.badgeLabel.backgroundColor = UIColor(hexString: "#33FF99")
        self.badgeLabel.textColor = .black
        self.badgeLabel.textAlignment = .center
        self.badgeLabel.font = UIFont(name: "Karla-Regular_Bold".localized, size: 11)
        self.badgeLabel.textAlignment = .center
        self.badgeLabel.layer.cornerRadius = 7.5
        self.badgeLabel.layer.masksToBounds = true
        self.badgeLabel.isHidden = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    
    @IBAction func sideMenuTapped(_ sender: UIButton){
        slideMenuController()?.toggleLeft()
    }
    
    @IBAction func notificatin(_ sender: UIButton){
        let storyBoard=UIStoryboard(name: "Main", bundle: nil)
        let vc=storyBoard.instantiateViewController(withIdentifier: "NotificationVC") as! NotificationVC
        let navVC=UINavigationController(rootViewController: vc)
        self.slideMenuController()?.changeMainViewController(navVC, close: true)
    }
    
    @objc func cartRedirection(){
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "CartScreenVC") as! CartScreenVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func markerAnimattion(lats:Double,longs:Double,street:String){
//    print("laa-\(lats),\(longs)")
//        mapView.camera = GMSCameraPosition.camera(withLatitude: lats,longitude: longs, zoom: 19)
//        let marker = GMSMarker()
//        marker.position = CLLocationCoordinate2D(latitude: lats, longitude: longs)
//        marker.map = self.mapView
        
        
        mapView.camera = GMSCameraPosition.camera(withLatitude: lats,longitude: longs, zoom: 1)

        self.delay(seconds: 0.5, closure: { () -> () in

            CATransaction.begin()
            CATransaction.setValue(2.0, forKey: kCATransactionAnimationDuration)
            let city = GMSCameraPosition.camera(withLatitude: lats,longitude: longs, zoom: 16)

            self.mapView.animate(to: city)
            let marker = GMSMarker()
            marker.snippet=street
            marker.position = CLLocationCoordinate2D(latitude: lats, longitude: longs)
            marker.map = self.mapView

            CATransaction.commit()
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden=false
        navigationController?.navigationBar.barTintColor = UIColor.white//UIColor(named: "backgroundViewColor")
        navigationController?.navigationBar.topItem?.title = "Map".localized.uppercased()
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(named: "NavigationText")!, NSAttributedString.Key.font: UIFont(name: "ProductSans-Bold", size: 17)!]
        navigationItem.leftBarButtonItem?.tintColor = UIColor(named: "NavigationText")!
        self.MapData()
        self.locationManager = CLLocationManager()
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
    }
    
    func delay(seconds: Double, closure: @escaping () -> ()) {
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            closure()
        }
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    func redirectOnMap(toLatitude:String,toLongitude:String){
        if locationManager.location !=  nil
        {
            let currentLat="\(self.locationManager.location!.coordinate.latitude)"
            let currentLong="\(self.locationManager.location!.coordinate.longitude)"
            UIApplication.shared.openURL(NSURL(string:
                "comgooglemaps://maps?saddr=\(currentLat),\(currentLong)&daddr=\(toLatitude),\(toLongitude)&directionsmode=driving")! as URL)
        } else{
            UIApplication.shared.openURL(NSURL(string:
                "comgooglemaps://maps?q=\(toLatitude),\(toLongitude)")! as URL)
        }
        /*if (UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!))
        {
            UIApplication.shared.openURL(NSURL(string:
                "comgooglemaps://maps?q=\(toLatitude),\(toLongitude)")! as URL)
        } else {
            NSLog("Can't use Google Maps");
            if locationManager.location !=  nil
            {
                let currentLat="\(self.locationManager.location!.coordinate.latitude)"
                let currentLong="\(self.locationManager.location!.coordinate.longitude)"
                if (UIApplication.shared.canOpenURL(NSURL(string:"http://maps.apple.com")! as URL)) {
                    UIApplication.shared.openURL(NSURL(string:"http://maps.apple.com/maps?saddr=\(self.locationManager.location!.coordinate.latitude),\(self.locationManager.location!.coordinate.longitude)&daddr=\(toLatitude),\(toLongitude)&directionsmode=driving")! as URL)
                } else {
                    NSLog("Can't use Apple Maps");
                }
            } else{
                if (UIApplication.shared.canOpenURL(NSURL(string:"http://maps.apple.com")! as URL)) {
                    UIApplication.shared.openURL(NSURL(string:"http://maps.apple.com/maps?q=\(toLatitude),\(toLongitude)")! as URL)
                } else {
                    NSLog("Can't use Apple Maps");
                }
            }*/
        
    }

}

extension MapScreenVC{

    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        self.redirectOnMap(toLatitude: "\(marker.position.latitude)", toLongitude: "\(marker.position.longitude)")
        return false
    }
    
}

extension MapScreenVC{
    func MapData(){
        startAnimating(CGSize(width: 100, height: 100), message: "", type: NVActivityIndicatorType.ballRotate, fadeInAnimation: nil)
        let parameters: Parameters = [
            "language" : "\(Language.language)",
            "club_name" : UserDefaults.standard.object(forKey: "club_name") as! String,
            "user_id" : UserDefaults.standard.string(forKey: "user_id")!,
            "macAddress" : Shared().getWifi(),
        ]
        print("params-\(parameters) ==  \("\(Shared().webCallMap)getMapData.php")")
        Alamofire.request("\(Shared().webCall)getMapData.php", method: .post, parameters: parameters)
            .responseJSON { response in
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()) {
                    self.stopAnimating(nil)
                }
                switch response.result {
                case .success:
                    print("JSON::",response.result.value!)
                    if let jsonData = response.result.value as? [String:Any] {
                        let flag = JSON(jsonData["flag"]!).stringValue
                        if flag == "1"{
                            let data = jsonData["data"] as? [String:Any]
                            let lat = data?["lat"]
                            let long = data?["lng"]
                            let street = data?["club_address"]
                            self.markerAnimattion(lats: lat as! Double, longs: long as! Double, street: street as! String)
//                            print("gdf-\(jsonData["data"])")
//                            let jsonData=jsonData["data"] as? [[String:Any]]
//                                print("jsonData Is",jsonData)
//                            let lat=JSON(jsonData?[0]["lat"]!).doubleValue
//                            let lng=JSON(jsonData?[0]["lng"]!).doubleValue
//                            let street=JSON(jsonData?[0]["club_address"]!).stringValue
//                                self.markerAnimattion(lats: lat, longs: lng, street: street)
//                                print("gdf-\(lat), \(lng)")
                            
                        } else{
                            let message : String = JSON(jsonData["message"]!).stringValue
                            Shared().showAlert(uIViewController: self, title: Shared().error, message: message)
                        }
                    }
                    break
                    
                case .failure(let error):
                    let errorCode = error._code
                    if(errorCode == -1001 || errorCode == -1005 || errorCode == -1009) {
                        Shared().showAlert(uIViewController: self, title: Shared().error, message: error.localizedDescription)
                    } else {
                        Shared().showAlert(uIViewController: self)
                    }
                    print("Server:",error.localizedDescription)
                    break
                }
        }
    }
}
