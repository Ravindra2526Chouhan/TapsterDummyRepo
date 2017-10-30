//
//  HomeTableCell.swift
//  TapsterWhiteLabel
//
//  Created by mac on 11/10/17.
//  Copyright © 2017 mac. All rights reserved.
//

import UIKit

class HomeTableCell: UITableViewCell {

    @IBOutlet weak var imgFeatured: UIImageView!
    @IBOutlet weak var lblVenueName: UILabel!
    @IBOutlet weak var lblVenueTime: UILabel!
    @IBOutlet weak var lblVenueAddress: UILabel!
    @IBOutlet weak var viewPickUp: UIView!
    @IBOutlet weak var lblPickUp: UILabel!
    @IBOutlet weak var lblReady: UILabel!
    @IBOutlet weak var btnPickUp:UIButton!
  
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.viewPickUp.roundCorners(corners: [.bottomLeft, .topLeft], radius: 14)
        self.viewPickUp.backgroundColor = Util.util.hexStringToUIColor(hex: User.currentUser.appColor)
        self.lblVenueName.textColor = Util.util.hexStringToUIColor(hex: User.currentUser.appColor)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
