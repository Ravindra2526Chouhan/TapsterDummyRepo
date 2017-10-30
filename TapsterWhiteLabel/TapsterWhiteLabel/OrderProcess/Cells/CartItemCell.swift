//
//  CartItemCell.swift
//  TapsterWhiteLabel
//
//  Created by Mac on 23/10/17.
//  Copyright © 2017 mac. All rights reserved.
//

import UIKit

class CartItemCell: UITableViewCell {

    @IBOutlet weak var lblQty:UILabel!
    @IBOutlet weak var lblMenuName:UILabel!
    @IBOutlet weak var lblSubTitle:UILabel!
    @IBOutlet weak var lblTotal:UILabel!
    @IBOutlet weak var viewSeperator:UIView!
  
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
