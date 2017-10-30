//
//  AllModels.swift
//  PostCard
//
//  Created by Mac on 21/04/17.
//  Copyright © 2017 Linkites. All rights reserved.
//


import Foundation
import Alamofire
import AlamofireImage
import SVProgressHUD
import Stripe

class User: NSObject  {
    var id:String = ""
    var mobile:String = ""
    var mobileforDisplay:String = ""
    var mobileDisplayInstagram:String = ""
    var smsVerificationCode:String = ""
    var deviceToken:String = ""
    var environment = ""
    var authToken:String = ""
    var fname:String = ""
    var lname:String = ""
    var email:String = ""
    var photoUrl:String = ""
    var info:NSMutableDictionary = NSMutableDictionary()
    var isLogin:Bool = false
    var isBlock:Bool = false
    static let currentUser:User = User()
    var selectedItems = [[String : Any]]()
    
    var cartTotalQty = 0
    
    var isPhotoPostFromVenue:Bool = false
    var defaultCard : Card!
    var isSelectApplePay:Bool = false
    
    
    var APNSorderID:String = ""
   // var isOrderDone:Bool =
    
    var totalPrice = 0.0
    
    var isOpenFullDetail:Bool = false
    
    //var selectedQty = 1
    
    var venueName = ""
    var currentLatitude: Double = Config.centrolParkLat
    var currentLongitude: Double = Config.centrolParkLng
    
    var isLoadedLoaction:Bool = false
    var accountSetting: AccountSetting = AccountSetting()
    var settingArr = [AccountSetting]()
    
    //var bookmarkedLocations = [Places]()
    var mArraySaveLocations = [Places]()
    var userPhotos = [[String: Any]]()
    
    var isHours:Bool = false
    var isEditorNotes:Bool = false
    var arrayTimings = [[String : Any]]()
    var editorNotes = ""
    var strTimings = ""
    var selectedPageIndex: Int = 0
    
  
    var placesAPNS = [Places]()
    var placeDetailAPNS : Places!
    
    var notificationListingID = ""
    var isFromNotificationListing:Bool = false
    var isFromNotificationVenue:Bool = false
    
    var deepLinkID = ""
    var isDeepLink_Venue:Bool = false
    var isDeepLink_List:Bool = false
  
    //Application settings json values
    var appName = ""
    var merchantId = ""
    var vendorGroupId = ""
    var appColor = "#066b72"
    var splashScreen  = ""
    var appLogo = ""
    var bundleId = ""
    var stripeTestKey = ""
    var stripePublishKey = ""
    var applyMerchantIdDev = ""
    var applyMerchantIdPro = ""

    var vendorGroupName = ""
    var mixPanelKey = ""
  
    var selectedVenueId = ""
    var selectedVenue:Venue!
    var salesTax:NSNumber!
  
    func deletePhotosWithPhotoid(photoid: String , completion:@escaping (_ success: Bool) -> Void) {
        let url = Config.serverUrl+"photos/\(photoid)"
        let parame = ["status": 3]
        Service().put(url: url, parameters: parame){ (result) in
            print(result as! NSDictionary)
            if result.isKind(of:NSDictionary.self) {
                completion(true)
            }else {
                completion(false)
            }
        }
    }
    
    func initWithInfo(isAPICall:Bool) {
        let preferences = UserDefaults.standard
        isLogin = preferences.bool(forKey: "isLogin")
        if isLogin {
            self.authToken = preferences.value(forKey: "authToken") as! String
//            print("authToken ==  \(authToken)")
            if (preferences.value(forKey: "info") != nil) {
                info = NSMutableDictionary(dictionary: preferences.dictionary(forKey: "info")!)
//                print("user****\(info)")
                self.id = self.info.value(forKey: "_id") as! String
                self.fname = self.info.value(forKey: "firstName") as! String
                self.lname = self.info.value(forKey: "lastName") as! String
                self.email = self.info.value(forKey: "email") as! String
                self.mobile = self.info.value(forKey: "mobile") as! String
                if let phone = self.info.value(forKey: "phone") {
                    self.mobileDisplayInstagram = phone as! String
                }
            }
            if isAPICall {
                getInfo()
            }
        }
      
    }
    
    func getAccountSettings() {
        let url = Config.serverUrl+"settings"
        Service.service.get(url: url) { (result) in     //Service().get(url: url) { (result) in
            if result .isKind(of: NSDictionary.self) {
//                print(result as! NSDictionary)
                self.accountSetting = AccountSetting(info: result as! NSDictionary)
            }
        }
    }
    
    func SignInWithPhoneNumber(phoneNumber:String, completion:@escaping (_ success: Bool) -> Void) {
        self.mobile = phoneNumber
        let parmeters:Parameters = ["mobile":phoneNumber]
        let url = Config.serverUrl+"session/mobile"
        Service().post(url: url, parameters: parmeters) { (result) in
            if result.isKind(of:NSDictionary.self) {
                let dataInfo = NSMutableDictionary(dictionary: result as! NSDictionary)
                if((dataInfo.value(forKey: "status") as! Bool)) {
                    completion(true)
                }else{
                    completion(false)
                }
                
            }else {
                print("error \(result)");
            }
        }
    }
  
