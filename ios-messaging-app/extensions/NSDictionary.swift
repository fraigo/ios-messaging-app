//
//  Extensions.swift
//  ios-messaging-app
//
//  Created by Fracisco Igor on 2018-11-23.
//  Copyright © 2018 User. All rights reserved.
//

import Foundation


extension NSDictionary {
    
    func safeString(forKey: String, defaultValue: String) -> String{
        if let result=self.value(forKeyPath: forKey){
            if (result is NSNull){
                return defaultValue
            }
            return result as! String
        }else{
            return defaultValue
        }
    }
    
    func safeValue(forKey: String, defaultValue: Any) -> Any{
        if let result=self.value(forKeyPath: forKey){
            if (result is NSNull){
                return defaultValue
            }
            return result
        }else{
            return defaultValue
        }
    }
    
    func isEmpty(key: String) -> Bool{
        if let result=self.value(forKey: key){
            if (result is NSNull){
                return true
            }
            return false
        }else{
            return true
        }
    }
}
