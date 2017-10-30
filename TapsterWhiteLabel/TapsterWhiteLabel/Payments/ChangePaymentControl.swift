//
//  ChangePaymentControl.swift
//  TapsterWhiteLabel
//
//  Created by Mac on 12/10/17.
//  Copyright © 2017 mac. All rights reserved.
//

import UIKit
import Stripe
import SVProgressHUD


class ChangePaymentControl: UIViewController,UITextFieldDelegate {

    @IBOutlet weak var viewBase: UIView!
    @IBOutlet weak var textCreditCard: UITextField!
    @IBOutlet weak var textMonthYear: UITextField!
    @IBOutlet weak var textCvv: UITextField!
    @IBOutlet weak var textZip: UITextField!
    @IBOutlet weak var imageCardType: UIImageView!
    @IBOutlet weak var btnSubmit: UIButton!
  
    var cardArray: NSMutableArray!
    var cvvnoSize = 3
    var cardIconDictionary: [String: String]!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
      // Do any additional setup after loading the view.
      Util.util.setUpNavigation(navControl: self.navigationController!)
      
      self.btnSubmit.backgroundColor = Util.util.hexStringToUIColor(hex: User.currentUser.appColor)
      
      self.setUpBackButton()
      self.title = "Change Payment"

      cardIconDictionary = ["Amex": "american express",
                            "DinersClub": "dinersclub",
                            "Discover": "discover",
                            "JCB": "jcb",
                            "Mastercard": "mastercard",
                            "Visa": "visa",
                            "Unknown" : "ic_changeCard"
      ]
      
      let strPath = Bundle.main.path(forResource: "CardList", ofType: "plist")
      let dict = NSDictionary(contentsOfFile: strPath!)
      if let array = dict?.value(forKey: "rexandname") as? NSMutableArray {
        self.cardArray = array
      }
      
      self.viewBase.layer.cornerRadius = 15
      self.viewBase.layer.masksToBounds  = true
      self.viewBase.layer.borderWidth = 1
      self.viewBase.layer.borderColor = Util.util.hexStringToUIColor(hex: Colors.Or).cgColor

      NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
      
      NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden), name:NSNotification.Name.UIKeyboardWillHide, object: nil)

