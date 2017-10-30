//
//  ViewCartControl.swift
//  TapsterWhiteLabel
//
//  Created by Mac on 22/10/17.
//  Copyright © 2017 mac. All rights reserved.
//

import UIKit
import Stripe
import SVProgressHUD
import Alamofire

class ViewCartControl: UIViewController, UITableViewDataSource, UITableViewDelegate, PKPaymentAuthorizationViewControllerDelegate {

    @IBOutlet weak var viewMainCart:UIView!
    @IBOutlet weak var tblCartItems:UITableView!
  
    //tips 
    @IBOutlet weak var lblHeader:UILabel!
  
    //total billing 
    @IBOutlet weak var lblSubTotal:UILabel!
    @IBOutlet weak var lblSalesTax:UILabel!
    @IBOutlet weak var lblServiceFee:UILabel!
    @IBOutlet weak var lblTotal:UILabel!
  
    //service fee label 
    @IBOutlet weak var lblServiceFeeDisplay:UILabel!
  
    //btnCard
    @IBOutlet weak var btnCardNumber:UIButton!
  
  
    //buttons 
    @IBOutlet weak var btnPlaceOrder:UIButton!
    @IBOutlet weak var btnApplePay:UIButton!
  
    //Service fee buttons
    @IBOutlet weak var btnServiceFee0:UIButton!
    @IBOutlet weak var btnServiceFee10:UIButton!
    @IBOutlet weak var btnServiceFee15:UIButton!
    @IBOutlet weak var btnServiceFee20:UIButton!
  
  
    @IBOutlet weak var scrollView:UIScrollView!
    @IBOutlet weak var viewOrderBilling:UIView!
    @IBOutlet weak var viewOrderPlaced:UIView!
  
    @IBOutlet weak var lblOrderPlacedTo:UILabel!
    @IBOutlet weak var imgComplete:UIImageView!
  
    var arrServicefees:[ServiceFee] = []
    var isStripe:Bool = true
    var paymentSucceededAppleToken:String = ""
  