  func SignUp(phoneNumber:String,firstName:String,lastName:String, completion:@escaping (_ success: Bool) -> Void) {
      self.mobile = phoneNumber
      self.fname = firstName
      self.lname = lastName
    
      let parmeters:Parameters = ["mobile":phoneNumber,"firstName":firstName,"lastName":lastName]
      let url = Config.serverUrl+"verificationsms"
      Service().post(url: url, parameters: parmeters) { (result) in
        if result.isKind(of:NSDictionary.self) {
          let dataInfo = NSMutableDictionary(dictionary: result as! NSDictionary)
          if((dataInfo.value(forKey: "status") as! Bool)) {
            completion(true)
          }else{
            completion(false)
          }
        }else {
          print("error \(result)");
        }
      }
    }
  
  func VerifySignUp(otp:String, completion:@escaping (_ success: Bool) -> Void) {
    
      let parmeters:Parameters = ["mobile":self.mobile,"firstName":self.fname,"lastName":self.lname,"smsVerificationCode":otp]
      let url = Config.serverUrl+"user"
      Service().post(url: url, parameters: parmeters) { (result) in
        if result.isKind(of:NSDictionary.self) {
          let dataInfo = NSMutableDictionary(dictionary: result as! NSDictionary)
          if((dataInfo.value(forKey: "status") as! Bool)) {
            self.authToken = dataInfo.value(forKey: "token") as! String
            User.currentUser.isLogin = true
            
            let data = dataInfo.value(forKey: "data") as! NSDictionary
            self.info = NSMutableDictionary()
            self.info.setValue(data.value(forKey: "_id"), forKey: "_id")
            self.info.setValue(data.value(forKey: "firstName"), forKey: "firstName")
            self.info.setValue(data.value(forKey: "lastName"), forKey: "lastName")
            self.info.setValue(data.value(forKey: "mobile"), forKey: "mobile")
            self.info.setValue(data.value(forKey: "email"), forKey: "email")
            self.info.setValue(data.value(forKey: "currentLocation"), forKey: "currentLocation")
            self.info.setValue(data.value(forKey: "devices"), forKey: "devices")
            self.info.setValue(data.value(forKey: "env"), forKey: "env")
            User.currentUser.saveToLocal()

            completion(true)
          }else{
            completion(false)
          }
        }else {
          print("error \(result)");
        }
      }
    }
  
  
  
    func VerifyWithOTP(otp:String, completion:@escaping (_ success: Bool) -> Void) {
        let parmeters:Parameters = ["mobile":self.mobile,"smsVerificationCode":otp];
        let url = Config.serverUrl+"session/mobile/verify"
        Service().post(url: url, parameters: parmeters) { (result) in
            if result.isKind(of:NSDictionary.self) {
                print("VerifyWithOTP :**** \(result)")
                let dataInfo = NSMutableDictionary(dictionary: result as! NSDictionary)
                if((dataInfo.value(forKey: "status") as! Bool)) {
                    self.authToken = dataInfo.value(forKey: "data") as! String
                    User.currentUser.isLogin = true
                    User.currentUser.saveToLocal()
                    //get user info
                    self.getInfo()
                    completion(true)
                }
                else{
                    completion(false)
                }
            }else {
                print("error \(result)");
            }
        }
    }
    
    func SocialSignInWithInstagram(parameters:[String:Any], completion:@escaping (_ success: Bool) -> Void) {
        
        let url = Config.serverUrl+"social"
        Service().post(url: url, parameters: parameters) { (result) in
            if result.isKind(of:NSDictionary.self) {
                let dataInfo = NSMutableDictionary(dictionary: result as! NSDictionary)
                
//                print("dataInfo**\(dataInfo)")
                if((dataInfo.value(forKey: "message") as! String) == "ok") {
                    self.authToken = dataInfo.value(forKey: "token") as! String
                    User.currentUser.isLogin = true
                    User.currentUser.saveToLocal()
                    //get user info
                    self.getInfo()
                    completion(true)
                }
                else{
                    completion(false)
                }
            }
            else {
                print("error \(result)");
            }
            
        }
    }
    
    func sendUserInformation(parameter: [String:Any], completion:@escaping (_ success: Bool) -> Void) {
        
        print("Parameterds***\(parameter)")
        let url = Config.serverUrl+"states"
        
        Service().post(url: url, parameters: parameter) { (result) in
            if result.isKind(of:NSDictionary.self) {
                let dataInfo = NSMutableDictionary(dictionary: result as! NSDictionary)
                completion(true)
            }else {
                print("error \(result)");
                completion(false)
            }
        }
    }

