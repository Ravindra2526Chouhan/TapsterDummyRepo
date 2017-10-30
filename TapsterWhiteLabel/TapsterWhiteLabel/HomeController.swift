//
//  HomeController.swift
//  TapsterWhiteLabel
//
//  Created by mac on 11/10/17.
//  Copyright © 2017 mac. All rights reserved.
//

import UIKit
import SVProgressHUD

class HomeController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var viewNavigation: UIView!
    @IBOutlet weak var navImg: UIImageView!
    @IBOutlet weak var btnMenu: UIButton!
    @IBOutlet weak var tableVW: UITableView!
    var venues:[Venue] = []
  
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableVW.dataSource = self
        self.tableVW.delegate = self
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        self.tableVW.register(UINib.init(nibName: "HomeTableCell", bundle: nil), forCellReuseIdentifier: "HomeTableCell")
      
        self.viewNavigation.backgroundColor = Util.util.hexStringToUIColor(hex: User.currentUser.appColor)
        self.GetVenues()
      
      if(User.currentUser.isLogin){
        NotificationCenter.default.post(name: AppNotifications.notificationRegisterAPNS, object: nil)
      }
    }

    func GetVenues() {
      SVProgressHUD.show()
      let url = Config.serverUrl+"venues"
      Service().get(url: url) { (result) in
        SVProgressHUD.dismiss()
        if result.isKind(of:NSDictionary.self) {
          let dataInfo:NSMutableDictionary = NSMutableDictionary(dictionary: result as! NSDictionary)
          if((dataInfo.value(forKey: "message") as! String) == "ok") {
            print(dataInfo)
            let results:NSArray = dataInfo.value(forKey: "data") as! NSArray
            for i in 0..<results.count {
              let venue:Venue = Venue(infoData: results.object(at: i) as! NSDictionary)
              self.venues.append(venue)
            }
            self.tableVW.reloadData()
          }
          else {
            print("CCARD NOT ADDED")
          }
        }
      }
    }
    @IBAction func actionMenuBtn(_ sender: Any) {
        let settingVC = self.storyboard?.instantiateViewController(withIdentifier: "SettingViewController") as! SettingViewController
        let navControl = UINavigationController(rootViewController: settingVC)
        self.present(navControl, animated: true, completion: nil)
    }
    
    //MARK:- UITableView DataSource & Delegate Method
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: HomeTableCell = self.tableVW.dequeueReusableCell(withIdentifier: "HomeTableCell") as! HomeTableCell
        cell.selectionStyle = .none
        let venue:Venue = self.venues[indexPath.row]
        cell.lblVenueName.text = venue.name
        cell.lblVenueAddress.text = "\(venue.address), \(venue.city), \(venue.state)"
        cell.lblVenueTime.text = venue.hours
        cell.imgFeatured.af_setImage(withURL: URL(string:venue.featuredPhotoUrl)!, placeholderImage: UIImage.init(named: "logoVenue"))
        return cell
    }
  
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      self.tableVW.deselectRow(at: indexPath, animated: true)
      let venue:Venue = self.venues[indexPath.row]
        if(Cart.cart.cartItems.count > 0) {
          if(Cart.cart.venueId != "" && Cart.cart.venueId != venue._id){
            //ask user that you will lose your cart items
            let alert = UIAlertController(title: "Are you sure?", message: "You already have some items into cart.By switching the venue will lose all your current cart items.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "YES", style: .default, handler: { (action) in
              Cart.cart.cartItems.removeAll()
              User.currentUser.selectedVenueId = venue._id
              User.currentUser.salesTax = venue.salesTax
              User.currentUser.selectedVenue = venue
              let menusControl = self.storyboard?.instantiateViewController(withIdentifier: "MenusControl") as! MenusControl
              self.navigationController?.pushViewController(menusControl, animated: true)
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
          }else {
            User.currentUser.selectedVenueId = venue._id
            User.currentUser.salesTax = venue.salesTax
            User.currentUser.selectedVenue = venue
            let menusControl = self.storyboard?.instantiateViewController(withIdentifier: "MenusControl") as! MenusControl
            self.navigationController?.pushViewController(menusControl, animated: true)
          }
        }else{
          User.currentUser.selectedVenueId = venue._id
          User.currentUser.salesTax = venue.salesTax
          User.currentUser.selectedVenue = venue
          let menusControl = self.storyboard?.instantiateViewController(withIdentifier: "MenusControl") as! MenusControl
          self.navigationController?.pushViewController(menusControl, animated: true)
        }
    }
  
    func actionPickup(_ sender: AnyObject) {
      let index:Int = sender.tag
      let venue:Venue = self.venues[index]
      User.currentUser.selectedVenueId = venue._id
      User.currentUser.salesTax = venue.salesTax
      let menusControl = self.storyboard?.instantiateViewController(withIdentifier: "MenusControl") as! MenusControl
      self.navigationController?.pushViewController(menusControl, animated: true)
    }
  
  
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.venues.count
    }
}
