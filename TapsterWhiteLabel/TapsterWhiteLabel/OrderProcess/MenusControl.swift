//
//  MenusControl.swift
//  TapsterWhiteLabel
//
//  Created by Mac on 12/10/17.
//  Copyright © 2017 mac. All rights reserved.
//

import UIKit
import ScrollableSegmentedControl


class MenusControl: UIViewController, UITableViewDataSource, UITableViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {

  @IBOutlet weak var viewNavigation: UIView!
  @IBOutlet weak var navImg: UIImageView!
  @IBOutlet weak var tblMenuItems:UITableView!
  @IBOutlet weak var viewTopHeader:UIView!
  @IBOutlet weak var collectionMenu:UICollectionView!
  
  @IBOutlet weak var lblCartCount: UILabel!
  @IBOutlet weak var viewViewCart: UIView!
  @IBOutlet weak var lblTotalPrice: UILabel!
  @IBOutlet weak var viewTableBottom: UIView!
  
  var menuCategories:[MenuCategory]!
  var menuItems:[MenuItem]!
  var selectedIndex:Int = 0
  var comeFrom:String = "Home"
  var orderDetails:[NSDictionary]!
  
  @IBOutlet weak var segmentedControl: ScrollableSegmentedControl!
  
    override func viewDidLoad() {
        super.viewDidLoad()

      self.lblCartCount.layer.cornerRadius =  lblCartCount.frame.width / 2
      self.lblCartCount.layer.masksToBounds =  true
      
        // Do any additional setup after loading the view.
      self.navigationController?.setNavigationBarHidden(true, animated: false)
      self.viewNavigation.backgroundColor = Util.util.hexStringToUIColor(hex: User.currentUser.appColor)
      self.viewViewCart.backgroundColor = Util.util.hexStringToUIColor(hex: User.currentUser.appColor)
      
      self.tblMenuItems.register(UINib.init(nibName: "MenuCell", bundle: nil), forCellReuseIdentifier: "MenuCell")
      self.collectionMenu.register(UINib.init(nibName: "MenuCategoryCell", bundle: nil), forCellWithReuseIdentifier: "MenuCategoryCell")
      
      self.menuCategories = []
      self.menuItems = []
      Cart.cart.venueId = User.currentUser.selectedVenueId
      
      self.collectionMenu.reloadData()
      
      self.GetMenus()
      
      //add observer for updating cart
      NotificationCenter.default.addObserver(self, selector: #selector(self.CartUpdated(withNotification:)), name:AppNotifications.notificationCartUpdated, object: nil)

    }
  
  
    func GetMenus()  {
      
      Util.util.showHUD()
      
      let URLstring = Config.serverUrl+"venuemenuitems/\(User.currentUser.selectedVenueId)"
      //URLstring = "http://54.148.250.99:4000/venuemenuitems/5967a387ad0eb3583b59b137"
      Service.service.get(url:URLstring, completion: { (result) in
        Util.util.hidHUD()
        
        self.menuCategories.removeAll()
        if result.isKind(of:NSDictionary.self) {
          let dataInfo:NSMutableDictionary = NSMutableDictionary(dictionary: result as! NSDictionary)
          print("dataInfo : \(dataInfo)")
          if((dataInfo.value(forKey: "message") as! String) == "ok") {
            let data:[NSDictionary] = dataInfo.value(forKey: "data") as! [NSDictionary]
            for info:NSDictionary in data {
              let menuCategory = MenuCategory()
              menuCategory.title = info.value(forKey: "menuCategory") as! String
              menuCategory.id = info.value(forKey: "menuCategory_id") as! String
              menuCategory.setMenuItems(items: info.value(forKey: "menuitems") as! [NSDictionary])
              self.menuCategories.append(menuCategory)
            }
            self.collectionMenu.reloadData()
            self.setMenuFrame()
            self.filterSelectedMenuCategory();
            if(self.comeFrom == "OrderAgain"){
                self.SetupOrderAgain()
            }
          }
        }
        else {
          print("error \(result)");
        }
      })
    }
  
    func setMenuFrame() {
      var menuWidth:Double = 0
      for i in 0..<self.menuCategories.count {
        let menuCat = self.menuCategories[i]
        menuWidth = menuWidth + menuCat.getSize()
      }
      if (menuWidth < Double(UIScreen.main.bounds.size.width)) {
          var frame:CGRect = self.collectionMenu.frame
          frame.size.width = CGFloat(menuWidth+10)
          self.collectionMenu.frame = frame
          self.collectionMenu.center = self.viewTopHeader.center
          var fc:CGRect = self.collectionMenu.frame
          fc.origin.y = 0
          self.collectionMenu.frame = fc
      }
    }
  
    //filter the menu category
    func filterSelectedMenuCategory() {
      let menuCategory:MenuCategory = self.menuCategories[self.selectedIndex]
      self.menuItems = menuCategory.menuItems
      self.tblMenuItems.reloadData()
    }
  
    //setup Order again 
    func SetupOrderAgain() {
      for i in 0..<self.menuCategories.count {
        let menuCategory:MenuCategory = self.menuCategories[i]
        var menus:[MenuItem] = menuCategory.menuItems
        for j in 0..<menus.count{
          let menu:MenuItem = menus[j]
          for k in 0..<self.orderDetails.count{
            let dictOption:NSDictionary = self.orderDetails[k]
            let sectionName:[NSDictionary] = dictOption.value(forKey: "sectionName") as! [NSDictionary]
            for n in 0..<sectionName.count{
              let dictO:NSDictionary = sectionName[n]
              for l in 0..<menu.sectionItems.count{
                let dict:AddOnItem = menu.sectionItems[l]
                for m in 0..<dict.options.count {
                  let option:AddOnOption = dict.options[m]
                  if(option.addOnName == (dictO.value(forKey: "addOnName") as! String)){
                    option.isSelected = true
                    if(dict.isRequired){
                      dict.isSelected = true
                    }
                  }
                }
              }
            }
          }
        }
      }
      
      for i in 0..<self.menuCategories.count {
        let menuCategory:MenuCategory = self.menuCategories[i]
        var menus:[MenuItem] = menuCategory.menuItems
        for j in 0..<menus.count{
          let menu:MenuItem = menus[j]
          
          for k in 0..<self.orderDetails.count{
            let dictOption:NSDictionary = self.orderDetails[k]
            if(menu._id == dictOption.value(forKey: "id") as! String){
              let cartItem:CartItem = CartItem()
              cartItem.quantity = (dictOption.value(forKey: "count") as! NSNumber).intValue
              cartItem.menuItem = menu
              
              var tPrice:Double = menu.itemPrice
              if(menu.sectionItems.count == 0){
                tPrice = menu.itemPrice
              }else{
                for l in 0..<menu.sectionItems.count {
                  let dict:AddOnItem = menu.sectionItems[l]
                  for m in 0..<dict.options.count {
                    let addOnOption:AddOnOption = dict.options[m]
                    if(addOnOption.isSelected){
                      tPrice = tPrice + addOnOption.price
                    }
                  }
                }
              }
              let totalAmount:Double = tPrice * Double(cartItem.quantity)
              
              cartItem.total = totalAmount
              cartItem.menuItemId = menu._id
              cartItem.updateItemSummary()
              Cart.cart.cartItems.append(cartItem)
            }
          }
        }
      }
      self.UpdateCartInfo()
      self.tblMenuItems.reloadData()
    }
  
    @IBAction func action_back(_ sender: AnyObject){
      self.navigationController?.popViewController(animated: true)
    }

    override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
      self.UpdateCartInfo()
    }
  