    override func viewDidLoad() {
        super.viewDidLoad()

      self.navigationController?.isNavigationBarHidden = true
      // Do any additional setup after loading the view.
      self.btnPlaceOrder.backgroundColor = Util.util.hexStringToUIColor(hex: User.currentUser.appColor)
      viewMainCart.layer.cornerRadius =  8.0
      viewMainCart.layer.masksToBounds =  true
      
      self.setUpScrollView()
      self.tblCartItems.register(UINib.init(nibName: "CartItemCell", bundle: nil), forCellReuseIdentifier: "CartItemCell")
      
      self.lblHeader.text = "Your Order"
      self.lblOrderPlacedTo.textColor = Util.util.hexStringToUIColor(hex: User.currentUser.appColor)
      
      self.imgComplete.image = UIImage(named: "complete")
      self.imgComplete.image = self.imgComplete.image!.withRenderingMode(.alwaysTemplate)
      self.imgComplete.tintColor = Util.util.hexStringToUIColor(hex: User.currentUser.appColor)

      
      //update the button title as cart item already exits into memory
      for i in 0..<4 {
        let serviceFee:ServiceFee = ServiceFee()
        if(i == 0){
          serviceFee.percent = 0
          serviceFee.isSelected = true
        }
        if(i == 1){ serviceFee.percent = 10 }
        if(i == 2){ serviceFee.percent = 15 }
        if(i == 3){ serviceFee.percent = 20 }
        self.arrServicefees.append(serviceFee)
      }
      
      //update order totals
      self.UpdateOrderBilling()
      
      DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
        self.view.backgroundColor = UIColor.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.7)
      }
      
      //check apply pay available or not into user device
      self.applePayAvailable()
      
      //get cards
      self.GetCards()
    }
    override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
      self.navigationController?.isNavigationBarHidden = true
      let isCardUpdated = UserDefaults.standard.bool(forKey: "cardupdated")
      if(isCardUpdated){
        UserDefaults.standard.set(false, forKey: "cardupdated")
        User.currentUser.getUserDefaultCard { (success) in
          if(success){
            self.GetCards()
          }
        }
      }
    }
  
    func GetCards() {
      
      self.btnCardNumber.setTitle("   Loading Cards...  ", for: .normal)
      User.currentUser.getUserDefaultCard { (success) in
        if(success){
          if(User.currentUser.defaultCard != nil){
            self.btnCardNumber.setTitle("   ****  \(User.currentUser.defaultCard.last4)", for: .normal)
            var brand = User.currentUser.defaultCard.brand
            brand = brand.lowercased()
            brand = brand.trim()
            self.btnCardNumber.setImage(UIImage(named: brand), for: .normal)
          } else {
            self.btnCardNumber.setTitle("   Add Card", for: .normal)
            self.btnCardNumber.setImage(UIImage(named: "ic_changeCard"), for: .normal)
          }
        }
      }
    }
  
    @IBAction func action_ChangeCard(_ sender: AnyObject){
      let paymentsControl = self.storyboard?.instantiateViewController(withIdentifier: "PaymentsControl") as! PaymentsControl
      self.navigationController?.pushViewController(paymentsControl, animated: true)
      self.navigationController?.isNavigationBarHidden = false
    }
  
    func setUpScrollView()  {
      let width = UIScreen.main.bounds.size.width
      
      var frBilling:CGRect = self.viewOrderBilling.frame
      frBilling.size.width = width
      self.viewOrderBilling.frame = frBilling
      
      var frPlaced:CGRect = self.viewOrderPlaced.frame
      frPlaced.size.width = width
      frPlaced.origin.x = width+1
      self.viewOrderPlaced.frame = frPlaced
      
      self.scrollView.contentSize = CGSize(width: width*2, height: self.scrollView.frame.size.height)
    }
  
  var SubTotal:Double = 0.0
  var SalesTax:Double = 0.0
  var ServiceFeeAmount:Double = 0.0
  var TotalAmount:Double = 0.0
  var selectedServiceFeeIndex = 0
  
    func UpdateOrderBilling() {

      SubTotal = 0.0
      SalesTax = 0.0
      ServiceFeeAmount = 0.0
      TotalAmount = 0.0
      
      for i in 0..<Cart.cart.cartItems.count {
        let cartObj = Cart.cart.cartItems[i]
        SubTotal = SubTotal + cartObj.total
      }
      SalesTax = (SubTotal * User.currentUser.salesTax.doubleValue)/100
      
      selectedServiceFeeIndex = 0
      for i in 0..<self.arrServicefees.count{
        let serviceFee:ServiceFee = self.arrServicefees[i]
        serviceFee.setServiceFee(subTotalAmount: SubTotal)
        if(serviceFee.isSelected){
          ServiceFeeAmount = serviceFee.serviceFee
          selectedServiceFeeIndex = i
        }
      }
      
      self.lblSubTotal.text = String(format: "$%.2f", SubTotal)
      self.lblServiceFee.text = String(format: "$%.2f", ServiceFeeAmount)
      
      TotalAmount = SubTotal + SalesTax + ServiceFeeAmount
      self.lblTotal.text = String(format: "$%.2f", TotalAmount)
      
      self.btnServiceFee0.layer.borderWidth = 1.0
      self.btnServiceFee0.setTitleColor(Util.util.hexStringToUIColor(hex: "#DCDCDC"), for: .normal)
      self.btnServiceFee0.layer.borderColor = Util.util.hexStringToUIColor(hex: "#DCDCDC").cgColor
      self.btnServiceFee0.setAttributedTitle(self.arrServicefees[0].defaultString, for: .normal)
      
      self.btnServiceFee10.layer.borderWidth = 1.0
      self.btnServiceFee10.setTitleColor(Util.util.hexStringToUIColor(hex: "#DCDCDC"), for: .normal)
      self.btnServiceFee10.layer.borderColor = Util.util.hexStringToUIColor(hex: "#DCDCDC").cgColor
      self.btnServiceFee10.setAttributedTitle(self.arrServicefees[1].defaultString, for: .normal)
      
      self.btnServiceFee15.layer.borderWidth = 1.0
      self.btnServiceFee15.setTitleColor(Util.util.hexStringToUIColor(hex: "#DCDCDC"), for: .normal)
      self.btnServiceFee15.layer.borderColor = Util.util.hexStringToUIColor(hex: "#DCDCDC").cgColor
      self.btnServiceFee15.setAttributedTitle(self.arrServicefees[2].defaultString, for: .normal)
      
      self.btnServiceFee20.layer.borderWidth = 1.0
      self.btnServiceFee20.setTitleColor(Util.util.hexStringToUIColor(hex: "#DCDCDC"), for: .normal)
      self.btnServiceFee20.layer.borderColor = Util.util.hexStringToUIColor(hex: "#DCDCDC").cgColor
      self.btnServiceFee20.setAttributedTitle(self.arrServicefees[3].defaultString, for: .normal)
      
      switch selectedServiceFeeIndex {
        case 0:
          self.btnServiceFee0.layer.borderWidth = 2.0
          self.btnServiceFee0.setTitleColor(Util.util.hexStringToUIColor(hex: User.currentUser.appColor), for: .normal)
          self.btnServiceFee0.layer.borderColor = Util.util.hexStringToUIColor(hex: User.currentUser.appColor).cgColor
          self.lblServiceFeeDisplay.text = "SERVICE FEE (0%)"
          self.btnServiceFee0.setAttributedTitle(self.arrServicefees[0].selectedString, for: .normal)
          break
        case 1:
          self.btnServiceFee10.layer.borderWidth = 2.0
          self.btnServiceFee10.setTitleColor(Util.util.hexStringToUIColor(hex: User.currentUser.appColor), for: .normal)
          self.btnServiceFee10.layer.borderColor = Util.util.hexStringToUIColor(hex: User.currentUser.appColor).cgColor
          self.lblServiceFeeDisplay.text = "SERVICE FEE (10%)"
          self.btnServiceFee10.setAttributedTitle(self.arrServicefees[1].selectedString, for: .normal)
          break
        case 2:
          self.btnServiceFee15.layer.borderWidth = 2.0
          self.btnServiceFee15.setTitleColor(Util.util.hexStringToUIColor(hex: User.currentUser.appColor), for: .normal)
          self.btnServiceFee15.layer.borderColor = Util.util.hexStringToUIColor(hex: User.currentUser.appColor).cgColor
          self.lblServiceFeeDisplay.text = "SERVICE FEE (15%)"
          self.btnServiceFee15.setAttributedTitle(self.arrServicefees[2].selectedString, for: .normal)
          break
        case 3:
          self.btnServiceFee20.layer.borderWidth = 2.0
          self.btnServiceFee20.setTitleColor(Util.util.hexStringToUIColor(hex: User.currentUser.appColor), for: .normal)
          self.btnServiceFee20.layer.borderColor = Util.util.hexStringToUIColor(hex: User.currentUser.appColor).cgColor
          self.lblServiceFeeDisplay.text = "SERVICE FEE (20%)"
          self.btnServiceFee20.setAttributedTitle(self.arrServicefees[3].selectedString, for: .normal)
          break
        default:
          break
      }
      
    }
  
    @IBAction func action_ServiceFee(_ sender: AnyObject){
      let index:Int = sender.tag
      for i in 0..<self.arrServicefees.count{
        let serviceFee:ServiceFee = self.arrServicefees[i]
        serviceFee.isSelected = (i == index) ? true : false
        self.arrServicefees[i] = serviceFee
      }
      
      //update order totals
      self.UpdateOrderBilling()
    }
  
  
    //MARK:- UITableView DataSource & Delegate Method
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      let cell: CartItemCell = self.tblCartItems.dequeueReusableCell(withIdentifier: "CartItemCell") as! CartItemCell
      cell.selectionStyle = .none
      cell.accessoryType = .none
      let cartItem:CartItem = Cart.cart.cartItems[indexPath.row]
      cell.lblMenuName.text = cartItem.menuItem.itemName
      cell.lblQty.text = "\(cartItem.quantity)"
      cell.lblTotal.text = String(format: "$%.2f", cartItem.total)
      cell.lblSubTitle.text = cartItem.itemSummary
      cell.viewSeperator.isHidden = (indexPath.row == (Cart.cart.cartItems.count - 1)) ? true : false
      return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
      return 1
    }
  
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
      if editingStyle == .delete {
        Cart.cart.cartItems.remove(at: indexPath.row)
        //update order totals
        self.UpdateOrderBilling()
        NotificationCenter.default.post(name: AppNotifications.notificationCartUpdated, object: nil)
        self.tblCartItems.deleteRows(at: [indexPath], with: .automatic)
      }
    }
  
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      return Cart.cart.cartItems.count
    }
  
    @IBAction func action_close(_ sender: AnyObject){
      if(Cart.cart.cartItems.count == 0){
        NotificationCenter.default.post(name: AppNotifications.notificationCartUpdated, object: nil)
      }
      self.dismiss(animated: true) {}
    }
  
    @IBAction func action_PlaceOrder(_ sender: AnyObject){
      
      if(Cart.cart.cartItems.count == 0){
        self.showAlert(title: "Error", message: "Your cart not have any items for order. please add some items into cart.")
        return
      }
      if(User.currentUser.defaultCard == nil){
        self.showAlert(title: "Error", message: "Please select a card for payment.")
        return
      }
      self.isStripe = true
      self.PlaceOrder()
    }
  
  func PlaceOrder() {
    var parmeters:Parameters = ["venue":User.currentUser.selectedVenueId,"isStripe":self.isStripe];
    let now = Date()
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
    let dateTime = dateFormatter.string(from: now)
    var secondsFromGMT: Int { return TimeZone.current.secondsFromGMT() }
    let timeInt = secondsFromGMT/60
    let timeZone = String(timeInt)
    parmeters["orderDate"] = dateTime
    parmeters["timezone"] = timeZone
    parmeters["price"] = "\(TotalAmount)"
    let serviceFee:ServiceFee = self.arrServicefees[selectedServiceFeeIndex]
    parmeters["tip"] = ["percentage":"\(serviceFee.percent)","amount":"\(ServiceFeeAmount)"]
    
    // Add Apple Pay token
    if(self.isStripe == false)
    {
      parmeters["rawCharges"] = ["appletoken":paymentSucceededAppleToken]
    }
    
    var orderDetails:[NSMutableDictionary] = []
    
    for i in 0..<Cart.cart.cartItems.count {
      let cartObj = Cart.cart.cartItems[i]
      let menuItem:NSMutableDictionary = NSMutableDictionary()
      menuItem.setValue(cartObj.menuItem._id, forKey: "id")
      menuItem.setValue(cartObj.menuItem.itemName, forKey: "name")
      menuItem.setValue(cartObj.quantity, forKey: "count")
      menuItem.setValue(cartObj.total, forKey: "price")
      
      var sectionNames:[NSMutableDictionary] = []
      for i in 0..<cartObj.menuItem.sectionItems.count{
        let addOnItem:AddOnItem = cartObj.menuItem.sectionItems[i]
        for j in 0..<addOnItem.options.count {
          let option:AddOnOption = addOnItem.options[j]
          if(option.isSelected){
            let objOption:NSMutableDictionary = NSMutableDictionary()
            objOption.setValue(option.addOnName, forKey: "addOnName")
            objOption.setValue(option.isRequired, forKey: "isRequired")
            objOption.setValue(option.price, forKey: "price")
            sectionNames.append(objOption)
          }
        }
      }
      menuItem.setValue(sectionNames, forKey: "sectionName")
      orderDetails.append(menuItem)
    }
    parmeters["orderDetails"] = orderDetails
    print(parmeters)
    
    SVProgressHUD.show()
    let url = Config.serverUrl+"orders"
    Service().post(url: url, parameters: parmeters) { (result) in
      if result.isKind(of:NSDictionary.self) {
        //print(result);
        SVProgressHUD.dismiss()
        if result.isKind(of:NSDictionary.self) {
          let dataInfo:NSMutableDictionary = NSMutableDictionary(dictionary: result as! NSDictionary)
          if((dataInfo.value(forKey: "message") as! String) == "ok") {
            let results = dataInfo.value(forKey: "data") as! NSDictionary
            
            self.lblHeader.text = "Order Placed"
            let width = UIScreen.main.bounds.size.width
            let scrollto:CGPoint = CGPoint(x: width+1, y: 0)
            self.scrollView.setContentOffset(scrollto, animated: true)
            
            //set order details
            let fullName:String = "\(User.currentUser.fname) \(User.currentUser.lname)"
            let orderNumber = results.value(forKey:"sortOrderNumber") as! String //sortOrderNumber
            self.lblOrderPlacedTo.text = "\(fullName)\n Order \(orderNumber)"
            
            Cart.cart.cartItems.removeAll()
            UserDefaults.standard.set(true, forKey: "OrderPlaced")
            NotificationCenter.default.post(name: AppNotifications.notificationCartUpdated, object: nil)
          }
          else {
            //print("CCARD NOT ADDED")
            self.showAlert(title: "Error", message:(dataInfo.value(forKey: "message") as! String))
          }
        }
      }else {
        print("error \(result)");
      }
    }
  }
  
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  

  func applePayAvailable() {
    let paymentNetworks = [PKPaymentNetwork.amex, PKPaymentNetwork.masterCard, PKPaymentNetwork.visa]
    if PKPaymentAuthorizationViewController.canMakePayments(usingNetworks: paymentNetworks) {
      print("Apple pay is available YES .....")
      
    }
    else {
      print("Apple pay is available NO .......")
      self.btnApplePay.isHidden = true
      self.btnPlaceOrder.frame = CGRect(x: 0, y: self.btnPlaceOrder.frame.origin.y, width: self.view.frame.size.width, height: 55)
    }
  }
  
  @IBAction func action_PayUsingApplePay(_ sender: AnyObject) {
    
    let paymentRequest = Stripe.paymentRequest(withMerchantIdentifier: STPPaymentConfiguration.shared().appleMerchantIdentifier!, country: "US", currency: "USD")
    paymentRequest.merchantCapabilities = [PKMerchantCapability.capability3DS] // PKMerchantCapability.capabilityEMV,
    paymentRequest.supportedNetworks = [PKPaymentNetwork.amex,PKPaymentNetwork.masterCard,PKPaymentNetwork.visa,PKPaymentNetwork.discover]
    paymentRequest.paymentSummaryItems = [
    PKPaymentSummaryItem(label: "SUBTOTAL", amount: NSDecimalNumber(value: SubTotal)),
    PKPaymentSummaryItem(label: "SALES TAX", amount: NSDecimalNumber(value:SalesTax)),
    PKPaymentSummaryItem(label: "TIP", amount: NSDecimalNumber(value: ServiceFeeAmount)),
    PKPaymentSummaryItem(label: "\(User.currentUser.selectedVenue.name) on \(User.currentUser.vendorGroupName)", amount: NSDecimalNumber(value: TotalAmount))
    ]
    // To be continued
    if(Stripe.canSubmitPaymentRequest(paymentRequest))
    {
      let paymentAuthorizationVC = PKPaymentAuthorizationViewController(paymentRequest: paymentRequest)
      paymentAuthorizationVC.delegate = self
      self.present(paymentAuthorizationVC, animated: true, completion: nil)
    }else
    {
      print("Apple pay is not configured properly......")
      self.showAlert(title: "", message: "Apple pay is not configured properly.")
    }
}
  var paymentSucceeded:Bool = false
  func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, completion: @escaping (PKPaymentAuthorizationStatus) -> Void) {
    STPAPIClient.shared().createToken(with: payment, completion: { (token, error) in
      
      print("GOOD : token : \(String(describing: token?.tokenId)))")
      if error != nil {
        completion(.failure)
        self.paymentSucceededAppleToken = ""
        print("FAIL")
      } else {
        self.paymentSucceeded = true
        let appleToken = token?.tokenId   //String(describing: token))
        self.paymentSucceededAppleToken = appleToken!
        completion(.success)
        print("SUCESS")
      }
    })
  }
  
  func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
    // Dismiss payment authorization view controller
    dismiss(animated: true, completion: {
      if (self.paymentSucceeded) {
        // Show a receipt page...
        self.isStripe = false
        self.PlaceOrder()
      }
    })
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
