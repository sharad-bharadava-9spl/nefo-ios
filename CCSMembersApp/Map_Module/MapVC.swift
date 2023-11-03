//
//  CCSMapVC.swift
//  CCSMembersApp
//
//  Created by Parth Makwana on 03/10/23.
//  Copyright © 2023 Jaimin Patel. All rights reserved.
//

/*import UIKit
import MapKit
import CoreLocation
import SwiftyJSON
import Alamofire
import DropDown


class MapVC: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, MapPinPopupDelegate, UITextFieldDelegate {


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
    @IBOutlet weak var mapView: MKMapView!
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
    // @IBOutlet weak var btnCurrentLocation: UIButton!

    //Variables
    var item1:UIBarButtonItem?
    var item2:UIBarButtonItem?
    var item3:UIBarButtonItem?
    var item4:UIBarButtonItem?
    var badgeLabel = UILabel()
    var isExpanded = false
    let locationManager = CLLocationManager()
    var zoomLevel: Double = 0.05
    var isSatelliteView = false
    var arrData = JSON()
    var clubData = JSON()
    //var ArrData = JSON()
    let dropDown = DropDown()
    var didZoomToUserLocation = false
    var selectedRegionIndex: Int?
    // MARK: - ViewController life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setUpUI()
        self.setupLanguage()
        self.maplocation()
        self.mapView.delegate = self
        self.txtsearch.delegate = self
        self.tblFilterList.dataSource = self
        self.tblFilterList.delegate = self
        self.filterClubLocation()
        self.getClubsMap()
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
        self.setLeftAlignTitleView(font: UIFont(name: "ProductSans-Bold", size: 17)!, text: "Map".localized, textColor: .white)
        self.setupBadgeLabel()
        navigationController?.navigationBar.barTintColor = UIColor.white

        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(named: "NavigationText")!, NSAttributedString.Key.font: UIFont(name: "ProductSans-Bold", size: 17)!]
        navigationItem.leftBarButtonItem?.tintColor = UIColor(named: "NavigationText")!
        self.setupNIB()
        self.ViewFiltershow.isHidden = true
        self.ViewFiltershowHeightConstraint.constant = 0
        self.imgfilterimg.image = UIImage(named: "Filterfill")
        self.ViewFilterbtn.backgroundColor = UIColor(named: "Map_filter")

        // Add tap gesture to dismiss keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        //Search Button Add Keyboard
        self.txtsearch.returnKeyType = UIReturnKeyType.search
        //viewMapType Font
        self.lblMap.font = UIFont.boldSystemFont(ofSize: 14)
        self.lblSatellite.font = UIFont.systemFont(ofSize: 14)
        self.tblFilterList.isHidden = true

    }
    // MARK: localized
    func setupLanguage(){
        self.lblfilterDone.text = "Filter".localized
        self.lblSelectRegion.text = "Select_Region".localized
    }
    fileprivate func setupNIB() {
        //        self.tblFriendList.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
        self.tblFilterList.register(UINib(nibName: "\(RegionNameTableViewCell.self)", bundle: nil), forCellReuseIdentifier: "\(RegionNameTableViewCell.self)")
    }
    //Add observer
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
        item2?.removeBadge()


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
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

// MARK: - MAP Button Actions
extension MapVC {
    @IBAction func btnfilter(_ sender: UIButton) {
        if isExpanded {
            self.ViewFiltershowHeightConstraint.constant = 0
            isExpanded = false
            self.ViewFiltershow.isHidden = true
            self.imgfilterimg.image = UIImage(named: "Filterfill")
            self.ViewFilterbtn.backgroundColor = UIColor(named: "Map_filter")
            self.viewMapType.isHidden = false
            self.viewZoomInOut.isHidden = false
            self.tblFilterList.isHidden = true
        } else {
            self.ViewFiltershowHeightConstraint.constant = 130
            isExpanded = true
            self.ViewFiltershow.isHidden = false
            self.imgfilterimg.image = UIImage(named: "Filter")
            self.ViewFilterbtn.backgroundColor = UIColor(named: "Map_filter_fill")
            self.viewMapType.isHidden = true
            self.viewZoomInOut.isHidden = true
        }
    }
    //Fillter Btn Re-direct Region
    @IBAction func btnfilterdone(_ sender: UIButton) {
        // View Hide
        self.ViewFiltershowHeightConstraint.constant = 0
        isExpanded = false
        self.ViewFiltershow.isHidden = true
        self.viewMapType.isHidden = false
        self.viewZoomInOut.isHidden = false
        self.imgfilterimg.image = UIImage(named: "Filterfill")
        self.ViewFilterbtn.backgroundColor = UIColor(named: "Map_filter")

        // No region selected, handle this case as needed
        guard let selectedRegionIndex = selectedRegionIndex else {
            return
        }

        let latitude = self.arrData[selectedRegionIndex]["latitude"].doubleValue
        let longitude = self.arrData[selectedRegionIndex]["longitude"].doubleValue

        let selectedCoordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.3, longitudeDelta: 0.3)
        let region = MKCoordinateRegion(center: selectedCoordinate, span: span)
        mapView.setRegion(region, animated: true)
       // self.getClubsMap()

    }

    @IBAction func zoomInButtonTapped(_ sender: UIButton) {
        zoomLevel = min(zoomLevel * 2, 360)
        let region = MKCoordinateRegion(
            center: mapView.region.center,
            span: MKCoordinateSpan(
                latitudeDelta: max(mapView.region.span.latitudeDelta / 2, 0.0001), // Adjusted calculation
                longitudeDelta: max(mapView.region.span.longitudeDelta / 2, 0.0001) // Adjusted calculation
            )
        )
        mapView.setRegion(region, animated: true)
    }

    @IBAction func zoomOutButtonTapped(_ sender: UIButton) {
        zoomLevel = max(zoomLevel / 2, 0.0005)
        let region = MKCoordinateRegion(
            center: mapView.region.center,
            span: MKCoordinateSpan(
                latitudeDelta: min(mapView.region.span.latitudeDelta * 2, 180), // Adjusted calculation
                longitudeDelta: min(mapView.region.span.longitudeDelta * 2, 180) // Adjusted calculation
            )
        )
        mapView.setRegion(region, animated: true)
    }




    @IBAction func togglesatelliteMapViewButtonTapped(_ sender: UIButton) {
        isSatelliteView.toggle()
        mapView.mapType = isSatelliteView ? .satellite : .standard
        self.lblSatellite.font = UIFont.boldSystemFont(ofSize: 14)
        self.lblMap.font = UIFont.systemFont(ofSize: 14)
    }
    @IBAction func togglnormalMapViewButtonTapped(_ sender: UIButton) {
        isSatelliteView.toggle()
        mapView.mapType = isSatelliteView ? .satellite : .standard
        self.lblMap.font = UIFont.boldSystemFont(ofSize: 14)
        self.lblSatellite.font = UIFont.systemFont(ofSize: 14)
    }
    @IBAction func btnSelectRegionClicked(_ sender: UIButton) {
        self.filterClubLocation()
        if isExpanded {
            tblFilterList.isHidden = false
            isExpanded = false
        } else {
            tblFilterList.isHidden = true
            isExpanded = true
        }

    }
}

// MARK: - MAP Pin Custom
extension MapVC {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // Ensure that the annotation is not the user's location
        guard !(annotation is MKUserLocation) else {
            return nil
        }

        // Define a unique identifier for the annotation view
        let reuseIdentifier = "pinAnnotation"

        // Attempt to dequeue a reusable annotation view
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier)

        // If no reusable view is available, create a new one
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier)
            // Set the image for the annotation view (pin image)
            annotationView!.image = UIImage(named: "Annotion")
            // Allow the callout to be shown when the annotation is selected
            annotationView!.canShowCallout = true
        } else {
            // If a reusable view is available, update its annotation
            annotationView!.annotation = annotation
        }
        //condition 0 falg to not show annotion
        if let clubAnnotation = annotation as? MKPointAnnotation {
            let index = Int(clubAnnotation.accessibilityLabel ?? "0") ?? 0
            let clubData = self.arrData[index]

            let centerImageView = UIImageView(frame: CGRect(x: 8.5, y: 9.5, width: 25, height: 25))
            centerImageView.layer.cornerRadius = 12.5
            centerImageView.layer.masksToBounds = true
            

            // Assuming you have an image URL in your API response
            if let imageURL = clubData["club_logo"].string,
               let url = URL(string: imageURL),
               let data = try? Data(contentsOf: url),
               let image = UIImage(data: data) {
                centerImageView.image = image
            } else {
                // Use a default image if the URL is not valid or the image download fails
                centerImageView.image = UIImage(named: "splash_app_logo")
            }

            // Add the center image view to the annotation view
            annotationView!.addSubview(centerImageView)
        }

        return annotationView
    }

    //Bondry Of location Area
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKCircle {
            let circleRenderer = MKCircleRenderer(overlay: overlay)
            circleRenderer.strokeColor = UIColor.red
            circleRenderer.lineWidth = 0.5
            return circleRenderer
        }
        return MKOverlayRenderer(overlay: overlay)
    }
}


// MARK: - MAP Custom (Redirection And All)
extension MapVC {
    // This function is used to start location services and request user authorization
    func maplocation() {
        // Check if location services are enabled
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            // Check if we have authorization for location
            if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
                locationManager.startUpdatingLocation()
            } else {
                locationManager.requestWhenInUseAuthorization()
            }
        } else {
            // Handle the case where location services are not enabled
            showDefaultLocation()
        }
    }
    // This function is called when the user changes location permissions
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            // Permission granted, show user's current location
            locationManager.startUpdatingLocation()
        case .denied, .restricted:
            // Permission denied or restricted, show default location (Spain)
            showDefaultLocation()
        default:
            break
        }
    }
    // This function is called when the user's location is updated
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let userLocation = locations.last, !didZoomToUserLocation else { return }

        // Update the map view to show user's location
        mapView.showsUserLocation = true

        // Now that you have the user's location, you can update the map view
        let userCoordinate = userLocation.coordinate
        let userLocationAnnotation = MKPointAnnotation()
        userLocationAnnotation.coordinate = userCoordinate
        mapView.addAnnotation(userLocationAnnotation)

        // User Current Location Zoom (only happens once)
        let region = MKCoordinateRegion(center: userCoordinate, span: MKCoordinateSpan(latitudeDelta: 2.0, longitudeDelta: 2.0))
        self.mapView.setRegion(region, animated: true)

        didZoomToUserLocation = true // Set the flag to prevent further automatic re-centering
    }


    // This function is used to show a default location when location services are disabled or denied
    func showDefaultLocation() {
        let defaultCoordinate = CLLocationCoordinate2D(latitude: 40.463669, longitude: -3.749220) // Coordinates for Spain
        let defaultLocationAnnotation = MKPointAnnotation()
        defaultLocationAnnotation.coordinate = defaultCoordinate
        //mapView.addAnnotation(defaultLocationAnnotation)

        // Current Location Zoom By Default Location Zoom
        let region = MKCoordinateRegion(center: defaultCoordinate, span: MKCoordinateSpan(latitudeDelta: 15, longitudeDelta: 15))
        mapView.setRegion(region, animated: true)
    }

    //MARK: Pin Clicked Event
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        mapView.deselectAnnotation(view.annotation, animated: false)
        if let annotation = view.annotation as? MKPointAnnotation{
            let index = Int(annotation.accessibilityLabel ?? "0") as? Int ?? 0
            let selectedCoordinate = annotation.coordinate
            let yOffset: CLLocationDegrees = 0

            let newCenterCoordinate = CLLocationCoordinate2D(latitude: selectedCoordinate.latitude + yOffset, longitude: selectedCoordinate.longitude)

            //let region = MKCoordinateRegion(center: newCenterCoordinate, span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2))
            //let region = MKCoordinateRegion(center: newCenterCoordinate, latitudinalMeters: 500, longitudinalMeters: 500)


            if let annotation = view.annotation {
                mapView.setCenter(annotation.coordinate, animated: true)
            }
            //mapView.setRegion(region, animated: true)

            let selectedClubLat = self.arrData[index]["latitude"].doubleValue
            let selectedClubLong = self.arrData[index]["longitude"].doubleValue

            let selectedClubData = CLLocation(latitude: selectedClubLat, longitude: selectedClubLong)

            let popUpVC = storyboardName.storyBoard_CCSMap.instantiateViewController(withIdentifier: "MapPinPopupVC") as! MapPinPopupVC
            popUpVC.modalPresentationStyle = .overCurrentContext
            popUpVC.modalTransitionStyle = .crossDissolve

            // Set clubData based on what you want to display
            popUpVC.clubData = self.arrData[index]

            popUpVC.delegate = self
            self.present(popUpVC, animated: true, completion: nil)
        }
    }

    func mapPinPopupDidDismiss() {
        // Handle delegate method if needed
    }
}


// MARK: - TableView Delegate And Data source Methods
extension MapVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RegionNameTableViewCell", for: indexPath) as! RegionNameTableViewCell

        // Assuming your custom cell has a label named 'nameLabel'
        cell.lblRegionName.text = self.arrData[indexPath.row]["name"].stringValue
        cell.btnRegionName.tag = indexPath.row

        cell.btnRegionName.addTarget(self, action: #selector(setRegion(sender:)), for: .touchUpInside)
        return cell
    }

    /*func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
     selectedRegionIndex = indexPath.row
     lblSelectRegion.text = self.arrData[indexPath.row]["name"].stringValue
     self.dismiss(animated: true, completion: nil)
     }*/

    @objc func setRegion(sender:UIButton){
        selectedRegionIndex = sender.tag
        lblSelectRegion.text = self.arrData[sender.tag]["name"].stringValue
        self.dismiss(animated: true, completion: nil)
        self.tblFilterList.isHidden = true
    }
}


