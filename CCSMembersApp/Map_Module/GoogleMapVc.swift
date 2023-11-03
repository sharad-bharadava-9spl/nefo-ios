//
//  GoogleMapVc.swift
//  CCSMembersApp
//
//  Created by Parth Makwana on 10/10/23.
//  Copyright © 2023 Jaimin Patel. All rights reserved.
//

import UIKit
import GoogleMaps
import SwiftyJSON
import Alamofire
import WebKit
import GooglePlaces

class GoogleMapVc: UIViewController, GMSMapViewDelegate, CLLocationManagerDelegate, MapPinPopupDelegate, WKNavigationDelegate, UITextFieldDelegate {
    
    // MARK: - Outlet
    @IBOutlet weak var ViewTop: UIView!
    @IBOutlet weak var Viewtxtfieald: UIView!
    @IBOutlet weak var ViewFilterbtn: UIView!
    @IBOutlet weak var btnfilter: UIButton!
    @IBOutlet weak var imgsearch: UIImageView!
    @IBOutlet weak var txtsearch: UITextField!
    @IBOutlet weak var ViewFiltershow: UIView!
    @IBOutlet weak var lblSelectRegion: UILabel!
    @IBOutlet weak var btnSelectRegion: UIButton!
    @IBOutlet weak var imgSelectRegion: UIImageView!
    @IBOutlet weak var btnfilterDone: UIButton!
    @IBOutlet weak var ViewfilterDone: UIView!
    @IBOutlet weak var lblfilterDone: UILabel!
    @IBOutlet weak var imgfilterimg: UIImageView!
    @IBOutlet weak var ViewFiltershowHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var viewMapType: UIView!
    @IBOutlet weak var viewMap: UIView!
    @IBOutlet weak var lblMap: UILabel!
    @IBOutlet weak var viewSatellite: UIView!
    @IBOutlet weak var lblSatellite: UILabel!
    @IBOutlet weak var viewZoomInOut: UIView!
    @IBOutlet weak var viewZoomIn: UIView!
    @IBOutlet weak var viewZoomOut: UIView!
    @IBOutlet weak var tblFilterList: UITableView!
    @IBOutlet weak var googleMapView: GMSMapView!
    @IBOutlet weak var tblsearchsuggetion: UITableView!
    
    
    //Variables2
    var item1:UIBarButtonItem?
    var item2:UIBarButtonItem?
    var item3:UIBarButtonItem?
    var item4:UIBarButtonItem?
    var badgeLabel = UILabel()
    var isExpanded = true
    let locationManager = CLLocationManager()
    var isSatelliteView = false
    var arrData = JSON()
    var clubData = JSON()
    var searchPlaceData = JSON()
    var selectedRegionIndex: Int?
    var placeDetails: [[String: Any]] = []
    
    
    // MARK: - ViewController life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpUI()
        self.setupLanguage()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNavigationBarButtonOnRight()
        navigationItem.leftBarButtonItem?.tintColor = UIColor(named: "NavigationText")
        // self.locationManager.stopUpdatingLocation()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.removeObserver()
        self.addObserver()
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.removeObserver()
    }
    deinit {
        self.removeObserver()
    }
    
    //MARK: SetupUI method
    func setUpUI(){
        
        self.txtsearch.delegate = self
        self.setLeftAlignTitleView(font: UIFont(name: "ProductSans-Bold", size: 17)!, text: "CCS Map".localized, textColor: .white)
        self.setupBadgeLabel()
        navigationController?.navigationBar.barTintColor = UIColor.white
        
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(named: "NavigationText")!, NSAttributedString.Key.font: UIFont(name: "ProductSans-Bold", size: 17)!]
        navigationItem.leftBarButtonItem?.tintColor = UIColor(named: "NavigationText")!
        self.setupNIB()
        self.ViewFiltershow.isHidden = true
        self.ViewFiltershowHeightConstraint.constant = 0
        self.imgfilterimg.image = UIImage(named: "Filterfill")
        self.ViewFilterbtn.backgroundColor = UIColor(named: "Map_filter")
        self.maplocation()
        self.hideKeyboardWhenTappedAround()
        //Search Button Add Keyboard
        self.txtsearch.returnKeyType = UIReturnKeyType.done
        //viewMapType Font
        self.lblMap.font = UIFont.boldSystemFont(ofSize: 14)
        self.lblSatellite.font = UIFont.systemFont(ofSize: 14)
        self.tblFilterList.isHidden = true
        self.tblFilterList.dataSource = self
        self.tblFilterList.delegate = self
        self.tblsearchsuggetion.dataSource = self
        self.tblsearchsuggetion.delegate = self
        self.callApiGetClubsMap()
        self.callApifilterClubLocation()
        self.tblsearchsuggetion.isHidden = true
        self.txtsearch.addTarget(self, action: #selector(textFieldTapped(_:)), for: .touchUpInside)
        self.txtsearch.returnKeyType = UIReturnKeyType.done  //Done Button Add Keyboard
    }
    // MARK: localized
    func setupLanguage(){
        self.lblfilterDone.text = "Filter".localized
        self.lblSelectRegion.text = "Select_Region".localized
        self.lblSatellite.text = "Satellite_View_Show_lbl".localized
        self.lblMap.text = "Map_View_Show_lbl".localized
        self.txtsearch.placeholder = "Search".localized
        
    }
    fileprivate func setupNIB() {
        //        self.tblFriendList.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
        self.tblFilterList.register(UINib(nibName: "\(RegionNameTableViewCell.self)", bundle: nil), forCellReuseIdentifier: "\(RegionNameTableViewCell.self)")
        self.tblsearchsuggetion.register(UINib(nibName: "\(SearchLocationTableViewCell.self)", bundle: nil), forCellReuseIdentifier: "\(SearchLocationTableViewCell.self)")
        
    }
    @objc func textFieldTapped(_ textField: UITextField) {
        self.searchPlaceApi()
        self.txtsearch.resignFirstResponder()
        let acController = GMSAutocompleteViewController()
        acController.delegate = self
        present(acController, animated: true, completion: nil)
    }
}