//      self.textCreditCard.addTarget(self, action: #selector(didChangeText(textField:)), for: .editingChanged)
//      self.textMonthYear.addTarget(self, action: #selector(didChangeText(textField:)), for: .editingChanged)
//      self.textCvv.addTarget(self, action: #selector(didChangeText(textField:)), for: .editingChanged)

    }
  
    @objc func keyboardWillShow(sender: NSNotification) {
      let keyboardHeight = (sender.userInfo?[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.height
      //print(keyboardHeight)
      self.btnSubmit.setTitle("Next", for: .normal)
      UIView.animate(withDuration: 0.3, animations: {
      }) { (isDone) in
        self.btnSubmit.frame.origin.y = UIScreen.main.bounds.size.height - (keyboardHeight + 120)
      }
    }
  
    func keyboardWillBeHidden(_ notification: Notification) {
      self.btnSubmit.setTitle("Submit", for: .normal)
      UIView.animate(withDuration: 0.3, animations: {
      }) { (isDone) in
        self.btnSubmit.frame.origin.y = UIScreen.main.bounds.size.height - 120
      }
    }

    func action_back(){
      self.navigationController?.popViewController(animated: true)
    }
    
    func setUpBackButton() {
      let backImg: UIImage = UIImage(named: "arrowBack")!
      self.navigationItem.backBarButtonItem?.tintColor = UIColor.clear
      self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: backImg, style: .plain, target: self, action:#selector(action_back))
    }

    // MARK:- UITextfield Delegate ------
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
      if textField == self.textCvv {
        self.btnSubmit.setTitle("Next", for: .normal)
        let str = string as NSString
        if range.length == 0 && !CharacterSet.decimalDigits.contains(UnicodeScalar(str.character(at: 0))!) {
          return false
        }
        if range.location == cvvnoSize {
          self.textZip.becomeFirstResponder()
          return false
        } else {
          return true
        }
      } else if textField == self.textCreditCard {
        self.perform(#selector(self.detectCreditCard), with: nil, afterDelay: 0.1)
        if range.location == 19 {
          self.textMonthYear.becomeFirstResponder()
          return false
        }
        let str = string as NSString
        if range.length == 0 && !CharacterSet.decimalDigits.contains(UnicodeScalar(str.character(at: 0))!) {
          return false
        }
        if (range.length == 0) && (range.location == 4 || range.location == 9 || range.location == 14) {
          textField.text = "\(textField.text!) \(string)"
          return false
        }
        return true
      } else if textField == self.textMonthYear {
        self.btnSubmit.setTitle("Next", for: .normal)
        if range.location == 5 {
          self.textCvv.becomeFirstResponder()
          return false
        }
        let str = string as NSString
        if (range.length == 0) && !CharacterSet.decimalDigits.contains(UnicodeScalar(str.character(at: 0))!) {
          return false
        }
        if (range.length == 0) && (range.location == 2) {
          textField.text = "\(textField.text!)/\(string)"
          return false
        }
        return true
      } else if textField == self.textZip {
        self.btnSubmit.setTitle("Submit", for: .normal)
        if range.location == 6 {
          return false
        }
        return true
      }
      return true
    }
  
    func didChangeText(textField: UITextField) {
      if textField == self.textCreditCard {
        if (self.textCreditCard.text?.characters.count)! == 16 {
          self.textMonthYear.becomeFirstResponder()
        }
      }
      if textField == self.textMonthYear {
        if (self.textMonthYear.text?.characters.count)! == 5 {
          self.textCvv.becomeFirstResponder()
        }
      }
      if textField == self.textCvv {
        if (self.textCvv.text?.characters.count)! >= 3 {
          self.textZip.becomeFirstResponder()
        }
      }
    }
    func actionChangedCreditCard() {
      
      if self.textCreditCard.text!.trim().isEmpty {
        self.showAlert(title: "", message: "Please enter credit card number.")
        self.textMonthYear.becomeFirstResponder()
      }
      else {
        if Luhn.validate(self.textCreditCard.text) {
          self.detectCreditCard()
          self.textMonthYear.becomeFirstResponder()
        } else {
          self.showAlert(title: "", message: "Please enter valid credit card number.")
        }
      }
    }
    
    func detectCreditCard() {
      let ccType = CreditCardType(number: textCreditCard.text!)
      let type = ccType.description
      cvvnoSize = type == "Amex" ? 4 : 3
      if let imageName = cardIconDictionary[type] {
        self.imageCardType.image = UIImage(named: imageName)
      } else {
        self.imageCardType.image = UIImage(named: "ic_changeCard")
      }
    }
    
    func actionChangedCVV() {
      let cvvno: NSString = self.textCvv.text!.trim() as NSString
      if self.textCvv.text!.trim().isEmpty {
        self.showAlert(title: "", message: "Please enter CVV")
        self.textCvv.becomeFirstResponder()
      } else if cvvno.length != self.cvvnoSize {
        self.showAlert(title: "", message: "Please enter valid CVV")
        self.textCvv.becomeFirstResponder()
      } else {
        self.textZip.becomeFirstResponder()
      }
    }
    
    func actionChangedMonthYear() {
      let monthYearNo: NSString = self.textMonthYear.text!.replacingOccurrences(of: "/", with: "") as NSString
      if self.textMonthYear.text!.trim().isEmpty {
        self.showAlert(title: "", message: "Please enter a month and year in forma MM/YY")
        self.textMonthYear.becomeFirstResponder()
      } else if monthYearNo.length != 4 {
        self.showAlert(title: "", message: "Please enter a valid MM/YY")
        self.textMonthYear.becomeFirstResponder()
      } else {
        self.textCvv.becomeFirstResponder()
      }
    }
  
    @IBAction func actionSaveCard(_ sender: Any){
      if self.textCreditCard.text!.trim().isEmpty {
        self.showAlert(title: "", message: "Please enter Credit Card number")
        self.textCreditCard.becomeFirstResponder()
      }else if self.textMonthYear.text!.trim().isEmpty
      {
        self.showAlert(title: "", message: "Please enter MM/YY")
        self.textMonthYear.becomeFirstResponder()
      }else if self.textCvv.text!.trim().isEmpty
      {
        self.showAlert(title: "", message: "Please enter CVV")
        self.textCvv.becomeFirstResponder()
      }else if self.textZip.text!.trim().isEmpty
      {
        self.showAlert(title: "", message: "Please enter ZIP code")
        self.textZip.becomeFirstResponder()
      }else
      {
        self.stripeToken()
      }
      print("Save Card****")
    }
    //payment methods
    func stripeToken() {
      let cardParams = STPCardParams()
      cardParams.number =  textCreditCard.text // "4242424242424242"
      let strmonth = textMonthYear.text!.components(separatedBy: "/").first
      let stryear = textMonthYear.text!.components(separatedBy: "/").last
      cardParams.expMonth = UInt(strmonth!)! //10
      cardParams.expYear = UInt("20" + stryear!)!//2018
      cardParams.cvc = textCvv.text//"123"
      
      Util.util.showHUD()
      STPAPIClient.shared().createToken(withCard: cardParams) { (token, error) in
        Util.util.hidHUD()
        if let error = error {
          // show the error to the user
          print("STRIPE Error : \(error.localizedDescription)")
          self.showAlert(title: "", message: error.localizedDescription)
          if(error.localizedDescription == "Your card's number is invalid"){
            self.textCreditCard.becomeFirstResponder()
          }
        }
        else if let token = token {
          //print("GOOD**STRIPE token \(token) ")
          
          let strtoken = "\(token)"
          let parmeters = ["token":strtoken];
          let url = Config.serverUrl+"payment-methods"
          Service().post(url: url, parameters: parmeters) { (result) in
            if result.isKind(of:NSDictionary.self) {
              let dataInfo = NSMutableDictionary(dictionary: result as! NSDictionary)
              //print("dataInfo++++++++====\(dataInfo)")
              if((dataInfo.value(forKey: "message") as! String) == "ok") {
                UserDefaults.standard.set(true, forKey: "cardupdated")
                self.navigationController?.popViewController(animated: true)
              }
              else {
                if let message = dataInfo.value(forKey: "message") {
                  self.showAlert(title: "", message: message as! String)
                }
              }
            }else {
              print("error***\(result)");
            }
          }
        }
      }
    }
    
    func applePayAvailable() {
      
      let paymentNetworks = [PKPaymentNetwork.amex, PKPaymentNetwork.masterCard, PKPaymentNetwork.visa]
      if PKPaymentAuthorizationViewController.canMakePayments(usingNetworks: paymentNetworks) {
        print("Apple pay is available YES .....")
      }
      else {
        print("Apple pay is available NO .......")
      }
    }
    
    func applePayTapped() {
      //https://www.spaceotechnologies.com/how-to-set-up-apple-pay-using-stripe-tutorial/
      
      let paymentRequest = Stripe.paymentRequest(withMerchantIdentifier: STPPaymentConfiguration.shared().appleMerchantIdentifier!)
      // Configure the line items on the payment sheet
      paymentRequest.paymentSummaryItems = [
        PKPaymentSummaryItem(label: "Fancy hat", amount: NSDecimalNumber(string: "50.00")),
        // the final line should represent your company; it'll be prepended with the word "Pay" (i.e. "Pay iHats, Inc $50")
        PKPaymentSummaryItem(label: "iHats, Inc", amount: NSDecimalNumber(string: "50.00")),
      ]
      // To be continued
      if Stripe.canSubmitPaymentRequest(paymentRequest)
      {
        let paymentAuthorizationVC = PKPaymentAuthorizationViewController(paymentRequest: paymentRequest)
        //            paymentAuthorizationVC.delegate = self
        paymentAuthorizationVC.delegate = self as! PKPaymentAuthorizationViewControllerDelegate
        self.present(paymentAuthorizationVC, animated: true, completion: nil)
      }else
      {
        print("Apple pay is not configured properly.")
        self.showAlert(title: "", message: "Apple pay is not configured properly.")
      }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