    //update cart info via notification
    func CartUpdated(withNotification obj : NSNotification) {
      self.UpdateCartInfo()
    }
    
    func UpdateCartInfo() {
      var fr:CGRect = self.viewTableBottom.frame
      if (Cart.cart.cartItems.count > 0) {
        self.viewViewCart.isHidden = false
        var totalCartAmount:Double = 0.0
        for i in 0..<Cart.cart.cartItems.count {
          let cartObj = Cart.cart.cartItems[i]
          totalCartAmount = totalCartAmount + cartObj.total
        }
        self.lblCartCount.text = "\(Cart.cart.cartItems.count)"
        self.lblTotalPrice.text = String(format: "$%.2f", totalCartAmount)
        fr.size.height = 57
      }else{
        self.viewViewCart.isHidden = true
        fr.size.height = 1
      }
      self.viewTableBottom.frame = fr
      self.tblMenuItems.reloadData()
    }
  
    @IBAction func action_ViewCart(_ sender: AnyObject){
      if (User.currentUser.isLogin) {
        let viewCartControl = self.storyboard?.instantiateViewController(withIdentifier: "ViewCartControl") as! ViewCartControl
        let navControl:UINavigationController = UINavigationController(rootViewController: viewCartControl)
        navControl.modalPresentationStyle = .overCurrentContext
        self.navigationController?.present(navControl, animated: true
          , completion: { })
      }else {
        let accountVC = self.storyboard?.instantiateViewController(withIdentifier: "CreateAccountController") as! CreateAccountController
        let navControl = UINavigationController(rootViewController: accountVC)
        self.present(navControl, animated: true, completion: nil)
      }
    }
  