//MARK: NAVBAR ITEM

//Add observer
extension GoogleMapVc {
    func addObserver(){
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateCartCountNotification(notification:)), name: Notification.Name("updateCartCount"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.openChatDetailsScreen(notification:)), name: Notification.Name(NotificationName().OepnChatDetailScreen), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateMessageCount(notification:)), name: Notification.Name(NotificationName().UpdateGlobalChatCount), object: nil)
    }
    //Remove Observer
    func removeObserver(){
        NotificationCenter.default.removeObserver(self, name: Notification.Name(NotificationName().UpdateGlobalChatCount), object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name(NotificationName().OepnChatDetailScreen), object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name("updateCartCount"), object: nil)
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setNavigationBarButtonOnRight(){
        self.setNavigationBarItem()
        self.navigationController?.navigationBar.isHidden = false
        navigationItem.leftBarButtonItem?.tintColor = UIColor(named: "NavigationText")
        var imageShopingCart = Shared().imageWithImage(image: UIImage(named: "Shoping_Cart")!, scaledToSize: CGSize(width: 23, height: 23))
        imageShopingCart = imageShopingCart.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        
        var imageNotification = Shared().imageWithImage(image: UIImage(named: "Notification_icon")!, scaledToSize: CGSize(width: 23, height: 23))
        imageNotification = imageNotification.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        
        /* var imageQRCode = Shared().imageWithImage(image: UIImage(named: "icon_showQRCode")!, scaledToSize: CGSize(width: 23, height: 23))
         imageQRCode = imageQRCode.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
         
         var imageChat = Shared().imageWithImage(image: UIImage(named: "icon_chat_topbar")!, scaledToSize: CGSize(width: 25, height: 25))
         imageChat = imageChat.withRenderingMode(UIImage.RenderingMode.alwaysOriginal) */
        
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
        btn2.addTarget(self, action: #selector(self.notificationScreenRedirection), for: .touchUpInside)
        btn2.frame = CGRect(x: 0, y: 0, width: 28, height: 28)
        item2 = UIBarButtonItem(customView: btn2)
        let notification_count = UserDefaults.standard.string(forKey: "notifcount") as? String ?? "0"
        if notification_count != "0" {
            self.item2?.addBadge(number: Int(notification_count ?? "") ?? 0)
        } else{
            self.item2?.removeBadge()
        }
        
        let btn4 = UIButton(type: .custom)
        //btn4.setImage(imageChat, for: .normal)
        btn4.addTarget(self, action: #selector(self.openFriendsChatScreen), for: .touchUpInside)
        btn4.frame = CGRect(x: 0, y: 0, width: 28, height: 28)
        btn4.addSubview(self.badgeLabel)
        item4 = UIBarButtonItem(customView: btn4)
        item4?.removeBadge()
        
        //        self.setupMessageCount()
        if targetName != Shared().cannibisAppName {
            if let _ = UserDefaults.standard.object(forKey: "club_name"){
                self.navigationItem.setRightBarButtonItems([item1!,item2!,item4!], animated: true)
            }else{
                self.navigationItem.setRightBarButtonItems([item1!,item4!], animated: true)
            }
            
        } else {
            if let _ = UserDefaults.standard.object(forKey: "club_name"){
                self.navigationItem.setRightBarButtonItems([item2!,item4!], animated: true)
            }else{
                self.navigationItem.setRightBarButtonItems([item4!], animated: true)
            }
            //            self.navigationItem.setRightBarButtonItems([item2!,item3!,item4!], animated: true)
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
        
        if #available(iOS 13.0, *) {
            let statusBar = UIView(frame: (UIApplication.shared.keyWindow?.windowScene?.statusBarManager?.statusBarFrame)!)
            statusBar.backgroundColor = UIColor.clear
            UIApplication.shared.keyWindow?.addSubview(statusBar)
        }
    }
    
    // MARK: - Bar button actions
    @objc func openChatDetailsScreen(notification: Notification) {
        let dict = notification.object as? [String:Any]
        let vc = storyboardName.storyBoard_Chat.instantiateViewController(withIdentifier: "ChatDetailsVC") as! ChatDetailsVC
        vc.userid = dict?["userid"] as? String ?? ""
        vc.receiverName = dict?["receiverName"] as? String ?? ""
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func notificationScreenRedirection(){
        let storyBoard=UIStoryboard(name: "Main", bundle: nil)
        let vc=storyBoard.instantiateViewController(withIdentifier: "NotificationVC") as! NotificationVC
        let navVC=UINavigationController(rootViewController: vc)
        slideMenuController()?.changeMainViewController(navVC, close: true)
    }
    
    @objc func cartRedirection(){
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "CartScreenVC") as! CartScreenVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @objc func openFriendsChatScreen(){
        
        
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
    @objc func updateMessageCount(notification: Notification){
        //let dict = notification.object as? [String:Any]
        
        let count = (notification.object as? [String:Any])?["count"] as? Int ?? 0
        if count > 0{
            self.badgeLabel.isHidden = false
            if count > 99 {
                self.badgeLabel.text = "+99"
            }else{
                self.badgeLabel.text = "\(count)"
            }
        }else{
            self.badgeLabel.isHidden = true
        }
    }
    // MARK: - Bar button actions
    @objc func updateCartCountNotification(notification: Notification) {
        if let cartCount = UserDefaults.standard.object(forKey: "Badge_cart_count") as? String{
            self.item1?.removeBadge()
            if cartCount != "0"{
                self.item1?.addBadge(number: Int(cartCount)!)
            } else{
                self.item1?.removeBadge()
            }
        }
    }
    // Add tap gesture to dismiss keyboard
    @objc  func handleMapTap() {
        view.endEditing(true)
    }
}
//MARK: Extension for button click
extension GoogleMapVc {
    @IBAction func btnfilter(_ sender: UIButton) {
        
        UIView.transition(with: tblFilterList, duration: 0.4,
                          options: .transitionCrossDissolve,
                          animations: {
            if self.isExpanded {
                self.ViewFiltershowHeightConstraint.constant = 0
                self.isExpanded = false
                self.ViewFiltershow.isHidden = true
                self.imgfilterimg.image = UIImage(named: "Filterfill")
                self.ViewFilterbtn.backgroundColor = UIColor(named: "Map_filter")
                self.viewMapType.isHidden = false
                self.viewZoomInOut.isHidden = false
                self.tblFilterList.isHidden = true
                self.tblsearchsuggetion.isHidden = true
            } else {
                //                UIView.animate(withDuration: 0.5) {
                //                    self.ViewFiltershowHeightConstraint.constant = 130
                //                    self.view.layoutIfNeeded()
                //                }
                self.ViewFiltershowHeightConstraint.constant = 115
                self.isExpanded = true
                self.ViewFiltershow.isHidden = false
                self.imgfilterimg.image = UIImage(named: "Filter")
                self.ViewFilterbtn.backgroundColor = UIColor(named: "Map_filter_fill")
                self.viewMapType.isHidden = true
                self.viewZoomInOut.isHidden = true
                self.tblsearchsuggetion.isHidden = true
            }
        })
        
        
        
        
    }
    @IBAction func btnfilterdone(_ sender: UIButton) {
        // View Hide
        // self.lblSelectRegion.text?.localized
        self.ViewFiltershowHeightConstraint.constant = 0
        self.txtsearch.text = ""
        self.isExpanded = false
        self.ViewFiltershow.isHidden = true
        self.viewMapType.isHidden = false
        self.viewZoomInOut.isHidden = false
        self.imgfilterimg.image = UIImage(named: "Filterfill")
        self.ViewFilterbtn.backgroundColor = UIColor(named: "Map_filter")
        
        // Check if a region is selected
        guard let selectedRegionIndex = selectedRegionIndex else {
            self.showAlert(title: "", message: "Please select a region".localized)
            return
        }
        
        let latitude = self.arrData[selectedRegionIndex]["latitude"].doubleValue
        let longitude = self.arrData[selectedRegionIndex]["longitude"].doubleValue
        
        // Create a camera position based on the selected region
        let camera = GMSCameraPosition.camera(withLatitude: latitude, longitude: longitude, zoom: 9)
        self.googleMapView.animate(to: camera)
    }
    
    @IBAction func zoomInButtonTapped(_ sender: UIButton) {
        let currentCamera = self.googleMapView.camera
        let newZoom = currentCamera.zoom + 1
        let camera = GMSCameraPosition.camera(withTarget: currentCamera.target, zoom: newZoom)
        self.googleMapView.animate(to: camera)
    }
    
    @IBAction func zoomOutButtonTapped(_ sender: UIButton) {
        let currentCamera = self.googleMapView.camera
        let newZoom = currentCamera.zoom - 1
        let camera = GMSCameraPosition.camera(withTarget: currentCamera.target, zoom: newZoom)
        self.googleMapView.animate(to: camera)
    }
    
    @IBAction func togglesatelliteMapViewButtonTapped(_ sender: UIButton) {
        self.isSatelliteView = true // Always set isSatelliteView to true when Satellite button is tapped
        self.googleMapView.mapType = .satellite
        self.lblSatellite.font = UIFont.boldSystemFont(ofSize: 14)
        self.lblMap.font = UIFont.systemFont(ofSize: 14)
    }
    
    @IBAction func togglnormalMapViewButtonTapped(_ sender: UIButton) {
        self.isSatelliteView = false
        self.googleMapView.mapType = .normal
        self.lblMap.font = UIFont.boldSystemFont(ofSize: 14)
        self.lblSatellite.font = UIFont.systemFont(ofSize: 14)
    }
    
    @IBAction func btnSelectRegionClicked(_ sender: UIButton) {
        // self.filterClubLocation()
        if self.isExpanded {
            self.tblFilterList.isHidden = false
            self.isExpanded = false
        } else {
            self.tblFilterList.isHidden = true
            self.isExpanded = true
        }
    }
}

//MARK: Extension for TextField delegate method
extension GoogleMapVc {
    // UITextField delegate method to handle text changes
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) ?? ""
        if currentText == ""{
            self.searchPlaceData = JSON("")
            self.tblsearchsuggetion.isHidden = true
            self.tblsearchsuggetion.reloadData()
        }else{
            self.callGoogleAPISearchPlace(query: currentText)
        }
        
        return true
    }
}

// MARK: - TableView Delegate And Data source Methods
extension GoogleMapVc: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.tblFilterList { // Assuming firstTableView is your first table view
            return self.arrData.count
        }else{ // Assuming secondTableView is your second table view
            return self.searchPlaceData.count
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == tblFilterList {
            let cell = tableView.dequeueReusableCell(withIdentifier: "RegionNameTableViewCell", for: indexPath) as! RegionNameTableViewCell
            cell.lblRegionName.text = self.arrData[indexPath.row]["name"].stringValue
            cell.btnRegionName.tag = indexPath.row
            cell.btnRegionName.addTarget(self, action: #selector(setRegion(sender:)), for: .touchUpInside)
            return cell
        }else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SearchLocationTableViewCell", for: indexPath) as! SearchLocationTableViewCell
            let detail = self.searchPlaceData[indexPath.row]
            cell.lblseachlocation.text = detail["description"].stringValue
            cell.btnAction.addTarget(self, action: #selector(clickonSearchPlace(sender:)), for: .touchUpInside)
            return cell
        }
    }
    
    
    @objc func setRegion(sender: UIButton){
        self.selectedRegionIndex = sender.tag
        self.lblSelectRegion.text = self.arrData[sender.tag]["name"].stringValue
        self.dismiss(animated: true, completion: nil)
        self.tblFilterList.isHidden = true
    }
    @objc func clickonSearchPlace(sender: UIButton){
        self.txtsearch.text = self.searchPlaceData[sender.tag]["description"].stringValue
        self.tblFilterList.isHidden = true
        self.callAPISearchParticularPlace(placeId:self.searchPlaceData[sender.tag]["place_id"].stringValue)
    }
}

//MARK: keyboard Done button
extension GoogleMapVc {
    //done button Add Keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Dismiss the keyboard
        self.txtsearch.resignFirstResponder()
        self.tblsearchsuggetion.isHidden = true
        return true
    }
    
}

//MAR: Keyboard Search Redirection
extension GoogleMapVc:GMSAutocompleteViewControllerDelegate {
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        // Get the place name from 'GMSAutocompleteViewController'
        // Then display the name in textField
        self.txtsearch.text = place.name
        let camera = GMSCameraPosition.camera(withTarget: place.coordinate, zoom: 9.0)
        self.googleMapView.animate(to: camera)
        
        
        // Dismiss the GMSAutocompleteViewController when something is selected
        dismiss(animated: true, completion: nil)
    }
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // Handle the error
        print("Error: ", error.localizedDescription)
    }
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        // Dismiss when the user canceled the action
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - MAP Pin Custom
extension GoogleMapVc {
    func addCustomPin() {
        let mapCenter = CLLocationCoordinate2DMake(googleMapView.camera.target.latitude, googleMapView.camera.target.longitude)
        let marker = GMSMarker(position: mapCenter)
        
        marker.icon = UIImage(named: "Map")
        marker.map = googleMapView
    }
}

