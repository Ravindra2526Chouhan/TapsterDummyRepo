//
//  MenuDetailControl.swift
//  TapsterWhiteLabel
//
//  Created by Mac on 12/10/17.
//  Copyright © 2017 mac. All rights reserved.
//

import UIKit

class MenuDetailControl: UIViewController, UITableViewDataSource, UITableViewDelegate {

  @IBOutlet weak var viewNavigation: UIView!
  @IBOutlet weak var navImg: UIImageView!
  @IBOutlet weak var tblMenuDetail: UITableView!
  
  @IBOutlet weak var lblItemName: UILabel!
  @IBOutlet weak var lblItemDesc: UILabel!
  @IBOutlet weak var lblItemQty: UILabel!
  @IBOutlet weak var imgMenuItem: UIImageView!
  
  @IBOutlet weak var lblCartCount: UILabel!
  @IBOutlet weak var viewAddToCart: UIView!
  @IBOutlet weak var lblTotalPrice: UILabel!
  @IBOutlet weak var btnAddToCart: UIButton!
  
  var menuItem:MenuItem!
  var menuItemQty:Int = 1
  var totalPrice:Double = 0.0
  
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
      self.navigationController?.setNavigationBarHidden(true, animated: false)
      self.viewNavigation.backgroundColor = Util.util.hexStringToUIColor(hex: User.currentUser.appColor)
      self.viewAddToCart.backgroundColor = Util.util.hexStringToUIColor(hex: User.currentUser.appColor)
      
      self.tblMenuDetail.register(UINib.init(nibName: "AddOnOptionCell", bundle: nil), forCellReuseIdentifier: "AddOnOptionCell")
      
      lblCartCount.layer.cornerRadius =  lblCartCount.frame.width / 2
      lblCartCount.layer.masksToBounds =  true

      
      self.lblItemDesc.text = self.menuItem.itemDescription
      self.lblItemQty.text = "1"
      self.imgMenuItem.af_setImage(withURL: URL(string:menuItem.imageUrl)!, placeholderImage: UIImage.init(named: "logoVenue"))
      
      self.calculateTotalAmount()
      
      //update the button title as cart item already exits into memory
      for i in 0..<Cart.cart.cartItems.count {
        let cartObj = Cart.cart.cartItems[i]
        if(cartObj.menuItemId == self.menuItem._id){
          self.btnAddToCart.setTitle("Update Cart", for: .normal)
          self.menuItem = cartObj.menuItem
          self.menuItemQty = cartObj.quantity
          self.lblItemQty.text = "\(self.menuItemQty)"
          self.lblCartCount.text = "\(Cart.cart.cartItems.count)"
          self.lblCartCount.isHidden = (Cart.cart.cartItems.count == 0) ? true : false
          self.calculateTotalAmount()
          self.tblMenuDetail.reloadData()
          break
        }
      }
      
