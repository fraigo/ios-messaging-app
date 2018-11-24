//
//  DataSource.swift
//  ios-messaging-app
//
//  Created by User on 2018-11-23.
//  Copyright © 2018 User. All rights reserved.
//

import UIKit
import CoreData

class DataSource: NSObject {
    
    static var senders: [NSManagedObject] = []
    static var messages: [NSManagedObject] = []
    
    static func loadData(){
        
        deleteEntities(entity: "Sender")
        senders = loadEntities(entity: "Sender", data: arrayFromJsonFromFile(name: "Sender"))
        print(senders)
        deleteEntities(entity: "Message")
        messages = loadEntities(entity: "Message", data: arrayFromJsonFromFile(name: "Message"))
        print(messages)
    }
    
    
    static func filterMessagesOf(email: String) -> [NSManagedObject]{
        let predicate = NSPredicate(format: "from = %@ or to = %@", email, email)
        return filterEntities(entity: "Message", predicate: predicate)
    }
    
    static func getViewContext() -> NSManagedObjectContext? {
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return nil
        }
        return appDelegate.persistentContainer.viewContext
    }
    
    static func loadEntities(entity: String, data: NSArray) -> [NSManagedObject]{
        
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
            } catch let error as NSError {
                print("Could not fetch \(entity): \(error), \(error.userInfo)")
            }
        }
        return entities
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
                newEntity.setValue(data.safeValue(forKey: dataKey, defaultValue: "") , forKeyPath:dataKey)
            }
            
            do {
                try managedContext.save()
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
        }
    }
    
    

}
