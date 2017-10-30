//
//  OrderHistoryCell.swift
//  TapsterWhiteLabel
//
//  Created by Mac on 12/10/17.
//  Copyright © 2017 mac. All rights reserved.
//

import UIKit

class OrderHistoryCell: UITableViewCell, UITableViewDataSource, UITableViewDelegate {

  @IBOutlet weak var mainView_Container: UIView!
  @IBOutlet weak var imgView_main: UIImageView!
  @IBOutlet weak var venueDetail_View: UIView!
  @IBOutlet weak var lblVenue: UILabel!
  @IBOutlet weak var lblTime: UILabel!
  @IBOutlet weak var lblDate_with_Time: UILabel!
  @IBOutlet weak var lblOrder: UILabel!
  @IBOutlet weak var tblMenuItems: UITableView!
  @IBOutlet weak var lblTotalAmount: UILabel!
  @IBOutlet weak var viewBottomContainer: UIView!
  @IBOutlet weak var btnOrderAgain: UIButton!
  @IBOutlet weak var lbltotal: UILabel!

  var orders:[NSDictionary] = []
  
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
      self.btnOrderAgain.backgroundColor = Util.util.hexStringToUIColor(hex: User.currentUser.appColor)
      mainView_Container.layer.shadowColor = Util.util.hexStringToUIColor(hex: "#DCDCDC").cgColor
      mainView_Container.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
      mainView_Container.layer.shadowOpacity = 0.8
      mainView_Container.layer.shadowRadius = 2.0
      mainView_Container.layer.masksToBounds =  false

      self.tblMenuItems.register(UINib.init(nibName: "CartItemCell", bundle: nil), forCellReuseIdentifier: "CartItemCell")
      
    }
  
    //MARK:- UITableView DataSource & Delegate Method
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      let cell: CartItemCell = self.tblMenuItems.dequeueReusableCell(withIdentifier: "CartItemCell") as! CartItemCell
      cell.selectionStyle = .none
      cell.accessoryType = .none
      let item:NSDictionary = orders[indexPath.row]
      
      let itemName:String = item.value(forKey: "name") as! String
      let countNum:NSNumber = item.value(forKey: "count") as! NSNumber
      let priceNum:NSNumber = item.value(forKey: "price") as! NSNumber
      cell.lblMenuName.text = itemName
      cell.lblQty.text = "\(countNum.intValue)"
      cell.lblTotal.text = String(format: "$%.2f", priceNum.floatValue)
      cell.lblSubTitle.text = self.ItemSummary(item: item)
      //cell.viewSeperator.isHidden = (indexPath.row == (orders.count - 1)) ? true : false
      return cell
    }
  
    func ItemSummary(item:NSDictionary) -> String {
      let options:[NSDictionary] = item.value(forKey: "sectionName") as! [NSDictionary]
      var summary:String = ""
      for i in 0..<options.count{
        let dictOption:NSDictionary = options[i]
        let title:String = dictOption.value(forKey: "addOnName") as! String
        summary = summary + title + ", "
      }
      return summary
    }
  
    func numberOfSections(in tableView: UITableView) -> Int {
      return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      return orders.count
    }


    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