    //get userinfo from server
    func getInfo() {
        let url = Config.serverUrl+"me"
        Service().get(url: url) { (result) in
            if result is NSDictionary {
                let dinfo = NSMutableDictionary(dictionary: result as! NSDictionary)
//                print(dinfo)
                if ((dinfo.value(forKey: "message") as! String) == "ok") {
                    self.isLogin = true
                    let data = dinfo.value(forKey: "data") as! NSDictionary
                    if(self.info == nil){ self.info = NSMutableDictionary() }
                    self.info.setValue(data.value(forKey: "_id"), forKey: "_id")
                    self.info.setValue(data.value(forKey: "firstName"), forKey: "firstName")
                    self.info.setValue(data.value(forKey: "lastName"), forKey: "lastName")
                    self.info.setValue(data.value(forKey: "mobile"), forKey: "mobile")
                    self.info.setValue(data.value(forKey: "email"), forKey: "email")
                    self.info.setValue(data.value(forKey: "authSource"), forKey: "authSource")
                    self.info.setValue(data.value(forKey: "currentLocation"), forKey: "currentLocation")
                    self.info.setValue(data.value(forKey: "devices"), forKey: "devices")
                    self.info.setValue(data.value(forKey: "env"), forKey: "env")
                    self.info.setValue(data.value(forKey: "invitedUsers"), forKey: "invitedUsers")
                    self.info.setValue(data.value(forKey: "profilePicture"), forKey: "profilePicture")
                    self.info.setValue(data.value(forKey: "roles"), forKey: "roles")
                  
                    self.saveToLocal()
                    self.initWithInfo(isAPICall: false)
                }
            }
        }
    }
    
    //save userinfo to server
    func saveToServer() {
        let name = fname + " " + lname
        self.info.setValue(name, forKey: "name")
        self.info.setValue(email, forKey: "email")
        let parmeters:Parameters = ["user":info];
        let url = Config.serverUrl+"users/create"
        Service().post(url: url, parameters: parmeters) { (result) in
            
            if result.isKind(of:NSDictionary.self) {
                //print(result);
                let dataInfo = NSMutableDictionary(dictionary: result as! NSDictionary)
                self.info = NSMutableDictionary(dictionary: dataInfo.value(forKey: "user") as! NSDictionary)
                self.id = self.info.value(forKey: "_id") as! String
                self.isLogin = true
                self.saveToLocal()
            }else {
                print("error \(result)");
            }
        }
    }
    
    func updateToServer(parametes: [String:Any], completion:@escaping (_ success: Bool) -> Void) {
        
        let url = Config.serverUrl+"users/"+self.id
        print("updateToServer parametes = \(parametes)")
        SVProgressHUD.show()
        Service().put(url: url, parameters: parametes) { (result) in
            SVProgressHUD.dismiss()
            if result.isKind(of:NSDictionary.self) {
                print(result);
                DispatchQueue.main.asyncAfter(deadline: .now()+0.2, execute: { 
                    self.getInfo()
                    completion(true)
                })
            }else {
                print("error \(result)");
                completion(false)
            }
        }
    }
    
    // save user info
    func saveToLocal() {
        let preferences = UserDefaults.standard
        preferences.set(isLogin, forKey:"isLogin")
        preferences.set(authToken, forKey:"authToken")
        preferences.set(self.info, forKey: "info")
        preferences.synchronize()
    }
    
    //delete current logged in user info
    func logout() {
        self.info.removeAllObjects();
        self.id = ""  // For Photo view count API -- 19-06-2017
        self.authToken = ""
        self.isLogin = false
        let preferences = UserDefaults.standard
        preferences.set(isLogin, forKey:"isLogin")
        preferences.set(info, forKey: "info")
        preferences.set(authToken, forKey:"authToken")
        self.defaultCard = nil
        preferences.synchronize()
    }
    
    func isApplePayAvailable()->Bool {
        
        let paymentNetworks = [PKPaymentNetwork.amex, PKPaymentNetwork.masterCard, PKPaymentNetwork.visa]
        if PKPaymentAuthorizationViewController.canMakePayments(usingNetworks: paymentNetworks) {
            print("Apple pay is available YES .....")
            return true
        }
        else {
            print("Apple pay is available NO .......")
            return false
        }
    }
    
    func getUserDefaultCard(completion:@escaping (_ success: Bool) -> Void) {
        let url = Config.serverUrl+"payment-methods"
        
        Service().get(url: url) { (result) in
            SVProgressHUD.dismiss()
            if result.isKind(of:NSDictionary.self) {
                let dataInfo:NSMutableDictionary = NSMutableDictionary(dictionary: result as! NSDictionary)
                if((dataInfo.value(forKey: "message") as! String) == "ok") {
                    let results = dataInfo.value(forKey: "data") as! [[String:Any]]
                    for temp in results {
                        let card = Card(info: temp as NSDictionary)
                        if card.isDefault
                        {
                            self.defaultCard = card
                            completion(true)
                        }
                    }
                }
                else {
                    print("CCARD NOT ADDED")
                }
                completion(true)
            }
        }
    }
    
    
    func clearAppCaches() {
        let myPathList: [Any] = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)
        let mainPath: String = myPathList[0] as? String ?? ""
        let fileMgr = FileManager.default
        let fileArray: [String]? = try? fileMgr.contentsOfDirectory(atPath: mainPath)
        for filename in fileArray! {
            try? fileMgr.removeItem(atPath: URL(fileURLWithPath: mainPath).appendingPathComponent(filename).absoluteString)
        }
        URLCache.shared.removeAllCachedResponses()
    }
    
    
}


