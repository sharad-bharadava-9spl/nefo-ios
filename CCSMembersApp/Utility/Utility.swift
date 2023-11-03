//
//  Utility.swift
//  Swift Structure
//


import Foundation
import AVFoundation
import AVKit
import MapKit
import CoreLocation
import Alamofire
import SwiftyJSON


// MARK: - Header Dictonary
var const_dictHeader :Dictionary<String,String>             = ["Content-Type" : "application/json"]

// MARK: - Log(Print) Utility
func logD(_ message:Any,
          file: String = #file, line: Int = #line,function: String = #function) {
    let str  : NSString = file as NSString
    //   #if DEBUG
    print("[\(str.lastPathComponent)][\(line)][\(function)]\n💜\(message)💜\n")
    //  #endif
}

// MARK: - UIView
//Border
func setDefaultBorder(_ view : UIView, color : UIColor, width : CGFloat)
{
    view.layer.borderColor = color.cgColor
    view.layer.borderWidth = width
}
// MARK: - Set TopCorner Radius
func curveTopCorners(_ view : UIView, radius:CGFloat) {
    let path = UIBezierPath(roundedRect: view.bounds, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: radius, height: 0))
    let maskLayer = CAShapeLayer()
    maskLayer.frame = view.bounds
    maskLayer.path = path.cgPath
    view.layer.mask = maskLayer
}
//Add Shadow To View
func addShadow(views: [UIView], opacity: CGFloat, radius: CGFloat, color: UIColor)
{
    for view in views
    {
        view.layer.shadowOpacity = Float(opacity) //0.7
        view.layer.shadowOffset = CGSize(width: 3.0, height: 2.0)
        view.layer.shadowRadius = radius //5.0
        view.layer.shadowColor = color.cgColor
    }
}

//Set Borders
func setBorders(_ arrViews: [UIView], color : UIColor, radius : CGFloat, width : CGFloat)
{
    for view in arrViews
    {
        view.layer.borderWidth = width
        view.layer.borderColor = color.cgColor
        view.layer.masksToBounds = true
        view.layer.cornerRadius = radius
    }
}

func setCornerRadius(_ arrViews : [UIView], radius : CGFloat)
{
    for view in arrViews
    {
        view.layer.masksToBounds = true
        view.layer.cornerRadius = radius
    }
}

func setTextFieldsIndicator(_ txtFields : UITextField, image:UIImage, position: Int)
{
    //position = 0 = left side, position = 1 = right side
    let imgView = UIImageView(image: image)
    imgView.contentMode = UIView.ContentMode.scaleAspectFit
    if (position==1)
    {
        let v = UIView(frame: CGRect(x: 10, y: 0, width: txtFields.frame.size.height, height: txtFields.frame.size.height))
        imgView.frame = CGRect(x: v.bounds.size.height-24, y: 15, width: v.bounds.size.height-30, height: v.bounds.size.height-30)
        
        v.addSubview(imgView)
        txtFields.rightViewMode = UITextField.ViewMode.always;
        txtFields.rightView = v;
    }
    else
    {
        let v = UIView(frame: CGRect(x: 0, y: 0, width: txtFields.frame.size.height, height: txtFields.frame.size.height))
        imgView.frame = CGRect(x: 0, y: 18, width: v.bounds.size.height-30, height: v.bounds.size.height-30);
        
        v.addSubview(imgView)
        txtFields.leftViewMode = UITextField.ViewMode.always;
        txtFields.leftView = v;
    }
}

func setTextFieldModification(arrTextField:[UITextField],arrImages :[String],position:Int)
{
    for textField in arrTextField
    {
        setTextFieldsIndicator(textField , image: UIImage(named: arrImages[arrTextField.index(of: textField)!] )! , position: position);
        /*if showIndicatorImage {
         setTextFieldsIndicator(textField , image: UIImage(named: arrImages[arrTextField.index(of: textField)!] as! String)! , position: position);
         }*/
    }
}

//Right Indicator
func setTextFieldIndicator(_ txtField : UITextField, image : UIImage)
{
    let imageView = UIImageView(image: image)
    txtField.rightViewMode = UITextField.ViewMode.always
    imageView.frame = CGRect(x: 0.0, y: 0.0, width: 15.0, height: 15.0)
    imageView.contentMode = UIView.ContentMode.scaleAspectFit
    imageView.clipsToBounds = true
    txtField.rightView = imageView;
}

//Right Indicator ArrTextFields
func setArrTextFieldIndicator(_ arrTextFields: [UITextField], arrImages : [AnyObject])
{
    for txtField in arrTextFields
    {
        setTextFieldIndicator(txtField, image: UIImage(named: arrImages[arrTextFields.index(of: txtField)!] as! String)!)
    }
}

//User Interaction
func setUserInterAction(_ arrViews: [UIView], isOn : Bool)
{
    for view in arrViews
    {
        view.isUserInteractionEnabled = isOn
    }
}

//Label Color
func setLabelColor(_ arrLables: [UILabel], color : UIColor)
{
    for label in arrLables
    {
        label.textColor = color
    }
}

//Text Color
func setTextColor(_ arrtxtflds: [UITextField], color : UIColor)
{
    for txtfld in arrtxtflds
    {
        txtfld.textColor = color
    }
}

//Left Margin
func setLeftPadding(_ txtField: UITextField)
{
    let view = UIView()
    view.frame = CGRect(x: 0.0, y: 0.0, width: 10, height: 20)
    txtField.leftViewMode = UITextField.ViewMode.always
    txtField.leftView = view
}

//Add Gradient
func addGradientToView(x:CGFloat,y:CGFloat,width:CGFloat,height:CGFloat) -> CAGradientLayer {
    
    let mGradient = CAGradientLayer()
    mGradient.frame = (CGRect(x: x, y: y, width: width, height:height))
    var colors = [CGColor]()
    colors.append(UIColor(red: 0, green: 0, blue: 0, alpha: 0.5).cgColor)
    colors.append(UIColor(red: 0, green: 0, blue: 0, alpha: 0).cgColor)
    mGradient.startPoint = CGPoint(x: (UIScreen.main.bounds.size.width), y: 0.9)
    mGradient.endPoint = CGPoint(x: (UIScreen.main.bounds.size.width), y: 0.1)
    mGradient.colors = colors
    
    return mGradient
    
}

// MARK: - Set Borders
func addTextFieldsBottomBorder(_ arrTextFields: [UITextField], color: UIColor)
{
    for textfields in arrTextFields
    {
        let bottomLine = CALayer()
        bottomLine.frame = CGRect(x: 0.0, y: textfields.bounds.size.height - 1, width: textfields.bounds.size.width, height: 1.0)
        bottomLine.backgroundColor = color.cgColor
        textfields.borderStyle = UITextField.BorderStyle.none
        textfields.layer.addSublayer(bottomLine)
    }
}

//Add Border to View
func addTopBorderWithColor(_ objView : UIView, color: UIColor, width: CGFloat) {
    let border = CALayer()
    border.backgroundColor = color.cgColor
    border.frame = CGRect(x: 0, y: 0, width: objView.frame.size.width, height: width)
    objView.layer.addSublayer(border)
}

