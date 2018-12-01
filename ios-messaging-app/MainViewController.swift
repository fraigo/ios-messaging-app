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
    
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var messageField: UITextView!
    @IBOutlet weak var keyboardSpace: UIView!
    @IBOutlet weak var keyboardConstraint: NSLayoutConstraint!
    var messages: [NSManagedObject] = []
    var email: String = ""
    
    
    func setMessages(email: String)
    {
        self.messages = DataSource.filterMessagesOf(email: email)
        self.email = email
        print("Checking messages " + email + " \(self.messages.count)")
        if (tableView != nil){
            print("Updating messages \(email) \(messages.count)" )
            tableView.reloadData()
        }
        
    }
    
    
    @IBAction func sendMessage(_ sender: Any) {
        let values: NSDictionary = [
            "message" :  messageField.text,
            "to" :  self.email,
            "from" : DataSource.currentUser.email,
            "visible" : 1,
            "timestamp" : 123
            ]
        print(values)
        
        DataSource.createMessage(data: values)
        setMessages(email: self.email)
        messageField.text = ""
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        tableView.delegate = self
        tableView.dataSource = self
        DataSource.addDataSourceDelegate(self)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyBoardDidShow(notification:)), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyBoardDidHide(notification:)), name: NSNotification.Name.UIKeyboardDidHide, object: nil)
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        navigationController?.title = self.email
        setMessages(email: email)
    }
    
    
    @objc func keyBoardDidShow(notification: NSNotification) {
        print("keyboard")
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            //let keyboardHeight = keyboardSize.height
            keyboardSpace.isHidden = false
            keyboardConstraint.constant = keyboardSize.height
        }
    }
    
    @objc func keyBoardDidHide(notification: NSNotification) {
        print("keyboard")
        keyboardSpace.isHidden = true
    }
    


}



extension MainViewController : DataSourceDelegate {
    
    func DataSourceLoaded() {
        if DataSource.currentUser != nil {
            setMessages(email: self.email)
        }
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

