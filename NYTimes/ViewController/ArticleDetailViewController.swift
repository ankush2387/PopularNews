//
//  ArticleDetailViewController.swift
//  NYTimes
//
//  Created by CHETUMAC043 on 11/22/18.
//  Copyright © 2018 CHETUMAC043. All rights reserved.
//

import UIKit
import WebKit

class ArticleDetailViewController: UIViewController, WKNavigationDelegate {

    @IBOutlet weak var webView: WKWebView!
    var urlString:String? = ""
    
    //MARK:- lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        let url = NSURL(string: urlString ?? "")
        let request = NSURLRequest(url: url! as URL)
        // init and load request in webview.
        webView.navigationDelegate = self
        webView.load(request as URLRequest)
    }

    //MARK:- WKNavigationDelegate
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        Loader.hide()
        print(error.localizedDescription)
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        Loader.show(animated: true)
        print("Strat to load")
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        Loader.hide()
        print("finish to load")
    }

}
