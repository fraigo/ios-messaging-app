//
//  MainTableViewCell.swift
//  ios-messaging-app
//
//  Created by User on 2018-11-23.
//  Copyright © 2018 User. All rights reserved.
//

import UIKit
import CoreData

class MainTableViewCell: UITableViewCell {

    
    @IBOutlet weak var messageContent: UITextView!
    @IBOutlet weak var senderLabel: UILabel!
    
    var message : NSManagedObject!
    var email : String = ""
    
    func setMessage(_ message: NSManagedObject, email: String){
        self.message = message
        self.email = email
    }
    
    override func didMoveToWindow() {
        updateView()
    }
    
    func updateView(){
        let from = message!.value(forKey: "from") as? String
        senderLabel.text = from
        messageContent.text = message!.value(forKey: "message") as? String
        if (from == self.email){
            messageContent.textAlignment = .left
            senderLabel.textAlignment = .left
            messageContent.backgroundColor = UIColor.init(red: 0.9, green: 1.0, blue: 0.9, alpha: 0.5)
            senderLabel.textColor = UIColor.init(red: 0.0, green: 0.5, blue: 0.0, alpha: 0.8)
            
        }else{
            messageContent.textAlignment = .right
            senderLabel.textAlignment = .right
            messageContent.backgroundColor = UIColor.init(red: 0.9, green: 0.9, blue: 1.0, alpha: 0.5)
            senderLabel.textColor = UIColor.init(red: 0.0, green: 0.0, blue: 0.9, alpha: 0.8)
        }
        messageContent.layer.cornerRadius = 5;
        messageContent.layer.masksToBounds = true;
        messageContent.isScrollEnabled = false
    }
    
    override func layoutSubviews() {
        print("Height", messageContent.frame.height)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
