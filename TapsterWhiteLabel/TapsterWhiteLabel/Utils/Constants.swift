//
//  Constants.swift
//  PostCard
//
//  Created by Mac on 21/04/17.
//  Copyright © 2017 Linkites. All rights reserved.
//

import Foundation
struct Config {
    
    //    static var serverUrl = "http://stagmapi.gopostcard.net/v1/"  // Development
    static var serverUrl = "http://54.148.250.99:4000/v1/"       // Production
    //static var serverUrl = "http://192.168.1.99:4000/v1/"       // Production
    
    static var google_key = "AIzaSyBxvbBF_31dAm4PVYv78178fIWVfGnsMxc"
    static var venueDefaultImage = "https://media.timeout.com/images/103012873/image.jpg"
    static var tapsterDeepLink = "https://itunes.apple.com/in/app/tapster-ditch-the-line-at-nyc-bars/id1191406754?mt=8"
    static var centrolParkLat = 40.785091
    static var centrolParkLng = -73.968285
    static var TIP = 20.0
    
}

struct UIConfig {
  static var keyboardHeight:CGFloat = 224.0
}


struct AppNotifications {
    static let notificationChangeMenu = Notification.Name("ChangeMenu")
    static let notificationGetLocation = Notification.Name("GetLocation")
    static let notificationShowMap = Notification.Name("ShowMap")
    static let notificationShowHome = Notification.Name("ShowHome")
    static let notificationOpenCamera = Notification.Name("OpenCamera")
    static let notificationSignInSuccess = Notification.Name("SignInSuccess")
    static let notificationGetIndex = Notification.Name("GetIndex")
    static let notificationSelectItem = Notification.Name("SelectItem")
    static let notificationSelectCardOption = Notification.Name("SelectCardOption")
    static let notificationLoadImageSlider = Notification.Name("LoadImageSlider")
    static let notificationReloadCardData = Notification.Name("ReloadCardData")
    static let notificationVisibleImg = Notification.Name("VisibleImg")
    static let notificationInviteContact = Notification.Name("InviteContact")
    static let notificationLoadAPNSData = Notification.Name("LoadAPNSData")
    static let notificationDeepLink = Notification.Name("NotificationDeepLink")
    
    static let notificationHideRightMenu = Notification.Name("HideRightMenu")
    static let notificationBlockedImage = Notification.Name("BlockedImage")
    
    static let notificationShowProductDetails = Notification.Name("ShowProductDetails")
    static let notificationReloadCardList = Notification.Name("ReloadCardList")
    static let notificationSetAddToCartDetails = Notification.Name("SetAddToCartDetails")
    static let notificationSetPurchasePopup = Notification.Name("SetPurchasePopup")
    
    static let notificationStatusBarNotification = Notification.Name("statusBarNotification")
    
    static let notificationGetTotalCost = Notification.Name("GetTotalCost")
  
    static let notificationRegisterAPNS = Notification.Name("RegisterAPNS")
    static let notificationCartUpdated = Notification.Name("CartUpdated")
}

struct AWS {
    //  static var S3BucketName = "postcard"
    //  static var poolId       = "us-west-2:ea78cc0e-4688-462f-b221-138b054a7e3d"
    //  static var accessKey    = "AKIAIQZ7XHSXDZRPCNIA"
    //  static var secretKey    = "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"
    
    static var S3BucketName = "postcardapp"
    static var poolId       = "us-west-2:ea78cc0e-4688-462f-b221-138b054a7e3d"
    static var accessKey    = "AKIAIL4KCVKK5KKMNPDQ"
    static var secretKey    = "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"
    
    static var imagesPath = "postcard/images/"
    static var gifPath = "postcard/gifs/"
    static var videosPath = "postcard/videos/"
    static var audioPath = "postcard/audio/"
    static var selfyPath = "postcard/selfy/"
    
    static var s3BucketUrl = "https://postcardapp.s3.amazonaws.com/"
    
    //     "https://d2e1sv7gzlpvhw.cloudfront.net/"
    //    https://postcardapp.s3.amazonaws.com/profile%20error.png
}

struct Colors {
    static var navBackgroundColor = "#DF4661"
    static var navTitleColor = "#FFFFFF"
    static var imgBgColor = "#D8D8D8"
    static var txtExplore = "000000"
    static var signIn = "9B9B9B"
    static var Or = "DCDCDC"
    static var instagram = "FB3958"
    static var terms = "4A4A4A"
    static var btnPink = "EA3055"
    static var borderColor = "E5E5E5"
    static var tableSeperatorColor = "C8C7CC"
    static var navBottomBorder = "#EFF0F6"
    static var invitedLabel = "#00C8FF"//00CDD5
    static var paginationDots = "#4394EA"
}

struct PAGES {
    static var MY_PHOTOS = 0
    static var SAVED_LOCATIONS = 1
    static var EDIT_PROFILE = 2
    static var DEVICE_SETTINGS = 3
    static var LOGOUT = 16
    static var HOME = 15
    static var MAP = 10
    static var LOGIN = 11
    static var HOURS = 12
    static var WALLET = 13
    static var MY_PURCHASE = 14
    static var SUGGEST_LOCATION = 6
    static var INVITE_FRIEND = 7
    static var PRIVACY = 8
    static var TERMS = 9
}

struct INSTAGRAM {
    
    static let INSTAGRAM_AUTHURL = "https://api.instagram.com/oauth/authorize/"
    static let INSTAGRAM_APIURl  = "https://api.instagram.com/v1/users/"
    static let INSTAGRAM_CLIENT_ID  = "507ea1125d804fac9958d949634686c2"    //  "5520488ddd7a4864b47c3fa339512f2c"
    static let INSTAGRAM_CLIENTSERCRET = "556548580da144adbb3db25055544236" //  "d82a5210e9b548a5bbd7a6c08a6f075a"
    static let INSTAGRAM_REDIRECT_URI = "http://52.54.83.73/instagram/deep/redirect"
    static let INSTAGRAM_ACCESS_TOKEN =  "54d9b9f9d02944de8b4384dff24a87d6"
}

