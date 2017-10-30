//
//  LoginController.swift
//  TapsterWhiteLabel
//
//  Created by mac on 11/10/17.
//  Copyright © 2017 mac. All rights reserved.
//

import UIKit
import Alamofire
import SVProgressHUD

class LoginController: UIViewController, UITextFieldDelegate {

  @IBOutlet weak var btnMenu: UIButton!
  @IBOutlet weak var btnSignIn: UIButton!
  @IBOutlet weak var txtMobile: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.white
      
        self.title = "Sign In"
        self.view.backgroundColor = UIColor.white
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        Util.util.setUpNavigation(navControl: self.navigationController!)
        self.addLeftbuttomWithController(controller: self, withCustomView: btnMenu)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideBoard))
        self.view.addGestureRecognizer(tapGesture)
        
        self.btnSignIn.backgroundColor = Util.util.hexStringToUIColor(hex: User.currentUser.appColor)
      
        self.txtMobile.becomeFirstResponder()
      
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
      
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
  func hideBoard() {
    self.view.endEditing(true)
  }
  @objc func keyboardWillShow(sender: NSNotification) {
    let keyboardHeight = (sender.userInfo?[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.height
    print(keyboardHeight)
    UIView.animate(withDuration: 0.3, animations: {
    }) { (isDone) in
      self.btnSignIn.frame.origin.y = UIScreen.main.bounds.size.height - (keyboardHeight + 120)
    }
  }
  
  func keyboardWillBeHidden(_ notification: Notification) {
    UIView.animate(withDuration: 0.3, animations: {
    }) { (isDone) in
      self.btnSignIn.frame.origin.y = UIScreen.main.bounds.size.height - 120
    }
  }
  
  @IBAction func actionMenuClosed(_ sender: Any) {
    self.navigationController?.popViewController(animated: true)
  }
  
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    if textField == self.txtMobile {
      if string.characters.count > 0 {
        if (textField.text?.characters.count)! <= 13 {
          if textField.text?.characters.count == 0 {
            let tempStr = "(\(textField.text!)"
            textField.text = tempStr
          }
          else if textField.text?.characters.count == 4 {
            let tempStr = "\(textField.text!)) "
            textField.text = tempStr
          }
          else if textField.text?.characters.count == 9 {
            let tempStr = "\(textField.text!)-"
            textField.text = tempStr
          }
        }
        else {
          return false
        }
      }
      return true
    }
    return true
  }
  
  @IBAction func actionSignIn(_ sender: Any) {
    if (self.txtMobile.text?.characters.count)! == 0 || (self.txtMobile.text?.characters.count)! < 10  {
      let alertController = UIAlertController(title: "Error", message: "Please enter your 10 digit phone number.", preferredStyle: .alert)
      let defaultAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
      alertController.addAction(defaultAction)
      self.present(alertController, animated: true, completion: nil)
      return
    }
    var phoneNumber = self.txtMobile.text!
    //
    let preference = UserDefaults.standard
    preference.set(phoneNumber, forKey:"MobileEditProfile")
    preference.synchronize()
    
    let tmp1 = phoneNumber.replacingOccurrences(of: "(", with: "", options: .literal, range: nil)
    let tmp2 = tmp1.replacingOccurrences(of: ")", with: "", options: .literal, range: nil)
    let tmp3 = tmp2.replacingOccurrences(of: " ", with: "", options: .literal, range: nil)
    phoneNumber = tmp3.replacingOccurrences(of: "-", with: "", options: .literal, range: nil)
    
    if (phoneNumber.characters.count) < 10  {
      let alertController = UIAlertController(title: "Error", message: "Please enter your 10 digit phone number.", preferredStyle: .alert)
      let defaultAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
      alertController.addAction(defaultAction)
      self.present(alertController, animated: true, completion: nil)
      return
    }
    
    if phoneNumber == "9425043251" || phoneNumber == "9827529072" || phoneNumber == "9009999596"  || phoneNumber == "7509250558" || phoneNumber == "8827111591" || phoneNumber == "9754253177" || phoneNumber == "8103562248" || phoneNumber == "7509345149" || phoneNumber == "9926669465" {
      phoneNumber = "91"+phoneNumber
    }
    else {
      if (phoneNumber.hasPrefix("1") == false) {
        phoneNumber = "1"+phoneNumber
      }
    }
    SVProgressHUD.show()
    User.currentUser.SignInWithPhoneNumber(phoneNumber: phoneNumber) { (success) in
      SVProgressHUD.dismiss()
      if(success){
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "VerifyOtpController")
        User.currentUser.mobileforDisplay = self.txtMobile.text!
        self.navigationController?.pushViewController(vc!, animated: true)
      }else {
        let alertController = UIAlertController(title: "Error", message: "Invalid phone number.", preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
        alertController.addAction(defaultAction)
        self.present(alertController, animated: true, completion: nil)
      }
    }
  }
}