func addBottomBorderWithColor(_ objView : UIView, color: UIColor, width: CGFloat) {
    let border = CALayer()
    border.backgroundColor = color.cgColor
    border.frame = CGRect(x: 0, y: objView.frame.size.height - width, width: objView.frame.size.width, height: width)
    objView.layer.addSublayer(border)
}

func addLeftBorderWithColor(_ objView : UIView, color: UIColor, width: CGFloat) {
    let border = CALayer()
    border.backgroundColor = color.cgColor
    border.frame = CGRect(x: 0, y: 0, width: width, height: objView.frame.size.height)
    objView.layer.addSublayer(border)
}

func addRightBorderWithColor(_ objView : UIView, color: UIColor, width: CGFloat) {
    let border = CALayer()
    border.backgroundColor = color.cgColor
    border.frame = CGRect(x: objView.frame.size.width, y: 0, width: width, height: objView.frame.size.height)
    objView.layer.addSublayer(border)
}

// MARK: - Currency Formattion
func getCurrencyFormat(localeIdentifier: String, price: NSNumber) -> String
{
    let currencyFormatter = NumberFormatter()
    currencyFormatter.usesGroupingSeparator = true
    currencyFormatter.numberStyle = NumberFormatter.Style.currency
    // localize to your grouping and decimal separator
    let locale = NSLocale(localeIdentifier: localeIdentifier)
    locale.displayName(forKey:  NSLocale.Key.currencySymbol, value: localeIdentifier)
    currencyFormatter.locale = locale as Locale
    let priceString = currencyFormatter.string(from: price)
    return priceString!
    
}


// MARK: - Show Map Directions
func getMapDirection(mapView: MKMapView,lattitude: Double, longitude: Double)
{
    let url = "http://maps.apple.com/?saddr=\(mapView.userLocation.coordinate.latitude),\(mapView.userLocation.coordinate.longitude)&daddr=\(lattitude),\(longitude)"
    if #available(iOS 10.0, *) {
        UIApplication.shared.open((NSURL(string: url)! as URL), options: [:], completionHandler: nil)
    } else {
        // Fallback on earlier versions
    }
}



//Convert Json to Data
func jsonToData(json: Any) -> Data? {
    do {
        return try JSONSerialization.data(withJSONObject: json, options: JSONSerialization.WritingOptions.prettyPrinted)
    } catch let myJSONError {
        print(myJSONError)
    }
    return nil;
}

//Convert from NSData to JSON Object
func dataToJSON(data: Data) -> Any? {
    do {
        return try JSONSerialization.jsonObject(with: data, options: .allowFragments)
    } catch let myJSONError {
        print(myJSONError)
    }
    return nil
}

// MARK: - Get Document Directory Path
func getDocumentDirectoryPath() -> URL {
    return try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
}
// MARK: - Move File
func moveFile(path:String,destinationPath:String) -> (Bool,Error?) {
    let fileManager = FileManager.default
    do {
        try fileManager.moveItem(atPath: path, toPath: destinationPath)
        return (true,nil)
    }catch let err as Error {
        return (false,err)
    }
}

// MARK: - Remove File
func removeFile(path:String) {
    
    let fileManager = FileManager.default
    
    if fileManager.fileExists(atPath: path) {
        do {
            try fileManager.removeItem(atPath: path)
        }catch {
            
        }
    }
}

// MARK: - Image Fuctions
//Save image to Directory
func saveImageToDirectory(folderName: String, image: UIImage, imageName: String)
{
    var documentsDirectoryURL = try! FileManager().url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
    if folderName != ""
    {
        // Create a new path for the new images folder
        documentsDirectoryURL = documentsDirectoryURL.appendingPathComponent(folderName)
        //var objcBool:ObjCBool = true
        let isExist = FileManager.default.fileExists(atPath: documentsDirectoryURL.path)
        //fileExistsAtPath(imagesDirectoryPath, isDirectory: &objcBool)
        // If the folder with the given path doesn't exist already, create it
        if isExist == false {
            do {
                try FileManager.default.createDirectory(atPath: documentsDirectoryURL.path, withIntermediateDirectories: true, attributes: nil)
            }catch {
                print("Something went wrong while creating a new folder")
            }
        }
    }
    // create a name for your image
    let fileURL = documentsDirectoryURL.appendingPathComponent(imageName)
    if !FileManager.default.fileExists(atPath: fileURL.path) {
        do {
            // UIImagePNGRepresentation(self.imgview.image!)!
            try image.jpegData(compressionQuality: 1.0)?.write(to: fileURL)
            print("Image Added Successfully")
            
        } catch {
            print(error)
        }
    } else {
        print("Error! Image Not Added \nImage with same identifire is exist")
    }
}

//Get image to Directory
func getImageFromDirectory(folderName: String, imageName: String) -> UIImage?
{
    let nsDocumentDirectory = FileManager.SearchPathDirectory.documentDirectory
    let nsUserDomainMask    = FileManager.SearchPathDomainMask.userDomainMask
    let paths               = NSSearchPathForDirectoriesInDomains(nsDocumentDirectory, nsUserDomainMask, true)
    if let dirPath          = paths.first
    {
        var imageURL = URL(fileURLWithPath: "")
        imageURL = URL(fileURLWithPath: dirPath).appendingPathComponent(folderName)
        /*
         if folderName != "" {
         imageURL = URL(fileURLWithPath: dirPath).appendingPathComponent(folderName)
         }*/
        imageURL = URL(fileURLWithPath: imageURL.path).appendingPathComponent(imageName)
        //print(dirPath)
        let image    = UIImage(contentsOfFile: imageURL.path)
        if image != nil {
            // Do whatever you want with the image
            return image
        } else {
            print("Image Not Found")
            return nil
        }
    }
    
    return nil
}

//Make ImageView Rounded
func roundedImageView(imgView: UIImageView, borderWidth: Float, borderColor: UIColor)
{
    imgView.layer.cornerRadius = imgView.frame.size.width / 2
    imgView.clipsToBounds = true
    imgView.layer.borderWidth = CGFloat(borderWidth)
    imgView.layer.borderColor = borderColor.cgColor
}

//Set tint Color
func setTintColor(imgView : UIImageView, color : UIColor)
{
    imgView.image = imgView.image!.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
    imgView.tintColor = color
}

