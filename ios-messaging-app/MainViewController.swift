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
        let oldCount = messages.count
        self.messages = DataSource.filterMessagesOf(email: email)
        self.email = email
        if (tableView != nil){
            print("Updating messages \(email) \(messages.count)" )
            tableView.reloadData()
            if (oldCount != messages.count){
                let indexPath = IndexPath(row: messages.count - 1, section: 0)
                tableView.selectRow(at: indexPath, animated: true, scrollPosition: .bottom)
                self.tableView.scrollToNearestSelectedRow(at: .bottom, animated: true)
            }
        }
        
    }
    
    
    @IBAction func sendMessage(_ sender: Any) {
        let values: NSDictionary = [
            "message" :  messageField.text,
            "to" :  self.email,
            "from" : DataSource.currentUser.email,
            "visible" : 1,
            "timestamp" : NSDate().timeIntervalSince1970
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
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyBoardDidShow(notification:)), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyBoardDidHide(notification:)), name: UIResponder.keyboardDidHideNotification, object: nil)
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        navigationController?.title = self.email
        setMessages(email: email)
    }
    
    
    @objc func keyBoardDidShow(notification: NSNotification) {
        print("keyboard")
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            //let keyboardHeight = keyboardSize.height
            keyboardSpace.isHidden = false
            keyboardConstraint.constant = keyboardSize.height
            self.tableView.setContentOffset(CGPoint(x:0, y:self.tableView.contentSize.height + 200.0), animated: false)
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

