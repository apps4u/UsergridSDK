//
//  UsergridManager.swift
//  ActivityFeed
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
    static let NOTIFIER_ID = "usergridsample"

    static func initializeSharedInstance() {
        Usergrid.initSharedInstance(configuration: UsergridClientConfig(orgId: UsergridManager.ORG_ID, appId: UsergridManager.APP_ID))
        ActivityEntity.registerSubclass()
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

    static func getFeedMessages(completion:UsergridResponseCompletion) {
        Usergrid.GET("users/me/feed", query: UsergridQuery().desc(UsergridEntityProperties.Created.stringValue), completion: completion)
    }

    static func postFeedMessage(text:String,completion:UsergridResponseCompletion) {
        let currentUser = Usergrid.currentUser!

        let verb = "post"
        let content = text

        var actorDictionary = [String:AnyObject]()
        actorDictionary["displayName"] = currentUser.name ?? currentUser.usernameOrEmail ?? ""
        actorDictionary["email"] = currentUser.email ?? ""
        if let imageURL = currentUser.picture {
            actorDictionary["image"] = ["url":imageURL,"height":80,"width":80]
        }

        Usergrid.POST("users/me/activities", jsonBody: ["actor":actorDictionary,"verb":verb,"content":content], completion: completion)
    }

    static func followUser(username:String, completion:UsergridResponseCompletion) {
        Usergrid.connect("users", entityID: "me", relationship: "following", toType: "users", toName: username, completion: completion)
    }
}