class AccountSetting {
    
//    var accountId = ""
//    var website = ""
//    var suggestLocationEmail = "suggestions@gopostcard.com"
//    var suggestTipEmail = "suggestions@gopostcard.com"
//    var termsUrl = "http://gopostcard.com/terms"
//    var privacyUrl = "" // "https://www.gopostcard.com/privacy-policy"
//    var aboutusUrl = ""
//    var facebookPageUrl = ""
//    var cloudUrl = ""
//    var ituneUrl = ""
//    var playstoreUrl = ""
//    var playstoreVersion = ""
//    var updatedDate = ""
//    var isItuneVersion:Bool!
//    var googleMapsKey = "AIzaSyCrG674mrrvSzmOqipHKFz1WRQvknZOYc0"
    
    var venueDefaultImage = ""
    var termAndConditionUrl = "http://facebook.com"
    var privacyUrl = "http://helloworld.com"
    var contactEmail = "ap@maxter.com"
    var MyPurchaseReportEmail = "help@gopostcard.com"
    var appLogo = ""
  
    var tipPercentage =  0.0
    var taxPercentage = 0.0
    var tipPercentageMessage = ""
    
    public init (){}
    public init (info:NSDictionary) {
        
        if(info["tipPercentageMessage"] != nil) {
            self.tipPercentageMessage = info["tipPercentageMessage"] as! String
        }
        else {
            self.tipPercentageMessage = ""
        }
      
        self.venueDefaultImage = info["venueDefaultImage"] as! String
        self.termAndConditionUrl = info["termAndConditionUrl"] as! String
        self.privacyUrl = info["privacyUrl"] as! String
        self.contactEmail = info["contactEmail"] as! String
        self.appLogo = info["appLogo"] as! String
        self.tipPercentage =  info["tipPercentage"] as! Double
        self.taxPercentage = info["taxPercentage"] as! Double
        let aws = info["aws"] as! [String:String]
        let instagram = info["instagram"] as! [String:String]
    }
}

class Venue{
  var _id = "5967a387ad0eb3583b59b137";
  var address = "121 West 3rd Street";
  var city = "New York";
  var featuredPhotoUrl = "https://postcardapp.s3.amazonaws.com/Pokee%20Venue%20Image.png";
  var name = "Pokee"
  var state = "NY";
  var hours = "12:00AM - 08:00PM"
  var salesTax:NSNumber!
  public init (){}
  public init (infoData:NSDictionary) {
    self._id = infoData.value(forKey: "_id") as! String
    self.address = infoData.value(forKey: "address") as! String
    self.city = infoData.value(forKey: "city") as! String
    self.featuredPhotoUrl = infoData.value(forKey: "featuredPhotoUrl") as! String
    self.name = infoData.value(forKey: "name") as! String
    self.state = infoData.value(forKey: "state") as! String
    self.hours = infoData.value(forKey: "Hours") as! String
    self.salesTax = infoData.value(forKey: "salesTax") as! NSNumber
  }
}

class Places {
    var _id = ""
    var name = ""
    var address = ""
    var city = ""
    var featuredPhotoUrl = ""
    var state = ""
    var zipcode = ""
    var category = ""
    //    var hours:[[String: Any]] = []
    var ratingLinks:[[String: Any]] = []
    var tips:[[String: Any]] = []
    var venueCategories:[[String: Any]] = []
    var viewport:[[String: Any]] = []
    
    var fullAddress = ""
    var miles = 0.0
    var status = 0
    var lat = 0.0
    var lng = 0.0
    var isTapsterPlace:Bool!
    var tapsterId:String!
    var description:String!
    
    var isBookmark = false
    var display:Bool = false
    var phone:String = ""
    var mobile:String = ""
    var ticketUrl:String = ""
    var editorNotes:String = ""
    var hoursOfOperations:String = ""
    var yelpRating:String = ""
    var googleRating:String = ""
    var fourSRating:String = ""
    var areaCode:String = "" // this is for showing the Area stamp
    var distance:String = ""
    var timezone:String = ""
    var Hours:String = ""
    var HappyHoursString:String = ""
    
    var weekendhours = [String]()
    var newHours = ""
    
    var labelOpen:String = ""
    var isOpen:Bool = false
    var menuStatus:Bool = false
    
    var info = [String: Any]()
    var venueclassification:String = ""
    
