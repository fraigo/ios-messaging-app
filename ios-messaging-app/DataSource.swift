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
    
    static var id_client = ""
    static var headers = Dictionary<String, String>()
    static var delegates : NSMutableArray = NSMutableArray()
    static var data: [String: [NSManagedObject]] = [:]
    
    static func arrayFromJsonFile(name: String) -> NSArray{
        do {
            if let filepath = Bundle.main.path(forResource: name, ofType: "json") {
                let contents = try String(contentsOfFile: filepath)
                return DataSource.parseJsonArray(data: contents.data(using: .utf8)!)
            }
        } catch {
            // contents could not be loaded
            print("Error parsing JSON data")
        }
        return NSArray()
    }
    
    static func setAuthenticationBearer(value: String){
        setAuthenticationHeader(type: "Bearer", value: value)
    }
        
    
    static func setAuthenticationHeader(type: String, value: String){
        headers["Authentication"] = "\(type) \(value)"
    }
    
    static func getJsonFromUrl(url: String, onComplete: @escaping (Data) -> Void ) {
        getJsonFromUrl(url: url, headers: headers, onComplete: onComplete)
    }
    
    static func getJsonFromUrl(url: String, headers: Dictionary<String, String>, onComplete: @escaping (Data) -> Void ) {
        //creating a NSURL
        let dataURL : String = url
        let url = URL(string: dataURL)
        
        var request = URLRequest(url: url!)
        for key in headers.keys {
            request.setValue(headers[key], forHTTPHeaderField: key)
        }
        
        //fetching the data from the url
        URLSession.shared.dataTask(with: request, completionHandler: {(data, response, error) -> Void in
            
            if error != nil {
                print("Error:")
                print(error!)
            } else {
                if let usableData = data {
                    onComplete(usableData)
                }
            }
            
        }).resume()
    }
    
    static func parseString(data: Data) -> String{
        if let string = String(data: data, encoding: String.Encoding.utf8){
            return string
        }
        return ""
    }
    
    
    static func parseJsonArray(data: Data) -> NSArray {
        
        if let string = String(data: data, encoding: String.Encoding.utf8){
            if (string.lengthOfBytes(using: .utf8)==0){
                print("Empty Data")
                return NSArray()
            }
            //print(string)
        }else{
            print("Invalid data:")
            return NSArray()
        }
        if let jsonArray = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as! NSArray {
            return jsonArray
        }else{
            print("Error trying to parse JSON")
            return NSArray()
        }
    }
    
    static func parseDictionary(data: Data, sortKey: String, itemKey: String) -> NSArray {
        if let jsonObj = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? NSDictionary {
            let descriptor: NSSortDescriptor = NSSortDescriptor(key: sortKey, ascending: false)
            if let itemArray = jsonObj!.value(forKey: itemKey) as? NSArray {
                let sortedResults: NSArray = itemArray.sortedArray(using: [descriptor]) as NSArray
                return sortedResults
            }
        }
        return NSArray()
    }

    
    static func loadDataFromUrl(url: String,entity: String){
        getJsonFromUrl(url: url) { (data) in
            let data = parseJsonArray(data: data)
            DispatchQueue.main.async{
                deleteEntities(entity: entity)
                DataSource.loadEntities(entity: entity, data: data)
                for delegate in delegates{
                    let dsDelegate = delegate as! DataSourceDelegate
                    dsDelegate.DataSourceLoaded(entity: entity)
                }
            }
            
        }
    
    }
    
    static func addDataSourceDelegate(_ delegate:DataSourceDelegate){
        if (!delegates.contains(delegate)){
            delegates.add(delegate)
        }
    }
    
    static func loadDataFromJson(entity: String){
        deleteEntities(entity: entity)
        loadEntities(entity: entity, data: arrayFromJsonFile(name: entity))
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
    
    static func getEntities(entity: String) -> [NSManagedObject]
    {
        return filterEntities(entity: entity, predicate: nil)
    }

    static func filterEntities(entity: String, predicate: NSPredicate?) -> [NSManagedObject]{
        
        var entities: [NSManagedObject] = []
        if let managedContext = getViewContext(){
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: entity)
            if (predicate != nil){
                fetchRequest.predicate = predicate
            }
            do {
                entities = try managedContext.fetch(fetchRequest)
                
            } catch let error as NSError {
                print("Could not fetch \(entity): \(error), \(error.userInfo)")
            }
        }
        return entities
    }
    
    static func deleteEntities(entity: String){
        deleteEntities(entity: entity, predicate: nil)
    }
        
    
    static func deleteEntities(entity: String, predicate: NSPredicate?){
        
        var entities: [NSManagedObject] = []
        if let managedContext = getViewContext(){
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: entity)
            if (predicate != nil){
                fetchRequest.predicate = predicate
            }
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
    
    func DataSourceLoaded(entity: String)
    
}
