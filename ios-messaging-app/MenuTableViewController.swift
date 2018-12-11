//
//  MenuTableViewController.swift
//  ios-messaging-app
//
//  Created by Fracisco Igor on 2018-11-23.
//  Copyright © 2018 User. All rights reserved.
//

import UIKit
import CoreData

class MenuTableViewController: UITableViewController {
    
    var senders : [NSManagedObject] = []
    let profileButton = UIBarButtonItem()
    let newMessageButton = UIBarButtonItem()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        DataSource.addDataSourceDelegate(self)
        
        profileButton.title = "Profile"
        profileButton.action = #selector(viewProfile)
        profileButton.target = self
        navigationItem.rightBarButtonItem = profileButton
        
        newMessageButton.title = "New"
        newMessageButton.action = #selector(addNew)
        newMessageButton.target = self
        //navigationItem.leftBarButtonItem = newMessageButton
    }
    
    override func viewWillLayoutSubviews() {
        if UIScreen.main.bounds.width>600 {
            splitViewController!.preferredDisplayMode = .allVisible
        }else{
            splitViewController!.preferredDisplayMode = .automatic
        }
    }
    

    
    @objc func viewProfile(){
        //performSegue(withIdentifier: "viewProfile", sender: self)
        print("Profile")
        LoginViewController.show(current: self)
    }
    
    @objc func addNew(){
        let view = navigationController?.storyboard?.instantiateViewController(withIdentifier: "NewMessage") as! NewMessageViewController
        present(view, animated: true) {
            print("Completed")
        }
        
    }
        
    @objc func addNewOld(){
        let alert = UIAlertController(title: "New contact", message: "Enther the user", preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.keyboardType = .emailAddress
            textField.text = "@gmail.com"
            textField.font = UIFont.systemFont(ofSize: 20)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                let newPosition = textField.beginningOfDocument
                textField.selectedTextRange = textField.textRange(from: newPosition, to: newPosition)
            })
        }
        
        alert.addAction(UIAlertAction(title: "Message", style: .default, handler: { [weak alert] (_) in
            if  let textField = alert?.textFields![0] {
                if let email = textField.text {
                    let values: NSDictionary = [
                        "message" :  "Let's chat!",
                        "to" :  email,
                        "from" : AppData.currentUser.email,
                        "visible" : 1,
                        "timestamp" : NSDate().timeIntervalSince1970
                    ]
                    AppData.createMessage(data: values)
                    AppData.loadData()
                }
            }
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return senders.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SenderCell", for: indexPath) as! MenuTableViewCell
        cell.setItem(senders[indexPath.row])
        DataSource.addDataSourceDelegate(cell)
        print("get cell \(indexPath.row)")
        return cell
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let viewCell = sender as! MenuTableViewCell
        if let email = viewCell.sender.email{
            let newView = segue.destination as! MainViewController
            let senderImage = viewCell.sender.imageUrl
            let userImage = AppData.currentUser.image
            AppData.updateChatHistory(email: email)
            newView.setImages(senderImage: senderImage!, userImage: userImage)
            newView.setMessages(email: email)
        }
        else{
            tableView.reloadData()
            return
        }
        
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Selected \(indexPath.row)")
        
    }
    

    
}


extension MenuTableViewController : DataSourceDelegate {
    
    func DataSourceLoaded(entity: String) {
        if (entity == "Sender"){
            if AppData.currentUser != nil {
                let newSenders = AppData.getSenders()
                self.senders = newSenders
                self.tableView.reloadData()
                navigationItem.leftBarButtonItem = newMessageButton
            }else{
                self.senders = []
                self.tableView.reloadData()
                navigationItem.leftBarButtonItem = nil
                navigationItem.title = "Messages"
            }
        }
        if (entity == "Message"){
            let pendingMessages = AppData.pendingMessages(senders: senders)
            navigationItem.title = "Messages"
            if (pendingMessages>0){
                navigationItem.title = "Messages (\(pendingMessages))"
                userNotification(message: "You have \(pendingMessages) new messages", title: "New messags", count: pendingMessages)
            }else{
                clearNotification()
            }
            
        }
    }
    
    
}

