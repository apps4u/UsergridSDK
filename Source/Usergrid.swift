//
//  Usergrid.swift
//  UsergridSDK
//
//  Created by Robert Walsh on 7/21/15.
//  Copyright © 2015 Apigee. All rights reserved.
//

import Foundation

public class Usergrid: NSObject {

    internal static var _sharedClient : UsergridClient!

    public static var sharedInstance : UsergridClient {
        assert(Usergrid._sharedClient != nil, "Usergrid shared instance is not initalized!")
        return Usergrid._sharedClient
    }

    public static func initSharedInstance(orgID orgID : String, appID: String) -> UsergridClient {
        if Usergrid._sharedClient == nil {
            Usergrid._sharedClient = UsergridClient(orgID: orgID, appID: appID)
        } else {
            print("The Usergrid shared instance was already initialized. All subsequent initialization attempts (including this) will be ignored.")
        }
        return Usergrid._sharedClient
    }

    public static func initSharedInstance(orgID orgID : String, appID: String, baseURL: String) -> UsergridClient {
        if Usergrid._sharedClient == nil {
            Usergrid._sharedClient = UsergridClient(orgID: orgID, appID: appID, baseURL: baseURL)
        } else {
            print("The Usergrid shared instance was already initialized. All subsequent initialization attempts (including this) will be ignored.")
        }
        return Usergrid._sharedClient
    }

    public static func initSharedInstance(configuration configuration: UsergridClientConfig) -> UsergridClient {
        if Usergrid._sharedClient == nil {
            Usergrid._sharedClient = UsergridClient(configuration: configuration)
        }  else {
            print("The Usergrid shared instance was already initialized. All subsequent initialization attempts (including this) will be ignored.")
        }
        return Usergrid._sharedClient
    }

    public static func destroySharedClient() {
        Usergrid._sharedClient = nil
    }

    public static func authenticateApp(completion: UsergridAppAuthCompletionBlock?) {
        Usergrid.sharedInstance.authenticateApp(completion)
    }

    public static func authenticateApp(auth: UsergridAppAuth, completion: UsergridAppAuthCompletionBlock?) {
        Usergrid.sharedInstance.authenticateApp(auth, completion: completion)
    }

    public static func authenticateUser(auth: UsergridUserAuth, completion: UsergridUserAuthCompletionBlock?) {
        Usergrid.sharedInstance.authenticateUser(auth, completion: completion)
    }

    public static func authenticateUser(userAuth: UsergridUserAuth, setAsCurrentUser:Bool, completion: UsergridUserAuthCompletionBlock?) {
        Usergrid.sharedInstance.authenticateUser(userAuth, setAsCurrentUser: setAsCurrentUser, completion: completion)
    }

    // GET a single Enitity of a given type with a specific UUID/name using the shared Usergrid instance
    public static func GET(type: String, uuidOrName: String, completion: UsergridResponseCompletion?) {
        Usergrid.sharedInstance.GET(type,uuidOrName:uuidOrName,completion:completion)
    }

    // GET Entities of a given type with an optional query using the shared Usergrid instance
    public static func GET(type: String, query: UsergridQuery? = nil, completion: UsergridResponseCompletion?) {
        Usergrid.sharedInstance.GET(type,query:query,completion:completion)
    }

    // PUT Updates an Enitity with the given type and UUID/name specified using the passed in jsonBody using the shared Usergrid instance
    public static func PUT(type: String, uuidOrName: String, jsonBody:[String:AnyObject], completion: UsergridResponseCompletion?) {
        Usergrid.sharedInstance.PUT(type, uuidOrName: uuidOrName, jsonBody: jsonBody, completion: completion)
    }

    // PUT Updates an Enitity with the given type using the jsonBody where the UUID/name is specified inside of the jsonBody using the shared Usergrid instance
    public static func PUT(type: String, jsonBody:[String:AnyObject], completion: UsergridResponseCompletion?) {
        Usergrid.sharedInstance.PUT(type, jsonBody: jsonBody, completion: completion)
    }

