//
//  NewMessageViewController.swift
//  ios-messaging-app
//
//  Created by Fracisco Igor on 2018-12-06.
//  Copyright © 2018 User. All rights reserved.
//

import UIKit
import SearchTextField

class NewMessageViewController: UIViewController {

    @IBOutlet weak var nameField: SearchTextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var messageField: UITextView!
    @IBOutlet weak var cancelButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        messageField.bordered(radius: 5, color: UIColor.lightGray)
        nameField.theme.bgColor = UIColor(white: 1.0, alpha: 0.9)
        nameField.theme.font = UIFont.systemFont(ofSize: 16)
        nameField.theme.cellHeight = 45
        nameField.itemSelectionHandler = {item, itemPosition in
            let itemSelected = item[itemPosition]
            self.nameField.text = itemSelected.title
            self.emailField.text = itemSelected.subtitle
            self.messageField.becomeFirstResponder()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        var items = [SearchTextFieldItem]()
        let contacts = DataSource.getEntities(entity: "Contact")
        for contact in contacts{
            if let c = contact as? Contact{
                let item1 = SearchTextFieldItem(title: c.name!, subtitle: c.email!, image: UIImage(named: "user-icon.png"))
                items.append(item1)
            }
        }
        nameField.filterItems(items)
        
    }


    @IBAction func sendClick(_ sender: Any) {
        let email = emailField.text
        let values: NSDictionary = [
            "message" :  messageField.text,
            "to" :  email as Any,
            "from" : AppData.currentUser.email,
            "visible" : 1,
            "timestamp" : NSDate().timeIntervalSince1970
        ]
        AppData.createMessage(data: values)
        AppData.loadData()
        AppData.updateChatHistory(email: email!)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelClick(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}