    public init (infoData:NSDictionary) {
        //        self.venueName = infoData["title"] as! String
        self.info = infoData as! [String : Any]
        self._id = infoData["_id"] as! String
        self.name = infoData["name"] as! String
        self.address = infoData["address"] as! String
        
        if((infoData["venueclassification"]) != nil)
        {
            self.venueclassification = infoData["venueclassification"]  as! String
        }
        else {
            self.venueclassification = ""
        }
        
        if((infoData["Hours"] ) != nil)
        {
            self.Hours = infoData["Hours"]  as! String
        }else
        {
            self.Hours = ""
        }
        if((infoData["HappyHours"]) != nil)
        {
            self.HappyHoursString = infoData["HappyHours"] as! String
        }else
        {
            self.HappyHoursString = ""
        }
        //      ADD NEW KEY
        
        self.city = infoData["city"] as! String
        self.fullAddress = infoData["addressLine2"] as! String
        let imageURL = infoData.value(forKey: "featuredPhotoUrl") as! String
        self.featuredPhotoUrl = imageURL.trim()  // infoData.value(forKey: "featuredPhotoUrl") as! String
        if(self.featuredPhotoUrl.trim().isEmpty) {
            if !User.currentUser.accountSetting.venueDefaultImage.trim().isEmpty {
                self.featuredPhotoUrl = User.currentUser.accountSetting.venueDefaultImage
            }
            else {
                self.featuredPhotoUrl = ""
            }
        }
        //self.hours = info.value(forKey: "hours") as! [NSDictionary]
        self.state = infoData.value(forKey: "state") as! String
        self.zipcode = infoData.value(forKey: "zipcode") as! String
        let category = infoData["venueCategories"] as! [[String:String]]
        
        self.venueCategories = infoData["venueCategories"] as! [[String:String]]
        
        if let ticket =  infoData.value(forKey: "ticketUrl") {
            self.ticketUrl = ticket as! String
        }
        if(category.count > 0)
        {
            self.category = category[0]["title"]!
        }else
        {
            self.category = " "
        }
        if let geoTamp = info["geo"]
        {
            let geo = geoTamp as! [Double]
            if geo.count > 0 {
                self.lng = geo.first!
                self.lat = geo.last!
                //                self.lat = geo.first!
                //                self.lng = geo.last!
//                if User.currentUser.currentLatitude != 0.0 && User.currentUser.currentLongitude != 0.0 {
//                    let userLocation = CLLocation(latitude: User.currentUser.currentLatitude, longitude: User.currentUser.currentLongitude)
//                    let venueLocation = CLLocation(latitude: self.lat, longitude: self.lng)
//                    self.miles = self.calculatedistanceBetweenTwoLocations(source: userLocation, destination: venueLocation)
//                }
            }
        }
        
        let openClose = info["openclose"] as! [String: Any]
        self.isOpen = openClose["isOpen"] as! Bool
        
        if let menuStatus =  info["menuStatus"] {
            self.menuStatus = menuStatus as! Bool
        }
        
        self.labelOpen = openClose["label"] as! String
        
        //12-06-START
        if let mobile =  info["mobile"] {
            self.mobile = mobile as! String
        }
        if let phone =  info["phone"] {
            self.phone = phone as! String
        }
        if let weekendhours =  info["weekendhours"] {
            self.weekendhours = weekendhours as! [String]
            for time in self.weekendhours {
                if newHours.isEmpty {
                    newHours = time
                }else{
                    //newHours = newHours + " \n" + time
                    newHours = newHours  + time
                }
            }
        }
        newHours = newHours.replacingOccurrences(of: "Monday: ", with:      "\n\n Monday:\n ")
        newHours = newHours.replacingOccurrences(of: "Tuesday: ", with:     "\n\n Tuesday:\n ")
        newHours = newHours.replacingOccurrences(of: "Wednesday: ", with:   "\n\n Wednesday:\n ")
        newHours = newHours.replacingOccurrences(of: "Thursday: ", with:    "\n\n Thursday:\n ")
        newHours = newHours.replacingOccurrences(of: "Friday: ", with:      "\n\n Friday:\n ")
        newHours = newHours.replacingOccurrences(of: "Saturday: ", with:    "\n\n Saturday:\n ")
        newHours = newHours.replacingOccurrences(of: "Sunday: ", with:      "\n\n Sunday:\n ")
        newHours = newHours.replacingOccurrences(of: ", ", with: "\n ")
        //12-06-END
        
        var venPhotos = [[String: Any]]()
        if let temp = info["venuePhotos"] {
            venPhotos = temp as! [[String: Any]]
        }
        
        if let tips = info["tips"] {
            self.tips = tips as! [[String: Any]]
        }
        
        if let editorNotes = info["editorNotes"] {
            self.editorNotes = editorNotes as! String
        }
        
        if User.currentUser.isLogin {
            let savedLocations = User.currentUser.info["savedLocations"] as! [String]
            self.isBookmark = savedLocations.contains(self._id)
        }
        
    }
    
