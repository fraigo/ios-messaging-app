//
//  UIImageView.swift
//  ios-messaging-app
//
//  Created by Fracisco Igor on 2018-12-06.
//  Copyright © 2018 User. All rights reserved.
//

import Foundation
import UIKit

extension UIImageView {
    
    func loadImageUrl(url: String){
        if (url != ""){
            loadImage(url: url, imageView: self)
        }else{
            setImage(name: "user-icon", imageView: self)
        }
    }
}


