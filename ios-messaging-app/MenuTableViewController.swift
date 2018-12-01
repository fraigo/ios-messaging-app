//
//  MenuTableViewController.swift
//  ios-messaging-app
//
//  Created by User on 2018-11-23.
//  Copyright © 2018 User. All rights reserved.
//

import UIKit
import CoreData

class MenuTableViewController: UITableViewController {
    
    var senders : [NSManagedObject] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
    
        DataSource.autoUpdate()
        DataSource.addDataSourceDelegate(self)
        
        let button = UIBarButtonItem()
        button.title = "Profile"
        button.action = #selector(viewProfile)
        button.target = self
        navigationItem.rightBarButtonItem = button
        
        let button2 = UIBarButtonItem()
        button2.title = "New"
        button2.action = #selector(addNew)
        button2.target = self
        navigationItem.leftBarButtonItem = button2
    }
    
    
    @objc func viewProfile(){
        //performSegue(withIdentifier: "viewProfile", sender: self)
        print("Profile")
        LoginViewController.show(current: self)
    }
    
    @objc func addNew(){
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
                        "from" : DataSource.currentUser.email,
                        "visible" : 1,
                        "timestamp" : NSDate().timeIntervalSince1970
                    ]
                    DataSource.createMessage(data: values)
                    DataSource.loadData()
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
        navigationItem.title = "Messages (\(senders.count))"
        return senders.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SenderCell", for: indexPath) as! MenuTableViewCell
        cell.setItem(senders[indexPath.row])
        print("get cell \(indexPath.row)")
        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let viewCell = sender as! MenuTableViewCell
        let value = viewCell.object.value(forKey: "email")
        if (value == nil){
            tableView.reloadData()
            return
        }
        let email = value as! String
        print("Selected \(email)")
        let newView = segue.destination as! MainViewController
        newView.setMessages(email: email)
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Selected \(indexPath.row)")
        
    }
    

    
}


extension MenuTableViewController : DataSourceDelegate {
    
    func DataSourceLoaded() {
        if let user = DataSource.currentUser {
            let newSenders = DataSource.filterField(entity: "Sender", field: "email", value: user.email, operation: "<>")
            print("Updating senders \(newSenders.count)")
            self.senders = newSenders
            self.tableView.reloadData()
        }
    }
}


extension MenuTableViewController : UISplitViewControllerDelegate {
    
    // allows to show the main table view at the start of the application
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        return true
    }
    
    
}
