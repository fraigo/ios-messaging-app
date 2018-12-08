//
//  UIView.swift
//  ios-messaging-app
//
//  Created by Fracisco Igor on 2018-12-06.
//  Copyright © 2018 User. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    
    func borderRadius( radius: CGFloat){
        self.layer.cornerRadius = radius
        self.layer.masksToBounds = true
    }
    
    func rounded(){
        self.borderRadius( radius: self.frame.width/2 )
    }
    
    func bordered( radius: CGFloat, color: UIColor){
        borderRadius(radius: radius)
        self.layer.borderColor = color.cgColor
        self.layer.borderWidth = 1.0
        self.layer.shadowRadius = 4
        self.layer.shadowColor = color.cgColor
    }
    
}
