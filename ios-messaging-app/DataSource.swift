//
//  DataSource.swift
//  ios-messaging-app
//
//  Created by Francisco Igor on 2018-11-23.
//  Copyright © 2018 User. All rights reserved.
//

import UIKit
import CoreData

class DataSource: NSObject {
    
    static var data: [String: [NSManagedObject]] = [:]
    static var currentUser: User!
    static var endpointURL = "https://fraigo.github.io/ios-messaging-app/ios-messaging-app/"
    static var isUpdating = 0
    static var delegates = [DataSourceDelegate]()
    static var nextTime = 20.0
    
    static func loadData(){
        if let user = currentUser {
            nextTime = 20.0
            let timestamp = Date.init().timeIntervalSince1970
            
            print("Loading URLs \(timestamp)")
            isUpdating = 0
            let url1 = endpointURL + "Message.json?email=" + user.email + "&t=\(timestamp)"
            loadDataFromUrl(url : url1, entity: "Message")
            
            let url2 = endpointURL + "Sender.json?email=" + user.email + "&t=\(timestamp)"
            loadDataFromUrl(url : url2, entity: "Sender")
        }else{
            nextTime = 2.0
        }
        
    }
    
    static func autoUpdate(){
        loadData()
        DispatchQueue.main.asyncAfter(deadline: .now() + nextTime) {
            self.autoUpdate()
        }
    }
    
    static func loadDataFromUrl(url: String,entity: String){
        getJsonFromUrl(url: url) { (data) in
            let data = parseArray(data: data)
            DispatchQueue.main.async{
                deleteEntities(entity: entity)
                DataSource.loadEntities(entity: entity, data: data)
                isUpdating += 1
                if (isUpdating==2){
                    print("Loaded URLs")
                    for delegate in delegates{
                        delegate.DataSourceLoaded()
                    }
                }
            }
            
        }
    
    }
    
    static func addDataSourceDelegate(_ delegate:DataSourceDelegate){
        delegates.append(delegate)
    }
    
    static func reLoadData(entity: String){
        deleteEntities(entity: entity)
        loadEntities(entity: entity, data: arrayFromJsonFromFile(name: entity))
    }
    
    static func filterMessagesOf(email: String) -> [NSManagedObject]{
        let predicate = NSPredicate(format: "from = %@ or to = %@", email, email)
        return filterEntities(entity: "Message", predicate: predicate)
    }
    
    static func filterField(entity: String, field: String, value: Any) -> [NSManagedObject]
    {
        return filterField(entity: entity, field: field, value: value, operation: "=")
    }
    
    static func filterField(entity: String, field: String, value: Any, operation: String) -> [NSManagedObject]{
        let predicate = NSPredicate(format: "\(field) \(operation) %@", argumentArray: [value])
        return filterEntities(entity: entity, predicate: predicate)
    }
    
    static func getViewContext() -> NSManagedObjectContext? {
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return nil
        }
        return appDelegate.persistentContainer.viewContext
    }
    
    static func loadEntities(entity: String, data: NSArray) {
        
        var entities: [NSManagedObject] = []
        if let managedContext = getViewContext(){
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: entity)
            
            do {
                entities = try managedContext.fetch(fetchRequest)
                if (entities.count == 0){
                    print("Loading \(entity)...")
                    for item in data {
                        let row = item as! NSDictionary
                        createEntity(entity, data:row)
                    }
                    entities = try managedContext.fetch(fetchRequest)
                }
            } catch let error as NSException {
                print("Could not fetch \(entity): \(error)")
            } catch let error as NSError {
                print("Could not fetch \(entity): \(error), \(error.userInfo)")
            }
        }
        self.data[entity] = entities
    }
    
    static func filterEntities(entity: String, predicate: NSPredicate) -> [NSManagedObject]{
        
        var entities: [NSManagedObject] = []
        if let managedContext = getViewContext(){
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: entity)
            fetchRequest.predicate = predicate
            do {
                entities = try managedContext.fetch(fetchRequest)
                
            } catch let error as NSError {
                print("Could not fetch \(entity): \(error), \(error.userInfo)")
            }
        }
        return entities
    }
    
    
    static func deleteEntities(entity: String){
        
        var entities: [NSManagedObject] = []
        if let managedContext = getViewContext(){
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: entity)
            do {
                entities = try managedContext.fetch(fetchRequest)
                if (entities.count > 0){
                    print("Deleting")
                    for item in entities {
                        managedContext.delete(item)
                    }
                    entities.removeAll()
                }
            } catch let error as NSError {
                print("Could not fetch or delete \(entity): \(error), \(error.userInfo)")
            }
        }
    }
    
    static func createEntity(_ name: String, data: NSDictionary){
        
        if let managedContext = getViewContext(){
            let entity = NSEntityDescription.entity(forEntityName: name, in: managedContext)!
            let newEntity = NSManagedObject(entity: entity, insertInto: managedContext)
            let keys = data.allKeys
            for key in keys{
                let dataKey = key as! String
                newEntity.setValue(data.safeValue(forKey: dataKey, defaultValue: ""), forKeyPath:dataKey)
            }
            
            do {
                try managedContext.save()
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
        }
    }
    
    
    
}

protocol DataSourceDelegate {
    
    func DataSourceLoaded()
    
}
