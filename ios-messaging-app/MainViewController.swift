//
//  ViewController.swift
//  ios-messaging-app
//
//  Created by Fracisco Igor on 2018-11-23.
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
    var senderImage : String?
    var userImage : String?
    
    func setImages(senderImage: String, userImage:String){
        self.senderImage = senderImage
        self.userImage = userImage
    }
    
    
    @IBAction func emojiClick(_ sender: Any) {
        let button = sender as! UIButton
        messageField.insertText(button.currentTitle!)
    }
    
    func setMessages(email: String)
    {
        let oldCount = messages.count
        self.messages = AppData.filterMessagesOf(email: email)
        self.email = email
        if (tableView != nil){
            print("Updating messages \(email) \(messages.count)" )
            tableView.reloadData()
            if (oldCount != messages.count && messages.count > 0){
                let indexPath = IndexPath(row: messages.count - 1, section: 0)
                tableView.selectRow(at: indexPath, animated: true, scrollPosition: .bottom)
                self.tableView.scrollToNearestSelectedRow(at: .bottom, animated: true)
            }
            navigationItem.title = AppData.getSender(email: email)?.name
        }
        
    }
    
    
    @IBAction func sendMessage(_ sender: Any) {
        if (messageField.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).count==0){
            return
        }
        let values = AppData.messageData(message: messageField.text, toEmail: email)
        AppData.createMessage(data: values)
        setMessages(email: self.email)
        AppData.updateChatHistory(email: email)
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
    
    func DataSourceLoaded(entity: String) {
        if (entity == "Message"){
            if AppData.currentUser != nil {
                setMessages(email: self.email)
            }
        }
        if self.viewIfLoaded?.window != nil {
            AppData.updateChatHistory(email: self.email)
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
        cell.header = true
        cell.footer = true
        if (indexPath.row>0){
            let prevMessage = messages[indexPath.row - 1] as! Message
            let currentMessage = message as! Message
            if (currentMessage.from == prevMessage.from){
                cell.header = false
            }
        }
        if (indexPath.row < messages.count - 2){
            let nextMessage = messages[indexPath.row + 1] as! Message
            let currentMessage = message as! Message
            let diff = nextMessage.timestamp - currentMessage.timestamp
            if (currentMessage.from == nextMessage.from && diff<10){
                cell.footer = false
            }
        }
        cell.senderImage = senderImage
        cell.userImage = userImage
        cell.setMessage(message, email: self.email)
        return cell
    }
    
    
    
    
}


extension MainViewController : UITableViewDelegate{
    
    
    
}

