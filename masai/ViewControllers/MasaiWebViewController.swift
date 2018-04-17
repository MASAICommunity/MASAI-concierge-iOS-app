//
//  MasaiWebViewController.swift
//  masai
//
//  Created by Bartomiej Burzec on 03.04.2017.
//  Copyright © 2017 Embiq sp. z o.o. All rights reserved.
//

import UIKit
import WebKit

class MasaiWebViewController: MasaiBaseViewController,  WKNavigationDelegate {

    var webView: WKWebView!
    @IBOutlet weak var notLoadedInfoLabel: UILabel!
    
    var requestAddress: String?
    var token: String?
    var credentials: LiveChatCredentials?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.webView = WKWebView(frame: self.view.frame)
        self.webView.backgroundColor = .clear
        self.webView.navigationDelegate = self
        self.view.addSubview(webView)
        
        if let userId = self.credentials?.liveChatUserId,
            let token = self.credentials?.liveChatUserLoginToken,
            let urlString = self.requestAddress {
            let request = NSMutableURLRequest(url: URL(string: urlString)!)
            
            let cookie = "rc_uid=\(userId);rc_token=\(token)"
            request.setValue(cookie, forHTTPHeaderField: "Cookie")
            self.webView.load(request as URLRequest)
        } else {
            self.notLoadedInfoLabel.isHidden = false
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func isNavigationBarRightItemVisible() -> Bool {
        return true
    }
    
    override func titleForNavigationBarRightItem() -> String? {
        return "close".localized
    }
    
    override func onPressedNavigationBarRightButton() {
        dismiss(animated: true, completion: nil)
    }

    private func webView(webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: NSError) {
        self.notLoadedInfoLabel.isHidden = false
    }
    private func webView(webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
    }
    
    private func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation!) {
    }
    
    
}
