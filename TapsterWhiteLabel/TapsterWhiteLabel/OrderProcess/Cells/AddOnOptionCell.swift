//
//  AddOnOptionCell.swift
//  TapsterWhiteLabel
//
//  Created by Mac on 17/10/17.
//  Copyright © 2017 mac. All rights reserved.
//

import UIKit

class AddOnOptionCell: UITableViewCell {

    @IBOutlet weak var lblAddOnName:UILabel!
    @IBOutlet weak var lblAddOnPrice:UILabel!
    @IBOutlet weak var imgIcon:UIImageView!
  
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
      
      imgIcon.image = imgIcon.image!.withRenderingMode(.alwaysTemplate)
      
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
