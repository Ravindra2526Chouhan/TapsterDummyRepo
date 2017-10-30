
//
//  SignUpController.swift
//  TapsterWhiteLabel
//
//  Created by mac on 11/10/17.
//  Copyright © 2017 mac. All rights reserved.
//

import UIKit
import SVProgressHUD

class SignUpController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var btnMenu: UIButton!
    @IBOutlet weak var btnSignup: UIButton!
    @IBOutlet weak var txtFirstName: UITextField!
    @IBOutlet weak var txtLastName: UITextField!
    @IBOutlet weak var txtMonth: UITextField!
    @IBOutlet weak var txtDay: UITextField!
    @IBOutlet weak var txtYear: UITextField!
    @IBOutlet weak var txtMobile: UITextField!
  
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Sign Up"
        self.view.backgroundColor = UIColor.white
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        Util.util.setUpNavigation(navControl: self.navigationController!)
        self.addLeftbuttomWithController(controller: self, withCustomView: btnMenu)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:NSNotification.Name.UIKeyboardWillShow, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
      
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideBoard))
        self.view.addGestureRecognizer(tapGesture)
      
        self.btnSignup.backgroundColor = Util.util.hexStringToUIColor(hex: User.currentUser.appColor)
        self.txtFirstName.becomeFirstResponder()
      
    }
    
    func hideBoard() {
        self.view.endEditing(true)
      
    }
    
    @objc func keyboardWillShow(sender: NSNotification) {
      let keyboardHeight = (sender.userInfo?[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.height
      print(keyboardHeight)
      UIView.animate(withDuration: 0.3, animations: {
      }) { (isDone) in
        self.btnSignup.frame.origin.y = UIScreen.main.bounds.size.height - (keyboardHeight + 120)
      }
    }
    
    func keyboardWillBeHidden(sender: NSNotification) {
        UIView.animate(withDuration: 0.3, animations: {
        }) { (isDone) in
            self.btnSignup.frame.origin.y = UIScreen.main.bounds.size.height - 120
        }
    }
    
    @IBAction func actionMenuClosed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == self.txtFirstName {
        }
        else if textField == self.txtLastName {
        }
        else if textField == self.txtMobile {
        }
        return true
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
  
    @IBAction func actionSignup(_ sender: Any) {
      
      if (self.txtFirstName.text?.characters.count)! == 0  {
        let alertController = UIAlertController(title: "Error", message: "Please enter your first name.", preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
        alertController.addAction(defaultAction)
        self.present(alertController, animated: true, completion: nil)
        return
      }
      if (self.txtLastName.text?.characters.count)! == 0 {
        let alertController = UIAlertController(title: "Error", message: "Please enter your last name.", preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
        alertController.addAction(defaultAction)
        self.present(alertController, animated: true, completion: nil)
        return
      }
      if (self.txtMobile.text?.characters.count)! == 0 || (self.txtMobile.text?.characters.count)! < 10  {
        let alertController = UIAlertController(title: "Error", message: "Please enter your 10 digit phone number.", preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
        alertController.addAction(defaultAction)
        self.present(alertController, animated: true, completion: nil)
        return
      }

      var phoneNumber = self.txtMobile.text!
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
      
      let alert = UIAlertController(title: "Verification Method", message: "We will send a verification code to \(self.txtMobile.text!). Please confirm your number.", preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "Send SMS", style: .default, handler: { (action) in
        
        SVProgressHUD.show()
        
        User.currentUser.SignUp(phoneNumber: phoneNumber, firstName: self.txtFirstName.text!, lastName: self.txtLastName.text!) { (success) in
          SVProgressHUD.dismiss()
          if(success){
            let vc:VerifyOtpController = self.storyboard?.instantiateViewController(withIdentifier: "VerifyOtpController") as!VerifyOtpController
            User.currentUser.mobileforDisplay = self.txtMobile.text!
            vc.isComeFor = "SignUp"
            self.navigationController?.pushViewController(vc, animated: true)
          }else{
            self.showAlert(title: "Error", message: "Error in doing signup. Please try again later.")
          }
        }
      }))
      alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
      self.present(alert, animated: true, completion: nil)
      
    }
}