//Resize image
func resizeImage(_ image:UIImage) -> UIImage {
    let maxImageSize = CGFloat(500)
    let originalSize = image.size
    if  originalSize.height>maxImageSize || originalSize.width>maxImageSize
    {
        var newSize = originalSize
        var ratio = originalSize.width/originalSize.height
        if  originalSize.height>originalSize.width
        {
            ratio = originalSize.width/originalSize.height
            newSize = CGSize(width: ratio*maxImageSize, height: maxImageSize)
        } else
        {
            ratio = originalSize.height/originalSize.width;
            newSize = CGSize(width: maxImageSize,height: ratio*maxImageSize);
        }
        UIGraphicsBeginImageContext(newSize);
        image.draw(in: CGRect(x: 0,y: 0,width: newSize.width,height: newSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    else
    {
        return image
    }
}


// MARK: - UITableView and UICollectionView configurations
//Configure TableView
func configureTableView(forVC vc:UIViewController, estimatedHeigth : CGFloat, tableView: UITableView)
{
    tableView.dataSource = vc as? UITableViewDataSource
    tableView.delegate = vc as? UITableViewDelegate
    tableView.rowHeight = UITableView.automaticDimension
    tableView.estimatedRowHeight = estimatedHeigth
}

//Configure CollectionView
func configureCollectionView(forVC vc: UIViewController, collectionView:UICollectionView, classname:AnyClass, space:CGFloat)
{
    /*  let identifier = String(describing: classname)
     collectionView.register(classname, forCellWithReuseIdentifier: identifier)
     collectionView.register(UINib(nibName: identifier, bundle: nil), forCellWithReuseIdentifier: identifier)
     let layout:UICollectionViewFlowLayout = UICollectionViewFlowLayout()
     layout.sectionInset = UIEdgeInsets(top: space, left: space, bottom: space, right: space)
     layout.minimumInteritemSpacing = 0
     layout.minimumLineSpacing = space
     collectionView.collectionViewLayout = layout*/
    collectionView.dataSource = vc as? UICollectionViewDataSource
    collectionView.delegate = vc as? UICollectionViewDelegate
    collectionView.alwaysBounceVertical = true
    
    collectionView.register(classname, forCellWithReuseIdentifier: "\(classname)")
    
    //collectionView.register(cellWithClass: CollectionViewCell.self)
    collectionView.register(UINib(nibName: "\(classname)", bundle: nil), forCellWithReuseIdentifier: "\(classname)")
    //collectionView.register(nib: UINib(nibName: "\(CollectionViewCell.self)", bundle: nil), forCellWithClass: CollectionViewCell.self)
    
    let layout:UICollectionViewFlowLayout = UICollectionViewFlowLayout()
    layout.sectionInset = UIEdgeInsets(top: space, left: space, bottom: space, right: space)
    layout.minimumInteritemSpacing = space
    layout.minimumLineSpacing = space
    collectionView.collectionViewLayout = layout
}

// Add Loading Cell
func showLoadingCell(_ indicatorColor:UIColor) -> UITableViewCell
{
    let cell = UITableViewCell(style: .default, reuseIdentifier: "LoadingCell")
    cell.backgroundColor = UIColor.clear
    cell.selectionStyle = .none
    cell.isUserInteractionEnabled = false
    
    //cell.textLabel?.text = msg_LoadingMore
    //let lblLoading: UILabel     = UILabel(frame: CGRectMake(50, 0, cell.bounds.size.width-70.0, cell.bounds.size.height))
    let lblLoading: UILabel     = UILabel(frame: CGRect(x: cell.center.x, y: cell.center.y, width: cell.bounds.size.width-70.0, height: 20.0)) //UILabel(frame: CGRect(x: (cell.frame.size.width / 4.0) - 30.0, y: actIndicator.frame.origin.y, width: cell.bounds.size.width-70.0, height: 20.0)) //UILabel(frame: CGRect(x: 50, y: actIndicator.frame.origin.y, width: cell.bounds.size.width-70.0, height: 20.0))
    
    let actIndicator = UIActivityIndicatorView(style: .gray)
    actIndicator.color = indicatorColor
    //actIndicator.center = CGPoint(x: (UIScreen.mainScreen().bounds.size.width/2)-(actIndicator.bounds.size.width/2), y: cell.center.y)
    actIndicator.frame = CGRect(x: lblLoading.frame.minX - 30.0, y: 20.0, width: 20.0, height: 20.0) //CGRect(x: 20.0, y: 20.0, width: 20.0, height: 20.0)
    cell.contentView.addSubview(actIndicator)
    actIndicator.startAnimating()
    actIndicator.hidesWhenStopped = true
    
    lblLoading.text             = "Loading...".localized
    lblLoading.numberOfLines    = 0
    lblLoading.lineBreakMode    = NSLineBreakMode.byWordWrapping
    //    lblLoading.textColor        = ThemeManager.currentTheme().textColor
    lblLoading.textAlignment    = .left   //.Center
    cell.contentView.addSubview(lblLoading)
    
    return cell
}

// No More Data Cell, used in Log Management, Account Statement
func noMoreDataCell() -> UITableViewCell
{
    let cell                            = UITableViewCell(style: .default, reuseIdentifier: "noMoreDataCell")
    cell.backgroundColor                = .clear
    cell.selectionStyle                 = .none
    
    cell.isUserInteractionEnabled       = false
    let lblLoading: UILabel             = UILabel(frame: cell.frame)
    cell.contentView.addSubview(lblLoading)
    
    //    lblLoading.center = cell.center
    lblLoading.numberOfLines            = 0
    lblLoading.text                     = "Loading...".localized
    lblLoading.lineBreakMode            = NSLineBreakMode.byWordWrapping
    //    lblLoading.textColor                = ThemeManager.currentTheme().textColor
    lblLoading.textAlignment            = .center//.Center
    lblLoading.backgroundColor          = .red
    cell.backgroundColor                = .blue
    
    return cell
}


// MARK: - Calling Number
func callNumber(_ phoneNumber:String) {
    if let phoneCallURL:URL = URL(string:"tel://\(phoneNumber)") {
        let application:UIApplication = UIApplication.shared
        if (application.canOpenURL(phoneCallURL)) {
            if #available(iOS 10.0, *) {
                application.open(phoneCallURL, options: [:], completionHandler: nil)
            } else {
                // Fallback on earlier versions
            }
        }
    }
}

// MARK: - Play Audio
func playAudio(_ fileName: String)
{
    let resourcePath = Bundle.main.resourcePath!
    let filePath = "\(resourcePath)/" + "\(fileName)"
    print(filePath)
    let url: URL = URL(fileURLWithPath: filePath)
    let playerObject = AVPlayer(url: url)
    let playerController = AVPlayerViewController()
    playerController.player = playerObject
    playerObject.play()
}

// MARK: - Open Translate Url
func openTranslateUrl(withText: String)
{
    let txtAppend = withText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
    let url = "https://translate.google.com/#auto/en/\(txtAppend!)"
    let openUrl = NSURL(string: url)
    if #available(iOS 10.0, *) {
        UIApplication.shared.open(openUrl! as URL, options: [:], completionHandler: nil)
    } else {
        UIApplication.shared.openURL(openUrl! as URL)
    }
}

//// MARK: - Open Schema
//func openScheme(Url: String)
// {
//    if !(UIApplication.shared.canOpenURL(NSURL (string: Url)! as URL)) {
//        let alertController = UIAlertController(title: msg_TitleAppName, message: "TODO://", preferredStyle:  UIAlertController.Style.alert)
//        let OKAction = UIAlertAction(title: "OK", style:  UIAlertAction.Style.default, handler: {(action: UIAlertAction) -> Void in
//        })
//        alertController.addAction(OKAction)
//        alertController.show()
//    }else {
//        if #available(iOS 10.0, *) {
//            UIApplication.shared.open(NSURL(string: Url)! as URL, options: [:], completionHandler: nil)
//        } else {
//            // Fallback on earlier versions
//        }
//    }
//
//}

// MARK: - Json Functions
//Load Json from file
func loadJson(forFilename fileName: String) -> JSON? {
    
    if let url = Bundle.main.url(forResource: fileName, withExtension: "json") {
        if let data = NSData(contentsOf: url) {
            do {
                let json = try JSON(data: data as Data)
                return json
            } catch {
                print("Error!! Unable to parse  \(fileName).json")
            }
        }
        print("Error!! Unable to load  \(fileName).json")
    }
    
    return nil
}

//// MARK: - Get Current Age
//func getCurrentAge(birthday: String) -> Int {
//
//    //let arrData = birthday.components(separatedBy: ",")
//    if birthday != "" {
//        //let dateString = "\(String(format: "%02d/%04d",Int(arrData[0])!+1,arrYear[Int(arrData[1])!]))"
//
//        let dateFormater = DateFormatter()
//        dateFormater.dateFormat = dateFormatDefault
//        //dateFormater.dateFormat = dateFormatMonthYearfull
//        let birthdayDate = dateFormater.date(from: birthday)
//
//        if birthdayDate != nil {
//            let calendar = NSCalendar(calendarIdentifier: .gregorian)
//            let calcAge = calendar?.components(.year, from: birthdayDate!, to: Date(), options: [])
//            let age = calcAge?.year
//
//            if age! < 1 {
//                return 1
//            }
//            else {
//                return age!
//            }
//        }
//    }
//    else {
//        return 0
//    }
//
//    return 0
//}

// MARK: - Show Massage
func showMessage( title : String, viewController: UIViewController){
    let alert = UIAlertController(title: "",
                                  message: title,
                                  preferredStyle: .alert)
    
    let cancelAction = UIAlertAction(title: "OK",
                                     style: .default)
    
    //to change font of title and message.
    let messageFont = [NSAttributedString.Key.font: UIFont(name: "MuseoSans-500", size: 16.0)!,NSAttributedString.Key.foregroundColor:UIColor.black]
    let messageAttrString = NSMutableAttributedString(string: title ?? "", attributes: messageFont)
    alert.setValue(messageAttrString, forKey: "attributedMessage")
    
    alert.view.tintColor = .blue
    alert.addAction(cancelAction)
    viewController.present(alert, animated: true, completion: nil)
}

// MARK: - Generate Random String/Password
func randomAlphaNumericString(length: Int) -> String {
    let allowedChars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    let allowedCharsCount = UInt32(allowedChars.count)
    var randomString = ""
    
    for _ in 0..<length {
        let randomNum = Int(arc4random_uniform(allowedCharsCount))
        let randomIndex = allowedChars.index(allowedChars.startIndex, offsetBy: randomNum)
        let newCharacter = allowedChars[randomIndex]
        randomString += String(newCharacter)
    }
    return randomString
}

// MARK: - User Default
//Set Value
func setToUserDefaultForKey(_ value:AnyObject?,key:String){
    UserDefaults.standard.set(value, forKey: key)
    UserDefaults.standard.synchronize()
}

//Set Archive Value
func setToUserDefaultForKeyByArchive(_ value:AnyObject?,key:String){
    UserDefaults.standard.set(value == nil ? nil : NSKeyedArchiver.archivedData(withRootObject: value!), forKey: key)
    UserDefaults.standard.synchronize()
}

//Get Value
func getFromUserDefaultForKey(_ key:String)->AnyObject?{
    return UserDefaults.standard.object(forKey: key) as AnyObject?
}

//Get UnArchive Value
func getFromUserDefaultForKeyByUnArchive(_ key:String)->AnyObject?{
    return UserDefaults.standard.object(forKey: key) == nil ? nil :NSKeyedUnarchiver.unarchiveObject(with: UserDefaults.standard.object(forKey: key) as! Data) as AnyObject?
}

//Remove Value
func removeFromUserDefaultForKey(_ key:String){
    UserDefaults.standard.removeObject(forKey: key)
}

// MARK: - Date-Time Formattion

func getDisplayDate(date: String, dateFormat : String, displayFormat : String) -> String {
    let datetimeFormatOriginal = DateFormatter()
    let datetimeFormatDisplay = DateFormatter()
    if "\(Language.language)" == "en"{
        let loc = Locale(identifier: "us") //Locale.init(identifier: "us")
        datetimeFormatDisplay.locale = loc
        datetimeFormatOriginal.locale = loc
    }else{
        let loc = Locale(identifier: "es")
        datetimeFormatDisplay.locale = loc
        datetimeFormatOriginal.locale = loc
    }
    datetimeFormatOriginal.dateFormat = dateFormat
    datetimeFormatOriginal.timeZone = TimeZone(abbreviation: "UTC")
    
    
    
    
    datetimeFormatDisplay.dateFormat = displayFormat
    datetimeFormatDisplay.timeZone = TimeZone.current  //TimeZone(abbreviation: "GMT")  //TimeZone.current
    datetimeFormatDisplay.amSymbol = "AM"
    datetimeFormatDisplay.pmSymbol = "PM"
    
    if date == "" || date == "-" {
        return ""
    }
    else {
        
        guard let tempDate = datetimeFormatOriginal.date(from: date)else {
            return "-"
        }
        
        return datetimeFormatDisplay.string(from: tempDate)
        /* guard let tempDate = dateFormat.date(withFormat: date) else {
         return "-"
         }*/
        //print(tempDate)
        
        //return datetimeFormatDisplay.string(from: datetimeFormatOriginal.date(from: date)!)
    }
}
func getDateString(_ datetime: Date, format : String) -> String {
    //let currentdate: NSDate = NSDate()
    let dateFormat: DateFormatter = DateFormatter()
    if "\(Language.language)" == "en"{
        let loc = Locale(identifier: "us") //Locale.init(identifier: "us")
        dateFormat.locale = loc
        dateFormat.locale = loc
    }else{
        let loc = Locale(identifier: "es")
        dateFormat.locale = loc
        dateFormat.locale = loc
    }
    dateFormat.dateFormat = format
    // format
    
    return dateFormat.string(from: datetime)
}

func getDefaultDate(_ datetime: String, format : String) -> Date {
    let dateFormat: DateFormatter = DateFormatter()
    dateFormat.dateFormat = format
    
    return dateFormat.date(from: datetime)!
}

func getDateFromTimeStamp(_ unixtimeInterval: Double, format : String) -> String {
    let date = Date(timeIntervalSince1970: unixtimeInterval)
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = format //Specify your format that you want
    dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
    let strDate = dateFormatter.string(from: date)
    return strDate
}
//UTC to Local timezone
func UTCToLocal(date:String,formate:String,displayFormate:String) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = formate
    dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
    
    let dt = dateFormatter.date(from: date)
    dateFormatter.timeZone = TimeZone.current
    dateFormatter.dateFormat = displayFormate//"h:mm a"
    
    return dateFormatter.string(from: dt!)
}

