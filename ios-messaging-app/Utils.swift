//
//  Utils.swift
//  ios-messaging-app
//
//  Created by Fracisco Igor on 2018-12-03.
//  Copyright © 2018 User. All rights reserved.
//

import UIKit
import Foundation
import AudioToolbox.AudioServices

func vibrate(){
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
}


func formatNumber( number: Double) -> String{
    return String( floor(number*10) / 10.0)
}


func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
    URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
}

func loadImage(url: String, imageView: UIImageView) {
    let imageUrl = URL(string: url)!
    getData(from: imageUrl) { data, response, error in
        guard let data = data, error == nil else { return }
        DispatchQueue.main.async() {
            imageView.image = UIImage(data: data)
        }
    }
}

func setImage(name: String, imageView: UIImageView) {
    
    if let filePath = Bundle.main.path(forResource: name, ofType: "png"), let image = UIImage(contentsOfFile: filePath) {
        imageView.contentMode = .scaleAspectFit
        imageView.image = image
    }
}

func localTime(timestamp: UInt) -> Date{
    let date = Date(timeIntervalSince1970: Double(timestamp))
    let timezone = NSTimeZone.local
    let seconds = Double(timezone.secondsFromGMT())
    return Date(timeInterval: seconds, since: date as Date)
}