    // PUT Updates the passed in Enitity using the shared Usergrid instance
    public static func PUT(entity: UsergridEntity, completion: UsergridResponseCompletion?) {
        Usergrid.sharedInstance.PUT(entity, completion: completion)
    }

    // PUT Updates Enitities that fit the given query using the passed in jsonBody using the shared Usergrid instance
    public static func PUT(query: UsergridQuery, jsonBody:[String:AnyObject], queryCompletion: UsergridResponseCompletion?) {
        Usergrid.sharedInstance.PUT(query, jsonBody: jsonBody, queryCompletion: queryCompletion)
    }

    // POST Creates an Enitity of the given type with a given name and the given jsonBody using the shared Usergrid instance
    public static func POST(type: String, name: String, jsonBody:[String:AnyObject], completion: UsergridResponseCompletion?) {
        Usergrid.sharedInstance.POST(type, name: name, jsonBody: jsonBody, completion: completion)
    }

    // POST Creates an Entity of the given type with the given jsonBody using the shared Usergrid instance
    public static func POST(type: String, jsonBody:[String:AnyObject], completion: UsergridResponseCompletion?) {
        Usergrid.sharedInstance.POST(type, jsonBody: jsonBody, completion: completion)
    }

    // POST Creates an array of Entities while assinging the given type to them using the shared Usergrid instance
    public static func POST(type: String, jsonBodies:[[String:AnyObject]], completion: UsergridResponseCompletion?) {
        Usergrid.sharedInstance.POST(type, jsonBodies: jsonBodies, completion: completion)
    }

    // POST Creates an Entity using the shared Usergrid instance
    public static func POST(entity:UsergridEntity, completion: UsergridResponseCompletion?) {
        Usergrid.sharedInstance.POST(entity, completion: completion)
    }

    // POST Creates an array of Entities. Each Enitity in the array much already have a type assinged using the shared Usergrid instance
    public static func POST(entities:[UsergridEntity], entitiesCompletion: UsergridResponseCompletion?) {
        Usergrid.sharedInstance.POST(entities, entitiesCompletion: entitiesCompletion)
    }

    public static func DELETE(type:String, uuidOrName: String, completion: UsergridResponseCompletion?) {
        Usergrid.sharedInstance.DELETE(type, uuidOrName: uuidOrName, completion: completion)
    }

    public static func DELETE(entity:UsergridEntity, completion: UsergridResponseCompletion?) {
        Usergrid.sharedInstance.DELETE(entity, completion:completion)
    }

    public static func DELETE(query:UsergridQuery, queryCompletion: UsergridResponseCompletion?) {
        Usergrid.sharedInstance.DELETE(query, queryCompletion:queryCompletion)
    }

    public static func CONNECT(entity:UsergridEntity, relationship:String, connectingEntity:UsergridEntity, completion: UsergridResponseCompletion?) {
        Usergrid.sharedInstance.CONNECT(entity, relationship: relationship, connectingEntity: connectingEntity, completion: completion)
    }

    public static func DISCONNECT(entity:UsergridEntity, relationship:String, connectingEntity:UsergridEntity, completion: UsergridResponseCompletion?) {
        Usergrid.sharedInstance.DISCONNECT(entity, relationship: relationship, connectingEntity: connectingEntity, completion: completion)
    }

    public static func uploadAsset(entity:UsergridEntity, asset:UsergridAsset, progress:UsergridAssetRequestProgress? = nil, completion:UsergridAssetUploadCompletion?) {
        Usergrid.sharedInstance.uploadAsset(entity, asset: asset, progress: progress, completion: completion)
    }

    public static func downloadAsset(entity:UsergridEntity, contentType:String, progress:UsergridAssetRequestProgress? = nil, completion:UsergridAssetDownloadCompletion?) {
        Usergrid.sharedInstance.downloadAsset(entity, contentType: contentType, progress: progress, completion: completion)
    }
}
