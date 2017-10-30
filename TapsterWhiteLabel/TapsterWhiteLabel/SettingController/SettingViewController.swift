
//
//  SettingViewController.swift
//  TapsterWhiteLabel
//
//  Created by mac on 11/10/17.
//  Copyright © 2017 mac. All rights reserved.
//

import UIKit
import MessageUI

class SettingViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, MFMailComposeViewControllerDelegate {

    @IBOutlet weak var btnMenu: UIButton!
    @IBOutlet weak var tableVW: UITableView!
    @IBOutlet weak var viewTblAccount: UIView!
    @IBOutlet weak var viewTblShare: UIView!
    @IBOutlet weak var btnLogin: UIButton!
    
    let accountArr = ["Payment", "Order History", "Contact Us", "Privacy Policy", "Terms & Conditions"]
    let shareArr = ["Facebook", "Instagram"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Settings"
        self.view.backgroundColor = UIColor.white
        Util.util.setUpNavigation(navControl: self.navigationController!)
        self.addLeftbuttomWithController(controller: self, withCustomView: btnMenu)
        
        self.tableVW.register(UINib.init(nibName: "SettingTableCell", bundle: nil), forCellReuseIdentifier: "SettingTableCell")
        self.tableVW.register(UINib.init(nibName: "SettingShareCell", bundle: nil), forCellReuseIdentifier: "SettingShareCell")
        self.btnLogin.backgroundColor = Util.util.hexStringToUIColor(hex: User.currentUser.appColor)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        if (User.currentUser.isLogin) {
          self.btnLogin.setTitle("Logout", for: .normal)
        }else{
          self.btnLogin.setTitle("Login", for: .normal)
        }
    }
  
    @IBAction func actionMenuClosed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func actionLogin(_ sender: Any) {
        if (User.currentUser.isLogin) {
          User.currentUser.isLogin = false
          User.currentUser.logout()
          self.btnLogin.setTitle("Login", for: .normal)
        }else{
          let accountVC = self.storyboard?.instantiateViewController(withIdentifier: "CreateAccountController") as! CreateAccountController
          let navControl = UINavigationController(rootViewController: accountVC)
          self.present(navControl, animated: true, completion: nil)
        }
    }
    
    // MARK:- UITableView DataSource & Delegate Method
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? self.accountArr.count : self.shareArr.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? self.viewTblAccount.frame.height : self.viewTblShare.frame.height
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return section == 0 ? self.viewTblAccount : self.viewTblShare
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell: SettingTableCell = self.tableVW.dequeueReusableCell(withIdentifier: "SettingTableCell") as! SettingTableCell
            cell.lblTitle.text = self.accountArr[indexPath.row]
            cell.selectionStyle = .none
            return cell
        }
        else {
            let cell: SettingShareCell = self.tableVW.dequeueReusableCell(withIdentifier: "SettingShareCell") as! SettingShareCell
            cell.lblTitle.text = self.shareArr[indexPath.row]
            cell.imgIcon.image = UIImage.init(named: self.shareArr[indexPath.row])
            cell.selectionStyle = .none
            return cell
        }
    }
  
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      self.tableVW.deselectRow(at: indexPath, animated: true)
      if indexPath.section == 0 {
        let option = self.accountArr[indexPath.row]
        if(option == "Payment"){
          if (User.currentUser.isLogin) {
            let paymentsControl = self.storyboard?.instantiateViewController(withIdentifier: "PaymentsControl") as! PaymentsControl
            self.navigationController?.pushViewController(paymentsControl, animated: true)
          }else{
            let accountVC = self.storyboard?.instantiateViewController(withIdentifier: "CreateAccountController") as! CreateAccountController
            let navControl = UINavigationController(rootViewController: accountVC)
            self.present(navControl, animated: true, completion: nil)
          }
        }
        if(option == "Order History"){
          if (User.currentUser.isLogin) {
            let orderHistoryControl = self.storyboard?.instantiateViewController(withIdentifier: "OrderHistoryControl") as! OrderHistoryControl
            self.navigationController?.pushViewController(orderHistoryControl, animated: true)
          }else{
            let accountVC = self.storyboard?.instantiateViewController(withIdentifier: "CreateAccountController") as! CreateAccountController
            let navControl = UINavigationController(rootViewController: accountVC)
            self.present(navControl, animated: true, completion: nil)
          }
        }
        if(option == "Contact Us"){
          if !MFMailComposeViewController.canSendMail() {
            //                print("Mail services are not available")
            let alert=UIAlertController(title: "Could Not Send Email", message: "Your device could not send e-mail. Please check e-mail configuration and try again!", preferredStyle: UIAlertControllerStyle.alert);
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: {(action:UIAlertAction) in
              //                    print("OK")
            }));
            present(alert, animated: true, completion: nil);
            return
          }
          let composeVC = MFMailComposeViewController()
          composeVC.mailComposeDelegate = self
          // Configure the fields of the interface.
          composeVC.setToRecipients([User.currentUser.accountSetting.contactEmail])
          composeVC.setSubject("Contact Us!")
          composeVC.setMessageBody("", isHTML: false)
          // Present the view controller modally.
          self.present(composeVC, animated: true, completion: nil)
        }
        if(option == "Privacy Policy"){
          let webControl = self.storyboard?.instantiateViewController(withIdentifier: "WebControl") as! WebControl
          webControl.strTitle = "Privacy Policy"
          webControl.strUrl = User.currentUser.accountSetting.privacyUrl
          self.navigationController?.pushViewController(webControl, animated: true)
        }
        if(option == "Terms & Conditions"){
          let webControl = self.storyboard?.instantiateViewController(withIdentifier: "WebControl") as! WebControl
          webControl.strTitle = "Terms & Conditions"
          webControl.strUrl = User.currentUser.accountSetting.termAndConditionUrl
          self.navigationController?.pushViewController(webControl, animated: true)
        }
      }
      else {
        let option = self.shareArr[indexPath.row]
        if(option == "Facebook"){
          
        }
        if(option == "Instagram"){
          
        }
      }
      
    }
  
  func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
    // Dismiss the mail compose view controller.
    controller.dismiss(animated: true, completion: nil)
  }
}
