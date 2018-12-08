//
//  AppDelegate.extension.swift
//  ios-messaging-app
//
//  Created by Francisco Igor on 2018-12-07.
//  Copyright © 2018 User. All rights reserved.
//
import UIKit

extension AppDelegate {
    
    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
        ) {
        let tokenParts = deviceToken.map
            { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        print("My Device Token: \(token)")
    }
    
    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Error registering notifications: \(error)")
    }
}