    //MARK:- UITableView DataSource & Delegate Method
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      let menuItem:MenuItem = self.menuItems[indexPath.row]
      let cell: MenuCell = self.tblMenuItems.dequeueReusableCell(withIdentifier: "MenuCell") as! MenuCell
      cell.selectionStyle = .none
      cell.accessoryType = .none
      cell.lblItemName.text = menuItem.itemName
      cell.lblItemPrice.text = String(format: "$%.2f", menuItem.itemPrice)
      cell.lblItemDesc.text = menuItem.itemDescription
      cell.imgMenuItem.af_setImage(withURL: URL(string:menuItem.imageSmallUrl)!, placeholderImage: UIImage.init(named: "logoVenue"))
      let itemCount:Int = menuItem.CheckAndGetQtyCount()
      if(itemCount > 0){
        cell.lblCount.isHidden = false
        cell.lblCount.text = "\(itemCount)"
      }else{
        cell.lblCount.isHidden = true
      }
      return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
      return  1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      return self.menuItems.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      self.tblMenuItems.deselectRow(at: indexPath, animated: true)
      let menuItem:MenuItem = self.menuItems[indexPath.row]
      let menuDetailControl = self.storyboard?.instantiateViewController(withIdentifier: "MenuDetailControl") as! MenuDetailControl
      menuDetailControl.menuItem = menuItem
      self.navigationController?.pushViewController(menuDetailControl, animated: true)
    }
  
    //Menu category collection view 
  
    // MARK:- Collcation view Delegates
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
      return self.menuCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
      
        let cell: MenuCategoryCell = collectionView.dequeueReusableCell(withReuseIdentifier: "MenuCategoryCell", for: indexPath) as! MenuCategoryCell
        let menuCat = self.menuCategories[indexPath.item]
        cell.lblMenuCategoryName.text = menuCat.title
        cell.lblMenuCategoryName.textColor = (indexPath.row == selectedIndex) ? Util.util.hexStringToUIColor(hex: User.currentUser.appColor) : Util.util.hexStringToUIColor(hex: "#DCDCDC")
        cell.viewUnderLine.backgroundColor = (indexPath.row == selectedIndex) ? Util.util.hexStringToUIColor(hex: User.currentUser.appColor) : Util.util.hexStringToUIColor(hex: "#DCDCDC")
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
      
        let menuCat = self.menuCategories[indexPath.item]
        return CGSize(width:menuCat.getSize(), height: 40)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let menucat = self.menuCategories[indexPath.row]
        self.selectedIndex = indexPath.row
        self.collectionMenu.reloadData()
        self.filterSelectedMenuCategory()
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
