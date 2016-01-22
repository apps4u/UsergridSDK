//
//  AppDelegate.swift
//  ActivityFeed
//
//  Created by Robert Walsh on 11/19/15.
//  Copyright © 2015 Apigee Inc. All rights reserved.
//

import UIKit
import UsergridSDK

// TODO: Change the values to correspond to your organization, application, and notifier identifiers.

@UIApplicationMain class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
        application.registerUserNotificationSettings(UIUserNotificationSettings( forTypes: [.Alert, .Badge, .Sound], categories: nil))
        application.registerForRemoteNotifications()

        // Initialize the Usergrid shared instance.
        UsergridManager.initializeSharedInstance()

        // If there is a current user already logged in from the keychain we will skip the login page and go right to the chat screen

        if Usergrid.currentUser != nil {
            let rootViewController = self.window!.rootViewController as! UINavigationController
            let loginViewController = rootViewController.viewControllers.first!
            loginViewController.performSegueWithIdentifier("loginSuccessNonAnimatedSegue", sender: loginViewController)
        }

        return true
    }

    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        Usergrid.applyPushToken(deviceToken, notifierID: UsergridManager.NOTIFIER_ID, completion: nil)
    }

    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        print("Application failed to register for remote notifications")
    }
}

