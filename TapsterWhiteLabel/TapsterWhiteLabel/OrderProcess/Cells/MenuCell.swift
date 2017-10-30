//
//  MenuCell.swift
//  TapsterWhiteLabel
//
//  Created by Mac on 16/10/17.
//  Copyright © 2017 mac. All rights reserved.
//

import UIKit

class MenuCell: UITableViewCell {

  @IBOutlet weak var lblItemName:UILabel!
  @IBOutlet weak var lblItemPrice:UILabel!
  @IBOutlet weak var lblItemDesc:UITextView!
  @IBOutlet weak var imgMenuItem:UIImageView!
  @IBOutlet weak var lblCount:UILabel!
  
  
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
      self.lblCount.backgroundColor = Util.util.hexStringToUIColor(hex: User.currentUser.appColor)
      lblCount.layer.cornerRadius =  lblCount.frame.width / 2
      lblCount.layer.masksToBounds =  true
      
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
