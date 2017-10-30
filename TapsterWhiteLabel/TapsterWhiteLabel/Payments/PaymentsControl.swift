//
//  PaymentsControl.swift
//  TapsterWhiteLabel
//
//  Created by Mac on 12/10/17.
//  Copyright © 2017 mac. All rights reserved.
//

import UIKit

class PaymentsControl: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tblPayments:UITableView!
    var isFoundCard:Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
      // Do any additional setup after loading the view.
      Util.util.setUpNavigation(navControl: self.navigationController!)
      
      self.setUpBackButton()
      self.title = "Payment"
      
      self.tblPayments.register(UINib.init(nibName: "CardCell", bundle: nil), forCellReuseIdentifier: "CardCell")

      User.currentUser.getUserDefaultCard { (success) in
        if(success){
          self.tblPayments.reloadData()
        }
      }
    }
  
    override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
      let isCardUpdated = UserDefaults.standard.bool(forKey: "cardupdated")
      if(isCardUpdated){
        UserDefaults.standard.set(false, forKey: "cardupdated")
        User.currentUser.getUserDefaultCard { (success) in
          if(success){
            self.tblPayments.reloadData()
          }
        }
      }
    }
    
    func action_back(){
      self.navigationController?.popViewController(animated: true)
    }
    
    func setUpBackButton() {
      let backImg: UIImage = UIImage(named: "arrowBack")!
      self.navigationItem.backBarButtonItem?.tintColor = UIColor.clear
      self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: backImg, style: .plain, target: self, action:#selector(action_back))
    }
    
    //MARK:- UITableView DataSource & Delegate Method
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      if(indexPath.section == 0){
        let cell: CardCell = self.tblPayments.dequeueReusableCell(withIdentifier: "CardCell") as! CardCell
        cell.selectionStyle = .none
        cell.accessoryType = .none
        
        cell.lblCardNumber.text = "****  \(User.currentUser.defaultCard.last4)"
        var brand = User.currentUser.defaultCard.brand
        brand = brand.lowercased()
        brand = brand.trim()
        cell.imgCardIcon.image = UIImage(named: brand)
        
        return cell
      }
      let cell: CardCell = self.tblPayments.dequeueReusableCell(withIdentifier: "CardCell") as! CardCell
      cell.selectionStyle = .none
      cell.accessoryType = .none
      cell.lblCardNumber.text = ((User.currentUser.defaultCard) != nil) ? "Change Card" : "Add Card"
      return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
      return  2
    }
  
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      if(section == 0){ return ((User.currentUser.defaultCard) != nil) ? 1 : 0 }
      return 1
    }
  
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      self.tblPayments.deselectRow(at: indexPath, animated: true)
      if (indexPath.section == 1) {
        let changePaymentControl = self.storyboard?.instantiateViewController(withIdentifier: "ChangePaymentControl") as! ChangePaymentControl
        self.navigationController?.pushViewController(changePaymentControl, animated: true)
      }
    }
  
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
