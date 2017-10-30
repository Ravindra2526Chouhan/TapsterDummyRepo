//
//  WebControl.swift
//  PostCard
//
//  Created by Mac on 26/04/17.
//  Copyright © 2017 Linkites. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class WebControl: UIViewController, UIWebViewDelegate {

    @IBOutlet weak var webview:UIWebView!
    var loading:NVActivityIndicatorView!
  
    var strTitle:String!
    var strUrl:String!
  
    override func viewDidLoad() {
        super.viewDidLoad()

        Util.util.setUpNavigation(navControl: self.navigationController!)
      
        self.setUpBackButton()
        // Do any additional setup after loading the view.
        //self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: self.btnMenu)
      
        self.loading = NVActivityIndicatorView(frame:CGRect(x: 0, y: 0, width: 40, height: 20), type: NVActivityIndicatorType.lineScale, color:UIColor.white, padding: 0)

        self.title = strTitle
        // Do any additional setup after loading the view.
        if let url = URL(string: strUrl) {
          let request = URLRequest(url: url)
          webview.loadRequest(request)
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
  
  func webViewDidStartLoad(_ webView: UIWebView)
  {
    self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.loading)
    self.loading.startAnimating()
  }
  func webViewDidFinishLoad(_ webView: UIWebView)
  {
    self.loading.stopAnimating()
    self.navigationItem.rightBarButtonItem = nil
  }
}