    public init (infoData:[String : Any]) {
        //        self.venueName = infoData["title"] as! String
        self.info = infoData
        self._id = info["_id"] as! String
        //        self.updatedAt = self.regularDetils["updatedAt"] as! String
        //        self.createdAt = self.regularDetils["createdAt"] as! String
        self.name = info["name"] as! String
        self.address = info["address"] as! String
        
        if((infoData["venueclassification"]) != nil)
        {
            self.venueclassification = infoData["venueclassification"]  as! String
        }
        
        if((info["Hours"] ) != nil)
        {
            self.Hours = info["Hours"]  as! String
        }else
        {
            self.Hours = ""
        }
        if((info["HappyHours"]) != nil)
        {
            self.HappyHoursString = info["HappyHours"] as! String
        }else
        {
            self.HappyHoursString = ""
        }
        //      ADD NEW KEY
        
        self.fullAddress = info["addressLine2"] as! String
        //        self.work = self.regularDetils["work"] as! String
        self.zipcode = info["zipcode"] as! String
        self.city = info["city"] as! String
        self.state = info["state"] as! String
        self.status = info["status"] as! Int
        self.editorNotes = info["editorNotes"] as! String
        self.featuredPhotoUrl = info["featuredPhotoUrl"] as! String
        if(self.featuredPhotoUrl.trim().isEmpty) {
            if !User.currentUser.accountSetting.venueDefaultImage.trim().isEmpty {
                self.featuredPhotoUrl = User.currentUser.accountSetting.venueDefaultImage
            }
            else {
                self.featuredPhotoUrl = ""
            }
        }
        self.timezone = info["timezone"] as! String
        if let geoTamp = info["geo"]
        {
            let geo = geoTamp as! [Double]
            if geo.count > 0 {
                self.lng = geo.first!
                self.lat = geo.last!
            }
        }
        
        if  User.currentUser.isLogin {
            let savedLocations = User.currentUser.info["savedLocations"] as! [String]
            self.isBookmark = savedLocations.contains(self._id)
        }
        
        self.description = info["description"] as! String
        self.mobile = info["mobile"] as! String
        self.phone = info["phone"] as! String
        self.ticketUrl = info["ticketUrl"] as! String
        
        if let display = info["display"]
        {
            self.display = display as! Bool
        }
        
        
        //        self.hours = info["hours"] as! [[String: Any]]
        if let weekendhours =  info["weekendhours"] {
            self.weekendhours = weekendhours as! [String]
            for time in self.weekendhours {
                if newHours.isEmpty {
                    newHours = time
                }else{
                    //newHours = newHours + " \n" + time
                    newHours = newHours  + time
                }
            }
        }
        newHours = newHours.replacingOccurrences(of: "Monday: ", with:      "\n\n Monday:\n ")
        newHours = newHours.replacingOccurrences(of: "Tuesday: ", with:     "\n\n Tuesday:\n ")
        newHours = newHours.replacingOccurrences(of: "Wednesday: ", with:   "\n\n Wednesday:\n ")
        newHours = newHours.replacingOccurrences(of: "Thursday: ", with:    "\n\n Thursday:\n ")
        newHours = newHours.replacingOccurrences(of: "Friday: ", with:      "\n\n Friday:\n ")
        newHours = newHours.replacingOccurrences(of: "Saturday: ", with:    "\n\n Saturday:\n ")
        newHours = newHours.replacingOccurrences(of: "Sunday: ", with:      "\n\n Sunday:\n ")
        newHours = newHours.replacingOccurrences(of: ", ", with: "\n ")
        
        
        let venPhotos = info["venuePhotos"] as! [[String: Any]]
        
        // Abhi-Start
        let tempRatingLink = info["ratingLinks"] as! [[String: Any]]
        
        if tempRatingLink.count > 0 {
            for k in 0..<tempRatingLink.count {
                let temp = tempRatingLink[k]
                let rating = temp["rating"] as! String
                if rating.trim() == "" || rating.trim() == "0" || rating.trim() == "0.0"  {
                    //print("RATING**LINK**NOT**ADDED")
                }
                else {
                    self.ratingLinks.append(temp)
                }
            }
        }
        // Abhi-End
        
        if self.ratingLinks.count > 0
        {
            for dict in self.ratingLinks
            {
                let strTitle = dict["source"] as! String
                switch strTitle {
                case "google":
                    let googleRating = dict["rating"] as! String
                    self.googleRating = googleRating.trim() // dict["rating"] as! String
                case "yelp":
                    let yelpRating = dict["rating"] as! String
                    self.yelpRating = yelpRating.trim() // dict["rating"] as! String
                case "foursquare":
                    let fourSRating = dict["rating"] as! String
                    self.fourSRating = fourSRating.trim() // dict["rating"] as! String
                default:
                    print("")
                }
            }
        }
        
        self.tips = info["tips"] as! [[String: Any]]
        self.venueCategories = info["venueCategories"] as! [[String: Any]]
        self.viewport = info["viewport"] as! [[String: Any]]
        
        //    self.menuStatus = info["menuStatus"] as! Bool
        if let menuStatus =  info["menuStatus"] {
            self.menuStatus = menuStatus as! Bool
        }
        
        let openClose = info["openclose"] as! [String: Any]
        self.isOpen = openClose["isOpen"] as! Bool
        
        self.labelOpen = openClose["label"] as! String
    }
  
    func bookMarkALocation(completion:@escaping (_ success: Bool) -> Void) {
        let url = Config.serverUrl+"bookmark/"
        let parmeters:Parameters = ["placeId":self._id];
        Service().post(url: url, parameters: parmeters) { (result) in
            if result.isKind(of:NSDictionary.self) {
                print(result);
                completion(true)
            }else {
                print("error \(result)");
                completion(false)
            }
        }
    }
    
    func getPhotos(completion:@escaping (_ success: Bool) -> Void) {
        let url = Config.serverUrl+"photos/"+self._id
        Service().get(url: url) { (result) in
            if result.isKind(of:NSDictionary.self) {
                print(result);
                completion(true)
            }else {
                print("error \(result)");
                completion(false)
            }
        }
    }
    