// MARK: - MAP Custom (Redirection And All)
extension GoogleMapVc {
    // This function is used to start location services and request user authorization
    func maplocation() {
        // Check if location services are enabled
        DispatchQueue.main.async {
            if CLLocationManager.locationServicesEnabled() {
                self.locationManager.delegate = self
                self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
                // Check if we have authorization for location
                if CLLocationManager.authorizationStatus() == .authorizedWhenInUse || CLLocationManager.authorizationStatus() == .authorizedAlways{
                    //self.locationManager.startUpdatingLocation()
                    
                    self.setLiveLocationOfUser(location: self.locationManager.location?.coordinate ?? CLLocationCoordinate2D(latitude: 40.463669, longitude: -3.749220))
                } else {
                    self.showDefaultLocation()
                    self.locationManager.requestWhenInUseAuthorization()
                }
            } else {
                // Handle the case where location services are not enabled
                self.showDefaultLocation()
            }
        }
    }
    // This function is called when the user changes location permissions
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            // Permission granted, show user's current location
            //locationManager.startUpdatingLocation()
            self.setLiveLocationOfUser(location: self.locationManager.location?.coordinate ?? CLLocationCoordinate2D(latitude: 40.463669, longitude: -3.749220))
        case .denied, .restricted:
            // Permission denied or restricted, show default location (Spain)
            showDefaultLocation()
        default:
            break
        }
    }
    // This function is called when the user's location is updated
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
    }
    
    
    // This function is used to show a default location when location services are disabled or denied
    func showDefaultLocation() {
        self.googleMapView.delegate = self
        let defaultCoordinate = CLLocationCoordinate2D(latitude: 40.463669, longitude: -3.749220) // Coordinates for Spain
        
        var camera: GMSCameraPosition
        camera = GMSCameraPosition.camera(withTarget: defaultCoordinate, zoom: 5.0)
        
        // Create the map view
        self.googleMapView.camera = camera
        self.googleMapView.animate(to: camera)
        
    }
    
    func setLiveLocationOfUser(location : CLLocationCoordinate2D){
        self.googleMapView.delegate = self
        self.googleMapView.isMyLocationEnabled = true
        self.googleMapView.settings.myLocationButton = true
        // Use a default location (Spain) if user location is unavailable
        
        // Set the initial camera position
        var camera : GMSCameraPosition = GMSCameraPosition.camera(withTarget: location, zoom: 5.0)
        // Create the map view
        self.googleMapView.camera = camera
        // Set the map view delegate
        self.googleMapView.animate(to: camera)
        
        //self.googleMapView.animate(toLocation: location)
    }
}