//Local to UTC timezone
func localToUTC(date:String,Localeformate:String,UTCFormate:String) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = UTCFormate //"h:mm a"
    dateFormatter.calendar = NSCalendar.current
    dateFormatter.timeZone = TimeZone.current
    
    let dt = dateFormatter.date(from: date)
    dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
    dateFormatter.dateFormat = Localeformate//"H:mm:ss"
    
    return dateFormatter.string(from: dt!)
}

func getUTCTimestampFromCurrentTime(dateToConvert: Date) -> String {
    let objDateformat: DateFormatter = DateFormatter()
    objDateformat.dateFormat = "yyyy-MM-dd HH:mm:ss Z"    //"yyyy-MM-dd"
    objDateformat.timeZone = TimeZone(abbreviation: "UTC")
    let strTime: String = objDateformat.string(from: dateToConvert as Date)
    let objUTCDate: NSDate = objDateformat.date(from: strTime)! as NSDate
    let milliseconds: Int64 = Int64(objUTCDate.timeIntervalSince1970)
    let strTimeStamp: String = "\(milliseconds)"
    return strTimeStamp
}


func dayDifferenceForMessage(from interval : TimeInterval) -> String
{
    let calendar = Calendar.current
    let date = Date(timeIntervalSince1970: interval)
    let previousSevenDaysDate = calendar.date(byAdding: .day, value: -7, to: Date()) ?? Date()
    if calendar.isDateInToday(date) {
        return getDateString(date, format: dateTimeFromatOnlyDisplayTime)
    } else if date.isBetween(previousSevenDaysDate, and: Date()){ //calendar.isDateInWeekend(date){
        return getDateString(date, format: dateTimeFromatOnlyDisplayDayShortName)
    } else {
        return getDateString(date, format: dateFormateDashShortDate)
    }
}


