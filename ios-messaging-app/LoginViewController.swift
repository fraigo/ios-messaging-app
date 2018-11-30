//
//  LoginViewController.swift
//  ios-messaging-app
//
//  Created by User on 2018-11-26.
//  Copyright © 2018 User. All rights reserved.
//

import UIKit
import GoogleSignIn

class LoginViewController: UIViewController, GIDSignInUIDelegate {

    @IBOutlet weak var loginLabel: UILabel!
    @IBOutlet weak var googleButton: GIDSignInButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().signInSilently()
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    override func viewDidAppear(_ animated: Bool) {
        updateLogin()
    }
    
    func updateLogin(){
        print("Checking login")
        if let user = DataSource.currentUser {
            loginLabel.text = "Signed In as " + user.email
            googleButton.isHidden = true
        }else{
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                self.updateLogin()
            }
        }
    }

}