// MARK: - API Call Method
extension MapVC {
    func filterClubLocation() {
        APIManager.callAPIRequest(Method: .post, url: "\(api_filterlocation)", parameters: APIParam.filterlocation(language: "\(Language.language)").getParam(), headers: nil, showAlert: false, completion: { jsonResult, msg in
            self.arrData = JSON(jsonResult["data"])
            self.tblFilterList.reloadData()
        },
                                  failure: { (response, errorMessage) in
            print("Failure: \(errorMessage)")
            // Handle failure condition
        })
    }
    //club Info Api And Func
    func getClubsMap() {
        APIManager.callAPIRequest(Method: .post, url: "\(api_getClubsMap)", parameters: APIParam.getClubsMap(language: "\(Language.language)").getParam(), headers: nil, showAlert: false, completion: { jsonResult, msg in
            if jsonResult["flag"].stringValue == "1" {
                self.arrData = JSON(jsonResult["data"])
                self.addMarkersForClubs()
            } else {
                // Handle the case where flag is not 1
            }
        },
                                  failure: { (response, errorMessage) in
            print("Failure: \(errorMessage)")
            // Handle failure condition
        }
        )
    }
    func addMarkersForClubs() {
        for (indx,club) in self.arrData.arrayValue.enumerated() {
            if club["is_show"].boolValue {
                let latitude = club["latitude"].doubleValue
                let longitude = club["longitude"].doubleValue
                let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                let ClubDetails = MKPointAnnotation()
                ClubDetails.coordinate = coordinate
                ClubDetails.accessibilityLabel = "\(indx)"
                ClubDetails.title = club["club_name"].stringValue
                ClubDetails.subtitle = club["full_address"].stringValue
                mapView.addAnnotation(ClubDetails)

            }
        }
    }
}
*/