//MARK: Date Difference
func timeGapBetweenDates(previousDate : String,currentDate : String)
{
    let dateString1 = previousDate
    let dateString2 = currentDate
    
    let Dateformatter = DateFormatter()
    Dateformatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"    //"yyyy-MM-dd HH:mm:ss"
    
    let date1 = Dateformatter.date(from: dateString1)
    let date2 = Dateformatter.date(from: dateString2)
    
    let distanceBetweenDates: TimeInterval? = date2?.timeIntervalSince(date1!)
    let secondsInAnHour: Double = 3600
    let minsInAnHour: Double = 60
    let secondsInDays: Double = 86400
    let secondsInWeek: Double = 604800
    let secondsInMonths : Double = 2592000
    let secondsInYears : Double = 31104000
    
    let minBetweenDates = Int((distanceBetweenDates! / minsInAnHour))
    let hoursBetweenDates = Int((distanceBetweenDates! / secondsInAnHour))
    let daysBetweenDates = Int((distanceBetweenDates! / secondsInDays))
    let weekBetweenDates = Int((distanceBetweenDates! / secondsInWeek))
    let monthsbetweenDates = Int((distanceBetweenDates! / secondsInMonths))
    let yearbetweenDates = Int((distanceBetweenDates! / secondsInYears))
    let secbetweenDates = Int(distanceBetweenDates!)
    
    if yearbetweenDates > 0 {
        print(yearbetweenDates,"years")//0 years
    }
    else if monthsbetweenDates > 0 {
        print(monthsbetweenDates,"months")//0 months
    }
    else if weekBetweenDates > 0 {
        print(weekBetweenDates,"weeks")//0 weeks
    }
    else if daysBetweenDates > 0 {
        print(daysBetweenDates,"days")//5 days
    }
    else if hoursBetweenDates > 0 {
        print(hoursBetweenDates,"hours")//120 hours
    }
    else if minBetweenDates > 0 {
        print(minBetweenDates,"minutes")//7200 minutes
    }
    else if secbetweenDates > 0 {
        print(secbetweenDates,"seconds")//seconds
    }
}
func isPastDate(previousDate : String,currentDate : String) -> Bool
{
    let dateString1 = previousDate
    let dateString2 = currentDate
    
    let Dateformatter = DateFormatter()
    Dateformatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"    //"yyyy-MM-dd HH:mm:ss"
    
    let date1 = Dateformatter.date(from: dateString1)
    let date2 = Dateformatter.date(from: dateString2)
    
    if date1 == nil || date2 == nil {
        return true
    }
    
    let distanceBetweenDates: TimeInterval? = date2?.timeIntervalSince(date1!)
    //let secondsInAnHour: Double = 3600
    //let minsInAnHour: Double = 60
    let secondsInDays: Double = 86400
    //let secondsInWeek: Double = 604800
    //let secondsInMonths : Double = 2592000
    //let secondsInYears : Double = 31104000
    
    //let minBetweenDates = Int((distanceBetweenDates! / minsInAnHour))
    //let hoursBetweenDates = Int((distanceBetweenDates! / secondsInAnHour))
    let daysBetweenDates = Int((distanceBetweenDates! / secondsInDays))
    //let weekBetweenDates = Int((distanceBetweenDates! / secondsInWeek))
    //let monthsbetweenDates = Int((distanceBetweenDates! / secondsInMonths))
    //let yearbetweenDates = Int((distanceBetweenDates! / secondsInYears))
    //let secbetweenDates = Int(distanceBetweenDates!)
    
    if daysBetweenDates > 0 {
        return true
    }
    return false
}

// MARK: - App Functions
//MARK: Rate The Application
func rateTheApp(_ appId: String) {
    //http://itunes.apple.com/app/id284815942
    if let url = URL(string: "itms-apps://itunes.apple.com/app/id"+appId),
       UIApplication.shared.canOpenURL(url)
    {
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
}
//MARK: Open The Application
func openTheApp(_ appId: String) {
    //let urlStr = "itms://itunes.apple.com/app/apple-store/id375380948?mt=8"
    let urlStr = "itms://itunes.apple.com/app/apple-store/id"+appId+"?mt=8"
    if #available(iOS 10.0, *) {
        UIApplication.shared.open(URL(string: urlStr)!, options: [:], completionHandler: nil)
    } else {
        UIApplication.shared.openURL(URL(string: urlStr)!)
    }
}

// MARK: - Open URL
func openURL(_ strURL: String) {
    let urlStr = strURL
    if #available(iOS 10.0, *) {
        UIApplication.shared.open(URL(string: urlStr)!, options: [:], completionHandler: nil)
    } else {
        UIApplication.shared.openURL(URL(string: urlStr)!)
    }
}