    func getTooltips(completion:@escaping (_ success: Bool) -> Void) {
        let url = Config.serverUrl+"tooltips/"+self._id
        Service().get(url: url) { (result) in
            if result.isKind(of:NSDictionary.self) {
                print(result);
                completion(true)
            }else {
                print("error \(result)");
                completion(false)
            }
        }
    }
    
    func postTooltips(completion:@escaping (_ success: Bool) -> Void) {
        let url = Config.serverUrl+"venues/"+self._id
        let parame = ["tips": self.tips]
        Service().put(url: url, parameters: parame){ (result) in
            if result.isKind(of:NSDictionary.self) {
                print(result);
                completion(true)
            }else {
                print("error \(result)");
                completion(false)
            }
        }
    }
    
    func deletePhotosWithPhotoid(photoid: String , completion:@escaping (_ success: Bool) -> Void) {
        let url = Config.serverUrl+"venues/"+self._id
        var venPhotos = self.info["venuePhotos"] as! [[String: Any]]
        for i in 0..<venPhotos.count{
            let venPhoto = venPhotos[i]
            if photoid == venPhoto["_id"] as! String {
                venPhotos.remove(at: i)
                break
            }
        }
        let parame = ["venuePhotos": venPhotos]
        print("Deletephotopostparam===\(parame)")
        Service().put(url: url, parameters: parame){ (result) in
            if result.isKind(of:NSDictionary.self) {
                
                print("Delete****\(result)")
                completion(true)
            }else {
                print("error \(result)");
                completion(false)
            }
        }
    }    
}

class Card {
    var id = ""
    var brand = ""
    var cardId = ""
    var expMonth = 0
    var expYear = 0
    var last4 = ""
    var isDefault:Bool = false
    
    public init (info:NSDictionary) {
        self.id = info["_id"] as! String
        self.cardId = info["cardId"] as! String
        self.isDefault = info["isDefault"] as! Bool
        
        let card = info["card"] as! [String:Any]
        self.brand = card["brand"] as! String
        self.expMonth = card["exp_month"] as! Int
        self.expYear = card["exp_year"]! as! Int
        self.last4 = card["last4"]! as! String
    }
    
    func setDefaultCard(cardId:String, completion:@escaping (_ success: Bool) -> Void) {
        let url = Config.serverUrl+"payment-methods/\(cardId)"
        let parame = ["isDefault": true]
        print("url***\(url)parame**\(parame)")
        Service().put(url: url, parameters: parame){ (result) in
            if result.isKind(of:NSDictionary.self) {
                print("result**\(result)")
                completion(true)
            }else {
                print("error**\(result)")
                completion(false)
            }
        }
    }
    
    func deleteCard(cardId:String, completion:@escaping (_ success: Bool) -> Void) {
        let url = Config.serverUrl+"payment-methods/\(cardId)"
        Service().delCreditCard(url: url){ (result) in
            if result.isKind(of:NSDictionary.self) {
                let dataInfo = NSMutableDictionary(dictionary: result as! NSDictionary)
                print("dataInfo**\(dataInfo)")
                if dataInfo.value(forKey: "message") as! String == "ok" {
                    completion(true)
                }else {
                    print("error \(result)");
                    completion(false)
                }
            }
            else if result.isKind(of:NSError.self) {
                let error = result as! NSError
                print("error \(error.localizedDescription)");
                completion(false)
            }
        }
    }
}

class MenuCategory {
  var title:String = ""
  var id:String = ""
  var selected:Bool = false
  var menuItems:[MenuItem] = []
  
  func getSize() -> Double {
    let font = UIFont(name: "SFUIText-semibold", size: 18)
    let width = title.widthOfString(usingFont: font!)
    return Double(width+10)
  }
  func setMenuItems(items:[NSDictionary])  {
    for menuItemInfo:NSDictionary in items {
      let menuItem:MenuItem = MenuItem(info: menuItemInfo)
      self.menuItems.append(menuItem)
    }
  }
}

class MenuItem {
    var _id = ""
    var category = ""
    var imageSmallUrl = ""
    var imageUrl = ""
    var itemDescription = ""
    var itemName = ""
    var itemPrice:Double = 0.0
  
    var sectionItems:[AddOnItem] = []
    //var arrayAddons = [Addons]()
    public init (){}
    public init (info:NSDictionary) {
      self._id = info.value(forKey: "_id") as! String
      self.category = info.value(forKey: "category") as! String
      self.imageSmallUrl = info.value(forKey: "imageSmallUrl") as! String
      self.imageUrl = info.value(forKey: "imageUrl") as! String
      self.itemDescription = info.value(forKey: "itemDescription") as! String
      self.itemName = info.value(forKey: "itemName") as! String
      self.itemPrice = Double(info.value(forKey: "itemPrice") as! String)!
      
      let sections:NSArray = info.value(forKey: "sectionItems") as! NSArray
      for i in 0..<sections.count {
        let section:NSDictionary = sections.object(at: i) as! NSDictionary
        let addOnItem:AddOnItem = AddOnItem(info: section)
        self.sectionItems.append(addOnItem)
      }
    }
  //check the cart have this item or not ?
  func CheckAndGetQtyCount() -> Int {
    var itemCount:Int = 0
    for i in 0..<Cart.cart.cartItems.count {
      let cartObj = Cart.cart.cartItems[i]
      if(cartObj.menuItemId == _id){
        itemCount = cartObj.quantity
        break
      }
    }
    return itemCount
  }
}

