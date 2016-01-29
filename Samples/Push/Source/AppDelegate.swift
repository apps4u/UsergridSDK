//
//  AppDelegate.swift
//  Push
//
//  Created by Robert Walsh on 1/29/16.
//  Copyright © 2016 Apigee Inc. All rights reserved.
//

import UIKit
import UsergridSDK

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

        UsergridManager.initializeSharedInstance()

        application.registerUserNotificationSettings(UIUserNotificationSettings( forTypes: [.Alert, .Badge, .Sound], categories: nil))
        application.registerForRemoteNotifications()

        return true
    }

    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        UsergridManager.applyPushToken(deviceToken)
    }

    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        print("Application failed to register for remote notifications")
    }
}

