//
//  CreateAccountController.swift
//  TapsterWhiteLabel
//
//  Created by mac on 11/10/17.
//  Copyright © 2017 mac. All rights reserved.
//

import UIKit

class CreateAccountController: UIViewController {

    @IBOutlet weak var imgBackground: UIImageView!
    @IBOutlet weak var imgLogo: UIImageView!
  
    @IBOutlet weak var btnLogin:UIButton!
    @IBOutlet weak var btnSignUp:UIButton!
  
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        self.btnLogin.backgroundColor = Util.util.hexStringToUIColor(hex: User.currentUser.appColor)
        self.btnSignUp.setTitleColor(Util.util.hexStringToUIColor(hex: User.currentUser.appColor), for:.normal)
        //add observer for home/map icon
        NotificationCenter.default.addObserver(self, selector: #selector(self.SignInSuccess(withNotification:)), name:AppNotifications.notificationSignInSuccess, object: nil)

    }
  
  @objc func SignInSuccess(withNotification obj : NSNotification) {
    User.currentUser.getUserDefaultCard { (success) in }
    self.dismiss(animated: true) {
      NotificationCenter.default.post(name: Notification.Name("notificationSelectMethodDirectStripe"), object: nil)
      NotificationCenter.default.post(name: Notification.Name("notificationSelectMethodDirectApple"), object: nil)
    }
  }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    @IBAction func actionMenuClosed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func actionLogin(_ sender: Any) {
        let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "LoginController") as! LoginController
        self.navigationController?.pushViewController(loginVC, animated: true)
    }
    
    @IBAction func actionSignUp(_ sender: Any) {
        let signupVC = self.storyboard?.instantiateViewController(withIdentifier: "SignUpController") as! SignUpController
        self.navigationController?.pushViewController(signupVC, animated: true)
    }
}
