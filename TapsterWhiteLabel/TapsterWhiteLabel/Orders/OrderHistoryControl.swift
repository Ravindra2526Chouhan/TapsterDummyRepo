//
//  OrderHistoryControl.swift
//  TapsterWhiteLabel
//
//  Created by Mac on 12/10/17.
//  Copyright © 2017 mac. All rights reserved.
//

import UIKit

class OrderHistoryControl: UIViewController, UITableViewDelegate, UITableViewDataSource {

  @IBOutlet weak var tblOrders:UITableView!
  @IBOutlet weak var viewNoOrders:UIView!
  @IBOutlet weak var btnPlaceOrder:UIButton!
  
  var Orders:[NSDictionary] = []
  
    override func viewDidLoad() {
        super.viewDidLoad()
      
        self.viewNoOrders.isHidden = true
        // Do any additional setup after loading the view.
        Util.util.setUpNavigation(navControl: self.navigationController!)
        
        self.setUpBackButton()
        self.title = "Order History"

        self.tblOrders.register(UINib.init(nibName: "OrderHistoryCell", bundle: nil), forCellReuseIdentifier: "OrderHistoryCell")
      
        self.btnPlaceOrder.backgroundColor = Util.util.hexStringToUIColor(hex: User.currentUser.appColor)
        UserDefaults.standard.set(false, forKey: "OrderPlaced")
        self.GetOrders()
    }

    override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
      self.navigationController?.isNavigationBarHidden = false
      if(UserDefaults.standard.bool(forKey: "OrderPlaced")){
        UserDefaults.standard.set(false, forKey: "OrderPlaced")
        self.GetOrders()
      }
    }
  
    func GetOrders() {
      Util.util.showHUD()
      let URLstring = Config.serverUrl+"orders"
      Service.service.get(url:URLstring, completion: { (result) in
        Util.util.hidHUD()
        if result.isKind(of:NSDictionary.self) {
          let dataInfo:NSMutableDictionary = NSMutableDictionary(dictionary: result as! NSDictionary)
          //print("dataInfo : \(dataInfo)")
          if((dataInfo.value(forKey: "message") as! String) == "ok") {
            self.Orders = dataInfo.value(forKey: "data") as! [NSDictionary]
          }
          self.viewNoOrders.isHidden = (self.Orders.count > 0) ? true : false
          self.tblOrders.isHidden = (self.Orders.count > 0) ? false : true
          self.tblOrders.reloadData()
        }
        else {
          print("error \(result)");
        }
      })
    }
  
    @IBAction func action_placeOrder(_ sender: AnyObject){
      self.dismiss(animated: true) { }
    }

  
    func action_back(){
      self.navigationController?.popViewController(animated: true)
    }
    
    func setUpBackButton() {
      let backImg: UIImage = UIImage(named: "arrowBack")!
      self.navigationItem.backBarButtonItem?.tintColor = UIColor.clear
      self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: backImg, style: .plain, target: self, action:#selector(action_back))
    }

    //MARK:- UITableView DataSource & Delegate Method
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      let cell: OrderHistoryCell = self.tblOrders.dequeueReusableCell(withIdentifier: "OrderHistoryCell") as! OrderHistoryCell
      cell.selectionStyle = .none
      let dictOrder:NSDictionary = self.Orders[indexPath.section]
      cell.lblVenue.text = dictOrder.value(forKeyPath: "venue.name") as? String
      let strPrice = NSString(format: "%0.2f", dictOrder.value(forKey: "price") as! Double)
      cell.lblTotalAmount.text =  "Total $" + (strPrice as String)
      cell.lblTime.text = dictOrder.value(forKeyPath: "venue.Hours") as? String
      let strImg  = dictOrder.value(forKeyPath: "venue.featuredPhotoUrl") as? String
      cell.imgView_main.af_setImage(withURL: URL(string: strImg!)!, placeholderImage: UIImage(named: "logoVenue"))
      cell.lblOrder.text = "Order #"+(dictOrder.value(forKey: "sortOrderNumber") as! String)
      
      let dateString = dictOrder.value(forKey: "orderDate") as! NSString //Date()
      let dateFormatter = DateFormatter()
      dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
      let dateFromString = dateFormatter.date(from: dateString as String)
      dateFormatter.dateFormat = "MM/dd/yyyy 'on' h:mm a"
      cell.lblDate_with_Time.text = "\(dateFormatter.string(from: dateFromString!))"

      cell.orders = dictOrder.value(forKey: "orderDetails") as! [NSDictionary]
      cell.tblMenuItems.reloadData()
      
      cell.btnOrderAgain.tag = indexPath.section
      cell.btnOrderAgain.addTarget(self, action: #selector(action_OrderAgain(_:)), for: UIControlEvents.touchUpInside)
      cell.btnOrderAgain.addTarget(self, action: #selector(action_OrderAgain(_:)), for: UIControlEvents.touchUpOutside)
      
      return cell
    }
  
    func action_OrderAgain(_ sender: AnyObject) {
      let index:Int = sender.tag
      let order:NSDictionary = self.Orders[index]
      
      print(order)
      let venue:Venue = Venue()
      venue._id = order.value(forKeyPath: "venue._id") as! String
      venue.name = order.value(forKeyPath: "venue.name") as! String
      venue.salesTax = 0
      
      Cart.cart.cartItems.removeAll()
      User.currentUser.selectedVenueId = venue._id
      User.currentUser.salesTax = venue.salesTax
      let menusControl = self.storyboard?.instantiateViewController(withIdentifier: "MenusControl") as! MenusControl
      menusControl.comeFrom = "OrderAgain"
      menusControl.orderDetails = order.value(forKey: "orderDetails") as! [NSDictionary]
      self.navigationController?.pushViewController(menusControl, animated: true)
    }
  
    func numberOfSections(in tableView: UITableView) -> Int {
      return  self.Orders.count
    }
  
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      return 1
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
      let order = self.Orders[indexPath.section]
      let orderItems:[NSDictionary] = order.value(forKey: "orderDetails") as! [NSDictionary]
      let menuItemCount:Int = orderItems.count
      return (menuItemCount == 1) ? 430 : CGFloat((430-55) + (menuItemCount * 55))
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