      self.lblCartCount.text = "\(Cart.cart.cartItems.count)"
      self.lblCartCount.isHidden = (Cart.cart.cartItems.count == 0) ? true : false

    }

  @IBAction func action_back(_ sender: AnyObject){
    self.navigationController?.popViewController(animated: true)
  }

  
    @IBAction func actionUpdateQty(_ sender: AnyObject){
      let tag = sender.tag
      if(tag == 1){
        if(self.menuItemQty > 1){
          self.menuItemQty = self.menuItemQty - 1
        }
      }
      if(tag == 2){
        self.menuItemQty = self.menuItemQty + 1
      }
      self.lblItemQty.text = "\(self.menuItemQty)"
      self.lblCartCount.text = "\(Cart.cart.cartItems.count)"
      self.lblCartCount.isHidden = (Cart.cart.cartItems.count == 0) ? true : false
      self.calculateTotalAmount()
    }
  
    //MARK:- UITableView DataSource & Delegate Method
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      let cell: AddOnOptionCell = self.tblMenuDetail.dequeueReusableCell(withIdentifier: "AddOnOptionCell") as! AddOnOptionCell
      cell.selectionStyle = .none
      cell.accessoryType = .none
      
      let dict:AddOnItem = self.menuItem.sectionItems[indexPath.section]
      let dictAddon:AddOnOption = dict.options[indexPath.row]
      cell.lblAddOnName.text = dictAddon.addOnName
      cell.lblAddOnPrice.text = String(format: "+$%.2f", dictAddon.price)
      
      if(dict.isRequired){
        if(dictAddon.isSelected){
          cell.imgIcon.image = UIImage(named: "radio_selected")
          cell.imgIcon.image = cell.imgIcon.image!.withRenderingMode(.alwaysTemplate)
          cell.imgIcon.tintColor = Util.util.hexStringToUIColor(hex: User.currentUser.appColor)
        }else{
          cell.imgIcon.image = UIImage(named: "radio_unselected")
        }
      }else{
        if(dictAddon.isSelected){
          cell.imgIcon.image = UIImage(named: "check_selected")
          cell.imgIcon.image = cell.imgIcon.image!.withRenderingMode(.alwaysTemplate)
          cell.imgIcon.tintColor = Util.util.hexStringToUIColor(hex: User.currentUser.appColor)
        }else{
          cell.imgIcon.image = UIImage(named: "check_unselected")
        }
      }
      return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
      return  self.menuItem.sectionItems.count
    }
    
  //  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?{
  //    let dict:NSDictionary = self.menuItem.sectionItems[section]
  //    return dict.value(forKey: "sectionName") as! String
  //  }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?{
      let dict:AddOnItem = self.menuItem.sectionItems[section]
      let header:MenuHeaderView = MenuHeaderView.instanceFromNib()
      if(dict.isRequired){
        header.lblSectionName.text = "Required Options"
      }else{
        header.lblSectionName.text = "Optional Options"
      }
      return header
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      let dict:AddOnItem = self.menuItem.sectionItems[section]
      return dict.options.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      self.tblMenuDetail.deselectRow(at: indexPath, animated: true)
      
      let dict:AddOnItem = self.menuItem.sectionItems[indexPath.section]
      if(dict.isRequired){
        for i in 0..<dict.options.count {
          let option:AddOnOption = dict.options[i]
          option.isSelected = false
          dict.options[i] = option
        }
        let dictAddon:AddOnOption = dict.options[indexPath.row]
        dictAddon.isSelected = true
        dict.options[indexPath.row] = dictAddon
        dict.isSelected = true
        self.menuItem.sectionItems[indexPath.section] = dict
      }else {
          let dictAddon:AddOnOption = dict.options[indexPath.row]
          dictAddon.isSelected = !dictAddon.isSelected
          dict.options[indexPath.row] = dictAddon
      }
      self.tblMenuDetail.reloadData()
      self.calculateTotalAmount()
    }
  
    @IBAction func action_AddToCart(_ sender: AnyObject) {
      var isAllGood:Bool = true
      for i in 0..<self.menuItem.sectionItems.count {
        let dict:AddOnItem = self.menuItem.sectionItems[i]
        if(dict.isRequired){
          if(dict.isSelected == false){
           self.showAlert(title: "Alert", message: "All required options must be selected.")
           isAllGood = false
           break
          }
        }
      }
      if(isAllGood) {
        
        let cartItem:CartItem = CartItem()
        cartItem.quantity = self.menuItemQty
        cartItem.menuItem = self.menuItem
        cartItem.total = self.totalPrice
        cartItem.menuItemId = self.menuItem._id
        cartItem.updateItemSummary()
        
        var isCartItemAlreadyExits = false
        for i in 0..<Cart.cart.cartItems.count {
          let cartObj = Cart.cart.cartItems[i]
          if(cartObj.menuItemId == self.menuItem._id){
            isCartItemAlreadyExits = true
            Cart.cart.cartItems[i] = cartItem
            break
          }
        }
        self.lblCartCount.text = "\(Cart.cart.cartItems.count)"
        self.lblCartCount.isHidden = (Cart.cart.cartItems.count == 0) ? true : false

        if(isCartItemAlreadyExits){
          //cart item already exits so we will udpate the cart Item with new qty and options selected
          //self.showAlert(title: "Alert", message: "Item updated successfully into cart.")
        }else{
          Cart.cart.cartItems.append(cartItem)
          //self.showAlert(title: "Alert", message: "Item added successfully into cart.")
        }
        self.navigationController?.popViewController(animated: true)
      }
    }
  
    func calculateTotalAmount()  {
      
      var tPrice:Double = self.menuItem.itemPrice
      for i in 0..<self.menuItem.sectionItems.count {
        let dict:AddOnItem = self.menuItem.sectionItems[i]
        for j in 0..<dict.options.count {
          let addOnOption:AddOnOption = dict.options[j]
          if(addOnOption.isSelected){
            tPrice = tPrice + addOnOption.price
          }
        }
      }
      if(self.menuItem.sectionItems.count == 0){
        tPrice = self.menuItem.itemPrice
      }
      let totalAmount:Double = tPrice * Double(self.menuItemQty)
      self.lblTotalPrice.text = String(format: "$%.2f", totalAmount)
      self.totalPrice = tPrice * Double(self.menuItemQty)
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
