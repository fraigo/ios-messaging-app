//
//  MainTableViewCell.swift
//  ios-messaging-app
//
//  Created by User on 2018-11-23.
//  Copyright © 2018 User. All rights reserved.
//

import UIKit
import CoreData
import DateToolsSwift

class MainTableViewCell: UITableViewCell {

    
    @IBOutlet weak var messageContent: UITextView!
    @IBOutlet weak var senderLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    
    var message : NSManagedObject!
    var email : String = ""
    
    func setMessage(_ message: NSManagedObject, email: String){
        self.message = message
        self.email = email
        if (messageContent != nil){
            updateView()
        }
    }
    
    override func didMoveToWindow() {
        updateView()
    }
    
    func updateView(){
        //print(message!.value(forKey: "from") ?? "No/MSG" )
        
        if let from = message!.value(forKey: "from") as? String {
            senderLabel.text = " " + from + " "
            messageContent.text = message!.value(forKey: "message") as? String
            let sender = DataSource.filterField(entity: "Sender", field: "email", value: from)
            if sender.count>0 {
                let name = sender[0].value(forKey: "name") as! String
                senderLabel.text = " " + name + " (" + from + ")"
            }
            if (from == self.email){
                messageContent.textAlignment = .left
                senderLabel.textAlignment = .left
                senderLabel.backgroundColor = UIColor.init(red: 0.8, green: 1.0, blue: 0.8, alpha: 0.6)
                messageContent.backgroundColor = senderLabel.backgroundColor
                senderLabel.textColor = UIColor.init(red: 0.0, green: 0.5, blue: 0.0, alpha: 0.8)
                
            }else{
                messageContent.textAlignment = .right
                senderLabel.textAlignment = .right
                senderLabel.backgroundColor = UIColor.init(red: 0.8, green: 0.8, blue: 1.0, alpha: 0.6)
                messageContent.backgroundColor = senderLabel.backgroundColor
                senderLabel.textColor = UIColor.init(red: 0.0, green: 0.0, blue: 0.9, alpha: 0.8)
            }
            
            let timestamp = message.value(forKey: "timestamp") as? UInt
            let date = Date(timeIntervalSince1970: Double(timestamp!))
            timestampLabel.text = date.timeAgoSinceNow
        }
        
        senderLabel.layer.cornerRadius = 5;
        senderLabel.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        senderLabel.layer.masksToBounds = true
        messageContent.layer.cornerRadius = 5;
        messageContent.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        senderLabel.layer.masksToBounds = true
        messageContent.isScrollEnabled = false
    }
    
    override func layoutSubviews() {
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        //super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
