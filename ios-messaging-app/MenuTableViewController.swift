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
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    
        DataSource.autoUpdate()
        updateLogin()
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
        let email = value as! String
        print("Selected \(email)")
        let newView = segue.destination as! MainViewController
        newView.setMessages(email: email)
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Selected \(indexPath.row)")
        
    }
    
    func updateLogin(){
        print("Checking login")
        if let user = DataSource.currentUser {
            updateSenders()
        }else{
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                self.updateLogin()
            }
            senders = []
            self.tableView.reloadData()
        }
        
    }
    
    func updateSenders(){
        if let user = DataSource.currentUser {
            print("Checking senders ")
            let newSenders = DataSource.filterField(entity: "Sender", field: "email", value: user.email, operation: "<>")
            if (newSenders.count>0){
                self.senders = newSenders
                print("Updating senders \(newSenders.count)")
                self.tableView.reloadData()
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            self.updateSenders()
        }
        
    }
    
    
}



extension MenuTableViewController : UISplitViewControllerDelegate {
    
    // allows to show the main table view at the start of the application
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        return true
    }
    
    
}
