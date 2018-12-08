//
//  MenuTableViewCell.swift
//  ios-messaging-app
//
//  Created by Fracisco Igor on 2018-11-23.
//  Copyright © 2018 User. All rights reserved.
//

import UIKit
import CoreData

class MenuTableViewCell: UITableViewCell {

    @IBOutlet weak var senderName: UILabel!
    @IBOutlet weak var senderStatus: UILabel!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var messageCount: UILabel!
    
    var newMessages = 0
    var sender : Sender!
    
    func setItem(_ obj: NSManagedObject){
        self.sender = obj as? Sender
        countMessages()
        
    }
    
    func countMessages(){
        if let email = sender.email {
            let timestamp = AppData.getLastChatHistory(email: email)
            print("Checking \(email) from \(timestamp)")
            self.newMessages = AppData.filterMessagesOf(email: email, from: timestamp).count
            if (senderName != nil){
                updateView()
            }
        }
    }
    
    override func didMoveToWindow() {
        updateView()
    }
    
    func updateView(){
        userImage.layer.cornerRadius = userImage.frame.width/2
        userImage.clipsToBounds = true
        
        messageCount.layer.cornerRadius = messageCount.frame.width/2
        messageCount.clipsToBounds = true
        messageCount.isHidden = (newMessages == 0)
        messageCount.text = "\(newMessages)"
        messageCount.layer.borderColor = UIColor.black.cgColor
        
        if let sender = sender {
            let imageUrl = sender.imageUrl
            senderName.text = sender.name
            senderStatus.text = sender.email
            if (imageUrl != nil && imageUrl != ""){
                loadImage(url: imageUrl!, imageView: userImage)
            }else{
                setImage(name: "user-icon", imageView: userImage)
            }
            
        }
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


extension MenuTableViewCell : DataSourceDelegate {
    
    func DataSourceLoaded(entity: String) {
        if (entity == "Message"){
            countMessages()
        }
    }
}
