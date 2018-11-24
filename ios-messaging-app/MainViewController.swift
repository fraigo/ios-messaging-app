//
//  ViewController.swift
//  ios-messaging-app
//
//  Created by User on 2018-11-23.
//  Copyright © 2018 User. All rights reserved.
//

import UIKit
import CoreData

class MainViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var messages: [NSManagedObject] = []
    var email: String = ""
    
    
    func setMessages(_ messages: [NSManagedObject], email: String)
    {
        self.messages = messages
        self.email = email
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        tableView.delegate = self
        tableView.dataSource = self
  
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        tableView.reloadData()
        navigationController?.title = self.email
    }


}


extension MainViewController : UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return messages.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath) as! MainTableViewCell
        let message = messages[indexPath.row]
        cell.setMessage(message, email: self.email)
        return cell
    }
    

    
    
}


extension MainViewController : UITableViewDelegate{
    
    
    
}

