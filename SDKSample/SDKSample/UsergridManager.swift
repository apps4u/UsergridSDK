//
//  UsergridManager.swift
//  SDKSample
//
//  Created by Robert Walsh on 1/19/16.
//  Copyright © 2016 Apigee Inc. All rights reserved.
//

import Foundation
import UsergridSDK

/// This class handles the primary communications to Usergird used by the iOS and watchOS applications.
public class UsergridManager {

    static let ORG_ID = "rwalsh"
    static let APP_ID = "sandbox"
    static let NOTIFIER_ID = "usergridsample"

    static let MESSAGE_ENTITY_TYPE = "sdkmessage"
    static let MESSAGE_ENTITY_CREATOR = "creator"
    static let MESSAGE_ENTITY_TEXT = "text"
    static let MESSAGE_ENTITY_CREATOR_THUMBNAIL = "creatorThumb"

    static func initializeSharedInstance() {
        Usergrid.initSharedInstance(configuration: UsergridClientConfig(orgId: UsergridManager.ORG_ID, appId: UsergridManager.APP_ID))
    }

    static func loginUser(username:String, password:String, completion:UsergridUserAuthCompletionBlock) {
        let userAuth = UsergridUserAuth(username: username, password: password)
        Usergrid.authenticateUser(userAuth, completion: completion)
    }

    static func createUser(name:String, username:String, email:String, password:String, completion:UsergridResponseCompletion) {
        let user = UsergridUser(name: name, propertyDict: [UsergridUserProperties.Username.stringValue:username,
                                                            UsergridUserProperties.Email.stringValue:email,
                                                            UsergridUserProperties.Password.stringValue:password])
        user.create(completion)
    }

    static func getMessages(completion:UsergridResponseCompletion) {
        let sortByCreatedDateQuery = UsergridQuery().desc(UsergridEntityProperties.Created.stringValue)
        Usergrid.GET(UsergridManager.MESSAGE_ENTITY_TYPE, query:sortByCreatedDateQuery, completion: completion)
    }

    static func postMessage(text:String) -> UsergridEntity {
        var messageEntityProperties: [String:String] = [:]
        messageEntityProperties[UsergridManager.MESSAGE_ENTITY_CREATOR] = Usergrid.currentUser?.usernameOrEmail ?? ""
        messageEntityProperties[UsergridManager.MESSAGE_ENTITY_CREATOR_THUMBNAIL] = Usergrid.currentUser?.picture ?? ""
        messageEntityProperties[UsergridManager.MESSAGE_ENTITY_TEXT] = text

        let messageEntity = UsergridEntity(type: UsergridManager.MESSAGE_ENTITY_TYPE, propertyDict: messageEntityProperties)

        messageEntity.save { (response) -> Void in
            if let errorDescription = response.error?.errorDescription {
                print("Uploading message error: \(errorDescription)")
            }
        }
        return messageEntity
    }
}