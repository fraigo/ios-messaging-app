//
//  LoginViewController.swift
//  ios-messaging-app
//
//  Created by Fracisco Igor on 2018-11-26.
//  Copyright © 2018 User. All rights reserved.
//

import UIKit
import GoogleSignIn


class LoginViewController: UIViewController, GIDSignInUIDelegate {

    @IBOutlet weak var loginImage: UIImageView!
    @IBOutlet weak var loginLabel: UILabel!
    @IBOutlet weak var googleButton: GIDSignInButton!
    @IBOutlet weak var signOutButton: UIButton!
    var firstLogin = true
    
    var collapseDetail : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().signInSilently()
        loginImage.rounded()
        setImage(name: "user-icon", imageView: loginImage)
        if let user = AppData.currentUser {
            firstLogin = false
            updateView(user: user)
        }
        requestNotificationAuthorization()
        splitViewController?.delegate = self
    }
    
    @IBAction func signOutClick(_ sender: Any) {
        signOutButton.isHidden = true
        loginLabel.text = "Not Signed"
        AppData.closeDataSource()
        googleButton.isHidden = false
        GIDSignIn.sharedInstance().signOut()
        setImage(name: "user-icon", imageView: loginImage)
        AppData.clearData()
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
    
    func updateView(user: User){
        loginLabel.text = "Signed In as\n" + user.name + "\n" + user.email
        signOutButton.isHidden = false
        loadImage(url: user.image, imageView: loginImage)
        googleButton.isHidden = true
    }
    
    func updateLogin(){
        print("Checking login")
        if let user = AppData.currentUser {
            updateView(user: user)
            let senders = AppData.getSenders()
            let pendingMessages = AppData.pendingMessages(senders: senders)
            if (pendingMessages>0){
                
            }
            if firstLogin {
                navigationController?.popToRootViewController(animated: true)
            }
            
        }else{
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                self.updateLogin()
            }
        }
    }
    
    
    
    
    static func show(current: UIViewController){
        let newView = current.storyboard?.instantiateViewController(withIdentifier: "LoginView") as! LoginViewController
        current.navigationController?.pushViewController(newView, animated: true)
    }

}






extension LoginViewController : UISplitViewControllerDelegate {
    
    // allows to show the main table view at the start of the application
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        if AppData.currentUser != nil {
            return true
        }
        return false
    }
    
    
}