//MARK: API CALL
extension GoogleMapVc {
    //Filter Region
    func callApifilterClubLocation() {
        APIManager.callAPIRequest(Method: .post, url: "\(api_filterlocation)", parameters: APIParam.filterlocation(language: "\(Language.language)").getParam(), headers: nil, showAlert: false, completion: { jsonResult, msg in
            self.arrData = JSON(jsonResult["data"])
            self.tblFilterList.reloadData()
            
        },
                                  failure: { (response, errorMessage) in
            print("Failure: \(errorMessage)")
            // Handle failure condition
        })
    }
    // Club Info Api And Func
    func callApiGetClubsMap() {
        APIManager.callAPIRequest(Method: .post, url: "\(api_getClubsMap)", parameters: APIParam.getClubsMap(language: "\(Language.language)").getParam(), headers: nil, showAlert: false, completion: { jsonResult, msg in
            if jsonResult["flag"].stringValue == "1" {
                self.clubData = JSON(jsonResult["data"])
                self.googleMapView.delegate = self
                self.addMarkersForClubs()
            } else {
                
            }
        },
                                  failure: { (response, errorMessage) in
            print("Failure: \(errorMessage)")
            // Handle failure condition
        }
        )
    }
    //Particular Region Marker
    func addMarkersForClubs() {
        for (indx, club) in self.clubData.arrayValue.enumerated() {
            if club["is_show"].boolValue {
                let latitude = club["latitude"].doubleValue
                let longitude = club["longitude"].doubleValue
                let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                let clubMarker = GMSMarker(position: coordinate)
                clubMarker.accessibilityLabel = "\(indx)"
                
                // Customize the marker icon
                let customView = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 60))
                customView.backgroundColor = UIColor.clear
                
                // Create and configure the first image view
                let imageView1 = UIImageView(frame: CGRect(x: 0, y: 5, width: 40, height: 60))
                imageView1.image = UIImage(named: "Annotion") // Set the appropriate image name
                // imageView1.isUserInteractionEnabled = false
                imageView1.contentMode = .scaleAspectFill
                imageView1.clipsToBounds = true
                customView.addSubview(imageView1)
                // Create and configure the second image view
                let imageView2 = UIImageView(frame: CGRect(x: 5 , y: 7, width: 30, height: 30))
                imageView2.image = UIImage(named: "Map_pin_deffualt") // Set the appropriate image name
                imageView2.layer.cornerRadius = 15.0 // Corrected typo
                imageView2.contentMode = .scaleAspectFill
                imageView2.clipsToBounds = true
                imageView1.addSubview(imageView2) // Add imageView2 as a subview of imageView1
                // imageView2.isUserInteractionEnabled = false
                // Assuming you're using Auto Layout
                customView.translatesAutoresizingMaskIntoConstraints = false
                
                /*
                // Download and set the marker icon image
                if let imageURL = club["club_logo"].string,
                   let url = URL(string: imageURL) {
                    URLSession.shared.dataTask(with: url) { data, _, error in
                        if let data = data, let image = UIImage(data: data) {
                            DispatchQueue.main.async {
                                //markerIconView.image = image
                                //clubMarker.iconView = markerIconView
                                imageView2.image = image
                            }
                        }
                    }.resume()
                } else {
                    // Use a default image if the URL is not valid or the image download fails
                    imageView2.image = UIImage(named: "splash_app_logo")
                }*/
                
                if let imageURL = club["club_logo"].string,
                   let url = URL(string: imageURL) {
                    if let cachedImage = imageCache.object(forKey: imageURL as NSString) {
                        imageView2.image = cachedImage
                    } else {
                        URLSession.shared.dataTask(with: url) { data, _, error in
                            if let data = data, let image = UIImage(data: data) {
                                DispatchQueue.main.async {
                                    imageCache.setObject(image, forKey: imageURL as NSString)
                                    imageView2.image = image
                                }
                            } else {
                                // Use a default image if download fails
                                DispatchQueue.main.async {
                                    imageView2.image = UIImage(named: "Map_pin_deffualt")
                                }
                            }
                        }.resume()
                    }
                } else {
                    // Use a default image if the URL is not valid
                    imageView2.image = UIImage(named: "Map_pin_deffualt")
                }
                
                
                clubMarker.iconView = customView
                clubMarker.isTappable = true
                clubMarker.map = self.googleMapView
            }
        }
    }
    //Tapped The Marker Club details
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        print("Marker tapped")
        
        //Map pin tapped Hide/show View
        self.ViewFiltershowHeightConstraint.constant = 0
        isExpanded = false
        self.ViewFiltershow.isHidden = true
        self.imgfilterimg.image = UIImage(named: "Filterfill")
        self.ViewFilterbtn.backgroundColor = UIColor(named: "Map_filter")
        self.viewMapType.isHidden = false
        self.viewZoomInOut.isHidden = false
        self.tblFilterList.isHidden = true
        
        
        if self.googleMapView.camera.zoom > 9.0{
            self.googleMapView.animate(to: GMSCameraPosition.camera(withTarget: marker.position, zoom: self.googleMapView.camera.zoom))
        }else{
            self.googleMapView.animate(to: GMSCameraPosition.camera(withTarget: marker.position, zoom: 9.0))
        }
        
        
        // Get the index of the selected club
        guard let index = Int(marker.accessibilityLabel ?? "0") else {
            return false
        }
        // Get the data of the selected club
        let selectedClubData = self.clubData[index]
        
        // Create an instance of MapPinPopupVC and set its properties
        let popUpVC = storyboard?.instantiateViewController(withIdentifier: "MapPinPopupVC") as! MapPinPopupVC
        popUpVC.modalPresentationStyle = .overCurrentContext
        popUpVC.modalTransitionStyle = .crossDissolve
        popUpVC.clubData = selectedClubData
        popUpVC.delegate = self
        
        
        // Present the MapPinPopupVC
        present(popUpVC, animated: true, completion: nil)
        return true
    }
    
    func mapPinPopupDidDismiss() {
        // Handle any actions after the pop-up is dismissed
    }
    
    //txtfieald Search Region request
    // Function to make API requests as the user types
    func makeAutoCompleteRequest(query: String) {
        guard let apiKey = "\(Shared().GOOGLE_API_KEY)".addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else {
            return
        }
        
        let baseURL = "https://maps.googleapis.com/maps/api/place/autocomplete/json?"
        let input = query
        let urlString = "\(baseURL)input=\(input)&key=\(apiKey)"
        
        if let url = URL(string: urlString) {
            URLSession.shared.dataTask(with: url) { (data, _, error) in
                if let error = error {
                    print("Error: \(error)")
                } else if let data = data {
                    do {
                        if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                           let predictions = json["predictions"] as? [[String: Any]] {
                            print(json)
                            
                        }
                    } catch {
                        print("Error parsing JSON: \(error)")
                    }
                }
            }.resume()
        }
    }
    
    //txtfieald Search Region
    func callGoogleAPISearchPlace(query: String) {
        guard let apiKey = "\(Shared().GOOGLE_API_KEY)".addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else {
            return
        }
        
        let baseURL = "https://maps.googleapis.com/maps/api/place/autocomplete/json?"
        let input = query
        let urlString = "\(baseURL)input=\(input)&key=\(apiKey)"
        
        APIManager.callAPIRequest(Method: .get, url: "\(urlString)", parameters: nil, headers: nil, showAlert: false, completion: { jsonResult, msg in
            
            self.searchPlaceData = JSON(jsonResult)["predictions"]
            print(jsonResult)
            //self.arrData = JSON(jsonResult["data"])
            if self.searchPlaceData.count > 0{
                self.tblsearchsuggetion.reloadData()
                self.tblsearchsuggetion.isHidden = false
            }else{
                self.tblsearchsuggetion.isHidden = true
            }
        },
                                  failure: { (response, errorMessage) in
            print("Failure: \(errorMessage)")
            // Handle failure condition
        })
    }
    //txtfieald Search Region
    func callAPISearchParticularPlace(placeId:String) {
        let apiKey = "AIzaSyB37T3DT1fLza9MGhJgDYbqh8oODJTuYsk"
        let baseURL = "https://maps.googleapis.com/maps/api/place/details/json?"
        
        //let placeId = "ChIJN1t_tDeuEmsRUsoyG83frY4"
        
        // Construct the full URL for the API request with properly encoded parameters.
        if let urlString = "\(baseURL)place_id=\(placeId)&key=\(Shared().GOOGLE_API_KEY)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
           let url = URL(string: urlString) {
            
            
            APIManager.callAPIRequest(Method: .get, url: "\(url)", parameters: nil, headers: nil, showAlert: false, completion: { jsonResult, msg in
                
                
                self.searchPlaceData = JSON("")
                self.tblsearchsuggetion.reloadData()
                self.tblsearchsuggetion.isHidden = true
                
                let dictGeoMetry = JSON(jsonResult)["result"]["geometry"]["location"]
                print(jsonResult)
                
                
                
                var camera = GMSCameraPosition.camera(withTarget: CLLocationCoordinate2D(latitude: dictGeoMetry["lat"].doubleValue, longitude: dictGeoMetry["lng"].doubleValue), zoom: 9 )//self.googleMapView.camera.zoom)
                self.googleMapView.camera = camera
                self.googleMapView.animate(to: camera)
                
            },
                                      failure: { (response, errorMessage) in
                print("Failure: \(errorMessage)")
                // Handle failure condition
            })
        } else {
            print("Invalid URL")
        }
    }
    
    func processPlaceDetails(_ details: [String: Any]) {
        // Assuming you have a data structure to hold your place details, like an array of dictionaries
        var placeDetails: [[String: Any]] = []
        
        if let result = details["result"] as? [String: Any] {
            if let name = result["name"] as? String {
                let placeDetail = ["place_name": name]
                placeDetails.append(placeDetail)
                
                // Assuming you have a table view outlet called tblsearchsuggetion
                DispatchQueue.main.async {
                    self.tblsearchsuggetion.reloadData()
                }
            }
        }
    }
    
    func searchPlaceApi(){
        
        let apiKey = "AIzaSyB37T3DT1fLza9MGhJgDYbqh8oODJTuYsk" // Replace with your actual API key.
        
        let baseURL = "https://maps.googleapis.com/maps/api/place/findplacefromtext/json?"
        
        let input = "Eiffel Tower"
        let inputType = "textquery"
        
        // Construct the full URL for the API request with properly encoded parameters.
        if let encodedInput = input.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
           let urlString = "\(baseURL)input=\(encodedInput)&inputtype=\(inputType)&key=\(Shared().GOOGLE_API_KEY)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
           let url = URL(string: urlString) {
            
            let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                if let error = error {
                    print("Error: \(error)")
                } else if let data = data {
                    do {
                        if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                            print(json)
                        }
                    } catch {
                        print("Error parsing JSON: \(error)")
                    }
                }
            }
            
            task.resume()
        } else {
            print("Invalid URL")
        }
    }
    
}
