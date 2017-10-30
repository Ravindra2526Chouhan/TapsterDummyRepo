
//
//  VerifyOtpController.swift
//  TapsterWhiteLabel
//
//  Created by mac on 11/10/17.
//  Copyright © 2017 mac. All rights reserved.
//

import UIKit
import SVProgressHUD

class VerifyOtpController: UIViewController, UITextFieldDelegate {

  @IBOutlet weak var btnNExt: UIButton!
  @IBOutlet weak var btnResendCode: UIButton!
  @IBOutlet weak var txtCode1:UITextField!
  @IBOutlet weak var txtCode2:UITextField!
  @IBOutlet weak var txtCode3:UITextField!
  @IBOutlet weak var txtCode4:UITextField!
  
  var isComeFor = "SignIn"
  
  @IBOutlet weak var btnBack: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
      
      self.title = "Verify Number"
      self.view.backgroundColor = UIColor.white
      self.navigationController?.setNavigationBarHidden(false, animated: false)
      Util.util.setUpNavigation(navControl: self.navigationController!)
      self.addLeftbuttomWithController(controller: self, withCustomView: btnBack)
      
      self.txtCode1.becomeFirstResponder()
      self.btnResendCode.isEnabled = true
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
        let yPos = (self.view.frame.size.height - UIConfig.keyboardHeight - 70.0)
        self.btnNExt.frame = CGRect(x: self.btnNExt.frame.origin.x , y:yPos, width: self.btnNExt.frame.size.width, height: self.btnNExt.frame.size.height)
      }

      self.txtCode1.becomeFirstResponder()
      self.txtCode1.addTarget(self, action: #selector(didChangeText(textField:)), for: .editingChanged)
      self.txtCode2.addTarget(self, action: #selector(didChangeText(textField:)), for: .editingChanged)
      self.txtCode3.addTarget(self, action: #selector(didChangeText(textField:)), for: .editingChanged)
      self.txtCode4.addTarget(self, action: #selector(didChangeText(textField:)), for: .editingChanged)

    }
  
    func didChangeText(textField: UITextField) {
      if textField == self.txtCode1 {
        if (self.txtCode1.text?.characters.count)! == 1 {
          self.txtCode2.becomeFirstResponder()
        }
      }
      if textField == self.txtCode2 {
        if (self.txtCode2.text?.characters.count)! == 1 {
          self.txtCode3.becomeFirstResponder()
        }
      }
      if textField == self.txtCode3 {
        if (self.txtCode3.text?.characters.count)! == 1 {
          self.txtCode4.becomeFirstResponder()
        }
      }
      if textField == self.txtCode4 {
        if (self.txtCode4.text?.characters.count)! == 1 {
          self.txtCode1.becomeFirstResponder()
        }
      }
    }
  
    @IBAction func actionMenuClosed(_ sender: Any) {
      self.navigationController?.popViewController(animated: true)
    }

    @IBAction func action_VerifyOtp(_ sender: Any) {
      
      let otp:String = "\(self.txtCode1.text!)\(self.txtCode2.text!)\(self.txtCode3.text!)\(self.txtCode4.text!)"
      if (otp.characters.count) == 0 || (otp.characters.count) < 4 {
        let alertController = UIAlertController(title: "Error", message: "Please enter 4 digit sms code.", preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
        alertController.addAction(defaultAction)
        self.present(alertController, animated: true, completion: nil)
        return
      }
      SVProgressHUD.show()
      if(self.isComeFor == "SignIn"){
        User.currentUser.VerifyWithOTP(otp: otp) { (success) in
          SVProgressHUD.dismiss()
          if(success){
            self.txtCode1.resignFirstResponder()
            self.txtCode2.resignFirstResponder()
            self.txtCode3.resignFirstResponder()
            self.txtCode4.resignFirstResponder()
            User.currentUser.getUserDefaultCard(completion: { (success) in })
            NotificationCenter.default.post(name: AppNotifications.notificationSignInSuccess, object: nil)
            NotificationCenter.default.post(name: AppNotifications.notificationRegisterAPNS, object: nil)
          }else {
            let alertController = UIAlertController(title: "", message: "Invalid sms code.", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
          }
        }
      }else{
        User.currentUser.VerifySignUp(otp: otp) { (success) in
          SVProgressHUD.dismiss()
          if(success){
            self.txtCode1.resignFirstResponder()
            self.txtCode2.resignFirstResponder()
            self.txtCode3.resignFirstResponder()
            self.txtCode4.resignFirstResponder()
            User.currentUser.getUserDefaultCard(completion: { (success) in })
            NotificationCenter.default.post(name: AppNotifications.notificationSignInSuccess, object: nil)
            NotificationCenter.default.post(name: AppNotifications.notificationRegisterAPNS, object: nil)
          }else {
            let alertController = UIAlertController(title: "", message: "Invalid sms code.", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
          }
        }
      }
    }
    
    @IBAction func action_ResendCode(_ sender: Any) {
      let alert=UIAlertController(title: "Confirm Your Number", message: "We will deliver a verification code to \(User.currentUser.mobileforDisplay)", preferredStyle: UIAlertControllerStyle.alert);
      alert.addAction(UIAlertAction(title: "Resend Code", style: UIAlertActionStyle.default, handler: {(action:UIAlertAction) in
        if(self.isComeFor == "SignIn"){
          SVProgressHUD.show()
          User.currentUser.SignInWithPhoneNumber(phoneNumber: User.currentUser.mobile) { (success) in
            SVProgressHUD.dismiss()
            if(success){
              //self.view.endEditing(true)
              let alertController = UIAlertController(title: "Success", message: "SMS code sent", preferredStyle: .alert)
              let defaultAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
              alertController.addAction(defaultAction)
              self.present(alertController, animated: true, completion: nil)
            }else {
              let alertController = UIAlertController(title: "Error", message: "Invalid phone number.", preferredStyle: .alert)
              let defaultAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
              alertController.addAction(defaultAction)
              self.present(alertController, animated: true, completion: nil)
            }
          }
        }else{
          SVProgressHUD.show()
          User.currentUser.SignUp(phoneNumber: User.currentUser.mobile,firstName: User.currentUser.fname,lastName: User.currentUser.lname) { (success) in
            SVProgressHUD.dismiss()
            if(success){
              let alertController = UIAlertController(title: "Success", message: "SMS code sent", preferredStyle: .alert)
              let defaultAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
              alertController.addAction(defaultAction)
              self.present(alertController, animated: true, completion: nil)
            }else {
              let alertController = UIAlertController(title: "Error", message: "Invalid phone number.", preferredStyle: .alert)
              let defaultAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
              alertController.addAction(defaultAction)
              self.present(alertController, animated: true, completion: nil)
            }
          }
        }
      }));
      alert.addAction(UIAlertAction(title: "Change Number", style: UIAlertActionStyle.default, handler: {(action:UIAlertAction) in
        print("Change Number")
        self.navigationController?.popViewController(animated: true)
      }));
      present(alert, animated: true, completion: nil);
      
    }
  
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
      guard let text = textField.text else { return true }
      let newLength = text.characters.count + string.characters.count - range.length
      return newLength <= 1 // Bool
    }
}
