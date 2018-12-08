//
//  MainTableViewCell.swift
//  ios-messaging-app
//
//  Created by Fracisco Igor on 2018-11-23.
//  Copyright © 2018 User. All rights reserved.
//

import UIKit
import CoreData
import DateToolsSwift

class MainTableViewCell: UITableViewCell {

    
    @IBOutlet weak var rightView: UIView!
    @IBOutlet weak var leftView: UIView!
    @IBOutlet weak var cellContainer: UIView!
    @IBOutlet weak var messageContent: UITextView!
    @IBOutlet weak var senderLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var rightIcon: UIImageView!
    @IBOutlet weak var leftIcon: UIImageView!
    
    var message : Message!
    var email : String = ""
    var header : Bool = true
    var footer : Bool = true
    
    var senderImage : String?
    var userImage : String?
    
    func setMessage(_ message: NSManagedObject, email: String){
        self.message = message as? Message
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
        leftIcon.rounded()
        rightIcon.rounded()
        cellContainer.bordered(radius: 15, color: UIColor.lightGray)
        
        if let from = message.from {
            senderLabel.isHidden = !header
            timestampLabel.isHidden = !footer
            messageContent.text = message.message
            
            leftIcon.loadImageUrl(url: senderImage!)
            rightIcon.loadImageUrl(url: userImage!)
            leftIcon.isHidden = true
            rightIcon.isHidden = true
            
            if (from == self.email){
                let senderName = AppData.getSender(email: from)?.name
                senderLabel.text = " " + senderName! + " (" + from + ")"
                messageContent.textAlignment = .left
                senderLabel.textAlignment = .left
                timestampLabel.textAlignment = .left
                cellContainer.backgroundColor = UIColor.init(red: 0.8, green: 1.0, blue: 0.8, alpha: 0.1)
                senderLabel.textColor = UIColor.init(red: 0.0, green: 0.5, blue: 0.0, alpha: 0.8)
                if header {
                    rightIcon.isHidden = true
                    leftIcon.isHidden = !rightIcon.isHidden
                }
                cellContainer.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner, .layerMaxXMinYCorner]
            }else{
                let senderName = AppData.currentUser.name
                senderLabel.text = " " + senderName + " (" + AppData.currentUser.email + ")"
                
                messageContent.textAlignment = .right
                senderLabel.textAlignment = .right
                timestampLabel.textAlignment = .right
                cellContainer.backgroundColor = UIColor.init(red: 0.8, green: 0.8, blue: 1.0, alpha: 0.1)
                senderLabel.textColor = UIColor.init(red: 0.0, green: 0.0, blue: 0.9, alpha: 0.8)
                if header {
                    rightIcon.isHidden = false
                    leftIcon.isHidden = !rightIcon.isHidden
                }
                cellContainer.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner, .layerMinXMinYCorner]
            }
            
            let timestamp = message.timestamp
            let date = Date(timeIntervalSince1970: Double(timestamp))
            timestampLabel.text = date.timeAgoSinceNow
        }
        
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
