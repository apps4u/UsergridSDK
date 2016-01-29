//
//  UsergridManager.swift
//  Push
//
//  Created by Robert Walsh on 1/19/16.
//  Copyright © 2016 Apigee Inc. All rights reserved.
//

import Foundation
import UsergridSDK

/// This class handles the primary communications to the UsergirdSDK.
public class UsergridManager {

    static let ORG_ID = "rwalsh"
    static let APP_ID = "sandbox"
    static let NOTIFIER_ID = "usergridpushsample"

    static func initializeSharedInstance() {
        Usergrid.initSharedInstance(configuration: UsergridClientConfig(orgId: UsergridManager.ORG_ID, appId: UsergridManager.APP_ID))
    }

    static func applyPushToken(deviceToken:NSData) {
        Usergrid.applyPushToken(deviceToken, notifierID: UsergridManager.NOTIFIER_ID, completion: { (response) -> Void in
            print("Apply token completed successfully : \(response.ok)")
            if !response.ok, let errorDescription = response.error?.errorDescription {
                print("Error Description : \(errorDescription)")
            }
        })
    }

    static func sendPush(deviceId deviceId:String,message:String) {
        let pushRequest = UsergridRequest(method: .Post,
                                          baseUrl: Usergrid.clientAppURL,
                                          paths: ["devices",deviceId,"notifications"],
                                          auth: Usergrid.authForRequests(),
                                          jsonBody: ["payloads":[UsergridManager.NOTIFIER_ID:message]])
        Usergrid.sendRequest(pushRequest, completion: { (response) -> Void in
            print("Push request completed successfully : \(response.ok)")
            if !response.ok, let errorDescription = response.error?.errorDescription {
                print("Error Description : \(errorDescription)")
            }
        })
    }

    static func pushToThisDevice() {
        UsergridManager.sendPush(deviceId: UsergridDevice.sharedDevice.uuid!, message: "Push to this device message.")
    }

    static func pushToAllDevices() {
        UsergridManager.sendPush(deviceId: "*", message: "Push to all devices message.")
    }
}