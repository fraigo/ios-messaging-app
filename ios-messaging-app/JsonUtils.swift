//
//  Utils.swift
//  ios-cognitive-test
//
//  Created by Francisco Igor on 2018-11-05.
//  Copyright © 2018 franciscoigor. All rights reserved.
//

import UIKit



func arrayFromJsonFromFile(name: String) -> NSArray{
    do {
        if let filepath = Bundle.main.path(forResource: name, ofType: "json") {
            let contents = try String(contentsOfFile: filepath)
            return parseArray(data: contents.data(using: .utf8)!)
        }
    } catch {
        // contents could not be loaded
        print("Error parsing JSON data")
    }
    return NSArray()
}

func getJsonFromUrl(url: String, onComplete: @escaping (Data) -> Void ) {
    //creating a NSURL
    let dataURL : String = url
    let url = NSURL(string: dataURL)
    
    //fetching the data from the url
    URLSession.shared.dataTask(with: (url as URL?)!, completionHandler: {(data, response, error) -> Void in
        
        if error != nil {
            print(error!)
        } else {
            if let usableData = data {
                onComplete(usableData)
            }
        }
        
    }).resume()
}

func parseString(data: Data) -> String{
    if let string = String(data: data, encoding: String.Encoding.utf8){
        return string
    }
    return ""
}


func parseArray(data: Data) -> NSArray {
    
    if let string = String(data: data, encoding: String.Encoding.utf8){
        print(string)
    }
    if let jsonArray = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as! NSArray {
        return jsonArray
    }else{
        print("Error trying to parse JSON")
        return NSArray()
    }
}

func parseDictionary(data: Data, key: String, items: String) -> NSArray {
    if let jsonObj = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? NSDictionary {
        let descriptor: NSSortDescriptor = NSSortDescriptor(key: key, ascending: false)
        if let itemArray = jsonObj!.value(forKey: items) as? NSArray {
            let sortedResults: NSArray = itemArray.sortedArray(using: [descriptor]) as NSArray
            return sortedResults
        }
    }
    return NSArray()
}

func formatNumber( number: Double) -> String{
    return String( floor(number*10) / 10.0)
}

