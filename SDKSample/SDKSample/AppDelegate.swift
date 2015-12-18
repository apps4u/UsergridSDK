//
//  AppDelegate.swift
//  SDKSample
//
//  Created by Robert Walsh on 11/19/15.
//  Copyright © 2015 Apigee Inc. All rights reserved.
//

import UIKit
import UsergridSDK


// TODO: Change the values to correspond to your organization, application, and notifier identifiers.

let ORG_ID = "rwalsh"
let APP_ID = "sandbox"
let NOTIFIER_ID = "usergridsample"

@UIApplicationMain class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

        // Initialize the Usergrid shared instance.
        Usergrid.initSharedInstance(configuration: UsergridClientConfig(orgID: ORG_ID, appID: APP_ID))

        application.registerUserNotificationSettings(UIUserNotificationSettings( forTypes: [.Alert, .Badge, .Sound], categories: nil))
        application.registerForRemoteNotifications()

        UINavigationBar.appearance().tintColor = UIColor.whiteColor()

        return true
    }

    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        Usergrid.applyPushToken(deviceToken, notifierID: NOTIFIER_ID, completion: nil)
    }

    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        print("Application failed to register for remote notifications")
    }
}