class AddOnItem {
  var isRequired:Bool!
  var sectionName = ""
  var options:[AddOnOption] = []
  var isSelected:Bool = false
  public init (){}
  public init (info:NSDictionary) {
    self.isRequired = info.value(forKey: "isRequired") as! Bool
    self.sectionName = info.value(forKey: "sectionName") as! String
    let addOnItems:NSArray = info.value(forKey: "addOnItems") as! NSArray
    for i in 0..<addOnItems.count {
      let addOnItem:NSDictionary = addOnItems.object(at: i) as! NSDictionary
      let addOnOption:AddOnOption = AddOnOption(info: addOnItem)
      options.append(addOnOption)
    }
  }
}

class AddOnOption {
  var isRequired:Bool!
  var addOnName = ""
  var price:Double = 0.0
  var isSelected:Bool = false
  public init (){}
  public init (info:NSDictionary) {
    self.isRequired = info.value(forKey: "isRequired") as! Bool
    self.addOnName = info.value(forKey: "addOnName") as! String
    self.price = Double(info.value(forKey: "price") as! String)!
  }
}
class Cart {
  var cartItems:[CartItem] = []
  static let cart:Cart = Cart()
  var venueId:String = ""
}

class CartItem {
  var quantity:Int = 0
  var total:Double = 0.0
  var menuItem:MenuItem!
  var menuItemId:String = ""
  var itemSummary:String = ""
  func updateItemSummary() {
    for i in 0..<self.menuItem.sectionItems.count {
      let dict:AddOnItem = self.menuItem.sectionItems[i]
      for i in 0..<dict.options.count {
        let option:AddOnOption = dict.options[i]
        if(option.isSelected){
          itemSummary = itemSummary+option.addOnName+", "
        }
      }
    }
  }
}

class ServiceFee {
  var percent:Int = 0
  var isSelected:Bool = false
  var serviceFee:Double = 0.0
  var selectedString:NSMutableAttributedString!
  var defaultString:NSMutableAttributedString!
  
  func setServiceFee(subTotalAmount:Double) {
    serviceFee = (percent == 0) ? 0 : ((subTotalAmount * Double(percent)) / 100)
    self.serviceFeeString()
    self.selectedServiceFeeString()
  }
  
  func serviceFeeString() {
    let fontB = [ NSFontAttributeName: UIFont(name: "SFUIText-bold", size: 16.0)!, NSForegroundColorAttributeName:Util.util.hexStringToUIColor(hex: "#A2A2A6") ]
    let fontS = [ NSFontAttributeName: UIFont(name: "SFUIText-regular", size: 10.0)!, NSForegroundColorAttributeName:Util.util.hexStringToUIColor(hex: "#A2A2A6") ]
    let attrStringPercent = NSMutableAttributedString(string: "\(percent)%\n", attributes: fontB)
    let attrStringServiceFee = NSAttributedString(string: String(format: "$%.2f", serviceFee), attributes: fontS)
    attrStringPercent.append(attrStringServiceFee)
    self.defaultString = attrStringPercent
  }
  
  func selectedServiceFeeString() {
    let fontB = [ NSFontAttributeName: UIFont(name: "SFUIText-bold", size: 16.0)!, NSForegroundColorAttributeName:Util.util.hexStringToUIColor(hex: User.currentUser.appColor) ]
    let fontS = [ NSFontAttributeName: UIFont(name: "SFUIText-regular", size: 10.0)!, NSForegroundColorAttributeName:Util.util.hexStringToUIColor(hex: User.currentUser.appColor) ]
    let attrStringPercent = NSMutableAttributedString(string: "\(percent)%\n", attributes: fontB)
    let attrStringServiceFee = NSAttributedString(string: String(format: "$%.2f", serviceFee), attributes: fontS)
    attrStringPercent.append(attrStringServiceFee)
    self.selectedString = attrStringPercent
  }
}

//class Tooltip {
//    var tooltip = ""
//    var toolTipId = ""
//    var status:Bool = false
//    
//    func flagGoodTip(completion:@escaping (_ success: Bool) -> Void) {
//        let url = Config.serverUrl+"flagtooltip/"
//        let parmeters:Parameters = ["tooltipId":self.toolTipId,"flag":"pasative"];
//        Service().post(url: url, parameters: parmeters) { (result) in
//            if result.isKind(of:NSDictionary.self) {
//                print(result);
//                completion(true)
//            }else {
//                print("error \(result)");
//                completion(false)
//            }
//        }
//    }
//    
//    func flagBadTip(completion:@escaping (_ success: Bool) -> Void) {
//        let url = Config.serverUrl+"flagtooltip/"
//        let parmeters:Parameters = ["tooltipId":self.toolTipId,"flag":"negative"];
//        Service().post(url: url, parameters: parmeters) { (result) in
//            if result.isKind(of:NSDictionary.self) {
//                print(result);
//                completion(true)
//            }else {
//                print("error \(result)");
//                completion(false)
//            }
//        }
//    }
//}