//func getTimeDifferenceFromNow(dateString: String, dateFormat: String, displayFormat: String) -> String {
//
//    let datetimeFormatOriginal = DateFormatter()
//    datetimeFormatOriginal.dateFormat = dateFormat
//
//    let datetimeFormatDisplay = DateFormatter()
//    datetimeFormatDisplay.dateFormat = displayFormat
//
//    //Get Time Difference between current time and TimeStamp
//    let date1:Date = Date() //  timeNow
//    let date2: Date = getDefaultDate(dateString, format: dateTimeFormatDefault)
//
//    let calender:Calendar = Calendar.current
//    let components: DateComponents = calender.dateComponents([.year,.month,.day,.hour, .minute], from: date2, to: date1)
//
//    var returnString:String = ""
//    if components.year! != 0
// {
//        //returnString =  "\(String(format: "%d", components.year!)) \("YEARS_AGO".localise())"
//        returnString = "YEARS_AGO".localiseWithFormat(arg: components.year!)
//    }
//    else if components.month! != 0 {
//        //returnString =  "\(String(format: "%d", components.month!)) \("MONTHS_AGO".localise())"
//        returnString = "MONTHS_AGO".localiseWithFormat(arg: components.month!)
//    }
//    else if components.day! >= 7
// {
//        let diff = Int(components.day!/7)
//        if components.day! > 14 {
//            //returnString =  "\(diff) \("WEEKS_AGO".localise())"
//            returnString = "WEEKS_AGO".localiseWithFormat(arg: diff)
//        } else {
//            //returnString =  "\(diff) \("WEEK_AGO".localise())"
//            returnString = "WEEK_AGO".localiseWithFormat(arg: diff)
//        }
//    }
//    else if components.day! != 0 {
//        //returnString =  "\(String(format: "%d", components.day!)) \("DAYS_AGO".localise())" //return datetimeFormatDisplay.string(from: datetimeFormatOriginal.date(from: dateString)!)
//        returnString = "DAYS_AGO".localiseWithFormat(arg: components.day!)
//    }
//    else if components.hour! != 0 {
//        //returnString =  "\(String(format: "%d", components.hour!)) \("HOURS_AGO".localise())"
//        returnString = "HOURS_AGO".localiseWithFormat(arg: components.hour!)
//    }
//    else if components.minute! != 0 {
//        //returnString =  "\(String(format: "%d", components.minute!)) \("MINUTES_AGO".localise())"
//        returnString = "MINUTES_AGO".localiseWithFormat(arg: components.minute!)
//    }
//    else if components.minute! == 0 {
//        returnString =  "JUST_NOW".localise()
//    }
//    else {
//        return datetimeFormatDisplay.string(from: datetimeFormatOriginal.date(from: dateString)!)
//    }
//    return returnString
//}
//
func convertDateToCustomFormat(datetime: String, format : String) -> String
{
    let date = getDefaultDate(datetime,format: format) //dateTimeFormatDefault
    let timeDifference = Date().timeIntervalSince(date)
    
    let minutes = timeDifference / 60
    let hours = minutes / 60
    let days = minutes / 1440
    
    /*if (days >= 360) {
     if (Int(days/360) == 1) {
     return "\(Int(days/360)) year ago"
     } else {
     return "\(Int(days/360)) years ago"
     }
     }
     if (days >= 30) {
     if (Int(days/30) == 1) {
     return "\(Int(days/30)) month ago"
     } else {
     return "\(Int(days/30)) months ago"
     }
     }*/
    if (days > 7) {
        
        return getDateString(date, format: "dd MMM yyyy")
    }
    if(days >= 1 && days <= 7) {
        if (Int(days) == 1) {
            return "\(Int(days)) day ago"
        } else {
            return "\(Int(days)) days ago"
        }
    }
    else if(hours>=1) {
        if (Int(hours) == 1) {
            return "\(Int(hours)) hour ago"
        } else {
            return "\(Int(hours)) hours ago"
        }
    }
    else if(minutes >= 1) {
        if (Int(minutes) == 1) {
            return "\(Int(minutes)) minute ago"
        } else {
            return "\(Int(minutes)) minutes ago"
        }
    }
    else {
        return "just now"
    }
    /*let calendar = Calendar.current
     if calendar.isDateInYesterday(date) { return "Yesterday" }
     else if calendar.isDateInToday(date)
     {
     let hour = Calendar.current.dateComponents([.hour], from: date, to: Date()).hour ?? 0
     return "\(abs(hour)) hr ago"
     }
     
     else {
     return getDateString(date, format: format)
     }*/
    return ""
}
// MARK: - Modify Text Style in WebView
func modifyTextStyleInLoadURL(into webView: UIWebView, fontFamily: String, fontStyle:String, fontSize: String ,colorHexCode: String ) {
    let cssString = "body {font-family: \(fontFamily); font-style: \(fontStyle); font-size: \(fontSize); color: #\(colorHexCode) }"
    let jsString = "var style = document.createElement('style'); style.innerHTML = '\(cssString)'; document.head.appendChild(style);"
    webView.stringByEvaluatingJavaScript(from: jsString)
}

//// MARK: - Get Network Time
//func getNetworkTime() -> String {
//    let formate = DateFormatter()
//    formate.dateFormat = dateFormatDateMonthYearFull
//    return formate.string(from: NetworkClock.shared().networkTime)
//}

// MARK: - Get File size
func getFileSize(filePath:String) -> Float64 {
    do {
        let attributes = try FileManager.default.attributesOfItem(atPath: filePath)
        let fileSize = attributes[FileAttributeKey.size] as! Float64
        return fileSize / 1000000
    }catch {
        return 0.0
    }
}

// MARK: - Get Video file duration
func getDuration(fileUrl:URL) -> Float64 {
    let asset = AVAsset(url: fileUrl)
    let duration = asset.duration
    return CMTimeGetSeconds(duration)
}
//Default App-Rating
/*if #available(iOS 10.3, *) {
 SKStoreReviewController.requestReview()
 } else {
 // Fallback on earlier versions
 }*/

