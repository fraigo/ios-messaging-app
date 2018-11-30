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
        let messages = DataSource.filterMessagesOf(email: email)
        self.messages = messages
        self.email = email
        
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
        
        DataSource.createEntity("Message", data: values)
        setMessages(email: self.email)
        tableView.reloadData()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        tableView.delegate = self
        tableView.dataSource = self
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyBoardDidShow(notification:)), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyBoardDidHide(notification:)), name: UIResponder.keyboardDidHideNotification, object: nil)
        
        updateMessages()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        tableView.reloadData()
        navigationController?.title = self.email
    }
    
    
    @objc func keyBoardDidShow(notification: NSNotification) {
        print("keyboard")
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            //let keyboardHeight = keyboardSize.height
            keyboardSpace.isHidden = false
            keyboardConstraint.constant = keyboardSize.height
        }
    }
    
    @objc func keyBoardDidHide(notification: NSNotification) {
        print("keyboard")
        keyboardSpace.isHidden = true
    }
    
    func updateMessages(){
        if let user = DataSource.currentUser {
            print("Checking messages " + user.email)
            setMessages(email: self.email)
            tableView.reloadData()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            self.updateMessages()
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

