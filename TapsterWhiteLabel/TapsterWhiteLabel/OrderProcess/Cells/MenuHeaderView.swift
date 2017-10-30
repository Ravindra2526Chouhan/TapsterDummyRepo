//
//  MenuHeaderView.swift
//  TapsterWhiteLabel
//
//  Created by Mac on 17/10/17.
//  Copyright © 2017 mac. All rights reserved.
//

import UIKit

class MenuHeaderView: UIView {

    @IBOutlet weak var lblSectionName:UILabel!
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
  class func instanceFromNib() -> MenuHeaderView {
    return UINib(nibName: "MenuHeaderView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! MenuHeaderView
  }
}
