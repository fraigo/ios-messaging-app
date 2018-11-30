//
//  MenuTableViewCell.swift
//  ios-messaging-app
//
//  Created by User on 2018-11-23.
//  Copyright © 2018 User. All rights reserved.
//

import UIKit
import CoreData

class MenuTableViewCell: UITableViewCell {

    @IBOutlet weak var senderName: UILabel!
    @IBOutlet weak var senderStatus: UILabel!
   
    
    var object : NSManagedObject!
    
    func setItem(_ obj: NSManagedObject){
        self.object = obj
        if (senderName != nil){
            updateView()
        }
    }
    
    override func didMoveToWindow() {
        updateView()
    }
    
    func updateView(){
        if let item = object {
            print(item.value(forKey: "name") ?? "N/A")
            senderName.text = item.value(forKey: "name") as? String
            senderStatus.text = item.value(forKey: "email") as? String
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