// MARK: - Verify URL
func verifyUrl (urlString: String?) -> Bool {
    if let urlString = urlString {
        if let url = NSURL(string: urlString) {
            return UIApplication.shared.canOpenURL(url as URL)
        }
    }
    return false
}
// MARK: - Check for Valid Email
func isValidEmail(strEmail:String) -> Bool {
    //let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z] {2,64}"
    let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
    let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
    return emailTest.evaluate(with: strEmail)
}
// MARK: - Check for Valid Name
//check for at least one alphabetic character
func isValidName(strName:String) -> Bool {
    //Only Capital letters ==  .*[A-Z]+.*
    //Support Special character ====== .*[!&^%$#@()/]+.*
    let NameRegEx = "(?s)[^A-Za-z]*[A-Za-z].*"
    let NameTest = NSPredicate(format:"SELF MATCHES %@", NameRegEx)
    return NameTest.evaluate(with: strName)
}
func isValidPassword(strPassword:String) -> Bool
{
    "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[$@$!%*?&#])[A-Za-z\\d$@$!%*?&#] {8,25}"
    let passRegEx = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[$.@$!%*?&#])[A-Za-z\\d$.@$!%*?&#] {8,25}"//  "^(?=.*\\d)(?=.*[a-z])(?=.*[A-Z])[\\w<=>~@#$%^&*+=`| {}:;!.?\"()\\[\\]-] {8,}$"   //"^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)[a-zA-Z\\d] {8,}$"
    let passwordTest = NSPredicate(format:"SELF MATCHES %@", passRegEx)
    return passwordTest.evaluate(with: strPassword)
}
// MARK: - Check for Valid Mobile Number
func isValidMobileNumber(strMobileNumber:String) -> Bool {
    //Only Capital letters ==  .*[A-Z]+.*
    //Support Special character ====== .*[!&^%$#@()/]+.*
    let MobileNumberRegEx = "^[0-9]{8,14}$"  //"^[0-9]*$"
    let MobileNumberTest = NSPredicate(format:"SELF MATCHES %@", MobileNumberRegEx)
    return MobileNumberTest.evaluate(with: strMobileNumber)
}
// MARK: - DATE SUFFIX
func daySuffix(from date: Date) -> [String] {
    let calendar = Calendar.current
    let dayOfMonth = calendar.component(.day, from: date)
    switch dayOfMonth {
    case 1, 21, 31: return ["\(dayOfMonth)" ,"st"]
    case 2, 22: return ["\(dayOfMonth)", "nd"]
    case 3, 23: return ["\(dayOfMonth)","rd"]
    default: return ["\(dayOfMonth)","th"]
    }
}

func checkDeviceTypeIsIpad() -> Bool {
    if UIDevice.current.userInterfaceIdiom == .pad {
        print("iPad")
        return true
    }else {
        print("not iPad")
        return false
    }
}

// MARK: - Switch Color Function
func SwitchColor(SwitchObject: [UISwitch], offColor: UIColor, onColor: UIColor) {
    
    for counter in SwitchObject{
        counter.onTintColor = onColor
        
        counter.tintColor = offColor
        counter.layer.cornerRadius = counter.frame.height / 2.0
        counter.backgroundColor = offColor
        counter.clipsToBounds = true
    }
    
}
var hasTopNotch: Bool {
    if #available(iOS 11.0, tvOS 11.0, *) {
        return UIApplication.shared.delegate?.window??.safeAreaInsets.top ?? 0 > 20
    }
    return false
}


extension UINavigationController {
    func pushViewController(viewController: UIViewController, animated: Bool, completion: @escaping () -> Void) {
        pushViewController(viewController, animated: animated)
        
        if animated, let coordinator = transitionCoordinator {
            coordinator.animate(alongsideTransition: nil) { _ in
                completion()
            }
        } else {
            completion()
        }
    }
    
    func popViewController(animated: Bool, completion: @escaping () -> Void) {
        popViewController(animated: animated)
        
        if animated, let coordinator = transitionCoordinator {
            coordinator.animate(alongsideTransition: nil) { _ in
                completion()
            }
        } else {
            completion()
        }
    }
}

//MARK:- No data available view
struct noDataAvaiableDetail {
    var title = String()
    var image = String()
    var description = String()
    
    init(msg:String,img:String?) {
        self.title = msg
        self.image = img ?? ""
        
    }
    init(msg:String,img:String?,desc:String) {
        self.title = msg
        self.image = img ?? ""
        self.description = desc
    }
}

//Check Records Available
func checkRecordAvailable(for view: UIView, count: Int,  ctrlRefresh: UIRefreshControl?, targetController: UIViewController, detail: noDataAvaiableDetail = noDataAvaiableDetail(msg: "No data available".localized, img: nil),shouldShowCenter:Bool = true)
{
    //    if ctrlRefresh != nil {
    //        let updateString = "\(LanguageManager.shared.getTranslationForKey("Last_Updated_at")) \(Date().dateTimeString(ofStyle: .medium))"
    //        ctrlRefresh!.attributedTitle = NSAttributedString(string: updateString)
    //        ctrlRefresh!.endRefreshing()
    //    }
    
    if count > 0 {
        if view.isKind(of: UITableView.self) {
            (view as! UITableView).reloadData()
            (view as! UITableView).backgroundView = nil
        }
        else if view.isKind(of: UICollectionView.self) {
            (view as! UICollectionView).reloadData()
            (view as! UICollectionView).backgroundView = nil
        }
        else {
            view.viewWithTag(-111)?.removeFromSuperview()
        }
    }
    else {
        
        let v : NoDataVC = Bundle.main.loadNibNamed("NoData", owner: targetController, options: nil)![0] as! NoDataVC
        v.tag = -111
        v.backgroundColor = UIColor.clear
        if detail.description == "" {
            v.lblTitle.textColor = UIColor.white
        }
        v.msg = detail.title
        v.desc = detail.description
        
        if !shouldShowCenter {
            v.conCenterPoint.constant = -150
        }
        
        if view.isKind(of: UITableView.self) {
            (view as! UITableView).reloadData()
            (view as! UITableView).backgroundView = v
            (view as! UITableView).separatorStyle = .none
        }
        else if view.isKind(of: UICollectionView.self) {
            (view as! UICollectionView).reloadData()
            (view as! UICollectionView).backgroundView = v
        }
        else {
            view.addSubview(v)
        }
    }
}

//OpenSnak bar
func openSnakBar(viewController:UIViewController,message:String){
    let storyBoard = UIStoryboard(name: "Common", bundle: nil)
    let nextVC = storyBoard.instantiateViewController(withIdentifier: "SnackBarVC") as! SnackBarVC
    nextVC.snackBarMsg = "\(message)"
    nextVC.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
    viewController.present(nextVC, animated: true, completion: nil)
}

//Check Device has a notch or not
func hasNotch() -> Bool {
    if #available(iOS 11.0, *) {
        let window = UIApplication.shared.windows[0]
        let safeAreaInsets = window.safeAreaInsets
        let topInset = safeAreaInsets.top
        
        return topInset > 20 // Check if the top inset is greater than 20 (indicating the presence of a notch)
    }
    
    return false // Assume no notch for older iOS versions
}

extension String {
    var htmlToAttributedString: NSAttributedString? {
        guard let data = data(using: .utf8) else { return nil }
        do {
            return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding:String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            return nil
        }
    }
    var htmlToString: String {
        return htmlToAttributedString?.string ?? ""
    }
}


//Extension for ViewController
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboardWhenClickOutside))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboardWhenClickOutside() {
        view.endEditing(true)
    }
    func checkIsDeviceIsASmallResolution() -> Bool {
        let modelName = UIDevice.modelName
            switch modelName {
            case "iPhone 5", "iPhone 5c", "iPhone 5s", "iPhone 8", "iPhone 7", "iPhone 6", "iPhone 6s", "iPhone SE","iPhone SE (2nd generation)", "iPhone SE (3rd generation)":
                return true
            default:
                return false
            }
        }
}
extension UITextView {
    // Calculate the vertical inset needed to center the text
    func centerVertically() {
        
        let verticalInset = (self.bounds.height - self.contentSize.height) / 2
        self.contentInset = UIEdgeInsets(top: verticalInset, left: 0, bottom: verticalInset, right: 0)
        /*
         let fittingSize = CGSize(width: bounds.width, height: CGFloat.greatestFiniteMagnitude)
         let size = sizeThatFits(fittingSize)
         let topOffset = (bounds.size.height - size.height * zoomScale) / 2
         let positiveTopOffset = max(1, topOffset)
         contentOffset.y = -positiveTopOffset*/
    }
}

