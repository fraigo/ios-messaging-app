//
//  AppDataSource.swift
//  ios-messaging-app
//
//  Created by Fracisco Igor on 2018-12-05.
//  Copyright © 2018 User. All rights reserved.
//

import Foundation
import GoogleSignIn
import CoreData

class AppData : NSObject {
    
    static var nextTime = 10.0
    static var endpointURL = ""
    static var currentUser: User!
    
    
    static func initDataSource(user: User){
        endpointURL = "https://message-chat-api.herokuapp.com/index.php/"
        currentUser = user
        DataSource.setAuthenticationBearer(value: user.idToken)
        DataSource.headers["Client-Id"] = GIDSignIn.sharedInstance().clientID
        DataSource.headers["Auth-Token"] = user.authToken
        
        registerUser()
        loadData()
    }
    
    static func closeDataSource(){
        currentUser = nil
    }
    
    static func UrlEncode(text: String) -> String {
        return text.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
    }
    
    static func loadData(){
        if let user = currentUser {
            nextTime = 10.0
            let timestamp = Date.init().timeIntervalSince1970
            
            print("Loading URLs \(timestamp)")
            
            let url1 = endpointURL + "Message/get/" + user.email + "/?t=\(timestamp)"
            DataSource.loadDataFromUrl(url : url1, entity: "Message")
            
            let url2 = endpointURL + "Sender/get/" + user.email + "/?t=\(timestamp)"
            DataSource.loadDataFromUrl(url : url2, entity: "Sender")
        }else{
            nextTime = 3.0
        }
        
    }
    
    static func clearData(){
        DataSource.deleteEntities(entity: "Message")
        DataSource.deleteEntities(entity: "Sender")
        DataSource.deleteEntities(entity: "Contact")
        for delegate in DataSource.delegates{
            let delegate = delegate as! DataSourceDelegate
            delegate.DataSourceLoaded(entity: "Sender")
            delegate.DataSourceLoaded(entity: "Message")
            delegate.DataSourceLoaded(entity: "Contact")
            
        }
        
    }
    
    static func autoUpdate(){
        loadData()
        DispatchQueue.main.asyncAfter(deadline: .now() + nextTime) {
            self.autoUpdate()
        }
    }
    
    static func registerUser(){
        let name=UrlEncode(text: currentUser.name)
        let image=UrlEncode(text: currentUser.image)
        if currentUser != nil {
            let url1 = endpointURL + "User/register/\(currentUser.email)/?name=\(name)&imageUrl=\(image)"
            DataSource.getJsonFromUrl(url: url1) { (data) in
                let contacts = DataSource.parseDictionary(data: data, sortKey: "name", itemKey: "contacts")
                DispatchQueue.main.async{
                    DataSource.loadEntities(entity: "Contact", data: contacts)
                }
            }
        }
    }
    
    static func filterMessagesOf(email: String) -> [NSManagedObject]{
        let predicate = NSPredicate(format: "from = %@ or to = %@", email, email)
        return DataSource.filterEntities(entity: "Message", predicate: predicate)
    }
    
    static func filterMessagesOf(email: String, from: Int) -> [NSManagedObject]{
        let predicate = NSPredicate(format: "(from = %@ or to = %@) and timestamp >= %d", email, email, from)
        return DataSource.filterEntities(entity: "Message", predicate: predicate)
    }
    
    static func messageData(message: String, toEmail:String) -> NSDictionary{
        return  [
            "message" :  message,
            "to" :  toEmail,
            "from" : currentUser.email,
            "visible" : 1,
            "timestamp" : NSDate().timeIntervalSince1970
        ]
    }
    
    static func createMessage(data: NSDictionary){
        DataSource.createEntity("Message", data: data)
        addMessage(message: data.value(forKey: "message") as! String, to: data.value(forKey: "to") as! String, from: data.value(forKey: "from") as! String)
    }
    
    static func addMessage(message: String, to: String, from: String){
        if let escapedMessage = message.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) {
            
            if currentUser != nil {
                let url1 = endpointURL + "Message/push/\(from)/?to=\(to)&message=\(escapedMessage)"
                DataSource.getJsonFromUrl(url: url1) { (data) in
                    //let data = parseString(data:data)
                    //print(data)
                }
            }
        }
    }
    
    static func getSender(email : String) -> Sender? {
        let senders = DataSource.filterField(entity: "Sender", field: "email", value: email)
        if senders.count>0 {
            return senders[0] as? Sender
        }
        return nil
    }
    
    static func updateChatHistory(email: String){
        let history : NSDictionary = [
            "email" :  email,
            "lastcheck" : NSDate().timeIntervalSince1970
        ]
        let predicate = NSPredicate(format: "email = %@", email)
        DataSource.deleteEntities(entity: "History", predicate: predicate)
        DataSource.createEntity("History", data: history)
    }
    
    static func getLastChatHistory(email: String) -> Int {
        let historyData = DataSource.getEntities(entity: "History")
        var result : Int = 0
        for item in historyData {
            let history = item as! History
            result = max(Int(history.lastcheck), result)
        }
        return result
    }
    
    static func getSenders() -> [NSManagedObject] {
        return DataSource.filterField(entity: "Sender", field: "email", value: currentUser.email, operation: "<>")
    }
    
    static func pendingMessages(senders: [NSManagedObject]) -> Int{
        var pendingMessages = 0
        for item in senders {
            let sender = item as! Sender
            let timestamp = AppData.getLastChatHistory(email: sender.email!)
            pendingMessages += AppData.filterMessagesOf(email: sender.email!, from: timestamp).count
        }
        return pendingMessages
    }
    
}
