//
//  SpotifyAuthViewController.swift
//  Wax
//
//  Created by Jack Bauman on 7/6/21.
//

import UIKit
import Foundation
import WebKit

class SpotifyAuthViewController: UIViewController, WKNavigationDelegate {

    
    private let webView: WKWebView = {
        let prefs = WKWebpagePreferences()
        let config = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero,configuration: config)
        return webView
    }()
    
    public var completionHandler: ((Bool) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.largeTitleDisplayMode = .never
        webView.navigationDelegate = self
        view.addSubview(webView)
        guard let url = SpotifyAuthManager.shared.signInUrl else {
            return
        }
        webView.load(URLRequest(url: url))
    }
    
    override func viewDidLayoutSubviews() {
        webView.frame = view.bounds
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        guard let url = webView.url else {
            return
        }
        
        //get access token
        let component = URLComponents(string: url.absoluteString)
        guard let code = component?.queryItems?.first(where: { $0.name == "code"})?.value else {
            NSLog("Error getting code, url =\(url)")
            return
        }
        NSLog("code = \(code)")
        SpotifyAuthManager.shared.getTokenFromCode(code: code) { [weak self] success in
            DispatchQueue.main.async {
                self?.navigationController?.popToRootViewController(animated: true)
                self?.completionHandler?(success)
            }
        }
    }
    

}