extension Date {
    func isBetween(_ date1: Date, and date2: Date) -> Bool {
        return (min(date1, date2) ... max(date1, date2)).contains(self)
    }
}

//Get Current device type
public extension UIDevice {

    static let modelName: String = {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }

        func mapToDevice(identifier: String) -> String { // swiftlint:disable:this cyclomatic_complexity
            #if os(iOS)
            switch identifier {
            case "iPod5,1":                                       return "iPod touch (5th generation)"
            case "iPod7,1":                                       return "iPod touch (6th generation)"
            case "iPod9,1":                                       return "iPod touch (7th generation)"
            case "iPhone3,1", "iPhone3,2", "iPhone3,3":           return "iPhone 4"
            case "iPhone4,1":                                     return "iPhone 4s"
            case "iPhone5,1", "iPhone5,2":                        return "iPhone 5"
            case "iPhone5,3", "iPhone5,4":                        return "iPhone 5c"
            case "iPhone6,1", "iPhone6,2":                        return "iPhone 5s"
            case "iPhone7,2":                                     return "iPhone 6"
            case "iPhone7,1":                                     return "iPhone 6 Plus"
            case "iPhone8,1":                                     return "iPhone 6s"
            case "iPhone8,2":                                     return "iPhone 6s Plus"
            case "iPhone9,1", "iPhone9,3":                        return "iPhone 7"
            case "iPhone9,2", "iPhone9,4":                        return "iPhone 7 Plus"
            case "iPhone10,1", "iPhone10,4":                      return "iPhone 8"
            case "iPhone10,2", "iPhone10,5":                      return "iPhone 8 Plus"
            case "iPhone10,3", "iPhone10,6":                      return "iPhone X"
            case "iPhone11,2":                                    return "iPhone XS"
            case "iPhone11,4", "iPhone11,6":                      return "iPhone XS Max"
            case "iPhone11,8":                                    return "iPhone XR"
            case "iPhone12,1":                                    return "iPhone 11"
            case "iPhone12,3":                                    return "iPhone 11 Pro"
            case "iPhone12,5":                                    return "iPhone 11 Pro Max"
            case "iPhone13,1":                                    return "iPhone 12 mini"
            case "iPhone13,2":                                    return "iPhone 12"
            case "iPhone13,3":                                    return "iPhone 12 Pro"
            case "iPhone13,4":                                    return "iPhone 12 Pro Max"
            case "iPhone14,4":                                    return "iPhone 13 mini"
            case "iPhone14,5":                                    return "iPhone 13"
            case "iPhone14,2":                                    return "iPhone 13 Pro"
            case "iPhone14,3":                                    return "iPhone 13 Pro Max"
            case "iPhone14,7":                                    return "iPhone 14"
            case "iPhone14,8":                                    return "iPhone 14 Plus"
            case "iPhone15,2":                                    return "iPhone 14 Pro"
            case "iPhone15,3":                                    return "iPhone 14 Pro Max"
            case "iPhone8,4":                                     return "iPhone SE"
            case "iPhone12,8":                                    return "iPhone SE (2nd generation)"
            case "iPhone14,6":                                    return "iPhone SE (3rd generation)"
            case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":      return "iPad 2"
            case "iPad3,1", "iPad3,2", "iPad3,3":                 return "iPad (3rd generation)"
            case "iPad3,4", "iPad3,5", "iPad3,6":                 return "iPad (4th generation)"
            case "iPad6,11", "iPad6,12":                          return "iPad (5th generation)"
            case "iPad7,5", "iPad7,6":                            return "iPad (6th generation)"
            case "iPad7,11", "iPad7,12":                          return "iPad (7th generation)"
            case "iPad11,6", "iPad11,7":                          return "iPad (8th generation)"
            case "iPad12,1", "iPad12,2":                          return "iPad (9th generation)"
            case "iPad13,18", "iPad13,19":                        return "iPad (10th generation)"
            case "iPad4,1", "iPad4,2", "iPad4,3":                 return "iPad Air"
            case "iPad5,3", "iPad5,4":                            return "iPad Air 2"
            case "iPad11,3", "iPad11,4":                          return "iPad Air (3rd generation)"
            case "iPad13,1", "iPad13,2":                          return "iPad Air (4th generation)"
            case "iPad13,16", "iPad13,17":                        return "iPad Air (5th generation)"
            case "iPad2,5", "iPad2,6", "iPad2,7":                 return "iPad mini"
            case "iPad4,4", "iPad4,5", "iPad4,6":                 return "iPad mini 2"
            case "iPad4,7", "iPad4,8", "iPad4,9":                 return "iPad mini 3"
            case "iPad5,1", "iPad5,2":                            return "iPad mini 4"
            case "iPad11,1", "iPad11,2":                          return "iPad mini (5th generation)"
            case "iPad14,1", "iPad14,2":                          return "iPad mini (6th generation)"
            case "iPad6,3", "iPad6,4":                            return "iPad Pro (9.7-inch)"
            case "iPad7,3", "iPad7,4":                            return "iPad Pro (10.5-inch)"
            case "iPad8,1", "iPad8,2", "iPad8,3", "iPad8,4":      return "iPad Pro (11-inch) (1st generation)"
            case "iPad8,9", "iPad8,10":                           return "iPad Pro (11-inch) (2nd generation)"
            case "iPad13,4", "iPad13,5", "iPad13,6", "iPad13,7":  return "iPad Pro (11-inch) (3rd generation)"
            case "iPad14,3", "iPad14,4":                          return "iPad Pro (11-inch) (4th generation)"
            case "iPad6,7", "iPad6,8":                            return "iPad Pro (12.9-inch) (1st generation)"
            case "iPad7,1", "iPad7,2":                            return "iPad Pro (12.9-inch) (2nd generation)"
            case "iPad8,5", "iPad8,6", "iPad8,7", "iPad8,8":      return "iPad Pro (12.9-inch) (3rd generation)"
            case "iPad8,11", "iPad8,12":                          return "iPad Pro (12.9-inch) (4th generation)"
            case "iPad13,8", "iPad13,9", "iPad13,10", "iPad13,11":return "iPad Pro (12.9-inch) (5th generation)"
            case "iPad14,5", "iPad14,6":                          return "iPad Pro (12.9-inch) (6th generation)"
            case "AppleTV5,3":                                    return "Apple TV"
            case "AppleTV6,2":                                    return "Apple TV 4K"
            case "AudioAccessory1,1":                             return "HomePod"
            case "AudioAccessory5,1":                             return "HomePod mini"
            case "i386", "x86_64", "arm64":                       return "Simulator \(mapToDevice(identifier: ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "iOS"))"
            default:                                              return identifier
            }
            #elseif os(tvOS)
            switch identifier {
            case "AppleTV5,3": return "Apple TV 4"
            case "AppleTV6,2": return "Apple TV 4K"
            case "i386", "x86_64": return "Simulator \(mapToDevice(identifier: ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "tvOS"))"
            default: return identifier
            }
            #endif
        }

        return mapToDevice(identifier: identifier)
    }()
}
