//
//  Util.swift
//  PostCard
//
//  Created by Mac on 22/04/17.
//  Copyright © 2017 Linkites. All rights reserved.
//

import Foundation
import UIKit
import SVProgressHUD

extension Date {
    func currentDay() -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, MMMM dd"
        return dateFormatter.string(from: self)
    }
}

extension UIViewController
{
    func showAlert(title : String , message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        self .present(alert, animated: true, completion: nil)
    }
    
    func showAlertWithPermission(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let settings = UIAlertAction(title: "Settings", style: .default, handler: { (action) in
            guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {
                return
            }
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                    print("Settings opened: \(success)") // Prints true
                })
            }
        })
        alert.addAction(cancel)
        alert.addAction(settings)
        self.present(alert, animated: true, completion: nil)
    }
    
    func addLeftbuttomWithController(controller : UIViewController, withCustomView btn: UIButton) {
        let leftBtn = UIBarButtonItem(customView: btn)
        controller.navigationItem.leftBarButtonItem = leftBtn
    }
    
    func addRightbuttomWithController(controller : UIViewController, withCustomView btn: UIButton) {
        let rightBtn = UIBarButtonItem(customView: btn)
        controller.navigationItem.rightBarButtonItem = rightBtn
    }
    
    func addRightLabelWithController(controller : UIViewController, withCustomView lbl: UILabel) {
        let rightBtn = UIBarButtonItem(customView: lbl)
        controller.navigationItem.rightBarButtonItem = rightBtn
    }
    
    func addRightbuttomWithController(controller : UIViewController, withCustomViewArray btn: [UIButton]) {
        
        var btnArr = [UIBarButtonItem]()
        for temp in btn {
            let rightBtn = UIBarButtonItem(customView: temp)
            btnArr.append(rightBtn)
        }
        if btnArr.count > 0 {
            controller.navigationItem.rightBarButtonItems = btnArr
        }
    }
}

extension UIView {
    
    func addDropShadowToView(){
        self.layer.masksToBounds =  false
        self.layer.shadowColor = Util.util.hexStringToUIColor(hex: "#DCDCDC").cgColor;
        self.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)//CGSizeMake(1.0, 1.0)
        self.layer.shadowOpacity = 0.8
    }
    
    func roundCorners(corners:UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }
    
    func prasentViewAnimationWithFrame(rect:CGRect, completion: ((Bool) -> Swift.Void)? = nil ) {
        
        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.70, initialSpringVelocity: 0.0, options: UIViewAnimationOptions.allowUserInteraction, animations: {
            self.frame = rect
        }) { (isDone) in
            completion!(isDone)
        }
    }
    
    func fadeinAndFadeOutAnimationWithBool(isShow:Bool, completion: ((Bool) -> Swift.Void)? = nil ) {
        UIView.animate(withDuration: 0.4, animations: {
            self.alpha = isShow ? 1 : 0 //rect
        }) { (isDone) in
            completion!(isDone)
        }
    }
}

extension String {
    
    func widthOfString(usingFont font: UIFont) -> CGFloat {
        let fontAttributes = [NSFontAttributeName: font]
        let size = self.size(attributes: fontAttributes)
        return size.width
    }
    
    func heightOfString(usingFont font: UIFont) -> CGFloat {
        let fontAttributes = [NSFontAttributeName: font]
        let size = self.size(attributes: fontAttributes)
        return size.height
    }
    
    func validEmailAddress() -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        return NSPredicate(format:"SELF MATCHES %@", emailRegEx).evaluate(with: self)
    }
    
    func trim() -> String
    {
        let trimStr:String = self.trimmingCharacters(in: NSCharacterSet.newlines)
        return trimStr.trimmingCharacters(in: NSCharacterSet.whitespaces)
    }
    
    func gethight(_ text: String, with font: UIFont, withLable width: Int) -> CGFloat {
        let maximumLabelSize = CGSize(width: CGFloat(width), height:CGFloat(UINT32_MAX))
        let textRect: CGRect = text.boundingRect(with: maximumLabelSize, options: ([.usesLineFragmentOrigin, .usesFontLeading]), attributes: [NSFontAttributeName: font], context: nil)
        return textRect.size.height
    }
}

extension UIColor {
    func as1ptImage() -> UIImage {
        UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
        let ctx = UIGraphicsGetCurrentContext()
        self.setFill()
        ctx!.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
}

class Util {
    static let util:Util = Util()
  
//    var hud:ProgressHUD!
//    func showHUD() {
//      if(hud == nil){
//        self.hud = ProgressHUD(nibName: "ProgressHUD", bundle: nil)
//      }
//      UIApplication.shared.windows.last?.addSubview(self.hud.view)
//    }
//    
//    func hidHUD() {
//      self.hud.view.removeFromSuperview()
//    }
  
      func showHUD() {
        SVProgressHUD.show()
      }
      func hidHUD() {
        SVProgressHUD.dismiss()
      }
  
  
    func setUpNavigation(navControl:UINavigationController)  {
        navControl.navigationBar.barTintColor = Util.util.hexStringToUIColor(hex: User.currentUser.appColor)
        navControl.navigationBar.tintColor = Util.util.hexStringToUIColor(hex: Colors.navTitleColor)
        navControl.navigationBar.barStyle = .default
        navControl.navigationBar.isTranslucent = false
        navControl.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "SFUIDisplay-Semibold", size: 18)!, NSForegroundColorAttributeName: Util.util.hexStringToUIColor(hex: Colors.navTitleColor)]
    }
    
    func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.characters.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    func format(phoneNumber sourcePhoneNumber: String) -> String? {
        
        // Remove any character that is not a number
        let numbersOnly = sourcePhoneNumber.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        let length = numbersOnly.characters.count
        let hasLeadingOne = numbersOnly.hasPrefix("1")
        
        // Check for supported phone number length
        guard length == 7 || length == 10 || (length == 11 && hasLeadingOne) else {
            return nil
        }
        
        let hasAreaCode = (length >= 10)
        var sourceIndex = 0
        
        // Leading 1
        var leadingOne = ""
        if hasLeadingOne {
            leadingOne = "1 "
            sourceIndex += 1
        }
        
        // Area code
        var areaCode = ""
        if hasAreaCode {
            let areaCodeLength = 3
            guard let areaCodeSubstring = numbersOnly.characters.substring(start: sourceIndex, offsetBy: areaCodeLength) else {
                return nil
            }
            areaCode = String(format: "(%@) ", areaCodeSubstring)
            sourceIndex += areaCodeLength
        }
        
        // Prefix, 3 characters
        let prefixLength = 3
        guard let prefix = numbersOnly.characters.substring(start: sourceIndex, offsetBy: prefixLength) else {
            return nil
        }
        sourceIndex += prefixLength
        
        // Suffix, 4 characters
        let suffixLength = 4
        guard let suffix = numbersOnly.characters.substring(start: sourceIndex, offsetBy: suffixLength) else {
            return nil
        }
        
        return leadingOne + areaCode + prefix + "-" + suffix
    }
}

extension String.CharacterView {
    /// This method makes it easier extract a substring by character index where a character is viewed as a human-readable character (grapheme cluster).
    internal func substring(start: Int, offsetBy: Int) -> String? {
        guard let substringStartIndex = self.index(startIndex, offsetBy: start, limitedBy: endIndex) else {
            return nil
        }
        
        guard let substringEndIndex = self.index(startIndex, offsetBy: start + offsetBy, limitedBy: endIndex) else {
            return nil
        }
        
        return String(self[substringStartIndex ..< substringEndIndex])
    }
}

