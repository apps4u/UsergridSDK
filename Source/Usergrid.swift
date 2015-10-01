//
//  Usergrid.swift
//  UsergridSDK
//
//  Created by Robert Walsh on 7/21/15.
//  Copyright © 2015 Apigee. All rights reserved.
//

import Foundation

public class Usergrid: NSObject {

    public static let shared : UsergridClient = UsergridClient()

    public static func initialize(orgID : String, appID: String, url: String = UsergridClient.DEFAULT_BASE_URL) -> UsergridClient {
        return Usergrid.shared.initialize(orgID,appID:appID,url:url)
    }

    public static func initialize(configuration: [UsergridClient.Config:AnyObject]) -> UsergridClient {
        return Usergrid.shared.initialize(configuration)
    }

    public static func authenticateApp(auth: UsergridAppAuth? = nil, completion: UsergridAppAuthCompletionBlock) {
        Usergrid.shared.authenticateApp(auth, completion: completion)
    }

    public static func authenticateUser(auth: UsergridUserAuth, completion: UsergridUserAuthCompletionBlock) {
        Usergrid.shared.authenticateUser(auth, completion: completion)
    }

    // GET a single Enitity of a given type with a specific UUID/name using the shared Usergrid instance
    public static func GET(type: String, uuidOrName: String, completion: UsergridResponseCompletionBlock) {
        Usergrid.shared.GET(type,uuidOrName:uuidOrName,completion:completion)
    }

    // GET Entities of a given type with an optional query using the shared Usergrid instance
    public static func GET(type: String, query: UsergridQuery? = nil, completion: UsergridResponseCompletionBlock) {
        Usergrid.shared.GET(type,query:query,completion:completion)
    }

    // PUT Updates an Enitity with the given type and UUID/name specified using the passed in jsonBody using the shared Usergrid instance
    public static func PUT(type: String, uuidOrName: String, jsonBody:[String:AnyObject], completion: UsergridResponseCompletionBlock) {
        Usergrid.shared.PUT(type, uuidOrName: uuidOrName, jsonBody: jsonBody, completion: completion)
    }

    // PUT Updates an Enitity with the given type using the jsonBody where the UUID/name is specified inside of the jsonBody using the shared Usergrid instance
    public static func PUT(type: String, jsonBody:[String:AnyObject], completion: UsergridResponseCompletionBlock) {
        Usergrid.shared.PUT(type, jsonBody: jsonBody, completion: completion)
    }

    // PUT Updates the passed in Enitity using the shared Usergrid instance
    public static func PUT(entity: UsergridEntity, completion: UsergridResponseCompletionBlock) {
        Usergrid.shared.PUT(entity, completion: completion)
    }

    // PUT Updates Enitities that fit the given query using the passed in jsonBody using the shared Usergrid instance
    public static func PUT(query: UsergridQuery, jsonBody:[String:AnyObject], queryCompletion: UsergridResponseCompletionBlock) {
        Usergrid.shared.PUT(query, jsonBody: jsonBody, queryCompletion: queryCompletion)
    }

    // POST Creates an Enitity of the given type with a given name and the given jsonBody using the shared Usergrid instance
    public static func POST(type: String, name: String, jsonBody:[String:AnyObject], completion: UsergridResponseCompletionBlock) {
        Usergrid.shared.POST(type, name: name, jsonBody: jsonBody, completion: completion)
    }

    // POST Creates an Entity of the given type with the given jsonBody using the shared Usergrid instance
    public static func POST(type: String, jsonBody:[String:AnyObject], completion: UsergridResponseCompletionBlock) {
        Usergrid.shared.POST(type, jsonBody: jsonBody, completion: completion)
    }

    // POST Creates an array of Entities while assinging the given type to them using the shared Usergrid instance
    public static func POST(type: String, jsonBodies:[[String:AnyObject]], completion: UsergridResponseCompletionBlock) {
        Usergrid.shared.POST(type, jsonBodies: jsonBodies, completion: completion)
    }

    // POST Creates an Entity using the shared Usergrid instance
    public static func POST(entity:UsergridEntity, completion: UsergridResponseCompletionBlock) {
        Usergrid.shared.POST(entity, completion: completion)
    }

    // POST Creates an array of Entities. Each Enitity in the array much already have a type assinged using the shared Usergrid instance
    public static func POST(entities:[UsergridEntity], entitiesCompletion: UsergridResponseCompletionBlock) {
        Usergrid.shared.POST(entities, entitiesCompletion: entitiesCompletion)
    }

    public static func DELETE(type:String, uuidOrName: String, completion: UsergridResponseCompletionBlock) {
        Usergrid.shared.DELETE(type, uuidOrName: uuidOrName, completion: completion)
    }

    public static func DELETE(entity:UsergridEntity, completion: UsergridResponseCompletionBlock) {
        Usergrid.shared.DELETE(entity, completion:completion)
    }

    public static func DELETE(query:UsergridQuery, queryCompletion: UsergridResponseCompletionBlock) {
        Usergrid.shared.DELETE(query, queryCompletion:queryCompletion)
    }
}
