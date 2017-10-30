//
//  CardCell.swift
//  TapsterWhiteLabel
//
//  Created by Mac on 12/10/17.
//  Copyright © 2017 mac. All rights reserved.
//

import UIKit

class CardCell: UITableViewCell {

    @IBOutlet weak var lblCardNumber:UILabel!
    @IBOutlet weak var imgCardIcon:UIImageView!
  
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
      
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
