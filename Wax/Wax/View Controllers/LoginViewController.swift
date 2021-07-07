//
//  LoginViewController.swift
//  Wax
//
//  Created by Jack Bauman on 7/6/21.
//

import Foundation
import UIKit
import WebKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var loginButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        loginButton?.layer.cornerRadius = loginButton.frame.height/2

    }
    
    @IBAction func loginTapped(_ sender: Any) {
        let vc = SpotifyAuthViewController()
        vc.navigationItem.largeTitleDisplayMode = .never
        vc.completionHandler = { [weak self] success in
            DispatchQueue.main.async {
                self?.handleSignIn(success:success)
            }
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func handleSignIn(success:Bool){
        
        guard success else {
            let alert = UIAlertController(title:"RIP",message: "There was an issue signing you in to Spotify",preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }
        
        let homeVC = HomeViewController()
        homeVC.modalPresentationStyle = .fullScreen
        present(homeVC, animated: true, completion: nil)
    }
}
